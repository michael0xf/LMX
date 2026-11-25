#!/usr/bin/env python3
"""Expand the upstream libdivsufsort header template for the fixed C99 ABI."""
import argparse
from pathlib import Path


def rendered_headers(project):
    compact = project / "third_party/lmx_c99_compact"
    template = (compact / "vendor/libdivsufsort/include/divsufsort.h.cmake").read_text()
    banner = ("/* Generated from vendor/libdivsufsort/include/divsufsort.h.cmake.\n"
              " * LMX portable C99 profile: uint8_t, int32_t, int64_t; static libraries. */\n")
    for width in ("", "64"):
        values = {
            "W64BIT": width, "INCFILE": "#include <inttypes.h>",
            "DIVSUFSORT_EXPORT": "", "DIVSUFSORT_IMPORT": "",
            "SAUCHAR_TYPE": "uint8_t", "SAINT32_TYPE": "int32_t",
            "SAINDEX_TYPE": "int64_t" if width else "int32_t",
            "SAINT_PRId": "PRId32", "SAINDEX_PRId": "PRId64" if width else "PRId32",
        }
        text = template
        for name, value in values.items():
            text = text.replace("@" + name + "@", value)
        yield compact / "extensions/text_hash_extra/include" / ("divsufsort" + width + ".h"), banner + text


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project", type=Path, required=True, help="LMX project root")
    parser.add_argument("--check", action="store_true", help="Check without writing")
    args = parser.parse_args()
    errors = []
    for path, text in rendered_headers(args.project.resolve()):
        if args.check:
            if not path.exists() or path.read_text() != text:
                errors.append(str(path))
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(text)
    if errors:
        raise SystemExit("Generated headers differ: " + ", ".join(errors))
    print("2 fixed-width divsufsort headers " + ("verified" if args.check else "generated"))


if __name__ == "__main__":
    main()
