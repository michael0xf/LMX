/* An offline directory store. Small output remains in the build dir for inspection. */
#include <netcdf.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define CHECK(x) do { if (!(x)) { fprintf(stderr,"NCZarr check failed line %d: %s\n",__LINE__,#x); exit(1); } } while(0)
#define NC(x) do { int status=(x); if(status!=NC_NOERR) { fprintf(stderr,"NCZarr error line %d: %s: %s\n",__LINE__,#x,nc_strerror(status)); exit(1); } } while(0)
int main(void) {
    const char *url="file://lmx-netcdf-directory.zarr#mode=nczarr,file";
    int file,rows,cols,dims[2],var,values[12],expected[12],readback[12],patch[4]={90,91,92,93},slice[4];
    size_t chunks[2]={2,2},start[2]={1,1},count[2]={2,2}; char title[32]={0}; FILE *metadata; int i;
    for(i=0;i<12;++i) values[i]=expected[i]=i*7-30;
    expected[5]=90;expected[6]=91;expected[9]=92;expected[10]=93;
    NC(nc_create(url,NC_NETCDF4|NC_CLOBBER,&file)); NC(nc_def_dim(file,"rows",3,&rows)); NC(nc_def_dim(file,"cols",4,&cols)); dims[0]=rows;dims[1]=cols;
    NC(nc_def_var(file,"values",NC_INT,2,dims,&var)); NC(nc_def_var_chunking(file,var,NC_CHUNKED,chunks)); NC(nc_put_att_text(file,NC_GLOBAL,"title",13,"offline store")); NC(nc_enddef(file));
    NC(nc_put_var_int(file,var,values)); NC(nc_put_vara_int(file,var,start,count,patch)); NC(nc_close(file));
    metadata=fopen("lmx-netcdf-directory.zarr/.zgroup","rb"); CHECK(metadata!=NULL); CHECK(fgetc(metadata)=='{'); CHECK(fclose(metadata)==0);
    metadata=fopen("lmx-netcdf-directory.zarr/values/.zarray","rb"); CHECK(metadata!=NULL); CHECK(fclose(metadata)==0);
    NC(nc_open(url,NC_NOWRITE,&file)); NC(nc_inq_varid(file,"values",&var)); NC(nc_get_var_int(file,var,readback)); CHECK(memcmp(expected,readback,sizeof expected)==0);
    NC(nc_get_vara_int(file,var,start,count,slice)); CHECK(memcmp(slice,patch,sizeof patch)==0); NC(nc_get_att_text(file,NC_GLOBAL,"title",title)); CHECK(strcmp(title,"offline store")==0);
    NC(nc_close(file)); puts("NCZarr directory metadata/chunks/attribute/hyperslab roundtrip OK (no network)"); return 0;
}
