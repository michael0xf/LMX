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
int main(void) {
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
    expect(root->steps[0].requirement.model==2&&root->steps[0].actual.model==3&&
           root->steps[0].physical==1&&root->steps[0].child_pair==1,
           "child pair is selected from the actual physical field's own model");
    expect(root->steps[0].status==3&&root->steps[0].slot==-1,"old unsupported admission boundary remains explicit, not silently accepted");
    expect(root->steps[2].physical==1&&root->steps[2].child_pair==1,"both ordinal and LAST retain the selected child contract");
    expect(leaf->steps[0].physical==1&&leaf->steps[1].physical==0&&
           leaf->steps[0].requirement.kind==7&&leaf->steps[1].actual.kind==4,
           "each selected leaf retains coordinates AND actual/required types");
    expect(!l2_d105_table(3,2,table,8,&n,1)&&n==4&&table[0]==1&&table[1]==0&&
           table[2]==1&&table[3]==0,"flat legacy consumer projects both halves of that same result");
    expect(l2_d105_table(1,0,table,8,&n,1)==2&&n==0,"nested language positive remains RED until templates reach both engines");
    memory=l2_bnd_mem_n;
    expect(!l2_d105_plan_prepare()&&l2_d105t_n==2&&l2_bnd_mem_n==memory,
           "rebuilding a stable planning state allocates no duplicate records or cells");
    kinds[7]=4;
    expect(!l2_d105_table(3,2,table,8,&n,1)&&n==4&&table[0]==-1&&table[2]==-1,
           "a changed primitive type becomes a hole, not positional success");
    expect(leaf->steps[0].actual.kind==4&&leaf->steps[0].requirement.kind==7,
           "the same record changes type and map together during planning");
    expect(l2_d105_table(3,2,table,8,&n,0)==1&&n==0,"full strict consumer refuses that missing compatible leaf");
    kinds[7]=7;
    names[6]=&x;kinds[6]=7;
    expect(!l2_d105_table(3,2,table,8,&n,1)&&table[0]==0&&table[2]==1,
           "explicit first occurrence and bare LAST keep distinct physical projections");
    expect(leaf->steps[0].selector==0&&leaf->steps[2].selector==-1,
           "the selector is retained, not inferred again by the backend");
    names[6]=&y;kinds[6]=4;
    counts[3]=1;
    expect(!l2_d105_table(3,2,table,8,&n,1)&&leaf->source_width==1&&table[0]==-1,
           "source extent and selected map remain consistent after source shrink");
    counts[3]=2;
    expect(!l2_d105_plan_prepare()&&leaf->source_width==2&&leaf->steps[0].slot==1,
           "a later valid planning state rebuilds the same row without stale holes");
    kinds[4]=2;model[4]=0;kinds[7]=2;model[7]=1;
    expect(!l2_d105_plan_prepare()&&l2_d105t_n==2&&leaf->steps[0].child_pair==0,
           "recursive schema pairs close by identity without a depth or pass limit");
    kinds[4]=7;model[4]=-1;kinds[7]=7;model[7]=-1;
    expect(!l2_d105_plan_prepare(),"primitive state restored before seal");
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
    L2D105Step blocked={0};
    L2SchemaField requested=leaf->steps[0].requirement;
    expect(l2_d105_resolve_field(3,&requested,0,&blocked)==4&&blocked.status==4&&blocked.slot==-1,
           "raw field preparer cannot become a spare backend lookup after seal");
    expect(l2_d105_table(3,0,table,8,&n,1)==1&&n==0&&l2_d105_plans==head,
           "absent sealed result refuses instead of falling back to a name search");
    expect(l2_d105_table(3,2,table,3,&n,1)==1&&n==0,"too-small output preserves the declared count contract");
    l2_bound_free();
    l2_xfree(l2_d105t_cand);l2_xfree(l2_d105t_req);
    l2_d105t_cand=l2_d105t_req=NULL;l2_d105t_n=l2_d105t_cap=0;
    expect(l2_d105_plans==NULL&&!l2_d105_plans_sealed&&l2_alloc_live==live,
           "prepared state shares the current source lifetime and releases completely");
    fprintf(stderr,"typed pair plan: %d checks, %d failures\n",checks,failures);
    return failures!=0;
}
