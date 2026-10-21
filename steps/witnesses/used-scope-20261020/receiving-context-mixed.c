#include "l2src/lmx_implements.lm1.h"
static int through_current_frame(LmxArena *,Lmx *,Lmx *,const LmxImplTemplate *,size_t,LmxImplUses *,int,Lmx *,Lmx *,Lmx *);
#define lmx_implements_admit_templates_typed through_current_frame
#include "C:/Nyasha_Planet/LMX/build/codex_declared93_mixed_test_01.c"
#undef lmx_implements_admit_templates_typed

/* Representation adapter in the TEST ONLY. No path/name is resolved here:
   copy the already prepared vector cells into ordinary current graph data.
   Every original mixed value/address/refusal predicate above stays intact. */
static int through_current_frame(LmxArena *a,Lmx *value,Lmx *req,const LmxImplTemplate *rows,size_t count,LmxImplUses *uses,int full,Lmx *references,Lmx *source,Lmx *source_references){
 size_t extent=1;for(size_t i=0;i<count;++i)extent+=3+2*rows[i].correspondence.n;
 Lmx *record=node(a,5),*catalog=node(a,extent);sizecell(a,catalog,0,count);
 size_t at=1;
 for(size_t i=0;i<count;++i){
  const LmxImplEntry *p=&rows[i].correspondence;
  token(a,catalog,at,rows[i].source_layout);token(a,catalog,at+1,rows[i].required_layout);sizecell(a,catalog,at+2,p->n);
  if(!p->map||p->frame)abort();
  for(size_t j=0;j<2*p->n;++j)sizecell(a,catalog,at+3+j,p->map[j]);at+=3+2*p->n;
 }
 put(record,0,catalog);sizecell(a,record,2,uses?2:(full?1:0));
 if(uses){if(!uses->map||uses->frame)abort();Lmx *coverage=node(a,uses->map[0]);for(size_t i=0;i<uses->map[0];++i)sizecell(a,coverage,i,uses->map[i]);put(record,1,coverage);}
 if(!references){references=node(a,1);sizecell(a,references,0,0);}put(record,3,references);
 if(source){
  Lmx *context=node(a,2);put(context,0,source);
  if(!source_references){source_references=node(a,1);sizecell(a,source_references,0,0);}put(context,1,source_references);put(record,4,context);
 }
 return lmx_implements_admit_receiving_frame(a,value,req,record);
}
