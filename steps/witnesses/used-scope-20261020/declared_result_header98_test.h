#ifndef LMX_TEST_DECLARED_RESULT_HEADER_H
#define LMX_TEST_DECLARED_RESULT_HEADER_H
#include "l2src/lmx_value_owned.lm1.h"
#include "l2src/lmx_arena_refs.lm1.h"
#include "l2src/lmx_merge_owned.lm1.h"
#include "l2src/lmx_walk.lm1.h"
#include <stdint.h>
#include <stdlib.h>
extern LmxArena *l2_program_arena;
extern Lmx *l2_program_unit;
/* Existing linked runtime helper; its forward declaration is private to this
   graph-inspection fixture, not a second role-decoding implementation. */
extern int lmx_walk_role_in(LmxArena *,void *);
static void *l2_test_return_witness(Lmx *method)
{
    Lmx *part=lmx_arena_ref_struct(method,1U);
    if(!part || part->array.size!=1U) return NULL;
    return lmx_graph_value_in(l2_program_arena,part,0U);
}
static int l2_test_result_headers(Lmx *first,Lmx *second,Lmx *opaque,
                                  Lmx *empty,Lmx *numeric,Lmx *a,Lmx *b)
{
    Lmx *part=lmx_arena_ref_struct(empty,1U);
    void *null_ref=l2_test_return_witness(opaque);
    void *number=l2_test_return_witness(numeric);
    return a && b && a!=b && l2_test_return_witness(first)==a &&
           l2_test_return_witness(second)==b && part && !part->array.size &&
           lmx_domain_kind(l2_program_arena,null_ref)==LMX_KIND_PRIMITIVE &&
           lmx_domain_type(l2_program_arena,null_ref)==LMX_TYPE_POINTER_BASE+16 &&
           lmx_domain_type(l2_program_arena,number)==LMX_TYPE_INT;
}
static int l2_test_result_header_copy(Lmx *method,Lmx *model)
{
    Lmx *root=lmx_node_new_owned(l2_program_arena),*copy=NULL;
    Lmx *operands[1]={root};
    if(!root || lmx_arena_refs_open_owned(l2_program_arena,root,2U) ||
       lmx_arena_ref_store(root,0U,method) || lmx_arena_ref_store(root,1U,model) ||
       lmx_merge_profiles_owned(operands,1U,NULL,l2_program_arena,l2_program_arena,
                               NULL,0U,NULL,0U,&copy) || !copy || copy==root)
        return 0;
    Lmx *copied_method=lmx_arena_ref_struct(copy,0U);
    Lmx *copied_model=lmx_arena_ref_struct(copy,1U);
    return copied_method && copied_model && copied_method!=method && copied_model!=model &&
           l2_test_return_witness(copied_method)==copied_model &&
           l2_test_return_witness(method)==model;
}
/* Test-only finite graph inspection. It does not evaluate a node, choose a
   source by layout, or reimplement a path resolver. Both result addresses
   must occur in the actual CALL/EXEC contracts as well as method headers.
   A selected callable parameter is EXEC; both operations own slot3. */
static int l2_test_call_result_models(Lmx *a,Lmx *b)
{
    size_t used=1U,at=0U,capacity=32U,seen_a=0U,seen_b=0U;
    Lmx **nodes=malloc(capacity*sizeof *nodes);
    if(!nodes || !l2_program_unit) {free(nodes);return 0;}
    nodes[0]=l2_program_unit;
    while(at<used){
        Lmx *node=nodes[at++];
        int role=lmx_walk_role_in(l2_program_arena,lmx_graph_value_in(l2_program_arena,node,0U));
        if(role==LMX_WALK_OP_CALL || role==LMX_WALK_OP_EXEC){
            Lmx *contract=lmx_arena_ref_struct(node,3U);
            if(contract && contract->array.size==2U){
                Lmx *part=lmx_arena_ref_struct(contract,1U);
                if(part && part->array.size==1U){
                    void *witness=lmx_graph_value_in(l2_program_arena,part,0U);
                    seen_a+=witness==a;seen_b+=witness==b;
                }
            }
        }
        for(size_t i=0;i<node->array.size;++i){
            Lmx *child=lmx_graph_node_in(l2_program_arena,lmx_graph_value_in(l2_program_arena,node,i));
            if(!child)continue;
            size_t j=0U;while(j<used && nodes[j]!=child)++j;
            if(j<used)continue;
            if(used==capacity){
                if(capacity>SIZE_MAX/sizeof *nodes/2U){free(nodes);return 0;}
                size_t next=capacity*2U;
                Lmx **grown=realloc(nodes,next*sizeof *nodes);
                if(!grown){free(nodes);return 0;}nodes=grown;capacity=next;
            }
            nodes[used++]=child;
        }
    }
    free(nodes);
    return seen_a>=2U && seen_b>=1U;
}
#endif
