#ifndef LMX_REFERENCE_NUMERIC_PROVIDER_H
#define LMX_REFERENCE_NUMERIC_PROVIDER_H
#include "primitive_runtime.h"
#include <tommath.h>
#include <mpdecimal.h>
#include <decNumber.h>

typedef struct LmxRefBigint { mp_int *number; } LmxRefBigint;
typedef struct LmxRefDecimal { mpd_t *number; } LmxRefDecimal;

typedef enum LmxRefRounding {
    LMX_ROUND_HALF_EVEN,
    LMX_ROUND_HALF_UP,
    LMX_ROUND_HALF_DOWN,
    LMX_ROUND_TOWARD_ZERO,
    LMX_ROUND_AWAY_ZERO,
    LMX_ROUND_CEILING,
    LMX_ROUND_FLOOR,
    LMX_ROUND_05UP
} LmxRefRounding;

enum {
    LMX_NUM_INEXACT = 1u << 0,
    LMX_NUM_ROUNDED = 1u << 1,
    LMX_NUM_OVERFLOW = 1u << 2,
    LMX_NUM_UNDERFLOW = 1u << 3,
    LMX_NUM_SUBNORMAL = 1u << 4,
    LMX_NUM_CLAMPED = 1u << 5,
    LMX_NUM_DIVISION_ZERO = 1u << 6,
    LMX_NUM_INVALID = 1u << 7,
    LMX_NUM_ALLOCATION = 1u << 8,
    LMX_NUM_SYNTAX = 1u << 9,
    LMX_NUM_CONTEXT = 1u << 10
};

typedef struct LmxRefDecimalContext {
    int64_t precision;
    int64_t emax;
    int64_t emin;
    LmxRefRounding rounding;
    uint32_t traps;
    int clamp;
    int exact_required;
} LmxRefDecimalContext;

typedef struct LmxRefNumericStatus {
    uint32_t conditions;
    uint32_t backend_bits;
    int backend; /* 1 = MPDecimal, 2 = decNumber, 3 = LibBF; not a language type code. */
} LmxRefNumericStatus;

/* Codes are allocated/resolved by the actual core, never hard-coded here.
 * Arbitrary binary real is a separate row in real_provider.h. */
void lmx_ref_numeric_rows(LmxRefType rows[2], int bigint_code,
                          int bigint_uninit_code, int decimal_code,
                          int decimal_uninit_code);

LmxRefStatus lmx_ref_bigint_parse(LmxRefArena *arena, const LmxRefType *type,
                                 const char *text, LmxRefRecord *out);
LmxRefStatus lmx_ref_bigint_add(LmxRefArena *arena, const LmxRefType *type,
                               const LmxRefBigint *a, const LmxRefBigint *b,
                               LmxRefRecord *out);
/* Returned strings use malloc; caller uses free. */
LmxRefStatus lmx_ref_bigint_text(const LmxRefBigint *value, char **out);
LmxRefStatus lmx_ref_decimal_parse(LmxRefArena *arena, const LmxRefType *type,
                                  const char *text,
                                  const LmxRefDecimalContext *context,
                                  LmxRefNumericStatus *status,
                                  LmxRefRecord *out);
LmxRefStatus lmx_ref_decimal_add(LmxRefArena *arena, const LmxRefType *type,
                                const LmxRefDecimal *a, const LmxRefDecimal *b,
                                const LmxRefDecimalContext *context,
                                LmxRefNumericStatus *status,
                                LmxRefRecord *out);
LmxRefStatus lmx_ref_decimal_text(const LmxRefDecimal *value, char **out);
/* The output is separately allocated decNumber storage, sized by the supplied
 * context's precision. Caller uses free; no cast between mpd_t and decNumber. */
LmxRefStatus lmx_ref_decimal_to_decnumber(const LmxRefDecimal *value,
                                         const LmxRefDecimalContext *context,
                                         LmxRefNumericStatus *status,
                                         decNumber **out);
LmxRefStatus lmx_ref_decimal_from_decnumber(LmxRefArena *arena,
                                           const LmxRefType *type,
                                           const decNumber *value,
                                           const LmxRefDecimalContext *context,
                                           LmxRefNumericStatus *status,
                                           LmxRefRecord *out);

#endif
