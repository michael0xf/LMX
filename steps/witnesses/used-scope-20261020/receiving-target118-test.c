#ifndef L2_FRONTEND_SOURCE
#define L2_FRONTEND_SOURCE "l2trans.c"
#endif
#define main target_source_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks,failures;
static void expect(int yes,const char *why){++checks;if(!yes){++failures;fprintf(stderr,"FAIL resolved receiving target: %s\n",why);}}
static int edge(int method,int key){
 for(int i=0;i<l2_d105e_n;++i)if(l2_d105e_fmi[i]==0&&l2_d105e_fk[i]==0&&l2_d105e_tmi[i]==method&&l2_d105e_tk[i]==key)return 1;
 return 0;
}
static int receive(const LmP0Node *at,LmP0Field *first,const L2Path *target){
#ifdef OLD_RECEIVING_API
 (void)target;
 return l2_check_reference_receiving(at,first,1,0,NULL,0);
#else
 return l2_check_reference_receiving_at(at,first,1,0,NULL,0,target);
#endif
}
int main(void){
 LmP0Text b={0},z={0};b.data="b";b.length=1;z.data="unbound-spelling";z.length=16;
 LmP0Text *inputs[]={&b},*empty_names[]={NULL};void *input_rows[]={inputs};
 int arity[]={1},dynamic[]={0},throws[]={0},negative[]={-1};
 int fm[]={0},fk[]={0},model[]={0},field_kind[]={10};size_t field_model[]={1};
 LmP0Node *empty_nodes[]={NULL};
 LmP0Node node={0},statement={0};LmP0NodeAs node_as={0};LmP0Field first={0};
 node.kind=LM_P0_NODE_ATOM;node.as=&node_as;node_as.atom=&z;first.value=&node;
 L2SourceSite site={0};L2PathFact fact={0};L2Path path;L2PathStep steps[129];
 l2_m_n=1;l2_e=0;l2_cur_mi=0;l2_here_source_mi=0;l2_here_node=&statement;
 l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_fn=input_rows;l2_m_throws=throws;
 l2_m_node=l2_m_body=empty_nodes;l2_m_name=empty_names;
 l2_ns_n=1;l2_ns_name=empty_names;l2_ns_eternal=l2_ns_proc=negative;
 l2_nsty_n=1;l2_nsty_mi=fm;l2_nsty_k=fk;l2_nsty_ni=model;
 l2_nsf_n=1;l2_nsf_kind=field_kind;l2_nsf_val=field_model;
 site.method=site.source_method=site.current_method=0;site.excluded=-1;
 fact.method=fact.source_method=0;fact.source=&node;fact.source_use=2;
 fact.input_symbol=&b;fact.use_site=&site;
 l2_path_init(z.data,z.length,&fact.resolved);fact.resolved.fi=0;
 l2_path_facts=l2_path_facts_tail=&fact;
 l2_path_init(NULL,0,&path);path.n=path.cap=129;path.names=64;path.indexed=65;
 path.steps=steps;path.leaf_kind=10;path.leaf_model=0;path.leaf_mi=path.leaf_ty=l2_graph_code();
 for(int i=0;i<129;++i){l2_path_step_clear(steps+i);steps[i].locus=i%2?1:7;}
 steps[128].nsrow=0;steps[128].kind=10;
 int key=l2_d105_field_key(0);
 expect(!receive(&statement,&first,&path),"a resolved mixed target is received without any target text or spelling lookup");
 expect(edge(0,key),"the actual source port reaches the already selected field port,not merely the receiving schema");
 expect(throws[0]&&l2_need_admit,"runtime admission remains mandatory after compile-time source flow");
 expect(!path.text&&path.n==129&&path.names==64&&path.indexed==65&&path.steps==steps&&steps[128].nsrow==0,
        "the checker borrows the entire target without slicing,mutating or reallocating its geometry");
 expect(fact.receivers&&fact.receivers->method==0&&fact.receivers->key==key,
        "Consumer reception is attached to the same source occurrence and physical target key");
 int before=l2_d105e_n;L2UseReceiver *receiver=fact.receivers;
 expect(!receive(&statement,&first,&path)&&l2_d105e_n==before&&fact.receivers==receiver,
        "rechecking the same prepared target deduplicates existing equations and roles");
 steps[128].nsrow=-1;steps[128].formal=0;steps[128].node_host=0;
 expect(!receive(&statement,&first,&path)&&edge(0,0),"a formal target consumes its bound input port through the same projection");
 steps[128].formal=steps[128].node_host=-1;steps[128].nsrow=0;path.fail_why=2;
 l2_d105_reset();
 expect(!receive(&statement,&first,&path)&&!edge(0,key),"a refused target cannot publish a leftover successful field port");
 path.fail_why=0;path.array_leaf=1;l2_d105_reset();
 expect(!receive(&statement,&first,&path)&&!edge(0,key),"whole array storage is not confused with its element port");
 path.array_leaf=0;l2_d105_reset();l2_own_n=INT_MAX;
 expect(receive(&statement,&first,&path)==1&&l2_alloc_err==2,
        "target flow-key exhaustion propagates;it cannot become a missing optional path");
 l2_own_n=0;l2_alloc_err=0;
 printf("resolved receiving target: %d checks, %d failures\n",checks,failures);
 return failures!=0;
}
