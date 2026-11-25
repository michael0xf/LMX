#!/usr/bin/env python3
"""Reviewed CPU tensor subset; original upstream files are never modified."""
import hashlib
import sys
from pathlib import Path

src, out = map(Path, sys.argv[1:3])
with_tests = "--with-tests" in sys.argv[3:]
out.mkdir(parents=True, exist_ok=True)
expected = {"mint.h": "ce0fdf95e53673fd42cc62bdb85b4b0b232f1eb5df254857a87bd3bd0f09a3b2",
            "tests/tensor.c": "da3d56d941f6c47eebdef6b195960e9603fd29cda328dc66a2e49c7ae6a5a55b"}
if not with_tests:
    expected.pop("tests/tensor.c")
for name, digest in expected.items():
    if hashlib.sha256((src/name).read_bytes()).hexdigest() != digest:
        raise SystemExit("Mint differs from the reviewed snapshot: " + name)

def replace_once(text, old, new):
    if text.count(old) != 1:
        raise SystemExit("Unexpected Mint source layout: " + repr(old[:90]))
    return text.replace(old, new)

def guard_region(text, first, last):
    if text.count(first) != 1 or text.count(last) != 1:
        raise SystemExit("Unexpected Mint subset region")
    a = text.index(first)
    b = text.index(last, a) + len(last)
    return text[:a] + "#ifndef LMX_MINT_TENSORS_ONLY\n" + text[a:b] + "\n#endif /* LMX_MINT_TENSORS_ONLY */\n" + text[b:]

h = (src/'mint.h').read_text()
for name in ('mt_tensor', 'mt_layer', 'mt_model'):
    h = replace_once(h, 'typedef struct '+name+' {', 'struct '+name+' {')
    h = replace_once(h, '} '+name+';', '};')
# Existing generic broadcasting already handles rank padding. Select the
# specialized paths only for ranks they actually accept; never read inactive
# shape slots, and keep rank-zero scalar strides empty.
h = replace_once(h, '    int same_shape = 1;', '    int same_shape = (a->ndim == b->ndim);')
h = replace_once(h, '    for (int i = 0; i < ndim; ++i) {\n        if (a->shape[i] != b->shape[i]) {',
                 '    for (int i = 0; same_shape && i < ndim; ++i) {\n        if (a->shape[i] != b->shape[i]) {')
h = replace_once(h, '    if (b_numel == 1) {', '    if (b_numel == 1 && b->ndim <= a->ndim) {')
for dim in (1, 2, 3):
    h = replace_once(h, f'if (result_ndim == {dim}) {{',
                    f'if (result_ndim == {dim} && a->ndim == {dim} && b->ndim == {dim}) {{')
h = replace_once(h, 'static void mt__calc_strides(int *shape, int ndim, int *strides) {\n',
                 'static void mt__calc_strides(int *shape, int ndim, int *strides) {\n    if (ndim == 0) return;\n')
# This collection selects tensor operations. The model loader/runner and the
# dimensionally inconsistent adaptive-pooling helper are retained upstream,
# but are not part of the selected API. No inference algorithm is repaired.
h = guard_region(h, 'typedef struct mt_model mt_model;', 'MTDEF void              mt_layer_debug_info(mt_layer *l);')
a = h.index('struct mt_layer {')
b = h.index('#define MT_ARR_INT', a)
h = h[:a] + '#ifndef LMX_MINT_TENSORS_ONLY\n' + h[a:b] + '#endif /* LMX_MINT_TENSORS_ONLY */\n\n' + h[b:]
h = guard_region(h, 'MTDEF mt_tensor *mt_adaptive_avg_pool_2d(mt_tensor *x, int out_h, int out_w);',
                 'MTDEF mt_tensor *mt_adaptive_avg_pool_2d(mt_tensor *x, int out_h, int out_w);')
a = h.index('mt_tensor *mt_adaptive_avg_pool_2d(mt_tensor *x, int out_h, int out_w) {')
b = h.index('// Helper function to calculate the broadcasted shape', a)
h = h[:a] + '#ifndef LMX_MINT_TENSORS_ONLY\n' + h[a:b] + '#endif /* LMX_MINT_TENSORS_ONLY */\n\n' + h[b:]
a = h.index('typedef struct {\n    unsigned char *data;\n    size_t         pos;\n    size_t         size;\n} mt__reader;')
b = h.index('#endif // !__MT_IMPLEMENTATION', a)
h = h[:a] + '#ifndef LMX_MINT_TENSORS_ONLY\n' + h[a:b] + '#endif /* LMX_MINT_TENSORS_ONLY */\n\n' + h[b:]
(out/'mint.h').write_text(h)

if not with_tests:
    raise SystemExit(0)

t = (src/'tests/tensor.c').read_text()
t = replace_once(t, '#include "../mint.h"', '#include "mint.h"')
t = t.replace('\\e', '\\x1b')
t = replace_once(t, '    return 0;\n}\n\n// clang-format on', '    return s.failed ? 1 : 0;\n}\n\n// clang-format on')
old = 'MT_ASSERT_TEST("1D reduce min axis 0 shape (no keep)", mt_arr_same(output_no_keep->shape, MT_ARR_INT(1), 1, SZ_I));'
new = 'MT_ASSERT_TEST("1D reduce min axis 0 scalar rank (no keep)", output_no_keep->ndim == 0 && mt_tensor_count_element(output_no_keep) == 1);'
t = replace_once(t, old, new)
(out/'tensor.c').write_text(t)
