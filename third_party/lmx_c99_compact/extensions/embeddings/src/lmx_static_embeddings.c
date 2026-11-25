/* SPDX-License-Identifier: MIT
 * Copyright (c) 2026 LMX contributors. */
#include "lmx_static_embeddings.h"
#include <float.h>
#include <math.h>

lmx_embedding_status lmx_static_embeddings_encode_ids(
    const lmx_embedding_table *table,
    const uint32_t *ids, size_t token_count,
    int normalize, float *output, size_t output_count) {
    size_t required, i, d;
    double scale = 0.0;
    if (!table || !output || !table->values || table->dimensions == 0 ||
        table->vocabulary_size == 0 || output_count < table->dimensions ||
        (normalize != 0 && normalize != 1) || (token_count && !ids)) {
        return LMX_EMBEDDING_INVALID_ARGUMENT;
    }
    if (table->dimensions > SIZE_MAX / sizeof(float) ||
        table->vocabulary_size > SIZE_MAX / table->dimensions ||
        token_count > SIZE_MAX / sizeof(uint32_t)) {
        return LMX_EMBEDDING_INVALID_ARGUMENT;
    }
    required = table->vocabulary_size * table->dimensions;
    if (required > SIZE_MAX / sizeof(float) || table->value_count < required) {
        return LMX_EMBEDDING_INVALID_ARGUMENT;
    }
    for (i = 0; i < token_count; ++i) {
        if ((uintmax_t)ids[i] >= (uintmax_t)table->vocabulary_size) return LMX_EMBEDDING_INVALID_TOKEN;
    }
    if (token_count == 0) {
        for (d = 0; d < table->dimensions; ++d) output[d] = 0.0f;
        return LMX_EMBEDDING_OK;
    }
    for (d = 0; d < table->dimensions; ++d) {
        double sum = 0.0, mean;
        for (i = 0; i < token_count; ++i) {
            float value = table->values[(size_t)ids[i] * table->dimensions + d];
            if (!isfinite(value)) return LMX_EMBEDDING_NONFINITE_VALUE;
            sum += (double)value;
        }
        mean = sum / (double)token_count;
        if (!isfinite(mean) || mean > FLT_MAX || mean < -FLT_MAX) {
            return LMX_EMBEDDING_NUMERIC_RANGE;
        }
        output[d] = (float)mean;
        if (fabs((double)output[d]) > scale) scale = fabs((double)output[d]);
    }
    if (normalize && scale != 0.0) {
        double sum_of_squares = 0.0, denominator;
        /* Scale before squaring: avoid overflow/underflow for float vectors. */
        for (d = 0; d < table->dimensions; ++d) {
            double unit = (double)output[d] / scale;
            sum_of_squares += unit * unit;
        }
        denominator = sqrt(sum_of_squares);
        if (!isfinite(denominator) || denominator == 0.0) return LMX_EMBEDDING_NUMERIC_RANGE;
        for (d = 0; d < table->dimensions; ++d) {
            output[d] = (float)(((double)output[d] / scale) / denominator);
        }
    }
    return LMX_EMBEDDING_OK;
}

const char *lmx_embedding_status_string(lmx_embedding_status status) {
    switch (status) {
    case LMX_EMBEDDING_OK: return "ok";
    case LMX_EMBEDDING_INVALID_ARGUMENT: return "invalid argument or matrix shape";
    case LMX_EMBEDDING_INVALID_TOKEN: return "token ID outside vocabulary";
    case LMX_EMBEDDING_NONFINITE_VALUE: return "non-finite selected embedding value";
    case LMX_EMBEDDING_NUMERIC_RANGE: return "numeric result outside supported range";
    default: return "unknown embedding status";
    }
}
