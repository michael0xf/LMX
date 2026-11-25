/* LMX adapter, MIT; upstream kexpr.c remains unmodified. */
#include "c99_strdup.h"
#define strdup lmx_klib_strdup
#include "../kexpr.c"
