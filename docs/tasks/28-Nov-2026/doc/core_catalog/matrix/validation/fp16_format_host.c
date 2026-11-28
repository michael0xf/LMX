// Actual pinned FP16 header test. This does not exercise LMX or a bridge.
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <fp16/fp16.h>

int main(void) {
    unsigned failures=0, cases=0;
    float x;
#define CHECK(C) do { ++cases; if (!(C)) ++failures; } while (0)
    CHECK(fp16_ieee_to_fp32_value(UINT16_C(0x3c00)) == 1.0f);
    CHECK(fp16_alt_to_fp32_value(UINT16_C(0x3c00)) == 1.0f);
    CHECK(isinf(fp16_ieee_to_fp32_value(UINT16_C(0x7c00))));
    CHECK(fp16_alt_to_fp32_value(UINT16_C(0x7c00)) == 65536.0f);
    x=fp16_ieee_to_fp32_value(UINT16_C(0x8000));
    CHECK(x == 0.0f && signbit(x));
    CHECK(fp16_ieee_to_fp32_value(UINT16_C(0x0001)) == ldexpf(1.0f,-24));
    CHECK(isnan(fp16_ieee_to_fp32_value(UINT16_C(0x7e00))));
    CHECK(fp16_ieee_from_fp32_value(1.0f) == UINT16_C(0x3c00));
    CHECK(fp16_alt_from_fp32_value(65536.0f) == UINT16_C(0x7c00));
    printf("{\"mode\":\"PINNED_VENDOR_FP16_HOST_NOT_LMX_BRIDGE\",\"cases\":%u,\"failures\":%u}\n", cases, failures);
    return failures != 0;
}
