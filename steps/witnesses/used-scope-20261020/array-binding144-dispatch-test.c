#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#define main array144_frontend_main
#include L2_FRONTEND_SOURCE
#undef main

/* Observe real collector invocations in complete translations, not a mock
 * root/step implementation or a grep count of calls in the source. */
static void *collector, *root_dispatch, *step_fold, *legacy_index;
static int active, roots, folds, legacy, calls, failures, root_total, fold_total;
void __cyg_profile_func_enter(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn,void *site)
{
    (void)site;
    if(fn==collector){++active;roots=folds=legacy=0;return;}
    if(!active)return;
    if(fn==root_dispatch)++roots;
    if(fn==step_fold)++folds;
    if(fn==legacy_index)++legacy;
}
void __cyg_profile_func_exit(void *fn,void *site)
{
    (void)site;
    if(fn!=collector)return;
    ++calls;root_total+=roots;fold_total+=folds;
    if(roots!=1 || folds>1 || legacy!=0){
        ++failures;
        fprintf(stderr,"FAIL Array-binding dispatch: roots=%d folds=%d legacy=%d\n",roots,folds,legacy);
    }
    --active;
}
int main(int argc,char **argv)
{
    collector=(void*)l2_ab_collect;
    root_dispatch=(void*)l2_path_root_resolve;
    step_fold=(void*)l2_path_walk_steps_from;
    legacy_index=(void*)l2_indexed_operand;
    int status=array144_frontend_main(argc,argv);
    printf("Array-binding dispatch: %d collectors, %d roots, %d folds, %d failures, frontend=%d\n",
           calls,root_total,fold_total,failures,status);
    return status!=0 || failures!=0 || calls==0;
}
