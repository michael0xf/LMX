#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#define main paths149_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks, failures, watching, core_depth, core_entries;
void __cyg_profile_func_enter(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn,void *site){
    (void)site;
#ifdef PATHS149_CURRENT
    if(watching&&fn==(void*)l2_value_expr_type){if(!core_depth)++core_entries;++core_depth;}
#else
    if(watching&&fn==(void*)l2_native_expr_ty){if(!core_depth)++core_entries;++core_depth;}
#endif
}
void __cyg_profile_func_exit(void *fn,void *site){
    (void)site;
#ifdef PATHS149_CURRENT
    if(watching&&fn==(void*)l2_value_expr_type)--core_depth;
#else
    if(watching&&fn==(void*)l2_native_expr_ty)--core_depth;
#endif
}
static void ck(int yes,const char *why){++checks;if(!yes){++failures;fprintf(stderr,"FAIL paths149: %s\n",why);}}
static int group_type(LmP0Field *f,int n,int *exact){
#ifdef PATHS149_CURRENT
    return l2_value_group_type(f,n,0,exact);
#else
    *exact=l2_native_composite_ty(f,n,0);return l2_native_group_ty(f,n,0);
#endif
}
int main(void){
    LmP0Text p={0},word={0};p.data="p";p.length=1;word.data="int";word.length=3;
    LmP0Text *names[]={&p},*method_names[]={NULL};void *input_rows[]={names};
    int ft[]={0},*ft_rows[]={ft},arity[]={1},dynamic[]={0},slots[]={0};LmP0Node *nodes[]={NULL};
    l2_m_n=l2_m_cap=l2_slot_cap=1;l2_e=0;l2_cur_mi=l2_rw_mi=0;
    l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_fn=input_rows;l2_m_ft=ft_rows;l2_m_sn=slots;
    l2_m_name=method_names;l2_m_node=l2_m_body=nodes;l2_src="paths149-types";l2_rw_quiet=1;l2_construct_phase=-1;
    const char *positive[]={"p + 2U * 3U","2U + p","(p + 3U) - 1U","(2U + p) - 1U","p + (2U * 3U)"};
    const int depths[]={1,2,6,65,129};
    for(unsigned d=0;d<sizeof depths/sizeof depths[0];++d)for(int qualified=0;qualified<2;++qualified){
        ft[0]=l2_foreign_intern_parts(&word,depths[d],qualified,0);
        for(unsigned k=0;k<sizeof positive/sizeof positive[0];++k){
            char source[192];snprintf(source,sizeof source,"return: %s\n",positive[k]);
            LmP0Document *doc=NULL;if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();
            LmP0Node *ret=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;
            LmP0Field *first=ret->as->frame->body->first_field;int n=l2_count_active(ret->as->frame->body),exact=-1,m=0;
            ck(group_type(first,n,&exact)==-5,"ordinary expression retains pointer kind");
            ck(exact==ft[0],"grouping and precedence preserve exact qualified pointer FT at arbitrary rank");
            core_entries=core_depth=0;watching=1;int native=l2_native_composite_ty(first,n,0);watching=0;
            ck(native==ft[0],"native receiving projection consumes exact pointer result");
            ck(core_entries==1,"native consumer enters one common expression fold");
            L2ValueSpan *tok=l2_value_spans(first,n,&m);if(!tok||m<1)abort();
            core_entries=core_depth=0;watching=1;int retained=l2_rw_tyof(tok,0,m-1);watching=0;
            ck(retained==l2_own_ty_of_param(ft[0]),"retained storage projection consumes the same exact FT");
            ck(core_entries==1,"retained consumer uses the same expression fold,not an independent type walk");
            l2_xfree(tok);lm_p0_document_destroy(doc);
        }
    }
    ft[0]=l2_foreign_intern_parts(&word,1,0,0);
    const char *negative[]={"p * 2U","2U - p","p + p","p = 1"};
    const int verdict[]={-15,-15,-15,-17};
    for(unsigned k=0;k<sizeof negative/sizeof negative[0];++k){
        char source[128];snprintf(source,sizeof source,"return: %s\n",negative[k]);LmP0Document *doc=NULL;
        if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();
        LmP0Node *ret=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;int exact=-1;
        ck(group_type(ret->as->frame->body->first_field,l2_count_active(ret->as->frame->body),&exact)==verdict[k],"invalid pointer operator retains located kind refusal");
        lm_p0_document_destroy(doc);
    }
#ifdef PATHS149_CURRENT
    word.data="void";word.length=4;
    ck(!l2_value_offset_pointer(l2_foreign_intern_parts(&word,1,0,0)),"void pointer has no object-cell offset");
    ck(!l2_value_offset_pointer(l2_foreign_intern_parts(&word,1,1,0)),"const void pointer also has no object-cell offset");
    ck(l2_value_offset_pointer(l2_foreign_intern_parts(&word,2,0,0)),"void pointer cell itself is a valid object for double pointer");
    ck(!l2_value_offset_pointer(l2_graph_ft()),"graph reference is not a machine offset pointer");
    ck(!l2_value_offset_pointer(l2_array_desc_ty()),"Array descriptor reference is not a machine offset pointer");
#endif
    printf("common expression kind/exact FT: %d checks, %d failures\n",checks,failures);return failures!=0;
}
