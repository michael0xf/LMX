#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#define main receive147_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks,failures,watching,roots;
static void *root_entry;
static int simple_calls;
static void *simple_entry;
void __cyg_profile_func_enter(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn,void *site){(void)site;if(watching&&fn==root_entry)++roots;if(watching&&fn==simple_entry)++simple_calls;}
void __cyg_profile_func_exit(void *fn,void *site){(void)fn;(void)site;}
static void ck(int good,const char *why){++checks;if(!good){++failures;fprintf(stderr,"FAIL closed root value: %s\n",why);}}
int main(void)
{
    LmP0Text p={0},word={0};p.data="p";p.length=1;
    LmP0Text *names[]={&p},*method_names[]={NULL};void *input_rows[]={names};
    int ft[]={0},*ft_rows[]={ft},arity[]={1},dynamic[]={0},slots[]={0};
    LmP0Node *nodes[]={NULL};
    l2_m_n=l2_m_cap=l2_slot_cap=1;l2_e=0;l2_cur_mi=l2_rw_mi=0;
    l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_fn=input_rows;l2_m_ft=ft_rows;l2_m_sn=slots;
    l2_m_name=method_names;l2_m_node=l2_m_body=nodes;l2_src="closed-root-value";l2_rw_quiet=1;l2_construct_phase=-1;
    root_entry=(void*)l2_path_root_resolve;simple_entry=(void*)l2_colon_simple_ty;
    word.data="int";word.length=3;
    int types[]={0,1,2,34,36,l2_foreign_intern(&word,1,0),l2_foreign_intern(&word,1,1),l2_graph_ft()};
    for(unsigned k=0;k<sizeof types/sizeof types[0];++k){
        ft[0]=types[k];LmP0Document *doc=NULL;
        if(lm_p0_parse_bytes("return: p\n",10,&doc)||!doc)abort();
        LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;
        L2ValueSpan span={0};span.first=stmt->as->frame->body->first_field;span.count=1;span.node=span.first->value;
        L2Path value;roots=0;watching=1;
        int status=l2_path_resolve_value(span.first,span.count,&value);watching=0;
        ck(status==0&&value.n==0&&value.fi==0&&value.oi==-1,"ordinary formal coordinate selected with zero steps");
        ck(roots==1,"actual resolver selects this root once");
        ck(value.leaf_kind==13&&value.leaf_ty==types[k],"common verdict closes exact value type, including int zero code");
        ck(l2_path_rec_leaf_ft(&value)==types[k],"projection consumes the closed type");
        ft[0]=types[k]==2?0:2;
        ck(l2_path_rec_leaf_ft(&value)==types[k],"post-resolution type-table poison does not relabel the verdict");
        l2_path_release(&value);ft[0]=types[k];
        roots=0;watching=1;int native=l2_value_span_type(&span,0,0);watching=0;
        int expected=l2_pointer_depth(types[k])>0?-5:types[k];
        ck(native==expected,"native kind uses selected scalar/reference value, never a callable result");
        ck(roots==1,"native kind enters common root dispatch once");
        roots=0;watching=1;int retained=l2_rw_span_ty(&span);watching=0;
        ck(retained==l2_own_ty_of_param(types[k]),"retained typing projects the same exact declared value type");
        ck(roots==1,"retained kind enters common root dispatch once");
        roots=0;watching=1;
#ifdef RECEIVE147_COMMON
        int field_status=l2_colon_field_ty(span.first,0,&expected);
#else
        int field_status=l2_colon_simple_ty(span.node,0,&expected);
#endif
        watching=0;ck(field_status==0&&expected==types[k],"single receiving field projects exact selected type");
        ck(roots==1,"single receiving field enters the actual common root once");
        roots=0;watching=1;
#ifdef RECEIVE147_COMMON
        int value_status=l2_colon_value_ty(span.first,0,&expected);
#else
        int value_status=l2_colon_value_ty(span.node,0,&expected);
#endif
        watching=0;ck(value_status==0&&expected==types[k],"assignment value projects same selected type");
        ck(roots==1,"assignment value enters actual common root once");
        l2_application_free();lm_p0_document_destroy(doc);
    }
    for(int literal=0;literal<2;++literal){
        const char *source=literal?"return: 7\n":"return: missing\n";LmP0Document *doc=NULL;
        if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();
        LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;
        LmP0Field *field=stmt->as->frame->body->first_field;int ty=-1,st;
        roots=simple_calls=0;watching=1;
#ifdef RECEIVE147_COMMON
        st=l2_colon_field_ty(field,0,&ty);
#else
        st=l2_colon_simple_ty(field->value,0,&ty);
#endif
        watching=0;
        ck(literal?(st==0&&ty==-10):st!=0,"literal keeps its literal type and missing root stays unresolved");
        ck(roots==(literal?0:1),"no root lookup for a literal;one actual lookup for a missing name");
        if(!literal)ck(simple_calls==0,"failed named field never retries old simple classification");
        roots=simple_calls=0;watching=1;
#ifdef RECEIVE147_COMMON
        st=l2_colon_value_ty(field,0,&ty);
#else
        st=l2_colon_value_ty(field->value,0,&ty);
#endif
        watching=0;
        ck(literal?(st==0&&ty==-10):st!=0,"assignment preserves literal or missing verdict");
        ck(roots==(literal?0:1),"assignment resolves a named root once,not a literal");
        if(!literal)ck(simple_calls==0,"failed named assignment has no old classification fallback");
        l2_application_free();lm_p0_document_destroy(doc);
    }
    printf("closed receiving value: %d checks, %d failures\n",checks,failures);return failures!=0;
}
