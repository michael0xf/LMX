#include <kann.h>
#ifdef inline
#error "The KANN public header must not redefine the C99 inline keyword"
#endif
#include <math.h>
#include <stdio.h>
#include <string.h>

#define CHECK(c) do { if (!(c)) { \
    fprintf(stderr, "KANN forward/gradient check failed at line %d: %s\n", __LINE__, #c); \
    return 1; } } while (0)

int main(void) {
    const float weights1[6]={0.3f,-0.2f,-0.4f,0.5f,0.7f,0.1f};
    const float bias1[3]={0.1f,-0.2f,0.05f};
    const float weights2[6]={0.2f,-0.3f,0.4f,-0.5f,0.6f,0.1f};
    const float bias2[2]={-0.1f,0.15f};
    float input[2]={0.25f,-0.75f}, target[2]={0,1}, *xp=input, *yp=target;
    float analytic[17], maximum_error=0, cost, plus, minus;
    double hidden_ref[3], logits[2], probability, expected_cost;
    kad_node_t *in, *truth, *w1, *b1, *w2, *b2, *hidden, *output, *loss;
    kann_t *ann;
    int i,j,nvar;
    kann_srand(1234);
    in=kann_layer_input(2);
    w1=kann_new_weight(3,2);b1=kann_new_bias(3);
    hidden=kad_tanh(kad_add(kad_cmul(in,w1),b1));
    w2=kann_new_weight(2,3);b2=kann_new_bias(2);
    output=kad_softmax(kad_add(kad_cmul(hidden,w2),b2));
    output->ext_flag|=KANN_F_OUT;
    truth=kad_feed(2,1,2);truth->ext_flag|=KANN_F_TRUTH;
    loss=kad_ce_multi(output,truth);
    ann=kann_new(loss,0);
    CHECK(ann != NULL);
    memcpy(w1->x,weights1,sizeof(weights1));memcpy(b1->x,bias1,sizeof(bias1));
    memcpy(w2->x,weights2,sizeof(weights2));memcpy(b2->x,bias2,sizeof(bias2));
    CHECK(kann_feed_bind(ann,KANN_F_IN,0,&xp)==1);
    CHECK(kann_feed_bind(ann,KANN_F_TRUTH,0,&yp)==1);
    cost=kann_cost(ann,0,1);
    for(i=0;i<3;++i)
        hidden_ref[i]=tanh((double)weights1[2*i]*input[0]+(double)weights1[2*i+1]*input[1]+bias1[i]);
    for(i=0;i<2;++i){logits[i]=bias2[i];for(j=0;j<3;++j)logits[i]+=(double)weights2[3*i+j]*hidden_ref[j];}
    probability=exp(logits[1])/(exp(logits[0])+exp(logits[1]));
    expected_cost=-log(probability);
    CHECK(fabs(output->x[1]-probability)<2e-6);
    CHECK(fabs(cost-expected_cost)<2e-6);
    nvar=kann_size_var(ann);CHECK(nvar==17);
    memcpy(analytic,ann->g,sizeof(analytic));
    for(i=0;i<nvar;++i){
        const float step=0.001f;
        const float original=ann->x[i];
        float numerical,error;
        ann->x[i]=original+step;plus=kann_cost(ann,0,0);
        ann->x[i]=original-step;minus=kann_cost(ann,0,0);
        ann->x[i]=original;
        numerical=(plus-minus)/(2*step);
        error=fabsf(analytic[i]-numerical);
        if(error>maximum_error)maximum_error=error;
        CHECK(isfinite(numerical) && error < 0.0003f+0.005f*fabsf(numerical));
    }
    printf("independent tanh/softmax forward cost %.9g; all17 finite-difference gradients pass, max abs error %.9g\n",cost,maximum_error);

    /* Check the selected backend with a real four-row batch. */
    {
        float x4[8]={0.25f,-0.75f,-0.1f,0.4f,0.8f,-0.3f,-0.5f,0.2f};
        float y4[8]={0,1,1,0,0,1,1,0};
        float serial_grad[17],serial_output[8],serial_cost,parallel_cost;
        xp=x4;yp=y4;
        kann_set_batch_size(ann,4);
        CHECK(kann_feed_bind(ann,KANN_F_IN,0,&xp)==1);
        CHECK(kann_feed_bind(ann,KANN_F_TRUTH,0,&yp)==1);
        serial_cost=kann_cost(ann,0,1);
        memcpy(serial_grad,ann->g,sizeof(serial_grad));
        memcpy(serial_output,output->x,sizeof(serial_output));
        kann_mt(ann,2,4);
#ifdef LMX_KANN_TEST_PTHREADS
        CHECK(ann->mt != NULL);
#else
        CHECK(ann->mt == NULL);
#endif
        parallel_cost=kann_cost(ann,0,1);
        CHECK(fabsf(serial_cost-parallel_cost)<2e-6f);
        for(i=0;i<nvar;++i)CHECK(fabsf(serial_grad[i]-ann->g[i])<2e-6f);
        i=kann_find(ann,KANN_F_OUT,0);CHECK(i>=0);
        kann_copy_mt(ann,4,i);
        for(j=0;j<8;++j)CHECK(fabsf(ann->v[i]->x[j]-serial_output[j])<2e-6f);
        kann_mt(ann,1,0);
        CHECK(ann->mt==NULL);
#ifdef LMX_KANN_TEST_PTHREADS
        printf("pthread2 batch cost/gradients/output agree with serial; cost %.9g\n",parallel_cost);
#else
        printf("serial fallback preserves batch cost/gradients/output; cost %.9g\n",parallel_cost);
#endif
    }
    kann_delete(ann);
    return 0;
}
