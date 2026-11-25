#include "numeric_provider.h"
#include "conversion_bridge.h"
#include "real_provider.h"
#include <float.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CHECK(condition) do { if (!(condition)) { \
    fprintf(stderr, "check failed at %s:%d: %s\n", __FILE__, __LINE__, #condition); \
    exit(1); } } while (0)

static LmxRefStatus double_clone(void *destination, const void *source, void *context)
{
    (void)context;
    *(double *)destination = *(const double *)source;
    return LMX_REF_OK;
}

static void check_runtime(LmxRefType rows[3], LmxRefRegistry *registry)
{
    LmxRefArena first, second;
    LmxRefMark mark;
    LmxRefRecord absent, copied_absent, scalar, copied_scalar, extra;
    size_t i;
    lmx_ref_arena_init(&first, 32);
    lmx_ref_arena_init(&second, 32);
    CHECK(lmx_ref_record_new(&first, &rows[2], 0, &absent) == LMX_REF_OK);
    CHECK(absent.value == NULL && *absent.code == rows[2].uninit_code);
    CHECK(lmx_ref_mark(&first).used == 4);
    CHECK(lmx_ref_record_copy(&second, registry, absent, &copied_absent) == LMX_REF_OK);
    CHECK(copied_absent.value == NULL && *copied_absent.code == rows[2].uninit_code);
    CHECK(lmx_ref_record_new(&first, &rows[2], 1, &scalar) == LMX_REF_OK);
    CHECK((uintptr_t)scalar.value % LMX_REF_ALIGNOF(double) == 0);
    CHECK((unsigned char *)scalar.value - (unsigned char *)scalar.code == 4);
    *(double *)scalar.value = 3.25;
    mark = lmx_ref_mark(&first);
    for (i = 0; i < 50; ++i) {
        CHECK(lmx_ref_record_new(&first, &rows[2], 1, &extra) == LMX_REF_OK);
        *(double *)extra.value = (double)i;
    }
    CHECK(*(double *)scalar.value == 3.25); /* Chunks never realloc existing values. */
    lmx_ref_revert(&first, mark);
    CHECK(*(double *)scalar.value == 3.25);
    CHECK(lmx_ref_record_copy(&second, registry, scalar, &copied_scalar) == LMX_REF_OK);
    *(double *)scalar.value = 8.5;
    CHECK(*(double *)copied_scalar.value == 3.25);
    lmx_ref_arena_destroy(&first);
    CHECK(*(double *)copied_scalar.value == 3.25);
    lmx_ref_arena_destroy(&second);
}

static void check_bigint(LmxRefType rows[3], LmxRefRegistry *registry)
{
    LmxRefArena first, second;
    LmxRefRecord a, b, sum, copied;
    LmxRefMark mark;
    size_t before;
    char *text;
    lmx_ref_arena_init(&first, 64);
    lmx_ref_arena_init(&second, 64);
    CHECK(lmx_ref_bigint_parse(&first, &rows[0], "123456789012345678901234567890", &a) == LMX_REF_OK);
    CHECK(lmx_ref_bigint_parse(&first, &rows[0], "1", &b) == LMX_REF_OK);
    CHECK(lmx_ref_bigint_add(&first, &rows[0], a.value, b.value, &sum) == LMX_REF_OK);
    CHECK(lmx_ref_bigint_text(sum.value, &text) == LMX_REF_OK);
    CHECK(!strcmp(text, "123456789012345678901234567891")); free(text);
    CHECK(lmx_ref_record_copy(&second, registry, sum, &copied) == LMX_REF_OK);
    CHECK(((LmxRefBigint *)sum.value)->number != ((LmxRefBigint *)copied.value)->number);
    CHECK(lmx_ref_bigint_parse(&first, &rows[0], "12x", &b) == LMX_REF_ENCODING);
    before = first.live_finalizers;
    mark = lmx_ref_mark(&first);
    CHECK(lmx_ref_bigint_parse(&first, &rows[0], "999", &b) == LMX_REF_OK);
    CHECK(first.live_finalizers == before + 1);
    lmx_ref_revert(&first, mark);
    CHECK(first.live_finalizers == before);
    lmx_ref_arena_destroy(&first);
    CHECK(lmx_ref_bigint_text(copied.value, &text) == LMX_REF_OK);
    CHECK(!strcmp(text, "123456789012345678901234567891")); free(text);
    lmx_ref_arena_destroy(&second);
}

static void check_decimal(LmxRefType rows[3], LmxRefRegistry *registry)
{
    LmxRefArena first, second;
    LmxRefRecord a, b, sum, rounded, copy, roundtrip;
    LmxRefDecimalContext ctx = { 28, 1000, -1000, LMX_ROUND_HALF_EVEN,
        LMX_NUM_INVALID | LMX_NUM_OVERFLOW | LMX_NUM_DIVISION_ZERO, 0, 0 };
    LmxRefNumericStatus status;
    decNumber *dec;
    size_t before;
    char *text;
    lmx_ref_arena_init(&first, 64);
    lmx_ref_arena_init(&second, 64);
    CHECK(lmx_ref_decimal_parse(&first, &rows[1], "0.1", &ctx, &status, &a) == LMX_REF_OK);
    CHECK(lmx_ref_decimal_parse(&first, &rows[1], "0.2", &ctx, &status, &b) == LMX_REF_OK);
    CHECK(lmx_ref_decimal_add(&first, &rows[1], a.value, b.value, &ctx, &status, &sum) == LMX_REF_OK);
    CHECK(status.conditions == 0);
    CHECK(lmx_ref_decimal_text(sum.value, &text) == LMX_REF_OK);
    CHECK(!strcmp(text, "0.3")); free(text);
    CHECK(lmx_ref_record_copy(&second, registry, sum, &copy) == LMX_REF_OK);
    CHECK(((LmxRefDecimal *)copy.value)->number != ((LmxRefDecimal *)sum.value)->number);
    ctx.precision = 3;
    CHECK(lmx_ref_decimal_parse(&first, &rows[1], "1.245", &ctx, &status, &rounded) == LMX_REF_OK);
    CHECK(status.conditions & LMX_NUM_INEXACT);
    CHECK(lmx_ref_decimal_text(rounded.value, &text) == LMX_REF_OK);
    CHECK(!strcmp(text, "1.24")); free(text);
    ctx.rounding = LMX_ROUND_HALF_UP;
    CHECK(lmx_ref_decimal_parse(&first, &rows[1], "1.245", &ctx, &status, &rounded) == LMX_REF_OK);
    CHECK(lmx_ref_decimal_text(rounded.value, &text) == LMX_REF_OK);
    CHECK(!strcmp(text, "1.25")); free(text);
    ctx.exact_required = 1;
    before = first.live_finalizers;
    CHECK(lmx_ref_decimal_parse(&first, &rows[1], "1.245", &ctx, &status, &rounded) == LMX_REF_NUMERIC);
    CHECK(first.live_finalizers == before);
    CHECK(lmx_ref_decimal_parse(&first, &rows[1], "junk", &ctx, &status, &rounded) == LMX_REF_ENCODING);
    CHECK(first.live_finalizers == before);
    ctx.precision = 28; ctx.rounding = LMX_ROUND_HALF_EVEN;
    CHECK(lmx_ref_decimal_parse(&first, &rows[1], "123.4500", &ctx, &status, &a) == LMX_REF_OK);
    CHECK(lmx_ref_decimal_to_decnumber(a.value, &ctx, &status, &dec) == LMX_REF_OK);
    CHECK(lmx_ref_decimal_from_decnumber(&second, &rows[1], dec, &ctx, &status, &roundtrip) == LMX_REF_OK);
    free(dec);
    CHECK(lmx_ref_decimal_text(roundtrip.value, &text) == LMX_REF_OK);
    CHECK(!strcmp(text, "123.4500")); free(text);
    CHECK(lmx_ref_decimal_parse(&first, &rows[1], "-0.00", &ctx, &status, &a) == LMX_REF_OK);
    CHECK(lmx_ref_decimal_to_decnumber(a.value, &ctx, &status, &dec) == LMX_REF_OK);
    CHECK(lmx_ref_decimal_from_decnumber(&second, &rows[1], dec, &ctx, &status, &roundtrip) == LMX_REF_OK);
    free(dec);
    CHECK(lmx_ref_decimal_text(roundtrip.value, &text) == LMX_REF_OK);
    CHECK(!strcmp(text, "-0.00")); free(text);
    /* A context mismatch must report failure, not reinterpret flags or round. */
    ctx.precision = 0;
    CHECK(lmx_ref_decimal_parse(&first, &rows[1], "1", &ctx, &status, &a) == LMX_REF_RANGE);
    lmx_ref_arena_destroy(&first);
    CHECK(lmx_ref_decimal_text(copy.value, &text) == LMX_REF_OK);
    CHECK(!strcmp(text, "0.3")); free(text);
    lmx_ref_arena_destroy(&second);
}

static void check_converters(void)
{
    float samples[] = { -1.0f, 0.0f, 0.5f, 1.0f };
    float restored[4];
    float bad[] = { 0.0f, NAN };
    int16_t pcm[4];
    int16_t unchanged[] = { 7, 9 };
    size_t shape[] = { 2, 3 }, strides[] = { 3, 1 };
    size_t empty[] = { 0, SIZE_MAX }, huge[] = { SIZE_MAX, 2 };
    size_t logical, extent;
    char text[] = { 'a', 'b', 'c' }, badtext[] = { 'a', '\0', 'b' };
    char *cstring;
    void *span;
    CHECK(lmx_ref_span(samples, 4, sizeof(float), 1, 2, &span) == LMX_REF_OK);
    CHECK(span == &samples[1]);
    CHECK(lmx_ref_span(samples, 4, sizeof(float), 3, 2, &span) == LMX_REF_RANGE);
    CHECK(lmx_ref_span(NULL, 0, sizeof(float), 0, 0, &span) == LMX_REF_OK && span == NULL);
    CHECK(lmx_ref_span(samples, SIZE_MAX, 2, 0, 1, &span) == LMX_REF_RANGE);
    CHECK(lmx_ref_cstring(text, sizeof text, &cstring) == LMX_REF_OK);
    CHECK(!strcmp(cstring, "abc")); free(cstring);
    CHECK(lmx_ref_cstring(badtext, sizeof badtext, &cstring) == LMX_REF_ENCODING);
    CHECK(lmx_ref_tensor_extent(shape, strides, 2, 0, 6, sizeof(float), &logical, &extent) == LMX_REF_OK);
    CHECK(logical == 6 && extent == 6);
    CHECK(lmx_ref_tensor_extent(shape, strides, 2, 1, 6, sizeof(float), &logical, &extent) == LMX_REF_RANGE);
    CHECK(lmx_ref_tensor_extent(empty, strides, 2, 0, 0, sizeof(float), &logical, &extent) == LMX_REF_OK && logical == 0);
    CHECK(lmx_ref_tensor_extent(huge, strides, 2, 0, 6, sizeof(float), &logical, &extent) == LMX_REF_RANGE);
    CHECK(lmx_ref_float_to_pcm16(samples, 4, pcm, 4) == LMX_REF_OK);
    CHECK(pcm[0] == INT16_MIN && pcm[1] == 0 && pcm[2] == 16384 && pcm[3] == INT16_MAX);
    CHECK(lmx_ref_pcm16_to_float(pcm, 4, restored, 4) == LMX_REF_OK);
    CHECK(restored[0] == -1.0f && restored[2] == 0.5f);
    CHECK(lmx_ref_float_to_pcm16(bad, 2, unchanged, 2) == LMX_REF_NUMERIC);
    CHECK(unchanged[0] == 7 && unchanged[1] == 9);
}

static void check_real(void)
{
    LmxRefRealOwner owner_a, owner_b;
    LmxRefArena arena_a, arena_b;
    LmxRefType type_a, type_b;
    LmxRefRegistry registry_b = { &type_b, 1 };
    LmxRefRealContext context = { 256, 20, LMX_ROUND_HALF_EVEN,
        LMX_NUM_INVALID | LMX_NUM_DIVISION_ZERO | LMX_NUM_OVERFLOW, 0, 1 };
    LmxRefNumericStatus status;
    LmxRefRecord one, epsilon, extended, two, root, copy, restored, rejected;
    size_t before;
    double narrowed = 99.0;
    char *text;
    lmx_ref_real_owner_init(&owner_a);
    lmx_ref_real_owner_init(&owner_b);
    lmx_ref_arena_init(&arena_a, 32);
    lmx_ref_arena_init(&arena_b, 32);
    lmx_ref_real_row(&type_a, &owner_a, 704, 1704);
    lmx_ref_real_row(&type_b, &owner_b, 704, 1704);
    CHECK(lmx_ref_registry_validate(&registry_b) == LMX_REF_OK);
    CHECK(lmx_ref_real_owner_limit(&owner_b, 0) == LMX_REF_OK);
    CHECK(lmx_ref_real_parse(&arena_b, &type_b, "1", &context, &status, &rejected) == LMX_REF_ALLOCATION);
    CHECK(owner_b.live_values == 0 && owner_b.allocated_bytes == 0 && arena_b.live_finalizers == 0);
    CHECK(lmx_ref_real_owner_limit(&owner_b, 65536) == LMX_REF_OK);
    CHECK(lmx_ref_real_parse(&arena_a, &type_a, "1", &context, &status, &one) == LMX_REF_OK);
    CHECK(lmx_ref_real_parse(&arena_a, &type_a, "0x1p-100", &context, &status, &epsilon) == LMX_REF_OK);
    CHECK(lmx_ref_real_add(&arena_a, &type_a, one.value, epsilon.value,
        &context, &status, &extended) == LMX_REF_OK);
    CHECK(bf_cmp(&((LmxRefReal *)extended.value)->number,
                 &((LmxRefReal *)one.value)->number) > 0);
    CHECK(lmx_ref_real_to_binary64(extended.value, &context, &status, &narrowed) == LMX_REF_NUMERIC);
    CHECK(narrowed == 99.0 && (status.conditions & LMX_NUM_INEXACT));
    CHECK(lmx_ref_real_text(extended.value, &text) == LMX_REF_OK);
    CHECK(lmx_ref_real_parse(&arena_b, &type_b, text, &context, &status, &restored) == LMX_REF_OK);
    free(text);
    CHECK(bf_cmp(&((LmxRefReal *)restored.value)->number,
                 &((LmxRefReal *)extended.value)->number) == 0);
    CHECK(lmx_ref_real_parse(&arena_a, &type_a, "2", &context, &status, &two) == LMX_REF_OK);
    before = owner_a.live_values;
    CHECK(lmx_ref_real_sqrt(&arena_a, &type_a, two.value, &context, &status, &rejected) == LMX_REF_NUMERIC);
    CHECK(owner_a.live_values == before && arena_a.live_finalizers == before);
    context.exact_required = 0;
    CHECK(lmx_ref_real_sqrt(&arena_a, &type_a, two.value, &context, &status, &root) == LMX_REF_OK);
    CHECK(status.conditions & LMX_NUM_INEXACT);
    CHECK(lmx_ref_record_copy(&arena_b, &registry_b, root, &copy) == LMX_REF_OK);
    CHECK(((LmxRefReal *)copy.value)->owner == &owner_b);
    CHECK(((LmxRefReal *)copy.value)->number.ctx == &owner_b.backend);
    CHECK(lmx_ref_real_owner_end(&owner_a) == LMX_REF_ARGUMENT);
    lmx_ref_arena_destroy(&arena_a);
    CHECK(owner_a.live_values == 0 && lmx_ref_real_owner_end(&owner_a) == LMX_REF_OK);
    CHECK(owner_a.allocated_bytes == 0);
    CHECK(lmx_ref_real_to_binary64(copy.value, &context, &status, &narrowed) == LMX_REF_OK);
    CHECK(fabs(narrowed - sqrt(2.0)) < 1e-15);
    before = owner_b.live_values;
    CHECK(lmx_ref_real_parse(&arena_b, &type_b, "1x", &context, &status, &rejected) == LMX_REF_ENCODING);
    CHECK(owner_b.live_values == before && (status.conditions & LMX_NUM_SYNTAX));
    lmx_ref_arena_destroy(&arena_b);
    CHECK(owner_b.live_values == 0 && lmx_ref_real_owner_end(&owner_b) == LMX_REF_OK);
    CHECK(owner_b.allocated_bytes == 0);
}

int main(void)
{
    LmxRefType rows[3];
    LmxRefType duplicate[2];
    LmxRefRegistry registry = { rows, 3 }, bad = { duplicate, 2 };
    LmxRefType scalar = { 703, 1703, "double", sizeof(double),
        LMX_REF_ALIGNOF(double), double_clone, NULL, NULL };
    /* Demonstration IDs only: production obtains codes from its own registry. */
    lmx_ref_numeric_rows(rows, 701, 1701, 702, 1702);
    rows[2] = scalar;
    CHECK(lmx_ref_registry_validate(&registry) == LMX_REF_OK);
    duplicate[0] = rows[0]; duplicate[1] = rows[1]; duplicate[1].code = rows[0].code;
    CHECK(lmx_ref_registry_validate(&bad) == LMX_REF_TYPE);
    check_runtime(rows, &registry);
    check_bigint(rows, &registry);
    check_decimal(rows, &registry);
    check_converters();
    check_real();
    printf("PASS: aligned records, code-only absence, chunk stability, owned numeric copy/revert, "
           "bigint arithmetic, decimal precision, decNumber conversion, arbitrary binary real, "
           "actor-owned real copy, quota rollback, exact narrowing and checked data adapters\n");
    printf("binary64 profile available on this target: %s\n",
           sizeof(double) == 8 && DBL_MANT_DIG == 53 && FLT_RADIX == 2 ? "yes" : "no");
    return 0;
}
