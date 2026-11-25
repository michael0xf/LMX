#include "check.h"
#include <stdlib.h>
#include <string.h>
#include <cmp.h>
#include <mpack/mpack.h>
struct memory { unsigned char data[256]; size_t pos, length; };
static bool read_cb(cmp_ctx_t *ctx, void *data, size_t n) {
    struct memory *m = ctx->buf; if (n > m->length-m->pos) return false;
    memcpy(data,m->data+m->pos,n); m->pos+=n; return true;
}
static bool skip_cb(cmp_ctx_t *ctx, size_t n) {
    struct memory *m=ctx->buf; if(n>m->length-m->pos)return false; m->pos+=n;return true;
}
static size_t write_cb(cmp_ctx_t *ctx,const void *data,size_t n) {
    struct memory *m=ctx->buf; if(n>sizeof(m->data)-m->length)return 0;
    memcpy(m->data+m->length,data,n);m->length+=n;return n;
}
int main(void) {
    struct memory mem = {{0},0,0}; cmp_ctx_t cmp; mpack_tree_t tree; mpack_node_t root;
    char *encoded; size_t size; mpack_writer_t writer; mpack_reader_t reader;
    uint32_t count, len; int64_t number; char text[16];
    cmp_init(&cmp,&mem,read_cb,skip_cb,write_cb);
    CHECK(cmp_write_map(&cmp,2)); CHECK(cmp_write_str(&cmp,"value",5)); CHECK(cmp_write_integer(&cmp,-123));
    CHECK(cmp_write_str(&cmp,"text",4)); CHECK(cmp_write_str(&cmp,"LMX",3));
    mpack_tree_init_data(&tree,(const char *)mem.data,mem.length);mpack_tree_parse(&tree);root=mpack_tree_root(&tree);
    CHECK(mpack_node_i64(mpack_node_map_cstr(root,"value"))==-123);
    CHECK(mpack_node_strlen(mpack_node_map_cstr(root,"text"))==3); CHECK(mpack_tree_destroy(&tree)==mpack_ok);
    mpack_reader_init_data(&reader,(const char *)mem.data,mem.length);mpack_expect_map_match(&reader,2);
    mpack_expect_cstr_match(&reader,"value");CHECK(mpack_expect_i64(&reader)==-123);
    mpack_expect_cstr_match(&reader,"text");mpack_expect_cstr_match(&reader,"LMX");mpack_done_map(&reader);
    CHECK(mpack_reader_destroy(&reader)==mpack_ok);
    mpack_writer_init_growable(&writer,&encoded,&size);mpack_start_array(&writer,2);
    mpack_write_i64(&writer,42);mpack_write_cstr(&writer,"back");mpack_finish_array(&writer);
    CHECK(mpack_writer_destroy(&writer)==mpack_ok && size<=sizeof(mem.data));
    memcpy(mem.data,encoded,size);mem.length=size;mem.pos=0;free(encoded);
    cmp_init(&cmp,&mem,read_cb,skip_cb,write_cb);CHECK(cmp_read_array(&cmp,&count)&&count==2);
    CHECK(cmp_read_integer(&cmp,&number)&&number==42);len=sizeof(text);CHECK(cmp_read_str(&cmp,text,&len)&&strcmp(text,"back")==0);
    mem.pos=0;mem.length=1;cmp_init(&cmp,&mem,read_cb,skip_cb,write_cb);CHECK(cmp_read_array(&cmp,&count));CHECK(!cmp_read_integer(&cmp,&number));
    puts("CMP <-> MPack interoperability, tree + streaming typed API, truncation rejection: OK");return 0;
}
