#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include "c99_quad.h"

static int check_moment(int n, int count, const double *x, const double *w,
    int degree, int a, int b, int c, double exact)
{
    double integral = 0;
    int j;
    for (j = 0; j < count; ++j) {
        double value = 1;
        if (degree > 0) value *= x[a+j*n];
        if (degree > 1) value *= x[b+j*n];
        if (degree > 2) value *= x[c+j*n];
        integral += w[j]*value;
    }
    if (fabs(integral-exact) > 1e-12*(1+fabs(exact))) {
        fprintf(stderr, "n=%d degree=%d indices=%d,%d,%d: %.17g expected %.17g\n",
            n, degree, a, b, c, integral, exact);
        return 0;
    }
    return 1;
}

int main(void)
{
    double nodes[7*14], weights[14];
    int n, variant, a, b, c, count, cases = 0;
    for (variant = 0; variant < 2; ++variant) for (n = 1; n <= 7; ++n) {
        double volume = ldexp(1.0, n);
        count = variant ? lmx_stroud_cn_leg_03_xiu_size(n) : lmx_stroud_cn_leg_03_1_size(n);
        if (count != 2*n) return 1;
        if (variant) lmx_stroud_cn_leg_03_xiu(n, count, nodes, weights);
        else lmx_stroud_cn_leg_03_1(n, count, nodes, weights);
        /* Independent product-integral oracle over [-1,1]^n:
         * any odd exponent gives zero; integral 1=2^n; integral x_i^2=2^n/3.
         */
        if (!check_moment(n,count,nodes,weights,0,0,0,0,volume)) return 2;
        ++cases;
        for (a = 0; a < n; ++a) {
            if (!check_moment(n,count,nodes,weights,1,a,0,0,0)) return 3;
            ++cases;
            for (b = a; b < n; ++b) {
                if (!check_moment(n,count,nodes,weights,2,a,b,0,a==b ? volume/3 : 0)) return 4;
                ++cases;
                for (c = b; c < n; ++c) {
                    if (!check_moment(n,count,nodes,weights,3,a,b,c,0)) return 5;
                    ++cases;
                }
            }
        }
    }
    printf("Stroud: %d independent polynomial moments passed for both rules, dimensions 1..7\n", cases);
    return EXIT_SUCCESS;
}
