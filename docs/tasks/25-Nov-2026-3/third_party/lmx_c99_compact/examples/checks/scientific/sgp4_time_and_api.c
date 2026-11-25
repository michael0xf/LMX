#include <inttypes.h>
#include <math.h>
#include <stdio.h>
#include <string.h>
#include "TLE.h"

#define REQUIRE(expr) do { if (!(expr)) { \
    fprintf(stderr, "%s:%d: %s\n", __FILE__, __LINE__, #expr); return 1; \
} } while (0)

static int date_case(char text[15], int64_t expected, int expected_year)
{
    ElsetRec rec;
    int64_t actual;
    memset(&rec, 0, sizeof rec);
    actual = parseEpoch(&rec, text);
    if (actual != expected || rec.epochyr != expected_year) {
        fprintf(stderr, "epoch %s: actual=%" PRId64 " expected=%" PRId64 "\n", text, actual, expected);
        return 0;
    }
    return 1;
}

int main(void)
{
    char l1[] = "1 00005U 58002B   00179.78495062  .00000023  00000-0  28098-4 0  4753";
    char l2[] = "2 00005  34.2682 348.7242 1859667 331.7664  19.3264 10.82419157413667";
    TLE tle, direct, dated, later, reference;
    double r1[3], v1[3], r2[3], v2[3];
    int i, direction;

    REQUIRE(sizeof(tle.epoch) == sizeof(int64_t));
    REQUIRE(date_case("56001.00000000", INT64_C(2713910400000), 56));
    REQUIRE(date_case("57001.00000000", -INT64_C(410227200000), 57));
    REQUIRE(date_case("39001.00000000", INT64_C(2177452800000), 39));
    REQUIRE(date_case("00060.50000000", INT64_C(951825600000), 0));

    memset(&tle, 0, sizeof tle);
    parseLines(&tle, l1, l2);
    REQUIRE(tle.rec.whichconst == wgs72);
    REQUIRE(strcmp(tle.objectID, "00005") == 0);
    REQUIRE(strcmp(tle.intlid, "58002B  ") == 0);
    REQUIRE(strcmp(tle.rec.satid, "00005") == 0);
    REQUIRE(fabs(tle.rec.epochdays - 179.78495062) < 1e-12);
    for (direction = -1; direction <= 1; direction += 2) {
        direct = tle; dated = tle;
        getRV(&direct, direction*60.0, r1, v1);
        getRVForDate(&dated, tle.epoch + direction*INT64_C(3600000), r2, v2);
        REQUIRE(direct.sgp4Error == 0 && dated.sgp4Error == 0);
        for (i = 0; i < 3; ++i) {
            REQUIRE(isfinite(r1[i]) && isfinite(v1[i]));
            REQUIRE(fabs(r1[i]-r2[i]) < 1e-10);
            REQUIRE(fabs(v1[i]-v2[i]) < 1e-12);
        }
    }

    /* Modern date beyond both 32-bit seconds and 32-bit milliseconds. */
    l1[18] = '5'; l1[19] = '6';
    memset(&later, 0, sizeof later);
    parseLines(&later, l1, l2);
    REQUIRE(later.epoch > INT64_C(2147483647000));
    reference = later;
    getRVForDate(&later, later.epoch + INT64_C(60000), r1, v1);
    getRV(&reference, 1.0, r2, v2);
    REQUIRE(later.sgp4Error == 0 && reference.sgp4Error == 0);
    for (i = 0; i < 3; ++i) REQUIRE(fabs(r1[i]-r2[i]) < 1e-10);

    printf("TLE parsing, int64 epochs (1957/2000/2039/2056), and +/-60 minute stepping passed.\n");
    printf("sizeof_TLE=%zu sizeof_ElsetRec=%zu sizeof_epoch=%zu\n", sizeof(TLE), sizeof(ElsetRec), sizeof(tle.epoch));
    return 0;
}
