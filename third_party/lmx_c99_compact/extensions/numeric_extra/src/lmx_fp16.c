#include "lmx_fp16.h"
#include <fp16.h>
float lmx_fp16_ieee_to_float(uint16_t encoded) { return fp16_ieee_to_fp32_value(encoded); }
uint16_t lmx_fp16_ieee_from_float(float value) { return fp16_ieee_from_fp32_value(value); }
float lmx_fp16_alt_to_float(uint16_t encoded) { return fp16_alt_to_fp32_value(encoded); }
uint16_t lmx_fp16_alt_from_float(float value) { return fp16_alt_from_fp32_value(value); }
