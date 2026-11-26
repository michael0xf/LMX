/* SPDX-License-Identifier: 0BSD
 * Independent consumer: compile with a netCDF-C library, not PnetCDF or MPI.
 * Read a one-rank CDF-5 file produced by roundtrip . --keep.
 */
#include <netcdf.h>
#include <stdio.h>
#include <string.h>
#define CHECK(call) do {int status=(call);if(status!=NC_NOERR){fprintf(stderr,"%s: %s\n",#call,nc_strerror(status));return 1;}} while(0)
#define REQUIRE(condition) do {if(!(condition)){fprintf(stderr,"%s\n",#condition);return 2;}} while(0)
int main(int argc,char **argv) {
    int ncid,format,var,dim,i,values[4];size_t length;unsigned long long wide[4];unsigned char bytes[3];
    CHECK(nc_open(argc>1?argv[1]:"pnetcdf-cdf5.nc",NC_NOWRITE,&ncid));
    CHECK(nc_inq_format(ncid,&format));REQUIRE(format==NC_FORMAT_64BIT_DATA);
    CHECK(nc_inq_dimid(ncid,"samples",&dim));CHECK(nc_inq_dimlen(ncid,dim,&length));REQUIRE(length==4);
    CHECK(nc_inq_varid(ncid,"values",&var));CHECK(nc_get_var_int(ncid,var,values));
    CHECK(nc_inq_varid(ncid,"wide_values",&var));CHECK(nc_get_var_ulonglong(ncid,var,wide));
    CHECK(nc_get_att_uchar(ncid,NC_GLOBAL,"bytes",bytes));REQUIRE(bytes[0]==0&&bytes[1]==127&&bytes[2]==255);
    for(i=0;i<4;i++){REQUIRE(values[i]==i);REQUIRE(wide[i]==9007199254740993ULL+(unsigned long long)i);}
    CHECK(nc_close(ncid));puts("netCDF-C independently read PnetCDF CDF-5 exact uint64 data PASS");return 0;
}
