/* Small, generated fixtures: classic CDF variants and enhanced netCDF-4. */
#include <netcdf.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define CHECK(x) do { if (!(x)) { fprintf(stderr,"netCDF check failed at %d: %s\n",__LINE__,#x); exit(1); } } while(0)
#define NC(x) do { int status=(x); if(status!=NC_NOERR) { fprintf(stderr,"netCDF error line %d: %s: %s\n",__LINE__,#x,nc_strerror(status)); exit(1); } } while(0)
static void classic(const char *path,int flags,int expected,int signature_version,int keep) {
    int file,time_dim,x_dim,dims[2],var,u64=-1,format; size_t start[2]={0,0},count[2]={2,3},length;
    int values[6]={-7,0,42,300,-900,12345},got[6]; char unit[8]={0};
    unsigned long long exact[3]={9007199254740993ULL,18446744073709551614ULL,12345678901234567890ULL},read_exact[3];
    unsigned char signature[4]; FILE *physical;
    NC(nc_create(path,NC_CLOBBER|flags,&file));
    NC(nc_def_dim(file,"time",NC_UNLIMITED,&time_dim)); NC(nc_def_dim(file,"x",3,&x_dim)); dims[0]=time_dim; dims[1]=x_dim;
    NC(nc_def_var(file,"values",NC_INT,2,dims,&var)); NC(nc_put_att_text(file,var,"unit",6,"Kelvin"));
    if(flags&NC_64BIT_DATA) NC(nc_def_var(file,"exact_u64",NC_UINT64,1,&x_dim,&u64));
    NC(nc_enddef(file)); NC(nc_put_vara_int(file,var,start,count,values));
    if(u64>=0) NC(nc_put_var_ulonglong(file,u64,exact));
    NC(nc_close(file));
    physical=fopen(path,"rb"); CHECK(physical!=NULL); CHECK(fread(signature,1,4,physical)==4); CHECK(fclose(physical)==0);
    CHECK(signature[0]=='C' && signature[1]=='D' && signature[2]=='F' && signature[3]==signature_version);
    NC(nc_open(path,NC_NOWRITE,&file)); NC(nc_inq_format(file,&format)); CHECK(format==expected);
    NC(nc_inq_dimid(file,"time",&time_dim)); NC(nc_inq_dimlen(file,time_dim,&length)); CHECK(length==2);
    NC(nc_inq_varid(file,"values",&var)); NC(nc_get_var_int(file,var,got)); CHECK(memcmp(got,values,sizeof values)==0);
    NC(nc_get_att_text(file,var,"unit",unit)); CHECK(strcmp(unit,"Kelvin")==0);
    if(flags&NC_64BIT_DATA) { NC(nc_inq_varid(file,"exact_u64",&u64)); NC(nc_get_var_ulonglong(file,u64,read_exact)); CHECK(memcmp(exact,read_exact,sizeof exact)==0); }
    NC(nc_close(file)); if(!keep) CHECK(remove(path)==0);
}
static void enhanced(void) {
    const char *path="lmx-netcdf-enhanced.nc"; int file,group,row,col,dims[2],matrix,status_var,labels_var,format,shuffle,deflate,level,storage;
    nc_type weather; unsigned char calm=0,storm=2,states[4]={0,2,0,2},read_states[4];
    size_t chunks[2]={2,3},read_chunks[2],start[2]={1,1},count[2]={2,2};
    double values[12],expected[12],readback[12],patch[4]={-1.5,-2.5,-3.5,-4.5},slice[4];
    const char *labels[4]={"north","south","station-A","station-B"}; char *read_labels[4]={NULL,NULL,NULL,NULL}; char name[NC_MAX_NAME+1]; int i;
    for(i=0;i<12;++i) values[i]=expected[i]=100.5+i*0.125;
    expected[4]=patch[0];expected[5]=patch[1];expected[7]=patch[2];expected[8]=patch[3];
    NC(nc_create(path,NC_CLOBBER|NC_NETCDF4,&file)); NC(nc_def_grp(file,"science",&group));
    NC(nc_def_dim(group,"row",4,&row)); NC(nc_def_dim(group,"col",3,&col)); dims[0]=row;dims[1]=col;
    NC(nc_def_var(group,"temperature",NC_DOUBLE,2,dims,&matrix)); NC(nc_def_var_chunking(group,matrix,NC_CHUNKED,chunks)); NC(nc_def_var_deflate(group,matrix,1,1,4));
    NC(nc_def_enum(group,NC_UBYTE,"weather_t",&weather)); NC(nc_insert_enum(group,weather,"calm",&calm)); NC(nc_insert_enum(group,weather,"storm",&storm));
    NC(nc_def_var(group,"weather",weather,1,&row,&status_var)); NC(nc_def_var(group,"labels",NC_STRING,1,&row,&labels_var));
    NC(nc_enddef(file)); NC(nc_put_var_double(group,matrix,values)); NC(nc_put_vara_double(group,matrix,start,count,patch));
    NC(nc_put_var(group,status_var,states)); NC(nc_put_var_string(group,labels_var,labels)); NC(nc_close(file));
    NC(nc_open(path,NC_NOWRITE,&file)); NC(nc_inq_format(file,&format)); CHECK(format==NC_FORMAT_NETCDF4);
    NC(nc_inq_ncid(file,"science",&group)); NC(nc_inq_varid(group,"temperature",&matrix));
    NC(nc_get_var_double(group,matrix,readback)); CHECK(memcmp(readback,expected,sizeof expected)==0);
    NC(nc_get_vara_double(group,matrix,start,count,slice)); CHECK(memcmp(slice,patch,sizeof patch)==0);
    NC(nc_inq_var_deflate(group,matrix,&shuffle,&deflate,&level)); CHECK(shuffle==1 && deflate==1 && level==4);
    NC(nc_inq_var_chunking(group,matrix,&storage,read_chunks)); CHECK(storage==NC_CHUNKED && read_chunks[0]==2 && read_chunks[1]==3);
    NC(nc_inq_varid(group,"weather",&status_var)); NC(nc_get_var(group,status_var,read_states)); CHECK(memcmp(states,read_states,sizeof states)==0);
    NC(nc_inq_typeid(group,"weather_t",&weather)); NC(nc_inq_enum_ident(group,weather,2,name)); CHECK(strcmp(name,"storm")==0);
    NC(nc_inq_varid(group,"labels",&labels_var)); NC(nc_get_var_string(group,labels_var,read_labels));
    for(i=0;i<4;++i) CHECK(strcmp(labels[i],read_labels[i])==0); NC(nc_free_string(4,read_labels));
    NC(nc_close(file)); CHECK(remove(path)==0);
}
int main(int argc,char **argv) {
    int keep=argc>1 && strcmp(argv[1],"--keep")==0;
    classic("lmx-netcdf-cdf1.nc",0,NC_FORMAT_CLASSIC,1,keep);
    classic("lmx-netcdf-cdf2.nc",NC_64BIT_OFFSET,NC_FORMAT_64BIT_OFFSET,2,keep);
    classic("lmx-netcdf-cdf5.nc",NC_64BIT_DATA,NC_FORMAT_CDF5,5,keep);
    enhanced(); puts("netCDF CDF1/2/5 exact uint64 + netCDF4 groups/enum/strings/hyperslabs/deflate OK"); return 0;
}
