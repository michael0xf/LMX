from pathlib import Path
DST = Path(r"C:\Nyasha_Planet\L1\dev\mixa_migration\mixa_manager")
def w(name, text):
    p = DST / name
    p.write_text(text.lstrip("\n"), encoding="utf-8", newline="\n")
    print("wrote", name, p.stat().st_size)

w("mixa_app_controller.h.lm1", """
include: "<stddef.h>"
predef: "mixa_manager/mixa_backend.h.lm1"
predef: "mixa_manager/mixa_core.h.lm1"

define: MIXA_APP_CONTROLLER_OK 0
define: MIXA_APP_CONTROLLER_ERR_ARG 1
define: MIXA_APP_CONTROLLER_ERR_OPEN 2

type: MixaAppController struct MixaAppController
type: MixaFm struct MixaFm
type: MixaAppFmPanel struct MixaAppFmPanel

prototype:
    fn: mixa_app_controller_open (@@: MixaAppController out; const: @(MixaBackendVTable vt); const: @(char root_utf8)) int
    fn: mixa_app_controller_step (@: MixaAppController c; @: int out_had_error) int
    fn: mixa_app_controller_running (const: @(MixaAppController c)) int
    fn: mixa_app_controller_close (@: MixaAppController c) void
    fn: mixa_app_controller_backend (const: @(MixaAppController c)) @: MixaBackend
    fn: mixa_app_controller_text_rect (const: @(MixaAppController c)) const @: MixaTextRect
    fn: mixa_app_controller_upper_rect (const: @(MixaAppController c)) const @: MixaTextRect
    fn: mixa_app_controller_command_running (const: @(MixaAppController c)) int
    fn: mixa_app_controller_last_exit_code (const: @(MixaAppController c)) int
    fn: mixa_app_controller_cwd (const: @(MixaAppController c)) const @: char
    fn: mixa_app_controller_cursor_row (const: @(MixaAppController c)) size_t
    fn: mixa_app_controller_cursor_col (const: @(MixaAppController c)) size_t
    fn: mixa_app_controller_file_size (const: @(MixaAppController c)) size_t
    fn: mixa_app_controller_fm (const: @(MixaAppController c)) @: MixaFm
    fn: mixa_app_controller_fmpanel (const: @(MixaAppController c)) @: MixaAppFmPanel
end: prototype
""")

w("mixa_app_controller_impl.h.lm1", """
predef: "mixa_manager/mixa_app_controller.h.lm1"
predef: "mixa_manager/mixa_file.h.lm1"
predef: "mixa_manager/mixa_help.h.lm1"
predef: "mixa_manager/mixa_cmdline.h.lm1"
predef: "mixa_manager/mixa_cmdline_dispatch.h.lm1"
predef: "mixa_manager/mixa_backend.h.lm1"
predef: "mixa_manager/mixa_core.h.lm1"
predef: "mixa_manager/mixa_overlay.h.lm1"
include: "<stddef.h>"

# Forward tags only (incomplete until their own headers are predef'd by the unit).
type: MixaAppLoop struct MixaAppLoop
type: MixaFmAllocVTable struct MixaFmAllocVTable
type: MixaConsoleView struct MixaConsoleView
type: MixaConsolePending struct MixaConsolePending
type: MixaCopySink struct MixaCopySink

struct: MixaAppController
    @: char root
    @: MixaAppLoop loop
    @: MixaCellMetrics m
    @: MixaEvent ev
    @: MixaFmAllocVTable av
    const: @: MixaBackendVTable vt
    @: char console_path
    @: MixaFile console_file
    @: MixaFile console_file_append
    @: MixaConsoleView view
    @: MixaTextRect text_rect
    @: MixaTextRect upper_rect
    @: MixaU8 rgba
    size_t: width_px
    size_t: height_px
    size_t: rgba_size
    @: MixaHelpCtx help_ctx
    size_t: help_btn_row
    size_t: help_btn_col
    size_t: help_btn_nrows
    size_t: help_btn_ncols
    @: MixaCmdLine cmdline
    @: MixaCmdDispatch dispatch
    @: char cwd_owned
    const: @: char cwd_cur
    @: MixaConsolePending pending_view
    int: last_exit_code
    @: MixaAppFmPanel fmpanel
    @: MixaCopySink copy_sink
end: MixaAppController
""")

w("mixa_app_fmpanel.h.lm1", """
include: "<stddef.h>"
predef: "mixa_manager/mixa_core.h.lm1"

define: MIXA_APP_FMPANEL_OK 0
define: MIXA_APP_FMPANEL_ERR_ARG 1
define: MIXA_APP_FMPANEL_ERR_NOMEM 2

type: MixaFm struct MixaFm
type: MixaAppFmPanel struct MixaAppFmPanel

prototype:
    fn: mixa_app_fmpanel_open (@@: MixaAppFmPanel out; @: MixaFm fm; size_t: list_row; size_t: list_col; size_t: list_rows; size_t: list_cols) int
    fn: mixa_app_fmpanel_close (@: MixaAppFmPanel p) void
    fn: mixa_app_fmpanel_render (@: MixaAppFmPanel p; @: MixaTextRect rect) int
    fn: mixa_app_fmpanel_hit (@: MixaAppFmPanel p; @: MixaTextRect rect; size_t: cell_row; size_t: cell_col) int
    fn: mixa_app_fmpanel_confirm_is_open (const: @(MixaAppFmPanel p)) int
    fn: mixa_app_fmpanel_report_copy_result (@: MixaAppFmPanel p; int: status) void
    fn: mixa_app_fmpanel_key (@: MixaAppFmPanel p; int: keycode) int
    fn: mixa_app_fmpanel_wheel (@: MixaAppFmPanel p; size_t: cell_row; size_t: cell_col; int: notches) int
    fn: mixa_app_fmpanel_release (@: MixaAppFmPanel p) int
    fn: mixa_app_fmpanel_view_top (const: @(MixaAppFmPanel p)) size_t
    fn: mixa_app_fmpanel_highlight_index (const: @(MixaAppFmPanel p)) int
    fn: mixa_app_fmpanel_drag_active (const: @(MixaAppFmPanel p)) int
end: prototype
""")

w("mixa_app_fmpanel_impl.h.lm1", """
predef: "mixa_manager/mixa_app_fmpanel.h.lm1"
predef: "mixa_manager/mixa_highlight.h.lm1"
predef: "mixa_manager/mixa_core.h.lm1"
include: "<stddef.h>"

define: MIXA_APP_FMPANEL_PATH_MAX 1024

struct: MixaAppFmPanel
    @: MixaFm fm
    size_t: list_row
    size_t: list_col
    size_t: list_rows
    size_t: list_cols
    size_t: action_row
    size_t: action_col
    int: confirm_open
    size_t: confirm_row
    size_t: confirm_col
    size_t: confirm_rows
    size_t: confirm_cols
    size_t: cancel_row
    size_t: cancel_col
    size_t: cancel_w
    size_t: ok_row
    size_t: ok_col
    size_t: ok_w
    @: MixaCell saved
    size_t: saved_count
    size_t: saved_row
    size_t: saved_col
    size_t: saved_rows
    size_t: saved_cols
    int: invocations
    int: has_failure
    int: last_status
    []: char failing_path MIXA_APP_FMPANEL_PATH_MAX
    int: has_copy_result
    int: copy_last_status
    size_t: view_top
    int: highlight_idx
    []: char last_dir MIXA_APP_FMPANEL_PATH_MAX
    int: has_last_dir
    int: drag_active
    size_t: drag_grab_offset
    MixaHighlight: focus
end: MixaAppFmPanel
""")

w("mixa_backend_win32.h.lm1", """
predef: "mixa_manager/mixa_backend.h.lm1"
include: "<stddef.h>"
include: "<windows.h>"

# Concrete Win32 backend. HWND/HDC/HBITMAP/HFONT as @: void (HANDLE-family).

struct: MixaWin32GlyphEntry
    unsigned: codepoint
    int: layer
    int: missing
    size_t: width
    size_t: height
    int: bearing_x
    int: bearing_y
    size_t: advance
    @: MixaU8 coverage
    @: MixaWin32GlyphEntry next
end: MixaWin32GlyphEntry

struct: MixaWin32
    const: @: MixaBackendVTable vt
    int: is_open
    @: void hwnd
    @: void hdc_mem
    @: void hbmp
    @: void hbmp_old
    @: MixaU8 bits
    size_t: cols
    size_t: rows
    size_t: cell_width
    size_t: cell_height
    size_t: upper_cell_width
    size_t: upper_cell_height
    size_t: pointer_cell_width
    size_t: pointer_cell_height
    size_t: frame_w
    size_t: frame_h
    size_t: frame_bytes
    @: void hfont_text
    @: void hfont_upper
    @: void hfont_pointer
    @: void hdc_glyph
    int: text_ascent
    int: upper_ascent
    int: pointer_ascent
    @: MixaWin32GlyphEntry glyph_cache
    int: force_gdi_error
end: MixaWin32

prototype:
    fn: mixa_backend_win32_table () const @: MixaBackendVTable
    fn: mixa_backend_win32_hidden_table () const @: MixaBackendVTable
    fn: mixa_win32_frame_at (const: @(MixaBackend backend); size_t: x; size_t: y; @: MixaU8 out) int
    fn: mixa_win32_test_set_force_ggo_error (@: MixaBackend backend; int: on) int
end: prototype
""")

w("tests\\l1_gaps\\vt.h.lm1", """
include: "<stddef.h>"

struct: VT
    int: x
end: VT

type: VTRef const @: VT

prototype:
    fn: reg_tables (@: size_t count) const @@: VT
end: prototype
""")

print("p4 ok")
