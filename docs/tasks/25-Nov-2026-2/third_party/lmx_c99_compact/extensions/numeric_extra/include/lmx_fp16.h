#ifndef LMX_FP16_H
#define LMX_FP16_H
#include <stdint.h>
/* Explicit scalar C entries for header-only FP16; no native half ABI needed. */
float lmx_fp16_ieee_to_float(uint16_t encoded);
uint16_t lmx_fp16_ieee_from_float(float value);
float lmx_fp16_alt_to_float(uint16_t encoded);
uint16_t lmx_fp16_alt_from_float(float value);
#endif
