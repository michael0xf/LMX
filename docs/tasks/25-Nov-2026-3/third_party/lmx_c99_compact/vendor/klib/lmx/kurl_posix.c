/* LMX adapter, MIT. Declare nanosleep before upstream first uses it. */
#ifndef _POSIX_C_SOURCE
#define _POSIX_C_SOURCE 200809L
#endif
#include <time.h>
#include "../kurl.c"
