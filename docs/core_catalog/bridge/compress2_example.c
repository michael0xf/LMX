/* Reviewed example of enabling the generated compress2 C gate.
 *
 * Compile through run_generated_shim_tests.py, which emits the actual shim
 * from the compact LMX catalogue into its build directory. No arena casts:
 * arguments are real C transport slots, and argument 1 borrows a real native
 * uLongf cell, materialised by the caller and copied back after the call.
 * The caller pins all backing storage and generation cells through return.
 * zlib compress2 has no caller callback or retained asynchronous buffer here.
 *
 * Arguments: writable destination bytes; writable native uLongf capacity/result
 * cell; readable source bytes; source length; compression level (-1..9).
 * A bridge success preserves the native Z_* status in frame.result, including
 * Z_BUF_ERROR. It does not turn a codec failure into a successful codec result.
 */
#include "lmx_catalog_bridge.h"
#include "zlib.h"
#include <stddef.h>
#include <stdint.h>

struct ulongf_alignment_probe { char before; uLongf value; };
#define ULONGF_ALIGNMENT offsetof(struct ulongf_alignment_probe, value)

static int example_failure(lmx_catalog_frame *frame, int code)
{
    frame->status = code;
    return code;
}

static int read_destination(lmx_catalog_frame *frame, size_t index, Bytef **out)
{
    void *bytes;
    int rc = lmx_catalog_read_span(frame, index, 0, 1, 1, &bytes);
    if (rc == LMXC_OK) *out = bytes;
    return rc;
}

static int read_length_cell(lmx_catalog_frame *frame, size_t index, uLongf **out)
{
    void *bytes;
    int rc = lmx_catalog_read_span(frame, index, sizeof(uLongf), ULONGF_ALIGNMENT, 1, &bytes);
    if (rc != LMXC_OK) return rc;
    if (frame->arguments[index].span.length_bytes != sizeof(uLongf))
        return example_failure(frame, LMXC_LENGTH);
    *out = bytes;
    return LMXC_OK;
}

static int read_source(lmx_catalog_frame *frame, size_t index, const Bytef **out)
{
    void *bytes;
    int rc = lmx_catalog_read_span(frame, index, 0, 1, 0, &bytes);
    if (rc == LMXC_OK) *out = bytes;
    return rc;
}

/* Native flat-address range validation. Do not compute end pointers beyond
 * actual objects, and reject address-space wrap before testing overlap. */
static int range_end(const void *p, size_t bytes, uintptr_t *end)
{
    uintptr_t start = (uintptr_t)p;
    if ((uintmax_t)bytes > (uintmax_t)UINTPTR_MAX - start) return 0;
    *end = start + (uintptr_t)bytes;
    return 1;
}

static int overlap(const void *a, uintptr_t ae, const void *b, uintptr_t be)
{
    uintptr_t ab = (uintptr_t)a, bb = (uintptr_t)b;
    return ae != ab && be != bb && ab < be && bb < ae;
}

static int check_arguments(lmx_catalog_frame *frame)
{
    Bytef *destination;
    const Bytef *source;
    uLongf *length;
    unsigned long source_length;
    int level, rc;
    uintptr_t destination_end, source_end, cell_end;
    /* CHECK is intentionally usable through its documented frame-only hook.
     * It revalidates borrows, then checks relationships between arguments. */
    if ((rc = read_destination(frame, 0, &destination)) != LMXC_OK) return rc;
    if ((rc = read_length_cell(frame, 1, &length)) != LMXC_OK) return rc;
    if ((rc = read_source(frame, 2, &source)) != LMXC_OK) return rc;
    if ((rc = lmx_catalog_read_ulong(frame, 3, &source_length)) != LMXC_OK) return rc;
    if ((rc = lmx_catalog_read_int(frame, 4, &level)) != LMXC_OK) return rc;
    if (level < Z_DEFAULT_COMPRESSION || level > Z_BEST_COMPRESSION)
        return example_failure(frame, LMXC_RANGE);
    if ((uintmax_t)*length > frame->arguments[0].span.length_bytes ||
        (uintmax_t)source_length > frame->arguments[2].span.length_bytes)
        return example_failure(frame, LMXC_LENGTH);
    if (!range_end(destination, (size_t)*length, &destination_end) ||
        !range_end(source, (size_t)source_length, &source_end) ||
        !range_end(length, sizeof *length, &cell_end))
        return example_failure(frame, LMXC_RANGE);
    /* This adapter requires three nonoverlapping native borrows. In particular,
     * zlib may update the length cell without corrupting either byte buffer. */
    if (overlap(destination, destination_end, source, source_end) ||
        overlap(destination, destination_end, length, cell_end) ||
        overlap(source, source_end, length, cell_end))
        return example_failure(frame, LMXC_RANGE);
    return LMXC_OK;
}

#ifdef LMXC99_COMPRESS2_EXAMPLE_TEST
static unsigned native_calls;
static int counted_compress2(Bytef *destination, uLongf *length,
                             const Bytef *source, uLong source_length, int level)
{
    ++native_calls;
    return compress2(destination, length, source, source_length, level);
}
/* Test instrumentation changes only the callee spelling at this include site.
 * The generated control flow and every validation hook remain unmodified. */
#define compress2 counted_compress2
#endif

#define LMXC99_ENABLE_CAPI_0732EECB50673D02
#define LMXC99_TYPE_CAPI_0732EECB50673D02_A0 Bytef *
#define LMXC99_TYPE_CAPI_0732EECB50673D02_A1 uLongf *
#define LMXC99_TYPE_CAPI_0732EECB50673D02_A2 const Bytef *
#define LMXC99_TYPE_CAPI_0732EECB50673D02_A3 uLong
#define LMXC99_TYPE_CAPI_0732EECB50673D02_A4 int
#define LMXC99_RESULT_CAPI_0732EECB50673D02 int
#define LMXC99_READ_CAPI_0732EECB50673D02_A0 read_destination
#define LMXC99_READ_CAPI_0732EECB50673D02_A1 read_length_cell
#define LMXC99_READ_CAPI_0732EECB50673D02_A2 read_source
#define LMXC99_READ_CAPI_0732EECB50673D02_A3 lmx_catalog_read_ulong
#define LMXC99_READ_CAPI_0732EECB50673D02_A4 lmx_catalog_read_int
#define LMXC99_CHECK_CAPI_0732EECB50673D02 check_arguments
#define LMXC99_SAVE_CAPI_0732EECB50673D02(frame, value) lmx_catalog_write_i64((frame), (int64_t)(value))
/* Created on demand by the unmodified catalogue generator. */
#include "generated_compress2.c"

#ifdef LMXC99_COMPRESS2_EXAMPLE_TEST
#undef compress2
#include <stdio.h>
#include <string.h>

static unsigned assertions, failures;
static const unsigned char owner = 1, other_owner = 2;
static uint64_t live_generation = 9;
#define REQUIRE(test) do { ++assertions; if (!(test)) { ++failures; \
    fprintf(stderr, "line %d: %s\n", __LINE__, #test); } } while (0)

static lmx_catalog_slot byte_slot(void *data, size_t length, size_t alignment, int writable)
{
    lmx_catalog_slot s = {0};
    s.kind = LMXC_SPAN; s.span.bytes = data; s.span.length_bytes = length;
    s.span.alignment = alignment; s.span.writable = writable;
    s.span.owner = &owner; s.span.live_generation = &live_generation;
    s.span.borrowed_generation = live_generation;
    return s;
}

static void reject_without_call(lmx_catalog_frame *frame, int expected, uLongf *length)
{
    unsigned before = native_calls;
    uLongf previous_length = *length;
    REQUIRE(lmx_bridge_compress2_0732eecb50673d02(frame) == expected);
    REQUIRE(native_calls == before && *length == previous_length);
    REQUIRE(frame->result.kind == LMXC_NONE);
}

int main(void)
{
    Bytef input[1024], compressed[2048], restored[1024];
    unsigned char misaligned_cell[sizeof(uLongf) + 1];
    lmx_catalog_slot a[5], original[5];
    lmx_catalog_frame frame = {0};
    uLongf length = sizeof compressed, restored_length;
    unsigned i, before;
    for (i = 0; i < sizeof input; ++i) input[i] = (Bytef)((i * 37U) % 251U);
    a[0] = byte_slot(compressed, sizeof compressed, 1, 1);
    a[1] = byte_slot(&length, sizeof length, ULONGF_ALIGNMENT, 1);
    a[2] = byte_slot(input, sizeof input, 1, 0);
    memset(&a[3], 0, sizeof a[3]); a[3].kind = LMXC_UNSIGNED; a[3].unsigned_value = sizeof input;
    memset(&a[4], 0, sizeof a[4]); a[4].kind = LMXC_SIGNED; a[4].signed_value = 6;
    memcpy(original, a, sizeof a);
    frame.abi_version = 1; frame.owner = &owner; frame.arguments = a; frame.argument_count = 5;

    REQUIRE(lmx_bridge_compress2_0732eecb50673d02(&frame) == LMXC_OK);
    REQUIRE(frame.result.kind == LMXC_SIGNED && frame.result.signed_value == Z_OK);
    REQUIRE(native_calls == 1 && length > 0 && length <= sizeof compressed);
    restored_length = sizeof restored;
    REQUIRE(uncompress(restored, &restored_length, compressed, length) == Z_OK);
    REQUIRE(restored_length == sizeof input && memcmp(input, restored, sizeof input) == 0);

#define RESET() do { memcpy(a, original, sizeof a); length = sizeof compressed; } while (0)
    RESET(); length = sizeof compressed + 1;
    reject_without_call(&frame, LMXC_LENGTH, &length);
    RESET(); a[3].unsigned_value = sizeof input + 1;
    reject_without_call(&frame, LMXC_LENGTH, &length);
    for (i = 0; i < 3; ++i) {
        RESET(); a[i].span.owner = &other_owner;
        reject_without_call(&frame, LMXC_OWNER, &length);
        RESET(); a[i].span.borrowed_generation = live_generation - 1;
        reject_without_call(&frame, LMXC_EXPIRED, &length);
    }
    RESET(); a[0].span.writable = 0;
    reject_without_call(&frame, LMXC_READ_ONLY, &length);
    RESET(); a[1].span.writable = 0;
    reject_without_call(&frame, LMXC_READ_ONLY, &length);
    RESET(); a[0].kind = LMXC_RESOURCE;
    reject_without_call(&frame, LMXC_TYPE, &length);
    RESET(); a[3].kind = LMXC_REAL; a[3].real_value = 12.0;
    reject_without_call(&frame, LMXC_TYPE, &length);
    RESET(); a[3].kind = LMXC_SIGNED; a[3].signed_value = -1;
    reject_without_call(&frame, LMXC_RANGE, &length);
    RESET(); a[1].span.length_bytes = sizeof length - 1;
    reject_without_call(&frame, LMXC_LENGTH, &length);
    if (ULONGF_ALIGNMENT > 1) {
        RESET();
        a[1].span.bytes = (uintptr_t)misaligned_cell % ULONGF_ALIGNMENT ? misaligned_cell : misaligned_cell + 1;
        reject_without_call(&frame, LMXC_ALIGNMENT, &length);
    }
    RESET(); a[4].signed_value = 10;
    reject_without_call(&frame, LMXC_RANGE, &length);
    RESET(); a[0] = byte_slot(input, sizeof input, 1, 1); length = sizeof input;
    reject_without_call(&frame, LMXC_RANGE, &length);
    RESET(); a[0] = byte_slot(&length, sizeof length, 1, 1); length = sizeof length;
    reject_without_call(&frame, LMXC_RANGE, &length);
    RESET(); frame.argument_count = 4;
    reject_without_call(&frame, LMXC_ARITY, &length);
    frame.argument_count = 5;

    /* Valid borrow, insufficient native codec capacity: native Z_BUF_ERROR is
     * preserved as a value, and the in/out length remains within the lease. */
    RESET(); length = 1; before = native_calls;
    REQUIRE(lmx_bridge_compress2_0732eecb50673d02(&frame) == LMXC_OK);
    REQUIRE(native_calls == before + 1 && frame.result.signed_value == Z_BUF_ERROR);
    REQUIRE(length <= 1);

    /* A zero-length readable span is distinct from a truncated nonempty one. */
    RESET(); a[2] = byte_slot(NULL, 0, 1, 0); a[3].unsigned_value = 0;
    REQUIRE(lmx_bridge_compress2_0732eecb50673d02(&frame) == LMXC_OK && frame.result.signed_value == Z_OK);
    restored_length = sizeof restored;
    REQUIRE(uncompress(restored, &restored_length, compressed, length) == Z_OK && restored_length == 0);

    printf("{\"assertions\":%u,\"failures\":%u,\"native_compress2_calls\":%u,\"zlib\":\"%s\"}\n",
           assertions, failures, native_calls, ZLIB_VERSION);
    return failures ? 1 : 0;
}
#endif
