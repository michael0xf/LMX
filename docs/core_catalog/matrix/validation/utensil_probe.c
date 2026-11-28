#include <stdio.h>
#include <utensil.h>
int utensil_probe(void) {
    int dims[3]={2,2,2};float av[8]={1,0,0,1,2,0,0,2},bv[8]={1,2,3,4,5,6,7,8};
    ut_tensor *a=ut_from_data(3,dims,av,UT_CPU),*b=ut_from_data(3,dims,bv,UT_CPU),*c=ut_matmul(a,b);
    int ok=c&&c->shape.ndim==3&&c->data[0]==1&&c->data[3]==4&&c->data[4]==10&&c->data[7]==16;
    printf("{\"case\":\"utensil_equal_batch_rank3\",\"pass\":%s}\n",ok?"true":"false");
    ut_free(a);ut_free(b);ut_free(c);return !ok;
}
