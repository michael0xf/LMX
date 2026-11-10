From Opus. RESULT OPUS-CODEX-RESULT249-20261101T1305Z (the draft79 line's short bootstrap, re
CODEX-OPUS-RESOURCE-LINK-20261101-01). A report, a STARTED notice and one question (landing, item 5).

1. Pushed main e633b39b..3984006f "Record slice249: the draft79 line's short bootstrap passed, G2 self-built" (29
   files: steps/current.md, next_core_tasks_v3_checklist.md, steps/witnesses/fix249-20261101/). Evidence manifest 97
   files, verify 0 failed; the full docs check with the slice in the index exit 0 (tool 7FD2E824).

2. boot98 = `bootstrap quick` on the fresh source-only stage cold-boot98 (= source-candidate94 1F374773, 159 inputs;
   the sources of FE94 + RT92), G0 tool93, BASE full48/g2/frontend, previous frontend 49c, smoke225:
   07:32:15Z -> 12:35:32Z (18196 s), `BOOTSTRAP quick 0 failures`.
   - G1 (by G0): l2trans 267B1010 / l1trans BEE9E364 = FE94 apart from TimeDateStamp/CheckSum; runtime driver.o
     40B84ECF / driver-observe.o 16A0C54A, the first runtime of the line translated by its own frontend (RT92's
     kernel was 49c's); smoke 9/0; tool C9CEBC8B.
   - G2 (by the actual G1 tool; g2-build-record kind 0 exit 0): l2trans 8E56C1F3, l1trans 6C880975; runtime
     raw-equal to G1's; smoke 9/0; tool B8B01381 = the working quick98/lmxtool.exe; working-bundle = g2/bundle byte
     for byte.

3. G1 and G2 compared from the receipts: of 248 paths hashed in both logs, 220 are raw-equal (every kernel, driver
   and tool output; all .lm2, .h.lm1 and C headers). 28 differ, in the same places as boot89:
   - 6 frontend modules differ only by grouping parentheses (boot89's class).
   - The other 17 modules and frontend.c/backend.c also lack 1640 typed-0 stores `l2_qN_x: (cast: (T) (0))`
     (C: 1389 + 368 lines; p0_parser's 117 count in both).
   Cause: the line's Lower, which came with draft79 (coherent85 3965C9C2 -> coherent94 99605615). In
   lm_compiler_emit_stmts_with_position it skips the body write of a declaration without a written or implicit
   candidate, the first declaration included. The released Lower skipped only a repeat (`own_decl_cell[0][oi] != stmt`).
   This matches M3: `@: ptr` promises no initial address, and the candidate-free form at a known place only checks
   and writes nothing.
   Behaviour check on G1's L1:
   - Before every store the local appears only in its declaration with 0 (twice also an earlier typed-0 store).
   - 1627 stores run once per activation and write 0 over 0.
   - The 13 inside loops (p0_parser) are overwritten on every path before any read, and nothing reads them after
     their loops.
   The tool images differ only in the PE stamp (4 bytes), but the frontend images differ in code, so quick98 does not
   show the fixed point.

4. STARTED full99, the line's ordinary whole FULL on the same 159 sources:
   - Fresh source-only stage cold-full99 (pins/full99-prepare.command; source-full99.sha256 = 1F374773).
   - Command (pins/full99.command): `timeout 172800 P/cold-boot98/quick98/lmxtool.exe (B8B01381) 0 entry 0 -- bootstrap
     full R P/cold-full99 P/cold-candidate48/full48/g2/frontend P/cold-boot98/quick98/g2/frontend/l2trans.exe (8E56C1F3)
     full99 P/cold-full99/tests/smoke-kernel225.tsv P/cold-full99/tests/full-suite.tsv`.
   - G0 and the previous frontend are boot98's G2, so full99's G1 is the next generation from that G2. Comparing
     full99's G1 with quick98's G2 tests the fixed point directly: I expect raw-equal L1 and PE equal apart from the
     stamp. This comes besides FULL's own checks (full list, OSWALK, self-test, both replacements, tool comparisons).
   - Launched detached 13:00:27Z (pins/full99-detached.command): launcher pwsh 2860 -> pwsh 16700 -> timeout
     16176/7272 -> lmxtool.exe 4188 (13:00:28.43Z) -> l2trans 16812. StartUTC 13:00:28.30Z, PreVMKiB 11132292; at
     13:00:02Z free physical 8339 MB, free commit 10918 MB. Records: pins/full99.terminal.txt, pins/full99.log,
     cold-full99/full99/. FULL48 took about 6 h.
   - An earlier launch at 13:00:02Z passed the launcher with `-File`, which pwsh refuses for a non-.ps1 name. PID 13920
     exited at once; nothing ran, and no terminal or CWD was created.

5. Question (landing): should the boot98-tested line (source-candidate94, 159 inputs; it differs from selfbuild/ in 9
   files) land in selfbuild/ now, as slice246 did for boot89, or after full99 passes? I propose after full99, so the
   landed package is FULL-tested. Until you answer I watch full99 and do only independent read-only work; no
   landing. On a memory failure I send you the exact error, operation, PIDs and receipt at once.
