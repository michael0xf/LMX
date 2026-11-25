#include <graphemebreak.h>
#include <linebreak.h>
#include <wordbreak.h>
#include <stdio.h>

#define CHECK(expr) do { if (!(expr)) { fprintf(stderr, "check failed at %d: %s\n", __LINE__, #expr); return 1; } } while (0)

int main(void)
{
    const utf8_t combining[] = { 'a', 0xcc, 0x81, 'b' };
    const utf32_t emoji[] = { 0x1f469, 0x200d, 0x1f4bb };
    const utf16_t utf16[] = { 0xd83d, 0xde00, 'a' };
    char marks[8];
    CHECK(unibreak_version == 0x0800);
    init_linebreak(); init_wordbreak(); init_graphemebreak();
    set_graphemebreaks_utf8(combining, 4, NULL, marks);
    CHECK(marks[0] == GRAPHEMEBREAK_NOBREAK);
    CHECK(marks[1] == GRAPHEMEBREAK_INSIDEACHAR);
    CHECK(marks[2] == GRAPHEMEBREAK_BREAK && marks[3] == GRAPHEMEBREAK_BREAK);
    set_graphemebreaks_utf32(emoji, 3, NULL, marks);
    CHECK(marks[0] == GRAPHEMEBREAK_NOBREAK && marks[1] == GRAPHEMEBREAK_NOBREAK);
    CHECK(marks[2] == GRAPHEMEBREAK_BREAK);
    set_graphemebreaks_utf16(utf16, 3, NULL, marks);
    CHECK(marks[0] == GRAPHEMEBREAK_INSIDEACHAR && marks[1] == GRAPHEMEBREAK_BREAK);
    set_linebreaks_utf8((const utf8_t *)"a b\n", 4, "en", marks);
    CHECK(marks[0] == LINEBREAK_NOBREAK && marks[1] == LINEBREAK_ALLOWBREAK);
    CHECK(marks[2] == LINEBREAK_NOBREAK && marks[3] == LINEBREAK_MUSTBREAK);
    set_wordbreaks_utf8((const utf8_t *)"abc def", 7, "en", marks);
    CHECK(marks[0] == WORDBREAK_NOBREAK && marks[2] == WORDBREAK_BREAK);
    CHECK(marks[3] == WORDBREAK_BREAK);
    return 0;
}
