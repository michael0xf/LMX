/* 0BSD integration facade. Vendor implementations retain their own notices.
 * Selected permissive Embedded Artistry libc algorithms, never a replacement
 * for the host C runtime. malloc/free are supplied by the host/application.
 * Narrow classification is ASCII; wide input is explicitly 32-bit.
 * strtoll/strtoull saturate but do not set errno; base is 0 or 2..36.
 */
#ifndef LMX_EA_LIBC_H
#define LMX_EA_LIBC_H
#include <stddef.h>
#include <stdint.h>
#include <inttypes.h>
#include <stdlib.h>
typedef uint32_t lmx_ea_wint_t;
typedef int32_t lmx_ea_wchar_t;
#ifdef __cplusplus
extern "C" {
#endif
int lmx_ea_isalnum(int ch);
int lmx_ea_isalpha(int ch);
int lmx_ea_isascii(int ch);
int lmx_ea_isblank(int ch);
int lmx_ea_iscntrl(int ch);
int lmx_ea_isdigit(int ch);
int lmx_ea_isgraph(int ch);
int lmx_ea_islower(int ch);
int lmx_ea_isprint(int ch);
int lmx_ea_ispunct(int ch);
int lmx_ea_isspace(int ch);
int lmx_ea_isupper(int ch);
int lmx_ea_isxdigit(int ch);
int lmx_ea_toascii(int ch);
int lmx_ea_tolower(int ch);
int lmx_ea_toupper(int ch);
void *lmx_ea_memcpy(void *dst, const void *src, size_t n);
void *lmx_ea_memmove(void *dst, const void *src, size_t n);
void *lmx_ea_memset(void *dst, int value, size_t n);
int lmx_ea_memcmp(const void *a, const void *b, size_t n);
void *lmx_ea_memchr(const void *src, int value, size_t n);
void *lmx_ea_memrchr(const void *src, int value, size_t n);
void *lmx_ea_memmem(const void *hay, size_t hay_n, const void *needle, size_t needle_n);
size_t lmx_ea_strlen(const char *s);
size_t lmx_ea_strnlen(const char *s, size_t max_n);
int lmx_ea_strcmp(const char *a, const char *b);
int lmx_ea_strncmp(const char *a, const char *b, size_t n);
int lmx_ea_strcoll(const char *a, const char *b);
char *lmx_ea_strchr(const char *s, int c);
char *lmx_ea_strchrnul(const char *s, int c);
char *lmx_ea_strrchr(const char *s, int c);
char *lmx_ea_strstr(const char *s, const char *needle);
char *lmx_ea_strnstr(const char *s, const char *needle, size_t n);
size_t lmx_ea_strspn(const char *s, const char *accept);
size_t lmx_ea_strcspn(const char *s, const char *reject);
char *lmx_ea_strpbrk(const char *s, const char *accept);
char *lmx_ea_strtok(char *s, const char *delimiters);
char *lmx_ea_strtok_r(char *s, const char *delimiters, char **state);
char *lmx_ea_strdup(const char *s);
char *lmx_ea_strndup(const char *s, size_t n);
void *lmx_ea_calloc(size_t count, size_t size);
void *lmx_ea_bsearch(const void *key, const void *base, size_t count, size_t size, int (*compare)(const void *, const void *));
void lmx_ea_qsort(void *base, size_t count, size_t size, int (*compare)(const void *, const void *));
void lmx_ea_qsort_r(void *base, size_t count, size_t size, void *context, int (*compare)(void *, const void *, const void *));
int lmx_ea_heapsort(void *base, size_t count, size_t size, int (*compare)(const void *, const void *));
int lmx_ea_heapsort_r(void *base, size_t count, size_t size, void *context, int (*compare)(void *, const void *, const void *));
int lmx_ea_abs(int value);
long lmx_ea_labs(long value);
long long lmx_ea_llabs(long long value);
intmax_t lmx_ea_imaxabs(intmax_t value);
div_t lmx_ea_div(int a, int b);
ldiv_t lmx_ea_ldiv(long a, long b);
lldiv_t lmx_ea_lldiv(long long a, long long b);
imaxdiv_t lmx_ea_imaxdiv(intmax_t a, intmax_t b);
long long lmx_ea_strtoll(const char *s, char **end, int base);
unsigned long long lmx_ea_strtoull(const char *s, char **end, int base);
int lmx_ea_rand(void);
int lmx_ea_rand_r(unsigned int *state);
void lmx_ea_srand(unsigned int seed);
int lmx_ea_fls(int value);
int lmx_ea_flsl(long value);
int lmx_ea_flsll(long long value);
float lmx_ea_fabsf(float value);
double lmx_ea_fabs(double value);
int lmx_ea_iswalnum(lmx_ea_wint_t codepoint);
int lmx_ea_iswalpha(lmx_ea_wint_t codepoint);
int lmx_ea_iswblank(lmx_ea_wint_t codepoint);
int lmx_ea_iswcntrl(lmx_ea_wint_t codepoint);
int lmx_ea_iswdigit(lmx_ea_wint_t codepoint);
int lmx_ea_iswgraph(lmx_ea_wint_t codepoint);
int lmx_ea_iswlower(lmx_ea_wint_t codepoint);
int lmx_ea_iswprint(lmx_ea_wint_t codepoint);
int lmx_ea_iswpunct(lmx_ea_wint_t codepoint);
int lmx_ea_iswspace(lmx_ea_wint_t codepoint);
int lmx_ea_iswupper(lmx_ea_wint_t codepoint);
int lmx_ea_iswxdigit(lmx_ea_wint_t codepoint);
lmx_ea_wint_t lmx_ea_towlower(lmx_ea_wint_t codepoint);
lmx_ea_wint_t lmx_ea_towupper(lmx_ea_wint_t codepoint);
int lmx_ea_wcwidth(lmx_ea_wchar_t codepoint);
int lmx_ea_wcswidth(const lmx_ea_wchar_t *text, size_t count);
#ifdef __cplusplus
}
#endif
#endif
