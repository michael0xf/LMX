#define _XOPEN_SOURCE 700
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>
#include "khmm.h"
#include "knetfile.h"
#include "ksort.h"
#include "lmx/kopen.h"
#define CHECK(x) do { if (!(x)) { fprintf(stderr, "%s:%d: %s\n", __FILE__, __LINE__, #x); return 1; } } while (0)
KSORT_INIT(sort, int, ks_lt_generic)
int main(void)
{
    int values[] = {4, 1, 3, 2}, i, fd;
    char text[] = "local transport\n", buffer[32] = {0};
    char path[] = "klib-posix-XXXXXX";
    knetFile *file;
    void *handle;
    hmm_par_t *model = hmm_new_par(2, 1);
    char observed[] = {0, 1, 0};
    hmm_data_t *data;
    char *simulated;
    CHECK(model != NULL);
    model->a0[0] = model->a[0][0] = 1.0;
    model->e[0][0] = model->e[1][0] = 0.5;
    data = hmm_new_data(3, observed, model);
    CHECK(data != NULL);
    hmm_forward(model, data);
    CHECK(fabs(hmm_lk(data) - 3.0 * log(0.5)) < 1e-8);
    hmm_pre_backward(model);
    hmm_backward(model, data);
    srand48(42);
    simulated = hmm_simulate(model, 8);
    CHECK(simulated != NULL);
    for (i = 0; i < 8; ++i) CHECK(simulated[i] == 0 || simulated[i] == 1);
    free(simulated);
    hmm_delete_data(data);
    hmm_delete_par(model);
    ks_introsort(sort, 4, values);
    for (i = 0; i < 4; ++i) CHECK(values[i] == i + 1);
    ks_shuffle(sort, 4, values);
    ks_heapmake(sort, 4, values);
    ks_heapsort(sort, 4, values);
    for (i = 0; i < 4; ++i) CHECK(values[i] == i + 1);
    fd = mkstemp(path);
    CHECK(fd >= 0);
    CHECK(write(fd, text, strlen(text)) == (ssize_t)strlen(text));
    CHECK(close(fd) == 0);
    file = knet_open(path, "r");
    CHECK(file != NULL);
    CHECK(knet_read(file, buffer, (off_t)strlen(text)) == (off_t)strlen(text));
    CHECK(strcmp(buffer, text) == 0);
    CHECK(knet_close(file) == 0);
    memset(buffer, 0, sizeof(buffer));
    handle = kopen(path, &fd);
    CHECK(handle != NULL && fd >= 0);
    CHECK(read(fd, buffer, sizeof(buffer)) == (ssize_t)strlen(text));
    CHECK(strcmp(buffer, text) == 0);
    CHECK(kclose(handle) == 0);
    CHECK(unlink(path) == 0);
    return 0;
}
