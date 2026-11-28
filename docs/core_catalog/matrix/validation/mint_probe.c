#include <stdio.h>
#define MT_IMPLEMENTATION
#include <mint.h>
int mint_probe(void) {
    int sa[2]={2,3},sb[2]={3,2};float av[6]={1,2,3,4,5,6},bv[6]={7,8,9,10,11,12};
    mt_tensor *a=mt_tensor_alloc_values(sa,2,av),*b=mt_tensor_alloc_values(sb,2,bv),*c=mt_matmul(a,b);
    int ok=c&&c->ndim==2&&c->shape[0]==2&&c->shape[1]==2&&c->data[0]==58&&c->data[1]==64&&c->data[2]==139&&c->data[3]==154;
    printf("{\"case\":\"mint_rank2_matmul\",\"pass\":%s}\n",ok?"true":"false");
    mt_tensor_free(a);mt_tensor_free(b);mt_tensor_free(c);return !ok;
}
