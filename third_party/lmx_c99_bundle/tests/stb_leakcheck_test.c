#include <stdio.h>
#include <string.h>
#include "stb_leakcheck.h"

int main(void)
{
    unsigned char *p = calloc(8, 1);
    if (!p || p[7] != 0) return 1;
    memcpy(p, "C99", 4);
    p = realloc(p, 32);
    if (!p || strcmp((char *)p, "C99") != 0) return 2;
    free(p);
    stb_leakcheck_dumpmem();
    return 0;
}
