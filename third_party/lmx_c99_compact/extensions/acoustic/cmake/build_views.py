#!/usr/bin/env python3
"""Pinned, fail-closed C99/POSIX views; complete vendor trees stay unchanged."""
import difflib
from pathlib import Path
import re
import shutil
import sys

vendor, output = map(Path, sys.argv[1:])
liquid = vendor / "liquid_dsp"
quiet = vendor / "quiet"
output.mkdir(parents=True, exist_ok=True)
patches = []


def view(source, destination, replacements):
    original = source.read_text()
    modified = original
    for old, new, count in replacements:
        actual = modified.count(old)
        if actual != count:
            raise RuntimeError(f"{source}: expected {count} copies of {old!r}, got {actual}")
        modified = modified.replace(old, new)
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(modified)
    if original != modified:
        patches.extend(difflib.unified_diff(original.splitlines(True), modified.splitlines(True),
            fromfile=str(source.relative_to(vendor)), tofile=str(destination.relative_to(output))))


# Both public error macros accept a format argument. Put it inside __VA_ARGS__
# to avoid the GNU comma-swallowing extension with an empty variadic tail.
include = output / "liquid_include"
view(liquid / "include/liquid.h", include / "liquid.h", [
    ("#define liquid_error(code, format, ...)", "#define liquid_error(code, ...)", 1),
    ("liquid_error_fl(code, LIQUID_FILENAME, __LINE__, format, ##__VA_ARGS__);",
     "liquid_error_fl(code, LIQUID_FILENAME, __LINE__, __VA_ARGS__);", 1),
    ("#define liquid_error_config(format, ...)", "#define liquid_error_config(...)", 1),
    ("liquid_error_config_fl(LIQUID_FILENAME, __LINE__, format, ##__VA_ARGS__);",
     "liquid_error_config_fl(LIQUID_FILENAME, __LINE__, __VA_ARGS__);", 1),
])
(include / "liquid").mkdir(exist_ok=True)
shutil.copyfile(include / "liquid.h", include / "liquid/liquid.h")
view(liquid / "include/liquid.internal.h", include / "liquid.internal.h", [
    ("void *    _callback);", "int (*_callback)(void *, TO *, unsigned int));", 1),
])

# Upstream already provides this POSIX implementation alongside timespec_get.
view(liquid / "src/core/src/logging.c", output / "liquid/logging.c", [
    ("#include <time.h>", "#include <time.h>\n#include <inttypes.h>", 1),
    ("#if 0\n    clock_gettime(CLOCK_REALTIME, &(_q->timestamp));",
     "#if 1 /* C99 + POSIX: use the upstream clock_gettime branch. */\n    clock_gettime(CLOCK_REALTIME, &(_q->timestamp));", 1),
    ('#include "liquid.internal.h"', '''#include "liquid.internal.h"

/* Preserve strsep's empty-field behavior using standard C99 string functions. */
static char *lmx_liquid_strsep(char **cursor, const char *delimiters)
{
    char *field = *cursor, *end;
    if (!field) return NULL;
    end = field + strcspn(field, delimiters);
    if (*end) { *end = '\\0'; *cursor = end + 1; }
    else *cursor = NULL;
    return field;
}''', 1),
    ('strsep(&s, ",")', 'lmx_liquid_strsep(&s, ",")', 1),
    ('snprintf(_q->time_str, 64, "%ld", _q->timestamp.tv_sec)',
     'snprintf(_q->time_str, 64, "%" PRIdMAX, (intmax_t)_q->timestamp.tv_sec)', 1),
])

# MinGW has POSIX clocks and pthreads, but no sys/resource.h/getrusage.
# Preserve process user+kernel CPU-time semantics with GetProcessTimes;
# never substitute wall-clock time for LIQUID_TIMER_RUSAGE.
view(liquid / "src/core/src/timer.c", output / "liquid/timer.c", [
    ("struct rusage", "lmx_liquid_rusage", 2),
    ("#include <sys/resource.h>", '''#ifdef _WIN32
#include "liquid_win32_resource.h"
#else
#include <sys/resource.h>
typedef struct rusage lmx_liquid_rusage;
static int lmx_liquid_getrusage(lmx_liquid_rusage *result)
{
    return getrusage(RUSAGE_SELF, result);
}
#endif''', 1),
    ("        getrusage(RUSAGE_SELF, &_q->tic_rusage);",
     '''        if (lmx_liquid_getrusage(&_q->tic_rusage))
            return liquid_error(LIQUID_EINT, "liquid_timer_tic(), process CPU timer failed");''', 1),
    ("        getrusage(RUSAGE_SELF, &toc);",
     '''        if (lmx_liquid_getrusage(&toc)) {
            liquid_error(LIQUID_EINT, "liquid_timer_toc(), process CPU timer failed");
            return -1;
        }''', 1),
])
shutil.copyfile(Path(__file__).resolve().parents[1] / "compat/liquid_win32_resource.h",
                output / "liquid/liquid_win32_resource.h")

# Three opaque, internal empty structs are GNU extensions. A reserved byte
# preserves each enclosing union's size. Keep callback pointers typed throughout.
for module, unit in (("framing", "framingcf.c"), ("modem", "modemcf.c")):
    destination = output / "liquid" / module
    destination.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(liquid / "src" / module / "src" / unit, destination / unit)
view(liquid / "src/framing/src/msource.proto.c", output / "liquid/framing/msource.proto.c", [
    ("QSOURCE(_init_user)(s, _userdata, (void*)_callback);",
     "QSOURCE(_init_user)(s, _userdata, _callback);", 1),
])
view(liquid / "src/framing/src/qsource.proto.c", output / "liquid/framing/qsource.proto.c", [
    ("struct { } tone;", "struct { char reserved; } tone;", 1),
    ("struct { } noise;", "struct { char reserved; } noise;", 1),
    ("void *    _callback)", "MSOURCE(_callback) _callback)", 1),
    ("_q->source.user.callback = (MSOURCE(_callback))_callback;",
     "_q->source.user.callback = _callback;", 1),
])
view(liquid / "src/modem/src/cpfskdem.proto.c", output / "liquid/modem/cpfskdem.proto.c", [
    ("// coherent demodulator\n        struct {",
     "// coherent demodulator\n        struct {\n            char reserved; /* C99 forbids an empty struct. */", 1),
])

# Extract every object-library source from the exact tagged upstream manifest.
# No module selection, C++ language enablement, SIMD probe, or external FFT find.
cmake = (liquid / "CMakeLists.txt").read_text()
groups = re.findall(r"^add_library\((\w+) OBJECT\s+(.*?)\)", cmake, re.M | re.S)
if len(groups) != 22:
    raise RuntimeError(f"Expected all 22 upstream core groups; got {len(groups)}")
sources = ["src/libliquid.c"]
for name, body in groups:
    source_group = re.findall(r"src/[^\s)]+\.c", body)
    if not source_group:
        raise RuntimeError(f"Empty source group {name}")
    sources.extend(source_group)
if len(sources) != len(set(sources)):
    raise RuntimeError("Duplicate official source entries")
with (output / "LiquidSources.cmake").open("w") as out:
    out.write("# All C sources from upstream v1.8.3's 22 core object libraries.\nset(_lmx_liquid_sources\n")
    for source in sources:
        substitutions = {
            "src/core/src/logging.c": output / "liquid/logging.c",
            "src/core/src/timer.c": output / "liquid/timer.c",
            "src/framing/src/framingcf.c": output / "liquid/framing/framingcf.c",
            "src/modem/src/modemcf.c": output / "liquid/modem/modemcf.c",
        }
        path = substitutions.get(source, liquid / source)
        if not path.is_file():
            raise RuntimeError(f"Missing {path}")
        out.write(f'  "{path.as_posix()}"\n')
    out.write(")\n")

# Quiet's opaque resampler handle is private. Its public quiet.h API is kept.
# Only the removed fork-specific resampler operation needs an adapter.
quiet_view = output / "quiet"
shutil.copytree(quiet, quiet_view, dirs_exist_ok=True)
for rel in ("include/quiet/encoder.h", "include/quiet/decoder.h", "src/encoder.c", "src/decoder.c"):
    source = quiet / rel
    original = source.read_text()
    replacements = [("resamp_rrrf", "lmx_quiet_resamp", original.count("resamp_rrrf"))]
    if rel == "src/encoder.c":
        replacements.append(("if (e->samplebuf_len > 0) {",
            "if (e->samplebuf_len > 0 || lmx_quiet_resamp_pending(e->resampler)) {", 1))
        replacements.append((
            "int finished = gmskframegen_write_samples(e->frame.gmsk.framegen, e->symbolbuf + i);\n            if (finished) {\n                break;",
            "int finished = gmskframegen_write(e->frame.gmsk.framegen, e->symbolbuf + i, e->frame.gmsk.stride);\n            if (finished) {\n                i += e->frame.gmsk.stride;\n                gmskframegen_reset(e->frame.gmsk.framegen);\n                break;", 1))
    if rel == "src/decoder.c":
        replacements.append(("for (size_t i = 0; i < sample_len; ) {",
            "for (size_t i = 0; i < sample_len || lmx_quiet_resamp_pending(d->resampler); ) {", 1))
    view(source, quiet_view / rel, replacements)
view(quiet / "include/quiet/common.h", quiet_view / "include/quiet/common.h", [
    ("#include <liquid/liquid.h>", '#include <liquid/liquid.h>\n#include "quiet_resampler.h"', 1),
])
# Make ssize_t's POSIX declaration explicit for standalone public consumers.
view(quiet / "include/quiet.h", quiet_view / "include/quiet.h", [
    ("#include <stdlib.h>", "#include <stdlib.h>\n#include <sys/types.h>", 1),
])
view(quiet / "src/ring_blocking.c", quiet_view / "src/ring_blocking.c", [
    ("pthread_cond_destroy(&w->cond);\n}",
     "pthread_cond_destroy(&w->cond);\n    free(w); /* Match ring_wait_create's allocation. */\n}", 1),
])
(output / "compatibility.diff").write_text("".join(patches))
print(f"Liquid-DSP: {len(groups)} complete modules, {len(sources)} C translation units; one shared engine")
