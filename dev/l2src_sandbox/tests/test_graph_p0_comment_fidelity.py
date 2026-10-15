"""Expected-failure witness for P0's missing retained comment annotations.

Usage:
    python test_graph_p0_comment_fidelity.py --oracle PATH
    python test_graph_p0_comment_fidelity.py --oracle PATH --expect-missing

The oracle must obtain comment records from the parsed P0 document, not by
re-opening the source file or scanning LmP0Document.source after parsing. The
existing graph_p0_method_order_oracle emits only retained P0 node events, so
the second command reports XFAIL today. The first command is the strict future
regression check and fails until a real P0 comment producer/API exists.

Test-only event format (not a public language/runtime format):
    comment owner=<path> gap=<n> placement=<leading|trailing> kind=<line|raw> hex=<HEX>

``owner`` is a structural occurrence path, not an identifier lookup. ``gap``
is the number of preceding fields in that owner's Structure. An inline comment
after a field and a standalone comment before the next field share a gap but
retain different placement. Each raw-block HEX payload includes both fences
and its intervening lines, excluding the physical newline after the closer.
The records occur in source order; duplicate comments at one gap stay distinct.
"""

from __future__ import annotations

import argparse
from pathlib import Path
import subprocess
import sys
import tempfile


FIXTURE = Path(__file__).with_name("graph_p0_comment_fidelity.lm2")
EXPECTED = [
    ("root", 0, "leading", "line", b"# root before Box A"),
    ("root", 0, "leading", "line", "# root before Box B: café".encode("utf-8")),
    ("root/0/body", 0, "leading", "line", b"# body before x"),
    ("root/0/body", 1, "trailing", "line", b"# inline after x: two  spaces"),
    ("root/0/body", 1, "leading", "line", b"# body before y"),
    ("root", 1, "leading", "raw", b"***\nraw block # is not code\n  int: not_a_field ???\n***"),
    ("root", 2, "trailing", "line", b"# inline after done"),
]


def read_records(blob: bytes) -> list[str]:
    records: list[str] = []
    for line in blob.split(b"\n"):
        if not line:
            continue
        # The output file is binary; tolerate CRLF only for an older oracle.
        if line.endswith(b"\r"):
            line = line[:-1]
        size, separator, payload = line.partition(b":")
        if separator != b":" or not size.isdigit() or int(size) != len(payload):
            raise ValueError(f"invalid length-prefixed P0 record: {line!r}")
        records.append(payload.decode("ascii"))
    return records


def parse_comment(record: str) -> tuple[str, int, str, str, bytes]:
    items = record.split(" ")
    if items[0] != "comment" or len(items) != 6:
        raise ValueError(f"invalid P0 comment record: {record!r}")
    fields = {}
    for item in items[1:]:
        key, separator, value = item.partition("=")
        if not separator or key in fields:
            raise ValueError(f"invalid P0 comment field: {item!r}")
        fields[key] = value
    if set(fields) != {"owner", "gap", "placement", "kind", "hex"}:
        raise ValueError(f"incomplete P0 comment record: {record!r}")
    return (
        fields["owner"],
        int(fields["gap"]),
        fields["placement"],
        fields["kind"],
        bytes.fromhex(fields["hex"]),
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--oracle", required=True, type=Path)
    parser.add_argument("--expect-missing", action="store_true")
    options = parser.parse_args()

    with tempfile.TemporaryDirectory(prefix="lmx_p0_comments_") as temporary:
        output = Path(temporary) / "events.bin"
        result = subprocess.run(
            [str(options.oracle), str(FIXTURE), str(output)],
            capture_output=True,
            check=False,
        )
        if result.returncode != 0:
            print(f"FAIL: P0 rejected comment fixture (exit {result.returncode})", file=sys.stderr)
            print(result.stderr.decode("utf-8", "replace"), file=sys.stderr)
            return 1
        records = read_records(output.read_bytes())

    if not records or not records[0].startswith("p0-events ") or records[-1] != "end-document":
        print("FAIL: missing successful P0 event envelope", file=sys.stderr)
        return 1
    if not any(record.startswith("structure depth=0 index=0 ") and " fields=2 " in record for record in records):
        print("FAIL: fixture no longer has two root fields", file=sys.stderr)
        return 1
    if not any(record.startswith("frame depth=1 index=0 ") and " body_fields=2 " in record for record in records):
        print("FAIL: fixture no longer has a two-field Box body", file=sys.stderr)
        return 1
    comments = [parse_comment(record) for record in records if record.startswith("comment ")]
    if not comments and options.expect_missing:
        print("XFAIL: P0 has no retained structural comment events (source buffer is not an oracle)")
        return 0
    if comments != EXPECTED:
        print("FAIL: retained P0 comment bytes/order/structural gaps differ", file=sys.stderr)
        print(f"expected: {EXPECTED!r}", file=sys.stderr)
        print(f"actual:   {comments!r}", file=sys.stderr)
        return 1
    if options.expect_missing:
        print("XPASS: P0 now retains comments; remove --expect-missing and integrate strict mode", file=sys.stderr)
        return 1
    print("PASS: exact P0 comment bytes, occurrence gaps, and order")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
