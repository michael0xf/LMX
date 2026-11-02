# Slice 259 (2026-11-02): B2b-2b of the optimization line -- the bitwise and shift operators as executable operations of the kernel's one shared binary operation; the walker's five codes (tp121, boot121a)

Writer/build: fable_pc (Opus waits; Codex coordinates, no ACK gate).  Previous slice: [258](../fix258-20261102/notes.md)
(B2b-2a: the runtime-typed deref, write and address of a free name, the `sub` defect; landed 12cac7fc + 443bdff8 + 92b39c5a;
Codex's independent confirmation of ~18:33Z, verbatim there: «P1-PTR-COVERAGE остаётся OPEN … Следующие bit/shift, model
admission, coverage, closures/C — как план, без нового design gate/повторного запуска зелёного.  Норму @free снова не обсуждаем и
origin-alias не возвращаем.  Opus ждёт, Codex goal paused»).  Design: `optimization_design_from_fable.md` revision 20 (the
header note; §4.5 «Реализация B2b-1»: the Реализовано (B2b-2b) / Остаётся (B2b-2c) passage).  No Codex message was needed
during this slice: it runs on the standing confirmation above; the RESULT message follows the landing (archived below).

## The step

The ledger `BITWISE-OPERATORS-NOT-CLASSIFIED` (steps/defects.md: Verified170 made one operator list `l2_rw_prec` and C's
operators in the native engine) left OPEN: the walker's evaluation (a body with `& | ^ << >>` stayed native under
`--walk-methods` -- `l2_rw_machine`, «retained machine operation has no interpreted implementation» -- so the witness never
exercised the walker), the refusal before C's operation in both engines for a shift count outside [0, width) and an
overflowing signed left shift, and unary `~`.  Slice 255 (B2a) made the arithmetic over a free operand one shared kernel
operation, `lmx_walk_value_bin`, and left the machine operators behind a located refusal («a runtime-typed value in a machine
operation (B2b …)»).  Design revision 18 planned a separate `lmx_walk_value_machine`; this slice extends `lmx_walk_value_bin`
instead -- one operation list, one promotion, one refusal path, one call printed by the native code, no new export -- with
five new walker codes (`LMX_WALK_OP_BAND 58`, `BOR 59`, `BXOR 60`, `SHL 61`, `SHR 62`; `LMX_WALK_OP_COUNT 63`).  The codes live
in `tools/build.lm2` (`decl_walk`, the generated `lmx_walk.h.lm1`): a tools change, so the candidate's rebuilt tool tool121 is
the tool of every step and the G0 of the bootstrap (as tool120 was in slice 258).

Semantics (the machine contract, L2 §17 and §21; C99): `& | ^` take two operands of one promoted type -- a contextual literal
takes the other operand's type, two numbers of different types are the implicit `convert` (as the arithmetic); a shift's
operands are promoted apart (C99 6.5.7) -- the result has the left's promoted type, the count keeps its own, a contextual left
literal is an int or an unsigned by its suffix, and the contextual-literal rule does not act across a shift (neither in the
walker nor in the native runtime-typed expression); a count outside [0, width of the left's type) and a signed left shift that
does not fit (a negative left, a bit carried past the sign) are the implicit `interpreter` throw BEFORE the operation, as a
signed ADD's overflow (the ledger's wording: «отказ до операции C в обоих движках, как у знакового ADD»); unsigned shifts wrap
modulo the width; a right shift of a negative int is the platform's (C99 implementation-defined), as the native engine's
operator.  The width is the bit count of the type's largest value (`lmx_type_width`: `UINT_MAX`, `SIZE_MAX`, `ULONG_MAX`,
`UCHAR_MAX` counted down -- 32 for int/unsigned, 64 for size_t on this platform), not a `sizeof` spelling.

### What the slice changes

- `tools/build.lm2` (`decl_walk`): the five `define:` lines and `LMX_WALK_OP_COUNT 63` in the generated kernel header
  `lmx_walk.h.lm1` (the OP record encodes `source * OP_COUNT + opcode`; every generation of the line is rebuilt from these
  sources, so the renumbering is total).  No new export: `lmx_walk_value_bin` is already in `walk_value_names`.
- `src/l2src/lmx_walk_values.lm2`: `lmx_type_width` (new, before its first use); `lmx_walk_native_int_bin_apply` -- BAND/BOR/BXOR
  on the promoted ints as C's, SHL/SHR with the count range and the signed left-shift overflow refusals (`left < 0 || left >
  (INT_MAX >> right)`), `>>` as C's; `lmx_walk_value_bin` -- the operation list, a shift's operands promoted apart (a NONE-typed
  left literal → int, or unsigned by `natural`; the count's size_t value checked against the left's width, so a negative count
  is outside; then `b: a`), the unsigned path `ua & ub`, `ua | ub`, `ua ^ ub`, `ua << ub`, `ua >> ub` stored by the result's
  type (`lmx_walk_store_numeric_raw` truncates: modulo the width); `lmx_walk_shape_min` -- the five codes are width 3;
  `lmx_walk_eval` -- the five codes evaluate as ADD…EQ do, the contextual-literal marking skipped for SHL/SHR.
  `lmx_walk_native_int_bin_check` (the retained integer sites of the native engine) keeps its list: a machine operator has no
  retained integer site.
- `src/l2src/l2_frontend_lower.lm2` (`lm_compiler_emit_dyn_values_full`): the located refusal of B2a is replaced by the code
  selection `&` BAND, `|` BOR, `^` BXOR, `<<` SHL, `>>` SHR; the printed call is the same `lmx_walk_value_bin(code, left, right,
  @ l2_dvN)` with the same fault handling (`interpreter`, `convert`, a malformed operand).  The typed native path
  (`lm_compiler_emit_native_values_full`) is unchanged: C's operator in place.
- `src/l2src/l2_frontend_emit.lm2` (`lm_compiler_rw_machine_bitwise`): a real frame `[op, left, right]` (`rw_frame(parent, code,
  3, out)`, the left typed by the expression's type, the count by its own `rw_tyof`) instead of `lm_compiler_rw_machine_operator`
  (a `LMX_WALK_OP_SOURCE_MACHINE` frame, inert for the walker, and `l2_rw_machine = 1`, which made the whole body non-walkable).
  `rw_machine_operator` remains for the other machine constructs (pointer arithmetic `rw_machine_offset`, machine functions,
  casts, declarations), whose bodies stay native with the old reason.  The refusals «a bitwise operation on a reference» and
  «mixed numeric types (a conversion)» for a shift count stay.
- `tests/dyn/free_machine_ops.lm2` (new; `runs	dyn/free_machine_ops.lm2	7	nf` in `tests/full-suite.tsv` with its comment):
  `quote` bound by the callers as unsigned (`outer_bits`: mask `& 0x0FF0U` → 0x0230, pick `| 1U`, flip `^ 0xFFFFU`, shifted(4)
  `<< n` → 0x12340, masked_by(0xFF00U) `& m`, the sub `widen` writing `quote: quote << 1` (Q52: the caller keeps 0x1234),
  shifted(32) → `interpreter` caught → 90U; 81..87), int (`outer_ints`: low_bits `& 7` on −6 → 2, both_free `quote | marks` with
  `marks` a lexical source (3) → −5, halved(1) `>> n` on 6 → 3, doubled(2) → 24, one_shifted `1 << quote` → 32, halved(−1) →
  `interpreter` → 93, doubled(1) on 1073741824 → `interpreter` → 95, doubled(1) on −6 → `interpreter` → 97, masked_by(255U) on an
  int → `convert` → 99U; 88..99) and size_t (`outer_wide`: wide_shift(40) `<< n` → 2^40, wide_shift(64) → `interpreter` → 101U;
  100..102); `typed_walked(171U, 4)` `(a & 0xF0U) >> n` → 10 (103) -- the typed walked path.  Entry 7.
- `tests/bits/bit_values.lm2`: the header's two lines (two lines) now say that `bits` and `ints` are walked under
  --walk-methods since this slice (before: «stays native: the walker does not evaluate these operators yet»).

Not changed, noted: the driver's `shape_op_code` word table (`l2_driver.lm2`: the shape probe's names → codes) does not list the
five new codes; a mutation of a machine operator's frame through the debug API is now a mutation of a physical OP, which the
walked body follows and the native body (C's operator, no site) does not -- the same inertness the SOURCE_MACHINE frame had.

### The candidate and its checks before the bootstrap (records in `pins/`, LF copies in [records/](records/))

Variant `variants/tp121` = the landed selfbuild (source-tp120 `55C1CC2D…`) with the 6 changed files and the new fixture;
`inputs.list` 165 lines (`tests/dyn/free_machine_ops.lm2` after `free_pointer_paths.lm2`).  Changed bytes (tp121-changed-fix01):
lmx_walk_values `7cdb7085…` (was `80c31f27…`), l2_frontend_lower `8965a881…` (`c8716c5b…`), l2_frontend_emit `281a5bef…`
(`63fd4428…`), tools/build.lm2 `46ec8d7b…` (`2ce67b32…`), tests/full-suite.tsv `df6638cf…` (`eb886770…`), tests/bits/bit_values.lm2
`8f5f0d07…` (`c26ec45a…`), tests/dyn/free_machine_ops.lm2 `fbf69604…` (new).

| step | record | result |
|---|---|---|
| stage | `tp121-prepare.command` TP_TRY=fix01 (19:09:44Z) | cold-tp121 = selfbuild + the 7 listed files; source-tp121 `BBCCB259…` (165 lines; exactly 13 manifest lines differ from source-tp120) |
| reuse set | `tp121-reuse.command` (19:09:50Z) | the 232 generated inputs of cold-boot120a (the landed generation) staged; the kernel headers among them predate tp121 |
| tool | `tp121-tool.command` TP_TRY=01 (19:09:51–19:11:56Z) | `rebuild tool` with boot120a's G2 frontend `F616D36F…` and runtime objects: tool121 `7F9C3DBB…`; `REBUILD tool 0 failures` (the smoke list through the new tool) |
| runtime | `tp121-rt.command` rt121/01 (19:13:40–19:14:36Z) | `build-runtime` by tool121: `HEADERS 84 regenerated` -- `lmx_walk.h.lm1` now `LMX_WALK_OP_BAND 58 … LMX_WALK_OP_COUNT 63`; the kernel's L2 and C compile pass; driver.o `5518FAD8…`, driver-observe.o `42EAD943…` |
| frontend | `tp121-fe.command` fe121/01 (19:14:53–19:20:38Z) | `build-frontend` by tool121 with boot120a's G2 as the previous frontend: every module translates, l2trans.exe `310A6920…` |
| focus suite | `tp121-suite.command` fe121+rt121/01 (19:20:49–19:21:58Z), list `focus121.tsv` | 12 rows, 0 failures: the two twins, os_walk_values, the three bits rows (bit_values runs 7 natively and forced; the two refusals say their needles), the five dyn fixtures of slices 254–258 and `free_machine_ops` (7 natively and forced, both roots) |
| observed walk | `tp121-obs.command` 01: `bits/bit_values.lm2` spec `run=1,bits=1,ints=1` (19:23:44Z) | natively no walked body; forced: the bodies of run, bits and ints walked once at both roots -- the ledger's walker part witnessed |
| observed walk | `tp121-obs.command` 02: `dyn/free_machine_ops.lm2`, 15 names (19:23:59Z) | forced: m, outer_bits, outer_ints, outer_wide, mask, low_bits, one_shifted, both_free, widen, typed_walked walked 1; shifted, masked_by, halved, wide_shift 2; doubled 3 -- every caller and callee walked, the results the entry at both roots; natively none walked |

One stage refresh, one tool, one runtime, one frontend, one suite, two observed walks: no fix was needed after fix01.

## boot121a, the fixed point, the focus suite on G2, the landing

| step | record | result |
|---|---|---|
| stage | `boot121-prepare.command` TP_TRY=a (19:22:38Z) | cold-boot121a = exactly source-tp121 (165 inputs; `source-boot121a.sha256` = `source-tp121.sha256` `BBCCB259…`); no generated input |
| bootstrap | `boot121-detached.command` → `boot121-quick.command` TP_TRY=a (19:24:13–19:42:15Z, 1082 s) | `bootstrap quick`: G0 = tool121 `7F9C3DBB…`, BASE full48/g2/frontend, previous frontend boot120a's G2 `F616D36F…`; G1 built and tested by G0 (`SUITE 9 rows, 0 failures`, `GENERATION quick … g1 0 failures`), G2 built and tested by G1; `BOOTSTRAP quick 0 failures`; the working tool quick121a/lmxtool.exe = G2's `4DD5D706…` |
| G1 = G2 | `boot121-compare.command` TP_TRY=a → `boot121a-compare.txt` (19:42:45Z; the record's stdout label still reads COMPARE120a, the file's header boot121a) | 248 receipt paths in both generations, 245 raw-equal, 3 differ: the PE images l1trans.exe, l2trans.exe, lmxtool-tool.exe at bytes 136–137 and 216–217 only (the link stamp TimeDateStamp and CheckSum); G2's driver.o `5518FAD8…` and driver-observe.o `42EAD943…` are byte-equal to the isolated rt121's |
| focus suite on G2 | `tp121-suite-g2.command` (19:42:46–19:43:55Z), list `focus121.tsv` | 12 rows, 0 failures on G2's frontend `2537E3B3…` and runtime objects, by the promoted working tool |
| landing | `land259.command` (19:44Z) | source-tp121 verified in cold-boot121a and stage-copied over `selfbuild/` (165 paths); the variant's `inputs.list` copied; `selfbuild/inputs.sha256` rewritten and verified = `source-tp121.sha256` `BBCCB259…`; the 65 sources G1 and G2 retained in their consumed-input snapshots verified against the landed files (the two subsets equal) |

The landing follows the rule of Codex's answer to FABLE-RESULT-S3-20261102T0100Z (choice (a): the whole tested set after an
actual quick PASS, no FULL, no ACK): `selfbuild/` = source-tp121 -- the 6 changed inputs and the new fixture over source-tp120;
`selfbuild/README.md` and `steps/current.md` updated; the design revision 20; this record.  Relative to boot120a the landed tool
sources change (`tools/build.lm2`), so the next slice's isolated builds and bootstrap take G0 = boot121a's G2 working tool
(`4DD5D706…`) unless they change `tools/` again.

## What B2b still owes (the next slices)

- **B2b-2c (slice 260):** a free value received by a modelled reference place (`implements` at the reception:
  `lm_compiler_check_receiving_value_at` → `lm_compiler_check_reference_receiving_at`, the kernel's `lmx_walk_admit_in`) --
  the path marked «keeps its admission path (slice 259)» in emit.lm2 is untouched by this slice; P1-PTR-COVERAGE (Codex,
  2026-11-02 ~15:25Z, OPEN): the address of a graph/descriptor place and the deref through it -- a kernel code «pointer to a
  reference cell», or admission by the actual pointee at the reception; no invented code, no blanket ban.
- **B2b-3 (slice 261):** the closures -- no forwarding of a callee's free input to its callers (`dyn_site_callee` /
  `dyn_site_held`), no static typing of free names, the translation refusal «unbound dynamic input» replaced by the runtime
  inadmissibility of the call (book :727/:777), the `wait_*` / `note_call` / `dyk` paths for free names removed as dead.
- Of the ledger `BITWISE-OPERATORS-NOT-CLASSIFIED`, after this slice: the typed NATIVE path keeps C's operator in place without
  a refusal before the operation for a count outside [0, width) or a signed left-shift overflow (the walker and the
  runtime-typed path refuse); unary `~` is not in `l2_rw_prec`.  Both are recorded in the ledger entry, not in a fixture.

## Evidence and the docs check

`pins/docs259.command` ([record](records/docs259.command)): the raw manifest of the 142 listed originals under P
(`evidence.list` → `evidence.sha256`) and its verify, exit 0 (19:45:27Z); 110 LF copies of the text records in [records/](records/).
Commit `d8ddf134` «Land the boot121a-tested tp121 bitwise and shift operators as operations of the one kernel binary operation in
selfbuild (slice259)» (own files only: the design, `selfbuild/`, `steps/current.md`, this directory).
`pins/docs259-check.command` ([record](records/docs259-check.command)): the ordinary full docs check with the slice files in the
Git index, exit 0 (19:46:01-19:46:28Z): `OK: 35 paired semantic chapters, 14 implements cases, both source snapshots; 27 paired grammar sections, 44 verbatim source excerpts, 615 imported files, links, exact semantic opening; line endings LF in the index for all 14515 tracked files (verbatim imports exempt)`.
The ledger entry `BITWISE-OPERATORS-NOT-CLASSIFIED` (steps/defects.md) records this slice's status (the walker part closed; the
typed native path's pre-operation refusal and unary `~` remain) in the records commit.
