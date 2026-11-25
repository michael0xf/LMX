/* Local integration test. Upstream library sources are unmodified. */
#define DECNUMDIGITS 50
#include "decNumber.h"
#include "decPacked.h"
#include "decimal32.h"
#include "decimal64.h"
#include "decimal128.h"
#include "decSingle.h"
#include "decDouble.h"
#include "decQuad.h"
#include <stdio.h>
#include <string.h>

#define CHECK(c) do { if (!(c)) { \
    fprintf(stderr, "%s:%d: %s\n", __FILE__, __LINE__, #c); return 1; \
} } while (0)

int main(void) {
    decContext ctx;
    decNumber a, b, result;
    decimal32 d32;
    decimal64 d64;
    decimal128 d128;
    decSingle single;
    decDouble da, db, dr;
    decQuad qa, qb, qr;
    uint8_t packed[16];
    int32_t scale = 0;
    char text[DECNUMDIGITS + 16];

    decContextDefault(&ctx, DEC_INIT_BASE);
    ctx.traps = 0;
    ctx.digits = DECNUMDIGITS;
    decNumberFromString(&a, "1.23", &ctx);
    decNumberFromString(&b, "1.27", &ctx);
    decNumberAdd(&result, &a, &b, &ctx);
    CHECK(strcmp(decNumberToString(&result, text), "2.50") == 0);
    CHECK(ctx.status == 0);

    decNumberFromString(&a, "1", &ctx);
    decNumberFromString(&b, "3", &ctx);
    ctx.digits = 10;
    decNumberDivide(&result, &a, &b, &ctx);
    CHECK(strcmp(decNumberToString(&result, text), "0.3333333333") == 0);
    CHECK((ctx.status & DEC_Inexact) != 0);

    decContextDefault(&ctx, DEC_INIT_DECIMAL32);
    decimal32FromString(&d32, "-123.45", &ctx);
    CHECK(strcmp(decimal32ToString(&d32, text), "-123.45") == 0);
    decimal32ToNumber(&d32, &result);
    CHECK(strcmp(decNumberToString(&result, text), "-123.45") == 0);
    decSingleFromString(&single, "123.45", &ctx);
    CHECK(strcmp(decSingleToString(&single, text), "123.45") == 0);

    decContextDefault(&ctx, DEC_INIT_DECIMAL64);
    decimal64FromString(&d64, "123456789012.3456", &ctx);
    CHECK(strcmp(decimal64ToString(&d64, text), "123456789012.3456") == 0);
    decDoubleFromString(&da, "0.1", &ctx);
    decDoubleFromString(&db, "0.2", &ctx);
    decDoubleAdd(&dr, &da, &db, &ctx);
    CHECK(strcmp(decDoubleToString(&dr, text), "0.3") == 0);

    decContextDefault(&ctx, DEC_INIT_DECIMAL128);
    decimal128FromString(&d128, "123456789012345678901234567890.1234", &ctx);
    CHECK(strcmp(decimal128ToString(&d128, text),
                 "123456789012345678901234567890.1234") == 0);
    decQuadFromString(&qa, "12345678901234567890", &ctx);
    decQuadFromString(&qb, "10", &ctx);
    decQuadMultiply(&qr, &qa, &qb, &ctx);
    CHECK(strcmp(decQuadToString(&qr, text), "123456789012345678900") == 0);

    decNumberFromString(&a, "-123.45", &ctx);
    CHECK(decPackedFromNumber(packed, (int32_t) sizeof(packed), &scale, &a) != NULL);
    CHECK(scale == 2);
    CHECK(decPackedToNumber(packed, (int32_t) sizeof(packed), &scale, &result) != NULL);
    CHECK(strcmp(decNumberToString(&result, text), "-123.45") == 0);
    CHECK(ctx.status == 0);
    return 0;
}
