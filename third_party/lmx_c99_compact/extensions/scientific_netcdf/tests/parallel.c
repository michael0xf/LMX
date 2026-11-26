/* Actual collective nc_* MPI I/O through both HDF5 and PnetCDF dispatch. */
#include <mpi.h>
#include <netcdf.h>
#include <netcdf_par.h>
#include <netcdf_meta.h>
#include <stdio.h>
#include <stdlib.h>
#define CHECK(x) do { if (!(x)) { fprintf(stderr,"netCDF parallel failure rank %d line %d: %s\n",rank,__LINE__,#x); MPI_Abort(MPI_COMM_WORLD,1); exit(1); } } while(0)
#define NC(x) do { int status=(x); if(status!=NC_NOERR) { fprintf(stderr,"netCDF parallel error rank %d line %d: %s: %s\n",rank,__LINE__,#x,nc_strerror(status)); MPI_Abort(MPI_COMM_WORLD,1); exit(1); } } while(0)
static void roundtrip(const char *path,int mode,int expected_format,int rank,int ranks) {
    int file,dim,var,format,i; size_t start[1]={(size_t)rank*4},count[1]={4};
    unsigned long long values[4],got[4];
    for(i=0;i<4;++i) values[i]=9007199254740993ULL+(unsigned long long)rank*100+(unsigned)i;
    NC(nc_create_par(path,NC_CLOBBER|mode,MPI_COMM_WORLD,MPI_INFO_NULL,&file));
    NC(nc_def_dim(file,"entry",(size_t)ranks*4,&dim)); NC(nc_def_var(file,"exact",NC_UINT64,1,&dim,&var)); NC(nc_enddef(file)); NC(nc_var_par_access(file,var,NC_COLLECTIVE));
    NC(nc_put_vara_ulonglong(file,var,start,count,values)); NC(nc_close(file));
    NC(nc_open_par(path,NC_NOWRITE,MPI_COMM_WORLD,MPI_INFO_NULL,&file)); NC(nc_inq_format(file,&format)); CHECK(format==expected_format);
    NC(nc_inq_varid(file,"exact",&var)); NC(nc_var_par_access(file,var,NC_COLLECTIVE)); NC(nc_get_vara_ulonglong(file,var,start,count,got));
    for(i=0;i<4;++i) CHECK(got[i]==values[i]); NC(nc_close(file)); CHECK(MPI_Barrier(MPI_COMM_WORLD)==MPI_SUCCESS);
    if(rank==0) CHECK(remove(path)==0);
}
int main(int argc,char **argv) {
    int rank=0,ranks=0;
    if(!NC_HAS_PARALLEL4 || !NC_HAS_PNETCDF) { fputs("This test requires both HDF5 parallel and PnetCDF dispatch enabled.\n",stderr); return 1; }
    if(MPI_Init(&argc,&argv)!=MPI_SUCCESS) { fputs("MPI initialization failed\n",stderr); return 1; }
    CHECK(MPI_Comm_rank(MPI_COMM_WORLD,&rank)==MPI_SUCCESS); CHECK(MPI_Comm_size(MPI_COMM_WORLD,&ranks)==MPI_SUCCESS);
    roundtrip("lmx-netcdf-parallel4.nc",NC_NETCDF4,NC_FORMAT_NETCDF4,rank,ranks);
    roundtrip("lmx-netcdf-parallel5.nc",NC_64BIT_DATA,NC_FORMAT_CDF5,rank,ranks);
    if(rank==0) printf("netCDF HDF5 and PnetCDF collective uint64 roundtrips OK, ranks=%d\n",ranks);
    CHECK(MPI_Finalize()==MPI_SUCCESS); return 0;
}
