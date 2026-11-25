#include "lmx_catalog_bridge.h"

/* capi_5bf3eaac1de535e5 | json_loadb
 * third_party/lmx_c99_compact/vendor/jansson/src/jansson.h:368
 * json_t * json_loadb ( const char * buffer , size_t buflen , size_t flags , json_error_t * error ) JANSSON_ATTRS ( ( warn_unused_result ) )
 */
#ifdef LMXC99_ENABLE_CAPI_5BF3EAAC1DE535E5
/* The selected target must supply its real public header/config.
 * For generated .h.in or alternate profiles, override HEADER explicitly. */
#ifndef LMXC99_HEADER_CAPI_5BF3EAAC1DE535E5
#define LMXC99_HEADER_CAPI_5BF3EAAC1DE535E5 "jansson.h"
#endif
#include LMXC99_HEADER_CAPI_5BF3EAAC1DE535E5
#endif
int lmx_bridge_json_loadb_5bf3eaac1de535e5(void *opaque)
{
    lmx_catalog_frame *frame = (lmx_catalog_frame *)opaque;
#ifdef LMXC99_ENABLE_CAPI_5BF3EAAC1DE535E5
    int rc;
    LMXC99_TYPE_CAPI_5BF3EAAC1DE535E5_A0 a0;
    LMXC99_TYPE_CAPI_5BF3EAAC1DE535E5_A1 a1;
    LMXC99_TYPE_CAPI_5BF3EAAC1DE535E5_A2 a2;
    LMXC99_TYPE_CAPI_5BF3EAAC1DE535E5_A3 a3;
    LMXC99_RESULT_CAPI_5BF3EAAC1DE535E5 result;
    rc = lmx_catalog_check(frame, 4U);
    if (rc != LMXC_OK) return rc;
    rc = LMXC99_READ_CAPI_5BF3EAAC1DE535E5_A0(frame, 0U, &a0);
    if (rc != LMXC_OK) return rc;
    rc = LMXC99_READ_CAPI_5BF3EAAC1DE535E5_A1(frame, 1U, &a1);
    if (rc != LMXC_OK) return rc;
    rc = LMXC99_READ_CAPI_5BF3EAAC1DE535E5_A2(frame, 2U, &a2);
    if (rc != LMXC_OK) return rc;
    rc = LMXC99_READ_CAPI_5BF3EAAC1DE535E5_A3(frame, 3U, &a3);
    if (rc != LMXC_OK) return rc;
    /* All conversions are finished in lexical order before C evaluates its
     * argument expressions. CHECK validates cross-argument lengths, output
     * capacity, overlap, resource states and any per-operation domain rule. */
    rc = LMXC99_CHECK_CAPI_5BF3EAAC1DE535E5(frame);
    if (rc != LMXC_OK) return rc;
    result = json_loadb(a0, a1, a2, a3);
    return LMXC99_SAVE_CAPI_5BF3EAAC1DE535E5(frame, result);
#else
    return lmx_catalog_review_required(frame, "json_loadb");
#endif
}
