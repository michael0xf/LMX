#ifndef C99_GSL_H
#define C99_GSL_H

/* Curated C99 mathematics toolbox. This is not GNU GSL's API or ABI.
 * Configuration is supplied by target c99_gsl_lite (alias LMX::math).
 * Do not define ANSI/MP_32BIT yourself: the targets own library configuration.
 */
#include <math.h>
#include <stdint.h>
#include <stddef.h>
#ifndef __cplusplus
#include <complex.h>
#endif

/* Arbitrary precision integers and decimal floating point, respectively.
 * MPDecimal does not implement MPFR's binary arithmetic or full function set.
 */
#include "tommath.h"
#include "mpdecimal.h"

/* Transforms, splines, fitting, special functions, small vector/matrix math,
 * and an explicit-state xoshiro256** generator.
 * Cephes exports use lmx_cephes_*; libc's math functions are not overridden.
 */
#include "lmx_scientific.h"

/* Enabled by default in the complete mathematical target. This uses the
 * current permissive implementations selected instead of GPL Cubature.
 */
#ifdef LMX_MATH_HAS_QUADRATURE
#include "c99_quad.h"
#endif

static inline double c99_gsl_rng_uniform(lmx_rng *rng)
{
    return lmx_rng_uniform(rng);
}

#endif /* C99_GSL_H */
