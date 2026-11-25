#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>
#include "bgzf.h"
#define CHECK(x) do { if (!(x)) { fprintf(stderr, "%s:%d: %s\n", __FILE__, __LINE__, #x); return 1; } } while (0)
int main(void)
{
    char path[] = "klib-bgzf-XXXXXX";
    const char text[] = "LMX compressed block\n";
    char buffer[sizeof(text)] = {0};
    int fd = mkstemp(path);
    BGZF *file;
    CHECK(fd >= 0);
    file = bgzf_dopen(fd, "w");
    CHECK(file != NULL);
    CHECK(bgzf_write(file, text, sizeof(text)) == sizeof(text));
    CHECK(bgzf_close(file) == 0);
    file = bgzf_open(path, "r");
    CHECK(file != NULL);
    CHECK(bgzf_read(file, buffer, sizeof(buffer)) == sizeof(buffer));
    CHECK(memcmp(buffer, text, sizeof(text)) == 0);
    CHECK(bgzf_close(file) == 0);
    CHECK(unlink(path) == 0);
    return 0;
}
