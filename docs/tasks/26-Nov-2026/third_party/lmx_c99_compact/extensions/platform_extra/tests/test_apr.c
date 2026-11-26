/* Offline C99 checks: allocator ownership, data structures, files, and threads. */
#include <apr_general.h>
#include <apr_pools.h>
#include <apr_hash.h>
#include <apr_tables.h>
#include <apr_strings.h>
#include <apr_file_io.h>
#include <apr_thread_proc.h>
#include <apr_thread_mutex.h>
#include <stdio.h>
#include <string.h>
#define CHECK(x) do { if (!(x)) { fprintf(stderr,"APR check failed at %d: %s\n",__LINE__,#x); return 1; } } while(0)
typedef struct { apr_thread_mutex_t *lock; int count; } Counter;
static void *APR_THREAD_FUNC increment(apr_thread_t *thread, void *data) {
    Counter *c = data; int i;
    for (i=0;i<1000;++i) { apr_thread_mutex_lock(c->lock); ++c->count; apr_thread_mutex_unlock(c->lock); }
    apr_thread_exit(thread, APR_SUCCESS); return NULL;
}
int main(void) {
    apr_pool_t *p; apr_hash_t *h; apr_array_header_t *a; apr_table_t *t;
    apr_file_t *f; char path[]="lmx-apr-XXXXXX"; char buf[16]={0}; apr_size_t n;
    Counter c; apr_thread_t *threads[2]; apr_status_t status; int i;
    CHECK(apr_initialize()==APR_SUCCESS); CHECK(apr_pool_create(&p,NULL)==APR_SUCCESS);
    h=apr_hash_make(p); apr_hash_set(h,"key",APR_HASH_KEY_STRING,"value");
    CHECK(strcmp(apr_hash_get(h,"key",APR_HASH_KEY_STRING),"value")==0);
    a=apr_array_make(p,1,sizeof(int)); *(int *)apr_array_push(a)=17; *(int *)apr_array_push(a)=25;
    CHECK(a->nelts==2 && ((int *)a->elts)[0]+((int *)a->elts)[1]==42);
    t=apr_table_make(p,1); apr_table_set(t,"Case","preserved"); CHECK(strcmp(apr_table_get(t,"CASE"),"preserved")==0);
    CHECK(apr_file_mktemp(&f,path,APR_CREATE|APR_READ|APR_WRITE|APR_EXCL,p)==APR_SUCCESS);
    CHECK(apr_file_write_full(f,"moon\n",5,&n)==APR_SUCCESS && n==5); CHECK(apr_file_close(f)==APR_SUCCESS);
    CHECK(apr_file_open(&f,path,APR_READ,APR_OS_DEFAULT,p)==APR_SUCCESS);
    CHECK(apr_file_read_full(f,buf,5,&n)==APR_SUCCESS && n==5 && memcmp(buf,"moon\n",5)==0);
    CHECK(apr_file_close(f)==APR_SUCCESS); CHECK(apr_file_remove(path,p)==APR_SUCCESS);
    c.count=0; CHECK(apr_thread_mutex_create(&c.lock,APR_THREAD_MUTEX_DEFAULT,p)==APR_SUCCESS);
    for(i=0;i<2;++i) CHECK(apr_thread_create(&threads[i],NULL,increment,&c,p)==APR_SUCCESS);
    for(i=0;i<2;++i) CHECK(apr_thread_join(&status,threads[i])==APR_SUCCESS && status==APR_SUCCESS);
    CHECK(c.count==2000); apr_pool_destroy(p); apr_terminate(); puts("APR pools/hash/table/file/thread OK"); return 0;
}
