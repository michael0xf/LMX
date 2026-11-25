#include "real_provider.h"
#include <stdlib.h>
#include <string.h>
#include <float.h>

/* Enough alignment for the scalar/pointer objects used by this C99 backend. */
typedef union LmxRefRealAllocation {
    struct { size_t size; } metadata;
    long double align_float;
    void *align_pointer;
    uint64_t align_integer;
} LmxRefRealAllocation;

static void *real_reallocate(void *opaque, void *pointer, size_t size)
{
    LmxRefRealOwner *owner = (LmxRefRealOwner *)opaque;
    LmxRefRealAllocation *old = pointer ? (LmxRefRealAllocation *)pointer - 1 : NULL;
    LmxRefRealAllocation *next;
    size_t old_bytes = old ? sizeof *old + old->metadata.size : 0;
    size_t next_bytes, remaining;
    if (!size) {
        owner->allocated_bytes -= old_bytes;
        free(old);
        return NULL;
    }
    if (size > SIZE_MAX - sizeof *next) return NULL;
    next_bytes = sizeof *next + size;
    remaining = owner->allocated_bytes - old_bytes;
    if (remaining > owner->allocation_limit ||
        next_bytes > owner->allocation_limit - remaining) return NULL;
    next = (LmxRefRealAllocation *)realloc(old, next_bytes);
    if (!next) return NULL;
    next->metadata.size = size;
    owner->allocated_bytes = remaining + next_bytes;
    return (void *)(next + 1);
}

void lmx_ref_real_owner_init(LmxRefRealOwner *owner)
{
    owner->live_values = 0;
    owner->allocated_bytes = 0;
    owner->allocation_limit = SIZE_MAX;
    owner->initialized = 1;
    bf_context_init(&owner->backend, real_reallocate, owner);
}

LmxRefStatus lmx_ref_real_owner_limit(LmxRefRealOwner *owner, size_t bytes)
{
    if (!owner || !owner->initialized) return LMX_REF_ARGUMENT;
    if (bytes < owner->allocated_bytes) return LMX_REF_RANGE;
    owner->allocation_limit = bytes;
    return LMX_REF_OK;
}

LmxRefStatus lmx_ref_real_owner_end(LmxRefRealOwner *owner)
{
    if (!owner || !owner->initialized || owner->live_values)
        return LMX_REF_ARGUMENT;
    bf_context_end(&owner->backend);
    owner->initialized = 0;
    return LMX_REF_OK;
}

static LmxRefStatus real_empty(LmxRefReal *value, LmxRefRealOwner *owner)
{
    if (!owner || !owner->initialized) return LMX_REF_ARGUMENT;
    if (owner->live_values == SIZE_MAX) return LMX_REF_RANGE;
    value->owner = owner;
    bf_init(&owner->backend, &value->number);
    ++owner->live_values;
    return LMX_REF_OK;
}

static void real_drop(void *payload)
{
    LmxRefReal *value = (LmxRefReal *)payload;
    bf_delete(&value->number);
    --value->owner->live_values;
    value->owner = NULL;
}

static LmxRefStatus real_clone(void *destination, const void *source,
                               void *destination_context)
{
    LmxRefReal *dst = (LmxRefReal *)destination;
    const LmxRefReal *src = (const LmxRefReal *)source;
    LmxRefStatus status;
    if (!src->owner || !src->owner->initialized) return LMX_REF_ARGUMENT;
    status = real_empty(dst, (LmxRefRealOwner *)destination_context);
    if (status != LMX_REF_OK) return status;
    if (bf_set(&dst->number, &src->number)) {
        real_drop(dst);
        return LMX_REF_ALLOCATION;
    }
    return LMX_REF_OK;
}

void lmx_ref_real_row(LmxRefType *row, LmxRefRealOwner *owner,
                      int code, int uninit_code)
{
    LmxRefType value = { code, uninit_code, "real", sizeof(LmxRefReal),
        LMX_REF_ALIGNOF(LmxRefReal), real_clone, real_drop, owner };
    *row = value;
}

static int real_type_valid(const LmxRefType *type)
{
    return type && type->clone == real_clone && type->drop == real_drop &&
        type->size == sizeof(LmxRefReal) && type->context;
}

static LmxRefStatus real_profile(const LmxRefRealContext *context,
                                 LmxRefNumericStatus *status,
                                 limb_t *precision, bf_flags_t *flags)
{
    bf_rnd_t rounding;
    if (!context || !status) return LMX_REF_ARGUMENT;
    status->backend = 3; status->backend_bits = 0; status->conditions = 0;
    if (context->precision_bits < BF_PREC_MIN ||
        context->precision_bits > BF_PREC_MAX ||
        context->exponent_bits < BF_EXP_BITS_MIN ||
        context->exponent_bits > BF_EXP_BITS_MAX ||
        (context->subnormals != 0 && context->subnormals != 1) ||
        (context->exact_required != 0 && context->exact_required != 1)) {
        status->conditions = LMX_NUM_CONTEXT; return LMX_REF_RANGE;
    }
    switch (context->rounding) {
        case LMX_ROUND_HALF_EVEN: rounding = BF_RNDN; break;
        case LMX_ROUND_HALF_UP: rounding = BF_RNDNA; break;
        case LMX_ROUND_TOWARD_ZERO: rounding = BF_RNDZ; break;
        case LMX_ROUND_AWAY_ZERO: rounding = BF_RNDA; break;
        case LMX_ROUND_CEILING: rounding = BF_RNDU; break;
        case LMX_ROUND_FLOOR: rounding = BF_RNDD; break;
        default: status->conditions = LMX_NUM_CONTEXT; return LMX_REF_ARGUMENT;
    }
    *precision = (limb_t)context->precision_bits;
    *flags = (bf_flags_t)rounding | bf_set_exp_bits((int)context->exponent_bits);
    if (context->subnormals) *flags |= BF_FLAG_SUBNORMAL;
    return LMX_REF_OK;
}

static LmxRefStatus real_status(int bits, const LmxRefRealContext *context,
                                LmxRefNumericStatus *status)
{
    uint32_t mapped = 0;
    if (bits & BF_ST_INVALID_OP) mapped |= LMX_NUM_INVALID;
    if (bits & BF_ST_DIVIDE_ZERO) mapped |= LMX_NUM_DIVISION_ZERO;
    if (bits & BF_ST_OVERFLOW) mapped |= LMX_NUM_OVERFLOW;
    if (bits & BF_ST_UNDERFLOW) mapped |= LMX_NUM_UNDERFLOW;
    if (bits & BF_ST_INEXACT) mapped |= LMX_NUM_INEXACT;
    if (bits & BF_ST_MEM_ERROR) mapped |= LMX_NUM_ALLOCATION;
    status->backend = 3;
    status->backend_bits = (uint32_t)bits;
    status->conditions = mapped;
    if (mapped & LMX_NUM_ALLOCATION) return LMX_REF_ALLOCATION;
    if ((mapped & context->traps) ||
        (context->exact_required && (mapped & LMX_NUM_INEXACT)))
        return LMX_REF_NUMERIC;
    return LMX_REF_OK;
}

static LmxRefStatus real_begin(LmxRefArena *arena, const LmxRefType *type,
                               LmxRefRecord *record)
{
    LmxRefStatus status = lmx_ref_record_new(arena, type, 1, record);
    if (status != LMX_REF_OK) return status;
    return real_empty((LmxRefReal *)record->value,
                       (LmxRefRealOwner *)type->context);
}

static LmxRefStatus real_finish(LmxRefArena *arena, const LmxRefType *type,
                                LmxRefMark mark, LmxRefRecord record,
                                LmxRefStatus result, LmxRefRecord *out)
{
    if (result == LMX_REF_OK) result = lmx_ref_record_own(arena, type, record);
    if (result != LMX_REF_OK) {
        real_drop(record.value);
        lmx_ref_revert(arena, mark);
        return result;
    }
    *out = record;
    return LMX_REF_OK;
}

LmxRefStatus lmx_ref_real_parse(LmxRefArena *arena, const LmxRefType *type,
                                const char *text, const LmxRefRealContext *context,
                                LmxRefNumericStatus *status, LmxRefRecord *out)
{
    limb_t precision;
    bf_flags_t flags;
    LmxRefRecord record;
    LmxRefMark mark;
    LmxRefStatus result;
    const char *next;
    int bits;
    if (!arena || !real_type_valid(type) || !text || !*text || !out)
        return LMX_REF_ARGUMENT;
    result = real_profile(context, status, &precision, &flags);
    if (result != LMX_REF_OK) return result;
    mark = lmx_ref_mark(arena);
    result = real_begin(arena, type, &record);
    if (result != LMX_REF_OK) { lmx_ref_revert(arena, mark); return result; }
    bits = bf_atof(&((LmxRefReal *)record.value)->number, text, &next, 0,
                    precision, flags | BF_ATOF_BIN_OCT);
    result = real_status(bits, context, status);
    if (!(bits & BF_ST_MEM_ERROR) && (next == text || *next)) {
        status->conditions |= LMX_NUM_SYNTAX;
        result = LMX_REF_ENCODING;
    }
    return real_finish(arena, type, mark, record, result, out);
}

LmxRefStatus lmx_ref_real_add(LmxRefArena *arena, const LmxRefType *type,
                              const LmxRefReal *a, const LmxRefReal *b,
                              const LmxRefRealContext *context,
                              LmxRefNumericStatus *status, LmxRefRecord *out)
{
    limb_t precision;
    bf_flags_t flags;
    LmxRefRecord record;
    LmxRefMark mark;
    LmxRefStatus result;
    int bits;
    if (!arena || !real_type_valid(type) || !a || !b || !out ||
        !a->owner || !b->owner || !a->owner->initialized || !b->owner->initialized)
        return LMX_REF_ARGUMENT;
    result = real_profile(context, status, &precision, &flags);
    if (result != LMX_REF_OK) return result;
    mark = lmx_ref_mark(arena);
    result = real_begin(arena, type, &record);
    if (result != LMX_REF_OK) { lmx_ref_revert(arena, mark); return result; }
    bits = bf_add(&((LmxRefReal *)record.value)->number, &a->number, &b->number,
                   precision, flags);
    result = real_status(bits, context, status);
    return real_finish(arena, type, mark, record, result, out);
}

LmxRefStatus lmx_ref_real_sqrt(LmxRefArena *arena, const LmxRefType *type,
                               const LmxRefReal *a, const LmxRefRealContext *context,
                               LmxRefNumericStatus *status, LmxRefRecord *out)
{
    limb_t precision;
    bf_flags_t flags;
    LmxRefRecord record;
    LmxRefMark mark;
    LmxRefStatus result;
    int bits;
    if (!arena || !real_type_valid(type) || !a || !out ||
        !a->owner || !a->owner->initialized) return LMX_REF_ARGUMENT;
    result = real_profile(context, status, &precision, &flags);
    if (result != LMX_REF_OK) return result;
    mark = lmx_ref_mark(arena);
    result = real_begin(arena, type, &record);
    if (result != LMX_REF_OK) { lmx_ref_revert(arena, mark); return result; }
    bits = bf_sqrt(&((LmxRefReal *)record.value)->number, &a->number, precision, flags);
    result = real_status(bits, context, status);
    return real_finish(arena, type, mark, record, result, out);
}

LmxRefStatus lmx_ref_real_text(const LmxRefReal *value, char **out)
{
    size_t length;
    char *native, *copy;
    if (!value || !value->owner || !out) return LMX_REF_ARGUMENT;
    native = bf_ftoa(&length, &value->number, 16, 0,
                      BF_FTOA_FORMAT_FREE | BF_FTOA_ADD_PREFIX);
    if (!native) return LMX_REF_ALLOCATION;
    if (length == SIZE_MAX) {
        bf_free(&value->owner->backend, native); return LMX_REF_RANGE;
    }
    copy = (char *)malloc(length + 1);
    if (copy) memcpy(copy, native, length + 1);
    bf_free(&value->owner->backend, native);
    if (!copy) return LMX_REF_ALLOCATION;
    *out = copy;
    return LMX_REF_OK;
}

LmxRefStatus lmx_ref_real_to_binary64(const LmxRefReal *value,
                                     const LmxRefRealContext *context,
                                     LmxRefNumericStatus *status, double *out)
{
    limb_t precision;
    bf_flags_t flags;
    LmxRefStatus result;
    double temporary;
    int bits;
    if (!value || !out) return LMX_REF_ARGUMENT;
    if (sizeof(double) != 8 || FLT_RADIX != 2 || DBL_MANT_DIG != 53)
        return LMX_REF_TYPE;
    result = real_profile(context, status, &precision, &flags);
    if (result != LMX_REF_OK) return result;
    bits = bf_get_float64(&value->number, &temporary,
                           (bf_rnd_t)(flags & BF_RND_MASK));
    result = real_status(bits, context, status);
    if (result == LMX_REF_OK) *out = temporary;
    return result;
}
