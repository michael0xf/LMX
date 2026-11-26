/* SPDX-License-Identifier: MIT */
#include <assert.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include <libwapcaplet/libwapcaplet.h>
#include <parserutils/charset/codec.h>

int main(void)
{
    lwc_string *a, *b, *upper;
    bool equal = false;
    parserutils_charset_codec *codec;
    const uint8_t text[] = {'A', 0xc3, 0xa9, 0xe4, 0xb8, 0xad};
    uint8_t ucs[64], result[64], *dst;
    const uint8_t *src;
    size_t input, output, decoded;
    assert(lwc_intern_string("orbit", 5, &a) == lwc_error_ok);
    assert(lwc_intern_string("orbit", 5, &b) == lwc_error_ok);
    assert(a == b);
    assert(lwc_intern_string("ORBIT", 5, &upper) == lwc_error_ok);
    assert(lwc_string_caseless_isequal(a, upper, &equal) == lwc_error_ok && equal);
    lwc_string_unref(a); lwc_string_unref(b); lwc_string_unref(upper);
    assert(parserutils_charset_codec_create("UTF-8", &codec) == PARSERUTILS_OK);
    src = text; input = sizeof text; dst = ucs; output = sizeof ucs;
    assert(parserutils_charset_codec_decode(codec, &src, &input, &dst, &output) == PARSERUTILS_OK);
    assert(input == 0); decoded = (size_t)(dst - ucs); assert(decoded == 12);
    assert(parserutils_charset_codec_reset(codec) == PARSERUTILS_OK);
    src = ucs; input = decoded; dst = result; output = sizeof result;
    assert(parserutils_charset_codec_encode(codec, &src, &input, &dst, &output) == PARSERUTILS_OK);
    assert(input == 0 && (size_t)(dst - result) == sizeof text);
    assert(memcmp(result, text, sizeof text) == 0);
    assert(parserutils_charset_codec_destroy(codec) == PARSERUTILS_OK);
    return 0;
}
