from pathlib import Path
DST = Path(r"C:\Nyasha_Planet\L1\dev\mixa_migration\mixa_manager")
def w(name, text):
    p = DST / name
    p.write_text(text.lstrip("\n"), encoding="utf-8", newline="\n")
    print("wrote", name, p.stat().st_size)

# backend.h.lm1 - mouse button enum renamed to MixaMouseButton to avoid
# collision with struct MixaButton (C defect: mixa_backend.h:126 vs mixa_buttons.h:16)
w("mixa_backend.h.lm1", """
include: "<stddef.h>"
predef: "mixa_manager/mixa_overlay.h.lm1"

# mixa_backend.h.lm1 - the one seam between Mixa Manager and a platform.
# L1 rename: enum MixaButton (mouse bits) -> MixaMouseButton; enumerator
# names MIXA_BUTTON_* unchanged. C headers collide on the bare typedef name
# with struct MixaButton in mixa_buttons.h (mixa_backend.h:126 / mixa_buttons.h:16).

enum: MixaEventKind
    MIXA_EVENT_NONE 0
    MIXA_EVENT_KEY 1
    MIXA_EVENT_MOUSE 2
    MIXA_EVENT_RESIZE 3
    MIXA_EVENT_CLOSE 4
    MIXA_EVENT_MOUSE_WHEEL 5
end: MixaEventKind

enum: MixaKeyCode
    MIXA_KEY_NONE 0
    MIXA_KEY_UP 1
    MIXA_KEY_DOWN 2
    MIXA_KEY_LEFT 3
    MIXA_KEY_RIGHT 4
    MIXA_KEY_HOME 5
    MIXA_KEY_END 6
    MIXA_KEY_PAGE_UP 7
    MIXA_KEY_PAGE_DOWN 8
    MIXA_KEY_INSERT 9
    MIXA_KEY_DELETE 10
    MIXA_KEY_BACKSPACE 11
    MIXA_KEY_TAB 12
    MIXA_KEY_ENTER 13
    MIXA_KEY_ESCAPE 14
    MIXA_KEY_F1 15
    MIXA_KEY_F2 16
    MIXA_KEY_F3 17
    MIXA_KEY_F4 18
    MIXA_KEY_F5 19
    MIXA_KEY_F6 20
    MIXA_KEY_F7 21
    MIXA_KEY_F8 22
    MIXA_KEY_F9 23
    MIXA_KEY_F10 24
    MIXA_KEY_F11 25
    MIXA_KEY_F12 26
end: MixaKeyCode

enum: MixaModifier
    MIXA_MOD_SHIFT 1
    MIXA_MOD_CTRL 2
    MIXA_MOD_ALT 4
    MIXA_MOD_META 8
end: MixaModifier

enum: MixaMouseButton
    MIXA_BUTTON_LEFT 1
    MIXA_BUTTON_MIDDLE 2
    MIXA_BUTTON_RIGHT 4
end: MixaMouseButton

enum: MixaGlyphLayer
    MIXA_LAYER_TEXT 0
    MIXA_LAYER_UPPER 1
    MIXA_LAYER_POINTER 2
end: MixaGlyphLayer

struct: MixaEvent
    int: kind
    unsigned: codepoint
    int: keycode
    unsigned: modifiers
    size_t: row
    size_t: col
    unsigned: buttons
    size_t: cols
    size_t: rows
    int: wheel_delta
end: MixaEvent

struct: MixaCellMetrics
    size_t: text_cell_width
    size_t: text_cell_height
    size_t: upper_cell_width
    size_t: upper_cell_height
    size_t: pointer_cell_width
    size_t: pointer_cell_height
end: MixaCellMetrics

struct: MixaGlyph
    size_t: width
    size_t: height
    int: bearing_x
    int: bearing_y
    size_t: advance
    const: @: MixaU8 coverage
    int: missing
end: MixaGlyph

# Forward: vtable defined after fnptrs
type: MixaBackendVTable struct MixaBackendVTable

struct: MixaBackend
    const: @: MixaBackendVTable vt
end: MixaBackend

fnptr: MixaBackendOpenFn (@@: MixaBackend out; size_t: cols; size_t: rows; @: MixaCellMetrics metrics) int
fnptr: MixaBackendPresentFn (@: MixaBackend backend; const: @(MixaU8 rgba); size_t: bytes) int
fnptr: MixaBackendPollFn (@: MixaBackend backend; @: MixaEvent out) int
fnptr: MixaBackendClipboardGetFn (const: @(MixaBackend backend); @: char out; size_t: cap) size_t
fnptr: MixaBackendClipboardSetFn (@: MixaBackend backend; const: @(char text)) int
fnptr: MixaBackendGlyphFn (@: MixaBackend backend; int: layer; unsigned: codepoint; @: MixaGlyph out) int
fnptr: MixaBackendCloseFn (@: MixaBackend backend) void

struct: MixaBackendVTable
    const: @: char name
    MixaBackendOpenFn: open
    MixaBackendPresentFn: present
    MixaBackendPollFn: poll
    MixaBackendClipboardGetFn: clipboard_get
    MixaBackendClipboardSetFn: clipboard_set
    MixaBackendGlyphFn: glyph
    MixaBackendCloseFn: close
end: MixaBackendVTable

type: MixaBackendTableRef const @: MixaBackendVTable

prototype:
    fn: mixa_backend_open (const: @(MixaBackendVTable vt); @@: MixaBackend out; size_t: cols; size_t: rows; @: MixaCellMetrics metrics) int
    fn: mixa_backend_present (@: MixaBackend backend; const: @(MixaU8 rgba); size_t: bytes) int
    fn: mixa_backend_poll (@: MixaBackend backend; @: MixaEvent out) int
    fn: mixa_backend_clipboard_get (const: @(MixaBackend backend); @: char out; size_t: cap) size_t
    fn: mixa_backend_clipboard_set (@: MixaBackend backend; const: @(char text)) int
    fn: mixa_backend_close (@: MixaBackend backend) void
    fn: mixa_backend_glyph (@: MixaBackend backend; int: layer; unsigned: codepoint; @: MixaGlyph out) int
    fn: mixa_backend_table_valid (const: @(MixaBackendVTable vt)) int
end: prototype
""")

w("mixa_event_fifo.h.lm1", """
include: "<stddef.h>"
predef: "mixa_manager/mixa_backend.h.lm1"

struct: MixaEventFifo
    @: MixaEvent items
    size_t: capacity
    size_t: head
    size_t: count
    int: is_open
end: MixaEventFifo

prototype:
    fn: mixa_event_fifo_init (@: MixaEventFifo fifo) int
    fn: mixa_event_fifo_release (@: MixaEventFifo fifo) void
    fn: mixa_event_fifo_push (@: MixaEventFifo fifo; const: @(MixaEvent ev)) int
    fn: mixa_event_fifo_pop (@: MixaEventFifo fifo; @: MixaEvent out) int
    fn: mixa_event_fifo_count (const: @(MixaEventFifo fifo)) size_t
end: prototype
""")

w("mixa_pump.h.lm1", """
include: "<stddef.h>"
predef: "mixa_manager/mixa_backend.h.lm1"
predef: "mixa_manager/mixa_event_fifo.h.lm1"

struct: MixaPump
    MixaEventFifo: inbox
    int: is_open
end: MixaPump

prototype:
    fn: mixa_pump_open (@: MixaPump pump) int
    fn: mixa_pump_release (@: MixaPump pump) void
    fn: mixa_pump_drain (@: MixaPump pump; @: MixaBackend backend) int
    fn: mixa_pump_next (@: MixaPump pump; @: MixaEvent out) int
    fn: mixa_pump_pending (const: @(MixaPump pump)) size_t
end: prototype
""")

w("mixa_backend_headless.h.lm1", """
predef: "mixa_manager/mixa_backend.h.lm1"
predef: "mixa_manager/mixa_event_fifo.h.lm1"

struct: MixaHeadless
    const: @: MixaBackendVTable vt
    int: is_open
    size_t: cols
    size_t: rows
    size_t: cell_width
    size_t: cell_height
    size_t: frame_w
    size_t: frame_h
    size_t: frame_bytes
    @: MixaU8 frame
    @: char clipboard
    size_t: clipboard_len
    @: MixaEventFifo inbox
end: MixaHeadless

prototype:
    fn: mixa_backend_headless_table () const @: MixaBackendVTable
    fn: mixa_headless_push_event (@: MixaBackend backend; const: @(MixaEvent ev)) int
    fn: mixa_headless_frame_at (const: @(MixaBackend backend); size_t: x; size_t: y; @: MixaU8 out) int
end: prototype
""")

w("mixa_pointer.h.lm1", """
include: "<stddef.h>"
include: "<stdint.h>"

define: MIXA_POINTER_OK 0
define: MIXA_POINTER_ERR 1
define: MIXA_POINTER_UP 0
define: MIXA_POINTER_UP_RIGHT 1
define: MIXA_POINTER_RIGHT 2
define: MIXA_POINTER_DOWN_RIGHT 3
define: MIXA_POINTER_DOWN 4
define: MIXA_POINTER_DOWN_LEFT 5
define: MIXA_POINTER_LEFT 6
define: MIXA_POINTER_UP_LEFT 7
define: MIXA_POINTER_CP_UP 0x2B06U
define: MIXA_POINTER_CP_UP_RIGHT 0x2B08U
define: MIXA_POINTER_CP_RIGHT 0x2B95U
define: MIXA_POINTER_CP_DOWN_RIGHT 0x2B0AU
define: MIXA_POINTER_CP_DOWN 0x2B07U
define: MIXA_POINTER_CP_DOWN_LEFT 0x2B0BU
define: MIXA_POINTER_CP_LEFT 0x2B05U
define: MIXA_POINTER_CP_UP_LEFT 0x2B09U

struct: MixaPointer
    int: is_open
    int: octant
    size_t: row
    size_t: col
end: MixaPointer

prototype:
    fn: mixa_pointer_init (@: MixaPointer p) int
    fn: mixa_pointer_release (@: MixaPointer p) void
    fn: mixa_pointer_codepoint (const: @(MixaPointer p)) unsigned
    fn: mixa_pointer_codepoint_for_octant (int: octant) unsigned
    fn: mixa_pointer_octant_from_delta (int32_t: dx; int32_t: dy; int: prev_octant) int
    fn: mixa_pointer_nudge (@: MixaPointer p; int32_t: dx; int32_t: dy) int
    fn: mixa_pointer_move_to (@: MixaPointer p; size_t: row; size_t: col) int
end: prototype
""")

w("mixa_highlight.h.lm1", """
include: "<stddef.h>"
predef: "mixa_manager/mixa_core.h.lm1"

struct: MixaHighlight
    int: is_open
    int: is_active
    size_t: row
    size_t: col
    size_t: nrows
    size_t: ncols
    unsigned: fg
    @: MixaCell saved
    size_t: saved_count
    size_t: saved_cap
    @: MixaTextRect target_rect
    @: MixaCell target_cells
    size_t: target_rows
    size_t: target_cols
end: MixaHighlight

prototype:
    fn: mixa_highlight_init (@: MixaHighlight hl) int
    fn: mixa_highlight_release (@: MixaHighlight hl) void
    fn: mixa_highlight_set (@: MixaHighlight hl; @: MixaTextRect rect; size_t: row; size_t: col; size_t: nrows; size_t: ncols; unsigned: fg) int
    fn: mixa_highlight_clear (@: MixaHighlight hl; @: MixaTextRect rect) int
end: prototype
""")

print("p2b ok")
