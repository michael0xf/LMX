#include <ccd/ccd.h>
#include <math.h>
#include <stdio.h>

#define CHECK(expr) do { if (!(expr)) { fprintf(stderr, "check failed at %d: %s\n", __LINE__, #expr); return 1; } } while (0)

typedef struct box_t { ccd_real_t x, y, z, half; } box_t;

static void support(const void *object, const ccd_vec3_t *direction, ccd_vec3_t *out)
{
    const box_t *box = (const box_t *)object;
    ccdVec3Set(out,
        box->x + (ccdVec3X(direction) < 0 ? -box->half : box->half),
        box->y + (ccdVec3Y(direction) < 0 ? -box->half : box->half),
        box->z + (ccdVec3Z(direction) < 0 ? -box->half : box->half));
}

static void center(const void *object, ccd_vec3_t *out)
{
    const box_t *box = (const box_t *)object;
    ccdVec3Set(out, box->x, box->y, box->z);
}

int main(void)
{
    const box_t a = { 0, 0, 0, 1 };
    box_t b = { 3, 0, 0, 1 };
    ccd_t ccd;
    ccd_real_t depth;
    ccd_vec3_t direction, position;
    CCD_INIT(&ccd);
    ccd.support1 = support;
    ccd.support2 = support;
    ccd.center1 = center;
    ccd.center2 = center;
    ccd.max_iterations = 128;
    CHECK(sizeof(ccd_real_t) == sizeof(double));
    CHECK(ccdGJKIntersect(&a, &b, &ccd) == 0);
    CHECK(ccdMPRIntersect(&a, &b, &ccd) == 0);
    b.x = 1.5;
    CHECK(ccdGJKIntersect(&a, &b, &ccd) == 1);
    CHECK(ccdMPRIntersect(&a, &b, &ccd) == 1);
    CHECK(ccdGJKPenetration(&a, &b, &ccd, &depth, &direction, &position) == 0);
    CHECK(fabs((double)depth - 0.5) < 1e-5);
    CHECK(ccdMPRPenetration(&a, &b, &ccd, &depth, &direction, &position) == 0);
    CHECK(fabs((double)depth - 0.5) < 1e-5);
    return 0;
}
