/* LMX adapter, MIT. Private ISO C99 replacement for the POSIX strdup calls.
 * Upstream source is included by the wrapper only after standard headers. */
#ifndef LMX_KLIB_C99_STRDUP_H
#define LMX_KLIB_C99_STRDUP_H
#include <stdlib.h>
#include <string.h>
static char *lmx_klib_strdup(const char *s)
{
    size_t n = strlen(s) + 1;
    char *p = (char *)malloc(n);
    if (p != NULL) memcpy(p, s, n);
    return p;
}
#endif
