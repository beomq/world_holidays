"""Deterministic JSON and Dart renderers."""

from __future__ import annotations

import json
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from collections.abc import Mapping
    from pathlib import Path

    from pydantic import BaseModel

    from .models import HolidayRecord


def write_json(path: Path, model: BaseModel) -> None:
    """Write stable, human-readable JSON."""
    payload = model.model_dump(mode="json", by_alias=True)
    path.parent.mkdir(parents=True, exist_ok=True)
    _ = path.write_text(
        f"{json.dumps(payload, ensure_ascii=False, indent=2)}\n",
        encoding="utf-8",
    )


def _dart_string(value: str) -> str:
    return (
        value.replace("\\", "\\\\")
        .replace("'", "\\'")
        .replace("$", "\\$")
        .replace("\n", "\\n")
    )


def render_dart(
    records: Mapping[str, tuple[HolidayRecord, ...]],
    years: tuple[int, ...],
    source_version: str,
) -> str:
    """Render the immutable bundled holiday map."""
    lines = [
        "// GENERATED CODE - DO NOT MODIFY BY HAND.",
        f"// Source: python-holidays {source_version} plus data/overrides.json.",
        "",
        "import '../models/holiday.dart';",
        "import '../models/holiday_type.dart';",
        "",
        f"const bundledSupportedYears = <int>{list(years)};",
        "",
        "final bundledHolidayData = <String, List<Holiday>>{",
    ]
    for country_code, holidays in records.items():
        lines.append(f"  '{country_code}': <Holiday>[")
        for holiday in holidays:
            lines.extend(
                [
                    "    Holiday(",
                    f"      name: '{_dart_string(holiday.name)}',",
                    (
                        "      date: DateTime("
                        f"{holiday.date.year}, {holiday.date.month}, "
                        f"{holiday.date.day}),"
                    ),
                    f"      type: HolidayType.{holiday.type.value.lower()},",
                    "      description: <String, String>{",
                    (f"        'en': '{_dart_string(holiday.description.en)}',"),
                    (f"        'ko': '{_dart_string(holiday.description.ko)}',"),
                    "      },",
                    "    ),",
                ]
            )
        lines.append("  ],")
    lines.extend(["};", ""])
    return "\n".join(lines)
