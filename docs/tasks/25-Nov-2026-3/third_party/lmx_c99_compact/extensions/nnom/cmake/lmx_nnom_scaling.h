/* LMX C99 integration helper, Apache-2.0. Upstream remains unchanged. */
#ifndef LMX_NNOM_SCALING_H
#define LMX_NNOM_SCALING_H
#include <stdint.h>
#include <limits.h>
#if CHAR_BIT != 8 || INT_MAX != INT32_MAX
#error "NNoM scalar profile requires 8-bit bytes and 32-bit int"
#endif
#if ((-2 >> 1) != -1)
#error "NNoM scalar profile requires arithmetic signed right shift"
#endif
/* Model quantization must keep shift in 0..30 and scaled values in int32_t.
 * Multiplication in int64_t is defined for negative values, unlike signed
 * left shift. It leaves the supported quantized arithmetic unchanged. */
static inline int32_t lmx_nnom_scale_signed(int32_t value, int32_t shift) {
    return (int32_t)((int64_t)value * (INT64_C(1) << shift));
}
#endif
