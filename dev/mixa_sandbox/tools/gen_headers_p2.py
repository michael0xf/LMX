from pathlib import Path
DST = Path(r"C:\Nyasha_Planet\L1\dev\mixa_migration\mixa_manager")
def w(name, text):
    p = DST / name
    p.write_text(text.lstrip("\n"), encoding="utf-8", newline="\n")
    print("wrote", name, p.stat().st_size)

w("mixa_file.h.lm1", """
include: "<stddef.h>"

# mixa_file.h.lm1 - portable console-file seam. Opaque MixaFile; body in mixa_file_win32.h.lm1.

define: MIXA_FILE_MODE_READ 1
define: MIXA_FILE_MODE_APPEND 2
define: MIXA_FILE_OK 0
define: MIXA_FILE_ERR_ARG 1
define: MIXA_FILE_ERR_MISSING 2
define: MIXA_FILE_ERR_IO 3
define: MIXA_FILE_ERR_NOMEM 4

# Incomplete/opaque: concrete fields in mixa_file_win32.h.lm1
type: MixaFile struct MixaFile

prototype:
    fn: mixa_file_open (@@: MixaFile out; const: @(char path_utf8); int: mode) int
    fn: mixa_file_close (@: MixaFile f) void
    fn: mixa_file_append (@: MixaFile f; const: @(void buf); size_t: n; @: size_t wrote) int
    fn: mixa_file_read (@: MixaFile f; @: void buf; size_t: n; @: size_t got) int
    fn: mixa_file_seek (@: MixaFile f; size_t: abs_off) int
    fn: mixa_file_size (@: MixaFile f; @: size_t out) int
end: prototype
""")

w("mixa_file_win32.h.lm1", """
predef: "mixa_manager/mixa_file.h.lm1"
include: "<stddef.h>"
include: "mixa_manager/mixa_file_win32_l2_win.h"

# Concrete Win32 MixaFile. HANDLE as @: void (ABI-identical PVOID).
# WIN32_LEAN_AND_MEAN + windows.h via the tiny C adapter (L1 cannot emit #define before #include).

struct: MixaFile
    @: void handle
    int: mode
    int: is_open
end: MixaFile
""")

w("mixa_selection.h.lm1", """
include: "<stddef.h>"

define: MIXA_SEL_OK 0
define: MIXA_SEL_CONFLICT 1
define: MIXA_SEL_NOTHING 2
define: MIXA_SEL_ERR 3

struct: MixaSelRev
    @: char ancestor
    @@: char paths
    size_t: count
    size_t: capacity
end: MixaSelRev

struct: MixaSelection
    @@: char selected
    size_t: selected_count
    size_t: selected_cap
    @@: char exc_paths
    @@: char exc_from
    size_t: exc_count
    size_t: exc_cap
    @: MixaSelRev revs
    size_t: rev_count
    size_t: rev_cap
    int: is_open
end: MixaSelection

prototype:
    fn: mixa_selection_init (@: MixaSelection sel) int
    fn: mixa_selection_release (@: MixaSelection sel) void
    fn: mixa_selection_select (@: MixaSelection sel; const: @(char path)) int
    fn: mixa_selection_deselect (@: MixaSelection sel; const: @(char path)) int
    fn: mixa_selection_query (@: MixaSelection sel; const: @(char path)) int
end: prototype
""")

w("mixa_draw.h.lm1", """
include: "<stddef.h>"
predef: "mixa_manager/mixa_core.h.lm1"

define: MIXA_DRAW_OK 0
define: MIXA_DRAW_ERR 1
define: MIXA_DRAW_SINGLE 0
define: MIXA_DRAW_DOUBLE 1
define: MIXA_DRAW_HORIZ 0
define: MIXA_DRAW_VERT 1
define: MIXA_DRAW_KEEP_BG 0x100U

prototype:
    fn: mixa_draw_text (@: MixaTextRect rect; size_t: row; size_t: col; const: @(char text); unsigned: fg; unsigned: bg; unsigned: flags; unsigned: alpha) int
    fn: mixa_draw_fill (@: MixaTextRect rect; size_t: row; size_t: col; size_t: nrows; size_t: ncols; unsigned: codepoint; unsigned: fg; unsigned: bg; unsigned: flags; unsigned: alpha) int
    fn: mixa_draw_line (@: MixaTextRect rect; size_t: row; size_t: col; size_t: len; int: orient; int: style; unsigned: fg; unsigned: bg; unsigned: flags; unsigned: alpha) int
    fn: mixa_draw_frame (@: MixaTextRect rect; size_t: row; size_t: col; size_t: nrows; size_t: ncols; int: style; unsigned: fg; unsigned: bg; unsigned: flags; unsigned: alpha) int
end: prototype
""")

w("mixa_tiles.h.lm1", """
include: "<stddef.h>"
predef: "mixa_manager/mixa_core.h.lm1"
predef: "mixa_manager/mixa_overlay.h.lm1"

define: MIXA_TILE_BASE 0xE000U
define: MIXA_TILE_LAST 0xE00FU
define: MIXA_TILE_GAP_L 0x1U
define: MIXA_TILE_GAP_R 0x2U
define: MIXA_TILE_GAP_T 0x4U
define: MIXA_TILE_GAP_B 0x8U
define: MIXA_TILE_FILL (MIXA_TILE_BASE)
define: MIXA_TILE_W (MIXA_TILE_BASE | MIXA_TILE_GAP_L)
define: MIXA_TILE_E (MIXA_TILE_BASE | MIXA_TILE_GAP_R)
define: MIXA_TILE_N (MIXA_TILE_BASE | MIXA_TILE_GAP_T)
define: MIXA_TILE_S (MIXA_TILE_BASE | MIXA_TILE_GAP_B)
define: MIXA_TILE_NW (MIXA_TILE_BASE | MIXA_TILE_GAP_L | MIXA_TILE_GAP_T)
define: MIXA_TILE_NE (MIXA_TILE_BASE | MIXA_TILE_GAP_R | MIXA_TILE_GAP_T)
define: MIXA_TILE_SW (MIXA_TILE_BASE | MIXA_TILE_GAP_L | MIXA_TILE_GAP_B)
define: MIXA_TILE_SE (MIXA_TILE_BASE | MIXA_TILE_GAP_R | MIXA_TILE_GAP_B)
define: MIXA_TILE_ALL (MIXA_TILE_BASE | MIXA_TILE_GAP_L | MIXA_TILE_GAP_R | MIXA_TILE_GAP_T | MIXA_TILE_GAP_B)

prototype:
    fn: mixa_tile_gap_px (size_t: cell_h) size_t
    fn: mixa_tile_is (unsigned: codepoint) int
    fn: mixa_tile_gaps (unsigned: codepoint) unsigned
    fn: mixa_tile_from_gaps (unsigned: gaps) unsigned
    fn: mixa_tile_pixel_solid (unsigned: codepoint; size_t: lx; size_t: ly; size_t: cell_w; size_t: cell_h) int
    fn: mixa_tile_paint_cell (unsigned: codepoint; unsigned: bg; unsigned: alpha; size_t: cell_x; size_t: cell_y; size_t: cell_w; size_t: cell_h; @: MixaU8 out_rgba; size_t: width; size_t: height) int
    fn: mixa_tile_fill_button (@: MixaTextRect rect; size_t: row; size_t: col; size_t: nrows; size_t: ncols; unsigned: fg; unsigned: bg; unsigned: alpha) int
end: prototype
""")

w("mixa_buttons.h.lm1", """
include: "<stddef.h>"
predef: "mixa_manager/mixa_core.h.lm1"
predef: "mixa_manager/mixa_tiles.h.lm1"

# UI button panel. NOTE: C mixa_backend.h also typedef-enums MixaButton for mouse
# bits — name collision with this struct (documented defect; fmpanel avoids both).

define: MIXA_BUTTONS_OK 0
define: MIXA_BUTTONS_ERR 1
define: MIXA_BUTTON_NONE -1

struct: MixaButton
    @: char label
    size_t: row
    size_t: col
    size_t: nrows
    size_t: ncols
    unsigned: fg
    unsigned: bg
    unsigned: alpha
    int: is_sep
    int: enlarge
end: MixaButton

struct: MixaButtonLine
    @: MixaButton items
    size_t: count
    size_t: cap
end: MixaButtonLine

struct: MixaButtonPanel
    @: MixaButtonLine lines
    size_t: line_count
    size_t: line_cap
    size_t: hb
    size_t: wb
    size_t: margin
    size_t: panel_w
    size_t: panel_h
    size_t: origin_row
    size_t: origin_col
    size_t: view_w
    size_t: scroll_x
    int: is_open
end: MixaButtonPanel

prototype:
    fn: mixa_button_panel_init (@: MixaButtonPanel panel; size_t: hb) int
    fn: mixa_button_panel_release (@: MixaButtonPanel panel) void
    fn: mixa_button_width (size_t: hb; size_t: wb; const: @(char label)) size_t
    fn: mixa_button_panel_add (@: MixaButtonPanel panel; size_t: line; const: @(char label); unsigned: fg; unsigned: bg; unsigned: alpha) int
    fn: mixa_button_panel_add_sep (@: MixaButtonPanel panel; size_t: line) int
    fn: mixa_button_panel_layout (@: MixaButtonPanel panel) int
    fn: mixa_button_panel_hit (const: @(MixaButtonPanel panel); size_t: cell_row; size_t: cell_col) int
    fn: mixa_button_panel_draw (const: @(MixaButtonPanel panel); @: MixaTextRect rect) int
    fn: mixa_button_panel_count (const: @(MixaButtonPanel panel)) size_t
end: prototype
""")
print("p2a ok")
