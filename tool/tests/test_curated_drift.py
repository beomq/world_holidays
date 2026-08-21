"""Regression tests for curated-year upstream drift detection."""

from __future__ import annotations

from datetime import date

import pytest
from pydantic import ValidationError

from tool.holiday_sync.generator import find_curated_year_gaps
from tool.holiday_sync.models import (
    Description,
    HolidayRecord,
    HolidayType,
    Overrides,
    SourceReference,
    Upsert,
)


def holiday(name: str, value: date) -> HolidayRecord:
    return HolidayRecord(
        name=name,
        date=value,
        type=HolidayType.NATIONAL,
        description=Description(en=name, ko=name),
    )


def overrides(*, upserts: list[Upsert] | None = None) -> Overrides:
    return Overrides.model_validate(
        {
            "version": 1,
            "curatedYears": {"KR": [2026]},
            "textReplacements": {},
            "removals": [],
            "upserts": upserts or [],
        }
    )


def test_curated_year_reports_new_baseline_date() -> None:
    existing = (holiday("Reviewed New Year", date(2026, 1, 1)),)
    baseline = (
        holiday("Calculated New Year", date(2026, 1, 1)),
        holiday("Constitution Day", date(2026, 7, 17)),
    )

    gaps = find_curated_year_gaps("KR", existing, baseline, overrides())

    assert gaps == (baseline[1],)


def test_reviewed_upsert_acknowledges_new_baseline_date() -> None:
    constitution_day = holiday("Constitution Day", date(2026, 7, 17))
    config = overrides(
        upserts=[
            Upsert(
                country="KR",
                holiday=constitution_day,
                source=SourceReference(
                    url="https://law.go.kr/example",
                    verifiedOn=date(2026, 8, 21),
                ),
            )
        ]
    )

    gaps = find_curated_year_gaps("KR", (), (constitution_day,), config)

    assert gaps == ()


def test_upsert_requires_official_source() -> None:
    constitution_day = holiday("Constitution Day", date(2026, 7, 17))

    with pytest.raises(ValidationError):
        _ = Overrides.model_validate(
            {
                "version": 1,
                "curatedYears": {"KR": [2026]},
                "textReplacements": {},
                "removals": [],
                "upserts": [
                    {
                        "country": "KR",
                        "holiday": constitution_day.model_dump(mode="json"),
                    }
                ],
            }
        )
