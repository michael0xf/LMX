#!/usr/bin/env python3
"""Reproduce the retained C99 quadrature adapters; no downloads or build dependency.

Run after verifying provenance/*.json. The upstream source trees are untouched.
Ordinary CMake builds use the committed outputs and do not require Python.
"""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
INCLUDE = ROOT / "include"
SOURCE = ROOT / "src" / "quadrature"
SOURCE.mkdir(parents=True, exist_ok=True)


def header_names(text):
    return re.findall(r"^(?:long long int|double|float|int|void)\s*\**\s*([A-Za-z_]\w*)\s*\(", text, re.M)


def replace_names(text, names, prefix):
    pattern = re.compile(r"\b(" + "|".join(map(re.escape, names)) + r")\b")
    return pattern.sub(lambda match: prefix + match.group(), text)


def public_header(name, declarations):
    guard = "LMX_" + name.upper() + "_H"
    return (f"/* MIT-licensed upstream APIs, namespaced for the LMX collection.\n"
            f" * Original notices and sources are retained under vendor/. */\n"
            f"#ifndef {guard}\n#define {guard}\n"
            '#ifdef __cplusplus\nextern "C" {\n#endif\n' + declarations.strip() +
            '\n#ifdef __cplusplus\n}\n#endif\n#endif\n')


symbol_groups = {}
for module, header, prefix in [
        ("stroud_rule", "stroud_rule.h", "lmx_stroud_"),
        ("sparse_grid_hw", "sparse_grid_hw.h", "lmx_sparse_"),
]:
    text = (ROOT / "vendor" / module / header).read_text()
    names = header_names(text)
    assert names and len(names) == len(set(names))
    symbol_groups[module] = names
    text = text.replace(";;", ";")  # Upstream Stroud has one empty global declaration.
    text = re.sub(r"\(\s*\)", "(void)", text)
    text = replace_names(text, names, prefix)
    output = "lmx_stroud.h" if module == "stroud_rule" else "lmx_sparse_grid_hw.h"
    (INCLUDE / output).write_text(public_header(module, text))

cq = (ROOT / "vendor/cquadpack/include/cquadpack.h").read_text()
names = re.findall(r"^CQUADPACK_EXPORT (?:double|void)\s+(\w+)\s*\(", cq, re.M)
assert names.count("G_B15") == 1
# G_B15 is declared in the upstream header but has no implementation in v1.1.1.
names.remove("G_B15")
symbol_groups["cquadpack"] = names + ["dq_function_type"]
declarations = cq[cq.index("typedef double"):cq.index("#ifdef __cplusplus", cq.index("typedef double"))]
declarations = re.sub(r"CQUADPACK_EXPORT double G_B15\([^;]+;", "", declarations, flags=re.S)
declarations = declarations.replace("CQUADPACK_EXPORT ", "")
declarations = replace_names(declarations, names, "lmx_quadpack_")
declarations = declarations.replace("dq_function_type", "lmx_quadpack_dq_function_type")
(INCLUDE / "lmx_quadpack.h").write_text(public_header("quadpack", declarations))

original = (ROOT / "vendor/sobol/sobol.cpp").read_text()
header = (ROOT / "vendor/sobol/sobol.hpp").read_text()
names = header_names(header)
assert len(names) == 18
header = header.replace("string output_filename", "const char *output_filename")
header = replace_names(header, names, "lmx_sobol_")
(INCLUDE / "lmx_sobol.h").write_text(public_header("sobol", header))

text = original[original.index("//****************************************************************************80"):]
text = text.replace("string output_filename", "const char *output_filename")

# Replace the one C++ stream-based file writer with the equivalent C stdio loop.
start = text.index("void r8mat_write (")
body_start = text.index("\n{", start)
body_end = text.index("\n}\n", body_start) + 3
text = text[:body_start] + r'''
{
  FILE *output;
  int i, j;
  if (output_filename == NULL || table == NULL || m < 0 || n < 0) return;
  output = fopen(output_filename, "w");
  if (output == NULL) {
    fprintf(stderr, "R8MAT_WRITE: could not open output file.\n");
    return;
  }
  for (j = 0; j < n; ++j) {
    for (i = 0; i < m; ++i)
      fprintf(output, "  %24.16g", table[(size_t)i + (size_t)j * (size_t)m]);
    fputc('\n', output);
  }
  fclose(output);
}
''' + text[body_end:]

def output_statement(match):
    stream, expr = match.groups()
    parts = [part.strip() for part in expr.split("<<")]
    fmt = ""
    args = []
    for part in parts:
        if part.startswith('"') and part.endswith('"'):
            fmt += part[1:-1]
        else:
            fmt += "%lld"
            args.append("(long long)(" + part + ")")
    args_text = ", " + ", ".join(args) if args else ""
    return 'fprintf(' + ("stdout" if stream == "cout" else "stderr") + ', "' + fmt + '"' + args_text + ');'

text, count = re.subn(r"\b(cout|cerr)\s*<<\s*([^;]+);", output_statement, text)
assert count == 34, count
for dtype in ("float", "double"):
    old = f"r = new {dtype}[m*n];"
    assert text.count(old) == 1
    new = (f"if (m < 1 || m > 1111 || n < 1 || skip < 0 ||\n"
           f"      (size_t)n > SIZE_MAX / sizeof({dtype}) / (size_t)m) return NULL;\n"
           f"  r = malloc((size_t)m * (size_t)n * sizeof({dtype}));\n"
           f"  if (r == NULL) return NULL;")
    text = text.replace(old, new)
text = text.replace("r+m*j", "r+(size_t)m*(size_t)j")
# C++ std::min/std::max occur only in the integer uniform helper.
text = re.sub(r"\bmin\s*\(", "lmx_sobol_int_min(", text)
text = re.sub(r"\bmax\s*\(", "lmx_sobol_int_max(", text)
text = replace_names(text, names, "lmx_sobol_")

# The upstream sequence routines cache mutable direction/position state.
# Public sequence and bulk-generation calls serialize access to those caches.
protected = ["i4_sobol", "i4_sobol_generate", "i8_sobol", "i8_sobol_generate"]
prototypes = []
for name in protected:
    public_name = "lmx_sobol_" + name
    raw_name = public_name + "_impl"
    text = re.sub(r"\b" + public_name + r"\b", raw_name, text)
    text = re.sub(r"^((?:void|float\s*\*|double\s*\*)\s*" + raw_name + r"\s*\()", r"static \1", text, flags=re.M)
    declaration = next(line for line in header.splitlines() if re.search(r"\b" + public_name + r"\s*\(", line))
    prototypes.append("static " + declaration.replace(public_name, raw_name))

prefix = '''/* C99 adaptation of the retained MIT-licensed Burkardt Sobol C++ source.
 * Numerical direction tables and recurrence are unchanged.
 * Adaptation: C stdio/allocation, explicit namespaces, checked bulk allocation,
 * and POSIX serialization of the upstream mutable sequence caches.
 * Reproduce with tools/prepare_quadrature.py; see docs/QUADRATURE.md.
 */
#include <math.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <pthread.h>
#include "lmx_sobol.h"
static int lmx_sobol_int_min(int a, int b) { return a < b ? a : b; }
static int lmx_sobol_int_max(int a, int b) { return a > b ? a : b; }
''' + "\n".join(prototypes) + "\n"

suffix = '''
static pthread_mutex_t lmx_sobol_mutex = PTHREAD_MUTEX_INITIALIZER;

static void lmx_sobol_lock(void)
{
    if (pthread_mutex_lock(&lmx_sobol_mutex) != 0) abort();
}

static void lmx_sobol_unlock(void)
{
    if (pthread_mutex_unlock(&lmx_sobol_mutex) != 0) abort();
}

void lmx_sobol_i4_sobol(int dim_num, int *seed, float quasi[])
{
    lmx_sobol_lock();
    lmx_sobol_i4_sobol_impl(dim_num, seed, quasi);
    lmx_sobol_unlock();
}

void lmx_sobol_i8_sobol(int dim_num, long long int *seed, double quasi[])
{
    lmx_sobol_lock();
    lmx_sobol_i8_sobol_impl(dim_num, seed, quasi);
    lmx_sobol_unlock();
}

float *lmx_sobol_i4_sobol_generate(int m, int n, int skip)
{
    float *points;
    lmx_sobol_lock();
    points = lmx_sobol_i4_sobol_generate_impl(m, n, skip);
    lmx_sobol_unlock();
    return points;
}

double *lmx_sobol_i8_sobol_generate(int m, int n, int skip)
{
    double *points;
    lmx_sobol_lock();
    points = lmx_sobol_i8_sobol_generate_impl(m, n, skip);
    lmx_sobol_unlock();
    return points;
}
'''
assert not re.search(r"\b(?:cout|cerr|ofstream|new|delete|using)\b", re.sub(r"//[^\n]*", "", text))
(SOURCE / "sobol_c99.c").write_text(prefix + text + suffix)

cmake = ["# Explicit upstream external symbols, generated by tools/prepare_quadrature.py."]
for module, names in symbol_groups.items():
    cmake.append("set(_lmx_quad_" + module + "_symbols\n    " + "\n    ".join(names) + "\n)")
(ROOT / "cmake/QuadratureSymbols.cmake").write_text("\n".join(cmake) + "\n")
print({module: len(names) for module, names in symbol_groups.items()})
