#define main inherited_pending_views_main
#include "lmx_implements_pending_views_selftest.c"
#undef main

static int checks,failures;
static void ck(int good,const char *why){++checks;if(!good){++failures;fprintf(stderr,"FAIL projection: %s\n",why);}}
static Lmx *node(LmxArena *a,size_t n){Lmx *v=lmx_node_new_owned(a);if(!v||lmx_arena_refs_open_owned(a,v,n))abort();return v;}
static void put(Lmx *v,size_t i,void *p){if(lmx_arena_ref_store(v,i,p))abort();}
static void *num(LmxArena *a,int n){void *p=lmx_int_new_owned(a);if(!p||lmx_int_store_known(p,n))abort();return p;}
static void layout(LmxArena *a,Lmx *v,void *token){if(lmx_implements_register_map(a,v,v,NULL,0,token)!=LMX_IMPLEMENTS_YES)abort();}
static size_t rev[]={1,0,1,0},identity[]={0,1,0,1},thin[]={0,(size_t)-1,0,(size_t)-1};
static char tokens[2];
static void templ(LmxImplTemplate *t,void *source,void *target,size_t *map,size_t n){memset(t,0,sizeof *t);t->source_layout=source;t->required_layout=target;t->correspondence.map=map;t->correspondence.n=n;}
static void catalog_size(LmxArena *a,Lmx *f,size_t i,size_t n){void *c=lmx_size_new_owned(a);if(!c||lmx_size_store_known(c,n))abort();put(f,i,c);}
static void catalog_token(LmxArena *a,Lmx *f,size_t i,void *token){void *c=lmx_charptr_new_owned(a);if(!c||lmx_charptr_store_known(c,token))abort();put(f,i,c);}
static Lmx *catalog(LmxArena *a,const LmxImplTemplate *ts,size_t n){
    size_t extent=1,at=1;
    for(size_t i=0;i<n;++i)extent+=3+2*ts[i].correspondence.n;
    Lmx *f=node(a,extent);catalog_size(a,f,0,n);
    for(size_t i=0;i<n;++i){
        const LmxImplEntry *row=&ts[i].correspondence;
        catalog_token(a,f,at,ts[i].source_layout);catalog_token(a,f,at+1,ts[i].required_layout);catalog_size(a,f,at+2,row->n);
        for(size_t j=0;j<2*row->n;++j)catalog_size(a,f,at+3+j,row->map[j]);
        at+=3+2*row->n;
    }
    return f;
}

static int selected_admit(int frame,LmxArena *a,Lmx *v,Lmx *m,LmxImplTemplate *ts,size_t n,int full){
    return frame?lmx_implements_admit_template_frame(a,v,m,catalog(a,ts,n),NULL,full):lmx_implements_admit_templates(a,v,m,ts,n,NULL,full);
}
static Lmx *ints(LmxArena *a,int x,int y){
    Lmx *v=node(a,2);put(v,0,num(a,x));put(v,1,num(a,y));return v;
}
static size_t physical(LmxArena *a,Lmx *v,Lmx *m,size_t edge){
    size_t p=(size_t)-1;
    if(lmx_implements_slot(a,v,m,edge,&p))return (size_t)-2;
    return p;
}
int main(void){
    const size_t u=(size_t)-1;
    for(int frame=0;frame<2;++frame){
        LmxArena a={0};if(lmx_arena_open(&a))abort();
        Lmx *m=ints(&a,0,0),*v=ints(&a,9,7);LmxImplTemplate ts[130];
        layout(&a,m,tokens);layout(&a,v,tokens);
        templ(ts,tokens,tokens,rev,2);
        ck(selected_admit(frame,&a,v,m,ts,1,1)==LMX_IMPLEMENTS_YES,"a matching explicit projection is consumed before physical identity");
        ck(physical(&a,v,m,0)==1&&physical(&a,v,m,1)==0,"the ordinal half is the supplied reordered map");
        ck(physical(&a,v,m,2)==1&&physical(&a,v,m,3)==0,"the LAST half is the same supplied reordered map");
        ck(lmx_int_value_known(lmx_graph_value_in(&a,v,physical(&a,v,m,0)))==7,"actual read uses the projected field,not identity");
        void *cell=lmx_graph_value_in(&a,v,physical(&a,v,m,0));
        ck(lmx_int_store_known(cell,41)==0&&lmx_int_value_known(lmx_graph_value_in(&a,v,1))==41,"actual write reaches the mapped physical field");
        ck(lmx_int_value_known(lmx_graph_value_in(&a,v,0))==9,"projected write leaves the neighbor unchanged");
        void **address=lmx_graph_ref_cell_in(&a,v,physical(&a,v,m,0));
        ck(address&&*address==cell,"taken address is the mapped physical reference cell");
        if(address)*address=num(&a,43);
        ck(lmx_int_value_known(lmx_graph_value_in(&a,v,physical(&a,v,m,2)))==43,"dereferencing the address changes the same LAST value");

        m=node(&a,2);v=node(&a,2);
        put(m,0,num(&a,0));put(v,0,num(&a,7));
        Lmx *mx=ints(&a,1,2),*vx=ints(&a,3,4);
        put(m,1,mx);put(v,1,vx);layout(&a,m,tokens);layout(&a,v,tokens);
        templ(ts,tokens,tokens,thin,2);
        ck(selected_admit(frame,&a,v,m,ts,1,0)==LMX_IMPLEMENTS_YES,"a declared hole is not replaced by a descent through source-only graph");
        LmxImplEntry *e=lmx_implements_find(&a,v,m);
        size_t hole1=0,hole2=0;
        ck(e&&e->n==2&&lmx_implements_at(&a,e,1,&hole1)==0&&lmx_implements_at_last(&a,e,1,&hole2)==0&&hole1==u&&hole2==u,"both holes survive prepared publication with their semantic width in either coordinate representation");
        ck(physical(&a,v,m,0)==0&&lmx_implements_slot(&a,v,m,1,&hole1)!=0,"partial map preserves its positive coordinate and refuses an omitted place");
        ck(selected_admit(frame,&a,v,m,ts,1,1)==LMX_IMPLEMENTS_NO,"a hole is still refused when the full receiver actually requires it");

        m=ints(&a,0,0);v=ints(&a,9,7);layout(&a,m,tokens);layout(&a,v,tokens);
        templ(ts,tokens,tokens,rev,1);
        ck(selected_admit(frame,&a,v,m,ts,1,1)==LMX_IMPLEMENTS_UNKNOWN,"a malformed matching width is not hidden by same-layout identity");
        ck(lmx_implements_find(&a,v,m)==NULL,"malformed projection publishes no pair");
        templ(ts,tokens,tokens,rev,2);templ(ts+1,tokens,tokens,identity,2);
        ck(selected_admit(frame,&a,v,m,ts,2,1)==LMX_IMPLEMENTS_UNKNOWN,"conflicting explicit direct rows are not silently ignored");
        ck(lmx_implements_find(&a,v,m)==NULL,"conflicting projections publish no pair");

        m=ints(&a,0,0);v=ints(&a,9,7);layout(&a,m,tokens);layout(&a,v,tokens);
        templ(ts,tokens+1,tokens,rev,2);
        ck(selected_admit(frame,&a,v,m,ts,1,1)==LMX_IMPLEMENTS_YES,"an irrelevant source row does not disable genuine physical identity");
        ck(physical(&a,v,m,0)==0&&physical(&a,v,m,1)==1,"identity without a direct explicit row retains its original coordinates");

        m=ints(&a,0,0);v=ints(&a,9,7);layout(&a,m,tokens);
        templ(ts,tokens,tokens,rev,2);
        ck(selected_admit(frame,&a,v,m,ts,1,1)==LMX_IMPLEMENTS_UNKNOWN,"the catalog alone does not invent a candidate's physical origin");
        ck(lmx_implements_find(&a,v,m)==NULL,"unknown source evidence publishes nothing");

        m=ints(&a,0,0);v=ints(&a,9,7);layout(&a,m,tokens);layout(&a,v,tokens);
        for(size_t i=0;i<129;++i)templ(ts+i,tokens+1,tokens,identity,2);
        templ(ts+129,tokens,tokens,rev,2);
        ck(selected_admit(frame,&a,v,m,ts,130,1)==LMX_IMPLEMENTS_YES,"matching projection beyond129 irrelevant rows uses the same inventory scan");
        ck(physical(&a,v,m,0)==1&&physical(&a,v,m,3)==0,"late matching row is really consumed");

        m=ints(&a,0,0);v=ints(&a,9,7);layout(&a,m,tokens);layout(&a,v,tokens);
        void *character=lmx_char_new_owned(&a);if(!character||lmx_char_store_known(character,'x'))abort();
        put(v,1,character);templ(ts,tokens,tokens,rev,2);
        ck(selected_admit(frame,&a,v,m,ts,1,1)==LMX_IMPLEMENTS_NO,"an explicit projection remains subject to actual field-type checking");
        ck(lmx_implements_find(&a,v,m)==NULL,"a rejected field type publishes no projection");
        lmx_arena_release(&a);
    }
    printf("explicit projection priority: %d checks, %d failures\n",checks,failures);
    return failures!=0;
}
