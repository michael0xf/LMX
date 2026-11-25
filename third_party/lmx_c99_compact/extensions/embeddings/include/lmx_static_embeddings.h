/* SPDX-License-Identifier: MIT
 * Copyright (c) 2026 LMX contributors.
 * A small token-ID pooling primitive, not a tokenizer or Model2Vec loader. */
#ifndef LMX_STATIC_EMBEDDINGS_H
#define LMX_STATIC_EMBEDDINGS_H
#include <stddef.h>
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif

typedef struct lmx_embedding_table {
    const float *values;  /* Row-major [vocabulary_size][dimensions]. */
    size_t value_count;   /* Available float elements, not byte count. */
    size_t vocabulary_size;
    size_t dimensions;
} lmx_embedding_table;

typedef enum lmx_embedding_status {
    LMX_EMBEDDING_OK = 0,
    LMX_EMBEDDING_INVALID_ARGUMENT,
    LMX_EMBEDDING_INVALID_TOKEN,
    LMX_EMBEDDING_NONFINITE_VALUE,
    LMX_EMBEDDING_NUMERIC_RANGE
} lmx_embedding_status;

/* Arithmetic mean of the rows selected by ids, optionally L2-normalized.
 *
 * IDs are already tokenized and filtered by the caller. Repeated IDs count
 * repeatedly. No unknown/special/pad token is treated specially here.
 * normalize must be 0 or 1. An empty sequence returns a zero vector and OK;
 * ids may be NULL only when token_count is zero. A zero mean stays zero.
 * output_count must be at least table->dimensions; extra elements untouched.
 *
 * The output must not overlap the table, table->values or ids. All buffers
 * must actually contain the declared number of elements. The table is read
 * only; no global state, allocation, file access or model download is used.
 * On a non-OK return, output contents are unspecified and must not be used.
 * A double accumulator is used for the mean. Results are C floats,
 * not a promise of bit-identical NumPy/Model2Vec inference.
 */
lmx_embedding_status lmx_static_embeddings_encode_ids(
    const lmx_embedding_table *table,
    const uint32_t *ids, size_t token_count,
    int normalize, float *output, size_t output_count);

const char *lmx_embedding_status_string(lmx_embedding_status status);
#ifdef __cplusplus
}
#endif
#endif
