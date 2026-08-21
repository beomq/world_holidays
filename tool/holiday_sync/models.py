"""Typed holiday synchronization models."""

from __future__ import annotations

import datetime
from enum import StrEnum
from typing import Annotated, ClassVar

from pydantic import BaseModel, ConfigDict, Field

CountryCode = Annotated[str, Field(pattern=r"^[A-Z]{2}$")]
Year = Annotated[int, Field(ge=1900, le=2200)]


class HolidayType(StrEnum):
    """Holiday wire types supported by the Dart package."""

    NATIONAL = "NATIONAL"
    RELIGIOUS = "RELIGIOUS"
    OBSERVANCE = "OBSERVANCE"
    REGIONAL = "REGIONAL"


class Description(BaseModel):
    """Multilingual holiday description."""

    model_config: ClassVar[ConfigDict] = ConfigDict(frozen=True)

    en: str = Field(min_length=1)
    ko: str = Field(min_length=1)


class HolidayRecord(BaseModel):
    """Canonical holiday record."""

    model_config: ClassVar[ConfigDict] = ConfigDict(frozen=True)

    name: str = Field(min_length=1)
    date: datetime.date
    type: HolidayType
    description: Description

    @property
    def identity(self) -> tuple[datetime.date, str]:
        """Return the stable key used by reviewed overrides."""
        return (self.date, self.name)


class Removal(BaseModel):
    """Holiday identity removed from the merged dataset."""

    model_config: ClassVar[ConfigDict] = ConfigDict(frozen=True)

    country: CountryCode
    date: datetime.date
    name: str = Field(min_length=1)


class Upsert(BaseModel):
    """Reviewed country-specific holiday replacement."""

    model_config: ClassVar[ConfigDict] = ConfigDict(frozen=True)

    country: CountryCode
    holiday: HolidayRecord


class Overrides(BaseModel):
    """Reviewed controls applied after baseline generation."""

    model_config: ClassVar[ConfigDict] = ConfigDict(frozen=True)

    version: int = Field(ge=1)
    curated_years: dict[CountryCode, tuple[Year, ...]] = Field(alias="curatedYears")
    text_replacements: dict[str, str] = Field(alias="textReplacements")
    removals: tuple[Removal, ...]
    upserts: tuple[Upsert, ...]


class CountryNames(BaseModel):
    """Localized country names retained by the hosted index."""

    model_config: ClassVar[ConfigDict] = ConfigDict(frozen=True)

    en: str = Field(min_length=1)
    ko: str = Field(min_length=1)


class CountryEntry(BaseModel):
    """Country metadata in the hosted index."""

    model_config: ClassVar[ConfigDict] = ConfigDict(frozen=True)

    code: CountryCode
    name: str = Field(min_length=1)
    flag: str = Field(min_length=1)
    total_holidays: int = Field(alias="totalHolidays", ge=0)
    data_url: str = Field(alias="dataUrl", min_length=1)
    names: CountryNames


class CountryIndex(BaseModel):
    """Hosted country index."""

    model_config: ClassVar[ConfigDict] = ConfigDict(frozen=True)

    last_updated: str = Field(alias="lastUpdated", min_length=1)
    total_countries: int = Field(alias="totalCountries", ge=0)
    supported_countries: tuple[CountryCode, ...] = Field(alias="supportedCountries")
    supported_years: tuple[Year, ...] = Field(alias="supportedYears")
    total_holidays: int = Field(alias="totalHolidays", ge=0)
    supported_languages: tuple[str, ...] = Field(alias="supportedLanguages")
    default_language: str = Field(alias="defaultLanguage", min_length=1)
    countries: tuple[CountryEntry, ...]


class CountryPayload(BaseModel):
    """Hosted country holiday payload."""

    model_config: ClassVar[ConfigDict] = ConfigDict(frozen=True)

    country: CountryCode
    country_name: str = Field(alias="countryName", min_length=1)
    last_updated: str = Field(alias="lastUpdated", min_length=1)
    supported_years: tuple[Year, ...] = Field(alias="supportedYears")
    total_holidays: int = Field(alias="totalHolidays", ge=0)
    holidays: tuple[HolidayRecord, ...]
