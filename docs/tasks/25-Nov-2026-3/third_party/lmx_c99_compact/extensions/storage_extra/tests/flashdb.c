/* SPDX-License-Identifier: 0BSD */
#include "flashdb.h"
#include "lmx_flashdb_callbacks.h"
#include "check.h"
#include <string.h>
static unsigned lock_calls,unlock_calls;
static void lock_db(fdb_db_t db){(void)db;++lock_calls;}
static void unlock_db(fdb_db_t db){(void)db;++unlock_calls;}
static fdb_time_t clock_value(void){static fdb_time_t t=1000;return ++t;}
static void cleanup(void){char path[40];int i;for(i=0;i<16;++i){snprintf(path,sizeof path,"kvtest.fdb.%d",i);remove(path);snprintf(path,sizeof path,"tstest.fdb.%d",i);remove(path);}}
static void kv_config(struct fdb_kvdb *db){
    uint32_t sec=4096,max=4*4096;bool file=true;
    fdb_kvdb_control(db,FDB_KVDB_CTRL_SET_SEC_SIZE,&sec);fdb_kvdb_control(db,FDB_KVDB_CTRL_SET_MAX_SIZE,&max);
    fdb_kvdb_control(db,FDB_KVDB_CTRL_SET_FILE_MODE,&file);
    lmx_fdb_set_callbacks(&db->parent,lock_db,unlock_db);
}
static void ts_config(struct fdb_tsdb *db){
    uint32_t sec=4096,max=4*4096;bool file=true;lmx_fdb_callback lock=lock_db,unlock=unlock_db;
    fdb_tsdb_control(db,FDB_TSDB_CTRL_SET_SEC_SIZE,&sec);fdb_tsdb_control(db,FDB_TSDB_CTRL_SET_MAX_SIZE,&max);
    fdb_tsdb_control(db,FDB_TSDB_CTRL_SET_FILE_MODE,&file);
    fdb_tsdb_control(db,FDB_TSDB_CTRL_SET_LOCK,&lock);fdb_tsdb_control(db,FDB_TSDB_CTRL_SET_UNLOCK,&unlock);
}
struct iter_state{fdb_tsdb_t db;unsigned n;uint32_t sum;int failed;};
static bool visit(fdb_tsl_t tsl,void *arg){
    struct iter_state *s=arg;struct fdb_blob blob;uint32_t v=0;
    fdb_blob_make(&blob,&v,sizeof v);fdb_tsl_to_blob(tsl,&blob);
    if(fdb_blob_read(&s->db->parent,&blob)!=sizeof v)s->failed=1;
    s->sum+=v;++s->n;return false;
}
int main(void){
    struct fdb_kvdb kv={0};struct fdb_tsdb ts={0};struct fdb_default_kv defs={NULL,0};struct fdb_blob blob;
    unsigned char in[257],out[257];size_t i;unsigned r;uint32_t v;struct iter_state state;
    cleanup();kv_config(&kv);CHECK(fdb_kvdb_init(&kv,"kvtest",".",&defs,NULL)==FDB_NO_ERR);
    CHECK(fdb_kv_set(&kv,"place","moon")==FDB_NO_ERR);
    for(r=0;r<80;++r){for(i=0;i<sizeof in;++i)in[i]=(unsigned char)(i+r);
        CHECK(fdb_kv_set_blob(&kv,"binary",fdb_blob_make(&blob,in,sizeof in))==FDB_NO_ERR);}
    CHECK(fdb_kvdb_deinit(&kv)==FDB_NO_ERR);memset(&kv,0,sizeof kv);kv_config(&kv);
    CHECK(fdb_kvdb_init(&kv,"kvtest",".",&defs,NULL)==FDB_NO_ERR);
    CHECK(fdb_kv_get(&kv,"place") && !strcmp(fdb_kv_get(&kv,"place"),"moon"));
    CHECK(fdb_kv_get_blob(&kv,"binary",fdb_blob_make(&blob,out,sizeof out))==sizeof out);CHECK(!memcmp(in,out,sizeof in));
    CHECK(fdb_kvdb_check(&kv)==FDB_NO_ERR);CHECK(fdb_kv_del(&kv,"place")==FDB_NO_ERR);
    CHECK(fdb_kvdb_deinit(&kv)==FDB_NO_ERR);
    ts_config(&ts);CHECK(fdb_tsdb_init(&ts,"tstest",".",clock_value,sizeof v,NULL)==FDB_NO_ERR);
    v=23;CHECK(fdb_tsl_append(&ts,fdb_blob_make(&blob,&v,sizeof v))==FDB_NO_ERR);
    v=41;CHECK(fdb_tsl_append(&ts,fdb_blob_make(&blob,&v,sizeof v))==FDB_NO_ERR);
    CHECK(fdb_tsdb_deinit(&ts)==FDB_NO_ERR);memset(&ts,0,sizeof ts);ts_config(&ts);
    CHECK(fdb_tsdb_init(&ts,"tstest",".",clock_value,sizeof v,NULL)==FDB_NO_ERR);
    state=(struct iter_state){&ts,0,0,0};fdb_tsl_iter(&ts,visit,&state);
    CHECK(!state.failed && state.n==2 && state.sum==64);CHECK(fdb_tsdb_deinit(&ts)==FDB_NO_ERR);
    CHECK(lock_calls>0 && lock_calls==unlock_calls);cleanup();return 0;
}
