/* Consumer equations against the real compiled frontend, not a second fold. */
#ifndef L2_FRONTEND_SOURCE
#define L2_FRONTEND_SOURCE "l2trans.c"
#endif
#define main l2_consumer_test_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks,failures;
static void expect(int good,const char *what)
{
 ++checks;if(!good){++failures;fprintf(stderr,"FAIL %s\n",what);}
}
int main(void)
{
 LmP0Text p={0},q={0},r={0};
 LmP0Text *names0[]={&p},*names1[]={&q},*names2[]={&r};
 void *names[]={names0,names1,names2};
 int arity[]={1,1,1},dynamic[]={0,0,0};
 L2UsePlanLevel *a,*b,*other,*left,*right,*shared,*holder,*identity,*unknown,*forward,*result;
 L2UsePlanEdge *e0,*e1,*e2;
 L2UseReceiver receiver={0};
 L2PathFact fact={0};
 L2PathStep step={0};
 int before,live=l2_alloc_live,n,whole,value;
 l2_m_n=3;l2_m_arity=arity;l2_m_dyn=dynamic;l2_m_fn=names;
 l2_uses_methods=3;l2_uses_ready=1;l2_src="consumer-equation-unit";
 l2_room_tag="source-use-consumer-unit";
 a=l2_use_plan_level(0,0,0);b=l2_use_plan_level(1,0,0);
 expect(a && b && a!=b,"bound consumers have distinct port identities");
 expect(l2_use_plan_level(0,0,0)==a && l2_use_plan_n==2,"same bound equation is deduplicated");
 other=l2_use_plan_level(0,0,1);
 expect(other && other!=a,"a different required schema is not the same equation");
 left=l2_use_plan_level(-1,-1,0);right=l2_use_plan_level(-1,-1,0);
 expect(left && right && left!=right,"nested scopes are not interned merely by schema");
 shared=l2_use_plan_level(2,0,0);
 expect(!l2_use_plan_link(a,b) && !l2_use_plan_link(b,a),"recursive aliases are finite equations");
 before=l2_bnd_mem_n;
 expect(!l2_use_plan_link(a,b) && l2_bnd_mem_n==before,"same alias allocates no duplicate equation");
 expect(!l2_use_plan_link(a,a) && l2_bnd_mem_n==before,"self recursion adds no unbounded work");
 l2_use_plan_seen(a);
 expect(a->seen && b->seen && !other->seen && !left->seen,"alias closure reaches exactly its component");
 l2_use_plan_full();
 expect(!a->full && !b->full,"a finite alias cycle is not inherently unknown");
 b->full=1;l2_use_plan_full();
 expect(a->full && b->full && !other->full,"unknown propagates along actual aliases only");
 a->full=b->full=0;
 expect(!l2_use_plan_link(left,shared) && !l2_use_plan_link(right,shared),"two nested consumers may share a downstream port");
 left->full=1;l2_use_plan_full();
 expect(!right->full && !shared->full,"one nested scope does not poison the other through a common callee");
 holder=l2_use_plan_level(-1,-1,0);
 step.locus=1;step.kind=7;step.row=7;step.segocc=-1;step.host_ns=0;
 step.host_res=-1;step.index.count=3;step.model_step=9;step.model_context=4;
 e0=l2_use_plan_edge(holder,&step,0);e1=l2_use_plan_edge(holder,&step,0);
 expect(e0 && e1 && e0!=e1 && holder->edges==e1 && e1->next==e0,"same field can carry independent nested requirements");
 expect(e0 && e0->step.index.count==3 && e0->step.model_step==9 && e0->step.model_context==4,"edge retains the complete resolved step and contract origin");
 e0->below=left;e1->below=right;l2_use_plan_full();
 expect(!holder->full && e0->below==left && e1->below==right,"child requirements are not mistaken for whole-parent aliases");
 step.row=99;step.model_step=10;
 expect(e0->step.row==7 && e0->step.model_step==9,"stored coordinate is not a borrowed mutable stack verdict");
 identity=l2_use_plan_level(-1,-1,0);
 fact.method=0;fact.source_use=2;fact.use_roles=1;
 expect(!l2_use_plan_role(identity,&fact) && !identity->full && !identity->edges && !identity->links,"identity-only consumption is a known empty field requirement");
 unknown=l2_use_plan_level(-1,-1,0);fact.use_roles=0;
 expect(!l2_use_plan_role(unknown,&fact) && unknown->full && !unknown->edges,"unclassified whole use is full, not empty permission");
 forward=l2_use_plan_level(-1,-1,0);
 receiver.method=1;receiver.key=0;receiver.input_symbol=&q;
 fact.use_roles=2;fact.receivers=&receiver;
 expect(!l2_use_plan_role(forward,&fact) && !forward->full && forward->links && forward->links->target==b,"forwarding composes an existing checked port");
 before=l2_use_plan_n;
 expect(!l2_use_plan_role(forward,&fact) && l2_use_plan_n==before,"repeated forwarding does not unfold a body again");
 fact.receivers=0;
 expect(!l2_use_plan_role(forward,&fact) && forward->full,"missing receiving evidence is unknown, not success");
 fact.receivers=&receiver;receiver.input_symbol=0;receiver.key=-1;
 result=l2_use_plan_level(-1,-1,0);
 expect(!l2_use_plan_role(result,&fact) && result->links && result->links->target->key==-1,"result remains a distinct contract port");
 expect(!l2_use_plan_build(result->links->target,arity) && result->links->target->full,"a typed return without a concrete Consumer keeps full structural fitness");
 before=l2_use_plan_n;l2_fail_left=1;
 expect(!l2_use_plan_level(-1,-1,0) && l2_use_plan_n==before,"failed allocation publishes no partial query level");
 l2_fail_left=0;l2_alloc_err=0;
 before=l2_bnd_mem_n;l2_fail_left=1;e2=l2_use_plan_edge(holder,&step,0);
 expect(!e2 && holder->edges==e1 && l2_bnd_mem_n==before,"failed edge allocation leaves prior requirements intact");
 l2_fail_left=0;l2_alloc_err=0;
 expect(!l2_ruse_append(0,e0) && !l2_ruse_append(0,e1),"both duplicate field requirements reach shared serialized coverage");
 expect(l2_ruse_e_n==2 && l2_ruse_e_edge[0]==e0 && l2_ruse_e_edge[1]==e1,"serialization does not merge distinct child scopes");
 expect(l2_ruse_e_below[0]==-1 && l2_ruse_e_below[1]==right->id,"only the full child is serialized as full below");
 expect(!l2_ruse_room(0),"per-receiver cells have checked capacity growth");
 l2_ruse_first[0]=0;l2_ruse_count[0]=2;l2_ruse_levels[0]=l2_use_plan_n+1;
 n=1+l2_ruse_levels[0]+4;
 expect(l2_ruse_cells(0)==n,"coverage count is topology only, independent of physical width");
 expect(!l2_ruse_cell(0,0,&whole,&value) && !whole && value==n,"cell zero carries the same topology count");
 expect(!l2_ruse_cell(0,1,&whole,&value) && !whole && value==2,"root contains both independent field obligations");
 l2_ruse_reset();l2_bound_free();
 expect(l2_alloc_live==live,"equations and flattened tables release through their existing lifetimes");
 fprintf(stderr,"Consumer equations: %d checks, %d failures\n",checks,failures);
 return failures!=0;
}
