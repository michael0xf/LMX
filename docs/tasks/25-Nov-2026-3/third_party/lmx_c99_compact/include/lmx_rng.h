#ifndef LMX_RNG_H
#define LMX_RNG_H
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
/* Reproducible non-cryptographic PRNG. For keys/tokens use libsodium. */
typedef struct { uint64_t state[4]; } lmx_rng;
/* Seed before first use; SplitMix64 expands any 64-bit seed to a valid state. */
void lmx_rng_seed(lmx_rng *rng, uint64_t seed);
uint64_t lmx_rng_next(lmx_rng *rng);
void lmx_rng_jump(lmx_rng *rng);
void lmx_rng_long_jump(lmx_rng *rng);
void lmx_rng_jump_ce(lmx_rng *rng, uint64_t c, uint32_t e);
void lmx_rng_jump_n(lmx_rng *rng, const uint64_t jump[4]);
/* Uniform dyadic double in [0, 1), using the high 53 bits. */
double lmx_rng_uniform(lmx_rng *rng);
#ifdef __cplusplus
}
#endif
#endif
