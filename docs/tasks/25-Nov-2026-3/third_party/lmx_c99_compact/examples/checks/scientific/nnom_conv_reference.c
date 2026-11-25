/* LMX integration fixture, Apache-2.0. */
#include "nnom.h"
#include <stdio.h>
#include <stdlib.h>
#include "test_support.h"

static int round_shift2(int sum) {
    sum += 2;
    return sum >= 0 ? sum / 4 : -((-sum + 3) / 4);
}

int main(void) {
    int8_t input[12] = {-6,2,3,4, 5,-4,7,8, 9,10,-2,12};
    int8_t output[12] = {0};
    const int8_t weights[8] = {1,-2,0,1, -1,0,2,1};
    const int8_t biases[2] = {-2,3};
    const nnom_weight_t w = {weights,2};
    const nnom_bias_t b = {biases,0};
    nnom_model_t storage;
    nnom_model_t *model;
    prepare_model_memory();
    model = new_model(&storage);
    nnom_layer_t *in = Input(shape(3,4,1),input);
    nnom_layer_t *conv = Conv2D(2,kernel(2,2),stride(1,1),dilation(1,1),PADDING_VALID,&w,&b);
    nnom_layer_t *out = Output(shape(2,3,2),output);
    int fail = 0;
    if (!model || !in || !conv || !out) return EXIT_FAILURE;
    if (!model->hook(conv,in) || !model->hook(out,conv)) return EXIT_FAILURE;
    if (model_compile(model,in,out) != NN_SUCCESS) return EXIT_FAILURE;
    if (conv->out->tensor->dim[0] != 2 || conv->out->tensor->dim[1] != 3 ||
        conv->out->tensor->dim[2] != 2 || tensor_size(conv->out->tensor) != 12)
        return EXIT_FAILURE;
    for (int run = 0; run < 2; ++run) {
        if (model_run(model) != NN_SUCCESS) return EXIT_FAILURE;
        for (int y = 0; y < 2; ++y) for (int x = 0; x < 3; ++x) for (int ch = 0; ch < 2; ++ch) {
            int sum = biases[ch];
            int expected;
            int index = (y*3+x)*2+ch;
            for (int ky = 0; ky < 2; ++ky) for (int kx = 0; kx < 2; ++kx)
                sum += input[(y+ky)*4+x+kx] * weights[ch*4+ky*2+kx];
            expected = round_shift2(sum);
            if (expected < -128) expected = -128;
            if (expected > 127) expected = 127;
            printf("conv run %d cell %d: expected %d actual %d\n",run,index,expected,output[index]);
            if (expected != output[index]) fail = 1;
        }
        for (int i = 0; i < 12; ++i) input[i] = -input[i];
    }
    model_delete(model);
    return fail || check_allocations() ? EXIT_FAILURE : EXIT_SUCCESS;
}
