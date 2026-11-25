/* LMX renderer integration; original Sokol headers are unchanged. */
#define SOKOL_IMPL
#include "lmx_sokol_backend.h"
#include "sokol_args.h"
#include "sokol_time.h"
#include "sokol_log.h"
#include "sokol_fetch.h"

sg_backend lmx_sokol_compiled_backend(void) {
#if defined(SOKOL_GLCORE)
    return SG_BACKEND_GLCORE;
#elif defined(SOKOL_GLES3)
    return SG_BACKEND_GLES3;
#elif defined(SOKOL_VULKAN)
    return SG_BACKEND_VULKAN;
#else
#error "Select a real Sokol renderer backend"
#endif
}
