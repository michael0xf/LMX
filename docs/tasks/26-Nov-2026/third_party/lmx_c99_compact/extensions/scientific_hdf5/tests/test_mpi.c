/* Real MPI-IO collective hyperslab roundtrip; works with one or more ranks. */
#include <mpi.h>
#include <hdf5.h>
#include <stdio.h>
#define CHECK(x) do { if (!(x)) { fprintf(stderr,"HDF5 MPI check failed rank %d line %d: %s\n",rank,__LINE__,#x); MPI_Abort(MPI_COMM_WORLD,1); return 1; } } while(0)
int main(int argc,char **argv) {
    int rank=0,ranks=0,i,values[4],readback[4]; hid_t fapl,file,space,memory,dataset,xfer;
    hsize_t total[1],local[1]={4},offset[1]; const char *path="lmx-hdf5-mpi.h5";
    if (MPI_Init(&argc,&argv)!=MPI_SUCCESS) { fputs("MPI initialization failed\n",stderr); return 1; } CHECK(MPI_Comm_rank(MPI_COMM_WORLD,&rank)==MPI_SUCCESS); CHECK(MPI_Comm_size(MPI_COMM_WORLD,&ranks)==MPI_SUCCESS);
    total[0]=(hsize_t)ranks*4; offset[0]=(hsize_t)rank*4;
    for(i=0;i<4;++i) values[i]=rank*100+i;
    fapl=H5Pcreate(H5P_FILE_ACCESS); CHECK(fapl>=0); CHECK(H5Pset_fapl_mpio(fapl,MPI_COMM_WORLD,MPI_INFO_NULL)>=0);
    file=H5Fcreate(path,H5F_ACC_TRUNC,H5P_DEFAULT,fapl); CHECK(file>=0);
    space=H5Screate_simple(1,total,NULL); memory=H5Screate_simple(1,local,NULL); CHECK(space>=0 && memory>=0);
    dataset=H5Dcreate2(file,"values",H5T_STD_I32LE,space,H5P_DEFAULT,H5P_DEFAULT,H5P_DEFAULT); CHECK(dataset>=0);
    CHECK(H5Sselect_hyperslab(space,H5S_SELECT_SET,offset,NULL,local,NULL)>=0);
    xfer=H5Pcreate(H5P_DATASET_XFER); CHECK(xfer>=0); CHECK(H5Pset_dxpl_mpio(xfer,H5FD_MPIO_COLLECTIVE)>=0);
    CHECK(H5Dwrite(dataset,H5T_NATIVE_INT,memory,space,xfer,values)>=0); CHECK(H5Dclose(dataset)>=0); CHECK(H5Fclose(file)>=0);
    file=H5Fopen(path,H5F_ACC_RDONLY,fapl); CHECK(file>=0); dataset=H5Dopen2(file,"values",H5P_DEFAULT); CHECK(dataset>=0);
    CHECK(H5Dread(dataset,H5T_NATIVE_INT,memory,space,xfer,readback)>=0);
    for(i=0;i<4;++i) CHECK(values[i]==readback[i]);
    CHECK(H5Dclose(dataset)>=0); CHECK(H5Fclose(file)>=0); CHECK(H5Sclose(space)>=0); CHECK(H5Sclose(memory)>=0); CHECK(H5Pclose(xfer)>=0); CHECK(H5Pclose(fapl)>=0); CHECK(H5close()>=0);
    CHECK(MPI_Barrier(MPI_COMM_WORLD)==MPI_SUCCESS); if(rank==0) { CHECK(remove(path)==0); printf("HDF5 MPI collective roundtrip OK, ranks=%d\n",ranks); }
    CHECK(MPI_Finalize()==MPI_SUCCESS); return 0;
}
