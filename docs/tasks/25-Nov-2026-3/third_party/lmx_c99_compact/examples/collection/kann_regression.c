#include <kann.h>
#include <math.h>
#include <stdio.h>

int main(void) {
    float samples[5]={-1,-0.5f,0,0.5f,1},targets[5],*x[5],*y[5],query=0.25f;
    float before,after;
    const float *prediction;
    kad_node_t *node;
    kann_t *ann;
    int i;
    kann_verbose=0;
    kann_srand(42);
    node=kann_layer_input(1);
    node=kann_layer_cost(node,1,KANN_C_MSE);
    ann=kann_new(node,0);
    if(!ann)return 1;
    for(i=0;i<5;++i){targets[i]=2*samples[i]+0.5f;x[i]=samples+i;y[i]=targets+i;}
    before=kann_cost_fnn1(ann,5,x,y);
    kann_train_fnn1(ann,0.01f,5,400,20,0,5,x,y);
    after=kann_cost_fnn1(ann,5,x,y);
    prediction=kann_apply1(ann,&query);
    if(!prediction || !isfinite(after) || after>=before){kann_delete(ann);return 1;}
    printf("KANN %s: loss %.6g -> %.6g, prediction for0.25 = %.6g (target1.0)\n",KANN_VERSION,before,after,prediction[0]);
    kann_delete(ann);
    return 0;
}
