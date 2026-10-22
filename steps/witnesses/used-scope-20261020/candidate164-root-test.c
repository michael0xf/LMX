#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#define main root155_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks,failures,watching,selections,root_reads,contract_reads,input_reads,formal_reads;
void __cyg_profile_func_enter(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn,void *site){
    (void)site;if(!watching)return;
    if(fn==(void*)l2_path_root_resolve)++selections;
    if(fn==(void*)l2_path_selected_binding_ft)++root_reads;
    if(fn==(void*)l2_path_selected_contract)++contract_reads;
    if(fn==(void*)l2_input_ft)++input_reads;
    if(fn==(void*)l2_formal_decl_at)++formal_reads;
}
void __cyg_profile_func_exit(void *fn,void *site){(void)fn;(void)site;}
static void ck(int good,const char *why){++checks;if(!good){++failures;fprintf(stderr,"FAIL ROOT155: %s\n",why);}}
static void begin(void){selections=root_reads=contract_reads=input_reads=formal_reads=0;watching=1;}
static void owners(void){
    l2_bound_free();l2_application_free();l2_indent_free();
    for(int i=0;i<l2_ltx_n;++i)l2_xfree(l2_ltx[i]);
    l2_xfree(l2_ltx);l2_ltx=NULL;l2_ltx_n=l2_ltx_cap=0;
}
static char *chunk(long first,long last){
    if(last<first||fflush(l2_out)||fseek(l2_out,first,SEEK_SET))abort();
    char *p=malloc((size_t)(last-first)+1);if(!p)abort();
    if(fread(p,1,(size_t)(last-first),l2_out)!=(size_t)(last-first))abort();
    p[last-first]=0;if(fseek(l2_out,0,SEEK_END))abort();return p;
}
int main(int argc,char **argv){
    if(argc!=2)abort();l2_out=fopen(argv[1],"wb+");if(!l2_out)abort();
    LmP0Text p={0},q={0},word={0};p.data="p";p.length=1;q.data="q";q.length=1;word.data="int";word.length=3;
    LmP0Text *names[]={&p},*method_names[]={NULL,NULL};void *input_rows[]={names,names};
    int ft0[]={0},ft1[]={0},*ft_rows[]={ft0,ft1},arity[]={1,1},dynamic[]={0,0},slots[]={0,0};LmP0Node *nodes[]={NULL,NULL};
    l2_m_n=l2_m_cap=l2_slot_cap=2;l2_e=0;l2_cur_mi=l2_rw_mi=0;
    l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_fn=input_rows;l2_m_ft=ft_rows;l2_m_sn=slots;
    l2_m_name=method_names;l2_m_node=l2_m_body=nodes;l2_src="root155";l2_rw_quiet=1;l2_construct_phase=-1;
    const int ranks[]={0,1,2,6,65,129};
    for(unsigned k=0;k<sizeof ranks/sizeof ranks[0];++k)for(int qualified=0;qualified<2;++qualified){
        int rank=ranks[k],n=0;
        int original=rank?l2_foreign_intern_parts(&word,rank,qualified,0):0;
        ft0[0]=ft1[0]=original;
        for(int depth=1;depth<=rank+1;++depth)l2_foreign_intern_parts(&word,depth,qualified,0);
        char source[2048];strcpy(source,"return: p");for(int i=0;i<rank;++i)strcat(source,"[0]");strcat(source," + 2\n");
        LmP0Document *doc=NULL;if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();
        LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;
        L2ValueSpan *tok=l2_value_fields(stmt->as->frame->body->first_field,l2_count_active(stmt->as->frame->body),&n);if(!tok||n!=3)abort();
        begin();int status=l2_check_prepared_kinds(tok,n,0,l2_src,stmt);watching=0;
        L2Path *held=tok->prepared;
        ck(!status&&held&&held->root_ft==original&&held->root_contract_own==-1&&root_reads==1&&contract_reads==1,"first use closes exact root type and carried contract once");
        L2Path view,copy,grammar;
        ck(!l2_path_record_view(held,&view)&&!l2_path_record_copy(held,&copy),"record views and owned copies retain the same root verdict");
        ck(!l2_path_prepared_view(held,&grammar)&&grammar.root_ft==-2&&!grammar.root_level&&grammar.root_contract_own==-1,"another semantic preparation resets root type and contract together");
        l2_path_release(&grammar);
        char text0[1024],text1[1024];L2Tx a={0},b={0};if(l2_tx_open(&a,text0,sizeof text0)||l2_tx_open(&b,text1,sizeof text1))abort();
        int next=l2_tn;long start=ftell(l2_out);
        status=l2_emit_native_values(tok,0,n-1,0,"",&a,NULL);long finish=ftell(l2_out);char *before=chunk(start,finish);
        ck(!status,"held native projection produces complete physical expression");
        ft0[0]=rank?0:11;names[0]=&q;l2_tn=next;start=ftell(l2_out);
        begin();status=l2_emit_native_values(tok,0,n-1,0,"",&b,NULL);watching=0;finish=ftell(l2_out);
        char *after=chunk(start,finish);
        ck(!status&&!root_reads&&!contract_reads&&!input_reads&&!formal_reads,"native projection never rereads poisoned formal type or contract tables");
        ck(!strcmp(a.data,b.data)&&!strcmp(before,after),"actual generated L1 expression and pointer-context setup remain byte-identical after poison");
        ck(l2_path_root_binding_ft(&view,0)==original&&l2_path_root_binding_ft(&copy,0)==original,"borrowed and owned root results survive source type poison");
        L2ValueSpan *fresh=l2_value_fields(stmt->as->frame->body->first_field,l2_count_active(stmt->as->frame->body),&n);
        L2Path *new_result=NULL;begin();status=l2_value_span_path(fresh,0,&new_result);watching=0;
        ck(status==2&&selections==1&&!root_reads,"a fresh query rejects removed spelling before any root type can be closed");
        l2_value_spans_release(fresh,n);names[0]=&p;
        fresh=l2_value_fields(stmt->as->frame->body->first_field,l2_count_active(stmt->as->frame->body),&n);
        begin();status=l2_value_span_path(fresh,0,&new_result);watching=0;
        ck(selections==1&&root_reads==1&&new_result&&new_result->root_ft==ft0[0]&&status==(rank?2:0),"an independent valid binding sees its current changed type,not the held root FT");
        ++l2_value_revision;
        begin();status=l2_value_span_path(tok,0,&new_result);watching=0;
        ck(new_result==held&&selections==1&&root_reads==1&&held->root_ft==ft0[0]&&held->value_revision==l2_value_revision&&status==(rank?2:0),"a new common source-plan revision recloses the same owned grammar and all root/step verdicts instead of retaining an early map");
        free(before);free(after);names[0]=&p;ft0[0]=original;
        l2_value_spans_release(fresh,n);l2_path_release(&view);l2_path_release(&copy);l2_value_spans_release(tok,3);owners();lm_p0_document_destroy(doc);
    }
    {
        const char *source="@: int owner\n";LmP0Document *doc=NULL;
        if(lm_p0_parse_bytes(source,strlen(source),&doc)||!doc)abort();
        LmP0Node *decl=l2_next_active(lm_p0_document_mutable_root(doc)->as->structure->first_field)->value;
        LmP0Node *decls[]={decl};int own_types[]={11};
        /* This parsed builtin declaration has no lexical inherited source.
           Supply that source context before consulting its declaration. */
        int saved_here=l2_here_mi;l2_here_mi=-1;
        l2_own_n=1;l2_own_ty=own_types;l2_own_decl=decls;
        L2Path held;l2_path_init("owner",5,&held);held.oi=held.root_own=0;
        begin();int status=l2_path_root_close(&held,0);watching=0;
        L2TypeContract *original=held.root_level;int exact=held.root_ft;
        ck(!status&&original&&held.root_contract_own==0&&root_reads==1&&contract_reads==1,"own root closes its real parsed declaration contract at the common boundary");
        L2Path view,copy,grammar;
        ck(!l2_path_record_view(&held,&view)&&!l2_path_record_copy(&held,&copy)&&view.root_contract_own==0&&copy.root_contract_own==0&&view.root_level==original&&copy.root_level==original,"root requirement source travels with both borrowed and owned verdicts");
        ck(!l2_path_prepared_view(&held,&grammar)&&grammar.root_contract_own==-1&&grammar.root_ft==-2&&!grammar.root_level,"fresh grammar clears requirement provenance,type and contract as one semantic result");
        l2_path_release(&view);l2_path_release(&copy);l2_path_release(&grammar);
        decls[0]=NULL;own_types[0]=0;
        begin();L2TypeContract *after=l2_path_root_contract(&held);int type=l2_path_root_binding_ft(&held,0);status=l2_path_root_close(&held,0);watching=0;
        ck(!status&&after==original&&type==exact&&held.root_contract_own==0&&!root_reads&&!contract_reads,"held own root getters and repeated close do not reread mutated declaration/type rows");
        decls[0]=decl;own_types[0]=11;owners();
        size_t live=l2_alloc_live,first_alloc=l2_alloc_n;
        l2_path_init("owner",5,&held);held.oi=held.root_own=0;
        status=l2_path_root_close(&held,0);size_t sites=l2_alloc_n-first_alloc;owners();
        ck(!status&&sites>0&&sites<32&&l2_alloc_live==live,"measure root-close declaration allocations with their actual application owner");
        for(size_t point=1;point<=sites;++point){
            l2_path_init("owner",5,&held);held.oi=held.root_own=0;l2_fail_left=(int)point;l2_alloc_err=0;
            status=l2_path_root_close(&held,0);
            ck(status&&l2_alloc_err&&held.root_ft==-2&&!held.root_level&&held.root_contract_own==-1,"root-close allocation refusal publishes neither stale type nor partial carried contract");
            owners();ck(l2_alloc_live==live,"every partially closed root releases its declaration/application owner exactly");
            l2_fail_left=0;l2_alloc_err=0;
        }
        printf("ROOT155 allocation sites=%zu\n",sites);
        l2_own_n=0;l2_own_ty=NULL;l2_own_decl=NULL;l2_here_mi=saved_here;owners();lm_p0_document_destroy(doc);
    }
    {
        int machine_types[]={11},slot_types[]={19,0};LmP0Text *machine_names[]={&p};
        l2_ml_n=1;l2_ml_ty=machine_types;l2_ml_nm=machine_names;l2_st=slot_types;slots[0]=1;
        for(int kind=4;kind<=6;++kind){
            L2Path held;l2_path_init("p",1,&held);held.root_kind=kind;held.root=0;
            ck(!l2_path_root_close(&held,0),"machine/slot/constant roots enter the same close boundary");
            int exact=held.root_ft;machine_types[0]=0;slot_types[0]=0;
            begin();int type=l2_path_root_binding_ft(&held,0);int status=l2_path_root_close(&held,0);watching=0;
            ck(type==exact&&!status&&!root_reads&&!contract_reads,"held machine/slot/constant root projects once-closed type,including known unknown");
            if(kind==6)ck(type==-1,"declared external constants acquire no invented L2 storage type");
            machine_types[0]=11;slot_types[0]=19;
        }
        l2_ml_n=0;l2_ml_ty=NULL;l2_ml_nm=NULL;l2_st=NULL;slots[0]=0;
    }
    fclose(l2_out);l2_out=NULL;
    printf("ROOT155: %d checks, %d failures\n",checks,failures);return failures!=0;
}
