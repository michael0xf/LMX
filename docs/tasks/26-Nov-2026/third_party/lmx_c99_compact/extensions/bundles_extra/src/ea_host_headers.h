#ifndef LMX_EA_HOST_HEADERS_H
#define LMX_EA_HOST_HEADERS_H
#include <stddef.h>
#include <stdint.h>
#include <inttypes.h>
#include <limits.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>
#include <wchar.h>
#include <wctype.h>
#include <math.h>
#include <assert.h>
#include "lmx_ea_libc.h"
#ifndef LONG_BIT
#if ULONG_MAX > 0xffffffffUL
#define LONG_BIT 64
#else
#define LONG_BIT 32
#endif
#endif
#if !defined(__GNUC__) && !defined(__clang__)
#define __attribute__(x)
#endif
#endif
