from pathlib import Path
DST = Path(r"C:\Nyasha_Planet\L1\dev\mixa_migration\mixa_manager")

def w(name, text):
    p = DST / name
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(text.lstrip("\n"), encoding="utf-8", newline="\n")
    print("wrote", name, p.stat().st_size)

w("mixa_core.h.lm1", """
include: \"<stddef.h>\"

# mixa_core.h.lm1 - cell + text rect (from mixa_core.h).
# unsigned char fields use a one-token alias (mixa_tiles_l2.h.lm1 precedent).

type: MixaCellByte unsigned char

enum: MixaStyle
    MIXA_STYLE_BOLD 1
    MIXA_STYLE_UNDERLINE 2
    MIXA_STYLE_REVERSE 4
end: MixaStyle

struct: MixaCell
    unsigned: codepoint
    MixaCellByte: fg
    MixaCellByte: bg
    MixaCellByte: flags
    MixaCellByte: width
    MixaCellByte: alpha
end: MixaCell

struct: MixaTextRect
    size_t: rows
    size_t: cols
    @: MixaCell cells
end: MixaTextRect
""")

w("mixa_overlay.h.lm1", """
include: \"<stddef.h>\"

# mixa_overlay.h.lm1 - MixaU8 + palette helper declaration.
# C header had static MIXA_PALETTE and static mixa_palette_rgb body;
# L1 headers cannot carry executable bodies. Body lives in mixa_overlay.lm1.

type: MixaU8 unsigned char

prototype:
    fn: mixa_palette_rgb (unsigned: index; @: MixaU8 out_r; @: MixaU8 out_g; @: MixaU8 out_b) void
end: prototype
""")

print("ok core+overlay hdr")