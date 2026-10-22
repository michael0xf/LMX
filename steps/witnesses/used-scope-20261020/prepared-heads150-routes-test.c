#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE
#endif
#define main heads150_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int watching,depth,check_text,source_text,native_text,rw_text,all_text,head_parser,head_adapter;
static void *calls[4096];
void __cyg_profile_func_enter(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *,void *) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn,void *site){
    (void)site;if(!watching)return;
    void *caller=depth?calls[depth-1]:NULL;
    if(fn==(void*)l2_path_resolve){
        ++all_text;
        if(caller==(void*)l2_check_path_write)++check_text;
        if(caller==(void*)l2_src_path_write)++source_text;
        if(caller==(void*)l2_emit_stmts)++native_text;
        if(caller==(void*)l2_rw_path_prepare_text)++rw_text;
    }
    if(fn==(void*)lm_p0_parse_bytes&&caller==(void*)l2_head_expression)++head_parser;
    if(fn==(void*)l2_path_steps_run&&caller==(void*)l2_head_expression)++head_adapter;
    if(depth==4096)exit(4);calls[depth++]=fn;
}
void __cyg_profile_func_exit(void *fn,void *site){(void)fn;(void)site;if(watching&&depth)--depth;}
int main(int argc,char **argv){
    watching=1;int status=heads150_frontend_main(argc,argv);watching=0;
    fprintf(stderr,"HEAD150 check_text=%d source_text=%d native_text=%d rw_text=%d all_text=%d head_parser=%d head_adapter=%d\n",check_text,source_text,native_text,rw_text,all_text,head_parser,head_adapter);
    return status;
}
