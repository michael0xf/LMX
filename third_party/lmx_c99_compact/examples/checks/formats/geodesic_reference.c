/* Reference tuple from upstream MIT-licensed tests/geodtest.c, Charles Karney. */
#include <math.h>
#include <stdio.h>
#include <geodesic.h>
#define CHECK(c) do { if (!(c)) { fprintf(stderr,"geodesic check line %d\n",__LINE__); return 1; } } while(0)
int main(void)
{
    struct geod_geodesic wgs84, sphere;
    struct geod_polygon polygon;
    double distance, azimuth1, azimuth2, latitude, longitude, area, perimeter;
    double pi = acos(-1.0);
    geod_init(&wgs84, 6378137.0, 1.0/298.257223563);
    geod_inverse(&wgs84, 35.60777, -139.44815, -11.17491, -69.95921,
                 &distance, &azimuth1, &azimuth2);
    CHECK(fabs(distance-8935244.5604818305) < 1e-7);
    CHECK(fabs(azimuth1-111.098748429560326) < 1e-12);
    CHECK(fabs(azimuth2-129.289270889708762) < 1e-12);
    geod_direct(&wgs84, 35.60777, -139.44815, azimuth1, distance,
                &latitude, &longitude, NULL);
    CHECK(fabs(latitude-(-11.17491)) < 1e-12);
    CHECK(fabs(longitude-(-69.95921)) < 1e-12);
    geod_inverse(&wgs84, 0, 0, 0, 90, &distance, NULL, NULL);
    CHECK(fabs(distance-(pi/2)*6378137.0) < 1e-7);
    geod_init(&sphere, 1, 0);
    geod_polygon_init(&polygon, 0);
    geod_polygon_addpoint(&sphere, &polygon, 0, 0);
    geod_polygon_addpoint(&sphere, &polygon, 0, 90);
    geod_polygon_addpoint(&sphere, &polygon, 90, 0);
    CHECK(geod_polygon_compute(&sphere, &polygon, 0, 1, &area, &perimeter) == 3);
    CHECK(fabs(area-pi/2) < 1e-14);
    CHECK(fabs(perimeter-3*pi/2) < 1e-14);
    puts("Geodesic reference/inverse/direct/equator/spherical-octant area passed");
    return 0;
}
