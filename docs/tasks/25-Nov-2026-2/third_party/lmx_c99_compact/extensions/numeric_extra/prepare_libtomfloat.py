#!/usr/bin/env python3
"""Produce two guarded fixes for the pinned experimental LibTomFloat snapshot.

Original production sources/notices stay untouched. These fixes address the
two demonstrated regression cases, not a proof of general numerical accuracy.
"""
from pathlib import Path
import sys


def main():
    source, output = map(Path, sys.argv[1:])
    output.mkdir(parents=True, exist_ok=True)
    constant = (source / "mpf_const_d.c").read_text()
    body = constant.index("int  mpf_const_d(")
    if "mp_set_int(&(a->mantissa), x)" not in constant or "x = -d;" not in constant:
        raise SystemExit("LibTomFloat constant adapter drift; review required")
    # Current LibTomMath's signed-long constructor handles LONG_MIN and the
    # complete long width. Legacy mp_set_int deliberately takes only 32 bits.
    constant = constant[:body] + """/* LMX adapter: full-width signed long, including LONG_MIN. */
int mpf_const_d(mp_float *a, long d)
{
    mp_set_l(&a->mantissa, d);
    a->exp = 0;
    return mpf_normalize(a);
}
"""
    (output / "mpf_const_d.c").write_text(constant)
    square_root = (source / "mpf_sqrt.c").read_text()
    marker = "   /* make sure it's positive */"
    if square_root.count(marker) != 1:
        raise SystemExit("LibTomFloat sqrt adapter drift; review required")
    square_root = square_root.replace(marker,
        "   /* LMX adapter: zero must not enter Newton's x/res step. */\n"
        "   if (mpf_iszero(a) == MP_YES) return mpf_const_0(b);\n\n" + marker)
    (output / "mpf_sqrt.c").write_text(square_root)


if __name__ == "__main__":
    main()
