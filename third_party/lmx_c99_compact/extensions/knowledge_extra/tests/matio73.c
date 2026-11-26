/* MAT 7.3 object-reference roundtrip using the collection's shared HDF5. */
#include <matio.h>
#include <hdf5.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define CHECK(x) do { if (!(x)) { fprintf(stderr,"MAT73 check failed line %d: %s\n",__LINE__,#x); exit(1); } } while(0)
static void write_variable(mat_t *file,matvar_t *value) {
    CHECK(value!=NULL); CHECK(Mat_VarWrite(file,value,MAT_COMPRESSION_ZLIB)==0); Mat_VarFree(value);
}
int main(void) {
    const char *path="knowledge_extra_mat73_roundtrip.mat";
    size_t dense_dims[2]={2,3},complex_dims[2]={2,2},sparse_dims[2]={3,3},one[2]={1,1};
    double dense[6]={1,-2,3.5,4,0,6},real[4]={1,2,3,4},imaginary[4]={-1,0,2,0.25},nonzero[3]={1,-2,4.5};
    mat_complex_split_t split={real,imaginary};
    mat_uint32_t ir[3]={0,2,1},jc[4]={0,1,2,3};
    mat_sparse_t sparse={3,ir,3,jc,4,3,nonzero};
    const char *fields[]={"samples","phasors",NULL};
    const unsigned char signature[8]={0x89,'H','D','F',0x0d,0x0a,0x1a,0x0a}; unsigned char got[8];
    mat_t *file; matvar_t *record,*v,*r; mat_complex_split_t *read_complex; mat_sparse_t *read_sparse; FILE *physical;
    file=Mat_CreateVer(path,"LMX MAT73 compact format test",MAT_FT_MAT73); CHECK(file!=NULL);
    write_variable(file,Mat_VarCreate("dense",MAT_C_DOUBLE,MAT_T_DOUBLE,2,dense_dims,dense,0));
    write_variable(file,Mat_VarCreate("complex",MAT_C_DOUBLE,MAT_T_DOUBLE,2,complex_dims,&split,MAT_F_COMPLEX));
    write_variable(file,Mat_VarCreate("sparse",MAT_C_SPARSE,MAT_T_DOUBLE,2,sparse_dims,&sparse,0));
    record=Mat_VarCreateStruct2("record",2,one,fields); CHECK(record!=NULL);
    v=Mat_VarCreate(NULL,MAT_C_DOUBLE,MAT_T_DOUBLE,2,dense_dims,dense,0); CHECK(v!=NULL); Mat_VarSetStructFieldByName(record,"samples",0,v);
    v=Mat_VarCreate(NULL,MAT_C_DOUBLE,MAT_T_DOUBLE,2,complex_dims,&split,MAT_F_COMPLEX); CHECK(v!=NULL); Mat_VarSetStructFieldByName(record,"phasors",0,v);
    write_variable(file,record); CHECK(Mat_Close(file)==0);
    /* Matio's MAT73 writer reserves a 512-byte MATLAB user block. */
    physical=fopen(path,"rb"); CHECK(physical!=NULL); CHECK(fseek(physical,512,SEEK_SET)==0); CHECK(fread(got,1,8,physical)==8); CHECK(fclose(physical)==0); CHECK(memcmp(got,signature,8)==0); CHECK(H5Fis_hdf5(path)>0);
    file=Mat_Open(path,MAT_ACC_RDONLY); CHECK(file!=NULL && Mat_GetVersion(file)==MAT_FT_MAT73);
    r=Mat_VarRead(file,"dense"); CHECK(r!=NULL && r->rank==2 && r->dims[0]==2 && r->dims[1]==3 && r->class_type==MAT_C_DOUBLE && r->data_type==MAT_T_DOUBLE); CHECK(memcmp(r->data,dense,sizeof dense)==0); Mat_VarFree(r);
    r=Mat_VarRead(file,"complex"); CHECK(r!=NULL && r->isComplex && r->dims[0]==2 && r->dims[1]==2); read_complex=r->data; CHECK(read_complex!=NULL); CHECK(memcmp(read_complex->Re,real,sizeof real)==0 && memcmp(read_complex->Im,imaginary,sizeof imaginary)==0); Mat_VarFree(r);
    r=Mat_VarRead(file,"sparse"); CHECK(r!=NULL && r->class_type==MAT_C_SPARSE && r->dims[0]==3 && r->dims[1]==3); read_sparse=r->data; CHECK(read_sparse!=NULL && read_sparse->nir==3 && read_sparse->njc==4 && read_sparse->ndata==3); CHECK(memcmp(read_sparse->ir,ir,sizeof ir)==0 && memcmp(read_sparse->jc,jc,sizeof jc)==0 && memcmp(read_sparse->data,nonzero,sizeof nonzero)==0); Mat_VarFree(r);
    r=Mat_VarRead(file,"record"); CHECK(r!=NULL && r->class_type==MAT_C_STRUCT);
    v=Mat_VarGetStructFieldByName(r,"samples",0); CHECK(v!=NULL && v->data!=NULL && memcmp(v->data,dense,sizeof dense)==0);
    v=Mat_VarGetStructFieldByName(r,"phasors",0); CHECK(v!=NULL && v->isComplex); read_complex=v->data; CHECK(read_complex!=NULL && memcmp(read_complex->Re,real,sizeof real)==0 && memcmp(read_complex->Im,imaginary,sizeof imaginary)==0); Mat_VarFree(r);
    CHECK(Mat_Close(file)==0); CHECK(remove(path)==0); puts("MAT73 dense/sparse/complex/struct and physical HDF5 signature OK"); return 0;
}
