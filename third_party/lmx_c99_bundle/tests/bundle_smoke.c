#include <math.h>
#include <stdio.h>
#include <string.h>
#include "stb_perlin.h"
#include "khash.h"
#include <stc/cstr.h>

#ifdef LMX_BUNDLE_CURL_ZLIB
#include <curl/curl.h>
#include <zlib.h>
#endif
#if defined(LMX_BUNDLE_PRECISION) && defined(LMX_BUNDLE_SCIENTIFIC)
#include "c99_gsl.h"
#elif defined(LMX_BUNDLE_PRECISION)
#include "tommath.h"
#include "mpdecimal.h"
#elif defined(LMX_BUNDLE_SCIENTIFIC)
#include "lmx_scientific.h"
#endif
#ifdef LMX_BUNDLE_QUADRATURE
#include "c99_quad.h"
static double bundle_squared(double x) { return x * x; }
#endif
#ifdef LMX_BUNDLE_SODIUM
#include <sodium.h>
#endif
#ifdef LMX_BUNDLE_SQLITE3
#include <sqlite3.h>
#endif
#ifdef LMX_BUNDLE_RUNTIME_EXTRAS
#include <decQuad.h>
#include <civetweb.h>
#include <sljitLir.h>
#endif

KHASH_MAP_INIT_INT(bundle_values, double)

int main(void)
{
    khash_t(bundle_values) *values = kh_init(bundle_values);
    int inserted;
    khiter_t key;
    double factorial;
    float noise;
    cstr message;
    if (!values) return 1;
    key = kh_put(bundle_values, values, 6, &inserted);
    if (inserted < 0) { kh_destroy(bundle_values, values); return 2; }
    factorial = tgamma(6.0);
    kh_value(values, key) = factorial;
    noise = stb_perlin_noise3(0.25f, 0.5f, 0.75f, 0, 0, 0);
    message = cstr_from("all enabled library groups linked and ran");
    if (fabs(kh_value(values, key) - 120.0) > 1e-10 || !isfinite(noise)) return 3;
    puts(cstr_str(&message));
    cstr_drop(&message);
    kh_destroy(bundle_values, values);
#ifdef LMX_BUNDLE_CURL_ZLIB
    {
        CURL *handle;
        if (curl_global_init(CURL_GLOBAL_DEFAULT) != CURLE_OK) return 10;
        handle = curl_easy_init();
        if (!handle || !zlibVersion() || !curl_version()) return 11;
        curl_easy_cleanup(handle);
        curl_global_cleanup();
    }
#endif
#ifdef LMX_BUNDLE_PRECISION
    {
        mp_int integer;
        mpd_context_t context;
        mpd_t *real;
        char *decimal;
        uint32_t status = 0;
        if (mp_init(&integer) != MP_OKAY) return 20;
        if (mp_read_radix(&integer, "1208925819614629174706176", 10) != MP_OKAY)
            return 21;
        if (mp_count_bits(&integer) != 81) return 22;
        mp_clear(&integer);
        mpd_defaultcontext(&context);
        context.prec = 50;
        context.traps = 0;
        real = mpd_qnew();
        if (!real) return 23;
        mpd_qset_string(real, "4", &context, &status);
        mpd_qsqrt(real, real, &context, &status);
        decimal = mpd_to_sci(real, 1);
        if (status || !decimal || strcmp(decimal, "2") != 0) return 24;
        mpd_free(decimal);
        mpd_del(real);
    }
#endif
#ifdef LMX_BUNDLE_SCIENTIFIC
    {
        lmx_rng rng;
        double sample;
        lmx_rng_seed(&rng, UINT64_C(123));
        sample = lmx_rng_uniform(&rng);
        if (!(sample >= 0.0 && sample < 1.0)) return 25;
    }
#endif
#ifdef LMX_BUNDLE_SODIUM
    if (sodium_init() < 0) return 30;
#endif
#ifdef LMX_BUNDLE_SQLITE3
    {
        sqlite3 *database = NULL;
        sqlite3_stmt *statement = NULL;
        int ok = 0;
        if (sqlite3_open(":memory:", &database) == SQLITE_OK &&
            sqlite3_prepare_v2(database, "SELECT 6 * 7", -1,
                &statement, NULL) == SQLITE_OK &&
            sqlite3_step(statement) == SQLITE_ROW &&
            sqlite3_column_int(statement, 0) == 42)
            ok = 1;
        if (sqlite3_finalize(statement) != SQLITE_OK) ok = 0;
        if (sqlite3_close(database) != SQLITE_OK) ok = 0;
        if (!ok) return 31;
    }
#endif
#ifdef LMX_BUNDLE_QUADRATURE
    {
        double error;
        int evaluations, status;
        double value = c99_quad_dqags(bundle_squared, 0.0, 1.0,
            1e-12, 1e-12, &error, &evaluations, &status);
        if (status || evaluations <= 0 || fabs(value - 1.0 / 3.0) > 1e-12)
            return 35;
    }
#endif
#ifdef LMX_BUNDLE_RUNTIME_EXTRAS
    {
        decContext context;
        decQuad a, b, sum;
        char decimal[DECQUAD_String];
        decContextDefault(&context, DEC_INIT_DECQUAD);
        decQuadFromString(&a, "0.1", &context);
        decQuadFromString(&b, "0.2", &context);
        decQuadAdd(&sum, &a, &b, &context);
        decQuadToString(&sum, decimal);
        if (strcmp(decimal, "0.3") != 0 || !mg_version() || !sljit_get_platform_name()) return 40;
    }
#endif
    return 0;
}
