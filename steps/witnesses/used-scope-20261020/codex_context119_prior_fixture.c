#define main inherited_pending_views_main
#include "lmx_implements_pending_views_selftest.c"
#undef main

static int checks,failures;
static void ctx_ck(int yes,const char *why){++checks;if(!yes){++failures;fprintf(stderr,"FAIL current context: %s\n",why);}}
static Lmx *ctx_node(LmxArena *a,size_t n){Lmx *v=lmx_node_new_owned(a);if(!v||(n&&lmx_arena_refs_open_owned(a,v,n)))abort();return v;}
static void ctx_put(Lmx *v,size_t i,void *p){if(lmx_arena_ref_store(v,i,p))abort();}
static void *ctx_int(LmxArena *a,int value){void *p=lmx_int_new_owned(a);if(!p||lmx_int_store_known(p,value))abort();return p;}
static void ctx_size(LmxArena *a,Lmx *v,size_t i,size_t value){void *p=lmx_size_new_owned(a);if(!p||lmx_size_store_known(p,value))abort();ctx_put(v,i,p);}
static void ctx_token(LmxArena *a,Lmx *v,size_t i,void *token){void *p=lmx_charptr_new_owned(a);if(!p||lmx_charptr_store_known(p,token))abort();ctx_put(v,i,p);}
static Lmx *ctx_pair(LmxArena *a,int x,int y){Lmx *v=ctx_node(a,2);ctx_put(v,0,ctx_int(a,x));ctx_put(v,1,ctx_int(a,y));return v;}
static void ctx_layout(LmxArena *a,Lmx *v,void *token){if(lmx_implements_register_map(a,v,v,NULL,0,token)!=LMX_IMPLEMENTS_YES)abort();}
static size_t identity[]={0,1,0,1},reverse[]={1,0,1,0};
static char tokens[3];
static Lmx *ctx_candidate(LmxArena *a,Lmx *d,Lmx *e){
    Lmx *v=ctx_pair(a,7,9);LmxImplEntry view={0};view.map=identity;view.n=2;
    if(lmx_implements_admit_receiving(a,v,d,&view,NULL)!=LMX_IMPLEMENTS_YES||
       lmx_implements_admit_receiving(a,v,e,&view,NULL)!=LMX_IMPLEMENTS_YES)abort();
    return v;
}
static Lmx *ctx_source(LmxArena *a,Lmx *model,Lmx *refs){Lmx *v=ctx_node(a,2);ctx_put(v,0,model);ctx_put(v,1,refs);return v;}
static Lmx *ctx_catalog(LmxArena *a){
    Lmx *v=ctx_node(a,15);ctx_size(a,v,0,2);size_t at=1;
    for(size_t i=0;i<2;++i){
        ctx_token(a,v,at,tokens+i);ctx_token(a,v,at+1,tokens+2);ctx_size(a,v,at+2,2);
        size_t *map=i?reverse:identity;
        for(size_t j=0;j<4;++j)ctx_size(a,v,at+3+j,map[j]);
        at+=7;
    }
    return v;
}
static Lmx *ctx_frame(LmxArena *a,Lmx *catalog,Lmx *refs,Lmx *closed){
    Lmx *v=ctx_node(a,5);ctx_put(v,0,catalog);ctx_size(a,v,2,1);ctx_put(v,3,refs);ctx_put(v,4,closed);return v;
}
static size_t ctx_slot(LmxArena *a,Lmx *v,Lmx *r,size_t edge){size_t slot=(size_t)-1;if(lmx_implements_slot(a,v,r,edge,&slot))return (size_t)-1;return slot;}
static int ctx_read(LmxArena *a,Lmx *v,Lmx *r,size_t edge){size_t slot=ctx_slot(a,v,r,edge);if(slot==(size_t)-1)return -10000;void *cell=lmx_graph_value_in(a,v,slot);return cell&&lmx_domain_type(a,cell)==LMX_TYPE_INT?lmx_int_value_known(cell):-10000;}
static int ctx_same(LmxArena *a,Lmx *v,void **saved){for(size_t i=0;i<5;++i)if(lmx_graph_value_in(a,v,i)!=saved[i])return 0;return 1;}
int inherited_context114_checks(void){
    LmxArena arena={0};LmxArena *a=&arena;if(lmx_arena_open(a))abort();
    Lmx *d=ctx_pair(a,0,0),*e=ctx_pair(a,0,0),*r=ctx_pair(a,0,0);
    ctx_layout(a,d,tokens);ctx_layout(a,e,tokens+1);ctx_layout(a,r,tokens+2);
    Lmx *refs=ctx_node(a,1);ctx_size(a,refs,0,0);
    Lmx *source_d=ctx_source(a,d,refs),*source_e=ctx_source(a,e,refs);
    Lmx *catalog=ctx_catalog(a),*frame=ctx_frame(a,catalog,refs,source_e);
    void *saved[5];for(size_t i=0;i<5;++i)saved[i]=lmx_graph_value_in(a,frame,i);
    void *frame_data=frame->array.data;
    Lmx *v=ctx_candidate(a,d,e);
    ctx_ck(lmx_implements_layout(a,v)==NULL,"two admitted namespaces do not invent a physical constructor");
    LmxArenaBlock *mark=lmx_arena_mark(a);
    ctx_ck(lmx_implements_admit_receiving_context(a,v,r,frame,source_e)==LMX_IMPLEMENTS_YES,"CURRENT E is the selected giving namespace");
    ctx_ck(ctx_read(a,v,r,0)==9&&ctx_read(a,v,r,2)==9,"ordinal and LAST read actual9 through E's reordered map");
    ctx_ck(ctx_slot(a,v,r,0)==1,"the common resolver retained the real selected physical slot");
    ctx_ck(lmx_arena_mark(a)==mark,"context adaptation materializes no replacement graph/frame");
    void *cell=lmx_graph_value_in(a,v,1);
    ctx_ck(lmx_int_store_known(cell,41)==0&&ctx_read(a,v,r,0)==41,"write uses the same physical correspondence");
    ctx_ck(lmx_int_value_known(lmx_graph_value_in(a,v,0))==7,"mapped write preserves the neighbor");
    void **address=lmx_graph_ref_cell_in(a,v,ctx_slot(a,v,r,0));
    ctx_ck(address&&*address==cell,"taken address is the mapped real reference cell");
    if(address)*address=ctx_int(a,43);
    ctx_ck(ctx_read(a,v,r,0)==43&&ctx_read(a,v,r,2)==43,"address dereference updates the same ordinal/LAST value");
    ctx_ck(ctx_same(a,frame,saved)&&frame->array.data==frame_data,"receiving record edges/backing were never changed");

    Lmx *v2=ctx_candidate(a,d,e);
    ctx_ck(lmx_implements_admit_receiving_context(a,v2,r,frame,source_d)==LMX_IMPLEMENTS_YES,"another operation supplies D without rewriting shared E data");
    ctx_ck(ctx_read(a,v2,r,0)==7&&ctx_read(a,v2,r,1)==9,"D's actual values follow D,not a previous E operation");
    ctx_ck(ctx_read(a,v,r,0)==43,"the next operation leaves the first value/correspondence intact");
    ctx_ck(ctx_same(a,frame,saved),"interleaved operations retain the shared closed context exactly");
    Lmx *v3=ctx_candidate(a,d,e);
    ctx_ck(lmx_implements_admit_receiving_context(a,v3,r,frame,NULL)!=LMX_IMPLEMENTS_YES&&!lmx_implements_find(a,v3,r),"explicit absence cannot resurrect another call's closed E context");
    ctx_ck(lmx_implements_find(a,v3,d)&&lmx_implements_find(a,v3,e),"refused ambiguity preserves both existing source namespaces");
    ctx_ck(ctx_same(a,frame,saved),"explicit absence does not clear or fill shared context data");
    Lmx *v4=ctx_candidate(a,d,e);
    ctx_ck(lmx_implements_admit_receiving_frame(a,v4,r,frame)==LMX_IMPLEMENTS_YES,"legacy ordinary-frame adapter still consumes its own fifth field");
    ctx_ck(ctx_read(a,v4,r,0)==9,"legacy adapter preserves its original E result");
    ctx_ck(ctx_same(a,frame,saved),"legacy adapter also leaves every record edge unchanged");

    Lmx *v5=ctx_candidate(a,d,e),*bad=ctx_node(a,0);
    ctx_ck(lmx_implements_admit_receiving_context(a,v5,r,frame,bad)==LMX_IMPLEMENTS_UNKNOWN&&!lmx_implements_find(a,v5,r),"present malformed context is not an untyped fallback");
    bad=ctx_source(a,NULL,refs);
    ctx_ck(lmx_implements_admit_receiving_context(a,v5,r,frame,bad)==LMX_IMPLEMENTS_UNKNOWN,"missing current Model refuses");
    bad=ctx_source(a,d,NULL);
    ctx_ck(lmx_implements_admit_receiving_context(a,v5,r,frame,bad)==LMX_IMPLEMENTS_UNKNOWN,"missing source declaration sheet refuses");
    bad=ctx_source(a,(Lmx *)ctx_int(a,1),refs);
    ctx_ck(lmx_implements_admit_receiving_context(a,v5,r,frame,bad)==LMX_IMPLEMENTS_UNKNOWN,"a primitive cannot masquerade as a giving Model");
    bad=ctx_source(a,d,(Lmx *)ctx_int(a,1));
    ctx_ck(lmx_implements_admit_receiving_context(a,v5,r,frame,bad)==LMX_IMPLEMENTS_UNKNOWN,"a primitive cannot masquerade as the declared reference sheet");
    Lmx *invalid=ctx_frame(a,catalog,refs,ctx_node(a,0));
    ctx_ck(lmx_implements_admit_receiving_frame(a,v5,r,invalid)==LMX_IMPLEMENTS_UNKNOWN,"legacy malformed fifth field remains refused");
    invalid=ctx_frame(a,catalog,refs,source_e);ctx_size(a,invalid,2,3);
    ctx_ck(lmx_implements_admit_receiving_context(a,v5,r,invalid,source_e)==LMX_IMPLEMENTS_UNKNOWN,"current source context never bypasses invalid reception mode");
    invalid=ctx_frame(a,NULL,refs,source_e);
    ctx_ck(lmx_implements_admit_receiving_context(a,v5,r,invalid,source_e)==LMX_IMPLEMENTS_UNKNOWN,"current source context never replaces a missing catalog");
    invalid=ctx_frame(a,catalog,(Lmx *)ctx_int(a,1),source_e);
    ctx_ck(lmx_implements_admit_receiving_context(a,v5,r,invalid,source_e)==LMX_IMPLEMENTS_UNKNOWN,"required declaration metadata is still validated independently");
    invalid=ctx_frame(a,catalog,refs,source_e);ctx_size(a,invalid,2,2);
    ctx_ck(lmx_implements_admit_receiving_context(a,v5,r,invalid,source_e)==LMX_IMPLEMENTS_UNKNOWN,"scoped reception still requires its actual coverage");
    Lmx *v6=ctx_candidate(a,d,e),*equivalent=ctx_source(a,e,refs);
    ctx_ck(lmx_implements_admit_receiving_context(a,v6,r,frame,equivalent)==LMX_IMPLEMENTS_YES&&ctx_read(a,v6,r,0)==9,"ordinary context data needs no registry/marker/first-object identity");
    ctx_ck(ctx_same(a,frame,saved)&&lmx_graph_value_in(a,source_e,0)==e&&lmx_graph_value_in(a,source_e,1)==refs,"all shared current data retains its original physical edges");
    Lmx *single=ctx_pair(a,7,9);LmxImplEntry only_d={0};only_d.n=2;only_d.map=identity;
    if(lmx_implements_admit_receiving(a,single,d,&only_d,NULL)!=LMX_IMPLEMENTS_YES)abort();
    ctx_ck(lmx_implements_admit_receiving_context(a,single,r,frame,source_e)!=LMX_IMPLEMENTS_YES&&!lmx_implements_find(a,single,r),"a present E namespace without E evidence cannot be replaced by the first old D admission");
    ctx_ck(lmx_implements_find(a,single,d)&&!lmx_implements_find(a,single,e),"failed current-source proof neither changes D nor fabricates E");
    ctx_ck(lmx_implements_admit_receiving_context(a,single,r,frame,source_d)==LMX_IMPLEMENTS_YES&&ctx_read(a,single,r,0)==7,"the later genuinely proved D operation still succeeds without poisoned receiving state");
    ctx_ck(lmx_implements_admit_receiving_context(a,v,r,frame,source_d)==LMX_IMPLEMENTS_YES&&ctx_read(a,v,r,0)==43,"the SAME already-admitted R role keeps its established current proof,not a newly guessed giving spelling");
    lmx_arena_release(a);
    printf("current receiving context: %d checks, %d failures\n",checks,failures);
    return failures!=0;
}
