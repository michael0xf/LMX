#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "md4c.h"
#include "md4c-html.h"
#include "gumbo.h"
#include "yxml.h"
#include "ezxml.h"
#include "toml.h"
#include "yaml.h"
#define CHECK(x) do { if (!(x)) { fprintf(stderr, "%s:%d: %s\n", __FILE__, __LINE__, #x); return 1; } } while (0)
struct md_events { unsigned blocks, headings, strong, bytes; };
static int enter_block(MD_BLOCKTYPE t, void *d, void *u) { struct md_events *s=u; (void)d; s->blocks++; if(t==MD_BLOCK_H)s->headings++; return 0; }
static int leave_block(MD_BLOCKTYPE t, void *d, void *u) { (void)t;(void)d;(void)u; return 0; }
static int enter_span(MD_SPANTYPE t, void *d, void *u) { struct md_events *s=u; (void)d; if(t==MD_SPAN_STRONG)s->strong++; return 0; }
static int leave_span(MD_SPANTYPE t, void *d, void *u) { (void)t;(void)d;(void)u;return 0; }
static int text_event(MD_TEXTTYPE t, const char *p, MD_SIZE n, void *u) { struct md_events *s=u; (void)t;(void)p;s->bytes+=n;return 0; }
struct output { char data[16384]; size_t used; int overflow; };
static void html_output(const char *s, MD_SIZE n, void *u) { struct output *o=u; if(n >= sizeof(o->data)-o->used){o->overflow=1;return;} memcpy(o->data+o->used,s,n);o->used+=n;o->data[o->used]='\0'; }
static int test_markdown(void) {
    const char source[]="# LMX\n\n**bold** & [site](https://example.test/ \"title\") with `code`.\n\n| a | b |\n|---|---|\n| 1 | 2 |\n\nFootnote[^n].\n\n[^n]: note **text**\n";
    struct md_events counts={0}; struct output output={{0},0,0};
    MD_PARSER parser={0}; parser.flags=MD_DIALECT_GITHUB;
    parser.enter_block=enter_block; parser.leave_block=leave_block;
    parser.enter_span=enter_span; parser.leave_span=leave_span; parser.text=text_event;
    CHECK(md_parse(source,(MD_SIZE)strlen(source),&parser,&counts)==0);
    CHECK(counts.headings==1 && counts.strong==2 && counts.blocks>=10 && counts.bytes>25);
    CHECK(md_html(source,(MD_SIZE)strlen(source),html_output,&output,MD_DIALECT_GITHUB,0)==0);
    CHECK(!output.overflow && strstr(output.data,"<h1>LMX</h1>") && strstr(output.data,"<strong>bold</strong>"));
    CHECK(strstr(output.data,"<table>") && strstr(output.data,"href=\"https://example.test/\"") && strstr(output.data,"footnote"));
    puts("md4c: callback events, HTML, links, table and footnotes passed"); return 0;
}
static unsigned tag_count(const GumboNode *node, GumboTag tag) {
    unsigned count=0,i; const GumboVector *children=NULL;
    if(node->type==GUMBO_NODE_ELEMENT){ if(node->v.element.tag==tag)count++; children=&node->v.element.children; }
    else if(node->type==GUMBO_NODE_DOCUMENT)children=&node->v.document.children;
    if(children) for(i=0;i<children->length;i++)count+=tag_count(children->data[i],tag);
    return count;
}
static int test_html(void) {
    const char source[]="<!doctype html><title>T</title><p id='a'>one<p>two<b><i>X</b>Y</i><ul><li>A<li>B</ul>";
    GumboOutput *output=gumbo_parse(source); CHECK(output!=NULL && output->root!=NULL);
    CHECK(tag_count(output->document,GUMBO_TAG_HTML)==1 && tag_count(output->document,GUMBO_TAG_BODY)==1);
    CHECK(tag_count(output->document,GUMBO_TAG_P)==2 && tag_count(output->document,GUMBO_TAG_LI)==2);
    CHECK(output->errors.length>0); gumbo_destroy_output(&kGumboDefaultOptions,output);
    puts("gumbo: malformed nesting recovered into HTML/body, two p and two li nodes"); return 0;
}
static int test_yxml(void) {
    const char source[]="<?xml version='1.0'?><root id='7'><item>A&amp;B</item></root>";
    char stack[1024],content[64]={0},attribute[16]={0}; size_t used=0,attr_used=0,i;unsigned starts=0,ends=0; yxml_t parser;
    yxml_init(&parser,stack,sizeof(stack));
    for(i=0;source[i];i++) {
        yxml_ret_t r=yxml_parse(&parser,(unsigned char)source[i]); CHECK(r>=0);
        if(r==YXML_ELEMSTART)starts++;
        if(r==YXML_ELEMEND)ends++;
        if(r==YXML_CONTENT){size_t n=strlen(parser.data);CHECK(used+n<sizeof(content));memcpy(content+used,parser.data,n+1);used+=n;}
        if(r==YXML_ATTRVAL){size_t n=strlen(parser.data);CHECK(attr_used+n<sizeof(attribute));memcpy(attribute+attr_used,parser.data,n+1);attr_used+=n;}
    }
    CHECK(yxml_eof(&parser)==YXML_OK && starts==2 && ends==2 && strcmp(content,"A&B")==0 && strcmp(attribute,"7")==0);
    yxml_init(&parser,stack,sizeof(stack));
    { const char malformed[]="<a></b>"; int rejected=0; for(i=0;malformed[i];i++){if(yxml_parse(&parser,malformed[i])<0){rejected=1;break;}} CHECK(rejected); }
    puts("yxml: bytewise tokens, entities, attribute and mismatched-close rejection passed"); return 0;
}
static int test_ezxml(void) {
    char source[]="<root id='7'><item>A&amp;B</item><item>C</item></root>";
    ezxml_t doc=ezxml_parse_str(source,strlen(source)),item; char *rendered; FILE *f;
    CHECK(doc!=NULL && !*ezxml_error(doc) && strcmp(ezxml_attr(doc,"id"),"7")==0);
    item=ezxml_child(doc,"item"); CHECK(item && strcmp(ezxml_txt(item),"A&B")==0 && item->next && strcmp(ezxml_txt(item->next),"C")==0);
    rendered=ezxml_toxml(doc); CHECK(rendered && strstr(rendered,"A&amp;B"));
    f=fopen("ezxml-roundtrip.xml","wb"); CHECK(f); CHECK(fwrite(rendered,1,strlen(rendered),f)==strlen(rendered));CHECK(fclose(f)==0);free(rendered);ezxml_free(doc);
    doc=ezxml_parse_file("ezxml-roundtrip.xml");CHECK(doc && !*ezxml_error(doc) && strcmp(ezxml_attr(doc,"id"),"7")==0);ezxml_free(doc);
    { char bad[]="<a></b>";doc=ezxml_parse_str(bad,strlen(bad));CHECK(doc && *ezxml_error(doc));ezxml_free(doc); }
    puts("ezXML: tree, attributes, entity roundtrip and POSIX file/mmap path passed"); return 0;
}
static int test_toml(void) {
    char source[]="title = \"LMX\"\ncount = 42\nratio = 1.25\nactive = true\nwhen = 2026-11-25T12:00:00Z\nitems = [1, 2, 3]\n[server]\nport = 8080\n";
    char error[200];toml_table_t *doc=toml_parse(source,error,sizeof(error)),*server;toml_datum_t d;toml_array_t *array;
    CHECK(doc);d=toml_string_in(doc,"title");CHECK(d.ok && strcmp(d.u.s,"LMX")==0);free(d.u.s);
    d=toml_int_in(doc,"count");CHECK(d.ok && d.u.i==42);d=toml_double_in(doc,"ratio");CHECK(d.ok && d.u.d==1.25);
    d=toml_bool_in(doc,"active");CHECK(d.ok && d.u.b);d=toml_timestamp_in(doc,"when");CHECK(d.ok && *d.u.ts->year==2026);free(d.u.ts);
    array=toml_array_in(doc,"items");CHECK(array && toml_array_nelem(array)==3);d=toml_int_at(array,2);CHECK(d.ok && d.u.i==3);
    server=toml_table_in(doc,"server");CHECK(server);d=toml_int_in(server,"port");CHECK(d.ok && d.u.i==8080);toml_free(doc);
    {char bad[]="a = [1,,2]";doc=toml_parse(bad,error,sizeof(error));CHECK(doc==NULL);}
    puts("tomlc99: string, int, float, bool, timestamp, array and table passed");return 0;
}
static int test_yaml(void) {
    const unsigned char source[]="name: LMX\ncount: 3\nactive: true\nitems: [a, b]\n";
    unsigned char rendered[2048];size_t used=0;yaml_parser_t parser;yaml_document_t document;yaml_emitter_t emitter;yaml_node_t *node;
    CHECK(yaml_parser_initialize(&parser));yaml_parser_set_input_string(&parser,source,sizeof(source)-1);
    CHECK(yaml_parser_load(&parser,&document));yaml_parser_delete(&parser);
    node=yaml_document_get_root_node(&document);CHECK(node && node->type==YAML_MAPPING_NODE && node->data.mapping.pairs.top-node->data.mapping.pairs.start==4);
    CHECK(yaml_emitter_initialize(&emitter));yaml_emitter_set_output_string(&emitter,rendered,sizeof(rendered),&used);
    CHECK(yaml_emitter_open(&emitter)); CHECK(yaml_emitter_dump(&emitter,&document)); /* transfers document ownership */
    CHECK(yaml_emitter_close(&emitter));yaml_emitter_delete(&emitter);CHECK(used>10 && used<sizeof(rendered));
    CHECK(yaml_parser_initialize(&parser));yaml_parser_set_input_string(&parser,rendered,used);CHECK(yaml_parser_load(&parser,&document));yaml_parser_delete(&parser);
    node=yaml_document_get_root_node(&document);CHECK(node && node->type==YAML_MAPPING_NODE && node->data.mapping.pairs.top-node->data.mapping.pairs.start==4);
    {yaml_node_pair_t pair=node->data.mapping.pairs.start[0];yaml_node_t *v=yaml_document_get_node(&document,pair.value);CHECK(v->type==YAML_SCALAR_NODE && strcmp((char*)v->data.scalar.value,"LMX")==0);}
    yaml_document_delete(&document); puts("libyaml: mapping/sequence parse -> emit -> parse passed (scalar typing is application policy)");return 0;
}
int main(int argc,char **argv) {
    if(argc!=2)return 2;
    if(strcmp(argv[1],"md4c")==0)return test_markdown();
    if(strcmp(argv[1],"gumbo")==0)return test_html();
    if(strcmp(argv[1],"yxml")==0)return test_yxml();
    if(strcmp(argv[1],"ezxml")==0)return test_ezxml();
    if(strcmp(argv[1],"tomlc99")==0)return test_toml();
    if(strcmp(argv[1],"libyaml")==0)return test_yaml();
    return 2;
}
