#include <tlsf.h>
#include <ryu/ryu.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CHECK(expr) do { if(!(expr)) { \
    fprintf(stderr, "check failed at %s:%d: %s\n", __FILE__, __LINE__, #expr); \
    return 1; } } while(0)

typedef union pool_storage {
    long double align_long_double;
    void *align_pointer;
    uint64_t align_integer;
    unsigned char bytes[65536];
} pool_storage;

static pool_storage first_storage, second_storage;

static void count_live(void *ptr, size_t size, int used, void *user)
{
    size_t *live = user;
    (void)ptr;
    (void)size;
    if(used) ++*live;
}

int main(void)
{
    tlsf_t allocator;
    pool_t first, second;
    unsigned char *p, *larger;
    void *slots[160];
    size_t i, j, count, live = 0;
    char *formatted;

    CHECK((uintptr_t)first_storage.bytes % tlsf_align_size() == 0);
    CHECK((uintptr_t)second_storage.bytes % tlsf_align_size() == 0);
    allocator = tlsf_create_with_pool(first_storage.bytes, sizeof first_storage.bytes);
    CHECK(allocator != NULL);
    first = tlsf_get_pool(allocator);
    second = tlsf_add_pool(allocator, second_storage.bytes, sizeof second_storage.bytes);
    CHECK(second != NULL && tlsf_check(allocator) == 0);
    CHECK(tlsf_malloc(allocator, 0) == NULL);
    tlsf_free(allocator, NULL);

    p = tlsf_memalign(allocator, 128, 113);
    CHECK(p != NULL && (uintptr_t)p % 128 == 0);
    memset(p, 0xa7, 113);
    larger = tlsf_realloc(allocator, p, 2048);
    CHECK(larger != NULL && tlsf_block_size(larger) >= 2048);
    for(i = 0; i < 113; ++i) CHECK(larger[i] == 0xa7);
    p = tlsf_realloc(allocator, larger, 17);
    CHECK(p != NULL);
    for(i = 0; i < 17; ++i) CHECK(p[i] == 0xa7);
    tlsf_free(allocator, p);

    formatted = tlsf_malloc(allocator, 64);
    CHECK(formatted != NULL);
    d2s_buffered(123.456, formatted);
    CHECK(strtod(formatted, NULL) == 123.456);
    tlsf_free(allocator, formatted);

    for(count = 0; count < sizeof slots / sizeof slots[0]; ++count) {
        slots[count] = tlsf_malloc(allocator, 1024);
        if(!slots[count]) break;
        memset(slots[count], (int)(count & 255), 1024);
    }
    CHECK(count > 0 && count < sizeof slots / sizeof slots[0]);
    CHECK(tlsf_malloc(allocator, 1024) == NULL);
    CHECK(tlsf_check(allocator) == 0 && tlsf_check_pool(first) == 0 && tlsf_check_pool(second) == 0);
    for(i = 0; i < count; ++i) {
        const unsigned char *bytes = slots[i];
        for(j = 0; j < 1024; ++j) CHECK(bytes[j] == (unsigned char)(i & 255));
    }
    for(i = 0; i < count; i += 2) tlsf_free(allocator, slots[i]);
    for(i = 1; i < count; i += 2) tlsf_free(allocator, slots[i]);
    CHECK(tlsf_check(allocator) == 0);
    p = tlsf_malloc(allocator, 32768); /* Freed neighbours must coalesce. */
    CHECK(p != NULL);
    tlsf_free(allocator, p);
    tlsf_walk_pool(first, count_live, &live);
    tlsf_walk_pool(second, count_live, &live);
    CHECK(live == 0 && tlsf_check_pool(first) == 0 && tlsf_check_pool(second) == 0);
    tlsf_remove_pool(allocator, second);
    CHECK(tlsf_check(allocator) == 0);
    tlsf_destroy(allocator);
    puts("TLSF: aligned pools, realloc preservation, exhaustion, coalescing and Ryu consumer passed");
    return 0;
}
