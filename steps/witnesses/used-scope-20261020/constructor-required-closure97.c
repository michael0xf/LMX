#ifndef L2_FRONTEND_SOURCE
#define L2_FRONTEND_SOURCE "l2trans.c"
#endif
#define main l2_seed_closure_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks, failures;
static void expect(int yes, const char *what) {
    ++checks;
    if (!yes) { ++failures; fprintf(stderr,"FAIL seed closure: %s\n",what); }
}
int main(void) {
    enum { N=131, ALL=N+1 };
    int live=l2_alloc_live, counts[ALL], negative[ALL], owner[ALL];
    int kinds[ALL], machine[ALL], seeds[ALL];
    size_t values[ALL];
    LmP0Text next={0}; next.data="next"; next.length=4;
    LmP0Text *names[ALL], *words[ALL]; LmP0Node *sites[ALL];
    for (int i=0;i<ALL;++i) {
        counts[i]=1;negative[i]=-1;owner[i]=i;kinds[i]=10;machine[i]=16;
        values[i]=(i<N ? (i+1)%N : 0)+1;seeds[i]=(i==N?1:0);
        names[i]=&next;words[i]=NULL;sites[i]=NULL;
    }
    l2_src="seed-required-closure-unit";l2_room_tag="seed-required-closure-unit";
    l2_ns_n=ALL;l2_ns_count=counts;l2_ns_proc=negative;
    l2_ns_eternal=negative;l2_ns_parent=negative;
    l2_nsf_n=ALL;l2_nsf_owner=owner;l2_nsf_kind=kinds;l2_nsf_ref=machine;
    l2_nsf_val=values;l2_nsf_seed=seeds;l2_nsf_fname=names;
    l2_nsf_name=words;l2_nsf_source=sites;l2_own_n=0;
    expect(!l2_reference_seed_pairs(),"known constructor facts close before sealing");
    expect(l2_d105t_n==0,"equal receiving models add no speculative candidate/identity pair row");
    int ready=0,complete=1;
    for(L2D105Plan *p=l2_d105_plans;p;p=p->next) {
        ++ready;
        complete &= p->candidate==p->requirement && p->ready && p->width==1 &&
                    p->steps.size==2 && p->steps.data &&
                    p->steps.data[0].requirement.pointee==(p->requirement+1)%N;
    }
    expect(ready==N && complete,"131 recursive declared-reference models retain complete selected type facts");
    expect(!l2_d105_plan(N,N,0),"unused sender model is not prepared merely because it exists");
    L2D105Plan *first=l2_d105_plans;
    expect(!l2_reference_seed_pairs() && l2_d105_plans==first,"repeated planning reuses the same required plans");
    l2_d105_plans_sealed=1;
    L2D105Catalog catalog={0};
    int closed=!l2_d105_catalog_add(&catalog,0,0) && !l2_d105_catalog_close(&catalog);
    expect(closed,"sealed constructor emission borrows the preplanned closure");
    expect(closed && catalog.count==0 && catalog.extent==1 && catalog.reference_count==N,
           "required references and physical catalog rows have independent exact extents");
    expect(closed && l2_reference_extent_valid(&catalog),"COUNT validates the same complete reference table as FILL");
    expect(!l2_d105_plan(N,N,1),"sealing still forbids creating a missing plan");
    expect(l2_d105t_n==0,"sealed adaptation creates no candidate or fallback inventory");
    if(closed) {
        catalog.reference_count--;
        expect(!l2_reference_extent_valid(&catalog),"a sliced/stale reference count is refused");
        catalog.reference_count++;
    } else expect(0,"a sliced/stale reference count is refused");
    char before_bytes[65536],after_bytes[65536];
    L2Tx before,after;
    l2_tx_local(&before,before_bytes,sizeof before_bytes);
    l2_tx_local(&after,after_bytes,sizeof after_bytes);
    int snapshot=!l2_source_plan_snapshot_bytes(&before);
    expect(snapshot,"the closed source snapshot includes required identity plans without candidate rows");
    int changed=0;
    if(first && first->steps.size) {
        int old=first->steps.data[0].requirement.pointee;
        first->steps.data[0].requirement.pointee=N;
        changed=!l2_source_plan_snapshot_bytes(&after) &&
                (before.len!=after.len || memcmp(before.data,after.data,before.len));
        first->steps.data[0].requirement.pointee=old;
    }
    expect(changed,"a changed declared pointee cannot falsely converge just because candidate rows are unchanged");
    expect(!l2_source_plan_snapshot_bytes(&after) && before.len==after.len &&
           !memcmp(before.data,after.data,before.len),"restored selected contracts produce the same exact snapshot");
    l2_bound_free();
    l2_xfree(l2_d105t_cand);l2_xfree(l2_d105t_req);
    l2_d105t_cand=l2_d105t_req=NULL;l2_d105t_n=l2_d105t_cap=0;
    expect(l2_alloc_live==live,"required plans share the existing bounded compiler lifetime");
    printf("constructor required closure: %d checks, %d failures\n",checks,failures);
    return failures!=0;
}
