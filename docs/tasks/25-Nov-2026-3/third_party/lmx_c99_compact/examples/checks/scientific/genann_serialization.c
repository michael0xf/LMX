/* Text topology/weight roundtrip and activation contract, MIT license. */
#include "genann.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define CHECK(x) do { if (!(x)) { \
    fprintf(stderr, "line %d: %s\n", __LINE__, #x); status = EXIT_FAILURE; goto done; \
} } while (0)

int main(void) {
    genann *ann = NULL, *loaded = NULL;
    FILE *stream = NULL;
    int status = EXIT_SUCCESS, i, j;
    const double inputs[3][2] = {{0.0, 0.0}, {0.25, -0.5}, {1.0, 0.5}};
    double expected[3][2];
    ann = genann_init(2, 2, 3, 2);
    CHECK(ann != NULL);
    for (i = 0; i < ann->total_weights; ++i)
        ann->weight[i] = ((i % 11) - 5) * 0.123456789012345;
    ann->activation_hidden = genann_act_tanh;
    ann->activation_output = genann_act_linear;
    for (i = 0; i < 3; ++i) {
        const double *output = genann_run(ann, inputs[i]);
        for (j = 0; j < 2; ++j) expected[i][j] = output[j];
    }
    stream = tmpfile();
    CHECK(stream != NULL);
    genann_write(ann, stream);
    CHECK(ferror(stream) == 0 && fflush(stream) == 0);
    CHECK(fseek(stream, 0, SEEK_SET) == 0);
    loaded = genann_read(stream);
    CHECK(loaded != NULL && ferror(stream) == 0);
    CHECK(loaded->inputs == ann->inputs && loaded->hidden == ann->hidden &&
          loaded->hidden_layers == ann->hidden_layers && loaded->outputs == ann->outputs);
    CHECK(loaded->total_weights == ann->total_weights);
    for (i = 0; i < loaded->total_weights; ++i)
        CHECK(loaded->weight[i] == ann->weight[i]);

    /* The upstream format does not serialize activation callbacks. Reapply
     * them explicitly when the model uses anything except the defaults. */
    CHECK(loaded->activation_hidden == genann_act_sigmoid_cached);
    CHECK(loaded->activation_output == genann_act_sigmoid_cached);
    loaded->activation_hidden = ann->activation_hidden;
    loaded->activation_output = ann->activation_output;
    for (i = 0; i < 3; ++i) {
        const double *output = genann_run(loaded, inputs[i]);
        for (j = 0; j < 2; ++j)
            CHECK(isfinite(output[j]) && fabs(output[j] - expected[i][j]) < 1e-14);
    }
    puts("Text serialization: topology/weights and 3x2 outputs roundtrip OK; callbacks restored explicitly");
done:
    if (stream != NULL && fclose(stream) != 0) status = EXIT_FAILURE;
    genann_free(loaded);
    genann_free(ann);
    return status;
}
