#include "lmx_rng.h"
#include <stdio.h>
#include <string.h>
#define CHECK(x) do {if (!(x)) {fprintf(stderr,"RNG check failed: %s\n",#x); return 1;}} while(0)
int main(void)
{
    const uint64_t expected[] = {
        UINT64_C(12966619160104079557), UINT64_C(9600361134598540522),
        UINT64_C(10590380919521690900), UINT64_C(7218738570589545383),
        UINT64_C(12860671823995680371)
    };
    lmx_rng a, b;
    uint64_t count[4] = {1000,0,0,0};
    unsigned i;
    lmx_rng_seed(&a, 1);
    for(i=0;i<sizeof expected/sizeof expected[0];++i) CHECK(lmx_rng_next(&a)==expected[i]);
    lmx_rng_seed(&a, 0); b=a;
    for(i=0;i<1000;++i) (void)lmx_rng_next(&a);
    lmx_rng_jump_n(&b,count); CHECK(!memcmp(&a,&b,sizeof a));
    lmx_rng_seed(&a, 42); b=a;
    lmx_rng_jump(&a); lmx_rng_jump_ce(&b,1,128); CHECK(!memcmp(&a,&b,sizeof a));
    lmx_rng_seed(&a, 42); b=a;
    lmx_rng_long_jump(&a); lmx_rng_jump_ce(&b,1,192); CHECK(!memcmp(&a,&b,sizeof a));
    for(i=0;i<10000;++i) {double u=lmx_rng_uniform(&a); CHECK(u>=0 && u<1);}
    puts("RNG reference vector, independent states, arbitrary and fixed jumps passed");
    return 0;
}
