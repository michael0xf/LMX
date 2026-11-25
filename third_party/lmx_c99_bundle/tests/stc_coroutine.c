#include "stc_test_common.h"
#include <stc/coroutine.h>

struct counter {
    cco_state cco;
    int next;
    int limit;
    int value;
    int cleaned;
};

static int counter_next(struct counter *self) {
    cco_routine(self) {
        for (self->next = 0; self->next < self->limit; ++self->next) {
            self->value = self->next * self->next;
            cco_yield;
        }
        cco_finally:
            self->cleaned = 1;
    }
    return CCO_DONE;
}

int main(void) {
    struct counter counter = {.limit = 4};
    for (int i = 0; i < 4; ++i) {
        CHECK(counter_next(&counter) == CCO_YIELD);
        CHECK(counter.value == i * i && cco_suspended(&counter));
    }
    CHECK(counter_next(&counter) == CCO_DONE);
    CHECK(counter.cleaned && cco_done(&counter));
    struct counter stopped = {.limit = 100};
    CHECK(counter_next(&stopped) == CCO_YIELD);
    cco_stop(&stopped);
    CHECK(counter_next(&stopped) == CCO_DONE);
    CHECK(stopped.cleaned);
    cco_semaphore semaphore = cco_make_semaphore(2);
    cco_acquire_semaphore(&semaphore);
    CHECK(semaphore.count == 1);
    cco_release_semaphore(&semaphore);
    CHECK(semaphore.count == 2);
    /* Exercise the POSIX/Win32 timer dependency without sleeping. */
    CHECK(cco_time() > 0.0);
    return EXIT_SUCCESS;
}
