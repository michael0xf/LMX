#include "tinycthread.h"
#include "check.h"
static mtx_t lock;
static int total;
static int worker(void *p) {
    int i, n = *(int *)p;
    for (i = 0; i < n; ++i) {
        if (mtx_lock(&lock) != thrd_success) return 1;
        ++total;
        if (mtx_unlock(&lock) != thrd_success) return 2;
    }
    return 7;
}
int main(void) {
    thrd_t a, b; int n = 10000, ra, rb;
    CHECK(mtx_init(&lock, mtx_plain) == thrd_success);
    CHECK(thrd_create(&a, worker, &n) == thrd_success); CHECK(thrd_create(&b, worker, &n) == thrd_success);
    CHECK(thrd_join(a, &ra) == thrd_success && thrd_join(b, &rb) == thrd_success);
    mtx_destroy(&lock); CHECK(ra == 7 && rb == 7 && total == 2*n);
    puts("TinyCThread two workers + mutex + join return values: OK"); return 0;
}
