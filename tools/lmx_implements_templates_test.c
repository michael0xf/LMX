#define main inherited_pending_views_main
#include "lmx_implements_pending_views_selftest.c"
#undef main

/* Source-linked kernel data tests, NOT a source-language/backend gate. */
static int checks, failures;
static void ck(int ok, const char *message) {
    ++checks;
    if (!ok) { ++failures; printf("FAIL templates: %s\n", message); }
}
static Lmx *node(LmxArena *a, size_t n) {
    Lmx *v=lmx_node_new_owned(a);
    if (!v || lmx_arena_refs_open_owned(a,v,n)) abort();
    return v;
}
static void put(Lmx *v,size_t i,void *p) {
    if(lmx_arena_ref_store(v,i,p)) abort();
}
static void *num(LmxArena *a,int n) {
    void *p=lmx_int_new_owned(a);
    if(!p || lmx_int_store_known(p,n)) abort();
    return p;
}
static void layout(LmxArena *a,Lmx *v,void *token) {
    if(lmx_implements_register_map(a,v,v,NULL,0,token)!=LMX_IMPLEMENTS_YES) abort();
}
static size_t rev[]={1,0,1,0};
static size_t identity[]={0,1,0,1};
static size_t thin[]={0,(size_t)-1,0,(size_t)-1};
static size_t scope[]={12,2,2,6,3,9,1,3,0,1,2,0};
static char tokens[16];
static int catalog_mode;
static void templ(LmxImplTemplate *t,void *source,void *target,size_t *map,size_t n) {
    memset(t,0,sizeof *t);
    t->source_layout=source;
    t->required_layout=target;
    t->correspondence.map=map;
    t->correspondence.n=n;
    /* These fields intentionally must convey NO permission or ownership. */
    t->correspondence.reception_proof=2;
    t->correspondence.owned_map=1;
    t->correspondence.exec_map=identity;
    t->correspondence.exec_n=2;
}
static void catalog_size(LmxArena *a,Lmx *f,size_t i,size_t n){
    void *c=lmx_size_new_owned(a);
    if(!c||lmx_size_store_known(c,n))abort();
    put(f,i,c);
}
static void catalog_token(LmxArena *a,Lmx *f,size_t i,void *token){
    void *c=lmx_charptr_new_owned(a);
    if(!c||lmx_charptr_store_known(c,token))abort();
    put(f,i,c);
}
static Lmx *catalog(LmxArena *a,const LmxImplTemplate *ts,size_t n){
    size_t extent=1,at=1;
    for(size_t i=0;i<n;++i)extent+=3+2*ts[i].correspondence.n;
    Lmx *f=node(a,extent);catalog_size(a,f,0,n);
    for(size_t i=0;i<n;++i){
        LmxImplEntry row=ts[i].correspondence;
        catalog_token(a,f,at,ts[i].source_layout);
        catalog_token(a,f,at+1,ts[i].required_layout);
        catalog_size(a,f,at+2,row.n);
        for(size_t j=0;j<row.n;++j){
            size_t p;
            if(lmx_implements_at(a,&row,j,&p))abort();
            catalog_size(a,f,at+3+j,p);
            if(lmx_implements_at_last(a,&row,j,&p))abort();
            catalog_size(a,f,at+3+row.n+j,p);
        }
        at+=3+2*row.n;
    }
    return f;
}
static int admit(LmxArena *a,Lmx *v,Lmx *m,const LmxImplTemplate *ts,size_t n,LmxImplUses *u){
    if(!catalog_mode)return lmx_implements_admit_receiving_templates(a,v,m,ts,n,u);
    return lmx_implements_admit_template_frame(a,v,m,catalog(a,ts,n),u,1);
}
static int read_slot(LmxArena *a,Lmx *v,Lmx *req,size_t edge) {
    size_t p=(size_t)-1;
    ck(lmx_implements_slot(a,v,req,edge,&p)==0,"resolved slot exists");
    void *c=lmx_graph_value_in(a,v,p);
    ck(c && lmx_domain_type(a,c)==LMX_TYPE_INT,"resolved value is the actual int cell");
    return c ? *(int *)c : -10000;
}
static void scenario(int frame_mode,int bad,int extra,int unknown,int derived) {
    LmxArena a={0};
    ck(lmx_arena_open(&a)==0,"arena open");
    Lmx *ma=node(&a,2),*mb=node(&a,2),*m=node(&a,2);
    Lmx *ca=node(&a,2),*cb=node(&a,1),*v=node(&a,2);
    put(ma,0,num(&a,1));put(ma,1,num(&a,2));
    put(mb,0,num(&a,1));put(mb,1,num(&a,2));
    put(m,0,ma);put(m,1,mb);
    put(ca,0,num(&a,8));put(ca,1,num(&a,99));
    put(cb,0,bad ? lmx_size_new_owned(&a) : num(&a,9));
    put(v,0,cb);put(v,1,ca);
    layout(&a,m,tokens);layout(&a,ma,tokens+1);layout(&a,mb,tokens+2);
    layout(&a,v,tokens+3);layout(&a,cb,tokens+5);
    if(!unknown && !derived) layout(&a,ca,tokens+4);
    Lmx *source=NULL;
    if(derived){
        source=node(&a,2);
        put(source,0,num(&a,0));put(source,1,num(&a,0));
        layout(&a,source,tokens+6);
        ck(lmx_implements_register_map(&a,ca,source,identity,2,NULL)==LMX_IMPLEMENTS_YES,
           "bound source coordinates without inventing physical layout");
    }
    LmxImplTemplate ts[5];
    templ(ts,tokens+3,tokens,rev,2);
    templ(ts+1,derived?tokens+6:tokens+4,tokens+1,rev,2);
    templ(ts+2,tokens+5,tokens+2,thin,2);
    /* No matching source evidence: must not erase an earlier composed YES. */
    templ(ts+3,tokens+7,tokens+1,identity,2);
    size_t nt=derived?4:3;
    if(extra) {
        templ(ts+nt,tokens+4,tokens+1,identity,extra==2?1:2);
        ++nt;
    }
    if(frame_mode) {
        for(size_t i=0;i<nt;++i) {
            ts[i].correspondence.frame=pn_frame(&a,ts[i].correspondence.map,
                                               ts[i].correspondence.n*2);
            ts[i].correspondence.at=0;
            ts[i].correspondence.map=NULL;
        }
    }
    LmxImplUses u={0};
    if(frame_mode) u.frame=pn_frame(&a,scope,sizeof scope/sizeof *scope);
    else u.map=scope;
    size_t before=a.impl_len;
    LmxImplEntry *old=malloc(before*sizeof *old);
    if(!old) abort();
    memcpy(old,a.impl,before*sizeof *old);
    int r=admit(&a,v,m,ts,nt,&u);
    int success=!bad&&!extra&&!unknown;
    if(success) {
        ck(r==LMX_IMPLEMENTS_YES,"one walk admits separately scoped child views");
        if(r==LMX_IMPLEMENTS_YES) {
            ck(read_slot(&a,ca,ma,3)+read_slot(&a,cb,mb,2)-10==7,"A.y plus B.x is 7, not a flattened scope");
            size_t p;
            ck(lmx_implements_slot(&a,ca,ma,3,&p)==0&&p==0,"reordered A.y projects to physical zero once");
            void *cell=lmx_graph_value_in(&a,ca,p);
            ck(lmx_int_store_known(cell,18)==0,"write uses the same projected cell");
            ck(*(int *)lmx_graph_value_in(&a,ca,0)==18&&*(int *)lmx_graph_value_in(&a,ca,1)==99,
               "write changes only y, not neighboring x");
            void **address=lmx_graph_ref_cell_in(&a,ca,p);
            ck(address&&*address==cell,"taken address reaches the selected physical reference cell");
            void *replacement=num(&a,28);
            if(address) *address=replacement;
            ck(read_slot(&a,ca,ma,3)==28&&*(int *)cell==18,"dereference through taken address rebinds y only");
            ck(lmx_implements_find(&a,v,m)->reception_proof==1,"root keeps instruction-scoped, not forged full proof");
            ck(lmx_implements_find(&a,ca,ma)->reception_proof==1,"template's fake full proof is ignored");
            ck(lmx_implements_find(&a,ca,ma)->exec_map==NULL,"template callable map is not imported");
            ck(lmx_implements_find(&a,ca,ma)->owned_map==(derived!=0),
               "only a computed map transfers ownership, never borrowed template data");
            ck(lmx_implements_find(&a,cb,mb)->owned_map==0,"thin template map stays borrowed");
            if(derived) ck(lmx_implements_layout(&a,ca)==NULL,"composition does not guess candidate layout from its model");
        }
    } else {
        ck(r==(bad?LMX_IMPLEMENTS_NO:LMX_IMPLEMENTS_UNKNOWN),"bad used leaf or uncertain coordinates refuse");
        ck(a.impl_len==before&&!memcmp(old,a.impl,before*sizeof *old),"failure leaves ALL old records and proofs byte-identical");
        ck(lmx_implements_find(&a,v,m)==NULL&&lmx_implements_find(&a,ca,ma)==NULL&&
           lmx_implements_find(&a,cb,mb)==NULL,"failure publishes neither parent nor either child");
    }
    free(old);
    lmx_arena_release(&a);
}
static void deep_cycle(void) {
    LmxArena a={0};
    if(lmx_arena_open(&a)) abort();
    enum { N=36 };
    Lmx *m[N],*v[N];
    for(size_t i=0;i<N;++i) {m[i]=node(&a,2);v[i]=node(&a,2);}
    for(size_t i=0;i<N;++i) {
        put(m[i],0,m[(i+1)%N]);put(m[i],1,num(&a,1));
        put(v[i],0,num(&a,7));put(v[i],1,v[(i+1)%N]);
    }
    for(size_t i=0;i<N;++i) {layout(&a,m[i],tokens+8);layout(&a,v[i],tokens+9);}
    LmxImplTemplate t;templ(&t,tokens+9,tokens+8,rev,2);
    ck(admit(&a,v[0],m[0],&t,1,NULL)==LMX_IMPLEMENTS_YES,
       "36 cyclic nested projections terminate in the SAME triple/level walk");
    size_t p;
    for(size_t i=0;i<N;++i) {
        ck(lmx_implements_slot(&a,v[i],m[i],0,&p)==0&&p==1,"each cycle edge has its prepared child correspondence");
        ck(read_slot(&a,v[i],m[i],3)==7,"each cyclic leaf reads actual seven");
    }
    ck(lmx_implements_find(&a,v[0],m[0])->reception_proof==2,"full walk proves full root, not just coordinates");
    lmx_arena_release(&a);
}
static void pure_composition(void) {
    LmxArena a={0};
    if(lmx_arena_open(&a)) abort();
    Lmx *s=pn_node(&a,num(&a,1),num(&a,2));
    Lmx *t=pn_node(&a,num(&a,3),num(&a,4));
    Lmx *v=pn_node(&a,num(&a,7),num(&a,9));
    layout(&a,s,tokens+10);layout(&a,t,tokens+11);
    ck(lmx_implements_register_map(&a,v,s,rev,2,NULL)==LMX_IMPLEMENTS_YES,"source admission prepared for composition test");
    LmxImplEntry pair={0},out;
    pair.req=t;pair.value=s;pair.n=2;pair.map=rev;
    size_t before=a.impl_len;
    LmxImplEntry saved_pair=pair;
    int applied=-1;
    ck(lmx_implements_compose_view(&a,v,tokens+10,t,&pair,&pair,&applied)==LMX_IMPLEMENTS_UNKNOWN&&
       applied==0&&!memcmp(&pair,&saved_pair,sizeof pair),"pure output may not alias input");
    LmxImplEntry *kept=lmx_implements_find(&a,v,s),saved=*kept;
    ck(lmx_implements_compose_view(&a,v,tokens+10,t,&pair,kept,&applied)==LMX_IMPLEMENTS_UNKNOWN&&
       applied==0&&!memcmp(kept,&saved,sizeof saved),"pure output may not alias proof table");
    ck(lmx_implements_compose_view(&a,v,tokens+10,t,&pair,&out,&applied)==LMX_IMPLEMENTS_YES&&
       applied==1&&out.owned_map==1&&out.reception_proof==0,"composition prepares coordinates, never proof");
    ck(a.impl_len==before&&lmx_implements_find(&a,v,t)==NULL,"pure composition retains nothing");
    size_t p;
    ck(lmx_implements_at(&a,&out,0,&p)==0&&p==0&&
       lmx_implements_at_last(&a,&out,1,&p)==0&&p==1,"both ordinal and last halves compose once");
    free(out.map);
    lmx_arena_release(&a);
}
/* Known physical layout must not disable composition through a bound model.
   Existing root coordinates must also be staged when children are new. */
static void root_transport(int frame_mode,int composed) {
    LmxArena a={0};
    if(lmx_arena_open(&a))abort();
    Lmx *ma=node(&a,2),*mb=node(&a,2),*m=node(&a,2),*source=node(&a,2);
    Lmx *ca=node(&a,2),*cb=node(&a,1),*v=node(&a,2);
    put(ma,0,num(&a,1));put(ma,1,num(&a,2));
    put(mb,0,num(&a,1));put(mb,1,num(&a,2));
    put(m,0,ma);put(m,1,mb);put(source,0,ma);put(source,1,mb);
    put(ca,0,num(&a,8));put(ca,1,num(&a,99));put(cb,0,num(&a,9));
    put(v,0,cb);put(v,1,ca);
    layout(&a,m,tokens);layout(&a,ma,tokens+1);layout(&a,mb,tokens+2);
    layout(&a,v,tokens+3);layout(&a,ca,tokens+4);layout(&a,cb,tokens+5);
    layout(&a,source,tokens+7);
    LmxImplUses u={0};
    if(frame_mode)u.frame=pn_frame(&a,scope,sizeof scope/sizeof *scope);
    else u.map=scope;
    if(composed){
        LmxImplEntry pending[3]={0};
        pending[0].value=v;pending[0].req=source;pending[0].map=rev;pending[0].n=2;
        pending[0].layout=tokens+3;
        pending[1].value=ca;pending[1].req=ma;pending[1].map=rev;pending[1].n=2;
        pending[1].layout=tokens+4;
        pending[2].value=cb;pending[2].req=mb;pending[2].map=thin;pending[2].n=2;
        pending[2].layout=tokens+5;
        ck(lmx_implements_admit_receiving_views(&a,v,source,pending,3,&u)==LMX_IMPLEMENTS_YES,
           "source basis is genuinely admitted with the same scoped walk");
    }else{
        size_t empty[]={2,0};
        LmxImplUses identity_use={0};identity_use.map=empty;
        LmxImplEntry root={0};
        root.value=v;root.req=m;root.map=rev;root.n=2;root.layout=tokens+3;
        ck(lmx_implements_admit_receiving(&a,v,m,&root,&identity_use)==LMX_IMPLEMENTS_YES,
           "prior identity-only Consumer admitted known root coordinates, not a full proof");
        ck(lmx_implements_find(&a,ca,ma)==NULL,"child evidence is still absent");
    }
    LmxImplTemplate ts[3];
    templ(ts,composed?tokens+7:tokens+3,tokens,composed?identity:rev,2);
    templ(ts+1,tokens+4,tokens+1,rev,2);
    templ(ts+2,tokens+5,tokens+2,thin,2);
    if(frame_mode)for(size_t i=0;i<3;++i){
        ts[i].correspondence.frame=pn_frame(&a,ts[i].correspondence.map,4);
        ts[i].correspondence.map=NULL;
    }
    int r=admit(&a,v,m,ts,3,&u);
    ck(r==LMX_IMPLEMENTS_YES,"root and children resolve in one context without caller's root seed");
    if(r==LMX_IMPLEMENTS_YES){
        LmxImplEntry *root=lmx_implements_find(&a,v,m);
        ck(root&&root->layout==tokens+3&&root->reception_proof==1,
           "root keeps genuine physical layout and only scoped proof");
        ck(root&&root->owned_map==(composed!=0),"only composed root owns computed coordinates");
        ck(read_slot(&a,ca,ma,3)+read_slot(&a,cb,mb,2)-10==7,"composed root retains actual seven");
        size_t p=(size_t)-1;
        ck(lmx_implements_slot(&a,v,m,2,&p)==0&&p==1,"root A projects to physical one once");
        Lmx *selected=lmx_graph_value_in(&a,v,p);
        ck(selected==ca,"root route reaches actual A, not Model constructor");
        ck(lmx_implements_slot(&a,selected,ma,3,&p)==0&&p==0,"child y projects to physical zero");
        void *cell=lmx_graph_value_in(&a,selected,p);
        ck(lmx_int_store_known(cell,18)==0,"write through nested root route succeeds");
        void **address=lmx_graph_ref_cell_in(&a,selected,p);
        ck(address&&*address==cell,"taken nested address is the actual physical cell");
        if(address)*address=num(&a,28);
        ck(read_slot(&a,ca,ma,3)==28&&*(int *)cell==18&&
           *(int *)lmx_graph_value_in(&a,ca,1)==99,"address rebind changes only selected child field");
    }
    lmx_arena_release(&a);
}
static void identity_does_not_invent_coordinates(int frame_mode) {
    LmxArena a={0};
    if(lmx_arena_open(&a))abort();
    Lmx *m=node(&a,2),*v=node(&a,2);
    put(m,0,num(&a,1));put(m,1,num(&a,2));
    put(v,0,num(&a,8));put(v,1,num(&a,7));
    layout(&a,m,tokens);
    LmxImplTemplate t;templ(&t,tokens+3,tokens,rev,2);
    size_t none[]={2,0},x[]={4,1,2,0},y[]={4,1,3,0};
    LmxImplUses u={0};
    if(frame_mode){
        t.correspondence.frame=pn_frame(&a,rev,4);t.correspondence.map=NULL;
        u.frame=pn_frame(&a,none,2);
    }else u.map=none;
    size_t before=a.impl_len;
    ck(admit(&a,v,m,&t,1,&u)==LMX_IMPLEMENTS_YES,
       "identity-only use needs no field correspondence");
    ck(a.impl_len==before&&lmx_implements_find(&a,v,m)==NULL,
       "identity-only use publishes neither guessed positions nor full proof");
    if(frame_mode)u.frame=pn_frame(&a,x,4);else u.map=x;
    ck(admit(&a,v,m,&t,1,&u)==LMX_IMPLEMENTS_UNKNOWN,
       "unknown actual layout is not inferred from requirement constructor");
    ck(a.impl_len==before&&lmx_implements_find(&a,v,m)==NULL,"unknown path remains publication-free");
    layout(&a,v,tokens+3);
    ck(admit(&a,v,m,&t,1,&u)==LMX_IMPLEMENTS_YES,
       "later genuine layout permits ordinary reception without poisoned old record");
    ck(read_slot(&a,v,m,2)==7,"later x reads candidate seven, not Model one or physical y");
    if(frame_mode)u.frame=pn_frame(&a,y,4);else u.map=y;
    ck(admit(&a,v,m,&t,1,&u)==LMX_IMPLEMENTS_YES,
       "existing exact root supports later y scope");
    ck(read_slot(&a,v,m,3)==8,"later y uses the same correct complete correspondence");
    lmx_arena_release(&a);
}
static void frame_current_graph(void){
    LmxArena a={0};
    if(lmx_arena_open(&a))abort();
    Lmx *m=node(&a,2),*v=node(&a,2);
    put(m,0,num(&a,1));put(m,1,num(&a,2));
    put(v,0,num(&a,8));put(v,1,num(&a,7));
    layout(&a,m,tokens);layout(&a,v,tokens+3);
    LmxImplTemplate t;templ(&t,tokens+3,tokens,rev,2);
    Lmx *old=catalog(&a,&t,1),*copy=NULL;
    ck(lmx_graph_copy_owned(old,&a,&a,&copy)==0&&copy&&copy!=old,
       "catalog is ordinary copyable current graph data");
    if(!copy){lmx_arena_release(&a);return;}
    ck(lmx_graph_value_in(&a,copy,4)!=lmx_graph_value_in(&a,old,4),
       "copied catalog map has independent numeric cells");
    catalog_size(&a,old,4,0);catalog_size(&a,old,6,0);
    ck(lmx_implements_admit_template_frame(&a,v,m,copy,NULL,1)==LMX_IMPLEMENTS_YES,
       "admission consumes selected copy, not an ancestor catalog");
    LmxImplEntry *e=lmx_implements_find(&a,v,m);
    ck(e&&e->frame==copy&&!e->map&&!e->owned_map,"retained view borrows actual current copied frame");
    ck(read_slot(&a,v,m,2)==7,"ancestor edit does not replace selected copied map");
    catalog_size(&a,copy,6,0); /* current LAST x coordinate, both cells int */
    ck(read_slot(&a,v,m,2)==8,"later coordinate read uses current selected graph, not a static snapshot");
    size_t p=(size_t)-1;
    ck(lmx_implements_slot(&a,v,m,0,&p)==0&&p==1,"untouched ordinal x still projects once to physical one");
    void **address=lmx_graph_ref_cell_in(&a,v,p);
    ck(address&&*address==lmx_graph_value_in(&a,v,1),"address is physical after the one projection");
    if(address)*address=num(&a,27);
    ck(*(int *)lmx_graph_value_in(&a,v,1)==27&&read_slot(&a,v,m,2)==8,
       "address write affects the physical target, not the independently edited LAST projection");
    lmx_arena_release(&a);
}
static void coordinate_and_frame_refusals(void){
    LmxArena a={0};
    if(lmx_arena_open(&a))abort();
    Lmx *m=node(&a,2),*v=node(&a,1);
    put(m,0,num(&a,1));put(m,1,num(&a,2));put(v,0,num(&a,7));
    layout(&a,m,tokens);layout(&a,v,tokens+3);
    LmxImplTemplate t;templ(&t,tokens+3,tokens,thin,2);
    Lmx *frame=catalog(&a,&t,1);
    ck(lmx_implements_admit_template_frame(&a,v,m,frame,NULL,0)==LMX_IMPLEMENTS_YES,
       "coordinate mode uses same resolver and may retain explicit absent unconsumed fields");
    LmxImplEntry *entry=lmx_implements_find(&a,v,m);
    ck(entry&&entry->reception_proof==0,"coordinate preparation grants no receiving permission");
    ck(read_slot(&a,v,m,2)==7,"coordinate-only map still identifies actual x");
    size_t before=a.impl_len;
    LmxImplEntry *saved=malloc(before*sizeof *saved);
    if(!saved)abort();memcpy(saved,a.impl,before*sizeof *saved);
    ck(lmx_implements_admit_template_frame(&a,v,m,frame,NULL,1)==LMX_IMPLEMENTS_NO,
       "no Consumer remains full fitness, not coordinate-mode permission");
    ck(a.impl_len==before&&!memcmp(saved,a.impl,before*sizeof *saved),"full refusal does not upgrade any old proof");
    size_t x[]={4,1,2,0};LmxImplUses uses={0};uses.map=x;
    ck(lmx_implements_admit_template_frame(&a,v,m,frame,&uses,0)==LMX_IMPLEMENTS_UNKNOWN,
       "coordinate mode cannot silently consume a receiving coverage");
    for(int bad=0;bad<8;++bad){
        Lmx *f=catalog(&a,&t,1);
        if(bad==0)catalog_size(&a,f,0,SIZE_MAX);
        if(bad==1)catalog_size(&a,f,0,0); /* trailing cells */
        if(bad==2)catalog_size(&a,f,3,SIZE_MAX);
        if(bad==3)put(f,1,num(&a,1));
        if(bad==4)catalog_token(&a,f,2,NULL);
        if(bad==5)put(f,7,num(&a,1));
        if(bad==6)catalog_size(&a,f,3,1); /* row extent disagrees */
        if(bad==7)catalog_token(&a,f,1,NULL);
        ck(lmx_implements_admit_template_frame(&a,v,m,f,&uses,1)==LMX_IMPLEMENTS_UNKNOWN,
           "malformed catalog refuses without selecting another route");
        ck(a.impl_len==before&&!memcmp(saved,a.impl,before*sizeof *saved),"malformed catalog publishes no partial state");
    }
    ck(lmx_implements_admit_template_frame(&a,v,m,frame,&uses,1)==LMX_IMPLEMENTS_YES,
       "legitimate partial receiving still succeeds through common frame adapter");
    ck(lmx_implements_find(&a,v,m)->reception_proof==1,"only the actual receiving operation upgrades partial proof");
    Lmx *empty=node(&a,1);catalog_size(&a,empty,0,0);
    ck(lmx_implements_admit_template_frame(&a,v,m,empty,&uses,1)==LMX_IMPLEMENTS_YES,
       "empty catalog can use genuinely existing exact correspondence");
    free(saved);lmx_arena_release(&a);
}
int main(void) {
    int old=inherited_pending_views_main();
    ck(old==0,"all inherited pending-map and transactional assertions still pass");
    for(catalog_mode=0;catalog_mode<2;++catalog_mode){
      for(int f=0;f<2;++f) {
        scenario(f,0,0,0,0);
        scenario(f,1,0,0,0);
        scenario(f,0,1,0,0);
        scenario(f,0,2,0,0);
        scenario(f,0,0,1,0);
        scenario(f,0,0,0,1);
        scenario(f,1,0,0,1);
        root_transport(f,0);
        root_transport(f,1);
        identity_does_not_invent_coordinates(f);
      }
      deep_cycle();
    }
    pure_composition();
    frame_current_graph();
    coordinate_and_frame_refusals();
    printf("prepared templates kernel: %d checks, %d failures\n",checks,failures);
    return failures!=0;
}
