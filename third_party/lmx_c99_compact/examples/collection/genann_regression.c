/* Deterministic Genann API example, MIT license. */
#include "genann.h"
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    genann *ann = genann_init(1, 0, 0, 1);
    int epoch, i;
    const double query = 0.3;
    if (ann == NULL) {
        fputs("Cannot allocate a Genann network\n", stderr);
        return EXIT_FAILURE;
    }
    ann->activation_output = genann_act_linear;
    ann->weight[0] = 0.0;
    ann->weight[1] = 0.0;
    for (epoch = 0; epoch < 200; ++epoch) {
        for (i = -2; i <= 2; ++i) {
            const double x = i * 0.5;
            const double desired = 0.75 * x + 0.25;
            genann_train(ann, &x, &desired, 0.1);
        }
    }
    printf("Learned y = 0.75*x + 0.25; x=%.1f -> y=%.12f\n",
           query, genann_run(ann, &query)[0]);
    puts("Weights can be saved with genann_write(ann, FILE*).\n"
         "After genann_read(), restore activation_output = genann_act_linear.");
    genann_free(ann);
    return EXIT_SUCCESS;
}
