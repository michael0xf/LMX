#include "conversion_bridge.h"
#include <stdlib.h>
#include <string.h>
#include <math.h>

LmxRefStatus lmx_ref_span(void *storage, size_t length, size_t element_size,
                          size_t offset, size_t count, void **out)
{
    if (!out || !element_size || (length && !storage)) return LMX_REF_ARGUMENT;
    if (offset > length || count > length - offset ||
        length > SIZE_MAX / element_size) return LMX_REF_RANGE;
    /* Avoid arithmetic on NULL for an empty Array. An empty span deliberately
     * maps to NULL: a provider requiring a nonnull sentinel needs its own rule. */
    if (!count) { *out = NULL; return LMX_REF_OK; }
    *out = (void *)((unsigned char *)storage + offset * element_size);
    return LMX_REF_OK;
}

LmxRefStatus lmx_ref_cstring(const char *text, size_t length, char **out)
{
    char *copy;
    if (!out || (length && !text)) return LMX_REF_ARGUMENT;
    if (length == SIZE_MAX) return LMX_REF_RANGE;
    if (length && memchr(text, '\0', length)) return LMX_REF_ENCODING;
    copy = (char *)malloc(length + 1);
    if (!copy) return LMX_REF_ALLOCATION;
    if (length) memcpy(copy, text, length);
    copy[length] = '\0';
    *out = copy;
    return LMX_REF_OK;
}

LmxRefStatus lmx_ref_tensor_extent(const size_t *shape, const size_t *strides,
                                   size_t rank, size_t offset, size_t length,
                                   size_t element_size, size_t *logical_count,
                                   size_t *extent)
{
    size_t i, count = 1, max_index = offset, term;
    int empty = 0;
    if (!logical_count || !extent || !element_size ||
        (rank && (!shape || !strides))) return LMX_REF_ARGUMENT;
    if (offset > length || length > SIZE_MAX / element_size)
        return LMX_REF_RANGE;
    for (i = 0; i < rank; ++i) if (!shape[i]) empty = 1;
    if (empty) { *logical_count = 0; *extent = offset; return LMX_REF_OK; }
    for (i = 0; i < rank; ++i) {
        if (shape[i] > SIZE_MAX / count) return LMX_REF_RANGE;
        count *= shape[i];
        if (shape[i] - 1 && strides[i] > SIZE_MAX / (shape[i] - 1))
            return LMX_REF_RANGE;
        term = (shape[i] - 1) * strides[i];
        if (term > SIZE_MAX - max_index) return LMX_REF_RANGE;
        max_index += term;
    }
    if (max_index >= length) return LMX_REF_RANGE;
    *logical_count = count;
    *extent = max_index + 1;
    return LMX_REF_OK;
}

LmxRefStatus lmx_ref_pcm16_to_float(const int16_t *input, size_t count,
                                    float *output, size_t output_count)
{
    size_t i;
    if ((count && (!input || !output)) || output_count < count)
        return LMX_REF_ARGUMENT;
    for (i = 0; i < count; ++i) output[i] = (float)input[i] / 32768.0f;
    return LMX_REF_OK;
}

LmxRefStatus lmx_ref_float_to_pcm16(const float *input, size_t count,
                                    int16_t *output, size_t output_count)
{
    size_t i;
    if ((count && (!input || !output)) || output_count < count)
        return LMX_REF_ARGUMENT;
    for (i = 0; i < count; ++i) if (!isfinite(input[i])) return LMX_REF_NUMERIC;
    for (i = 0; i < count; ++i) {
        double x = input[i];
        if (x <= -1.0) output[i] = INT16_MIN;
        else if (x >= 32767.0 / 32768.0) output[i] = INT16_MAX;
        else {
            double scaled = x * 32768.0;
            output[i] = (int16_t)(scaled < 0.0 ? ceil(scaled - 0.5) : floor(scaled + 0.5));
        }
    }
    return LMX_REF_OK;
}
