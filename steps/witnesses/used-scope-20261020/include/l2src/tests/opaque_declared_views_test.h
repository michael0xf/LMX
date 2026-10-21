#ifndef LMX_TEST_OPAQUE_DECLARED_VIEWS_H
#define LMX_TEST_OPAQUE_DECLARED_VIEWS_H
#include "l2src/lmx_value_owned.lm1.h"
#include "l2src/lmx_arena_refs.lm1.h"
#include "l2src/lmx_implements.lm1.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
extern LmxArena *l2_program_arena;
extern Lmx *l2_program_unit;
static Lmx *l2_test_declared_raw;
static size_t l2_test_declared_maps[2][8];
/* Only this foreign ABI fixture supplies these explicit source relations.
   D(v,w) and E(w,v) are root children 1/2. No target R permission is added,
   and neither giving view is claimed as the raw graph's physical origin. */
static void *l2_test_opaque_declared(void)
{
    if(l2_test_declared_raw)return l2_test_declared_raw;
    Lmx *value=lmx_node_new_owned(l2_program_arena);
    if(!value||lmx_arena_refs_open_owned(l2_program_arena,value,2U))abort();
    for(size_t k=0;k<2U;++k){
        void *cell=lmx_int_new_owned(l2_program_arena);
        if(!cell||lmx_int_store_known(cell,k?9:7)||lmx_arena_ref_store(value,k,cell))abort();
    }
    for(size_t k=0;k<2U;++k){
        Lmx *model=lmx_arena_ref_struct(l2_program_unit,k+1U);
        if(!model||model->array.size!=4U)abort();
        size_t *map=l2_test_declared_maps[k];
        for(size_t j=0;j<8U;++j)map[j]=SIZE_MAX;
        map[0]=map[4]=0U;map[2]=map[6]=1U;
        LmxImplEntry view={0};view.map=map;view.n=4U;
        if(lmx_implements_admit_receiving(l2_program_arena,value,model,&view,NULL)!=LMX_IMPLEMENTS_YES)abort();
    }
    if(lmx_implements_layout(l2_program_arena,value))abort();
    l2_test_declared_raw=value;
    return value;
}
#endif
