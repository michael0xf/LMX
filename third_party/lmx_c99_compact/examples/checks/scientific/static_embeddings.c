#include "lmx_static_embeddings.h"
#include <float.h>
#include <math.h>
#include <stdio.h>

#define CHECK(x) do { if (!(x)) { fprintf(stderr,"Check failed at line %d: %s\n",__LINE__,#x); return 1; } } while (0)
static int near(float x, double y) { return fabs((double)x-y)<0.000002; }
int main(void) {
    static const float values[] = {1,0,0, 0,2,0, 0,0,3, 0,0,0};
    lmx_embedding_table table={values,12,4,3}, bad;
    const uint32_t repeated[]={0,1,1}, invalid[]={0,4}, zero[]={3}, single[]={0};
    float out[4]={99,99,99,77};
    float nonfinite[]={NAN,0,0};
    float large[]={FLT_MAX/2.0f,FLT_MAX/2.0f,0};
    float small[]={FLT_MIN,FLT_MIN,0};
    CHECK(lmx_static_embeddings_encode_ids(&table,repeated,3,0,out,4)==LMX_EMBEDDING_OK);
    CHECK(near(out[0],1.0/3.0)&&near(out[1],4.0/3.0)&&out[2]==0&&out[3]==77);
    CHECK(lmx_static_embeddings_encode_ids(&table,repeated,3,1,out,3)==LMX_EMBEDDING_OK);
    CHECK(near(out[0],1.0/sqrt(17.0))&&near(out[1],4.0/sqrt(17.0)));
    CHECK(near(out[0]*out[0]+out[1]*out[1]+out[2]*out[2],1.0));
    CHECK(lmx_static_embeddings_encode_ids(&table,NULL,0,1,out,3)==LMX_EMBEDDING_OK);
    CHECK(out[0]==0&&out[1]==0&&out[2]==0);
    CHECK(lmx_static_embeddings_encode_ids(&table,zero,1,1,out,3)==LMX_EMBEDDING_OK);
    CHECK(out[0]==0&&out[1]==0&&out[2]==0);
    CHECK(lmx_static_embeddings_encode_ids(&table,invalid,2,0,out,3)==LMX_EMBEDDING_INVALID_TOKEN);
    CHECK(lmx_static_embeddings_encode_ids(&table,NULL,1,0,out,3)==LMX_EMBEDDING_INVALID_ARGUMENT);
    CHECK(lmx_static_embeddings_encode_ids(&table,single,1,0,out,2)==LMX_EMBEDDING_INVALID_ARGUMENT);
    CHECK(lmx_static_embeddings_encode_ids(&table,single,1,2,out,3)==LMX_EMBEDDING_INVALID_ARGUMENT);
    bad=table;bad.vocabulary_size=SIZE_MAX;bad.dimensions=2;
    CHECK(lmx_static_embeddings_encode_ids(&bad,single,1,0,out,3)==LMX_EMBEDDING_INVALID_ARGUMENT);
    bad=table;bad.value_count=11;
    CHECK(lmx_static_embeddings_encode_ids(&bad,single,1,0,out,3)==LMX_EMBEDDING_INVALID_ARGUMENT);
    bad=table;bad.values=nonfinite;bad.value_count=3;bad.vocabulary_size=1;
    CHECK(lmx_static_embeddings_encode_ids(&bad,single,1,0,out,3)==LMX_EMBEDDING_NONFINITE_VALUE);
    bad.values=large;
    CHECK(lmx_static_embeddings_encode_ids(&bad,single,1,1,out,3)==LMX_EMBEDDING_OK);
    CHECK(near(out[0],sqrt(0.5))&&near(out[1],sqrt(0.5))&&out[2]==0);
    bad.values=small;
    CHECK(lmx_static_embeddings_encode_ids(&bad,single,1,1,out,3)==LMX_EMBEDDING_OK);
    CHECK(near(out[0],sqrt(0.5))&&near(out[1],sqrt(0.5))&&out[2]==0);
    CHECK(lmx_embedding_status_string(LMX_EMBEDDING_OK)[0]=='o');
    puts("Static embedding mean/duplicates, L2, empty/zero, invalid IDs/shapes, NaN, extreme magnitudes: passed");
    return 0;
}
