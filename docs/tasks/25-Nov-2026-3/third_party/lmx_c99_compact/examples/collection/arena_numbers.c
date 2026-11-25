#include <tlsf.h>
#include <ryu/ryu.h>
#include <stdint.h>
#include <stdio.h>

static union {
    long double alignment;
    void *pointer_alignment;
    unsigned char bytes[32768];
} storage;

int main(void)
{
    tlsf_t allocator;
    char *text;
    if((uintptr_t)storage.bytes % tlsf_align_size() != 0) return 1;
    allocator = tlsf_create_with_pool(storage.bytes, sizeof storage.bytes);
    if(!allocator) return 1;
    text = tlsf_malloc(allocator, 64);
    if(!text) return 1;
    d2s_buffered(0.1, text);
    printf("double shortest: %s\n", text);
    f2s_buffered(0.125f, text);
    printf("float shortest:  %s\n", text);
    d2fixed_buffered(0.125, 6, text);
    printf("fixed:           %s\n", text);
    d2exp_buffered(123.456, 3, text);
    printf("scientific:      %s\n", text);
    tlsf_free(allocator, text);
    tlsf_destroy(allocator);
    return 0;
}
