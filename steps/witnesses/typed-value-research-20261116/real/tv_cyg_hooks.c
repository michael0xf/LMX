/* FABLE-R-TV-D item 5, counting variant (opus, 2026-11-16).  driver.c is one translation unit, so at -O2 GCC inlines
 * many runtime functions into their callers and gprof's mcount never sees those calls.  -finstrument-functions calls
 * __cyg_profile_func_enter for every function entry, inlined copies included (the GCC manual: the instrumentation
 * "is also done for functions expanded inline in other functions"), with the address of the function's out-of-line
 * body.  This file counts those entries per address and writes them at exit; prof.sh names them with nm.
 *
 * Compile this file WITHOUT -finstrument-functions.  Output: $LMX_CYG_OUT, else cyg-counts.txt in the current
 * directory; the first line "#self <hex>" is this file's __cyg_profile_func_enter at run time, so prof.sh can undo an
 * image relocation (the link also passes --disable-dynamicbase).  Lines: <16 hex digits> TAB <decimal count>. */
#include <stdio.h>
#include <stdlib.h>

#define TV_CYG_CAP 65536U

static void * tv_cyg_keys[TV_CYG_CAP];
static unsigned long long tv_cyg_counts[TV_CYG_CAP];
static unsigned long long tv_cyg_lost;

void __cyg_profile_func_enter(void * fn, void * site) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void * fn, void * site) __attribute__((no_instrument_function));
static void tv_cyg_dump(void) __attribute__((no_instrument_function));
static void tv_cyg_open(void) __attribute__((no_instrument_function, constructor));
static void tv_cyg_hex(FILE * f, unsigned long long v) __attribute__((no_instrument_function));
static void tv_cyg_dec(FILE * f, unsigned long long v) __attribute__((no_instrument_function));

void __cyg_profile_func_enter(void * fn, void * site)
{
    size_t h = (size_t) fn;
    size_t i;
    size_t probes = 0U;
    (void) site;
    h ^= h >> 17;
    h *= (size_t) 0x9E3779B97F4A7C15ULL;
    i = (h ^ (h >> 29)) & (TV_CYG_CAP - 1U);
    while (tv_cyg_keys[i] != 0 && tv_cyg_keys[i] != fn) {
        i = (i + 1U) & (TV_CYG_CAP - 1U);
        if (++probes == TV_CYG_CAP) {
            tv_cyg_lost++;
            return;
        }
    }
    tv_cyg_keys[i] = fn;
    tv_cyg_counts[i]++;
}

void __cyg_profile_func_exit(void * fn, void * site)
{
    (void) fn;
    (void) site;
}

static void tv_cyg_hex(FILE * f, unsigned long long v)
{
    char text[17];
    int k;
    for (k = 15; k >= 0; k--) {
        text[k] = "0123456789abcdef"[v & 15U];
        v >>= 4;
    }
    text[16] = '\0';
    fputs(text, f);
}

static void tv_cyg_dec(FILE * f, unsigned long long v)
{
    char text[24];
    int k = 23;
    text[k] = '\0';
    do {
        text[--k] = (char) ('0' + (int) (v % 10U));
        v /= 10U;
    } while (v != 0U && k > 0);
    fputs(text + k, f);
}

static void tv_cyg_dump(void)
{
    const char * path = getenv("LMX_CYG_OUT");
    FILE * f = fopen(path != 0 ? path : "cyg-counts.txt", "w");
    size_t i;
    if (f == 0)
        return;
    fputs("#self ", f);
    tv_cyg_hex(f, (unsigned long long) (size_t) &__cyg_profile_func_enter);
    fputs("\n#lost ", f);
    tv_cyg_dec(f, tv_cyg_lost);
    fputs("\n", f);
    for (i = 0U; i < TV_CYG_CAP; i++)
        if (tv_cyg_keys[i] != 0) {
            tv_cyg_hex(f, (unsigned long long) (size_t) tv_cyg_keys[i]);
            fputs("\t", f);
            tv_cyg_dec(f, tv_cyg_counts[i]);
            fputs("\n", f);
        }
    fclose(f);
}

static void tv_cyg_open(void)
{
    atexit(tv_cyg_dump);
}
