/* MIT, same terms as vendor/liblsoda/LICENSE.
 * Preserve the internal signature; account for the terminating NUL and errors.
 */
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>

char *_strdup_printf(char *fmt, ...)
{
    va_list ap;
    int n;
    char *out;
    va_start(ap, fmt);
    n = vsnprintf(NULL, 0, fmt, ap);
    va_end(ap);
    if (n < 0) return NULL;
    out = (char *)malloc((size_t)n + 1);
    if (out == NULL) return NULL;
    va_start(ap, fmt);
    if (vsnprintf(out, (size_t)n + 1, fmt, ap) != n) {
        va_end(ap);
        free(out);
        return NULL;
    }
    va_end(ap);
    return out;
}
