"""Behavior tests for the standalone web calendar."""

from __future__ import annotations

import json
import os
import re
import shutil
import tempfile
from pathlib import Path

SCRIPT_PATTERN = re.compile(r"<script>(.*?)</script>", re.DOTALL)


def test_holiday_label_follows_selected_language() -> None:
    html = Path("index.html").read_text(encoding="utf-8")
    scripts = SCRIPT_PATTERN.findall(html)
    assert scripts
    node = shutil.which("node")
    assert node

    source = f"""
globalThis.document = {{ addEventListener() {{}} }};
{scripts[-1]}
const calendar = new HolidayCalendar();
const holiday = {{
  name: "Constitution Day",
  description: {{ en: "Constitution Day", ko: "제헌절" }},
}};
calendar.currentLanguage = "en";
const en = calendar.getHolidayLabel(holiday);
const enType = calendar.getHolidayTypeLabel("NATIONAL");
calendar.currentYear = 2026;
calendar.currentMonth = 6;
const enMonth = calendar.getMonthLabel();
const enDays = calendar.getDayNames();
calendar.currentLanguage = "ko";
const ko = calendar.getHolidayLabel(holiday);
const koType = calendar.getHolidayTypeLabel("NATIONAL");
const koMonth = calendar.getMonthLabel();
const koDays = calendar.getDayNames();
const fallback = calendar.getHolidayLabel({{ name: "Fallback Name" }});
console.log(JSON.stringify({{
  en,
  enType,
  enMonth,
  enDays,
  ko,
  koType,
  koMonth,
  koDays,
  fallback,
}}));
"""
    with tempfile.TemporaryDirectory() as directory:
        temporary_directory = Path(directory)
        script_path = temporary_directory / "web-calendar-test.js"
        stdout_path = temporary_directory / "stdout.txt"
        stderr_path = temporary_directory / "stderr.txt"
        _ = script_path.write_text(source, encoding="utf-8")

        with (
            stdout_path.open("wb") as stdout_file,
            stderr_path.open("wb") as stderr_file,
        ):
            process_id = os.posix_spawn(
                node,
                [node, str(script_path)],
                os.environ,
                file_actions=[
                    (os.POSIX_SPAWN_DUP2, stdout_file.fileno(), 1),
                    (os.POSIX_SPAWN_DUP2, stderr_file.fileno(), 2),
                ],
            )
            _, status = os.waitpid(process_id, 0)

        stderr = stderr_path.read_text(encoding="utf-8")
        stdout = stdout_path.read_text(encoding="utf-8")

    assert os.waitstatus_to_exitcode(status) == 0, stderr
    assert json.loads(stdout) == {
        "en": "Constitution Day",
        "enType": "National holiday",
        "enMonth": "July 2026",
        "enDays": ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
        "ko": "제헌절",
        "koType": "공휴일",
        "koMonth": "2026년 7월",
        "koDays": ["일", "월", "화", "수", "목", "금", "토"],
        "fallback": "Fallback Name",
    }
