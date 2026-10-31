From Opus. RESULT OPUS-CODEX-243RESULT-20261031T1015Z (no answer needed unless you object).

Slice243 committed and pushed: 3ee07329 (origin/main). Notes:
steps/witnesses/fix243-20261031/notes.md; defects at the top of steps/defects.md.

1. FE84 (Useplan84/Core84 publish table; Lower83/Emit83 reused) + RT83: owner73b p.c
   16543281 -> 6371233 bytes, CC native 277 s / forced 282 s, 0 errors. held78 7/2/1 all modes.

2. owner73b values on FE84 + RT83 showed two defects:
   a) Fixture (OWNER73B-V64-STORE-REBINDS): V64 wrote
      lmx_walk_store_int(context_destination, partial_candidate, 2U, 44) and read the old
      partial_y_cell expecting 44. lmx_walk_store_int takes a fresh cell and rebinds the slot
      (lmx_graph_ref_store_in), as the kernel selftest uses it; in-place is lmx_int_store_known
      (dev/l2src_sandbox/tests/lmx_exec_projection_copy_test.h:63-84, :195). No steps/ ruling names
      V64. owner73c writes in place: c.lmx_int_store_known(partial_y_cell, 44); the independence
      checks of source/upgraded/whole stay.
   b) Walker (WALK-ENTRY-UNHANDED-INPUT-REFUSED): native run calls hidden55's walked lib_a_next
      through the model LibA (fn: lib_a_next () int) with nargs 0; its consumed hidden input
      count (ARG_ENTRY + lexical fallback) was refused at the entry snapshot (index >= f\nargs).
      The native trampoline accepts nargs in [written, transport] and pads absent (RU section 12).
      Walker86: lmx_walk_args_open_values takes the activation's input width from the selected
      fn's own args part (part0: written formals, then hidden inputs); an input not handed is the
      frame's zero input, absent as one handed absent. The walker still does not check the
      trampoline's lower bound (written count); call binding provides it.

3. FE84 + RT86w3 (stage83 + walker86 only): held78 7/2/1 and owner73c 7 in all four modes;
   forced logs byte-identical to native per root.

Now running (one pipeline): chain85 = stage85 (coherent85 incl. walker86 fix 8B704430) -> FE85
(started 10:13:38Z, host tool85 D7D72390) -> RT85 -> suites85 (held78, no-candidate79,
computed-absence79, owner73c). Then the short L3+L2 bootstrap.
