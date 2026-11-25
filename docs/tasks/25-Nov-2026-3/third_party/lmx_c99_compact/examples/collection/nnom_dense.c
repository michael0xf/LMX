/* A manually described quantized model; Apache-2.0. No Python is required. */
#include "nnom.h"
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    int8_t input[3] = {1, 2, 3};
    int8_t output[2] = {0};
    /* With fewer than four output neurons, the optimized dense layout is
     * ordinary output-row order. Larger models must use the documented x4
     * packing from upstream scripts/fully_connected_opt_weight_generation.py. */
    static const int8_t weights[6] = {1, 2, 0, 0, 1, 2};
    static const int8_t biases[2] = {0, 1};
    const nnom_weight_t w = {weights, 0};
    const nnom_bias_t b = {biases, 0};
    nnom_model_t storage;
    nnom_model_t *model;
    nnom_layer_t *in, *dense, *out;
#ifdef NNOM_USING_STATIC_MEMORY
    static union {
        double align_double;
        uint64_t align_u64;
        void *align_pointer;
        unsigned char bytes[8192];
    } arena;
    nnom_set_static_buf(arena.bytes, sizeof(arena.bytes));
#endif
    model = new_model(&storage);
    in = Input(shape(1, 1, 3), input);
    dense = Dense(2, &w, &b);
    out = Output(shape(1, 1, 2), output);
    if (model == NULL || in == NULL || dense == NULL || out == NULL) {
        fputs("NNoM model construction failed\n", stderr);
        return EXIT_FAILURE;
    }
    if (model->hook(dense, in) == NULL || model->hook(out, dense) == NULL ||
        model_compile(model, in, out) != NN_SUCCESS ||
        model_run(model) != NN_SUCCESS) {
        fputs("NNoM model compilation/inference failed\n", stderr);
        return EXIT_FAILURE;
    }
    printf("Raw quantized output: %d, %d (expected 5, 9)\n", output[0], output[1]);
    model_delete(model);
    return output[0] == 5 && output[1] == 9 ? EXIT_SUCCESS : EXIT_FAILURE;
}
