/* Representative CPU tensor operations, independent expected values. */
#define MT_IMPLEMENTATION
#include <mint.h>
#include <stdio.h>
#include <math.h>

static int check(mt_tensor *t, int rank, const int *shape, const float *data, int count)
{
    int i;
    if (!t || t->ndim != rank || mt_tensor_count_element(t) != count) return 0;
    for (i=0;i<rank;i++) if(t->shape[i] != shape[i]) return 0;
    for (i=0;i<count;i++) if(fabsf(t->data[i]-data[i]) > 1e-5f) return 0;
    return 1;
}
#define CHECK(x) do { if(!(x)) { fprintf(stderr,"Mint sample check failed at line %d\n",__LINE__); return 1; } } while(0)
int main(void)
{
    int a_shape[2]={2,3}, b_shape[1]={3}, m_shape[2]={3,2};
    float a_data[6]={1,2,3,4,5,6}, b_data[3]={10,20,30};
    float m_data[6]={1,2,3,4,5,6}, sum_data[6]={11,22,33,14,25,36};
    float product_data[4]={22,28,49,64}, scalar_value[1]={2};
    int product_shape[2]={2,2};
    mt_tensor *a=mt_tensor_alloc_values(a_shape,2,a_data);
    mt_tensor *b=mt_tensor_alloc_values(b_shape,1,b_data);
    mt_tensor *m=mt_tensor_alloc_values(m_shape,2,m_data);
    mt_tensor *sum=mt_add(a,b), *reverse=mt_add(b,a), *product=mt_matmul(a,m);
    mt_tensor *scalar=mt_tensor_alloc_values(b_shape,0,scalar_value);
    mt_tensor *left=mt_add(scalar,b), *right=mt_add(b,scalar);
    float scalar_sum[3]={12,22,32};
    CHECK(check(sum,2,a_shape,sum_data,6)); CHECK(check(reverse,2,a_shape,sum_data,6));
    CHECK(check(product,2,product_shape,product_data,4));
    CHECK(check(left,1,b_shape,scalar_sum,3)); CHECK(check(right,1,b_shape,scalar_sum,3));
    { int one_shape[2]={1,1}, expected_shape[2]={1,3};
      mt_tensor *one=mt_tensor_alloc_values(one_shape,2,scalar_value);
      mt_tensor *result=mt_add(b,one), *rev=mt_add(one,b);
      CHECK(check(result,2,expected_shape,scalar_sum,3));
      CHECK(check(rev,2,expected_shape,scalar_sum,3));
      mt_tensor_free(one); mt_tensor_free(result); mt_tensor_free(rev); }
    { int shape4[4]={2,1,2,3}; float data4[12]={1,2,3,4,5,6,7,8,9,10,11,12};
      float wanted4[12]={11,22,33,14,25,36,17,28,39,20,31,42};
      mt_tensor *a4=mt_tensor_alloc_values(shape4,4,data4), *r4=mt_add(a4,b);
      CHECK(check(r4,4,shape4,wanted4,12)); mt_tensor_free(a4); mt_tensor_free(r4); }
    { mt_tensor *r=mt_min(b,0,0); float expected[1]={10};
      CHECK(check(r,0,NULL,expected,1)); mt_tensor_free(r); }
    mt_tensor_free(a);mt_tensor_free(b);mt_tensor_free(m);mt_tensor_free(sum);
    mt_tensor_free(reverse);mt_tensor_free(product);mt_tensor_free(scalar);
    mt_tensor_free(left);mt_tensor_free(right);
    puts("Mint: broadcast, rank-zero scalars, matmul and reduction passed");
    return 0;
}
