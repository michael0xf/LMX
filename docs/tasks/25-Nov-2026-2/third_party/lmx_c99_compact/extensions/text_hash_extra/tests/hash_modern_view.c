/* Deliberately separate: this unit sees only the modern namespaced header. */
#include <lmx_xxhash_modern.h>
#include <stddef.h>
#include <stdint.h>
uint64_t lmx_test_hash_modern(const void *bytes, size_t length)
{
    return (uint64_t)XXH64(bytes, length, 123456789);
}
