/* Private libquiet compatibility API; public quiet.h remains source compatible. */
#ifndef LMX_QUIET_RESAMPLER_H
#define LMX_QUIET_RESAMPLER_H
typedef struct lmx_quiet_resamp_s *lmx_quiet_resamp;
lmx_quiet_resamp lmx_quiet_resamp_create(float rate, unsigned int delay,
    float bandwidth, float attenuation, unsigned int filters);
void lmx_quiet_resamp_destroy(lmx_quiet_resamp q);
int lmx_quiet_resamp_pending(lmx_quiet_resamp q);
int lmx_quiet_resamp_execute_output_block(lmx_quiet_resamp q,
    const float *input, unsigned int input_len, unsigned int *input_used,
    float *output, unsigned int output_len, unsigned int *output_used);
#endif
