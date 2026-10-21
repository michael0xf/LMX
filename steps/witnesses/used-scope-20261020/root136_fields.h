#ifndef ROOT136_FIELDS_H
#define ROOT136_FIELDS_H
typedef struct Root136Record {int scalar;int cells[2];} Root136Record;
static Root136Record root136_record={5,{7,9}};
static Root136Record root136_make(void){return root136_record;}
static Root136Record *root136_ptr(void){return &root136_record;}
static int root136_read(Root136Record r){return r.cells[1];}
static int root136_read_ptr(Root136Record *r){return r->cells[1];}
static int root136_original(void){return root136_record.cells[1];}
static int root136_scalar(void){return root136_record.scalar;}
#endif
