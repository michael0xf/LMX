#include "check.h"
#include "cute_sync.h"
static void task(void *p){cute_atomic_add((cute_atomic_int_t*)p,1);}
int main(void) {
    cute_atomic_int_t count={0}; cute_threadpool_t *pool; cute_rw_lock_t lock; int i, a, b; void *pointer=&a;
    cute_atomic_set(&count,0); pool=cute_threadpool_create(3,NULL); REQUIRE(pool);
    for(i=0;i<300;++i)cute_threadpool_add_task(pool,task,&count);
    cute_threadpool_kick_and_wait(pool); REQUIRE(cute_atomic_get(&count)==300);
    cute_threadpool_destroy(pool); REQUIRE(cute_atomic_cas(&count,300,7)); REQUIRE(cute_atomic_get(&count)==7);
    REQUIRE(!cute_atomic_cas(&count,300,7)); REQUIRE(cute_atomic_get(&count)==7);
    REQUIRE(cute_atomic_ptr_cas(&pointer,&a,&b)); REQUIRE(pointer==&b);
    REQUIRE(!cute_atomic_ptr_cas(&pointer,&a,&b)); REQUIRE(pointer==&b);
    lock=cute_rw_lock_create(); cute_read_lock(&lock);cute_read_unlock(&lock);cute_write_lock(&lock);cute_write_unlock(&lock);cute_rw_lock_destroy(&lock);
    puts("cute_sync: threadpool/atomics/rwlock PASS");return 0;
}
