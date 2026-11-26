/* Bidirectional, independently implemented CDF-5 interoperability.
 * netcdf.h comes first: PnetCDF then reuses its common nc_type/constants.
 * No external fixtures. The serial nc_* API is used for the netCDF side.
 */
#include <mpi.h>
#include <netcdf.h>
#include <pnetcdf.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static int rank;
#define REQUIRE(x) do { if (!(x)) { fprintf(stderr,"CDF5 interop rank %d line %d: %s\n",rank,__LINE__,#x); MPI_Abort(MPI_COMM_WORLD,1); exit(1); } } while(0)
#define NC(x) do { int status=(x); if(status!=NC_NOERR) { fprintf(stderr,"netCDF-C rank %d line %d: %s\n",rank,__LINE__,nc_strerror(status)); MPI_Abort(MPI_COMM_WORLD,1); exit(1); } } while(0)
#define PNC(x) do { int status=(x); if(status!=NC_NOERR) { fprintf(stderr,"PnetCDF rank %d line %d: %s\n",rank,__LINE__,ncmpi_strerror(status)); MPI_Abort(MPI_COMM_WORLD,1); exit(1); } } while(0)
static unsigned long long expected(size_t index) {
    switch(index%3) {
    case 0:return 9007199254740993ULL+(unsigned long long)index;
    case 1:return 18446744073709551614ULL-(unsigned long long)index;
    default:return 12345678901234567890ULL+(unsigned long long)index;
    }
}
int main(int argc,char **argv) {
    const char *from_nc="lmx-cross-netcdf-cdf5.nc",*from_pnc="lmx-cross-pnetcdf-cdf5.nc";
    const unsigned char bytes[3]={0,127,255}; unsigned char got_bytes[3];
    int ranks,ncid,dim,var,format,i; size_t total,start[1],count[1]={4},length;
    MPI_Offset mpi_start[1],mpi_count[1]={4},mpi_length;
    unsigned long long local[4],got[4];
    if(MPI_Init(&argc,&argv)!=MPI_SUCCESS) { fputs("MPI initialization failed\n",stderr);return 1; }
    REQUIRE(MPI_Comm_rank(MPI_COMM_WORLD,&rank)==MPI_SUCCESS);
    REQUIRE(MPI_Comm_size(MPI_COMM_WORLD,&ranks)==MPI_SUCCESS);
    total=(size_t)ranks*4;start[0]=(size_t)rank*4;mpi_start[0]=(MPI_Offset)rank*4;
    for(i=0;i<4;++i) local[i]=expected(start[0]+(size_t)i);
    /* netCDF-C's serial classic backend writes; every MPI rank reads with PnetCDF. */
    if(rank==0) {
        unsigned long long *all=malloc(total*sizeof(*all));size_t j;REQUIRE(all!=NULL);
        for(j=0;j<total;++j) all[j]=expected(j);
        NC(nc_create(from_nc,NC_CLOBBER|NC_64BIT_DATA,&ncid));
        NC(nc_def_dim(ncid,"n",total,&dim));NC(nc_def_var(ncid,"exact",NC_UINT64,1,&dim,&var));
        NC(nc_put_att_uchar(ncid,NC_GLOBAL,"bytes",NC_UBYTE,3,bytes));
        NC(nc_enddef(ncid));NC(nc_put_var_ulonglong(ncid,var,all));NC(nc_close(ncid));free(all);
    }
    REQUIRE(MPI_Barrier(MPI_COMM_WORLD)==MPI_SUCCESS);
    PNC(ncmpi_open(MPI_COMM_WORLD,from_nc,NC_NOWRITE,MPI_INFO_NULL,&ncid));
    PNC(ncmpi_inq_format(ncid,&format));REQUIRE(format==NC_FORMAT_CDF5);
    PNC(ncmpi_inq_dimid(ncid,"n",&dim));PNC(ncmpi_inq_dimlen(ncid,dim,&mpi_length));REQUIRE(mpi_length==(MPI_Offset)total);
    PNC(ncmpi_get_att_ubyte(ncid,NC_GLOBAL,"bytes",got_bytes));REQUIRE(memcmp(bytes,got_bytes,sizeof bytes)==0);
    PNC(ncmpi_inq_varid(ncid,"exact",&var));PNC(ncmpi_get_vara_ulonglong_all(ncid,var,mpi_start,mpi_count,got));
    for(i=0;i<4;++i) REQUIRE(got[i]==local[i]);PNC(ncmpi_close(ncid));
    /* PnetCDF writes collectively; serial nc_open/read uses the other implementation. */
    PNC(ncmpi_create(MPI_COMM_WORLD,from_pnc,NC_CLOBBER|NC_64BIT_DATA,MPI_INFO_NULL,&ncid));
    PNC(ncmpi_def_dim(ncid,"n",(MPI_Offset)total,&dim));PNC(ncmpi_def_var(ncid,"exact",NC_UINT64,1,&dim,&var));
    PNC(ncmpi_put_att_ubyte(ncid,NC_GLOBAL,"bytes",NC_UBYTE,3,bytes));PNC(ncmpi_enddef(ncid));
    PNC(ncmpi_put_vara_ulonglong_all(ncid,var,mpi_start,mpi_count,local));PNC(ncmpi_close(ncid));
    REQUIRE(MPI_Barrier(MPI_COMM_WORLD)==MPI_SUCCESS);
    NC(nc_open(from_pnc,NC_NOWRITE,&ncid));NC(nc_inq_format(ncid,&format));REQUIRE(format==NC_FORMAT_CDF5);
    NC(nc_inq_dimid(ncid,"n",&dim));NC(nc_inq_dimlen(ncid,dim,&length));REQUIRE(length==total);
    NC(nc_get_att_uchar(ncid,NC_GLOBAL,"bytes",got_bytes));REQUIRE(memcmp(bytes,got_bytes,sizeof bytes)==0);
    NC(nc_inq_varid(ncid,"exact",&var));NC(nc_get_vara_ulonglong(ncid,var,start,count,got));
    for(i=0;i<4;++i) REQUIRE(got[i]==local[i]);NC(nc_close(ncid));
    REQUIRE(MPI_Barrier(MPI_COMM_WORLD)==MPI_SUCCESS);
    if(rank==0) {
        REQUIRE(remove(from_nc)==0);REQUIRE(remove(from_pnc)==0);
        printf("CDF5 netCDF-C->PnetCDF and PnetCDF->netCDF-C exact uint64+metadata PASS, ranks=%d\n",ranks);
    }
    REQUIRE(MPI_Finalize()==MPI_SUCCESS);return 0;
}
