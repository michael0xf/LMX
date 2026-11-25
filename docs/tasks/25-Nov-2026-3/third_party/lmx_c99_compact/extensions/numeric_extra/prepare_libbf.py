#!/usr/bin/env python3
"""Create a strict C99, namespaced LibBF build view; never modify vendor files."""
from pathlib import Path
import argparse
import json
import re


def prepare(source, destination):
    destination.mkdir(parents=True, exist_ok=True)
    names = ("libbf.c", "libbf.h", "cutils.c", "cutils.h")
    texts = {name: (source / name).read_text() for name in names}
    guard = "#if defined(__SIZEOF_INT128__) && (INTPTR_MAX >= INT64_MAX)"
    if texts["libbf.h"].count(guard) != 1:
        raise ValueError("LibBF limb guard changed; review portable profile")
    texts["libbf.h"] = texts["libbf.h"].replace(guard, "#if 0 /* LMX portable C99: 32-bit limbs, uint64_t products. */")
    # The scalar portable32 profile is independent of host/compiler AVX flags.
    texts["libbf.c"] = texts["libbf.c"].replace("#ifdef __AVX2__", "#if 0 /* LMX scalar profile */")
    texts["libbf.c"] = texts["libbf.c"].replace("defined(__AVX2__)", "0 /* LMX scalar profile */")
    # Demonstrated by an allocation-budget regression: the initial parse limb
    # allocation was unchecked upstream and could be followed by a NULL store.
    initial_parse = "    cur_limb = 0;\n    bf_resize(a, 1);\n    pos = 0;"
    if texts["libbf.c"].count(initial_parse) != 1:
        raise ValueError("LibBF initial parse allocation site changed; review required")
    texts["libbf.c"] = texts["libbf.c"].replace(initial_parse,
        "    cur_limb = 0;\n    if (bf_resize(a, 1))\n        goto mem_error;\n    pos = 0;")
    header = texts["cutils.h"]
    header = header.replace("#include <inttypes.h>", "#include <inttypes.h>\n#include <stddef.h>\n#include <string.h>")
    replacements = {
        "#define likely(x)       __builtin_expect(!!(x), 1)": "#define likely(x) (!!(x))",
        "#define unlikely(x)     __builtin_expect(!!(x), 0)": "#define unlikely(x) (!!(x))",
        "#define force_inline inline __attribute__((always_inline))": "#define force_inline inline",
        "#define no_inline __attribute__((noinline))": "#define no_inline",
        "#define __maybe_unused __attribute__((unused))": "#define __maybe_unused",
        "return __builtin_clz(a);": "int n = 0; if (!a) return 32; while (!(a & UINT32_C(0x80000000))) { ++n; a <<= 1; } return n;",
        "return __builtin_clzll(a);": "int n = 0; if (!a) return 64; while (!(a & UINT64_C(0x8000000000000000))) { ++n; a <<= 1; } return n;",
        "return __builtin_ctz(a);": "int n = 0; if (!a) return 32; while (!(a & 1)) { ++n; a >>= 1; } return n;",
        "return __builtin_ctzll(a);": "int n = 0; if (!a) return 64; while (!(a & 1)) { ++n; a >>= 1; } return n;",
        "return ((struct packed_u32 *)tab)->v;": "uint32_t value; memcpy(&value, tab, sizeof value); return value;",
        "((struct packed_u32 *)tab)->v = val;": "memcpy(tab, &val, sizeof val);",
        "return ((struct packed_u16 *)tab)->v;": "uint16_t value; memcpy(&value, tab, sizeof value); return value;",
        "((struct packed_u16 *)tab)->v = val;": "memcpy(tab, &val, sizeof val);",
        "int __attribute__((format(printf, 2, 3))) dbuf_printf": "int dbuf_printf",
    }
    for old, new in replacements.items():
        if header.count(old) != 1:
            raise ValueError("LibBF cutils portability site changed: " + old)
        header = header.replace(old, new)
    header, count = re.subn(r"struct __attribute__\(\(packed\)\) packed_u(?:16|32) \{.*?\};\n", "", header, flags=re.S)
    if count != 2:
        raise ValueError("Unexpected LibBF packed helper layout")
    texts["cutils.h"] = header
    all_text = "\n".join(texts.values())
    generic = set(re.findall(r"\bmp_[A-Za-z0-9_]+\b", all_text))
    generic |= set(re.findall(r"\bdbuf_[A-Za-z0-9_]+\b", all_text))
    generic |= {"pstrcpy", "pstrcat", "strstart", "unicode_to_utf8", "unicode_from_utf8"}
    mapping = {name: "lmx_bf_" + name for name in sorted(generic)}
    pattern = re.compile(r"\b(" + "|".join(map(re.escape, mapping)) + r")\b")
    for name, text in texts.items():
        text = pattern.sub(lambda match: mapping[match.group(0)], text)
        (destination / name).write_text(text)
    (destination / "symbol_map.json").write_text(json.dumps(mapping, indent=2) + "\n")
    return mapping


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("destination", type=Path)
    args = parser.parse_args()
    prepare(args.source, args.destination)
