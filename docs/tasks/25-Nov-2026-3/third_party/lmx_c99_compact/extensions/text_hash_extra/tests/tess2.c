#include <tesselator.h>
#include <math.h>
#include <stdio.h>

#define CHECK(expr) do { if (!(expr)) { fprintf(stderr, "check failed at %d: %s\n", __LINE__, #expr); return 1; } } while (0)

int main(void)
{
    const TESSreal outer[] = { 0, 0, 4, 0, 4, 4, 0, 4 };
    const TESSreal inner[] = { 1, 1, 1, 3, 3, 3, 3, 1 };
    TESStesselator *tess = tessNewTess(NULL);
    const TESSreal *vertices;
    const TESSindex *elements;
    double area = 0.0;
    int i, j, count;
    CHECK(tess != NULL);
    tessAddContour(tess, 2, outer, (int)(2 * sizeof(TESSreal)), 4);
    tessAddContour(tess, 2, inner, (int)(2 * sizeof(TESSreal)), 4);
    CHECK(tessTesselate(tess, TESS_WINDING_ODD, TESS_POLYGONS, 3, 2, NULL) == 1);
    vertices = tessGetVertices(tess);
    elements = tessGetElements(tess);
    count = tessGetElementCount(tess);
    CHECK(count > 0 && vertices != NULL && elements != NULL);
    for (i = 0; i < count; ++i) {
        const TESSreal *a, *b, *c;
        for (j = 0; j < 3; ++j) {
            CHECK(elements[3 * i + j] != TESS_UNDEF);
            CHECK(elements[3 * i + j] >= 0 && elements[3 * i + j] < tessGetVertexCount(tess));
        }
        a = vertices + 2 * elements[3 * i];
        b = vertices + 2 * elements[3 * i + 1];
        c = vertices + 2 * elements[3 * i + 2];
        area += fabs((double)(b[0] - a[0]) * (c[1] - a[1]) - (double)(b[1] - a[1]) * (c[0] - a[0])) / 2.0;
    }
    CHECK(fabs(area - 12.0) < 1e-5);
    CHECK(tessGetVertexIndices(tess) != NULL);
    tessDeleteTess(tess);
    return 0;
}
