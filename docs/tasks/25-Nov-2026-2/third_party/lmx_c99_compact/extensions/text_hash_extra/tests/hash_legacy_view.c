/* Deliberately separate: this unit sees only the LZ4 legacy xxHash header. */
#include <xxhash.h>
#include <stddef.h>
#include <stdint.h>
uint64_t lmx_test_hash_legacy(const void *bytes, size_t length)
{
    return (uint64_t)XXH64(bytes, length, 123456789);
}
