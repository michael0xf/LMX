#include <lbfgs.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#define CHECK(c) do { if (!(c)) { fprintf(stderr,"L-BFGS check failed: %s\n",#c); exit(1); } } while (0)
static lbfgsfloatval_t evaluate(void *context, const lbfgsfloatval_t *x,
                              lbfgsfloatval_t *g, const int n, const lbfgsfloatval_t step)
{
    lbfgsfloatval_t a = 1-x[0], b = x[1]-x[0]*x[0];
    (void)context; (void)n; (void)step;
    g[0] = -2*a-400*x[0]*b; g[1] = 200*b;
    return a*a+100*b*b;
}
int main(void)
{
    lbfgs_parameter_t p;
    lbfgsfloatval_t *x = lbfgs_malloc(2), objective;
    int status;
    CHECK(x != NULL); x[0] = -1.2; x[1] = 1;
    lbfgs_parameter_init(&p); p.epsilon = 1e-8; p.max_iterations = 1000;
    status = lbfgs(2,x,&objective,evaluate,NULL,NULL,&p);
    CHECK(status >= 0 && objective < 1e-12);
    CHECK(fabs(x[0]-1) < 1e-6 && fabs(x[1]-1) < 1e-6);
    CHECK(lbfgs(0,x,&objective,evaluate,NULL,NULL,&p) == LBFGSERR_INVALID_N);
    lbfgs_free(x);
    puts("PASS: L-BFGS Rosenbrock minimization and invalid dimension");
    return 0;
}
