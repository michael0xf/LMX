#include "lmx_cephes.h"
#include <math.h>
#include <stdio.h>
#define NEAR(a,b,t) do { double av=(a), bv=(b); if (!(fabs(av-bv) <= (t))) {fprintf(stderr,"line %d: %.17g != %.17g\n",__LINE__,av,bv); return 1;} } while(0)
int main(void)
{
    unsigned i;
    const double x[] = {0.01, 0.1, 0.5, 1, 2, 10, 100};
    for(i=0;i<sizeof x/sizeof x[0];++i) {
        NEAR(lmx_cephes_log(x[i]), log(x[i]), 2e-14);
        NEAR(lmx_cephes_sqrt(x[i]), sqrt(x[i]), 2e-14);
        NEAR(lmx_cephes_sin(x[i]), sin(x[i]), 2e-14);
        NEAR(lmx_cephes_exp(lmx_cephes_log(x[i])), x[i], 2e-12);
    }
    NEAR(lmx_cephes_j0(0), 1, 1e-15);
    NEAR(lmx_cephes_j1(0), 0, 1e-15);
    NEAR(lmx_cephes_i0(0), 1, 1e-15);
    NEAR(lmx_cephes_k0(1), 0.421024438240708333, 2e-15);
    NEAR(lmx_cephes_gamma(5), 24, 1e-13);
    NEAR(lmx_cephes_lgam(5), log(24), 2e-14);
    NEAR(lmx_cephes_beta(2,3), 1.0/12.0, 2e-15);
    NEAR(lmx_cephes_igam(2,3), 1-4*exp(-3), 2e-14);
    NEAR(lmx_cephes_igam(2,3)+lmx_cephes_igamc(2,3), 1, 2e-14);
    NEAR(lmx_cephes_incbet(2,3,0.5), 0.6875, 2e-14);
    NEAR(lmx_cephes_incbi(2,3,0.6875), 0.5, 2e-14);
    NEAR(lmx_cephes_erf(0.7), erf(0.7), 2e-14);
    NEAR(lmx_cephes_erfc(0.7), erfc(0.7), 2e-14);
    NEAR(lmx_cephes_ndtr(0), 0.5, 2e-15);
    NEAR(lmx_cephes_ndtri(lmx_cephes_ndtr(1.25)), 1.25, 2e-14);
    NEAR(lmx_cephes_stdtr(10,0), 0.5, 2e-15);
    NEAR(lmx_cephes_chdtr(2,2), 1-exp(-1), 2e-14);
    NEAR(lmx_cephes_fdtr(2,2,1), 0.5, 2e-14);
    NEAR(lmx_cephes_pdtr(0,2), exp(-2), 2e-14);
    puts("namespaced Cephes identities and libc comparisons passed");
    return 0;
}
