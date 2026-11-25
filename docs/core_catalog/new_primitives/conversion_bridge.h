#ifndef LMX_REFERENCE_CONVERSION_BRIDGE_H
#define LMX_REFERENCE_CONVERSION_BRIDGE_H
#include "primitive_runtime.h"

/* These C functions receive trusted, already resolved Array metadata. They do
 * not accept unchecked user pointers or infer an Array's type from an address. */
LmxRefStatus lmx_ref_span(void *storage, size_t length, size_t element_size,
                          size_t offset, size_t count, void **out);
LmxRefStatus lmx_ref_cstring(const char *text, size_t length, char **out);
/* Returns addressed element extent including offset; strides are nonnegative
 * element strides. Rank zero is one scalar; an empty dimension is no data. */
LmxRefStatus lmx_ref_tensor_extent(const size_t *shape, const size_t *strides,
                                   size_t rank, size_t offset, size_t length,
                                   size_t element_size, size_t *logical_count,
                                   size_t *extent);
/* Inputs and outputs must be disjoint, correctly aligned actual typed Arrays.
 * The native resolver checks descriptor ownership and dtype before this call. */
LmxRefStatus lmx_ref_pcm16_to_float(const int16_t *input, size_t count,
                                    float *output, size_t output_count);
LmxRefStatus lmx_ref_float_to_pcm16(const float *input, size_t count,
                                    int16_t *output, size_t output_count);
#endif
