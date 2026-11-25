#include <stdio.h>
#include <geodesic.h>
#include <minmea.h>
int main(void)
{
    const char *sentence = "$GPRMC,123519,A,4807.038,N,01131.000,E,022.4,084.4,230394,003.1,W*6A";
    struct minmea_sentence_rmc fix;
    struct geod_geodesic earth;
    double distance;
    if(!minmea_check(sentence, true) || !minmea_parse_rmc(&fix, sentence) || !fix.valid) {
        fputs("Invalid NMEA position\n", stderr);
        return 1;
    }
    geod_init(&earth, 6378137.0, 1.0/298.257223563);
    printf("Sentence: %.2s %.3s\n", fix.type.fields.talker_id,
           fix.type.fields.sentence_id);
    geod_inverse(&earth, minmea_tocoord(&fix.latitude), minmea_tocoord(&fix.longitude),
                 48.8566, 2.3522, &distance, NULL, NULL);
    printf("Distance from the supplied sample fix to Paris: %.3f km\n", distance/1000.0);
    return 0;
}
