/* Train a tiny sigmoid curve offline, then save/load the model. No dataset download. */
#include <Tinn.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

static const float inputs[5] = {-1, -0.5f, 0, 0.5f, 1};
static float target(float x) { return 1.0f / (1.0f + expf(-3.0f * x)); }
static double loss(Tinn model)
{
    double sum = 0;
    unsigned int i;
    for (i = 0; i < 5; ++i) {
        double error = xtpredict(model, &inputs[i])[0] - target(inputs[i]);
        sum += 0.5 * error * error;
    }
    return sum / 5;
}

int main(int argc, char **argv)
{
    static const float initial[8] = {-0.8f, -0.3f, 0.4f, 0.9f, -0.7f, -0.2f, 0.2f, 0.6f};
    const char *path = argc > 1 ? argv[1] : "tinn_curve.model";
    Tinn model = xtbuild(1, 4, 1), restored;
    double before, after, prediction_delta = 0, weight_delta = 0;
    unsigned int epoch, i;
    FILE *check;
    for (i = 0; i < 8; ++i) model.w[i] = initial[i];
    model.b[0] = 0.05f; model.b[1] = -0.1f;
    before = loss(model);
    for (epoch = 0; epoch < 2000; ++epoch)
        for (i = 0; i < 5; ++i) {
            unsigned int sample = (i + epoch) % 5;
            float expected = target(inputs[sample]);
            if (!isfinite(xttrain(model, &inputs[sample], &expected, 0.4f))) { xtfree(model); return 1; }
        }
    after = loss(model);
    printf("Tinn deterministic training: loss %.12g -> %.12g\n", before, after);
    if (!(after < before * 0.1 && after < 0.001)) { xtfree(model); return 2; }
    /* The upstream persistence API assumes a valid, writable local path. */
    check = fopen(path, "w");
    if (!check) { perror(path); xtfree(model); return 3; }
    fclose(check);
    xtsave(model, path);
    restored = xtload(path);
    if (restored.nips != model.nips || restored.nhid != model.nhid || restored.nops != model.nops) return 4;
    for (i = 0; i < 8; ++i) {
        double d = fabs((double)model.w[i] - restored.w[i]);
        if (d > weight_delta) weight_delta = d;
    }
    for (i = 0; i < 5; ++i) {
        double a = xtpredict(model, &inputs[i])[0];
        double b = xtpredict(restored, &inputs[i])[0];
        double d = fabs(a - b);
        if (d > prediction_delta) prediction_delta = d;
        printf("x=% .2f target=%.6f trained=%.6f reloaded=%.6f\n",
            (double)inputs[i], (double)target(inputs[i]), a, b);
    }
    printf("Tinn text roundtrip: max_weight_delta=%.9g max_prediction_delta=%.9g\n", weight_delta, prediction_delta);
    xtfree(restored); xtfree(model);
    if (weight_delta > 1e-6 || prediction_delta > 2e-6) return 5;
    puts("training_and_roundtrip=PASS");
    return 0;
}
