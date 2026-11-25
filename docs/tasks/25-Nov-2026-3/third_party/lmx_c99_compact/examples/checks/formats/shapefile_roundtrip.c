#include <math.h>
#include <stdio.h>
#include <string.h>
#include <shapefil.h>
#define CHECK(c) do { if (!(c)) { fprintf(stderr,"Shapelib check line %d\n",__LINE__); return 1; } } while(0)
int main(int argc, char **argv)
{
    double x[5] = {0,0,2,2,0}, y[5] = {0,1,1,0,0};
    double low[4], high[4];
    SHPHandle shp;
    DBFHandle dbf;
    SHPObject *polygon;
    int entities, type, i;
    CHECK(argc == 2);
    shp = SHPCreate(argv[1], SHPT_POLYGON);
    CHECK(shp != NULL);
    polygon = SHPCreateSimpleObject(SHPT_POLYGON, 5, x, y, NULL);
    CHECK(polygon != NULL);
    CHECK(SHPWriteObject(shp, -1, polygon) == 0);
    SHPDestroyObject(polygon);
    SHPClose(shp);
    dbf = DBFCreateEx(argv[1], "UTF-8");
    CHECK(dbf != NULL);
    CHECK(DBFAddField(dbf, "NAME", FTString, 32, 0) == 0);
    CHECK(DBFAddField(dbf, "COUNT", FTInteger, 9, 0) == 1);
    CHECK(DBFAddField(dbf, "VALUE", FTDouble, 12, 3) == 2);
    CHECK(DBFWriteStringAttribute(dbf, 0, 0, "LMX тест & data"));
    CHECK(DBFWriteIntegerAttribute(dbf, 0, 1, 42));
    CHECK(DBFWriteDoubleAttribute(dbf, 0, 2, 12.375));
    DBFClose(dbf);
    shp = SHPOpen(argv[1], "rb");
    CHECK(shp != NULL);
    SHPGetInfo(shp, &entities, &type, low, high);
    CHECK(entities == 1 && type == SHPT_POLYGON);
    CHECK(low[0] == 0 && low[1] == 0 && high[0] == 2 && high[1] == 1);
    polygon = SHPReadObject(shp, 0);
    CHECK(polygon != NULL && polygon->nVertices == 5 && polygon->nParts == 1);
    for(i = 0; i < 5; ++i) CHECK(polygon->padfX[i] == x[i] && polygon->padfY[i] == y[i]);
    SHPDestroyObject(polygon);
    SHPClose(shp);
    dbf = DBFOpen(argv[1], "rb");
    CHECK(dbf != NULL && DBFGetRecordCount(dbf) == 1 && DBFGetFieldCount(dbf) == 3);
    CHECK(strcmp(DBFReadStringAttribute(dbf, 0, 0), "LMX тест & data") == 0);
    CHECK(DBFReadIntegerAttribute(dbf, 0, 1) == 42);
    CHECK(fabs(DBFReadDoubleAttribute(dbf, 0, 2)-12.375) < 1e-12);
    DBFClose(dbf);
    puts("Shapelib polygon/SHP/SHX/DBF UTF-8+number roundtrip passed");
    return 0;
}
