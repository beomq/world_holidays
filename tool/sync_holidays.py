# /// script
# requires-python = ">=3.12"
# dependencies = [
#   "holidays>=0.102,<1",
#   "pydantic>=2.12,<3",
#   "typer>=0.21,<1",
# ]
# ///
"""Synchronize hosted and bundled holiday datasets.

Usage:
    uv run tool/sync_holidays.py
    uv run tool/sync_holidays.py --current-year 2026 --check
"""

from __future__ import annotations

import shutil
from datetime import UTC, datetime
from pathlib import Path
from tempfile import TemporaryDirectory
from typing import Annotated

import typer
from holiday_sync import generate_repository
from holiday_sync.providers import PythonHolidaysProvider

app = typer.Typer(add_completion=False)


def _check(root: Path, current_year: int) -> tuple[Path, ...]:
    with TemporaryDirectory(prefix="world-holidays-") as directory:
        temporary_root = Path(directory)
        _ = shutil.copytree(root / "api", temporary_root / "api")
        _ = (temporary_root / "data").mkdir()
        _ = shutil.copy2(
            root / "data/overrides.json",
            temporary_root / "data/overrides.json",
        )
        generated = generate_repository(
            temporary_root,
            current_year,
            PythonHolidaysProvider(),
        )
        mismatches: list[Path] = []
        for temporary_path in generated:
            relative_path = temporary_path.relative_to(temporary_root)
            repository_path = root / relative_path
            if (
                not repository_path.exists()
                or repository_path.read_bytes() != temporary_path.read_bytes()
            ):
                mismatches.append(repository_path)
        return tuple(mismatches)


@app.command()
def sync(
    root: Annotated[
        Path | None,
        typer.Option(exists=True, file_okay=False),
    ] = None,
    current_year: Annotated[
        int | None,
        typer.Option(min=1900, max=2200),
    ] = None,
    check: Annotated[bool | None, typer.Option()] = None,
) -> None:
    """Generate current data or verify checked-in output."""
    root = root or Path.cwd()
    current_year = current_year or datetime.now(tz=UTC).year
    root = root.resolve()
    if check is True:
        mismatches = _check(root, current_year)
        if mismatches:
            for path in mismatches:
                typer.echo(f"outdated: {path.relative_to(root)}", err=True)
            raise typer.Exit(code=1)
        typer.echo("Holiday data is synchronized.")
        return

    written = generate_repository(
        root,
        current_year,
        PythonHolidaysProvider(),
        generated_on=datetime.now(tz=UTC).date(),
    )
    typer.echo(f"Generated {len(written)} files.")


if __name__ == "__main__":
    app()
