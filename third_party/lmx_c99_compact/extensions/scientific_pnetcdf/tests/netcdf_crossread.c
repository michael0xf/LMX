/* SPDX-License-Identifier: 0BSD
 * Read the CDF-5 fixture produced by scientific_netcdf/tests/formats.c --keep.
 * Every MPI rank collectively reads and verifies the same small fixture.
 */
#include <pnetcdf.h>
#include <stdio.h>
#include <string.h>

static int rank;
#define CHECK(call) do { int rc_ = (call); if (rc_ != NC_NOERR) { \
    fprintf(stderr, "rank %d line %d: %s: %s\n", rank, __LINE__, #call, ncmpi_strerror(rc_)); \
    MPI_Abort(MPI_COMM_WORLD, 2); } } while (0)
#define REQUIRE(condition) do { if (!(condition)) { \
    fprintf(stderr, "rank %d line %d: %s\n", rank, __LINE__, #condition); \
    MPI_Abort(MPI_COMM_WORLD, 3); } } while (0)

int main(int argc, char **argv)
{
    const int expected[6] = {-7, 0, 42, 300, -900, 12345};
    const unsigned long long expected_wide[3] = {
        9007199254740993ULL, 18446744073709551614ULL, 12345678901234567890ULL
    };
    MPI_Offset start[2] = {0, 0}, count[2] = {2, 3};
    MPI_Offset wide_start[1] = {0}, wide_count[1] = {3}, length;
    int ncid, format, dim, unlimited, values, exact, actual[6], nprocs;
    unsigned long long actual_wide[3];
    char unit[7] = {0};
    nc_type type;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &nprocs);
    REQUIRE(argc == 2);
    CHECK(ncmpi_open(MPI_COMM_WORLD, argv[1], NC_NOWRITE, MPI_INFO_NULL, &ncid));
    CHECK(ncmpi_inq_format(ncid, &format));
    REQUIRE(format == NC_FORMAT_64BIT_DATA);
    CHECK(ncmpi_inq_dimid(ncid, "time", &dim));
    CHECK(ncmpi_inq_unlimdim(ncid, &unlimited)); REQUIRE(dim == unlimited);
    CHECK(ncmpi_inq_dimlen(ncid, dim, &length)); REQUIRE(length == 2);
    CHECK(ncmpi_inq_dimid(ncid, "x", &dim));
    CHECK(ncmpi_inq_dimlen(ncid, dim, &length)); REQUIRE(length == 3);
    CHECK(ncmpi_inq_varid(ncid, "values", &values));
    CHECK(ncmpi_inq_vartype(ncid, values, &type)); REQUIRE(type == NC_INT);
    CHECK(ncmpi_get_vara_int_all(ncid, values, start, count, actual));
    REQUIRE(memcmp(expected, actual, sizeof(expected)) == 0);
    CHECK(ncmpi_inq_attlen(ncid, values, "unit", &length)); REQUIRE(length == 6);
    CHECK(ncmpi_get_att_text(ncid, values, "unit", unit)); REQUIRE(!strcmp(unit, "Kelvin"));
    CHECK(ncmpi_inq_varid(ncid, "exact_u64", &exact));
    CHECK(ncmpi_inq_vartype(ncid, exact, &type)); REQUIRE(type == NC_UINT64);
    CHECK(ncmpi_get_vara_ulonglong_all(ncid, exact, wide_start, wide_count, actual_wide));
    REQUIRE(memcmp(expected_wide, actual_wide, sizeof(expected_wide)) == 0);
    CHECK(ncmpi_close(ncid));
    if (rank == 0)
        printf("netCDF-C -> PnetCDF CDF-5: dimensions, unlimited records, int data, text attribute, exact uint64; ranks=%d PASS\n", nprocs);
    MPI_Finalize();
    return 0;
}
