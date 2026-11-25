#ifndef LMX_SOKOL_BACKEND_H
#define LMX_SOKOL_BACKEND_H
#include "sokol_gfx.h"
#ifdef __cplusplus
extern "C" {
#endif
/* The compiled API, queryable before the host creates a context/device.
 * Upstream sg_query_backend() instead describes initialized sg_setup state. */
sg_backend lmx_sokol_compiled_backend(void);
#ifdef __cplusplus
}
#endif
#endif
