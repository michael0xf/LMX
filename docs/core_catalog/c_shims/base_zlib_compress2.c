#include "lmx_catalog_bridge.h"

/* capi_0732eecb50673d02 | compress2
 * third_party/lmx_c99_compact/vendor/zlib/zlib.h:1292
 * ZEXTERN int ZEXPORT compress2 ( Bytef * dest , uLongf * destLen , const Bytef * source , uLong sourceLen , int level )
 */
#ifdef LMXC99_ENABLE_CAPI_0732EECB50673D02
/* The selected target must supply its real public header/config.
 * For generated .h.in or alternate profiles, override HEADER explicitly. */
#ifndef LMXC99_HEADER_CAPI_0732EECB50673D02
#define LMXC99_HEADER_CAPI_0732EECB50673D02 "zlib.h"
#endif
#include LMXC99_HEADER_CAPI_0732EECB50673D02
#endif
int lmx_bridge_compress2_0732eecb50673d02(void *opaque)
{
    lmx_catalog_frame *frame = (lmx_catalog_frame *)opaque;
#ifdef LMXC99_ENABLE_CAPI_0732EECB50673D02
    int rc;
    LMXC99_TYPE_CAPI_0732EECB50673D02_A0 a0;
    LMXC99_TYPE_CAPI_0732EECB50673D02_A1 a1;
    LMXC99_TYPE_CAPI_0732EECB50673D02_A2 a2;
    LMXC99_TYPE_CAPI_0732EECB50673D02_A3 a3;
    LMXC99_TYPE_CAPI_0732EECB50673D02_A4 a4;
    LMXC99_RESULT_CAPI_0732EECB50673D02 result;
    rc = lmx_catalog_check(frame, 5U);
    if (rc != LMXC_OK) return rc;
    rc = LMXC99_READ_CAPI_0732EECB50673D02_A0(frame, 0U, &a0);
    if (rc != LMXC_OK) return rc;
    rc = LMXC99_READ_CAPI_0732EECB50673D02_A1(frame, 1U, &a1);
    if (rc != LMXC_OK) return rc;
    rc = LMXC99_READ_CAPI_0732EECB50673D02_A2(frame, 2U, &a2);
    if (rc != LMXC_OK) return rc;
    rc = LMXC99_READ_CAPI_0732EECB50673D02_A3(frame, 3U, &a3);
    if (rc != LMXC_OK) return rc;
    rc = LMXC99_READ_CAPI_0732EECB50673D02_A4(frame, 4U, &a4);
    if (rc != LMXC_OK) return rc;
    /* All conversions are finished in lexical order before C evaluates its
     * argument expressions. CHECK validates cross-argument lengths, output
     * capacity, overlap, resource states and any per-operation domain rule. */
    rc = LMXC99_CHECK_CAPI_0732EECB50673D02(frame);
    if (rc != LMXC_OK) return rc;
    result = compress2(a0, a1, a2, a3, a4);
    return LMXC99_SAVE_CAPI_0732EECB50673D02(frame, result);
#else
    return lmx_catalog_review_required(frame, "compress2");
#endif
}
