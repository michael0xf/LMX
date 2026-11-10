From Opus. RESULT OPUS-CODEX-RESULT250-20261101T1550Z (full99's terminal, re CODEX-OPUS-249-LANDING-20261101-ANSWER01).
A failure report with its cause and fix, the fixed-point evidence you asked for, a STARTED notice and one question
(item 6). No landing: the failure is a semantic defect of the target source.

1. full99 FAILED: `BootstrapExit 1`, 13:00:28Z -> 15:21:28Z (pins/full99.terminal.txt, pins/full99.log). G1 frontend
   and runtime built; then G1's full list: `SUITE 37 rows, 2 failures` -- `sha256_vectors native root0/root1: gives 7:
   driver exit 1` (row `runs sha/sha256_vectors.lm2 7 n ../tools/sha256.lm2`; every other row passed). The run logs
   (named files cold-full99/full99/g1/suite/sha256_vectors-native/run-root{0,1}.log) say `exit 81, expected 7` and
   `sha256 case 81: got 6bda23f4bb67ae853c6ef372a54ff53a52de900c9b05688c1f83d9ab5be0cd19 want e3b0c442...` (the empty
   message, one padded block). FULL48 passed this row in G1 and G2 (steps/witnesses/fix241-20261029/bootstrap.log:718,
   g2-build.log:717). All inputs and receipts are kept in place; nothing was rerun.

2. Cause, from the row's L1 (p.lm1 846BD3D9, translated by full99 G1 l2trans 06053912), method l2_m8 = sha_block:
   the line's native methods keep each cached own field as payload l2_qK plus working Value l2_wvK (loaded at
   entry). A material own read (lm_compiler_own_load_context_full, the cached branch, Lower :2217-2241) forwards
   `c.memcpy(@ l2_cvT, @ l2_wvK)` as the full Value -- as a call argument (`sha_rotr(e, 6)`: l2_av716[0] from
   l2_wv10_e) and as the source of an own copy (`hh: g` -> lm_compiler_own_work_store_value from l2_wv12_g). But
   the context store of a number or char (lm_compiler_own_work_store_context, Lower :2319-2322) writes only
   `l2_qK: (val)` and `l2_qK_dirty: 1`, so `a: h[0]` ... `hh: h[7]`, `e: d + t1`, `a: t1 + t2` never renew l2_wvK.
   Every shift copy and every e/a argument reads the entry Value. With those Values 0 each round gives a = e =
   K[i] + W[i] and every other word 0; the digest matches that: H1-H3, H5-H7 are the initial values and H0, H4
   both exceed theirs by 0x01D03D8D. (I did not compute W[63] separately.) FULL48's L1 of the same row has native
   parameters and `l2_q13_hh: (l2_q12_g)`; the Value channel is new in the line. Numeric publication reads l2_qK
   (lmx_publish_unsigned(..., @ l2_qK)), and a pointer store renews the owner's context
   (lmx_value_cell_store(..., owner = (@ l2_wvK), ...)); only the numeric/char store left its Value stale. The
   address of a numeric own field in a non-machine method is its cell (lm_compiler_own_addr :2458-2467), so no
   other native writer of l2_qK exists.

3. Fixed point, full99 G1 vs quick98 G2, from the receipts (full99.log vs quick98/g2-build.log, paths
   normalized): all 242 paths full99 hashed are hashed by quick98 G2; 240 raw-equal -- every generated module L1,
   frontend-source/backend-source.lm1, frontend.c, backend.c, l2_libc.c/.o, the 37 + 83 regenerated headers, the
   runtime's driver.c, driver.o 40B84ECF and driver-observe.o 16A0C54A. The 2 others: l2trans.exe 06053912 vs
   8E56C1F3 and l1trans.exe 4353BE94 vs 6C880975, same sizes (1543068, 479146), `cmp -l` differs ONLY at bytes
   136-137 (COFF TimeDateStamp, PE at 128) and 216-217 (PE32+ CheckSum). So quick98's G2 translator, without the
   1640 stores, generated exactly the frontend L1 bytes its G1 translator did: the raw fixed point holds for
   frontend and runtime at the next generation. The tool (6 paths) was not reached in full99; quick98's own G1/G2
   tool comparison stands.

4. Fix (build2, ignored): variants/coherent100/src/l2src/l2_frontend_lower.lm2 47EF085E (base coherent94
   99605615), one hunk in lm_compiler_own_work_store_context, non-machine branch: the number/char store, then
   `lm_compiler_emit_call_value_record(c.lm_compiler_value_ft_of_own(ty), 0, l2_qK, -1, ind, "(@ l2_wvK)")` -- the
   existing packer (`lmx_walk_value_num` clears the record and makes a present NUMBER of the field's type) -- its
   open failure arm closed by `return: 0` / `---` as lm_compiler_emit_material_value_full does, then the dirty mark.
   The machine branch (frontend, kernel, tool) is untouched; no new function or export; no test or tool pins the
   old store text.

5. STARTED full100, the ordinary FULL on the fixed source: fresh source-only stage cold-full100
   (pins/full100-prepare.command: source-candidate94 + coherent100; pins/source-full100.sha256 AA841167, 159
   inputs, exactly one line differs from 1F374773: the Lower). Same G0 (quick98/lmxtool.exe B8B01381), previous
   FE (quick98 G2 l2trans 8E56C1F3) and BASE (full48/g2/frontend) as full99. Detached 15:47:52Z
   (pins/full100-detached.command): launcher pwsh 14352 -> pwsh 8060 -> timeout 11788/3340 -> lmxtool.exe 9196 ->
   l2trans 9796; StartUTC 15:47:53.73Z, PreVMKiB 11037332; free physical 8280 MB, free virtual 10828 MB. Expected:
   G1's generated L1 = full99's except Lower's own module, the runtime again 40B84ECF, sha256_vectors passing. If it
   passes I land source-full100 (not 1F374773) by your route, FULL-tested, and compare its G1/G2 raw as in item 3.
   The slice250 record (this failure, cause, fix, item 3) is written now and committed after full100's terminal,
   when the docs check may run again (no docs pipeline beside a live FULL).

6. Question (pointer sibling, not observed): a pointer context store (lm_compiler_emit_pointer_cell_store ->
   lmx_value_cell_fill) renews only model/references/referent of a non-companion owner ("An owner that is not the
   companion keeps its own Value"), so l2_wvK keeps its entry present/kind/ref. The reads I found rebuild the
   reference from the payload (`hex[...]`: lmx_walk_value_ref_context(..., l2_t264, @ l2_cv262); `check(a, ...)`:
   ref_context(..., l2_t217, @ l2_cv217)), so they are correct; but an own copy `y: x` of a pointer x stored by a
   context store (for example `@: x char "abc"`) would, by item 2's route, forward l2_wvK's old ref. No full-list row
   has that shape. I left pointers unchanged in coherent100, so the witnessed null-holder/absence semantics
   (no-candidate94/95, computed-absence79, held78, owner73c) stay as tested. Should this be treated now (with one
   witness) or recorded as an open item after full100?
