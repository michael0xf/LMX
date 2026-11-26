/* 0BSD integration test: works with one or multiple MPI ranks.
 * Optional: roundtrip <output-directory> --keep, for serial netCDF cross-read.
 */
#include <pnetcdf.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
static int rank;
#define CHECK(call) do { int status=(call); if(status!=NC_NOERR) { fprintf(stderr,"rank %d line %d: %s: %s\n",rank,__LINE__,#call,ncmpi_strerror(status)); MPI_Abort(MPI_COMM_WORLD,2); } } while(0)
#define REQUIRE(condition) do { if(!(condition)) { fprintf(stderr,"rank %d line %d: %s\n",rank,__LINE__,#condition); MPI_Abort(MPI_COMM_WORLD,3); } } while(0)
int main(int argc,char **argv) {
    const int modes[3]={0,NC_64BIT_OFFSET,NC_64BIT_DATA};
    const int formats[3]={NC_FORMAT_CLASSIC,NC_FORMAT_64BIT_OFFSET,NC_FORMAT_64BIT_DATA};
    const int magic[3]={1,2,5};
    const char *directory=argc>1?argv[1]:".";int keep=argc>2 && !strcmp(argv[2],"--keep");
    int nprocs,k,i,ncid,dim,var,wide=-1,request,status,format;char path[1024],attr[32];
    int expected[4],actual[4];MPI_Offset start[1],count[1]={4},length;
    unsigned long long large[4],readlarge[4];
    const unsigned char bytes[3]={0,127,255};unsigned char readbytes[3];
    MPI_Init(&argc,&argv);MPI_Comm_rank(MPI_COMM_WORLD,&rank);MPI_Comm_size(MPI_COMM_WORLD,&nprocs);
    start[0]=(MPI_Offset)rank*4;
    for(i=0;i<4;i++){expected[i]=rank*100+i;large[i]=9007199254740993ULL+(unsigned long long)(rank*4+i);}
    for(k=0;k<3;k++) {
        REQUIRE(snprintf(path,sizeof(path),"%s/pnetcdf-cdf%d.nc",directory,magic[k])>0);
        CHECK(ncmpi_create(MPI_COMM_WORLD,path,NC_CLOBBER|modes[k],MPI_INFO_NULL,&ncid));
        CHECK(ncmpi_def_dim(ncid,"samples",(MPI_Offset)nprocs*4,&dim));
        CHECK(ncmpi_def_var(ncid,"values",NC_INT,1,&dim,&var));
        if(k==2) {
            CHECK(ncmpi_def_var(ncid,"wide_values",NC_UINT64,1,&dim,&wide));
            CHECK(ncmpi_put_att_ubyte(ncid,NC_GLOBAL,"bytes",NC_UBYTE,3,bytes));
        }
        CHECK(ncmpi_put_att_text(ncid,NC_GLOBAL,"purpose",17,"LMX CDF roundtrip"));
        CHECK(ncmpi_enddef(ncid));
        CHECK(ncmpi_iput_vara_int(ncid,var,start,count,expected,&request));
        CHECK(ncmpi_wait_all(ncid,1,&request,&status));CHECK(status);
        if(k==2)CHECK(ncmpi_put_vara_ulonglong_all(ncid,wide,start,count,large));
        CHECK(ncmpi_close(ncid));
        MPI_Barrier(MPI_COMM_WORLD);
        if(rank==0) {
            unsigned char signature[4];FILE *f=fopen(path,"rb");REQUIRE(f);
            REQUIRE(fread(signature,1,4,f)==4);fclose(f);
            REQUIRE(!memcmp(signature,"CDF",3) && signature[3]==magic[k]);
        }
        CHECK(ncmpi_open(MPI_COMM_WORLD,path,NC_NOWRITE,MPI_INFO_NULL,&ncid));
        CHECK(ncmpi_inq_format(ncid,&format));REQUIRE(format==formats[k]);
        CHECK(ncmpi_inq_dimid(ncid,"samples",&dim));CHECK(ncmpi_inq_dimlen(ncid,dim,&length));REQUIRE(length==(MPI_Offset)nprocs*4);
        CHECK(ncmpi_inq_varid(ncid,"values",&var));memset(actual,0,sizeof(actual));
        CHECK(ncmpi_get_vara_int_all(ncid,var,start,count,actual));REQUIRE(!memcmp(expected,actual,sizeof(actual)));
        CHECK(ncmpi_begin_indep_data(ncid));memset(actual,0,sizeof(actual));
        CHECK(ncmpi_get_vara_int(ncid,var,start,count,actual));REQUIRE(!memcmp(expected,actual,sizeof(actual)));
        CHECK(ncmpi_end_indep_data(ncid));
        memset(attr,0,sizeof(attr));CHECK(ncmpi_get_att_text(ncid,NC_GLOBAL,"purpose",attr));REQUIRE(!strcmp(attr,"LMX CDF roundtrip"));
        if(k==2) {
            CHECK(ncmpi_get_att_ubyte(ncid,NC_GLOBAL,"bytes",readbytes));REQUIRE(!memcmp(bytes,readbytes,sizeof(bytes)));
            CHECK(ncmpi_inq_varid(ncid,"wide_values",&wide));
            CHECK(ncmpi_get_vara_ulonglong_all(ncid,wide,start,count,readlarge));REQUIRE(!memcmp(large,readlarge,sizeof(large)));
        }
        CHECK(ncmpi_close(ncid));MPI_Barrier(MPI_COMM_WORLD);
        if(rank==0 && !keep)REQUIRE(remove(path)==0);
    }
    if(rank==0)printf("PnetCDF %s: CDF-1/2/5, collective + independent + nonblocking I/O, uint64 exactness; ranks=%d PASS\n",ncmpi_inq_libvers(),nprocs);
    MPI_Finalize();return 0;
}
