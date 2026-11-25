#include <isocline.h>
#include <stdio.h>
#include <string.h>

#define CHECK(expr) do { if (!(expr)) { fprintf(stderr, "check failed at %d: %s\n", __LINE__, #expr); return 1; } } while (0)

int main(int argc, char **argv)
{
    const char utf8[] = "a\xc3\xa9z";
    const char *copy;
    if (argc == 2 && strcmp(argv[1], "--readline") == 0) {
        char *line = ic_readline("");
        CHECK(line != NULL);
        CHECK(strcmp(line, "hello \xce\xbb") == 0);
        ic_free(line);
        return 0;
    }
    CHECK(ic_next_char(utf8, 0) == 1);
    CHECK(ic_next_char(utf8, 1) == 3);
    CHECK(ic_prev_char(utf8, 3) == 1);
    CHECK(ic_prev_char(utf8, 0) == -1);
    CHECK(ic_starts_with("local-node", "local"));
    CHECK(ic_istarts_with("LoCaL", "local"));
    CHECK(ic_char_is_digit("7", 1));
    CHECK(!ic_char_is_digit("x", 1));
    CHECK(ic_match_token("actor send", 0, &ic_char_is_letter, "actor") == 5);
    CHECK(ic_match_token("actors", 0, &ic_char_is_letter, "actor") == 0);
    ic_set_prompt_marker("lmx> ", "...> ");
    CHECK(strcmp(ic_get_prompt_marker(), "lmx> ") == 0);
    CHECK(strcmp(ic_get_continuation_prompt_marker(), "...> ") == 0);
    copy = ic_strdup("owned by isocline");
    CHECK(copy != NULL && strcmp(copy, "owned by isocline") == 0);
    ic_free((void *)copy);
    ic_set_history(NULL, 8);
    ic_history_add("alpha");
    ic_history_remove_last();
    ic_history_clear();
    return 0;
}
