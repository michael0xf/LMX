/* LMX integration fixture, Apache-2.0. */
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

void *__real_malloc(size_t);
void *__real_calloc(size_t, size_t);
void __real_free(void *);
static struct { void *pointer; size_t size; } live[256];

static void *remember(void *p, size_t size) {
    if (p != NULL) {
        for (unsigned i = 0; i < sizeof(live)/sizeof(live[0]); ++i) {
            if (live[i].pointer == NULL) {
                live[i].pointer = p;
                live[i].size = size;
                return p;
            }
        }
        fputs("allocation tracker exhausted\n", stderr);
        abort();
    }
    return p;
}

void *__wrap_malloc(size_t size) { return remember(__real_malloc(size), size); }
void *__wrap_calloc(size_t count, size_t size) {
    return remember(__real_calloc(count, size), count * size);
}

void __wrap_free(void *p) {
    if (p != NULL) {
        for (unsigned i = 0; i < sizeof(live)/sizeof(live[0]); ++i) {
            if (live[i].pointer == p) { live[i].pointer = NULL; break; }
        }
    }
    __real_free(p);
}

int check_allocations(void) {
    unsigned count = 0;
    size_t bytes = 0;
    for (unsigned i = 0; i < sizeof(live)/sizeof(live[0]); ++i) {
        if (live[i].pointer != NULL) { ++count; bytes += live[i].size; }
    }
    printf("outstanding library allocations: %u (%zu bytes)\n", count, bytes);
    return count != 0;
}
