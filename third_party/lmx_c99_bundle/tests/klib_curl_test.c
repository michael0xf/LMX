#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>
#include "kurl.h"
#define CHECK(x) do { if (!(x)) { fprintf(stderr, "%s:%d: %s\n", __FILE__, __LINE__, #x); return 1; } } while (0)
int main(void)
{
    char path[] = "klib-curl-XXXXXX";
    const char text[] = "LMX local kurl\n";
    char buffer[sizeof(text)] = {0};
    int fd = mkstemp(path);
    kurl_t *file;
    CHECK(fd >= 0);
    CHECK(write(fd, text, sizeof(text)) == sizeof(text));
    CHECK(lseek(fd, 0, SEEK_SET) == 0);
    CHECK(kurl_init() == 0);
    file = kurl_dopen(fd);
    CHECK(file != NULL);
    CHECK(kurl_read(file, buffer, sizeof(buffer)) == sizeof(buffer));
    CHECK(memcmp(buffer, text, sizeof(text)) == 0);
    CHECK(kurl_close(file) == 0);
    kurl_destroy();
    CHECK(unlink(path) == 0);
    return 0;
}
