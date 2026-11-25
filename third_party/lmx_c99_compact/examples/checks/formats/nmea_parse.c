#include <math.h>
#include <stddef.h>
#include <stdio.h>
#include <minmea.h>
#define CHECK(c) do { if (!(c)) { fprintf(stderr,"minmea check line %d\n",__LINE__); return 1; } } while(0)
int main(void)
{
    const char *rmc = "$GPRMC,123519,A,4807.038,N,01131.000,E,022.4,084.4,230394,003.1,W*6A";
    const char *gga = "$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*47";
    struct minmea_sentence_rmc frame;
    struct minmea_sentence_gga fix;
    struct minmea_date date = {1,1,2000};
    struct minmea_time time = {0,0,0,0};
    struct timespec ts;
    CHECK(sizeof(union minmea_type) == 6);
    CHECK(offsetof(union minmea_type, buf) == 0);
    CHECK(offsetof(union minmea_type, fields.talker_id) == 0);
    CHECK(offsetof(union minmea_type, fields.sentence_id) == 2);
    CHECK(offsetof(union minmea_type, fields.null_terminator) == 5);
    CHECK(minmea_check(rmc, true));
    CHECK(minmea_sentence_id(rmc, true) == MINMEA_SENTENCE_RMC);
    CHECK(minmea_parse_rmc(&frame, rmc) && frame.valid);
    CHECK(frame.type.fields.talker_id[0] == 'G' && frame.type.fields.talker_id[1] == 'P');
    CHECK(frame.type.fields.sentence_id[0] == 'R' && frame.type.fields.sentence_id[1] == 'M');
    CHECK(frame.type.fields.sentence_id[2] == 'C' && frame.type.fields.null_terminator == '\0');
    CHECK(frame.time.hours == 12 && frame.time.minutes == 35 && frame.time.seconds == 19);
    CHECK(frame.date.day == 23 && frame.date.month == 3 && frame.date.year == 94);
    CHECK(fabs(minmea_tocoord(&frame.latitude)-48.1173) < 1e-5);
    CHECK(fabs(minmea_tocoord(&frame.longitude)-11.5166666667) < 1e-5);
    CHECK(minmea_rescale(&frame.speed, 10) == 224);
    CHECK(minmea_check(gga, true) && minmea_parse_gga(&fix, gga));
    CHECK(fix.fix_quality == 1 && fix.satellites_tracked == 8);
    CHECK(minmea_rescale(&fix.altitude, 10) == 5454);
    CHECK(!minmea_check("$GPRMC,123519,A*00", true));
    CHECK(minmea_gettime(&ts, &date, &time) == 0);
    CHECK(ts.tv_sec == (time_t)946684800 && ts.tv_nsec == 0);
    puts("minmea RMC/GGA/checksum/coordinates/UTC conversion passed (no GPS device)");
    return 0;
}
