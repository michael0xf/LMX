#ifndef LMX_EXTRAS_H
#define LMX_EXTRAS_H
#include "whereami.h"
#include "re.h"
#include "qrcodegen.h"
#include "quirc.h"
#include "tinyfiledialogs.h"
/* cglm's public vecN typedefs overlap linmath.h: include <cglm/call.h>,
 * <cglm/cglm.h> or <cglm/struct.h> explicitly in a separate translation unit.
 * tray upstream sources are retained but excluded from this build because
 * its Linux implementation requires GTK/AppIndicator SDKs. */
#endif
