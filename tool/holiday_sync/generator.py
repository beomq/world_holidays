"""Pure holiday merge and rendering operations."""

from __future__ import annotations

from typing import TYPE_CHECKING, Protocol

from .models import (
    CountryEntry,
    CountryIndex,
    CountryPayload,
    CuratedDriftReport,
    CuratedYearGap,
    Description,
    HolidayRecord,
    Overrides,
)
from .renderers import render_dart, write_json

if TYPE_CHECKING:
    from collections.abc import Iterable, Sequence
    from datetime import date
    from pathlib import Path


class BaselineProvider(Protocol):
    """Calculated public-holiday source."""

    @property
    def version(self) -> str:
        """Return the source library version."""
        ...

    def holidays_for(
        self,
        country_code: str,
        years: Sequence[int],
    ) -> tuple[HolidayRecord, ...]:
        """Calculate holidays for a country and year set."""
        ...


def _replace_text(value: str, replacements: dict[str, str]) -> str:
    for source, target in replacements.items():
        value = value.replace(source, target)
    return value


def _normalize_text(
    holiday: HolidayRecord,
    replacements: dict[str, str],
) -> HolidayRecord:
    return holiday.model_copy(
        update={
            "name": _replace_text(holiday.name, replacements),
            "description": Description(
                en=_replace_text(holiday.description.en, replacements),
                ko=_replace_text(holiday.description.ko, replacements),
            ),
        }
    )


def find_curated_year_gaps(
    country_code: str,
    existing: Iterable[HolidayRecord],
    baseline: Iterable[HolidayRecord],
    overrides: Overrides,
) -> tuple[HolidayRecord, ...]:
    """Find calculated dates not acknowledged by authoritative curated data."""
    curated_years = set(overrides.curated_years.get(country_code, ()))
    acknowledged_dates = {
        holiday.date for holiday in existing if holiday.date.year in curated_years
    }
    acknowledged_dates.update(
        removal.date
        for removal in overrides.removals
        if removal.country == country_code
    )
    acknowledged_dates.update(
        upsert.holiday.date
        for upsert in overrides.upserts
        if upsert.country == country_code
    )
    return tuple(
        holiday
        for holiday in baseline
        if holiday.date.year in curated_years and holiday.date not in acknowledged_dates
    )


def merge_records(
    country_code: str,
    existing: Iterable[HolidayRecord],
    baseline: Iterable[HolidayRecord],
    overrides: Overrides,
) -> tuple[HolidayRecord, ...]:
    """Merge curated records, calculated years, and reviewed corrections."""
    curated_years = set(overrides.curated_years.get(country_code, ()))
    selected = [holiday for holiday in existing if holiday.date.year in curated_years]
    selected.extend(
        holiday for holiday in baseline if holiday.date.year not in curated_years
    )

    normalized = [
        _normalize_text(holiday, overrides.text_replacements) for holiday in selected
    ]
    removals = {
        (removal.date, removal.name)
        for removal in overrides.removals
        if removal.country == country_code
    }
    by_identity: dict[tuple[date, str], HolidayRecord] = {}
    for holiday in normalized:
        if holiday.identity in by_identity:
            msg = (
                "Duplicate holiday identity: "
                f"{country_code} {holiday.date} {holiday.name}"
            )
            raise ValueError(msg)
        if holiday.identity not in removals:
            by_identity[holiday.identity] = holiday

    for upsert in overrides.upserts:
        if upsert.country == country_code:
            holiday = _normalize_text(
                upsert.holiday,
                overrides.text_replacements,
            )
            by_identity[holiday.identity] = holiday

    return tuple(sorted(by_identity.values(), key=lambda item: (item.date, item.name)))


def generate_repository(
    root: Path,
    current_year: int,
    provider: BaselineProvider,
    generated_on: date | None = None,
) -> tuple[Path, ...]:
    """Generate hosted metadata and bundled Dart from reviewed inputs."""
    overrides = Overrides.model_validate_json(
        (root / "data/overrides.json").read_text(encoding="utf-8")
    )
    index_path = root / "api/countries.json"
    index = CountryIndex.model_validate_json(index_path.read_text(encoding="utf-8"))
    target_years = tuple(range(current_year - 1, current_year + 3))
    generated: dict[str, tuple[HolidayRecord, ...]] = {}
    curated_gaps: list[CuratedYearGap] = []
    payloads: list[CountryPayload] = []
    written: list[Path] = []
    content_changed = False

    for country in index.countries:
        payload_path = root / f"api/holidays/{country.code.lower()}.json"
        payload = CountryPayload.model_validate_json(
            payload_path.read_text(encoding="utf-8")
        )
        baseline = provider.holidays_for(country.code, target_years)
        curated_gaps.extend(
            CuratedYearGap(country=country.code, holiday=holiday)
            for holiday in find_curated_year_gaps(
                country.code,
                payload.holidays,
                baseline,
                overrides,
            )
        )
        holidays = merge_records(
            country.code,
            payload.holidays,
            baseline,
            overrides,
        )
        payload_changed = holidays != payload.holidays
        content_changed = content_changed or payload_changed
        years = tuple(sorted({holiday.date.year for holiday in holidays}))
        generated[country.code] = holidays
        updated_payload = payload.model_copy(
            update={
                "last_updated": (
                    f"{generated_on.isoformat()}T00:00:00.000Z"
                    if payload_changed and generated_on is not None
                    else payload.last_updated
                ),
                "supported_years": years,
                "total_holidays": len(holidays),
                "holidays": holidays,
            }
        )
        write_json(payload_path, updated_payload)
        payloads.append(updated_payload)
        written.append(payload_path)

    drift_path = root / "data/curated-drift.json"
    write_json(drift_path, CuratedDriftReport(gaps=tuple(curated_gaps)))
    written.append(drift_path)

    supported_years = tuple(
        sorted({year for payload in payloads for year in payload.supported_years})
    )
    counts = {payload.country: payload.total_holidays for payload in payloads}
    countries = tuple(
        CountryEntry.model_validate(
            country.model_dump(mode="json", by_alias=True)
            | {"totalHolidays": counts[country.code]}
        )
        for country in index.countries
    )
    updated_index = index.model_copy(
        update={
            "last_updated": (
                f"{generated_on.isoformat()}T00:00:00.000Z"
                if content_changed and generated_on is not None
                else index.last_updated
            ),
            "total_countries": len(countries),
            "supported_countries": tuple(country.code for country in countries),
            "supported_years": supported_years,
            "total_holidays": sum(counts.values()),
            "countries": countries,
        }
    )
    write_json(index_path, updated_index)
    written.append(index_path)

    dart_path = root / "lib/src/generated/holiday_data.g.dart"
    dart_path.parent.mkdir(parents=True, exist_ok=True)
    _ = dart_path.write_text(
        render_dart(generated, supported_years, provider.version),
        encoding="utf-8",
    )
    written.append(dart_path)
    return tuple(written)
