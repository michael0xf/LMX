#include <inttypes.h>
#include <stdio.h>
#include <h3api.h>
#define CHECK(c) do { if (!(c)) { fprintf(stderr,"H3 check line %d\n",__LINE__); return 1; } } while(0)
int main(void)
{
    LatLng sf = {0,0}, center;
    H3Index cell, disk[7] = {0}, again, parent;
    CellBoundary boundary;
    int64_t size, children;
    int i, j, center_count = 0;
    double area;
    sf.lat = degsToRads(37.775938728915946);
    sf.lng = degsToRads(-122.41795063018799);
    CHECK(latLngToCell(&sf, 9, &cell) == E_SUCCESS);
    CHECK(cell == UINT64_C(0x8928308280fffff));
    CHECK(isValidCell(cell) && getResolution(cell) == 9);
    CHECK(cellToLatLng(cell, &center) == E_SUCCESS);
    CHECK(latLngToCell(&center, 9, &again) == E_SUCCESS && again == cell);
    CHECK(maxGridDiskSize(1, &size) == E_SUCCESS && size == 7);
    CHECK(gridDisk(cell, 1, disk) == E_SUCCESS);
    for(i = 0; i < 7; ++i) {
        CHECK(isValidCell(disk[i]));
        if(disk[i] == cell) ++center_count;
        else {
            int neighbors = 0;
            CHECK(areNeighborCells(cell, disk[i], &neighbors) == E_SUCCESS);
            CHECK(neighbors == 1);
        }
        for(j = 0; j < i; ++j) CHECK(disk[i] != disk[j]);
    }
    CHECK(center_count == 1);
    CHECK(cellToParent(cell, 8, &parent) == E_SUCCESS);
    CHECK(cellToChildrenSize(parent, 9, &children) == E_SUCCESS && children == 7);
    CHECK(cellToBoundary(cell, &boundary) == E_SUCCESS);
    CHECK(boundary.numVerts == 6);
    CHECK(cellAreaKm2(cell, &area) == E_SUCCESS && area > 0.1 && area < 0.12);
    printf("H3 reference cell %" PRIx64 ", centroid, grid and parent passed\n", cell);
    return 0;
}
