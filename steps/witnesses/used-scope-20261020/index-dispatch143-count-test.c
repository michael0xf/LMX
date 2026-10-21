#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#define main dispatch143_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks,failures,watching,walks,roots;
static void *watched,*watched_root;
void __cyg_profile_func_enter(void *fn,void *site) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *fn,void *site) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn,void *site){(void)site;if(watching&&fn==watched)++walks;if(watching&&fn==watched_root)++roots;}
void __cyg_profile_func_exit(void *fn,void *site){(void)fn;(void)site;}
static void ck143(int yes,const char *why){++checks;if(!yes){++failures;fprintf(stderr,"FAIL one INDEX dispatch: %s\n",why);}}
static int head_place(LmP0Node *stmt,L2ArrayPlace *array,L2Address *raw){
#ifdef DISPATCH143_CURRENT
    return l2_index_head_place(stmt,0,array,raw);
#else
    int result=l2_array_place(stmt,0,array);
    if(result==1&&l2_raw_index_location(stmt,0,raw)==0)return 7;
    return result;
#endif
}
static int run_place(L2HeadExpression *head,L2ArrayPlace *array,L2Address *raw){
#ifdef DISPATCH143_CURRENT
    return l2_index_run_place(head->prepared.source_first,head->prepared.run_count,0,array,0,raw);
#else
    L2ValueSpan span={0};span.first=head->prepared.source_first;span.count=head->prepared.run_count;span.node=span.first->value;
    int result=l2_array_span(span.first,span.count,0,array);
    if(result==1&&l2_raw_span_location(&span,0,raw)==0)return 7;
    return result;
#endif
}
int main(void){
    LmP0Text p={0},word={0};p.data="p";p.length=1;
    LmP0Text *names[]={&p},*method_names[]={NULL};void *input_rows[]={names};
    int ft[]={18},*ft_rows[]={ft},arity[]={1},dynamic[]={0},slots[]={0};
    LmP0Node *nodes[]={NULL};
    l2_m_n=l2_m_cap=l2_slot_cap=1;l2_e=0;l2_cur_mi=l2_rw_mi=0;
    l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_fn=input_rows;l2_m_ft=ft_rows;l2_m_sn=slots;
    l2_m_name=method_names;l2_m_node=l2_m_body=nodes;l2_src="one-index-dispatch";l2_rw_quiet=1;l2_construct_phase=-1;
    watched=(void*)l2_path_walk_steps_from;watched_root=(void*)l2_path_root_resolve;
    const int ranks[]={1,2,6,65,129};
    for(int ri=0;ri<5;++ri)for(int qualified=0;qualified<2;++qualified){
        int rank=ranks[ri];char source[2048];strcpy(source,"p");for(int i=0;i<rank;++i)strcat(source,"[0]");strcat(source,": 0\n");
        word.data=qualified?"int":"void";word.length=qualified?3:4;
        int ty=l2_foreign_intern_parts(&word,rank+(qualified?0:1),qualified,0);ft[0]=ty;
        LmP0Document *doc=NULL;int status=lm_p0_parse_bytes(source,strlen(source),&doc);
        ck143(!status&&doc,"actual original head parses");if(status||!doc)abort();
        LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;
        int hs;L2HeadExpression *head=l2_head_expression(stmt,&hs);if(!head||hs)abort();
        L2ArrayPlace array;L2Address raw={0};walks=roots=0;watching=1;status=head_place(stmt,&array,&raw);watching=0;
        int address_type=status==7?raw.type:-1;
        ck143(status==7,"head selects a machine representation");
        ck143(walks==1,"head dispatch enters the actual common fold ONCE");
        ck143(roots==1,"head selects its root ONCE");
        ck143(status==7&&raw.path.n==rank&&raw.path.indexed==rank&&raw.path.leaf_kind==13&&raw.index==(qualified?0:16),"head carries full typed geometry and leaf");
        ck143(status==7&&raw.path.owned==0&&raw.path.source_first==head->prepared.source_first,"head borrows cached text and original AST");
        ck143(status==7&&raw.immutable==qualified&&raw.type>=0,"head retains exact qualification and address type");
        ck143(status==7&&array.path.steps==NULL,"unselected Array view releases its temporary steps");
        if(status==7)l2_address_release(&raw);else if(!status)l2_array_place_release(&array);
        memset(&raw,0,sizeof raw);walks=roots=0;watching=1;status=run_place(head,&array,&raw);watching=0;
        ck143(status==7,"operand selects a machine representation");
        ck143(walks==1,"operand dispatch enters the actual common fold ONCE");
        ck143(roots==1,"operand selects its root ONCE");
        ck143(status==7&&raw.path.owned==1&&raw.path.text&&raw.path.text!=head->prepared.text,"operand transfers its actual joined-text owner");
        ck143(status==7&&raw.path.source_first==head->prepared.source_first&&raw.path.n==rank&&raw.immutable==qualified,"operand preserves source coordinates and qualifier");
        if(status==7)l2_address_release(&raw);else if(!status)l2_array_place_release(&array);
        char address_source[2048];strcpy(address_source,"return: @ p");
        for(int i=0;i<rank;++i)strcat(address_source,"[0]");strcat(address_source,"\n");
        LmP0Document *address_doc=NULL;
        if(lm_p0_parse_bytes(address_source,strlen(address_source),&address_doc)||!address_doc)abort();
        LmP0Node *address_frame=l2_next_active(lm_p0_document_mutable_root(address_doc)->as->structure->first_field)->value;
        if(!address_frame||address_frame->kind!=LM_P0_NODE_FRAME||!address_frame->as->frame->body)abort();
        L2ValueSpan address_span={0};address_span.first=address_frame->as->frame->body->first_field;
        address_span.count=l2_count_active(address_frame->as->frame->body);address_span.node=address_span.first->value;
        walks=roots=0;watching=1;int address_own=l2_rw_span_ty(&address_span);watching=0;
        ck143(address_type>=0&&address_own==l2_own_ty_of_param(address_type),"retained prefix-address type equals the selected exact address contract");
        ck143(walks==1,"retained prefix-address typing enters the actual common fold ONCE");
        ck143(roots==1,"retained prefix-address selects its root ONCE");
        lm_p0_document_destroy(address_doc);
        /* A cached grammar must not retain a stale semantic verdict. */
        ft[0]=0;memset(&raw,0,sizeof raw);walks=roots=0;watching=1;status=head_place(stmt,&array,&raw);watching=0;
        ck143(status!=0&&status!=7,"later actual nonpointer contract is refused,not an ancestor's pointer");
        ck143(walks==1,"refused head still has only one actual semantic fold");
        ck143(roots==1,"refused head selects its current root ONCE");
        ck143(head->prepared.fi==-1&&head->prepared.leaf_kind==-1&&head->prepared.n==rank,"cached grammar remains unresolved and intact");
        if(status==7)l2_address_release(&raw);else if(!status)l2_array_place_release(&array);
        ft[0]=ty;l2_application_free();lm_p0_document_destroy(doc);
    }
    printf("one INDEX dispatch: %d checks, %d failures\n",checks,failures);return failures!=0;
}
