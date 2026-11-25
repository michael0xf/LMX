/* Behavioral tests of the explicit C99 reference frame contract.
 * These tests never cast an LMX arena node to a C frame or a native buffer.
 * Run with run_tests.py; zlib is built from the supplied collection source.
 */
#include "lmx_catalog_bridge.h"
#include "zlib.h"
#include <stdio.h>
#include <string.h>

static unsigned checks, failures;
static const unsigned char owner_a = 1, owner_b = 2;
static uint64_t generation = 7;

#define CHECK(c) do { ++checks; if (!(c)) { ++failures; \
    fprintf(stderr, "%s:%d: failed: %s\n", __FILE__, __LINE__, #c); } } while (0)

static lmx_catalog_frame frame(lmx_catalog_slot *args, size_t count)
{
    lmx_catalog_frame f;
    memset(&f, 0, sizeof f);
    f.abi_version = 1;
    f.owner = &owner_a;
    f.arguments = args;
    f.argument_count = count;
    return f;
}

static lmx_catalog_slot span(void *data, size_t length, int writable)
{
    lmx_catalog_slot s;
    memset(&s, 0, sizeof s);
    s.kind = LMXC_SPAN;
    s.span.bytes = data;
    s.span.length_bytes = length;
    s.span.alignment = 1;
    s.span.owner = &owner_a;
    s.span.live_generation = &generation;
    s.span.borrowed_generation = generation;
    s.span.writable = writable;
    return s;
}

static void test_frames(void)
{
    lmx_catalog_slot a = {0};
    lmx_catalog_frame f = frame(&a, 1);
    int out = 123;
    CHECK(lmx_catalog_check(NULL, 0) == LMXC_BAD_FRAME);
    CHECK(lmx_catalog_check(&f, 1) == LMXC_OK);
    CHECK(lmx_catalog_check(&f, 2) == LMXC_ARITY);
    CHECK(f.status == LMXC_ARITY);
    CHECK(lmx_catalog_read_int(&f, 1, &out) == LMXC_ARITY);
    CHECK(out == 123);
    f.abi_version = 2;
    CHECK(lmx_catalog_check(&f, 1) == LMXC_BAD_FRAME);
    f.abi_version = 1; f.owner = NULL;
    CHECK(lmx_catalog_check(&f, 1) == LMXC_BAD_FRAME);
    f.owner = &owner_a; f.arguments = NULL;
    CHECK(lmx_catalog_check(&f, 1) == LMXC_BAD_FRAME);
    f.argument_count = 0;
    CHECK(lmx_catalog_check(&f, 0) == LMXC_OK);
    f.result.kind = LMXC_UNSIGNED; f.result.unsigned_value = 42;
    f.status = LMXC_RANGE; f.diagnostic_symbol = "old";
    CHECK(lmx_catalog_check(&f, 0) == LMXC_OK);
    CHECK(f.result.kind == LMXC_NONE && f.result.unsigned_value == 0);
    CHECK(f.status == LMXC_OK && f.diagnostic_symbol == NULL);
    CHECK(lmx_catalog_review_required(&f, "unreviewed_api") == LMXC_REVIEW_REQUIRED);
    CHECK(f.status != LMXC_OK && f.result.kind == LMXC_NONE);
    CHECK(strcmp(f.diagnostic_symbol, "unreviewed_api") == 0);
}

static void test_integers(void)
{
    lmx_catalog_slot a = {0};
    lmx_catalog_frame f = frame(&a, 1);
    int i = 123;
    unsigned int u = 123;
    unsigned long ul = 123;
    size_t sz = 123;
    int64_t i64 = 123;
    uint64_t u64 = 123;
    a.kind = LMXC_SIGNED; a.signed_value = INT_MIN;
    CHECK(lmx_catalog_read_int(&f, 0, &i) == LMXC_OK && i == INT_MIN);
    a.signed_value = INT_MAX;
    CHECK(lmx_catalog_read_int(&f, 0, &i) == LMXC_OK && i == INT_MAX);
    a.kind = LMXC_UNSIGNED; a.unsigned_value = (uint64_t)INT_MAX + UINT64_C(1);
    CHECK(lmx_catalog_read_int(&f, 0, &i) == LMXC_RANGE && i == INT_MAX);
    a.kind = LMXC_SIGNED; a.signed_value = -1;
    CHECK(lmx_catalog_read_uint(&f, 0, &u) == LMXC_RANGE && u == 123);
    CHECK(lmx_catalog_read_ulong(&f, 0, &ul) == LMXC_RANGE && ul == 123);
    CHECK(lmx_catalog_read_size(&f, 0, &sz) == LMXC_RANGE && sz == 123);
    a.kind = LMXC_UNSIGNED; a.unsigned_value = UINT_MAX;
    CHECK(lmx_catalog_read_uint(&f, 0, &u) == LMXC_OK && u == UINT_MAX);
#if UINT_MAX < UINT64_MAX
    a.unsigned_value = (uint64_t)UINT_MAX + UINT64_C(1);
    CHECK(lmx_catalog_read_uint(&f, 0, &u) == LMXC_RANGE && u == UINT_MAX);
#endif
    a.unsigned_value = ULONG_MAX;
    CHECK(lmx_catalog_read_ulong(&f, 0, &ul) == LMXC_OK && ul == ULONG_MAX);
    a.unsigned_value = SIZE_MAX;
    CHECK(lmx_catalog_read_size(&f, 0, &sz) == LMXC_OK && sz == SIZE_MAX);
    a.unsigned_value = UINT64_MAX;
    CHECK(lmx_catalog_read_u64(&f, 0, UINT64_MAX, &u64) == LMXC_OK && u64 == UINT64_MAX);
    CHECK(lmx_catalog_read_i64(&f, 0, INT64_MIN, INT64_MAX, &i64) == LMXC_RANGE && i64 == 123);
    a.kind = LMXC_SIGNED; a.signed_value = INT64_MIN;
    CHECK(lmx_catalog_read_i64(&f, 0, INT64_MIN, INT64_MAX, &i64) == LMXC_OK && i64 == INT64_MIN);
    a.signed_value = INT64_MAX;
    CHECK(lmx_catalog_read_i64(&f, 0, INT64_MIN, INT64_MAX, &i64) == LMXC_OK && i64 == INT64_MAX);
    a.signed_value = -129;
    CHECK(lmx_catalog_read_i64(&f, 0, -128, 127, &i64) == LMXC_RANGE && i64 == INT64_MAX);
    a.signed_value = 128;
    CHECK(lmx_catalog_read_i64(&f, 0, -128, 127, &i64) == LMXC_RANGE);
    a.signed_value = 127;
    CHECK(lmx_catalog_read_i64(&f, 0, -128, 127, &i64) == LMXC_OK && i64 == 127);
    a.signed_value = 256;
    CHECK(lmx_catalog_read_u64(&f, 0, 255, &u64) == LMXC_RANGE && u64 == UINT64_MAX);
    a.signed_value = 255;
    CHECK(lmx_catalog_read_u64(&f, 0, 255, &u64) == LMXC_OK && u64 == 255);
    CHECK(lmx_catalog_read_i64(&f, 0, 10, 9, &i64) == LMXC_BAD_FRAME);
    CHECK(lmx_catalog_read_int(&f, 0, NULL) == LMXC_BAD_FRAME);
    CHECK(lmx_catalog_read_u64(&f, 0, UINT64_MAX, NULL) == LMXC_BAD_FRAME);
    a.kind = LMXC_REAL; a.real_value = 1.0;
    CHECK(lmx_catalog_read_int(&f, 0, &i) == LMXC_TYPE);
    CHECK(lmx_catalog_read_u64(&f, 0, UINT64_MAX, &u64) == LMXC_TYPE);
}

static void test_spans(void)
{
    unsigned char data[8] = {0};
    lmx_catalog_slot a = span(data, sizeof data, 1);
    lmx_catalog_frame f = frame(&a, 1);
    void *p = data;
    CHECK(lmx_catalog_read_span(&f, 0, sizeof data, 1, 1, &p) == LMXC_OK && p == data);
    CHECK(lmx_catalog_read_span(&f, 0, sizeof data + 1, 1, 0, &p) == LMXC_LENGTH);
    CHECK(lmx_catalog_read_span(&f, 0, SIZE_MAX, 1, 0, &p) == LMXC_LENGTH);
    a.span.bytes = NULL;
    CHECK(lmx_catalog_read_span(&f, 0, 0, 1, 0, &p) == LMXC_LENGTH);
    a.span.length_bytes = 0;
    CHECK(lmx_catalog_read_span(&f, 0, 0, 1, 0, &p) == LMXC_OK && p == NULL);
    CHECK(lmx_catalog_read_span(&f, 0, 1, 1, 0, &p) == LMXC_LENGTH);
    a = span(data, sizeof data, 0);
    CHECK(lmx_catalog_read_span(&f, 0, sizeof data, 1, 0, &p) == LMXC_OK);
    CHECK(lmx_catalog_read_span(&f, 0, 1, 1, 1, &p) == LMXC_READ_ONLY);
    a.span.owner = &owner_b;
    CHECK(lmx_catalog_read_span(&f, 0, 1, 1, 0, &p) == LMXC_OWNER);
    a.span.owner = &owner_a; ++generation;
    CHECK(lmx_catalog_read_span(&f, 0, 1, 1, 0, &p) == LMXC_EXPIRED);
    a.span.borrowed_generation = generation; a.span.live_generation = NULL;
    CHECK(lmx_catalog_read_span(&f, 0, 1, 1, 0, &p) == LMXC_EXPIRED);
    a = span(data, sizeof data, 1);
    CHECK(lmx_catalog_read_span(&f, 0, 1, 0, 0, &p) == LMXC_BAD_FRAME);
    CHECK(lmx_catalog_read_span(&f, 0, 1, 1, 0, NULL) == LMXC_BAD_FRAME);
    CHECK(lmx_catalog_read_span(&f, 0, 1, 2, 0, &p) == LMXC_ALIGNMENT);
    /* Choose a byte that is demonstrably odd without dereferencing as a wider type. */
    a.span.bytes = ((uintptr_t)data % 2) ? data : data + 1;
    a.span.length_bytes = 1; a.span.alignment = 2;
    CHECK(lmx_catalog_read_span(&f, 0, 1, 2, 0, &p) == LMXC_ALIGNMENT);
    a.kind = LMXC_UNSIGNED;
    CHECK(lmx_catalog_read_span(&f, 0, 0, 1, 0, &p) == LMXC_TYPE);
}

static void test_cstrings(void)
{
    char good[] = "hello", empty[] = "", embedded[] = {'a', '\0', 'b', '\0'};
    char unterminated[] = {'a', 'b'};
    lmx_catalog_slot a = span(good, sizeof good, 0);
    lmx_catalog_frame f = frame(&a, 1);
    const char *s = NULL;
    CHECK(lmx_catalog_read_cstring(&f, 0, &s) == LMXC_OK && s == good);
    a = span(empty, sizeof empty, 0);
    CHECK(lmx_catalog_read_cstring(&f, 0, &s) == LMXC_OK && s[0] == '\0');
    a = span(embedded, sizeof embedded, 0);
    CHECK(lmx_catalog_read_cstring(&f, 0, &s) == LMXC_EMBEDDED_NUL);
    a = span(unterminated, sizeof unterminated, 0);
    CHECK(lmx_catalog_read_cstring(&f, 0, &s) == LMXC_LENGTH);
    a = span(NULL, 0, 0);
    CHECK(lmx_catalog_read_cstring(&f, 0, &s) == LMXC_LENGTH);
    a = span(good, sizeof good, 0); a.span.owner = &owner_b;
    CHECK(lmx_catalog_read_cstring(&f, 0, &s) == LMXC_OWNER);
    CHECK(lmx_catalog_read_cstring(&f, 0, NULL) == LMXC_BAD_FRAME);
}

static void test_resources(void)
{
    unsigned char native = 0;
    lmx_catalog_slot a = {0};
    lmx_catalog_frame f = frame(&a, 1);
    void *p = NULL;
    a.kind = LMXC_RESOURCE; a.resource.native = &native;
    a.resource.owner = &owner_a; a.resource.live_generation = &generation;
    a.resource.borrowed_generation = generation; a.resource.native_type = "sqlite3 *";
    CHECK(lmx_catalog_read_resource(&f, 0, "sqlite3 *", &p) == LMXC_OK && p == &native);
    CHECK(lmx_catalog_read_resource(&f, 0, "sqlite3_stmt *", &p) == LMXC_TYPE);
    CHECK(lmx_catalog_read_resource(&f, 0, "void *", &p) == LMXC_TYPE);
    a.resource.native_type = "unknown_backend_object";
    CHECK(lmx_catalog_read_resource(&f, 0, "sqlite3 *", &p) == LMXC_TYPE);
    a.resource.native_type = NULL;
    CHECK(lmx_catalog_read_resource(&f, 0, "sqlite3 *", &p) == LMXC_TYPE);
    a.resource.native_type = "sqlite3 *"; a.resource.owner = &owner_b;
    CHECK(lmx_catalog_read_resource(&f, 0, "sqlite3 *", &p) == LMXC_OWNER);
    a.resource.owner = &owner_a; ++generation;
    CHECK(lmx_catalog_read_resource(&f, 0, "sqlite3 *", &p) == LMXC_EXPIRED);
    a.resource.borrowed_generation = generation; a.resource.native = NULL;
    CHECK(lmx_catalog_read_resource(&f, 0, "sqlite3 *", &p) == LMXC_EXPIRED);
    CHECK(lmx_catalog_read_resource(&f, 0, NULL, &p) == LMXC_BAD_FRAME);
    CHECK(lmx_catalog_read_resource(&f, 0, "sqlite3 *", NULL) == LMXC_BAD_FRAME);
    a.kind = LMXC_SPAN;
    CHECK(lmx_catalog_read_resource(&f, 0, "sqlite3 *", &p) == LMXC_TYPE);
}

static void test_result_values(void)
{
    lmx_catalog_slot a = {0};
    lmx_catalog_frame f = frame(&a, 1);
    int64_t signed_source = -42;
    uint64_t unsigned_source = UINT64_MAX;
    double real_source = 1.25, out = 123.0;
    a.kind = LMXC_REAL; a.real_value = real_source;
    CHECK(lmx_catalog_read_double(&f, 0, &out) == LMXC_OK && out == 1.25);
    a.real_value = 99.0;
    CHECK(out == 1.25);
    a.kind = LMXC_SIGNED; a.signed_value = 1;
    CHECK(lmx_catalog_read_double(&f, 0, &out) == LMXC_TYPE && out == 1.25);
    CHECK(lmx_catalog_read_double(&f, 0, NULL) == LMXC_BAD_FRAME);
    CHECK(lmx_catalog_write_i64(&f, signed_source) == LMXC_OK);
    signed_source = 7;
    CHECK(f.result.kind == LMXC_SIGNED && f.result.signed_value == -42);
    CHECK(lmx_catalog_write_u64(&f, unsigned_source) == LMXC_OK);
    unsigned_source = 0;
    CHECK(f.result.kind == LMXC_UNSIGNED && f.result.unsigned_value == UINT64_MAX);
    CHECK(f.result.signed_value == 0 && f.result.span.bytes == NULL);
    CHECK(lmx_catalog_write_real(&f, real_source) == LMXC_OK);
    real_source = 9.0;
    CHECK(f.result.kind == LMXC_REAL && f.result.real_value == 1.25);
    CHECK(f.result.unsigned_value == 0);
    CHECK(lmx_catalog_write_none(&f) == LMXC_OK && f.result.kind == LMXC_NONE);
    CHECK(f.result.real_value == 0.0 && f.status == LMXC_OK);
    CHECK(lmx_catalog_write_i64(NULL, signed_source) == LMXC_BAD_FRAME);
    CHECK(lmx_catalog_write_u64(NULL, unsigned_source) == LMXC_BAD_FRAME);
    CHECK(lmx_catalog_write_real(NULL, real_source) == LMXC_BAD_FRAME);
    CHECK(lmx_catalog_write_none(NULL) == LMXC_BAD_FRAME);
}

/* A separately authored example gate validates the *paired* buffer/count.
 * Merely checking a span with needed=0 would miss the truncated-span failure. */
static int checked_checksum(lmx_catalog_frame *f, int adler)
{
    unsigned long initial;
    unsigned int count;
    void *data;
    int rc;
    if ((rc = lmx_catalog_check(f, 3)) != LMXC_OK) return rc;
    if ((rc = lmx_catalog_read_ulong(f, 0, &initial)) != LMXC_OK) return rc;
    if ((rc = lmx_catalog_read_uint(f, 2, &count)) != LMXC_OK) return rc;
    if ((rc = lmx_catalog_read_span(f, 1, count, 1, 0, &data)) != LMXC_OK) return rc;
    return lmx_catalog_write_u64(f, adler
        ? adler32(initial, (const Bytef *)data, count)
        : crc32(initial, (const Bytef *)data, count));
}

static void test_real_zlib_calls(void)
{
    char digits[] = "123456789", wikipedia[] = "Wikipedia";
    lmx_catalog_slot a[3] = {{0}};
    lmx_catalog_frame f = frame(a, 3);
    a[0].kind = LMXC_UNSIGNED; a[0].unsigned_value = 0;
    a[1] = span(digits, sizeof digits - 1, 0);
    a[2].kind = LMXC_UNSIGNED; a[2].unsigned_value = sizeof digits - 1;
    CHECK(checked_checksum(&f, 0) == LMXC_OK);
    CHECK(f.result.kind == LMXC_UNSIGNED && f.result.unsigned_value == UINT64_C(0xcbf43926));
    a[0].unsigned_value = 1;
    CHECK(checked_checksum(&f, 1) == LMXC_OK && f.result.unsigned_value == UINT64_C(0x091e01de));
    a[1] = span(wikipedia, sizeof wikipedia - 1, 0);
    CHECK(checked_checksum(&f, 1) == LMXC_OK && f.result.unsigned_value == UINT64_C(0x11e60398));
    a[1].span.length_bytes = 8;
    CHECK(checked_checksum(&f, 1) == LMXC_LENGTH && f.result.kind == LMXC_NONE);
    a[1] = span(NULL, 0, 0); a[2].unsigned_value = 0; a[0].unsigned_value = 0;
    CHECK(checked_checksum(&f, 1) == LMXC_OK && f.result.unsigned_value == 1);
    CHECK(checked_checksum(&f, 0) == LMXC_OK && f.result.unsigned_value == 0);
    a[2].unsigned_value = 1;
    CHECK(checked_checksum(&f, 0) == LMXC_LENGTH);
    a[2].kind = LMXC_SIGNED; a[2].signed_value = -1;
    CHECK(checked_checksum(&f, 0) == LMXC_RANGE);
}

int main(void)
{
    test_frames(); test_integers(); test_spans(); test_cstrings();
    test_resources(); test_result_values(); test_real_zlib_calls();
    printf("{\"checks\":%u,\"failures\":%u,\"char_bits\":%u,"
           "\"int_bits\":%u,\"long_bits\":%u,\"size_bits\":%u,\"zlib\":\"%s\"}\n",
           checks, failures, (unsigned)CHAR_BIT, (unsigned)(sizeof(int) * CHAR_BIT),
           (unsigned)(sizeof(long) * CHAR_BIT), (unsigned)(sizeof(size_t) * CHAR_BIT), ZLIB_VERSION);
    return failures ? 1 : 0;
}
