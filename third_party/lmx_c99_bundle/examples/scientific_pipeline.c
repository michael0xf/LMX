/* C99: deterministic simulation samples, FFT, and a distribution function. */
#include "lmx_scientific.h"
#include <stdio.h>
int main(void)
{
    lmx_rng rng;
    kiss_fft_cpx input[8], spectrum[8];
    kiss_fft_cfg fft;
    unsigned i;
    lmx_rng_seed(&rng, UINT64_C(2026));
    for(i=0;i<8;++i) {
        input[i].r=(kiss_fft_scalar)lmx_rng_uniform(&rng);
        input[i].i=0;
    }
    fft=kiss_fft_alloc(8,0,NULL,NULL);
    if(!fft) {fputs("Cannot allocate FFT\n",stderr);return 1;}
    kiss_fft(fft,input,spectrum);
    printf("Sample mean: %.12g\n",(double)spectrum[0].r/8);
    printf("Normal CDF at 1.96: %.12g\n",lmx_cephes_ndtr(1.96));
    kiss_fft_free(fft);
    return 0;
}
