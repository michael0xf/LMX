/* Exercises the typed callback adaptation and binary/XML/URI/SDBM boundaries. */
#include <apr_general.h>
#include <apr_pools.h>
#include <apr_base64.h>
#include <apr_uri.h>
#include <apr_xml.h>
#include <apr_sdbm.h>
#include <apr_optional.h>
#include <apr_hooks.h>
#include <apr_file_io.h>
#include <stdio.h>
#include <string.h>
#define CHECK(x) do { if (!(x)) { fprintf(stderr,"APU check failed at %d: %s\n",__LINE__,#x); return 1; } } while(0)
APR_DECLARE_OPTIONAL_FN(int,lmx_answer,(int));
static int lmx_answer(int x) { return x+1; }
int main(void) {
    apr_pool_t *p; apr_uri_t uri; apr_xml_parser *xml; apr_xml_doc *doc;
    const unsigned char raw[]={0,1,127,128,255}; unsigned char decoded[16]; char encoded[32];
    apr_sdbm_t *db; apr_sdbm_datum_t key={(char *)"key",3}, value={(char *)"answer",6}, got;
    APR_OPTIONAL_FN_TYPE(lmx_answer) *fn;
    const char *text="<r><v>A&amp;B</v></r>";
    apr_text *part; char content[16]={0}; size_t used=0;
    CHECK(apr_initialize()==APR_SUCCESS); CHECK(apr_pool_create(&p,NULL)==APR_SUCCESS);
    CHECK(apr_base64_encode_binary(encoded,raw,sizeof raw)>0);
    CHECK(apr_base64_decode_binary(decoded,encoded)==sizeof raw && memcmp(decoded,raw,sizeof raw)==0);
    CHECK(apr_uri_parse(p,"https://example.invalid:8443/data?q=1#x",&uri)==APR_SUCCESS);
    CHECK(uri.port==8443 && strcmp(uri.path,"/data")==0 && strcmp(uri.query,"q=1")==0);
    xml=apr_xml_parser_create(p); CHECK(xml!=NULL);
    CHECK(apr_xml_parser_feed(xml,text,7)==APR_SUCCESS);
    CHECK(apr_xml_parser_feed(xml,text+7,strlen(text)-7)==APR_SUCCESS);
    CHECK(apr_xml_parser_done(xml,&doc)==APR_SUCCESS && strcmp(doc->root->first_child->name,"v")==0);
    for(part=doc->root->first_child->first_cdata.first;part;part=part->next) {
        size_t length=strlen(part->text); CHECK(used+length<sizeof content);
        memcpy(content+used,part->text,length); used+=length;
    }
    CHECK(strcmp(content,"A&B")==0);
    xml=apr_xml_parser_create(p); CHECK(apr_xml_parser_feed(xml,"<r></x>",7)!=APR_SUCCESS);
    CHECK(apr_sdbm_open(&db,"lmx-apu-test",APR_CREATE|APR_WRITE|APR_READ|APR_TRUNCATE,APR_OS_DEFAULT,p)==APR_SUCCESS);
    CHECK(apr_sdbm_store(db,key,value,APR_SDBM_REPLACE)==APR_SUCCESS); CHECK(apr_sdbm_close(db)==APR_SUCCESS);
    CHECK(apr_sdbm_open(&db,"lmx-apu-test",APR_READ,APR_OS_DEFAULT,p)==APR_SUCCESS);
    CHECK(apr_sdbm_fetch(db,&got,key)==APR_SUCCESS && got.dsize==6 && memcmp(got.dptr,"answer",6)==0);
    CHECK(apr_sdbm_close(db)==APR_SUCCESS); apr_file_remove("lmx-apu-test.dir",p); apr_file_remove("lmx-apu-test.pag",p);
    apr_hook_global_pool=p; APR_REGISTER_OPTIONAL_FN(lmx_answer); fn=APR_RETRIEVE_OPTIONAL_FN(lmx_answer);
    CHECK(fn!=NULL && fn(41)==42); apr_dynamic_fn_register("lmx_answer",NULL); CHECK(APR_RETRIEVE_OPTIONAL_FN(lmx_answer)==NULL);
    apr_pool_destroy(p); apr_terminate(); puts("APU XML/base64/URI/SDBM/typed hooks OK"); return 0;
}
