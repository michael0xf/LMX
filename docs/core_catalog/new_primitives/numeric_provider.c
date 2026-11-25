#include "numeric_provider.h"
#include <stdlib.h>
#include <string.h>
#include <limits.h>

static void bigint_drop(void *payload)
{
    LmxRefBigint *value = (LmxRefBigint *)payload;
    if (value->number) { mp_clear(value->number); free(value->number); }
    value->number = NULL;
}

static void decimal_drop(void *payload)
{
    LmxRefDecimal *value = (LmxRefDecimal *)payload;
    if (value->number) mpd_del(value->number);
    value->number = NULL;
}

static LmxRefStatus bigint_empty(LmxRefBigint *value)
{
    value->number = (mp_int *)malloc(sizeof *value->number);
    if (!value->number) return LMX_REF_ALLOCATION;
    if (mp_init(value->number) != MP_OKAY) {
        free(value->number); value->number = NULL;
        return LMX_REF_ALLOCATION;
    }
    return LMX_REF_OK;
}

static LmxRefStatus bigint_clone(void *destination, const void *source, void *context)
{
    (void)context;
    LmxRefBigint *dst = (LmxRefBigint *)destination;
    const LmxRefBigint *src = (const LmxRefBigint *)source;
    LmxRefStatus status;
    if (!src->number) return LMX_REF_ARGUMENT;
    status = bigint_empty(dst);
    if (status != LMX_REF_OK) return status;
    if (mp_copy(src->number, dst->number) != MP_OKAY) {
        bigint_drop(dst); return LMX_REF_ALLOCATION;
    }
    return LMX_REF_OK;
}

static LmxRefStatus decimal_clone(void *destination, const void *source, void *context)
{
    (void)context;
    LmxRefDecimal *dst = (LmxRefDecimal *)destination;
    const LmxRefDecimal *src = (const LmxRefDecimal *)source;
    uint32_t status = 0;
    if (!src->number) return LMX_REF_ARGUMENT;
    dst->number = mpd_qnew();
    if (!dst->number) return LMX_REF_ALLOCATION;
    if (!mpd_qcopy(dst->number, src->number, &status)) {
        decimal_drop(dst); return LMX_REF_ALLOCATION;
    }
    return LMX_REF_OK;
}

void lmx_ref_numeric_rows(LmxRefType rows[2], int bigint_code,
                          int bigint_uninit_code, int decimal_code,
                          int decimal_uninit_code)
{
    LmxRefType bigint = { bigint_code, bigint_uninit_code, "bigint",
        sizeof(LmxRefBigint), LMX_REF_ALIGNOF(LmxRefBigint),
        bigint_clone, bigint_drop, NULL };
    LmxRefType decimal = { decimal_code, decimal_uninit_code, "decimal",
        sizeof(LmxRefDecimal), LMX_REF_ALIGNOF(LmxRefDecimal),
        decimal_clone, decimal_drop, NULL };
    rows[0] = bigint;
    rows[1] = decimal;
}

static int bigint_type_valid(const LmxRefType *type)
{
    return type && type->clone == bigint_clone && type->drop == bigint_drop &&
        type->size == sizeof(LmxRefBigint);
}

static int decimal_type_valid(const LmxRefType *type)
{
    return type && type->clone == decimal_clone && type->drop == decimal_drop &&
        type->size == sizeof(LmxRefDecimal);
}

static LmxRefStatus publish(LmxRefArena *arena, const LmxRefType *type,
                            LmxRefMark mark, LmxRefRecord record,
                            LmxRefRecord *out)
{
    LmxRefStatus status = lmx_ref_record_own(arena, type, record);
    if (status != LMX_REF_OK) {
        type->drop(record.value);
        lmx_ref_revert(arena, mark);
        return status;
    }
    *out = record;
    return LMX_REF_OK;
}

LmxRefStatus lmx_ref_bigint_parse(LmxRefArena *arena, const LmxRefType *type,
                                 const char *text, LmxRefRecord *out)
{
    const char *p;
    LmxRefMark mark;
    LmxRefRecord record;
    LmxRefStatus status;
    LmxRefBigint *value;
    if (!arena || !bigint_type_valid(type) || !text || !out)
        return LMX_REF_ARGUMENT;
    p = text;
    if (*p == '-') ++p;
    if (!*p) return LMX_REF_ENCODING;
    for (; *p; ++p) if (*p < '0' || *p > '9') return LMX_REF_ENCODING;
    mark = lmx_ref_mark(arena);
    status = lmx_ref_record_new(arena, type, 1, &record);
    if (status != LMX_REF_OK) return status;
    value = (LmxRefBigint *)record.value;
    status = bigint_empty(value);
    if (status == LMX_REF_OK && mp_read_radix(value->number, text, 10) != MP_OKAY)
        status = LMX_REF_ALLOCATION;
    if (status != LMX_REF_OK) {
        bigint_drop(value); lmx_ref_revert(arena, mark); return status;
    }
    return publish(arena, type, mark, record, out);
}

LmxRefStatus lmx_ref_bigint_add(LmxRefArena *arena, const LmxRefType *type,
                               const LmxRefBigint *a, const LmxRefBigint *b,
                               LmxRefRecord *out)
{
    LmxRefMark mark;
    LmxRefRecord record;
    LmxRefStatus status;
    LmxRefBigint *value;
    if (!arena || !bigint_type_valid(type) || !a || !b || !out ||
        !a->number || !b->number) return LMX_REF_ARGUMENT;
    mark = lmx_ref_mark(arena);
    status = lmx_ref_record_new(arena, type, 1, &record);
    if (status != LMX_REF_OK) return status;
    value = (LmxRefBigint *)record.value;
    status = bigint_empty(value);
    if (status == LMX_REF_OK && mp_add(a->number, b->number, value->number) != MP_OKAY)
        status = LMX_REF_ALLOCATION;
    if (status != LMX_REF_OK) {
        bigint_drop(value); lmx_ref_revert(arena, mark); return status;
    }
    return publish(arena, type, mark, record, out);
}

LmxRefStatus lmx_ref_bigint_text(const LmxRefBigint *value, char **out)
{
    int length;
    char *text;
    if (!value || !value->number || !out) return LMX_REF_ARGUMENT;
    if (mp_radix_size(value->number, 10, &length) != MP_OKAY || length <= 0)
        return LMX_REF_NUMERIC;
    text = (char *)malloc((size_t)length);
    if (!text) return LMX_REF_ALLOCATION;
    if (mp_to_radix(value->number, text, (size_t)length, NULL, 10) != MP_OKAY) {
        free(text); return LMX_REF_NUMERIC;
    }
    *out = text;
    return LMX_REF_OK;
}

static int mpd_rounding(LmxRefRounding rounding)
{
    switch (rounding) {
    case LMX_ROUND_HALF_EVEN: return MPD_ROUND_HALF_EVEN;
    case LMX_ROUND_HALF_UP: return MPD_ROUND_HALF_UP;
    case LMX_ROUND_HALF_DOWN: return MPD_ROUND_HALF_DOWN;
    case LMX_ROUND_TOWARD_ZERO: return MPD_ROUND_DOWN;
    case LMX_ROUND_AWAY_ZERO: return MPD_ROUND_UP;
    case LMX_ROUND_CEILING: return MPD_ROUND_CEILING;
    case LMX_ROUND_FLOOR: return MPD_ROUND_FLOOR;
    case LMX_ROUND_05UP: return MPD_ROUND_05UP;
    }
    return -1;
}

static LmxRefStatus make_context(const LmxRefDecimalContext *source,
                                 mpd_context_t *out)
{
    int rounding;
    if (!source || !out) return LMX_REF_ARGUMENT;
    rounding = mpd_rounding(source->rounding);
    if (source->precision <= 0 || source->precision > MPD_MAX_PREC ||
        source->emax < 0 || source->emax > MPD_MAX_EMAX ||
        source->emin > 0 || source->emin < MPD_MIN_EMIN || rounding < 0 ||
        (source->clamp != 0 && source->clamp != 1) ||
        (source->exact_required != 0 && source->exact_required != 1))
        return LMX_REF_RANGE;
    mpd_maxcontext(out);
    if (!mpd_qsetprec(out, (mpd_ssize_t)source->precision) ||
        !mpd_qsetemax(out, (mpd_ssize_t)source->emax) ||
        !mpd_qsetemin(out, (mpd_ssize_t)source->emin) ||
        !mpd_qsetround(out, rounding) || !mpd_qsetclamp(out, source->clamp))
        return LMX_REF_RANGE;
    out->traps = 0; out->status = 0; out->newtrap = 0;
    return LMX_REF_OK;
}

static uint32_t mpd_conditions(uint32_t flags)
{
    uint32_t result = 0;
    if (flags & MPD_Inexact) result |= LMX_NUM_INEXACT;
    if (flags & MPD_Rounded) result |= LMX_NUM_ROUNDED;
    if (flags & MPD_Overflow) result |= LMX_NUM_OVERFLOW;
    if (flags & MPD_Underflow) result |= LMX_NUM_UNDERFLOW;
    if (flags & MPD_Subnormal) result |= LMX_NUM_SUBNORMAL;
    if (flags & MPD_Clamped) result |= LMX_NUM_CLAMPED;
    if (flags & MPD_Division_by_zero) result |= LMX_NUM_DIVISION_ZERO;
    if (flags & MPD_IEEE_Invalid_operation) result |= LMX_NUM_INVALID;
    if (flags & MPD_Malloc_error) result |= LMX_NUM_ALLOCATION;
    if (flags & MPD_Conversion_syntax) result |= LMX_NUM_SYNTAX;
    if (flags & MPD_Invalid_context) result |= LMX_NUM_CONTEXT;
    return result;
}

static LmxRefStatus check_conditions(const LmxRefDecimalContext *context,
                                     const LmxRefNumericStatus *status)
{
    if (status->conditions & LMX_NUM_ALLOCATION) return LMX_REF_ALLOCATION;
    if (status->conditions & LMX_NUM_CONTEXT) return LMX_REF_RANGE;
    if (status->conditions & LMX_NUM_SYNTAX) return LMX_REF_ENCODING;
    if ((status->conditions & context->traps) ||
        (context->exact_required && (status->conditions & LMX_NUM_INEXACT)))
        return LMX_REF_NUMERIC;
    return LMX_REF_OK;
}

LmxRefStatus lmx_ref_decimal_parse(LmxRefArena *arena, const LmxRefType *type,
                                  const char *text,
                                  const LmxRefDecimalContext *context,
                                  LmxRefNumericStatus *numeric_status,
                                  LmxRefRecord *out)
{
    mpd_context_t ctx;
    uint32_t flags = 0;
    LmxRefStatus status;
    LmxRefMark mark;
    LmxRefRecord record;
    LmxRefDecimal *value;
    if (!arena || !decimal_type_valid(type) || !text || !numeric_status || !out)
        return LMX_REF_ARGUMENT;
    numeric_status->conditions = 0; numeric_status->backend_bits = 0;
    numeric_status->backend = 1;
    status = make_context(context, &ctx);
    if (status != LMX_REF_OK) return status;
    mark = lmx_ref_mark(arena);
    status = lmx_ref_record_new(arena, type, 1, &record);
    if (status != LMX_REF_OK) return status;
    value = (LmxRefDecimal *)record.value;
    value->number = mpd_qnew();
    if (!value->number) {
        lmx_ref_revert(arena, mark); return LMX_REF_ALLOCATION;
    }
    mpd_qset_string(value->number, text, &ctx, &flags);
    numeric_status->backend_bits = flags;
    numeric_status->conditions = mpd_conditions(flags);
    status = check_conditions(context, numeric_status);
    if (status != LMX_REF_OK) {
        decimal_drop(value); lmx_ref_revert(arena, mark); return status;
    }
    return publish(arena, type, mark, record, out);
}

LmxRefStatus lmx_ref_decimal_add(LmxRefArena *arena, const LmxRefType *type,
                                const LmxRefDecimal *a, const LmxRefDecimal *b,
                                const LmxRefDecimalContext *context,
                                LmxRefNumericStatus *numeric_status,
                                LmxRefRecord *out)
{
    mpd_context_t ctx;
    uint32_t flags = 0;
    LmxRefStatus status;
    LmxRefMark mark;
    LmxRefRecord record;
    LmxRefDecimal *value;
    if (!arena || !decimal_type_valid(type) || !a || !b || !a->number ||
        !b->number || !numeric_status || !out) return LMX_REF_ARGUMENT;
    numeric_status->conditions = 0; numeric_status->backend_bits = 0;
    numeric_status->backend = 1;
    status = make_context(context, &ctx);
    if (status != LMX_REF_OK) return status;
    mark = lmx_ref_mark(arena);
    status = lmx_ref_record_new(arena, type, 1, &record);
    if (status != LMX_REF_OK) return status;
    value = (LmxRefDecimal *)record.value;
    value->number = mpd_qnew();
    if (!value->number) {
        lmx_ref_revert(arena, mark); return LMX_REF_ALLOCATION;
    }
    mpd_qadd(value->number, a->number, b->number, &ctx, &flags);
    numeric_status->backend_bits = flags;
    numeric_status->conditions = mpd_conditions(flags);
    status = check_conditions(context, numeric_status);
    if (status != LMX_REF_OK) {
        decimal_drop(value); lmx_ref_revert(arena, mark); return status;
    }
    return publish(arena, type, mark, record, out);
}

LmxRefStatus lmx_ref_decimal_text(const LmxRefDecimal *value, char **out)
{
    char *backend, *text;
    size_t size;
    if (!value || !value->number || !out) return LMX_REF_ARGUMENT;
    backend = mpd_to_sci(value->number, 1);
    if (!backend) return LMX_REF_ALLOCATION;
    size = strlen(backend);
    if (size == SIZE_MAX) { mpd_free(backend); return LMX_REF_RANGE; }
    text = (char *)malloc(size + 1);
    if (!text) { mpd_free(backend); return LMX_REF_ALLOCATION; }
    memcpy(text, backend, size + 1);
    mpd_free(backend);
    *out = text;
    return LMX_REF_OK;
}

static enum rounding dec_rounding(LmxRefRounding rounding)
{
    switch (rounding) {
    case LMX_ROUND_HALF_EVEN: return DEC_ROUND_HALF_EVEN;
    case LMX_ROUND_HALF_UP: return DEC_ROUND_HALF_UP;
    case LMX_ROUND_HALF_DOWN: return DEC_ROUND_HALF_DOWN;
    case LMX_ROUND_TOWARD_ZERO: return DEC_ROUND_DOWN;
    case LMX_ROUND_AWAY_ZERO: return DEC_ROUND_UP;
    case LMX_ROUND_CEILING: return DEC_ROUND_CEILING;
    case LMX_ROUND_FLOOR: return DEC_ROUND_FLOOR;
    case LMX_ROUND_05UP: return DEC_ROUND_05UP;
    }
    return DEC_ROUND_MAX;
}

static uint32_t dec_conditions(uint32_t flags)
{
    uint32_t result = 0;
    if (flags & DEC_Inexact) result |= LMX_NUM_INEXACT;
    if (flags & DEC_Rounded) result |= LMX_NUM_ROUNDED;
    if (flags & DEC_Overflow) result |= LMX_NUM_OVERFLOW;
    if (flags & DEC_Underflow) result |= LMX_NUM_UNDERFLOW;
    if (flags & DEC_Subnormal) result |= LMX_NUM_SUBNORMAL;
    if (flags & DEC_Clamped) result |= LMX_NUM_CLAMPED;
    if (flags & DEC_Division_by_zero) result |= LMX_NUM_DIVISION_ZERO;
    if (flags & DEC_IEEE_754_Invalid_operation) result |= LMX_NUM_INVALID;
    if (flags & DEC_Insufficient_storage) result |= LMX_NUM_ALLOCATION;
    if (flags & DEC_Conversion_syntax) result |= LMX_NUM_SYNTAX;
    if (flags & DEC_Invalid_context) result |= LMX_NUM_CONTEXT;
    return result;
}

LmxRefStatus lmx_ref_decimal_to_decnumber(const LmxRefDecimal *value,
                                         const LmxRefDecimalContext *context,
                                         LmxRefNumericStatus *numeric_status,
                                         decNumber **out)
{
    decContext ctx;
    mpd_context_t mpd_check;
    size_t units, bytes;
    decNumber *number;
    char *text;
    LmxRefStatus status;
    if (!value || !value->number || !context || !numeric_status || !out)
        return LMX_REF_ARGUMENT;
    numeric_status->conditions = 0; numeric_status->backend_bits = 0;
    numeric_status->backend = 2;
    status = make_context(context, &mpd_check);
    if (status != LMX_REF_OK) return status;
    if (context->precision > DEC_MAX_DIGITS || context->emax > DEC_MAX_EMAX ||
        context->emin < DEC_MIN_EMIN) return LMX_REF_RANGE;
    units = ((size_t)context->precision + DECDPUN - 1) / DECDPUN;
    if (units < DECNUMUNITS) units = DECNUMUNITS;
    if (units - DECNUMUNITS > (SIZE_MAX - sizeof(decNumber)) / sizeof(decNumberUnit))
        return LMX_REF_RANGE;
    bytes = sizeof(decNumber) + (units - DECNUMUNITS) * sizeof(decNumberUnit);
    number = (decNumber *)malloc(bytes);
    if (!number) return LMX_REF_ALLOCATION;
    status = lmx_ref_decimal_text(value, &text);
    if (status != LMX_REF_OK) { free(number); return status; }
    decContextDefault(&ctx, DEC_INIT_BASE);
    ctx.digits = (int32_t)context->precision;
    ctx.emax = (int32_t)context->emax;
    ctx.emin = (int32_t)context->emin;
    ctx.round = dec_rounding(context->rounding);
    ctx.clamp = (uint8_t)context->clamp;
    ctx.traps = 0; ctx.status = 0;
    decNumberFromString(number, text, &ctx);
    free(text);
    numeric_status->backend_bits = ctx.status;
    numeric_status->conditions = dec_conditions(ctx.status);
    status = check_conditions(context, numeric_status);
    if (status != LMX_REF_OK) { free(number); return status; }
    *out = number;
    return LMX_REF_OK;
}

LmxRefStatus lmx_ref_decimal_from_decnumber(LmxRefArena *arena,
                                           const LmxRefType *type,
                                           const decNumber *value,
                                           const LmxRefDecimalContext *context,
                                           LmxRefNumericStatus *numeric_status,
                                           LmxRefRecord *out)
{
    char *text;
    size_t size;
    LmxRefStatus status;
    if (!value || value->digits <= 0) return LMX_REF_ARGUMENT;
    if ((uint64_t)value->digits > SIZE_MAX - 14) return LMX_REF_RANGE;
    size = (size_t)value->digits + 14;
    text = (char *)malloc(size);
    if (!text) return LMX_REF_ALLOCATION;
    decNumberToString(value, text);
    status = lmx_ref_decimal_parse(arena, type, text, context, numeric_status, out);
    free(text);
    return status;
}
