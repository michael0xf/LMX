from pathlib import Path
DST = Path(r"C:\Nyasha_Planet\L1\dev\mixa_migration\mixa_manager")
def w(name, text):
    p = DST / name
    p.write_text(text.lstrip("\n"), encoding="utf-8", newline="\n")
    print("wrote", name, p.stat().st_size)

w("mixa_process.h.lm1", """
include: "<stddef.h>"

define: MIXA_PROC_OK 0
define: MIXA_PROC_ERR_ARG 1
define: MIXA_PROC_ERR_SPAWN 2
define: MIXA_PROC_ERR_IO 3
define: MIXA_PROC_ERR_NOMEM 4
define: MIXA_PROC_EOF 5

type: MixaProcess struct MixaProcess

prototype:
    fn: mixa_process_spawn (@@: MixaProcess out; const: @(char command_line_utf8); const: @(char cwd_utf8); int: stdin_enabled) int
    fn: mixa_process_read (@: MixaProcess p; @: void buf; size_t: cap; @: size_t got) int
    fn: mixa_process_write (@: MixaProcess p; const: @(void buf); size_t: n; @: size_t wrote) int
    fn: mixa_process_status (@: MixaProcess p; @: int running; @: int exit_code) int
    fn: mixa_process_kill (@: MixaProcess p) int
    fn: mixa_process_close (@@: MixaProcess p) void
end: prototype
""")

w("mixa_process_win32.h.lm1", """
predef: "mixa_manager/mixa_process.h.lm1"
include: "<stddef.h>"
include: "mixa_manager/mixa_file_win32_l2_win.h"

# Concrete Win32 MixaProcess. HANDLEs as @: void.

struct: MixaProcess
    @: void h_process
    @: void h_thread
    @: void h_job
    @: void h_out_read
    @: void h_in_write
    int: stdin_enabled
    int: eof_seen
    int: is_closed
end: MixaProcess
""")

w("mixa_help.h.lm1", """
include: "<stddef.h>"
predef: "mixa_manager/mixa_file.h.lm1"
predef: "mixa_manager/mixa_backend.h.lm1"

define: MIXA_HELP_OK 0
define: MIXA_HELP_ERR_ARG 1
define: MIXA_HELP_ERR_NOMEM 2
define: MIXA_HELP_ERR_IO 3
define: MIXA_HELP_HIT_NONE 0
define: MIXA_HELP_HIT_ACTION 1

struct: MixaHelpCtx
    @: MixaFile console_file
    int: last_status
end: MixaHelpCtx

prototype:
    fn: mixa_help_text () const @: char
    fn: mixa_help_action (@: void ctx_raw) int
    fn: mixa_help_key_event (@: MixaHelpCtx ctx; const: @(MixaEvent ev)) int
    fn: mixa_help_hit (@: MixaHelpCtx ctx; size_t: cell_row; size_t: cell_col; size_t: btn_row; size_t: btn_col; size_t: btn_nrows; size_t: btn_ncols) int
end: prototype
""")

w("mixa_cmdline.h.lm1", """
include: "<stddef.h>"

define: MIXA_CMDLINE_OK 0
define: MIXA_CMDLINE_ERR_ARG 1
define: MIXA_CMDLINE_ERR_NOMEM 2

fnptr: MixaCmdLineFaultFn (@: void ctx; size_t: requested_size) int

struct: MixaCmdLineFaultVTable
    MixaCmdLineFaultFn: on_alloc
    @: void ctx
end: MixaCmdLineFaultVTable

struct: MixaCmdLine
    @: unsigned cps
    size_t: len
    size_t: cap
    size_t: cursor
end: MixaCmdLine

prototype:
    fn: mixa_cmdline_init (@: MixaCmdLine cl) void
    fn: mixa_cmdline_release (@: MixaCmdLine cl) void
    fn: mixa_cmdline_insert (@: MixaCmdLine cl; const: @(MixaCmdLineFaultVTable fault); unsigned: codepoint) int
    fn: mixa_cmdline_backspace (@: MixaCmdLine cl) void
    fn: mixa_cmdline_delete_forward (@: MixaCmdLine cl) void
    fn: mixa_cmdline_move_left (@: MixaCmdLine cl) void
    fn: mixa_cmdline_move_right (@: MixaCmdLine cl) void
    fn: mixa_cmdline_move_home (@: MixaCmdLine cl) void
    fn: mixa_cmdline_move_end (@: MixaCmdLine cl) void
    fn: mixa_cmdline_clear (@: MixaCmdLine cl) void
    fn: mixa_cmdline_extract_to_cursor_utf8 (const: @(MixaCmdLine cl); const: @(MixaCmdLineFaultVTable fault); @@: char out) int
    fn: mixa_cmdline_char_position (size_t: start_row; size_t: start_col; size_t: screen_cols; size_t: screen_rows; size_t: index; size_t: len; @: size_t out_row; @: size_t out_col) int
end: prototype
""")

w("mixa_cmdline_dispatch.h.lm1", """
include: "<stddef.h>"
predef: "mixa_manager/mixa_file.h.lm1"

define: MIXA_CMD_DISPATCH_OK 0
define: MIXA_CMD_DISPATCH_ERR_ARG 1
define: MIXA_CMD_DISPATCH_ERR_NOMEM 2
define: MIXA_CMD_DISPATCH_ERR_IO 3
define: MIXA_CMD_DISPATCH_ERR_SPAWN 4
define: MIXA_CMD_DISPATCH_RUNNING 0
define: MIXA_CMD_DISPATCH_DONE 1

type: MixaCmdDispatch struct MixaCmdDispatch

prototype:
    fn: mixa_cmd_dispatch_start (const: @(char command_utf8); const: @(char cwd_utf8); @: MixaFile console_file; @@: MixaCmdDispatch out) int
    fn: mixa_cmd_dispatch_poll (@: MixaCmdDispatch d; @: int out_exit_code; @@: char out_new_cwd) int
    fn: mixa_cmd_dispatch_running (const: @(MixaCmdDispatch d)) int
    fn: mixa_cmd_dispatch_release (@: MixaCmdDispatch d) void
end: prototype
""")

w("mixa_cmdline_dispatch_impl.h.lm1", """
predef: "mixa_manager/mixa_cmdline_dispatch.h.lm1"
predef: "mixa_manager/mixa_process.h.lm1"
predef: "mixa_manager/mixa_file.h.lm1"
include: "<stddef.h>"

# Concrete MixaCmdDispatch. MixaProcessMarkerScanner is forward-only here.
type: MixaProcessMarkerScanner struct MixaProcessMarkerScanner

struct: MixaCmdDispatch
    @: MixaProcess proc
    @: MixaProcessMarkerScanner scanner
    @: MixaFile console_file
    @: char wrapper_path
    int: done
    int: exit_code
    @: char new_cwd
end: MixaCmdDispatch
""")

w("mixa_app_path.h.lm1", """
include: "<stddef.h>"

define: MIXA_APP_PATH_OK 0
define: MIXA_APP_PATH_ERR_ARG 1
define: MIXA_APP_PATH_ERR_NOMEM 2
define: MIXA_APP_PATH_ERR_OVERFLOW 3

fnptr: MixaAppPathFaultFn (@: void ctx; size_t: requested_size) int

struct: MixaAppPathFaultVTable
    MixaAppPathFaultFn: on_alloc
    @: void ctx
end: MixaAppPathFaultVTable

prototype:
    fn: mixa_app_path_total (size_t: a_len; size_t: b_len; @: size_t out_total) int
    fn: mixa_app_path_join (const: @(char a); const: @(char b); const: @(MixaAppPathFaultVTable fault); @@: char out) int
end: prototype
""")

print("p3a ok")
