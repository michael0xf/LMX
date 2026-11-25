#include <stdio.h>
#include <string.h>
#include "kthread.h"
#define CHECK(x) do { if (!(x)) { fprintf(stderr, "%s:%d: %s\n", __FILE__, __LINE__, #x); return 1; } } while (0)
#define WORKERS 4
#define ITEMS 4096

typedef struct { long long sum[WORKERS]; } work_t;
static void sum_item(void *opaque, long index, int worker)
{
    work_t *work = (work_t *)opaque;
    work->sum[worker] += index + 1;
}
static long long sum_all(const work_t *work)
{
    int i;
    long long total = 0;
    for (i = 0; i < WORKERS; ++i) total += work->sum[i];
    return total;
}

typedef struct { int emitted, consumed, values[64]; long sum; } pipeline_t;
static void *pipeline_step(void *opaque, int step, void *data)
{
    pipeline_t *pipeline = (pipeline_t *)opaque;
    if (step == 0) {
        int index = pipeline->emitted;
        if (index == 64) return NULL;
        pipeline->values[index] = index + 1;
        ++pipeline->emitted;
        return &pipeline->values[index];
    }
    if (step == 1) {
        *(int *)data *= 2;
        return data;
    }
    pipeline->sum += *(int *)data;
    ++pipeline->consumed;
    return NULL;
}

int main(void)
{
    work_t work = {{0}};
    pipeline_t pipeline = {0};
    void *pool;
    const long long expected = (long long)ITEMS * (ITEMS + 1) / 2;
    kt_for(WORKERS, sum_item, &work, ITEMS);
    CHECK(sum_all(&work) == expected);
    pool = kt_forpool_init(WORKERS);
    CHECK(pool != NULL);
    memset(&work, 0, sizeof(work));
    kt_forpool(pool, sum_item, &work, ITEMS);
    CHECK(sum_all(&work) == expected);
    memset(&work, 0, sizeof(work));
    kt_forpool(pool, sum_item, &work, ITEMS / 2);
    CHECK(sum_all(&work) == (long long)(ITEMS / 2) * (ITEMS / 2 + 1) / 2);
    kt_forpool_destroy(pool);
    kt_pipeline(3, pipeline_step, &pipeline, 3);
    CHECK(pipeline.emitted == 64 && pipeline.consumed == 64);
    CHECK(pipeline.sum == 64L * 65L);
    return 0;
}
