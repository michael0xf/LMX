/* Independent physical-storage tests. The production runtime is generated
 * from the changed L1 sources; this translation unit only replaces its host
 * main with these assertions. No runtime C implementation is patched. */
#define main places152_unused_driver_main
#include "actual-02/driver.c"
#undef main

static int tests152, failures152, reads152, writes152, wrong152;
#define CHECK152(condition) do { tests152++; if (!(condition)) { \
    failures152++; fprintf(stderr, "FAIL physical152:%d: %s\n", __LINE__, #condition); \
} } while (0)

static void *double_pointer_read152(void *cell)
{
    reads152++;
    return *(double **)cell;
}
static int double_pointer_write152(void *cell, void *value)
{
    writes152++;
    *(double **)cell = (double *)value;
    return 0;
}
static int wrong_write152(void *cell, void *value)
{
    (void)cell; (void)value; wrong152++;
    return 1;
}

int main(void)
{
    LmxArena arena;
    Lmx *node, *first, *second, *mapped;
    LmxArray *array, *reference_array;
    void **slot0, **slot1;
    void *addresses[2], *typed, *numeric, *cstring;
    double a=1.25, b=8.5, *raw=&a;
    char text_a[]="first", text_b[]="second";
    LmxWalkValue value, context, owner;
    LmxWalkPlace place;
    LmxPointerCellRead read;
    LmxPointerCellWrite write;
    int logical=LMX_TYPE_POINTER_BASE+777, previous_writes;
    memset(&arena,0,sizeof(arena));
    CHECK152(lmx_arena_open(&arena)==0);
    node=lmx_node_new_owned(&arena);
    first=lmx_node_new_owned(&arena);
    second=lmx_node_new_owned(&arena);
    mapped=lmx_node_new_owned(&arena);
    CHECK152(node && first && second && mapped);
    if (!node || !first || !second || !mapped) return 1;
    CHECK152(lmx_arena_refs_open_owned(&arena,node,2U)==0);
    CHECK152(lmx_arena_refs_open_owned(&arena,mapped,2U)==0);
    slot0=lmx_arena_ref_cell(node,0U); slot1=lmx_arena_ref_cell(node,1U);
    CHECK152(slot0 && slot1 && slot0!=slot1);
    CHECK152(lmx_range_classify(&arena,slot0)==LMX_KIND_CHILDREN);
    CHECK152(lmx_pointer_pool_in(&arena,slot0)==0);
    CHECK152(lmx_arena_ref_store(node,0U,first)==0);
    CHECK152(lmx_arena_ref_store(node,1U,second)==0);
    read=0; write=wrong_write152;
    CHECK152(lmx_value_cell_access(&arena,slot0,&read,&write)==0);
    CHECK152(read==lmx_arena_pointer_void_read && write==lmx_arena_pointer_void_write);
    CHECK152(read(slot0)==first);
    CHECK152(lmx_walk_value_load(&arena,slot0,logical,&value)==LMX_WALK_OK && value.ref==first && value.type==logical);
    memset(&place,0,sizeof(place)); place.address=slot0;place.storage=slot0;place.type=logical;
    CHECK152(lmx_walk_value_ref(&value,logical,second)==LMX_WALK_OK);
    CHECK152(lmx_walk_value_store(&arena,&place,&value)==0);
    CHECK152(slot0[0]==second && slot1[0]==second && wrong152==0);
    CHECK152(lmx_value_cell_store(&arena,slot0,0,first,0,wrong_write152)==0);
    CHECK152(slot0[0]==first && wrong152==0);

    /* Permutation is projected exactly once. A held physical field address
     * remains that same address when read/written through another view. */
    addresses[0]=slot1;addresses[1]=slot0;
    CHECK152(lmx_graph_fields_bind(&arena,mapped,addresses)==0);
    CHECK152(lmx_graph_cell_in(&arena,mapped,0U)==slot1);
    CHECK152(lmx_graph_cell_in(&arena,mapped,1U)==slot0);
    CHECK152(lmx_range_classify(&arena,mapped->array.data)==LMX_KIND_FIELD_ADDRESSES);
    place.address=lmx_graph_cell_in(&arena,mapped,0U);place.storage=place.address;
    CHECK152(lmx_walk_value_ref(&value,logical,first)==LMX_WALK_OK);
    CHECK152(lmx_walk_value_store(&arena,&place,&value)==0);
    CHECK152(slot1[0]==first && lmx_graph_value_in(&arena,mapped,0U)==first);
    CHECK152(lmx_walk_value_load(&arena,place.address,logical,&value)==0 && value.ref==first);
    CHECK152(place.address==slot1);
    CHECK152(lmx_walk_value_load(&arena,mapped->array.data,logical,&value)==LMX_WALK_INVALID);

    /* The exact C double * object must use its typed pool callbacks, never
     * void **. The logical reference ID is not a physical ABI classifier. */
    typed=lmx_pointer_new_typed_profiled(logical,&arena,0,sizeof(double *),double_pointer_read152,double_pointer_write152);
    CHECK152(typed!=0);
    previous_writes=writes152;
    lmx_walk_value_clear(&context);lmx_walk_value_clear(&owner);
    context.model=first;owner.model=second;
    CHECK152(lmx_value_cell_store(&arena,typed,&owner,&a,&context,wrong_write152)==0);
    CHECK152(writes152==previous_writes+1 && wrong152==0 && *(double **)typed==&a);
    CHECK152(owner.model==first && lmx_pointer_cell_context(&arena,typed)->model==first);
    CHECK152(lmx_walk_value_load(&arena,typed,logical,&value)==0 && value.ref==&a && value.model==first);
    CHECK152(reads152==1);
    /* Even the same payload address clears the CURRENT metadata on a raw write. */
    CHECK152(lmx_value_cell_store(&arena,typed,&owner,&a,0,wrong_write152)==0);
    CHECK152(owner.model==0 && lmx_pointer_cell_context(&arena,typed)->model==0 && wrong152==0);
    CHECK152(lmx_walk_value_load(&arena,typed,logical,&value)==0 && value.ref==&a && value.model==0);

    array=lmx_array_new_typed_profiled(LMX_TYPE_ARRAY_OF_POINTER_BASE+777,3U,&arena,0,sizeof(double *),double_pointer_read152,double_pointer_write152);
    CHECK152(array!=0);
    CHECK152(lmx_value_array_place(&arena,array,2U,&place)==0);
    CHECK152(place.address==((double **)array->array.data)+2 && place.type==logical);
    CHECK152(lmx_walk_value_ref(&value,logical,&b)==0);
    CHECK152(lmx_walk_value_store(&arena,&place,&value)==0);
    CHECK152(((double **)array->array.data)[2]==&b && ((double **)array->array.data)[0]==0);
    CHECK152(lmx_walk_value_load(&arena,place.address,place.type,&value)==0 && value.ref==&b);
    CHECK152(lmx_value_array_place(&arena,array,3U,&place)==LMX_WALK_THROWN+LMX_WALK_NAME_INTERPRETER);

    /* Array reference backing shares void * ABI with graph fields, but its
     * logical element type is DESC or LMX rather than the REFS table type. */
    reference_array=lmx_array_ref_new_owned(LMX_TYPE_ARRAY_OF_DESC,2U,&arena);
    CHECK152(reference_array!=0);
    CHECK152(lmx_value_array_place(&arena,reference_array,1U,&place)==0);
    CHECK152(lmx_range_classify(&arena,place.address)==LMX_KIND_REF && place.type==LMX_TYPE_DESC);
    CHECK152(lmx_walk_value_ref(&value,LMX_TYPE_DESC,array)==0);
    CHECK152(lmx_walk_value_store(&arena,&place,&value)==0);
    CHECK152(lmx_walk_place_load(&arena,&place,&value)==0 && value.ref==array);
    CHECK152(((void **)reference_array->array.data)[1]==array && ((void **)reference_array->array.data)[0]==0);
    reference_array=lmx_array_ref_new_owned(LMX_TYPE_ARRAY_OF_LMX,2U,&arena);
    CHECK152(reference_array!=0);
    CHECK152(lmx_value_array_place(&arena,reference_array,0U,&place)==0 && place.type==LMX_TYPE_LMX);
    CHECK152(lmx_walk_value_ref(&value,LMX_TYPE_LMX,mapped)==0);
    CHECK152(lmx_walk_value_store(&arena,&place,&value)==0);
    CHECK152(lmx_walk_place_load(&arena,&place,&value)==0 && value.ref==mapped);

    /* Legacy char * storage is still a real char * object, with explicit
     * typed adapters rather than an incompatible void ** read/write. */
    cstring=lmx_charptr_new_owned(&arena);
    CHECK152(cstring!=0);
    CHECK152(lmx_value_cell_store(&arena,cstring,0,text_a,0,0)==0);
    CHECK152(*(char **)cstring==text_a);
    CHECK152(lmx_walk_value_load(&arena,cstring,LMX_TYPE_CHAR_PTR,&value)==0 && value.ref==text_a);
    CHECK152(lmx_value_cell_store(&arena,cstring,0,text_b,0,wrong_write152)==0);
    CHECK152(lmx_charptr_value_known(cstring)==text_b && wrong152==0);

    /* A producer-proven raw C object retains its own callbacks. */
    read=double_pointer_read152;write=double_pointer_write152;
    CHECK152(lmx_value_cell_access(&arena,&raw,&read,&write)==0);
    CHECK152(read==double_pointer_read152 && write==double_pointer_write152 && read(&raw)==&a);
    CHECK152(lmx_value_cell_store(&arena,&raw,0,&b,0,double_pointer_write152)==0 && raw==&b);
    numeric=lmx_int_new_owned(&arena);
    read=lmx_pointer_value_known;write=wrong_write152;
    CHECK152(lmx_value_cell_access(&arena,numeric,&read,&write)!=0);
    CHECK152(lmx_walk_value_load(&arena,numeric,logical,&value)==LMX_WALK_INVALID);
    CHECK152(lmx_value_cell_store(&arena,numeric,0,first,0,wrong_write152)!=0 && wrong152==0);
    CHECK152(lmx_value_cell_access(&arena,node,&read,&write)!=0);
    CHECK152(lmx_value_cell_access(&arena,0,&read,&write)!=0);
    CHECK152(lmx_value_cell_access(&arena,slot0,0,&write)!=0);
    CHECK152(lmx_value_cell_access(&arena,slot0,&read,0)!=0);
    CHECK152(lmx_walk_value_load(&arena,0,logical,&value)==0 && !value.present);
    CHECK152(lmx_arena_release(&arena)==0);
    printf("physical152: %d checks, %d failures; typed read=%d write=%d, wrong=%d\n",tests152,failures152,reads152,writes152,wrong152);
    return failures152 ? 1 : 0;
}
