#include <kann.h>
#include <math.h>
#include <stdio.h>
#include <string.h>

#define CHECK(c) do { if (!(c)) { \
    fprintf(stderr, "KANN training/serialization check failed at line %d: %s\n", __LINE__, #c); \
    return 1; } } while (0)

int main(void) {
    float values[8]={-1,-0.75f,-0.5f,-0.25f,0.25f,0.5f,0.75f,1};
    float truth[8],*x[8],*y[8],saved_output[8];
    float before,after;
    kad_node_t *node;
    kann_t *ann,*repeat,*loaded;
    FILE *file;
    int i,nvar;
    kann_verbose=0;
    kann_srand(81723);
    node=kann_layer_input(1);
    node=kad_tanh(kann_layer_dense(node,4));
    node=kann_layer_cost(node,1,KANN_C_MSE);
    ann=kann_new(node,0);CHECK(ann!=NULL);
    nvar=kann_size_var(ann);
    for(i=0;i<8;++i){truth[i]=0.6f*values[i]-0.2f;x[i]=&values[i];y[i]=&truth[i];}
    repeat=kann_clone(ann,1);CHECK(repeat!=NULL);
    before=kann_cost_fnn1(ann,8,x,y);
    kann_srand(192837);
    CHECK(kann_train_fnn1(ann,0.005f,3,250,20,0,8,x,y)==250);
    after=kann_cost_fnn1(ann,8,x,y);
    CHECK(isfinite(after) && after<0.002f && after<before*0.02f);
    kann_srand(192837);
    CHECK(kann_train_fnn1(repeat,0.005f,3,250,20,0,8,x,y)==250);
    CHECK(memcmp(ann->x,repeat->x,(size_t)nvar*sizeof(float))==0);
    for(i=0;i<8;++i){const float *out=kann_apply1(ann,x[i]);CHECK(out!=NULL);saved_output[i]=out[0];}
    file=tmpfile();CHECK(file!=NULL);
    kann_save_fp(file,ann);CHECK(fflush(file)==0 && !ferror(file));
    rewind(file);
    loaded=kann_load_fp(file);CHECK(loaded!=NULL);
    CHECK(fclose(file)==0);
    CHECK(kann_size_var(loaded)==nvar && kann_dim_in(loaded)==1 && kann_dim_out(loaded)==1);
    CHECK(memcmp(ann->x,loaded->x,(size_t)nvar*sizeof(float))==0);
    for(i=0;i<8;++i){const float *out=kann_apply1(loaded,x[i]);CHECK(out!=NULL && memcmp(&saved_output[i],out,sizeof(float))==0);}
    printf("deterministic tanh MLP training with mini-batch3: loss %.9g -> %.9g; repeat weights exact; saved/loaded weights and8 outputs exact\n",before,after);
    kann_delete(loaded);kann_delete(repeat);kann_delete(ann);
    return 0;
}
