/* LMX integration fixture, Apache-2.0. */
#include "nnom.h"
#include <stdio.h>
#include <stdlib.h>
#include "test_support.h"

int main(void) {
    int8_t input[3] = {1,2,3};
    int8_t output[2] = {0};
    const int8_t weights[6] = {1,2,0, 0,1,2};
    const int8_t biases[2] = {0,1};
    const nnom_weight_t w = {weights,0};
    const nnom_bias_t b = {biases,0};
    nnom_model_t storage;
    nnom_model_t *model;
    prepare_model_memory();
    model = new_model(&storage);
    nnom_layer_t *in = Input(shape(1,1,3),input);
    nnom_layer_t *dense = Dense(2,&w,&b);
    nnom_layer_t *out = Output(shape(1,1,2),output);
    if (!model || !in || !dense || !out) return EXIT_FAILURE;
    if (!model->hook(dense,in) || !model->hook(out,dense)) return EXIT_FAILURE;
    if (model_compile(model,in,out) != NN_SUCCESS) return EXIT_FAILURE;
    if (model_run(model) != NN_SUCCESS) return EXIT_FAILURE;
    printf("model outputs %d %d (expected 5 9); dense shape rank=%u len=%zu\n",
           output[0],output[1],dense->out->tensor->num_dim,tensor_size(dense->out->tensor));
    if (output[0] != 5 || output[1] != 9 || tensor_size(dense->out->tensor) != 2) return EXIT_FAILURE;
    model_delete(model);
    return check_allocations() ? EXIT_FAILURE : EXIT_SUCCESS;
}
