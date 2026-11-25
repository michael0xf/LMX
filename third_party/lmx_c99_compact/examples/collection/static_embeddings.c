/* This toy table demonstrates pooling, not a trained semantic model. */
#include "lmx_static_embeddings.h"
#include <stdio.h>
int main(void) {
    const float rows[]={1,0,0, 0,1,0, 0,0,1};
    const lmx_embedding_table table={rows,9,3,3};
    const uint32_t already_tokenized[]={0,1,1};
    float vector[3];
    lmx_embedding_status status=lmx_static_embeddings_encode_ids(
        &table,already_tokenized,3,1,vector,3);
    if (status!=LMX_EMBEDDING_OK) {
        fprintf(stderr,"%s\n",lmx_embedding_status_string(status)); return 1;
    }
    printf("Normalized token-ID mean: [%.6f, %.6f, %.6f]\n",vector[0],vector[1],vector[2]);
    return 0;
}
