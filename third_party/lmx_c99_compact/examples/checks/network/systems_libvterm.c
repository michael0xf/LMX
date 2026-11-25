#include "check.h"
#include <string.h>
#include "vterm.h"
int main(void) {
    VTerm *v = vterm_new(4, 20); VTermScreen *screen; VTermScreenCell cell; VTermPos p = {0, 0};
    const char sequence[] = "\033[31mA\033[0mB\033[2;4HZ";
    CHECK(v != NULL); vterm_set_utf8(v, 1); screen = vterm_obtain_screen(v); CHECK(screen != NULL);
    vterm_screen_reset(screen, 1); CHECK(vterm_input_write(v, sequence, sizeof(sequence)-1) == sizeof(sequence)-1);
    CHECK(vterm_screen_get_cell(screen, p, &cell) == 1 && cell.chars[0] == 'A');
    CHECK(VTERM_COLOR_IS_INDEXED(&cell.fg) && cell.fg.indexed.idx == 1);
    p.col = 1; CHECK(vterm_screen_get_cell(screen, p, &cell) == 1 && cell.chars[0] == 'B');
    p.row = 1; p.col = 3; CHECK(vterm_screen_get_cell(screen, p, &cell) == 1 && cell.chars[0] == 'Z');
    vterm_state_get_cursorpos(vterm_obtain_state(v), &p); CHECK(p.row == 1 && p.col == 4);
    vterm_free(v); puts("libvterm ANSI color/cursor parsing and screen cells: OK"); return 0;
}
