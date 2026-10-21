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
    if(!v||(n&&lmx_arena_refs_open_owned(a,v,n)))abort();
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
static int inherited_root_checks(void){
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

static int r111_checks,r111_failures;
static void r111_check(int yes,const char *why){
    ++r111_checks;
    if(!yes){++r111_failures;fprintf(stderr,"FAIL final copy map: %s\n",why);}
}
static int r111_merge(LmxArena *a,Lmx **ops,size_t n,Lmx *body,
                     LmxMergePair **pairs,size_t count,Lmx **out,LmxCopyMap *map){
    return lmx_merge_used_relocated_profiled_owned(ops,n,body,a,a,NULL,0,
        NULL,NULL,NULL,NULL,0,0,pairs,count,NULL,out,map);
}
static int r111_num(LmxArena *a,Lmx *node,size_t i){
    void *cell=lmx_graph_value_in(a,node,i);
    return cell&&lmx_domain_type(a,cell)==LMX_TYPE_INT?lmx_int_value_known(cell):-10000;
}
static void r113_refuses_unchanged(LmxCopyMap *raw,LmxCopyMap *projection,void *key1,void *key2,const char *why){
    void *before1=lmx_copy_map_get(raw,key1),*before2=lmx_copy_map_get(raw,key2);
    size_t before_n=raw->n;
    int answer=lmx_graph_copy_map_project(raw,projection);
    r111_check(answer==LMX_GRAPH_COPY_INVALID&&raw->n==before_n&&
        lmx_copy_map_get(raw,key1)==before1&&lmx_copy_map_get(raw,key2)==before2,why);
    /* Restore the independent next control even if an old kernel changed it. */
    if(lmx_copy_map_put(raw,key1,before1)||lmx_copy_map_put(raw,key2,before2))abort();
}
int main(void){
    int inherited=inherited_root_checks();
    LmxArena arena={0};LmxArena *a=&arena;
    if(lmx_arena_open(a))abort();
    Lmx *source=c106_node(a,2),*copy=NULL,*external=c106_node(a,0);
    void *one=c106_num(a,7),*two=c106_num(a,9);
    c106_put(source,0,one);c106_put(source,1,two);
    LmxCopyMap moved={0};
    r111_check(r111_merge(a,&source,1,NULL,NULL,0,&copy,&moved)==LMX_MERGE_OK&&copy&&copy!=source,
               "one ordinary copy returns its existing relocation map");
    r111_check(lmx_copy_map_get(&moved,source)==copy,"Model=value relocates by exact identity to the returned root");
    void **address=lmx_copy_map_get(&moved,lmx_graph_ref_cell_in(a,source,0));
    r111_check(address==lmx_graph_ref_cell_in(a,copy,0),"a source address denotes the actual result's physical slot");
    r111_check(lmx_copy_map_get(&moved,one)==lmx_graph_value_in(a,copy,0),"a primitive value and its reference slot are distinct relocated identities");
    r111_check(!lmx_copy_map_get(&moved,external),"an unrelated external Model is absent,not guessed from another admission");
    if(address)*address=c106_num(a,41);
    r111_check(r111_num(a,copy,0)==41&&r111_num(a,source,0)==7,"writing through the exported address changes only the copied value");
    lmx_graph_copy_map_dispose(&moved);
    r111_check(r111_num(a,copy,0)==41,"disposing transient metadata does not dispose the graph");

    Lmx *host=c106_node(a,2),*model=c106_node(a,2);
    model->parent=host;c106_put(host,0,model);c106_put(host,1,model);
    c106_put(model,0,host);c106_put(model,1,c106_num(a,9));
    copy=NULL;
    r111_check(r111_merge(a,&host,1,NULL,NULL,0,&copy,&moved)==LMX_MERGE_OK&&copy,
               "a Model inside its value uses the same cyclic graph copy");
    Lmx *newmodel=lmx_copy_map_get(&moved,model);
    r111_check(newmodel&&newmodel!=model&&newmodel==lmx_graph_value_in(a,copy,0),"the exact embedded Model address is projected,not the old namespace");
    r111_check(newmodel==lmx_graph_value_in(a,copy,1),"two aliases to that Model remain one copy");
    r111_check(newmodel&&newmodel->parent==copy&&lmx_graph_value_in(a,newmodel,0)==copy,
               "Model/value parent and back-edge use the same root identity");
    address=lmx_copy_map_get(&moved,lmx_graph_ref_cell_in(a,model,1));
    r111_check(address==lmx_graph_ref_cell_in(a,newmodel,1),"the Model's own cell address is relocated without another lookup");
    if(address)*address=c106_num(a,43);
    r111_check(r111_num(a,newmodel,1)==43&&r111_num(a,model,1)==9,"address writes preserve the original current Model");
    lmx_graph_copy_map_dispose(&moved);

    Lmx *arrayhost=c106_node(a,2),*element=c106_node(a,2);
    LmxArray *array=lmx_array_ref_new_child_profiled(arrayhost,LMX_TYPE_ARRAY_OF_LMX,2,a,NULL);
    if(!array)abort();element->parent=(Lmx *)array;
    c106_put(element,0,c106_num(a,11));c106_put(element,1,c106_num(a,12));
    c106_put(arrayhost,0,array);c106_put(arrayhost,1,element);
    if(lmx_graph_ref_store_in(a,(Lmx *)array,0,element)||lmx_graph_ref_store_in(a,(Lmx *)array,1,element))abort();
    copy=NULL;
    r111_check(r111_merge(a,&arrayhost,1,NULL,NULL,0,&copy,&moved)==LMX_MERGE_OK&&copy,
               "an indexed reference and its Model participate in the same copy");
    Lmx *newarray=lmx_copy_map_get(&moved,array);newmodel=lmx_copy_map_get(&moved,element);
    r111_check(newarray&&newarray==lmx_graph_value_in(a,copy,0)&&lmx_range_classify(a,newarray)==LMX_KIND_ARRAY,
               "the Array header keeps its own copied identity");
    r111_check(newmodel&&newmodel==lmx_graph_value_in(a,newarray,0)&&newmodel==lmx_graph_value_in(a,newarray,1)&&
               newmodel==lmx_graph_value_in(a,copy,1)&&newmodel->parent==newarray,
               "indexed and direct aliases reach one relocated Model,not another instance");
    address=lmx_copy_map_get(&moved,lmx_graph_cell_in(a,(Lmx *)array,1));
    r111_check(address==lmx_graph_cell_in(a,newarray,1),"an element-cell address is in that same returned map");
    Lmx *new_element=c106_node(a,2);c106_put(new_element,0,c106_num(a,43));
    if(address)*address=new_element;
    r111_check(lmx_graph_value_in(a,newarray,1)==new_element&&lmx_graph_value_in(a,newarray,0)==newmodel&&
               lmx_graph_value_in(a,copy,1)==newmodel,"an indexed address writes exactly its copied reference cell");
    r111_check(lmx_graph_value_in(a,(Lmx *)array,1)==element&&r111_num(a,element,0)==11,
               "indexed copy/address operations leave the original value and Model unchanged");
    lmx_graph_copy_map_dispose(&moved);

    Lmx *left=c106_node(a,1),*right=c106_node(a,1),*shared=c106_node(a,0);
    Lmx *ops[]={left,right};c106_put(left,0,shared);c106_put(right,0,shared);copy=NULL;
    r111_check(r111_merge(a,ops,2,NULL,NULL,0,&copy,&moved)==LMX_MERGE_OK&&copy,
               "ordinary composition exports its final receiving projection");
    r111_check(lmx_copy_map_get(&moved,left)==copy&&lmx_copy_map_get(&moved,right)==copy,
               "both absorbed operand roots map to the final result,not discarded roots");
    r111_check(lmx_copy_map_get(&moved,shared)==lmx_graph_value_in(a,copy,0)&&
               lmx_graph_value_in(a,copy,0)==lmx_graph_value_in(a,copy,1),"shared declared objects across operands are copied once");
    void **laddr=lmx_copy_map_get(&moved,lmx_graph_ref_cell_in(a,left,0));
    void **raddr=lmx_copy_map_get(&moved,lmx_graph_ref_cell_in(a,right,0));
    r111_check(laddr==lmx_graph_ref_cell_in(a,copy,0)&&raddr==lmx_graph_ref_cell_in(a,copy,1),
               "source cells map to final placed result slots after absorption");
    Lmx *replacement=c106_node(a,0);if(raddr)*raddr=replacement;
    r111_check(lmx_graph_value_in(a,copy,1)==replacement&&lmx_graph_value_in(a,copy,0)!=replacement&&
               lmx_graph_value_in(a,right,0)==shared,"a composed address changes exactly its result field");
    lmx_graph_copy_map_dispose(&moved);

    Lmx *decl=c106_node(a,2),*later=c106_node(a,2);
    c106_put(decl,0,c106_num(a,10));c106_put(decl,1,c106_num(a,20));
    c106_put(later,0,c106_num(a,90));c106_put(later,1,c106_num(a,80));
    Lmx *reordered[]={decl,later};LmxMergePair pa={0,1,1},pb={1,1,0};LmxMergePair *pairs[]={&pa,&pb};copy=NULL;
    r111_check(r111_merge(a,reordered,2,NULL,pairs,2,&copy,&moved)==LMX_MERGE_OK&&copy,
               "reordered specialization uses that same exported map");
    r111_check(r111_num(a,copy,0)==80&&r111_num(a,copy,1)==90,"the actual override values are in their final physical order");
    laddr=lmx_copy_map_get(&moved,lmx_graph_ref_cell_in(a,later,0));
    raddr=lmx_copy_map_get(&moved,lmx_graph_ref_cell_in(a,later,1));
    r111_check(laddr==lmx_graph_ref_cell_in(a,copy,1)&&raddr==lmx_graph_ref_cell_in(a,copy,0),
               "later source addresses follow the prepared field permutation");
    if(laddr)*laddr=c106_num(a,91);
    r111_check(r111_num(a,copy,0)==80&&r111_num(a,copy,1)==91&&r111_num(a,later,0)==90,
               "dereferencing a reordered address changes its real result value only");
    lmx_graph_copy_map_dispose(&moved);

    Lmx *body=c106_node(a,1);c106_put(body,0,c106_num(a,3));copy=NULL;
    r111_check(r111_merge(a,&source,1,body,NULL,0,&copy,&moved)==LMX_MERGE_OK&&copy,
               "an appended body participates in the same ordinary composition");
    r111_check(lmx_copy_map_get(&moved,source)==copy&&lmx_copy_map_get(&moved,body)==copy,
               "operand and body roots both name the final receiving root");
    address=lmx_copy_map_get(&moved,lmx_graph_ref_cell_in(a,body,0));
    r111_check(address==lmx_graph_ref_cell_in(a,copy,2)&&r111_num(a,copy,2)==3,
               "a body's source cell maps to its final appended physical slot");
    if(address)*address=c106_num(a,33);
    r111_check(r111_num(a,copy,2)==33&&r111_num(a,body,0)==3&&r111_num(a,source,0)==7,
               "body address writes leave both original roots unchanged");
    lmx_graph_copy_map_dispose(&moved);

    Lmx *profile=c106_node(a,0),*kept=lmx_node_new_profiled(a,profile);
    if(!kept||lmx_arena_seal_profile(a,profile))abort();
    Lmx *profiles[]={profile};copy=NULL;
    r111_check(lmx_merge_used_relocated_profiled_owned(&kept,1,NULL,a,a,profiles,1,
                   NULL,NULL,NULL,NULL,0,0,NULL,0,NULL,&copy,&moved)==LMX_MERGE_OK&&copy==kept,
               "exact-profile retention returns the unchanged occurrence through the same API");
    r111_check(!moved.n&&!lmx_copy_map_get(&moved,kept),
               "a retained address is not falsely reported as a newly copied identity");
    lmx_graph_copy_map_dispose(&moved);
    r111_check(lmx_range_classify(a,kept)==LMX_KIND_STRUCT&&!kept->parent&&!kept->array.size,
               "disposing a retained operation's transient map does not mutate or release its graph");

    int old1,old2,p0,p1,p2;LmxCopyMap raw={0},projection={0},empty={0};
    if(lmx_copy_map_init(&raw)||lmx_copy_map_init(&projection)||
       lmx_copy_map_put(&raw,&old1,&p0)||lmx_copy_map_put(&raw,&old2,&p1)||
       lmx_copy_map_put(&projection,&p0,&p1)||lmx_copy_map_put(&projection,&p1,&p2))abort();
    r111_check(lmx_graph_copy_map_project(&raw,&projection)==LMX_GRAPH_COPY_OK,
               "one physical projection applies to a generic source map");
    r111_check(lmx_copy_map_get(&raw,&old1)==&p1&&lmx_copy_map_get(&raw,&old2)==&p2,
               "already physical addresses are not projected transitively a second time");
    r111_check(raw.n==2,"source keys and the map's occupancy are unchanged");
    r111_check(lmx_graph_copy_map_project(&raw,&empty)==LMX_GRAPH_COPY_OK&&lmx_copy_map_get(&raw,&old1)==&p1,
               "an empty receiving projection preserves physical coordinates");
    raw.n++;
    r111_check(lmx_graph_copy_map_project(&raw,&projection)==LMX_GRAPH_COPY_INVALID&&
               lmx_copy_map_get(&raw,&old1)==&p1,"invalid inventory is rejected before any partial projection");
    raw.n--;
    r111_check(lmx_graph_copy_map_project(&raw,&raw)==LMX_GRAPH_COPY_INVALID&&lmx_copy_map_get(&raw,&old1)==&p1,
               "an identity map is not silently reused as its own receiving projection");
    r111_check(lmx_graph_copy_map_project(&empty,&projection)==LMX_GRAPH_COPY_OK&&!empty.n,
               "a fully retained operation has a valid empty copied-address map");
    LmxCopyMap malformed=projection;
    malformed.n++;
    r113_refuses_unchanged(&raw,&malformed,&old1,&old2,"projection occupancy is validated before any exported value changes");
    malformed=projection;malformed.vals.capacity--;
    r113_refuses_unchanged(&raw,&malformed,&old1,&old2,"projection value capacity must agree with key capacity");
    malformed=projection;malformed.keys.array.size--;
    r113_refuses_unchanged(&raw,&malformed,&old1,&old2,"projection key extent is not an unchecked second counter");
    malformed=projection;malformed.vals.array.size--;
    r113_refuses_unchanged(&raw,&malformed,&old1,&old2,"projection value extent must describe the same inventory");
    malformed=projection;malformed.keys.array.data=NULL;
    r113_refuses_unchanged(&raw,&malformed,&old1,&old2,"nonempty projection without key storage cannot silently become identity");
    malformed=projection;malformed.n=lmx_copy_map_keys_cap(&projection);
    r113_refuses_unchanged(&raw,&malformed,&old1,&old2,"a probe table must retain a genuine empty bucket");
    void *bad_keys[3]={0},*bad_values[3]={0};malformed=(LmxCopyMap){0};
    malformed.keys.array.data=bad_keys;malformed.vals.array.data=bad_values;
    malformed.keys.array.size=malformed.keys.capacity=3;malformed.vals.array.size=malformed.vals.capacity=3;
    r113_refuses_unchanged(&raw,&malformed,&old1,&old2,"a malformed probe capacity is rejected by representation,not a language depth bound");
    void **pkeys=lmx_copy_map_keys_data(&projection),**pvals=lmx_copy_map_vals_data(&projection);
    size_t pcap=lmx_copy_map_keys_cap(&projection),bucket=lmx_copy_hash(&p0,pcap);
    while(pkeys[bucket]!=&p0)bucket=(bucket+1)&(pcap-1);
    void *saved=pvals[bucket];pvals[bucket]=NULL;
    r113_refuses_unchanged(&raw,&projection,&old1,&old2,"an unqueried malformed projection row still prevents partial mutation");
    pvals[bucket]=saved;
    raw.keys.array.size--;
    r113_refuses_unchanged(&raw,&projection,&old1,&old2,"the exported key extent is validated as well as its count");
    raw.keys.array.size++;
    raw.vals.array.size--;
    r113_refuses_unchanged(&raw,&projection,&old1,&old2,"the exported value extent stays coherent with its capacity");
    raw.vals.array.size++;
    malformed=raw;
    r113_refuses_unchanged(&raw,&malformed,&old1,&old2,"a shallow metadata alias is not a separate once-only projection");
    size_t vacant=0;while(pkeys[vacant])++vacant;
    pkeys[vacant]=&p0;pvals[vacant]=saved;projection.n++;
    r113_refuses_unchanged(&raw,&projection,&old1,&old2,"duplicate projection keys cannot disagree with lookup identity");
    pkeys[vacant]=NULL;pvals[vacant]=NULL;projection.n--;
    lmx_graph_copy_map_dispose(&raw);lmx_graph_copy_map_dispose(&projection);
    LmxArenaBlock *mark=lmx_arena_mark(a);Lmx *invalid[]={NULL};copy=source;
    r111_check(r111_merge(a,invalid,1,NULL,NULL,0,&copy,&moved)==LMX_MERGE_INVALID&&!copy&&!moved.n,
               "an invalid operand publishes neither a graph nor relocation metadata");
    r111_check(lmx_arena_mark(a)==mark,"early refusal performs no arena construction");
    copy=source;
    r111_check(r111_merge(a,&source,0,NULL,NULL,0,&copy,&moved)==LMX_MERGE_INVALID&&!copy&&!moved.n,
               "an invalid count clears both outputs too");
    lmx_arena_release(a);
    printf("final receiving relocation: %d checks, %d failures\n",r111_checks,r111_failures);
    return inherited||r111_failures!=0;
}
