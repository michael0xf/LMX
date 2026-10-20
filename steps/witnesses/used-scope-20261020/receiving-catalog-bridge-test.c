#ifndef L2_FRONTEND_SOURCE
#define L2_FRONTEND_SOURCE "l2trans.c"
#endif
#define main l2_pair_test_frontend_main
#include L2_FRONTEND_SOURCE
#undef main

static int checks,failures;
static void expect(int yes,const char *message) {
    ++checks;
    if(!yes){++failures;fprintf(stderr,"FAIL pair plan: %s\n",message);}
}
static void catalog_cycle(void){
    enum {N=72, ALL=2*N};
    int live=l2_alloc_live,counts[ALL],negative[ALL],owner[ALL],kinds[ALL],models[ALL];
    LmP0Text name={0};name.data="next";name.length=4;
    LmP0Text *names[ALL],*words[ALL];LmP0Node *sources[ALL];
    for(int i=0;i<ALL;++i){
        counts[i]=1;negative[i]=-1;owner[i]=i;kinds[i]=2;
        models[i]=(i<N?0:N)+(i+1)%N;
        names[i]=&name;words[i]=NULL;sources[i]=NULL;
    }
    l2_ns_n=ALL;l2_ns_count=counts;l2_ns_proc=negative;l2_ns_eternal=negative;
    l2_nsf_n=ALL;l2_nsf_owner=owner;l2_nsf_kind=kinds;l2_nsf_ref=models;
    l2_nsf_fname=names;l2_nsf_name=words;l2_nsf_source=sources;
    L2D105Catalog catalog={0};
    expect(!l2_d105_catalog_add(&catalog,N,0)&&!l2_d105_catalog_close(&catalog)&&
           catalog.ready&&catalog.count==N&&catalog.extent==1+N*5,
           "72 cyclic schema pairs close by identity, with no depth/pass cap or source reparse");
    int good=1,seen=0,cell;
    for(L2D105CatalogRow *r=catalog.first;r;r=r->next){
        ++seen;
        good&=!l2_d105_catalog_cell(r->plan,0,&cell)&&cell==0&&r->plan->steps.data[0].child_pair>=0;
    }
    expect(good&&seen==N,"every cycle row consumes its retained physical field and selected child pair");
    l2_bound_free();l2_xfree(l2_d105t_cand);l2_xfree(l2_d105t_req);
    l2_d105t_cand=l2_d105t_req=NULL;l2_d105t_n=l2_d105t_cap=0;
    expect(l2_alloc_live==live,"operation catalogs share compiler-source lifetime and release completely");
}
static void opaque_catalog_bridge(void){
 int live=l2_alloc_live,counts[]={1,2,1},negative[]={-1,-1,-1};
 int owners[]={0,1,1,2},kinds[]={7,7,7,7},models[]={-1,-1,-1,-1};
 LmP0Text v={0},pad={0};v.data="v";v.length=1;pad.data="pad";pad.length=3;
 LmP0Text *names[]={&v,&pad,&v,&v},*words[4]={0};LmP0Node *sources[4]={0};
 l2_ns_n=3;l2_ns_count=counts;l2_ns_proc=negative;l2_ns_eternal=negative;
 l2_nsf_n=4;l2_nsf_owner=owners;l2_nsf_kind=kinds;l2_nsf_ref=models;
 l2_nsf_fname=names;l2_nsf_name=words;l2_nsf_source=sources;
 expect(l2_d105_pair(1,0)>=0&&!l2_d105_plan_prepare(),"opaque bridge starts from a real program receiving schema, not a constructor assumption");
 L2ReferenceSource opaque={0};opaque.schema=opaque.layout=opaque.method=opaque.place=-1;
 L2D105Catalog current={0};
 expect(!l2_d105_catalog(2,&opaque,-1,-1,1,&current)&&current.ready&&current.count==1&&current.extent==6,
        "unknown source retains a possible earlier-requirement to current-requirement bridge");
 L2D105Plan *bridge=l2_d105_plan(0,2,0);
 expect(bridge&&bridge->ready&&bridge->steps.data[0].physical==0&&bridge->steps.data[0].requirement.kind==7&&l2_d105t_n==2,
        "bridge is one retained typed pair, not value authorization or an extra path parser");
 int memory=l2_bnd_mem_n;
 expect(!l2_d105_plan_prepare()&&l2_bnd_mem_n==memory,"completed bridge planning does not add duplicate typed records");
 L2D105Plan *head=l2_d105_plans;l2_d105_plans_sealed=1;l2_nsf_n=0;
 L2D105Catalog sealed={0};
 expect(!l2_d105_catalog(2,&opaque,-1,-1,1,&sealed)&&sealed.ready&&sealed.count==1&&l2_d105_plans==head,
        "opaque bridge emission consumes only the sealed result with field metadata unavailable");
 int cell=-1;
 expect(!l2_d105_catalog_cell(bridge,0,&cell)&&cell==0&&!l2_d105_catalog_cell(bridge,1,&cell)&&cell==0,
        "both bridge map halves consume prepared physical addresses");
 l2_bound_free();l2_xfree(l2_d105t_cand);l2_xfree(l2_d105t_req);
 l2_d105t_cand=l2_d105t_req=NULL;l2_d105t_n=l2_d105t_cap=0;
 expect(l2_alloc_live==live,"opaque bridge metadata shares the same source lifetime and releases completely");
}
int main(int argc,char **argv) {
    LmP0Text a={0},t={0},x={0},y={0};
    LmP0Text *names[]={&a,&t,&t,&a,&x,&y,&y,&x};
    LmP0Text *words[8]={0};
    LmP0Node *sources[8]={0};
    int owner[]={0,0,1,1,2,2,3,3};
    int kinds[]={2,7,7,2,7,4,4,7};
    int model[]={2,-1,-1,3,-1,-1,-1,-1};
    int counts[]={2,2,2,2};
    int negative[]={-1,-1,-1,-1};
    int table[8],n=91,p,live=l2_alloc_live,memory;
    L2D105Plan *root,*leaf,*head;
    a.data="A";a.length=1;t.data="tail";t.length=4;
    x.data="x";x.length=1;y.data="y";y.length=1;
    l2_src="typed-pair-unit";l2_room_tag="source-map-plan-unit";
    l2_ns_n=4;l2_ns_count=counts;l2_ns_proc=negative;l2_ns_eternal=negative;
    l2_nsf_n=8;l2_nsf_owner=owner;l2_nsf_kind=kinds;l2_nsf_ref=model;
    l2_nsf_fname=names;l2_nsf_name=words;l2_nsf_source=sources;
    l2_construct_phase=0;
    p=l2_d105_pair(1,0);
    expect(p==0&&!l2_d105_plan_prepare(),"parent prepares a finite nested pair closure");
    expect(l2_d105t_n==2&&l2_d105_pair_find(3,2)==1,"only its selected child pair is reserved");
    root=l2_d105_plan(1,0,0);leaf=l2_d105_plan(3,2,0);
    expect(root&&leaf&&root->ready&&leaf->ready,"root and child retain complete typed records");
    expect(root->width==2&&root->physical_width==2&&root->source_width==2,"counts distinguish requirement, physical and source extents");
    expect(root->steps.size==4&&root->steps.capacity>=4&&root->steps.data,
           "typed DynamicArray owns the allocated extent and exact two-half initialized size");
    expect(root->steps.data[0].requirement.model==2&&root->steps.data[0].actual.model==3&&
           root->steps.data[0].physical==1&&root->steps.data[0].child_pair==1,
           "child pair is selected from the actual physical field's own model");
    expect(root->steps.data[0].status==3&&root->steps.data[0].slot==-1,"nested selection retains a child obligation, not invented leaf-type fitness");
    expect(root->steps.data[2].physical==1&&root->steps.data[2].child_pair==1,"both ordinal and LAST retain the selected child contract");
    expect(leaf->steps.data[0].physical==1&&leaf->steps.data[1].physical==0&&
           leaf->steps.data[0].requirement.kind==7&&leaf->steps.data[1].actual.kind==4,
           "each selected leaf retains coordinates AND actual/required types");
    L2D105Catalog catalog={0};
    expect(!l2_d105_catalog_add(&catalog,1,0)&&!l2_d105_catalog_add(&catalog,1,0)&&
           catalog.count==1&&!catalog.ready,"catalog seeds deduplicate current schema-pair identities");
    expect(!l2_d105_catalog_close(&catalog)&&catalog.ready&&catalog.count==2&&catalog.extent==15,
           "catalog has one exact frame extent for root and nested correspondence rows");
    expect(catalog.first->plan==root&&catalog.last->plan==leaf&&!catalog.last->next,
           "both representations borrow the same typed parent/child plans");
    int frame=-1,old_t=l2_rw_t;
    expect(!l2_rw_catalog_frame(-1,&catalog,&frame)&&frame==old_t&&l2_rw_t==old_t+1,
           "COUNT represents the whole closed catalog by one ordinary frame, with exact topology");
    size_t saved_extent=catalog.extent;catalog.extent--;
    expect(l2_rw_catalog_frame(-1,&catalog,&frame)==1,
           "a sliced extent cannot silently drop the nested row or desynchronize its count");
    catalog.extent=saved_extent;
    size_t saved_count=catalog.count;catalog.count=1;
    expect(l2_rw_catalog_frame(-1,&catalog,&frame)==1,
           "a stale row count refuses instead of publishing a different catalog");
    catalog.count=saved_count;
    L2ReferenceSource receiving_source={0};
    receiving_source.schema=1;receiving_source.layout=1;
    receiving_source.method=-1;receiving_source.place=-1;
    receiving_source.origin_method=-1;
    int record=-1,record_start=l2_rw_t;
    expect(!l2_rw_receiving_record(-1,0,&receiving_source,1,-1,-1,-1,&record)&&
           record==record_start&&l2_rw_t==record_start+3,
           "COUNT retains record4, exact catalog and the ordinary declared-reference table");
    expect(l2_reference_extent_valid(&catalog)&&catalog.reference_count==0&&catalog.required_first,
           "owned requirement closure has an exact empty reference table, not missing metadata");
    catalog.reference_count=1;
    int refs=-1,refs_start=l2_rw_t;
    expect(!l2_reference_extent_valid(&catalog)&&l2_rw_reference_contracts(-1,&catalog,&refs)==1&&l2_rw_t==refs_start,
           "COUNT refuses stale reference-table counts before allocating another graph place");
    catalog.reference_count=0;
    expect(l2_receiving_mode(0,-1)==0&&l2_receiving_mode(1,-1)==1&&
           l2_receiving_mode(1,INT_MAX)==1,
           "unknown Consumer coverage remains full receiving, never empty scoped permission");
    FILE *saved_output=l2_out,*generated=argc==2?fopen(argv[1],"w+b"):NULL;int saved_phase=l2_construct_phase;
    l2_construct_phase=-1;l2_rw_emit=1;l2_out=generated;
    int emitted=generated?l2_rw_catalog_frame(-1,&catalog,&frame):1;
    int record_emitted=generated?l2_rw_receiving_record(-1,0,&receiving_source,1,-1,-1,-1,&record):1;
    char output[16000]={0};
    if(generated){rewind(generated);fread(output,1,sizeof output-1,generated);fclose(generated);}
    l2_out=saved_output;l2_rw_emit=0;l2_construct_phase=saved_phase;
    char expected_record_mode[128];
    snprintf(expected_record_mode,sizeof expected_record_mode,"l2_rw%d, 2U, 1U",record);
    expect(!record_emitted&&strstr(output,expected_record_mode)&&
           strstr(output,"lmx_arena_ref_store")&&!strstr(output,"l2_layout_found"),
           "FILL writes the receiving mode/current frame links without a second layout selection");
    expect(!emitted&&strstr(output,"lmx_walk_store_charptr")&&strstr(output,", 4U, (cast: (size_t) 1)")&&
           strstr(output,", 14U, (cast: (size_t) 0)"),
           "FILL emits current root/child tokens and both physical map halves from the typed result");
    int selected=-2;
    expect(!l2_d105_catalog_cell(root,0,&selected)&&selected==1,
           "catalog represents nested selection by physical parent edge plus its child obligation");
    expect(!l2_d105_catalog_cell(root,2,&selected)&&selected==1,
           "catalog LAST uses the retained LAST selection, not another field lookup");
    expect(!l2_d105_catalog_cell(leaf,0,&selected)&&selected==1&&
           !l2_d105_catalog_cell(leaf,1,&selected)&&selected==0,
           "primitive projections are the same prepared typed coordinates");
    L2D105Catalog empty={0};
    expect(!l2_d105_catalog_add(&empty,0,0)&&!l2_d105_catalog_close(&empty)&&
           empty.ready&&!empty.count&&empty.extent==1,"identity needs no redundant template row");
    expect(l2_d105_catalog_add(&empty,1,0)==1&&!empty.count,"completed catalog cannot be silently appended");
    expect(l2_d105_catalog_cell(root,4,&selected)==1&&selected==-1,"out-of-range projection does not publish a guessed coordinate");
    expect(!l2_d105_table(3,2,table,8,&n,1)&&n==4&&table[0]==1&&table[1]==0&&
           table[2]==1&&table[3]==0,"flat legacy consumer projects both halves of that same result");
    expect(!l2_d105_table(1,0,table,8,&n,1)&&n==4&&table[0]==1&&table[1]==0&&table[2]==1&&table[3]==0,"flat and ordinary catalog consumers project the same retained nested coordinates");
    memory=l2_bnd_mem_n;
    expect(!l2_d105_plan_prepare()&&l2_d105t_n==2&&l2_bnd_mem_n==memory,
           "rebuilding a stable planning state allocates no duplicate records or cells");
    L2D105Step *buffer=leaf->steps.data;
    size_t capacity=leaf->steps.capacity;
    counts[2]=1;
    expect(!l2_d105_plan_build(leaf)&&leaf->width==1&&leaf->steps.size==2&&
           leaf->steps.capacity==capacity&&leaf->steps.data==buffer&&leaf->steps.data[1].slot==1,
           "requirement shrink updates both halves and size without pretending capacity shrank");
    counts[2]=2;
    expect(!l2_d105_plan_build(leaf)&&leaf->width==2&&leaf->steps.size==4&&leaf->steps.data==buffer,
           "requirement restore reuses typed storage with a matching initialized extent");
    counts[2]=3;l2_fail_left=1;
    expect(l2_d105_plan_build(leaf)==1&&!leaf->ready&&leaf->steps.data==buffer&&
           leaf->steps.size==4&&leaf->steps.capacity==capacity,
           "failed growth exposes no ready plan and preserves old DynamicArray allocation state");
    counts[2]=2;l2_fail_left=0;l2_alloc_err=0;
    expect(!l2_d105_plan_build(leaf)&&leaf->ready&&leaf->steps.size==4,
           "later valid planning state recovers without stale counts or a second buffer");
    kinds[7]=4;
    expect(!l2_d105_table(3,2,table,8,&n,1)&&n==4&&table[0]==-1&&table[2]==-1,
           "a changed primitive type becomes a hole, not positional success");
    expect(leaf->steps.data[0].actual.kind==4&&leaf->steps.data[0].requirement.kind==7,
           "the same record changes type and map together during planning");
    expect(l2_d105_table(3,2,table,8,&n,0)==1&&n==0,"full strict consumer refuses that missing compatible leaf");
    kinds[7]=7;
    names[6]=&x;kinds[6]=7;
    expect(!l2_d105_table(3,2,table,8,&n,1)&&table[0]==0&&table[2]==1,
           "explicit first occurrence and bare LAST keep distinct physical projections");
    expect(leaf->steps.data[0].selector==0&&leaf->steps.data[2].selector==-1,
           "the selector is retained, not inferred again by the backend");
    names[6]=&y;kinds[6]=4;
    counts[3]=1;
    expect(!l2_d105_table(3,2,table,8,&n,1)&&leaf->source_width==1&&table[0]==-1,
           "source extent and selected map remain consistent after source shrink");
    counts[3]=2;
    expect(!l2_d105_plan_prepare()&&leaf->source_width==2&&leaf->steps.data[0].slot==1,
           "a later valid planning state rebuilds the same row without stale holes");
    kinds[4]=2;model[4]=0;kinds[7]=2;model[7]=1;
    expect(!l2_d105_plan_prepare()&&l2_d105t_n==2&&leaf->steps.data[0].child_pair==0,
           "recursive schema pairs close by identity without a depth or pass limit");
    kinds[4]=7;model[4]=-1;kinds[7]=7;model[7]=-1;
    expect(!l2_d105_plan_prepare(),"primitive state restored before seal");
    L2D105Catalog failed={0};l2_fail_left=1;
    expect(l2_d105_catalog_add(&failed,1,0)==1&&!failed.first&&!failed.last&&!failed.count&&!failed.ready,
           "row allocation failure publishes no partial operation catalog");
    l2_fail_left=0;l2_alloc_err=0;
    head=l2_d105_plans;memory=l2_bnd_mem_n;l2_fail_left=1;
    expect(!l2_d105_plan(99,98,1)&&l2_d105_plans==head&&l2_bnd_mem_n==memory,
           "failed new plan allocation publishes no partial dictionary entry");
    l2_fail_left=0;l2_alloc_err=0;
    l2_d105_plans_sealed=1;
    /* Deliberately make any fallback metadata lookup impossible. The current
       source is not mutable after sealing; this is an adversarial unit probe. */
    l2_ns_count=NULL;l2_ns_proc=NULL;l2_ns_eternal=NULL;l2_nsf_fname=NULL;
    expect(!l2_d105_table(3,2,table,8,&n,1)&&n==4&&table[0]==1&&table[3]==0,
           "a sealed consumer reads prepared coordinates without any schema/name lookup");
    expect(!l2_d105_plan_prepare(),"sealed preparation is read-only, not a second resolver");
    L2ReferenceSource source={0};source.schema=1;source.layout=1;source.method=-1;source.place=-1;
    L2D105Catalog sealed={0};
    expect(!l2_d105_catalog(0,&source,-1,-1,1,&sealed)&&sealed.ready&&sealed.count==2&&sealed.extent==15,
           "source/receiving catalog consumes the closed typed result with namespace metadata unavailable");
    L2D105Catalog absent={0};
    expect(l2_d105_catalog_add(&absent,3,0)==1&&!absent.first&&!absent.ready,
           "missing sealed pair cannot revive an old schema/name fallback");
    L2D105Step blocked={0};
    L2SchemaField requested=leaf->steps.data[0].requirement;
    expect(l2_d105_resolve_field(3,&requested,0,&blocked)==4&&blocked.status==4&&blocked.slot==-1,
           "raw field preparer cannot become a spare backend lookup after seal");
    expect(l2_d105_table(3,0,table,8,&n,1)==1&&n==0&&l2_d105_plans==head,
           "absent sealed result refuses instead of falling back to a name search");
    expect(l2_d105_table(3,2,table,3,&n,1)==1&&n==0,"too-small output preserves the declared count contract");
    --leaf->steps.size;
    expect(l2_d105_table(3,2,table,8,&n,1)==1&&n==0,
           "sealed DynamicArray size mismatch refuses before consuming stale steps, with no namespace lookup");
    ++leaf->steps.size;
    l2_bound_free();
    l2_xfree(l2_d105t_cand);l2_xfree(l2_d105t_req);
    l2_d105t_cand=l2_d105t_req=NULL;l2_d105t_n=l2_d105t_cap=0;
    expect(l2_d105_plans==NULL&&!l2_d105_plans_sealed&&l2_alloc_live==live,
           "prepared state shares the current source lifetime and releases completely");
    LmP0Node actual={0},cursor={0};LmP0Field operand={0};operand.value=&actual;
    l2_here_node=&cursor;
    expect(!l2_reference_source(&operand,2,-1,&source)&&source.origin==&actual&&source.origin_count==2,
           "source occurrence survives a different last diagnostic cursor without inventing layout");
    expect(!l2_reference_source(NULL,0,-1,&source)&&!source.origin&&!source.origin_count,
           "an absent source run carries no stale source occurrence");
    expect(!l2_reference_source(&operand,2,42,&source)&&source.origin_method==42,
           "operand ownership belongs to the executing source method, not the receiving schema");
    L2ExpressionSite site={0},other={0};L2AdmissionPlan key={0},otherkey={0};
    LmP0Text symbol={0},othersymbol={0};
    key.source.origin=&actual;key.source.origin_count=0;key.source.origin_method=42;
    key.requirement=3;key.mode=0;key.own=-1;key.target_method=7;key.target_key=1;key.target_symbol=&symbol;
    otherkey=key;otherkey.target_symbol=&othersymbol;
    site.role=3;site.view_kind=0;site.view_index=42;site.method=42;site.node=&actual;
    site.admission=&key;site.allocated_next=&other;
    other=site;other.admission=&otherkey;other.allocated_next=NULL;
    l2_expr_sites=&site;
    expect(l2_admission_site(0,42,42,&key)==&site,
           "an implicit receiving port binds its exact source event and executing owner");
    expect(!l2_admission_site(0,7,7,&key),
           "receiving context cannot impersonate the operation's executing owner");
    expect(l2_admission_site(0,42,42,&otherkey)==&other,
           "distinct canonical receiving ports on one source event remain distinct");
    key.source.origin=&cursor;
    expect(!l2_admission_site(0,42,42,&key),
           "a missing event cannot fall back to the neighbouring source cursor");
    key.source.origin=&actual;l2_expr_sites=NULL;
    L2AdmissionPlan resultkey={0};
    expect(!l2_admission_key(3,&source,1,-1,42,-1,&resultkey)&&resultkey.target_method==-1&&resultkey.target_key==-1,
           "a result has no receiving input port even when its refusal belongs to an executing method");
    catalog_cycle();
    opaque_catalog_bridge();
    fprintf(stderr,"typed pair plan: %d checks, %d failures\n",checks,failures);
    return failures!=0;
}
