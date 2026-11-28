#!/usr/bin/env python3
"""Independent host checks of interval arithmetic and source-coordinate fixtures.

This executes Python, not LMX and not the production P0 parser.
"""
from __future__ import annotations
import itertools
import json
import re
from datetime import datetime, timezone
from pathlib import Path

BASE = Path(__file__).resolve().parents[1]
PROJECT = BASE.parents[1]

def shift(position, edit, right):
    begin, end, new_end = edit
    if position < begin:
        return position
    if position > end:
        return position - end + new_end
    if position == end and end > begin:
        return new_end
    return new_end if right else begin

def envelope(edits):
    dirty = None
    for edit in edits:
        begin, end, new_end = edit
        if dirty is None:
            dirty = (begin, new_end)
        else:
            dirty = (min(shift(dirty[0], edit, False), begin),
                     max(shift(dirty[1], edit, True), new_end))
    return dirty

def boundary_tables(length, edit):
    """Explicit old-boundary images; no running dirty interval is involved."""
    begin, end, new_end = edit
    added = new_end - begin
    removed = end - begin
    before = list(range(begin))
    after = [n + added - removed for n in range(end + 1, length + 1)]
    if removed:
        left = before + [begin] * removed + [new_end] + after
        right = before + [new_end] * (removed + 1) + after
    else:
        left = before + [begin] + after
        right = before + [new_end] + after
    assert len(left) == len(right) == length + 1
    return left, right

def independent_envelope(length, edits):
    intervals = []
    for edit in edits:
        left, right = boundary_tables(length, edit)
        intervals = [(left[a], right[b]) for a, b in intervals]
        intervals.append((edit[0], edit[2]))
        length += edit[2] - edit[1]
    return min(a for a, _ in intervals), max(b for _, b in intervals)

def possible_edits(length):
    for begin in range(length + 1):
        for end in range(begin, length + 1):
            for added in range(3):
                if begin == end and added == 0:
                    continue
                yield begin, end, begin + added

arithmetic_cases = 0
for initial_length in range(7):
    for first in possible_edits(initial_length):
        next_length = initial_length + first[2] - first[1]
        for second in possible_edits(next_length):
            edits = [first, second]
            actual = envelope(edits)
            expected = independent_envelope(initial_length, edits)
            assert actual == expected, (initial_length, edits, actual, expected)
            arithmetic_cases += 1
assert envelope([(8, 8, 12), (0, 0, 2)]) == (0, 14)
assert envelope([(4, 8, 4), (1, 1, 4)]) == (1, 7)

def preceding(points, flags, before):
    lo, hi = 0, len(points)
    while lo < hi:
        middle = lo + (hi - lo) // 2
        if points[middle] < before or (middle == 0 and points[middle] == 0):
            lo = middle + 1
        else:
            hi = middle
    while lo:
        lo -= 1
        if flags[lo]:
            return lo
    return None

checkpoint_cases = 0
for n in range(1, 9):
    points = list(range(n))
    for flags in itertools.product((False, True), repeat=n):
        for before in range(n + 1):
            admitted = [i for i in range(n) if flags[i] and
                        (points[i] < before or i == 0)]
            assert preceding(points, flags, before) == (admitted[-1] if admitted else None)
            checkpoint_cases += 1

fixtures = [
    ("string_mark_empty.lmx", '"a{}b"', 2),
    ("string_mark_character_number.lmx", '"жёлтый{a}"', 7),
    ("string_mark_non_bmp_character.lmx", '"🙂{a}"', 2),
    ("string_mark_c_prefix.lmx", 'L"ab{c}"', 4),
    ("string_mark_triple.lmx", '"""a{b}"""', 4),
    ("string_mark_backslash_brace.lmx", '"a\\{b}c"', 3),
]
expectations = json.loads((PROJECT / "tests/parser/current/expectations.json").read_text())
by_name = {Path(x["path"]).name: x for x in expectations}
coordinate_rows = []
for name, raw, expected in fixtures:
    char_offset = raw.index("{")
    byte_offset = len(raw[:char_offset].encode("utf-8"))
    assert char_offset == expected
    entry = by_name[name]
    fixture = (PROJECT / entry["path"]).read_text()
    assert raw in fixture
    reported = [int(x) for x in re.findall(r"MIX at (\d+)", entry["stdout_exact"])]
    assert reported[0] == expected
    coordinate_rows.append({"fixture": entry["path"],
                            "source_token_codepoints": char_offset,
                            "source_token_utf8_bytes": byte_offset,
                            "existing_expected_p0": reported[0]})

report = {
    "generated_utc": datetime.now(timezone.utc).isoformat(),
    "status": "HOST_ORACLE_PASS",
    "runtime": "Python host arithmetic and inspection of supplied fixtures only",
    "two_edit_combinations": arithmetic_cases,
    "checkpoint_combinations": checkpoint_cases,
    "coordinate_fixture_checks": coordinate_rows,
    "not_run": ["LMX case execution", "production P0 parser",
                "incremental node reuse", "Message execution"],
}
(BASE / "validation/p0_host_report.json").write_text(
    json.dumps(report, ensure_ascii=False, indent=2) + "\n")
print(json.dumps({"status": report["status"], "two_edit_combinations": arithmetic_cases,
                  "checkpoint_combinations": checkpoint_cases,
                  "coordinate_fixtures": len(coordinate_rows)}))
