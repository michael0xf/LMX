/* LMX integration fixture, Apache-2.0. */
#ifndef LMX_NNOM_TEST_SUPPORT_H
#define LMX_NNOM_TEST_SUPPORT_H
#include "nnom.h"
#ifdef NNOM_USING_STATIC_MEMORY
static union {
    double align_double;
    uint64_t align_u64;
    void *align_pointer;
    unsigned char bytes[8192];
} test_arena;
#endif
static inline void prepare_model_memory(void) {
#ifdef NNOM_USING_STATIC_MEMORY
    nnom_set_static_buf(test_arena.bytes, sizeof(test_arena.bytes));
#endif
}
#ifdef LMX_NNOM_TRACK_ALLOCATIONS
int check_allocations(void);
#else
static inline int check_allocations(void) { return 0; }
#endif
#endif
