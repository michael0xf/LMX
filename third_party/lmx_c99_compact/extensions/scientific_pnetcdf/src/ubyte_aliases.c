/* SPDX-License-Identifier: 0BSD
 * PnetCDF 1.15.1 declares these two byte spelling aliases, but its C dispatcher
 * exports only the identical unsigned-char implementations. Preserve the
 * declared signatures and delegate all validation/conversion to that API.
 */
#include <pnetcdf.h>
int ncmpi_put_att_ubyte(int ncid,int varid,const char *name,nc_type xtype,
                      MPI_Offset length,const unsigned char *values) {
    return ncmpi_put_att_uchar(ncid,varid,name,xtype,length,values);
}
int ncmpi_get_att_ubyte(int ncid,int varid,const char *name,unsigned char *values) {
    return ncmpi_get_att_uchar(ncid,varid,name,values);
}
