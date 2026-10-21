/* Actual contract APIs only; ordinary word/value queries are not retargeted. */
typedef struct Origin145State {
    int method,source,current,on,excluded,visibility,count;
    size_t at,visible_at;
    LmP0Node *node;
    LmP0Node **scopes;
} Origin145State;
static int origin145_queries,origin145_formals,origin145_models,origin145_failures,origin145_max_scope,origin145_registered;
static int origin145_model_original(L2TypeContract *,const LmP0Text *);
static void origin145_contract_dump(void)
{
    fprintf(stderr,"origin145-contract: %d queries, %d formal, %d model, %d failures, max-scope=%d\n",
            origin145_queries,origin145_formals,origin145_models,origin145_failures,origin145_max_scope);
}
static Origin145State origin145_capture(void)
{
    Origin145State s;
    s.method=l2_here_mi;s.source=l2_here_source_mi;s.current=l2_cur_mi;
    s.on=l2_here_on;s.at=l2_here;s.node=l2_here_node;s.excluded=l2_own_excl;
    s.visibility=l2_vis_on;s.visible_at=l2_vis_at;s.count=l2_scope_n;s.scopes=NULL;
    if(s.count<0)abort();
    if(s.count){
        s.scopes=malloc((size_t)s.count*sizeof(*s.scopes));if(!s.scopes)abort();
        memcpy(s.scopes,l2_scope_at,(size_t)s.count*sizeof(*s.scopes));
    }
    if(!origin145_registered){origin145_registered=1;atexit(origin145_contract_dump);}
    ++origin145_queries;if(s.count>origin145_max_scope)origin145_max_scope=s.count;
    return s;
}
static void origin145_check(Origin145State *s)
{
    int same=s->method==l2_here_mi && s->source==l2_here_source_mi && s->current==l2_cur_mi &&
        s->on==l2_here_on && s->at==l2_here && s->node==l2_here_node && s->excluded==l2_own_excl &&
        s->visibility==l2_vis_on && s->visible_at==l2_vis_at && s->count==l2_scope_n;
    if(same && s->count)same=memcmp(s->scopes,l2_scope_at,(size_t)s->count*sizeof(*s->scopes))==0;
    free(s->scopes);
    if(!same){++origin145_failures;fprintf(stderr,"FAIL origin145 contract caller context changed\n");}
}
int l2_contract_formal(L2TypeContract *contract,int *out_ty)
{
    Origin145State s=origin145_capture();++origin145_formals;
#ifdef ORIGIN145_DROP_SOURCE
    int result=l2_contract_formal_here(contract,out_ty);
#else
    int result=origin145_formal_original(contract,out_ty);
#endif
    origin145_check(&s);return result;
}
int l2_contract_model_word(L2TypeContract *contract,const LmP0Text *word)
{
    Origin145State s=origin145_capture();++origin145_models;
#ifdef ORIGIN145_DROP_SOURCE
    (void)contract;int result=l2_type_model(word);
#else
    int result=origin145_model_original(contract,word);
#endif
    origin145_check(&s);return result;
}
