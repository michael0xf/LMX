#ifndef L2_FRONTEND_SOURCE
#error Define L2_FRONTEND_SOURCE to the actual source-linked frontend C
#endif
#define main index135_frontend_main
#include L2_FRONTEND_SOURCE
#undef main
static int checks,failures;
static void ck135(int yes,const char *why){++checks;if(!yes){++failures;fprintf(stderr,"FAIL common index record: %s\n",why);}}
int main(void){
 int ranks[]={1,2,6,65,129},live=l2_alloc_live;
 for(size_t n=0;n<sizeof ranks/sizeof ranks[0];++n)for(int prefix=0;prefix<2;++prefix){
  int rank=ranks[n];size_t room=(size_t)rank*10+64;char *source=malloc(room);
  strcpy(source,prefix?"p\\field":"p");for(int i=0;i<rank;++i)strcat(source,"[0 + 1]");strcat(source,": 5\n");
  LmP0Document *document=NULL;int parse=lm_p0_parse_bytes(source,strlen(source),&document);
  ck135(!parse&&document,"original source parses");
  if(parse||!document)abort();
  LmP0Node *root=lm_p0_document_mutable_root(document);
  LmP0Field *field=l2_next_active(root->as->structure->first_field);int status=-1;
  L2HeadExpression *e=l2_head_expression(field->value,&status);
  ck135(e&&status==0&&e->path_status==0,"one retained head contains the general adapter's grammar verdict");
  if(!e)abort();
  L2Path *p=&e->prepared;
  ck135(p->n==rank+prefix&&p->indexed==rank&&p->names==prefix,"every adjacent index is retained,not truncated at old flat boundary");
  ck135(p->run_count==l2_count_active(e->body)&&p->names_run==1+prefix*2,"complete original field span and name prefix remain coherent");
  ck135(!!p->flat==(rank>1),"Array's flat-shape distinction is retained without discarding later indices");
  int good=1;for(int k=prefix;k<p->n;++k){L2PathStep *step=p->steps+k;good&=step->locus==7&&step->index.first&&step->index.count==3&&step->index.node==step->index.first->value;}
  ck135(good,"all index operands are original bounded P0 spans");
  int allocated=l2_alloc_live;
  ck135(l2_head_expression(field->value,&status)==e&&l2_alloc_live==allocated,"later CHECK/graph/native queries borrow the SAME head,without a parser fallback");
  L2Path view;int copied=l2_path_prepared_view(p,&view);
  ck135(!copied&&view.n==p->n&&view.indexed==p->indexed&&view.run_count==p->run_count&&view.flat==p->flat&&view.steps!=p->steps,"an independently resolved view preserves every grammar coordinate");
  int same=1;for(int k=prefix;k<view.n;++k)same&=view.steps[k].index.first==p->steps[k].index.first&&view.steps[k].index.count==p->steps[k].index.count&&view.steps[k].elem_ty==-1;
  ck135(same,"views borrow original index expressions and cannot inherit an earlier type verdict");
  l2_path_release(&view);
  ck135(e->prepared.n==rank+prefix&&e->prepared.indexed==rank,"releasing a use does not cut the retained source record");
  l2_application_free();lm_p0_document_destroy(document);free(source);
  ck135(l2_alloc_live==live,"all prepared/index view storage returns to the existing owner lifetime");
 }
 printf("common raw index record: %d checks, %d failures\n",checks,failures);return failures!=0;
}
