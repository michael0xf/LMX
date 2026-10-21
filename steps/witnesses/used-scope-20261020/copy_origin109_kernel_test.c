#ifndef COPY_KERNEL_SOURCE
#define COPY_KERNEL_SOURCE "lmx_implements_pending_views_selftest.c"
#endif
#define main inherited_copy_kernel_main
#include COPY_KERNEL_SOURCE
#undef main

static int c106_checks,c106_failures;
static void c106_check(int good,const char *why){
    ++c106_checks;
    if(!good){++c106_failures;fprintf(stderr,"FAIL copy root: %s\n",why);}
}
static Lmx *c106_node(LmxArena *a,size_t n){
    Lmx *v=lmx_node_new_owned(a);
    if(!v||lmx_arena_refs_open_owned(a,v,n))abort();
    return v;
}
static void *c106_num(LmxArena *a,int n){
    void *v=lmx_int_new_owned(a);
    if(!v||lmx_int_store_known(v,n))abort();
    return v;
}
static void c106_put(Lmx *v,size_t i,void *p){
    if(lmx_arena_ref_store(v,i,p))abort();
}
static void c106_known_map(LmxArena *a,Lmx *v,Lmx *req,size_t *map,size_t n){
    LmxImplEntry e={0};e.map=map;e.n=n;
    if(lmx_implements_admit_receiving(a,v,req,&e,NULL)!=LMX_IMPLEMENTS_YES)abort();
}
static int c106_read(LmxArena *a,Lmx *v,Lmx *req,size_t edge){
    size_t p=(size_t)-1;
    if(lmx_implements_slot(a,v,req,edge,&p))return -10000;
    void *cell=lmx_graph_value_in(a,v,p);
    return cell&&lmx_domain_type(a,cell)==LMX_TYPE_INT?lmx_int_value_known(cell):-10000;
}
int main(void){
    LmxArena arena={0};LmxArena *a=&arena;
    if(lmx_arena_open(a))abort();
    const size_t u=(size_t)-1;
    size_t dm[]={0,u,1,u,0,u,1,u},em[]={1,u,0,u,1,u,0,u};
    Lmx *d=c106_node(a,4),*e=c106_node(a,4),*v=c106_node(a,2),*copy=NULL;
    for(size_t i=0;i<4;i+=2){c106_put(d,i,c106_num(a,(int)i));c106_put(e,i,c106_num(a,(int)i));}
    c106_put(v,0,c106_num(a,7));c106_put(v,1,c106_num(a,9));
    c106_known_map(a,v,d,dm,4);c106_known_map(a,v,e,em,4);
    c106_check(lmx_implements_layout(a,v)==NULL,"source has no physical-layout token to guess from");
    c106_check(c106_read(a,v,d,0)==7&&c106_read(a,v,e,0)==9,"two admitted current views select different actual cells");
    c106_check(lmx_graph_copy_owned(v,a,a,&copy)==LMX_GRAPH_COPY_OK&&copy&&copy!=v,"ordinary graph copy succeeds with a fresh root");
    LmxImplEntry *ce=copy?lmx_implements_find(a,copy,e):NULL;
    LmxImplEntry *cd=copy?lmx_implements_find(a,copy,d):NULL;
    c106_check(ce&&cd,"both receiving correspondences survive the same relocation map");
    c106_check(ce&&ce->n==4&&ce->map&&ce->map[0]==1&&ce->map[4]==1,"both halves retain Model width4 over physical width2");
    c106_check(cd&&cd->n==4&&cd->map&&cd->map[0]==0&&cd->map[4]==0,"the other view is not overwritten by the first");
    c106_check(ce&&cd&&ce->reception_proof==2&&cd->reception_proof==2,"a complete unabsorbed copy preserves its source admission proof");
    c106_check(ce&&cd&&!ce->layout&&!cd->layout,"copying a logical view fabricates no physical-layout token");
    c106_check(c106_read(a,copy,e,0)==9&&c106_read(a,copy,e,4)==9,"ordinal and LAST reads consume the copied reordered view");
    size_t physical=(size_t)-1;
    int selected=copy&&lmx_implements_slot(a,copy,e,0,&physical)==0;
    void *cell=selected?lmx_graph_value_in(a,copy,physical):NULL;
    c106_check(selected&&cell&&lmx_int_store_known(cell,41)==0&&c106_read(a,copy,e,0)==41,"write reaches the actual copied receiving cell");
    c106_check(c106_read(a,copy,d,0)==7,"reordered write leaves the neighboring copied field unchanged");
    void **address=selected?lmx_graph_ref_cell_in(a,copy,physical):NULL;
    c106_check(address&&*address==cell,"taken address names the selected physical reference cell");
    if(address)*address=c106_num(a,43);
    c106_check(c106_read(a,copy,e,0)==43&&c106_read(a,copy,e,4)==43,"dereferencing the taken address changes the same mapped value");
    c106_check(c106_read(a,v,e,0)==9&&c106_read(a,v,d,0)==7,"copy writes and address rebinding never mutate the source");

    Lmx *self=c106_node(a,2),*selfcopy=NULL;size_t identity[]={0,1,0,1};
    char physical_layout,fresh_layout;
    c106_put(self,0,c106_num(a,11));c106_put(self,1,c106_num(a,12));
    if(lmx_implements_register_map(a,self,self,NULL,0,&physical_layout)!=LMX_IMPLEMENTS_YES)abort();
    c106_known_map(a,self,self,identity,2);
    c106_check(lmx_graph_copy_owned(self,a,a,&selfcopy)==LMX_GRAPH_COPY_OK&&selfcopy!=self,"a Model that is also its value is copied once");
    LmxImplEntry *selfview=selfcopy?lmx_implements_find(a,selfcopy,selfcopy):NULL;
    c106_check(selfview&&selfview->req==selfcopy&&selfview->value==selfcopy&&selfview->reception_proof==2,"copied requirement and value use their common relocated identity");
    c106_check(lmx_merge_result_layout(a,selfcopy,&self,1,&fresh_layout,NULL)==LMX_IMPLEMENTS_YES,"common merge finalization accepts the copied result's already-proved physical origin");
    selfview=lmx_implements_find(a,selfcopy,selfcopy);
    c106_check(lmx_implements_layout(a,selfcopy)==&physical_layout&&selfview&&selfview->reception_proof==2,"finalization neither overwrites the physical token nor downgrades the copied admission proof");

    Lmx *absorbed=c106_node(a,2);LmxCopyMap relocation={0},wholes={0};
    if(lmx_copy_map_init(&relocation)||lmx_copy_map_init(&wholes)||lmx_copy_map_put(&relocation,v,absorbed))abort();
    c106_check(lmx_copy_carry_records(&v,1,a,a,&relocation,&wholes,0,0,1)==LMX_GRAPH_COPY_OK,"absorbed-root carry keeps its existing guarded policy");
    c106_check(!lmx_implements_find(a,absorbed,d)&&!lmx_implements_find(a,absorbed,e),"absorption does not copy an unrelated full-root admission proof");
    lmx_copy_map_dispose(&relocation);lmx_copy_map_dispose(&wholes);
    lmx_arena_release(a);
    printf("unabsorbed root carry: %d checks, %d failures\n",c106_checks,c106_failures);
    return c106_failures!=0;
}
