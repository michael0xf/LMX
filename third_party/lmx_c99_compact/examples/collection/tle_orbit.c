#include <inttypes.h>
#include <stdio.h>
#include <string.h>
#include "TLE.h"

int main(void)
{
    /* Published Vallado verification case 00005, not a current live TLE. */
    char line1[] = "1 00005U 58002B   00179.78495062  .00000023  00000-0  28098-4 0  4753";
    char line2[] = "2 00005  34.2682 348.7242 1859667 331.7664  19.3264 10.82419157413667";
    TLE orbit;
    int step;
    memset(&orbit, 0, sizeof orbit);
    parseLines(&orbit, line1, line2);
    printf("Satellite %s, epoch_milliseconds_since_1970=%" PRId64 "\n", orbit.objectID, orbit.epoch);
    puts("minutes_since_epoch, TEME_x_km, TEME_y_km, TEME_z_km, TEME_vx_km_s, TEME_vy_km_s, TEME_vz_km_s");
    for (step = 0; step <= 6; ++step) {
        double position[3], velocity[3], minutes = step*60.0;
        getRV(&orbit, minutes, position, velocity);
        if (orbit.sgp4Error) {
            fprintf(stderr, "SGP4 failed: %d\n", orbit.sgp4Error);
            return 1;
        }
        printf("%.1f, %.8f, %.8f, %.8f, %.9f, %.9f, %.9f\n", minutes,
               position[0], position[1], position[2], velocity[0], velocity[1], velocity[2]);
    }
    return 0;
}
