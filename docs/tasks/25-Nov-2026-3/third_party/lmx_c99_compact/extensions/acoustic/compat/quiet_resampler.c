/* C99 bridge to the official Liquid-DSP resampler. No fork DSP implementation.
 * The public liquid API consumes one input at a time and may emit ceil(rate)
 * samples. Keep that single input's output until the caller has room for it.
 * In particular, never throw away a sample when capacity is one or zero.
 */
#include "quiet_resampler.h"
#include <liquid/liquid.h>
#include <limits.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>

struct lmx_quiet_resamp_s {
    resamp_rrrf core;
    float *samples;
    unsigned int begin;
    unsigned int end;
};

lmx_quiet_resamp lmx_quiet_resamp_create(float rate, unsigned int delay,
    float bandwidth, float attenuation, unsigned int filters)
{
    lmx_quiet_resamp q;
    size_t capacity;
    if (!isfinite(rate) || rate <= 0 || (double)rate > (double)UINT_MAX - 2)
        return NULL;
    capacity = (size_t)ceilf(rate) + 1;
    if (capacity > (size_t)-1 / sizeof(float)) return NULL;
    q = calloc(1, sizeof(*q));
    if (!q) return NULL;
    q->samples = malloc(capacity * sizeof(*q->samples));
    if (!q->samples) { free(q); return NULL; }
    q->core = resamp_rrrf_create(rate, delay, bandwidth, attenuation, filters);
    if (!q->core) { free(q->samples); free(q); return NULL; }
    return q;
}

void lmx_quiet_resamp_destroy(lmx_quiet_resamp q)
{
    if (!q) return;
    resamp_rrrf_destroy(q->core);
    free(q->samples);
    free(q);
}

int lmx_quiet_resamp_pending(lmx_quiet_resamp q)
{
    return q && q->begin < q->end;
}

int lmx_quiet_resamp_execute_output_block(lmx_quiet_resamp q,
    const float *input, unsigned int input_len, unsigned int *input_used,
    float *output, unsigned int output_len, unsigned int *output_used)
{
    unsigned int consumed = 0, written = 0;
    while (written < output_len) {
        unsigned int count;
        if (q->begin == q->end) {
            if (consumed == input_len) break;
            q->begin = 0;
            q->end = 0;
            resamp_rrrf_execute(q->core, input[consumed++], q->samples, &q->end);
        }
        count = q->end - q->begin;
        if (count > output_len - written) count = output_len - written;
        memcpy(output + written, q->samples + q->begin, count * sizeof(*output));
        written += count;
        q->begin += count;
    }
    *input_used = consumed;
    *output_used = written;
    return lmx_quiet_resamp_pending(q);
}
