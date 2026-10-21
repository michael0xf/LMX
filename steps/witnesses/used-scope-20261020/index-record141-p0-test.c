#define main p0_record141_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks,failures;
static void ck(int yes,const char *why){++checks;if(!yes){++failures;fprintf(stderr,"FAIL canonical P0: %s\n",why);}}
static int atoms(LmP0Node *n){
 if(!n||!n->as)return 1;
 if(n->kind==LM_P0_NODE_ATOM){LmP0Text *t=n->as->atom;if(!t||!t->length)return 1;
  if(t->data[0]=='"'||t->data[0]=='\''||t->data[0]=='`')return 1;
  for(size_t k=0;k<t->length;k++)if((t->data[k]=='['||t->data[k]==']')&&t->length!=1)return 0;
  return 1;
 }
 LmP0Structure *s=n->kind==LM_P0_NODE_STRUCTURE?n->as->structure:n->kind==LM_P0_NODE_FRAME&&n->as->frame?n->as->frame->body:NULL;
 for(LmP0Field *f=s?s->first_field:NULL;f;f=f->next)if(!atoms(f->value))return 0;return 1;
}
static void check(const char *expression,int rank){
 char source[8192];LmP0Document *doc=NULL;LmP0Node *stmt;LmP0Field *first;int count,status,length;
 snprintf(source,sizeof source,"return: %s\n",expression);
 int parsed=lm_p0_parse_bytes(source,strlen(source),&doc);ck(!parsed&&doc,"actual source parses");if(parsed||!doc)abort();
 LmP0Node *root=lm_p0_document_mutable_root(doc);stmt=l2_next_active(root->as->structure->first_field)->value;
 first=l2_next_active(stmt->as->frame->body->first_field);count=l2_count_active(stmt->as->frame->body);
 ck(count>1&&first&&first->value->kind==LM_P0_NODE_ATOM,"indexed operand is not one fused text atom");
 ck(atoms(root),"P0 keeps brackets as tokens and nested expressions,not embedded unquoted atom text");
 L2Path path={0};l2_path_init(NULL,0,&path);status=l2_path_steps_run(first,count,&path);
 ck(!status,"ordinary body operand enters common run adapter");if(status)abort();
 ck(path.run_count==count&&path.indexed==rank&&path.source_first==first,"exact complete span and rank belong to the adapter record");
 for(int k=0;k<path.n;k++)if(path.steps[k].locus==7)ck(path.steps[k].index.first&&path.steps[k].index.count>0,"every index retains a real original P0 span");
 L2ValueSpan *spans=l2_value_spans(first,count,&length);ck(spans&&length==1&&spans[0].first==first&&spans[0].count==count,"ordinary expression span consumes this whole operand");if(spans)l2_xfree(spans);
 l2_path_release(&path);lm_p0_document_destroy(doc);doc=NULL;
 snprintf(source,sizeof source,"%s: 0\n",expression);parsed=lm_p0_parse_bytes(source,strlen(source),&doc);
 ck(!parsed&&doc,"actual receiving head parses");if(parsed||!doc)abort();
 root=lm_p0_document_mutable_root(doc);stmt=l2_next_active(root->as->structure->first_field)->value;
 L2HeadExpression *head=l2_head_expression(stmt,&status);ck(head&&!status&&!head->path_status&&head->prepared.indexed==rank,"compact head uses retained complete P0 grammar");if(!head||status)abort();
 ck(l2_head_expression(stmt,&status)==head&&!status,"same head never reparses after its cached grammar verdict");
 L2Path view={0};status=l2_path_prepared_view(&head->prepared,&view);
 ck(!status&&view.n==head->prepared.n&&view.indexed==head->prepared.indexed&&view.names==head->prepared.names&&view.names_run==head->prepared.names_run&&view.run_count==head->prepared.run_count&&view.source_first==head->prepared.source_first,"every prepared-view counter and source anchor travels together");
 l2_path_release(&view);l2_application_free();lm_p0_document_destroy(doc);
}
int main(void){
 const char *expressions[]={"p[0]","p[-1]","p[c.pick(1)]","p[choose(1)][other(2)]","p\\items[choose()]\\value","p[i]\\[j]\\tail","p[(i + 2)]","p[c.choose(\"x]y\")]"};
 int ranks[]={1,1,1,2,1,2,1,1};for(size_t k=0;k<sizeof ranks/sizeof *ranks;k++)check(expressions[k],ranks[k]);
 int deep[]={1,2,6,65,129};for(size_t k=0;k<sizeof deep/sizeof *deep;k++){char expr[4096]="p";for(int n=0;n<deep[k];n++)strcat(expr,"[0]");check(expr,deep[k]);}
 printf("canonical P0 indexed records: %d checks, %d failures\n",checks,failures);return failures!=0;
}
