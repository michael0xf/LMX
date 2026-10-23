import sys
src, dst = sys.argv[1], sys.argv[2]
s = open(src, 'rb').read().decode()
anchor = "    if (lmx_implements_slot(l2_program_arena, l2_pst, l2_root_model0, 6U, &l2_dslot1) != 0) {"
assert s.count(anchor) == 1
dbg = (
    '    { size_t dbg_i; fprintf(stderr, "DBG176 value %p req %p reqsize %zu impl_len %zu\\n", (void*)l2_pst, (void*)l2_root_model0, l2_root_model0->array.size, l2_program_arena->impl_len);\n'
    '      for (dbg_i = 0; dbg_i < l2_program_arena->impl_len; dbg_i++) { LmxImplEntry *e = l2_program_arena->impl + dbg_i; if (e->value == l2_pst || e->req == l2_root_model0) { size_t q; fprintf(stderr, "DBG176 entry %zu value %p req %p reqsize %zu frame %p map %p n %zu holes %d proof %d map:", dbg_i, (void*)e->value, (void*)e->req, e->req ? e->req->array.size : 0, (void*)e->frame, (void*)e->map, e->n, e->holes, e->reception_proof); if (e->map) for (q = 0; q < 2*e->n; q++) fprintf(stderr, " %td", (ptrdiff_t)e->map[q]); fprintf(stderr, "\\n"); } } }\n'
)
s = s.replace(anchor, dbg + anchor)
open(dst, 'wb').write(s.encode())
print("ok")
