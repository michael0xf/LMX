#include <matio.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define CHECK(x) do { if (!(x)) { fprintf(stderr, "MAT check failed at %d: %s\n", __LINE__, #x); exit(1); } } while (0)
static void roundtrip(enum mat_ft version, enum matio_compression compression)
{
    const char *path = "knowledge_extra_roundtrip.mat";
    size_t dims[] = {2,3};
    double values[] = {1,-2,3.5,4,0,6};
    mat_t *f = Mat_CreateVer(path, "LMX portable data", version);
    matvar_t *v, *r;
    CHECK(f);
    v = Mat_VarCreate("measurements", MAT_C_DOUBLE, MAT_T_DOUBLE, 2, dims, values, 0);
    CHECK(v); CHECK(Mat_VarWrite(f, v, compression) == 0);
    Mat_VarFree(v);
    if (version == MAT_FT_MAT5) {
        size_t one[] = {1,1};
        const char *fields[] = {"value", NULL};
        double number = 42;
        matvar_t *record = Mat_VarCreateStruct2("record", 2, one, fields);
        CHECK(record);
        v = Mat_VarCreate(NULL, MAT_C_DOUBLE, MAT_T_DOUBLE, 2, one, &number, 0);
        CHECK(v); Mat_VarSetStructFieldByName(record, "value", 0, v);
        CHECK(Mat_VarWrite(f, record, compression) == 0);
        Mat_VarFree(record);
    }
    CHECK(Mat_Close(f) == 0);
    f = Mat_Open(path, MAT_ACC_RDONLY); CHECK(f);
    CHECK(Mat_GetVersion(f) == version);
    r = Mat_VarRead(f, "measurements"); CHECK(r);
    CHECK(r->rank == 2 && r->dims[0] == 2 && r->dims[1] == 3);
    CHECK(r->class_type == MAT_C_DOUBLE && r->data_type == MAT_T_DOUBLE);
    CHECK(memcmp(r->data, values, sizeof(values)) == 0); Mat_VarFree(r);
    if (version == MAT_FT_MAT5) {
        r = Mat_VarRead(f, "record"); CHECK(r && r->class_type == MAT_C_STRUCT);
        v = Mat_VarGetStructFieldByName(r, "value", 0);
        CHECK(v && v->data && *(double *)v->data == 42);
        Mat_VarFree(r);
    }
    CHECK(Mat_VarRead(f, "missing") == NULL);
    CHECK(Mat_Close(f) == 0); CHECK(remove(path) == 0);
}
int main(void)
{
    roundtrip(MAT_FT_MAT4, MAT_COMPRESSION_NONE);
    roundtrip(MAT_FT_MAT5, MAT_COMPRESSION_NONE);
    roundtrip(MAT_FT_MAT5, MAT_COMPRESSION_ZLIB);
    return 0;
}
