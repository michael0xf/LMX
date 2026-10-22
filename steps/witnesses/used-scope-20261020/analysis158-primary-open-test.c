#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#define main index157_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks,failures,watching,adapters,roots,folds;
void __cyg_profile_func_enter(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn,void *site){
    (void)site;if(!watching)return;
    if(fn==(void*)l2_path_steps_operand)++adapters;
    if(fn==(void*)l2_path_root_resolve)++roots;
    if(fn==(void*)l2_path_walk_steps_from)++folds;
}
void __cyg_profile_func_exit(void *fn,void *site){(void)fn;(void)site;}
static void ck(int yes,const char *why){++checks;if(!yes){++failures;fprintf(stderr,"FAIL ANALYSIS158: %s\n",why);}}
static void begin(void){adapters=roots=folds=0;watching=1;}
static void owners(void){
    l2_bound_free();l2_application_free();l2_indent_free();l2_expr_sites_free();l2_graph_places_free();l2_scope_free();
    for(int i=0;i<l2_ltx_n;++i)l2_xfree(l2_ltx[i]);
    l2_xfree(l2_ltx);l2_ltx=NULL;l2_ltx_n=l2_ltx_cap=0;
}
static int independent(const L2Path *a,const L2Path *b);
static int span_independent(const L2ValueSpan *a,const L2ValueSpan *b){
    if(a->grammar!=b->grammar||a->count!=b->count||a->node!=b->node||a->first!=b->first||a->value_n!=b->value_n)return 0;
    if((a->values!=NULL)!=(b->values!=NULL)||(a->prepared!=NULL)!=(b->prepared!=NULL)||(a->operand!=NULL)!=(b->operand!=NULL))return 0;
    if(a->prepared&&(a->prepared==b->prepared||!independent(a->prepared,b->prepared)))return 0;
    if(a->operand&&(a->operand==b->operand||!span_independent(a->operand,b->operand)))return 0;
    if(a->values&&a->values==b->values)return 0;
    for(int i=0;i<a->value_n;++i)if(!span_independent(a->values+i,b->values+i))return 0;
    return 1;
}
static int independent(const L2Path *a,const L2Path *b){
    if(!l2_path_same_grammar(a,b)||(a->steps&&a->steps==b->steps))return 0;
    for(int i=0;i<a->n;++i)if(a->steps[i].locus==7&&!span_independent(&a->steps[i].index,&b->steps[i].index))return 0;
    return 1;
}
static L2ValueSpan *tokens(const char *source,LmP0Document **doc,int *n){
    if(lm_p0_parse_bytes(source,strlen(source),doc)||!*doc)abort();
    LmP0Node *stmt=l2_next_active(lm_p0_document_mutable_root(*doc)->as->structure->first_field)->value;
    return l2_value_fields(stmt->as->frame->body->first_field,l2_count_active(stmt->as->frame->body),n);
}
int main(int argc,char **argv){
    if(argc!=2)abort();l2_out=fopen(argv[1],"wb+");if(!l2_out)abort();
    LmP0Text p={0},q={0},r={0},word={0};p.data="p";p.length=1;q.data="q";q.length=1;r.data="r";r.length=1;word.data="int";word.length=3;
    LmP0Text *names[]={&p,&q},*method_names[]={NULL,NULL};void *input_rows[]={names,names};
    int ft0[]={11,11},ft1[]={11,11},*ft_rows[]={ft0,ft1},arity[]={2,2},dynamic[]={0,0},slots[]={0,0};LmP0Node *nodes[]={NULL,NULL};
    l2_m_n=l2_m_cap=l2_slot_cap=2;l2_e=0;l2_cur_mi=l2_rw_mi=0;
    l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_fn=input_rows;l2_m_ft=ft_rows;l2_m_sn=slots;
    l2_m_name=method_names;l2_m_node=l2_m_body=nodes;l2_src="index157";l2_rw_quiet=1;l2_construct_phase=-1;
    const int depths[]={1,4,16};
    for(unsigned k=0;k<sizeof depths/sizeof depths[0];++k){
        int depth=depths[k],n=0;char source[4096];strcpy(source,"return: p[");
        for(int i=1;i<depth;++i)strcat(source,"q[");
        strcat(source,"q[0] + 1");for(int i=0;i<depth;++i)strcat(source,"]");strcat(source,"\n");
        LmP0Document *doc=NULL;L2ValueSpan *tok=tokens(source,&doc,&n);if(!tok||n!=1||!tok->prepared)abort();
        L2Path *path=tok->prepared;ck(path->n==1&&path->indexed==1&&path->steps[0].index.grammar==3,"adapter owns INDEX expression grammar before semantics");
        L2Path copied,view,record;begin();int status=l2_path_record_copy(path,&copied);status|=l2_path_record_view(path,&record);status|=l2_path_prepared_view(path,&view);watching=0;
        ck(!status&&!adapters&&!roots&&!folds&&independent(path,&copied)&&independent(path,&record)&&independent(path,&view),"all record/semantic views independently own every nested child without parsing");
        ck(copied.owned&&copied.text!=path->text&&!view.owned&&view.text==path->text,"owned copies and borrowed root-text views keep their distinct lifetimes");
        l2_path_release(&record);l2_path_release(&view);
        int exact=-1;begin();int kind=l2_value_span_type(tok,0,&exact);watching=0;
        ck(kind==0&&exact==0&&!adapters,"whole result closes from prepared grammar without an adapter retry");
        begin();status=l2_scan_value_span(&path->steps[0].index,0,NULL,0);watching=0;
        ck(!status&&!adapters,"lexical/capture traversal borrows all nested INDEX grammar without field-list reconstruction");
        begin();status=l2_value_path_effects(&path->steps[0].index,0);watching=0;
        ck(!status&&!adapters&&path->root_ft==11,"effects create fresh semantic views of the held INDEX trees without adapter calls or mutation");
        char data[2048];L2Tx dest={0};if(l2_tx_open(&dest,data,sizeof data))abort();
        begin();status=l2_check_value_span(tok,0,l2_src,tok->node);status|=l2_emit_native_span(tok,0,"",&dest,NULL);watching=0;
        ck(!status&&!adapters,"CHECK and machine native evaluate the same held INDEX trees");
        begin();status=l2_path_prepared_view(path,&view);status|=l2_path_record_copy(path,&record);watching=0;
        L2Path *fresh=view.steps[0].index.values[0].prepared,*closed=record.steps[0].index.values[0].prepared;
        ck(!status&&fresh&&closed&&fresh->root_ft==-2&&!fresh->value_status&&closed->root_ft==11&&closed->value_status==1&&!adapters&&!roots&&!folds,"semantic views reset nested root/type verdicts while completed copies preserve them");
        l2_path_release(&view);l2_path_release(&record);
        printf("ANALYSIS158 depth=%d clone/verdict projection adapters=%d roots=%d folds=%d\n",depth,adapters,roots,folds);
        names[0]=names[1]=&r;ft0[0]=ft0[1]=0;
        begin();status=l2_check_value_span(tok,0,l2_src,tok->node);status|=l2_emit_native_span(tok,0,"",&dest,NULL);watching=0;
        ck(!status&&!adapters&&!roots&&!folds,"nested native/CHECK use closed INDEX roots after name+FT poison");
        begin();status=l2_value_path_effects(&path->steps[0].index,0);watching=0;
        ck(status==1&&!adapters&&path->root_ft==11,"fresh effects see current binding refusal rather than an old verdict; the closed native result stays intact");
        l2_rw_t=0;l2_rw_emit=0;l2_rw_machine=0;int out=-1;
        begin();status=l2_rw_span(tok,0,-2,&out);watching=0;int count=l2_rw_t,machine=l2_rw_machine;
        ck(!status&&!adapters&&!roots&&!folds,"retained machine COUNT borrows each closed INDEX child after poison");
        l2_rw_t=0;l2_rw_emit=1;l2_rw_machine=0;
        begin();status=l2_rw_span(tok,0,-2,&out);watching=0;
        ck(!status&&l2_rw_t==count&&l2_rw_machine==machine&&!adapters&&!roots&&!folds,"retained machine EMIT borrows the same INDEX result and COUNT geometry");
        l2_rw_emit=0;
        names[0]=&p;names[1]=&q;ft0[0]=ft0[1]=11;
        l2_value_spans_release(tok,n);
        begin();kind=l2_path_walk(&copied);watching=0;
        ck(!kind&&!adapters&&copied.text[0]=='p',"copied trees and owned root text survive original operand release");
        l2_path_release(&copied);owners();lm_p0_document_destroy(doc);
    }
    {
        const char *source="return: p[q[0] + 1]\n";LmP0Document *doc=NULL;int n=0;
        L2ValueSpan *tok=tokens(source,&doc,&n);if(!tok)abort();L2Path *path=tok->prepared;
        if(l2_path_walk(path))abort();
        size_t before=l2_alloc_n,live=l2_alloc_live;L2Path copy;
        if(l2_path_record_copy(path,&copy))abort();size_t sites=l2_alloc_n-before;l2_path_release(&copy);
        ck(sites>0&&sites<=(size_t)INT_MAX&&l2_alloc_live==live,"measure full recursive record copy ownership");
        for(size_t point=1;point<=sites;++point){
            l2_fail_left=(int)point;l2_alloc_err=0;begin();int status=l2_path_record_copy(path,&copy);watching=0;
            ck(status!=0&&l2_alloc_err&&l2_fail_left==0&&!adapters&&!roots&&!folds,"every recursive record-copy refusal is final without parser retry");
            l2_path_release(&copy);ck(l2_alloc_live==live,"failed partial recursive copies release all owners exactly once");l2_fail_left=l2_alloc_err=0;
        }
        printf("ANALYSIS158 recursive copy allocation sites=%zu\n",sites);
        if(l2_path_fact_note_bytes(path,0))abort();L2PathFact *fact=l2_path_facts;if(!fact)abort();
        ck(independent(path,&fact->resolved),"bound facts independently own child trees inside stable arena step storage");
        char *text=(char*)fact->resolved.text;L2PathStep *steps=fact->resolved.steps;
        before=l2_alloc_n;live=l2_alloc_live;if(l2_path_fact_store(fact,path))abort();sites=l2_alloc_n-before;
        ck(l2_alloc_live==live&&text==fact->resolved.text&&steps==fact->resolved.steps,"successful replacement keeps bound addresses and balances old/new owners");
        for(size_t point=1;point<=sites;++point){
            L2ValueSpan *children=fact->resolved.steps[0].index.values;int ft=fact->resolved.root_ft;
            l2_fail_left=(int)point;l2_alloc_err=0;begin();int status=l2_path_fact_store(fact,path);watching=0;
            ck(status!=0&&l2_alloc_err&&!adapters&&!roots&&!folds,"fact replacement allocation refusal never republishes a partial result");
            ck(l2_alloc_live==live&&fact->resolved.steps==steps&&fact->resolved.text==text&&fact->resolved.steps[0].index.values==children&&fact->resolved.root_ft==ft&&independent(path,&fact->resolved),"failed replacement leaves exact old child owner,root type,geometry and arena addresses intact");
            l2_fail_left=l2_alloc_err=0;
        }
        printf("ANALYSIS158 transactional fact allocation sites=%zu\n",sites);
        l2_value_spans_release(tok,n);owners();lm_p0_document_destroy(doc);
    }
    {
        const char *forms[]={"return: p[(q[0] + 1)]\n","return: p[-(q[0] + 1)]\n","return: p[+(q[0] + 1)]\n","return: p[\\(@: q[0])]\n"};
        for(unsigned k=0;k<sizeof forms/sizeof forms[0];++k){
            size_t live=l2_alloc_live;
            LmP0Document *doc=NULL;int n=0;L2ValueSpan *tok=tokens(forms[k],&doc,&n);if(!tok||!tok->prepared)abort();
            int depth=l2_scope_n;
            if(k==3){L2ValueSpan *v=tok->prepared->steps[0].index.values;printf("ANALYSIS158 form3 grammar=%d nodekind=%d operand=%d children=%d",v->grammar,v->node->kind,v->operand!=NULL,v->value_n);if(v->node->kind==LM_P0_NODE_FRAME)printf(" head='%.*s' flags=%d",(int)v->node->as->frame->head->length,v->node->as->frame->head->data,v->node->as->frame->flags);puts("");}
            begin();int status=l2_scan_value_span(&tok->prepared->steps[0].index,0,NULL,0);watching=0;
            printf("ANALYSIS158 form=%u lexical status=%d adapters=%d roots=%d folds=%d scope=%d/%d\n",k,status,adapters,roots,folds,l2_scope_n,depth);
            ck(!status&&!adapters&&l2_scope_n==depth,"group/sign/address/dereference INDEX operands share the lexical visitor without depth/form reparsing");
            begin();status=l2_value_path_effects(&tok->prepared->steps[0].index,0);watching=0;
            printf("ANALYSIS158 form=%u effects status=%d adapters=%d roots=%d folds=%d scope=%d/%d\n",k,status,adapters,roots,folds,l2_scope_n,depth);
            ck(!status&&!adapters&&l2_scope_n==depth,"owned group/prefix/address effects preserve ordinary scope balance without re-reading fields");
            l2_value_spans_release(tok,n);owners();lm_p0_document_destroy(doc);
            ck(l2_alloc_live==live,"group/prefix/address lexical facts and effect-scope owners release with their actual compilation lifetimes");
        }
    }
    {
        char text[]={'p','!'};L2Path raw,copy;l2_path_init(text,1U,&raw);
        begin();int status=l2_path_record_copy(&raw,&copy);watching=0;
        ck(!status&&copy.owned&&copy.length==1&&copy.text[0]=='p'&&copy.text[1]==0&&!adapters&&!roots&&!folds,"owned text copies obey the explicit span length and provide their own terminator");
        l2_path_release(&copy);
        LmP0Node node={0};LmP0Field field={0};L2PathStep step;l2_path_step_clear(&step);
        step.locus=7;step.index.first=&field;step.index.node=&node;step.index.count=1;
        raw.n=raw.cap=raw.indexed=1;raw.steps=&step;
        begin();status=l2_path_record_copy(&raw,&copy);watching=0;
        ck(!status&&copy.steps[0].index.first==&field&&copy.steps[0].index.node==&node&&!copy.steps[0].index.grammar&&!copy.steps[0].index.values&&!adapters&&!roots&&!folds,"metadata-only coordinates remain unprepared through a copy,never parsed at a copy boundary");
        l2_path_release(&copy);
    }
    fclose(l2_out);l2_out=NULL;printf("ANALYSIS158: %d checks, %d failures\n",checks,failures);return failures!=0;
}
