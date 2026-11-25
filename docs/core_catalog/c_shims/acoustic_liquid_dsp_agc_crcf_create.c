#include "lmx_catalog_bridge.h"

/* capi_40b8c998b630a923 | agc_crcf_create
 * third_party/lmx_c99_compact/vendor/liquid_dsp/include/liquid.h:834
 * agc_crcf agc_crcf_create ( void )
 */
#ifdef LMXC99_ENABLE_CAPI_40B8C998B630A923
/* The selected target must supply its real public header/config.
 * For generated .h.in or alternate profiles, override HEADER explicitly. */
#ifndef LMXC99_HEADER_CAPI_40B8C998B630A923
#define LMXC99_HEADER_CAPI_40B8C998B630A923 "liquid.h"
#endif
#include LMXC99_HEADER_CAPI_40B8C998B630A923
#endif
int lmx_bridge_agc_crcf_create_40b8c998b630a923(void *opaque)
{
    lmx_catalog_frame *frame = (lmx_catalog_frame *)opaque;
#ifdef LMXC99_ENABLE_CAPI_40B8C998B630A923
    int rc;
    LMXC99_RESULT_CAPI_40B8C998B630A923 result;
    rc = lmx_catalog_check(frame, 0U);
    if (rc != LMXC_OK) return rc;
    /* All conversions are finished in lexical order before C evaluates its
     * argument expressions. CHECK validates cross-argument lengths, output
     * capacity, overlap, resource states and any per-operation domain rule. */
    rc = LMXC99_CHECK_CAPI_40B8C998B630A923(frame);
    if (rc != LMXC_OK) return rc;
    result = agc_crcf_create();
    return LMXC99_SAVE_CAPI_40B8C998B630A923(frame, result);
#else
    return lmx_catalog_review_required(frame, "agc_crcf_create");
#endif
}
