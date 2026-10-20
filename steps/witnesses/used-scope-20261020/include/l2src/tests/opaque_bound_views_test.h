#ifndef LMX_TEST_OPAQUE_BOUND_VIEWS_H
#define LMX_TEST_OPAQUE_BOUND_VIEWS_H
#include "l2src/lmx_value_owned.lm1.h"
#include "l2src/lmx_arena_refs.lm1.h"
#include "l2src/lmx_implements.lm1.h"
#include <stdlib.h>
#include <stdio.h>
extern LmxArena *l2_program_arena;
extern Lmx *l2_program_unit;
static Lmx *l2_test_bound_raw;
static size_t l2_test_bound_maps[2][12];
/* Explicit foreign ABI receptions, not a guessed physical layout. Namespace
   declarations occupy root children 1 and optionally 2. Neither reception
   may claim that the raw value has either declaration's physical origin. */
static void *l2_test_opaque_bound(int two_views)
{
    if(l2_test_bound_raw)return l2_test_bound_raw;
    size_t count=two_views?3U:2U;
    int numbers[]={7,9,29};
    Lmx *value=lmx_node_new_owned(l2_program_arena);
    if(!value||lmx_arena_refs_open_owned(l2_program_arena,value,count)){fprintf(stderr,"bound fixture: graph allocation failed\n");abort();}
    for(size_t i=0;i<count;++i){
        void *cell=lmx_int_new_owned(l2_program_arena);
        if(!cell||lmx_int_store_known(cell,numbers[i])||lmx_arena_ref_store(value,i,cell)){fprintf(stderr,"bound fixture: integer %zu failed\n",i);abort();}
    }
    for(size_t i=1;i<=(two_views?2U:1U);++i){
        Lmx *model=(Lmx *)lmx_arena_ref_value(l2_program_unit,i);
        /* The source fixture's two/three flat declarations occupy physical
           slots 0,2[,4]; the interleaved slots hold retained source bodies.
           Supply that explicit ABI correspondence, not guessed identity. */
        size_t fields=i==1U?2U:3U,width=model?model->array.size:0U;
        if(width!=2U*fields||width>6U){fprintf(stderr,"bound fixture: unexpected declaration width %zu\n",width);abort();}
        size_t *map=l2_test_bound_maps[i-1U];
        for(size_t k=0;k<2U*width;++k)map[k]=SIZE_MAX;
        for(size_t k=0;k<fields;++k)map[2U*k]=map[width+2U*k]=k;
        LmxImplEntry view={0};view.map=map;view.n=width;
        int answer=lmx_implements_admit_receiving(l2_program_arena,value,model,&view,NULL);
        if(answer!=LMX_IMPLEMENTS_YES){fprintf(stderr,"bound fixture: explicit reception %zu answer %d width %zu\n",i,answer,model?model->array.size:0U);abort();}
    }
    if(lmx_implements_layout(l2_program_arena,value)){fprintf(stderr,"bound fixture: spurious layout\n");abort();}
    l2_test_bound_raw=value;
    return value;
}
#endif
