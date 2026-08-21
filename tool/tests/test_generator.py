"""Regression tests for deterministic holiday generation."""

from __future__ import annotations

import json
from datetime import date
from typing import TYPE_CHECKING

import pytest

from tool.holiday_sync import (
    HolidayRecord,
    HolidayType,
    Overrides,
    generate_repository,
    merge_records,
)
from tool.holiday_sync.models import CountryIndex, CountryPayload, Description
from tool.holiday_sync.providers import PythonHolidaysProvider

if TYPE_CHECKING:
    from collections.abc import Sequence
    from pathlib import Path


class FakeBaselineProvider:
    @property
    def version(self) -> str:
        return "test-1"

    def holidays_for(
        self,
        country_code: str,
        years: Sequence[int],
    ) -> tuple[HolidayRecord, ...]:
        assert country_code == "KR"
        return tuple(holiday(f"Calculated {year}", date(year, 1, 1)) for year in years)


def holiday(name: str, value: date) -> HolidayRecord:
    return HolidayRecord(
        name=name,
        date=value,
        type=HolidayType.NATIONAL,
        description=Description(en=name, ko=name),
    )


def overrides(
    *,
    replacements: dict[str, str] | None = None,
    removals: list[dict[str, str]] | None = None,
    upserts: list[dict[str, object]] | None = None,
) -> Overrides:
    return Overrides.model_validate(
        {
            "version": 1,
            "curatedYears": {"KR": [2026]},
            "textReplacements": replacements or {},
            "removals": removals or [],
            "upserts": upserts or [],
        }
    )


def test_curated_year_replaces_calculated_baseline() -> None:
    curated = holiday("Reviewed", date(2026, 1, 1))
    calculated = holiday("Calculated", date(2026, 1, 1))

    result = merge_records("KR", [curated], [calculated], overrides())

    assert result == (curated,)


def test_non_curated_year_is_refreshed_from_baseline() -> None:
    stale = holiday("Stale", date(2027, 1, 1))
    calculated = holiday("Calculated", date(2027, 1, 1))

    result = merge_records("KR", [stale], [calculated], overrides())

    assert result == (calculated,)


def test_duplicate_holiday_identity_is_rejected() -> None:
    duplicate = holiday("Duplicate", date(2026, 1, 1))

    with pytest.raises(ValueError, match="Duplicate holiday identity"):
        _ = merge_records("KR", [duplicate, duplicate], [], overrides())


def test_text_replacement_removal_and_upsert_are_deterministic() -> None:
    existing = [
        HolidayRecord(
            name="어린이날 대체휴일",
            date=date(2026, 5, 6),
            type=HolidayType.NATIONAL,
            description=Description(
                en="Children's Day (Observed)",
                ko="어린이날 대체휴일",
            ),
        ),
        holiday("Remove me", date(2026, 6, 1)),
    ]
    replacement = holiday("Added", date(2026, 7, 1))
    config = overrides(
        replacements={"대체휴일": "대체 휴일"},
        removals=[{"country": "KR", "date": "2026-06-01", "name": "Remove me"}],
        upserts=[
            {
                "country": "KR",
                "holiday": replacement.model_dump(mode="json"),
            }
        ],
    )

    result = merge_records("KR", existing, [], config)

    assert [item.name for item in result] == ["어린이날 대체 휴일", "Added"]
    assert result[0].description.ko == "어린이날 대체 휴일"
    assert merge_records("KR", result, [], config) == result


def test_repository_generation_is_complete_and_idempotent(
    tmp_path: Path,
) -> None:
    api_dir = tmp_path / "api"
    holidays_dir = api_dir / "holidays"
    data_dir = tmp_path / "data"
    holidays_dir.mkdir(parents=True)
    data_dir.mkdir()
    _ = (data_dir / "overrides.json").write_text(
        json.dumps(
            {
                "version": 1,
                "curatedYears": {"KR": [2024, 2025, 2026]},
                "textReplacements": {"대체휴일": "대체 휴일"},
                "removals": [],
                "upserts": [],
            }
        )
    )
    _ = (api_dir / "countries.json").write_text(
        json.dumps(
            {
                "lastUpdated": "2026-01-01T00:00:00.000Z",
                "totalCountries": 1,
                "supportedCountries": ["KR"],
                "supportedYears": [2024, 2025, 2026],
                "totalHolidays": 999,
                "supportedLanguages": ["en", "ko"],
                "defaultLanguage": "en",
                "countries": [
                    {
                        "code": "KR",
                        "name": "South Korea",
                        "flag": "🇰🇷",
                        "totalHolidays": 999,
                        "dataUrl": "https://example.test/kr.json",
                        "names": {"en": "South Korea", "ko": "대한민국"},
                    }
                ],
            }
        )
    )
    _ = (holidays_dir / "kr.json").write_text(
        json.dumps(
            {
                "country": "KR",
                "countryName": "South Korea",
                "lastUpdated": "2026-01-01T00:00:00.000Z",
                "supportedYears": [2024, 2025, 2026],
                "totalHolidays": 999,
                "holidays": [
                    holiday("Curated 2024", date(2024, 1, 1)).model_dump(mode="json"),
                    HolidayRecord(
                        name="어린이날 대체휴일",
                        date=date(2026, 5, 6),
                        type=HolidayType.NATIONAL,
                        description=Description(
                            en="Observed",
                            ko="어린이날 대체휴일",
                        ),
                    ).model_dump(mode="json"),
                ],
            }
        )
    )

    written = generate_repository(
        tmp_path,
        current_year=2026,
        provider=FakeBaselineProvider(),
        generated_on=date(2026, 8, 21),
    )
    first_contents = {path: path.read_text() for path in written}
    generated_payload = CountryPayload.model_validate_json(
        (holidays_dir / "kr.json").read_text()
    )
    generated_index = CountryIndex.model_validate_json(
        (api_dir / "countries.json").read_text()
    )

    assert generated_payload.supported_years == (2024, 2026, 2027, 2028)
    assert generated_payload.total_holidays == 4
    assert generated_payload.last_updated == "2026-08-21T00:00:00.000Z"
    assert generated_payload.holidays[1].name == "어린이날 대체 휴일"
    assert generated_index.total_holidays == 4
    assert generated_index.countries[0].total_holidays == 4
    assert (
        "final bundledHolidayData"
        in (tmp_path / "lib/src/generated/holiday_data.g.dart").read_text()
    )

    second_written = generate_repository(
        tmp_path,
        current_year=2026,
        provider=FakeBaselineProvider(),
        generated_on=date(2026, 8, 22),
    )

    assert {path: path.read_text() for path in second_written} == first_contents


def test_python_holidays_provider_covers_supported_countries() -> None:
    provider = PythonHolidaysProvider()

    assert provider.version
    for country_code in (
        "KR",
        "US",
        "JP",
        "CN",
        "VN",
        "MY",
        "TH",
        "CA",
        "BR",
        "TW",
    ):
        records = provider.holidays_for(country_code, [2027])
        assert records
        assert records == tuple(
            sorted(records, key=lambda item: (item.date, item.name))
        )
        assert all(record.description.en for record in records)
        assert all(record.description.ko for record in records)
