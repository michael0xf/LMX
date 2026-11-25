/* LMX adapter, MIT. Preserve upstream implementation and explicitly provide
 * its missing integer types and compiler stack-allocation spelling.
 * CMake probes these intrinsics and POSIX threads before enabling the target. */
#include <stdint.h>
#include <stdlib.h>
#if !defined(__GNUC__) && !defined(__clang__)
#error "This kthread adapter requires verified GNU-compatible compiler intrinsics"
#endif
#ifndef alloca
#define alloca __builtin_alloca
#endif
#include "../kthread.c"
