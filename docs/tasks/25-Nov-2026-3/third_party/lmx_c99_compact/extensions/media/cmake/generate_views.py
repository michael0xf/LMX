#!/usr/bin/env python3
"""Build-tree-only, checked C99 compatibility views; upstream stays intact."""
import sys
import re
import difflib
import hashlib
import json
import shutil
from pathlib import Path

src, out = map(Path, sys.argv[1:])
out.mkdir(parents=True, exist_ok=True)
changes = []


def write_changed(path, text):
    if not path.exists() or path.read_text() != text:
        path.write_text(text)


def emit(name, original, text):
    (out / name).parent.mkdir(parents=True, exist_ok=True)
    write_changed(out / name, text)
    changes.append({
        "view": name, "source": str(original.relative_to(src)),
        "original_sha256": hashlib.sha256(original.read_bytes()).hexdigest(),
        "view_sha256": hashlib.sha256(text.encode()).hexdigest()
    })
    write_changed(out / (name + ".patch"), "".join(difflib.unified_diff(
        original.read_text().splitlines(True), text.splitlines(True),
        fromfile=str(original.relative_to(src)), tofile=name)))


def replace_once(text, before, after):
    assert text.count(before) == 1, (before, text.count(before))
    return text.replace(before, after)


p = src / "jo_gif/jo_gif.cpp"
t = "#include <stdbool.h>\n#include <stdio.h>\n" + p.read_text()
assert t.count("= {}") == 2
t = t.replace("= {}", "= {0}").replace("#include <memory.h>", "#include <string.h>")
t = replace_once(t, "#ifndef JO_GIF_HEADER_FILE_ONLY", "#ifdef LMX_JO_GIF_IMPLEMENTATION")
emit("jo_gif.h", p, t)

p = src / "jo_mpeg/jo_mpeg.cpp"
t = "#include <stdio.h>\n" + p.read_text()
t = replace_once(t, "#ifndef JO_MPEG_HEADER_FILE_ONLY", "#ifdef LMX_JO_MPEG_IMPLEMENTATION")
emit("jo_mpeg.h", p, t)

p = src / "jo_mp1/jo_mp1.cpp"
t = "#include <stdbool.h>\n#include <stdio.h>\n" + p.read_text()
assert t.count("short *&output, int &outputSize, int &hz, int &channels") == 2
t = t.replace("short *&output, int &outputSize, int &hz, int &channels",
              "short **output, int *outputSize, int *hz, int *channels")
t = t.replace("int &at, int num", "int *at_ptr, int num")
a = t.index("static unsigned jo_readBits(")
b = t.index("\n}", a) + 2
t = t[:a] + re.sub(r"\bat\b", "(*at_ptr)", t[a:b]) + t[b:]
a = t.index("\nbool jo_read_mp1(")
a = t.index("{", a)
b = t.index("\n}", a) + 2
part = t[a:b]
for word in ["outputSize", "output", "channels", "hz"]:
    part = re.sub(r"\b" + word + r"\b", "(*" + word + ")", part)
part = re.sub(r"jo_readBits\(data,\s*at,", "jo_readBits(data, &at,", part)
part = part.replace("int(sum * 0x8000)", "(int)(sum * 0x8000)")
t = t[:a] + part + t[b:]
t = replace_once(t, "#ifndef JO_MP1_HEADER_FILE_ONLY", "#ifdef LMX_JO_MP1_IMPLEMENTATION")
emit("jo_mp1.h", p, t)

p = src / "minih264/minih264e.h"
t = p.read_text()
a = t.index("#if !defined(MINIH264_ONLY_SIMD)")
b = t.index("#define H264E_CONFIGS_COUNT", a)
t = t[:a] + """/* LMX C99 view: select the upstream scalar implementation. */
#define H264E_ENABLE_SSE2 0
#define H264E_ENABLE_NEON 0
#define H264E_ENABLE_PLAIN_C 1

""" + t[b:]
t = replace_once(t, "return H264E_STATUS_SUCCESS;\n};",
                 "return H264E_STATUS_SUCCESS;\n}")
emit("minih264e.h", p, t)

p = src / "pl_mpeg/pl_mpeg.h"
emit("pl_mpeg.h", p, "#include <stddef.h>\n#include <stdio.h>\n" + p.read_text())

# libwebp uses object addresses as function-pointer sentinel values.
# Real private functions of the same signature preserve sentinel semantics.
# This is a generated complete source view, for upstream relative includes.
_patched_webp = {"src/dsp/cpu.h", "sharpyuv/sharpyuv.c", "src/enc/vp8l_enc.c"}
def copy_original(source, destination):
    source, destination = Path(source), Path(destination)
    relative = source.relative_to(src / "libwebp").as_posix()
    if relative in _patched_webp and destination.exists():
        return str(destination)
    if not destination.exists() or source.read_bytes() != destination.read_bytes():
        shutil.copy2(source, destination)
    return str(destination)

shutil.copytree(src / "libwebp", out / "webp", dirs_exist_ok=True,
                copy_function=copy_original)
p = src / "libwebp/src/dsp/cpu.h"
t = p.read_text()
t = replace_once(t, "typedef int (*VP8CPUInfo)(CPUFeature feature);",
    """typedef int (*VP8CPUInfo)(CPUFeature feature);
/* LMX C99: private function pointer sentinel, never called. */
static inline int LmxWebpUninitializedCPUInfo(CPUFeature feature) {
  (void)feature;
  return 0;
}""")
assert t.count("(VP8CPUInfo)&func##_last_cpuinfo_used") == 2
t = t.replace("(VP8CPUInfo)&func##_last_cpuinfo_used", "LmxWebpUninitializedCPUInfo")
emit("webp/src/dsp/cpu.h", p, t)
p = src / "libwebp/sharpyuv/sharpyuv.c"
t = p.read_text()
t = t.replace("(VP8CPUInfo)&sharpyuv_last_cpuinfo_used", "LmxWebpUninitializedCPUInfo")
assert t.count("(VP8CPUInfo)&SharpYuvGetCPUInfo") == 2
t = t.replace("(VP8CPUInfo)&SharpYuvGetCPUInfo", "LmxWebpUninitializedCPUInfo")
emit("webp/sharpyuv/sharpyuv.c", p, t)
p = src / "libwebp/src/enc/vp8l_enc.c"
t = p.read_text()
assert t.count("&histo->category[kHistoPairs[*min_entropy_ix]") == 2
t = t.replace("&histo->category[kHistoPairs[*min_entropy_ix]",
              "(const HistogramBuckets*)&histo->category[kHistoPairs[*min_entropy_ix]")
emit("webp/src/enc/vp8l_enc.c", p, t)
write_changed(out / "views.json", json.dumps(changes, indent=2) + "\n")
