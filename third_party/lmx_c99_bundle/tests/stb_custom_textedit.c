/* Minimal application adapter: bounded ASCII string and single-line layout.
 * Exercises editing and undo/redo without an OS, window system or renderer.
 * This is not a Unicode, multiline layout or exhaustive editor test. */
#include "stb_test_common.h"
#include <string.h>

typedef struct {
    char bytes[256];
    int length;
} TestText;

#define STB_TEXTEDIT_CHARTYPE char
#define STB_TEXTEDIT_STRING TestText
#include <stb_textedit.h>

static int text_insert(TestText *text, int position, const char *input, int count) {
    if (position < 0 || position > text->length || count < 0 ||
        count > (int)sizeof(text->bytes) - 1 - text->length) return 0;
    memmove(text->bytes + position + count, text->bytes + position,
            (size_t)(text->length - position + 1));
    memcpy(text->bytes + position, input, (size_t)count);
    text->length += count;
    return 1;
}

static void text_delete(TestText *text, int position, int count) {
    memmove(text->bytes + position, text->bytes + position + count,
            (size_t)(text->length - position - count + 1));
    text->length -= count;
}

static void text_layout(StbTexteditRow *row, TestText *text, int start) {
    row->x0 = 0.0f;
    row->x1 = (float)(text->length - start);
    row->baseline_y_delta = 1.0f;
    row->ymin = 0.0f;
    row->ymax = 1.0f;
    row->num_chars = text->length - start;
}

#define STB_TEXTEDIT_STRINGLEN(text) ((text)->length)
#define STB_TEXTEDIT_GETCHAR(text, index) ((text)->bytes[index])
#define STB_TEXTEDIT_GETWIDTH(text, start, index) (1.0f)
#define STB_TEXTEDIT_LAYOUTROW(row, text, start) text_layout(row, text, start)
#define STB_TEXTEDIT_DELETECHARS(text, at, count) text_delete(text, at, count)
#define STB_TEXTEDIT_INSERTCHARS(text, at, chars, count) text_insert(text, at, chars, count)
#define STB_TEXTEDIT_NEWLINE '\n'
#define STB_TEXTEDIT_KEYTOTEXT(key) ((key) >= 32 && (key) < 127 ? (key) : 0)
#define STB_TEXTEDIT_K_SHIFT     0x10000
#define STB_TEXTEDIT_K_LEFT      0x100
#define STB_TEXTEDIT_K_RIGHT     0x101
#define STB_TEXTEDIT_K_UP        0x102
#define STB_TEXTEDIT_K_DOWN      0x103
#define STB_TEXTEDIT_K_PGUP      0x104
#define STB_TEXTEDIT_K_PGDOWN    0x105
#define STB_TEXTEDIT_K_LINESTART 0x106
#define STB_TEXTEDIT_K_LINEEND   0x107
#define STB_TEXTEDIT_K_TEXTSTART 0x108
#define STB_TEXTEDIT_K_TEXTEND   0x109
#define STB_TEXTEDIT_K_DELETE    0x10a
#define STB_TEXTEDIT_K_BACKSPACE 0x10b
#define STB_TEXTEDIT_K_UNDO      0x10c
#define STB_TEXTEDIT_K_REDO      0x10d
#define STB_TEXTEDIT_IMPLEMENTATION
#include <stb_textedit.h>

int main(void) {
    TestText text = {{0}, 0};
    STB_TexteditState state;
    stb_textedit_initialize_state(&state, 1);
    CHECK(stb_textedit_paste(&text, &state, "abc", 3));
    CHECK(strcmp(text.bytes, "abc") == 0 && state.cursor == 3);
    stb_textedit_key(&text, &state, STB_TEXTEDIT_K_LEFT);
    stb_textedit_char(&text, &state, 'X');
    CHECK(strcmp(text.bytes, "abXc") == 0);
    stb_textedit_key(&text, &state, STB_TEXTEDIT_K_UNDO);
    CHECK(strcmp(text.bytes, "abc") == 0);
    stb_textedit_key(&text, &state, STB_TEXTEDIT_K_REDO);
    CHECK(strcmp(text.bytes, "abXc") == 0);
    stb_textedit_key(&text, &state, STB_TEXTEDIT_K_BACKSPACE);
    CHECK(strcmp(text.bytes, "abc") == 0);
    stb_textedit_click(&text, &state, 0.0f, 0.0f);
    stb_textedit_drag(&text, &state, 1.0f, 0.0f);
    CHECK(stb_textedit_cut(&text, &state));
    CHECK(strcmp(text.bytes, "bc") == 0);
    stb_textedit_key(&text, &state, STB_TEXTEDIT_K_UNDO);
    CHECK(strcmp(text.bytes, "abc") == 0);
    return EXIT_SUCCESS;
}
