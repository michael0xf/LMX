# Slice 261 (2026-11-02): B2b-2d of the optimization line -- P1-PTR-COVERAGE at the address level: the address of a free name at any typed place, received by a typed pointer place by the actual pointees at every depth, in both executors

Fable implemented tp123, ran its isolated checks and started boot123a. At the author's direction Codex took over the running bootstrap, the G2 focus suite and publication. Previous slice: [260](../fix260-20261102/notes.md)
(B2b-2c: a free value at a place with a receiving model admitted at run time; P1-NUMERIC-KIND; landed a4694ed3 + b9060374 +
1727adcc).  Design: `optimization_design_from_fable.md` revision 22 (the header note; §4.5 «Реализация B2b-1»: the Реализовано
(B2b-2d) passage).  The rulings this slice runs on: Codex's confirmation of slice 260 (~21:12Z, verbatim in the 260 notes and
`pins/CODEX-TP122-MESSAGES-20261102.txt`): «Общий P1-PTR-COVERAGE остаётся OPEN: place_address 1699 descriptor/1706 pointer_to ещё
дают UNSUPPORTED для graph/descriptor/depth; raw-only consumer gap также не языковая норма. 261 coverage/address →262 closures →C
допустимо, продолжай как sole writer/build без ACK. Адрес graph-bound free name всё так же адрес semantic LOCAL input cell, без
origin alias/promotion; receiving по actual pointee/context при сохранении depth/admission/immutable/native-reset. Разрешённую
полноту не свести к одному адресу Point; произвольная допустимая глубина/descriptor остаются обязательными в B2.»  No new design
gate.

The archived text copy of the generated header `boot123a-lmx_walk_values.h.lm1.txt` omits its trailing blank line. The raw generated header is covered by the evidence manifest.

## The step

The address of a free name (`@ quote`, slice 258) is the address of the activation's input cell (the author's ruling of
2026-11-02: a hidden input is a local of the activation) -- a reference typed by `lmx_type_pointer_to(place type)`
(`lmx_walk_place_address`).  That table knew only the translator's fixed primitive codes: a place holding a graph reference
(LMX, or a native graph own's record with the translator's pointer code), an Array (DESC), a pointer of a translator code (a
pointer to a graph reference, any depth above the table), a descriptor place (`place\descriptor != 0`) all ended in
UNSUPPORTED («walk error: UNSUPPORTED», exit 3, both executors: probe_graph_address of slice 260).  The receiving side had the
twin problem: a typed pointer place `@@: pp Point` carries a translator foreign code (interned per translation, `Lmx` at depth
2) which the kernel cannot derive, so `lmx_walk_value_receive`'s code comparison could never admit a kernel-made address there.

1. **The kernel's own pointer code.**  `LMX_TYPE_CELL_POINTER` (1088 = `LMX_TYPE_POINTER_BASE + 64`; `tools/build.lm2`, enum
   LmxType) names the address of a cell no pointer code of the table expresses: below the translator's foreign band
   (POINTER_BASE + 100 and up), above its fixed codes.  `lmx_type_pointer_to` is total but for NONE: a type without a table code
   -- LMX, DESC, UNSIGNED_CHAR, a translator pointer code, a second level of the table's own codes -- is addressed by
   CELL_POINTER.  The pointee is never read from that code (`lmx_type_pointee` gives NONE): `lmx_walk_value_deref_actual` reads
   it cell-first -- the owning record (the free input's record is the address's referent, slice 258) or the arena's pool; a slot
   of a graph node (a CHILDREN/REF pool cell: the storage of a descriptor place, the address of a graph-valued field) is typed by
   what it holds (a Structure -- LMX, an Array -- DESC).  `lmx_walk_place_address` therefore addresses every typed place: a
   descriptor place by its slot (the storage), a reference or opaque cell by CELL_POINTER; only a place of no type is
   UNSUPPORTED.  The address value keeps its referent, so a deref through it reads the record (as before).
2. **The one receive by the actual pointees.**  `lmx_walk_value_receive_pointer(arena, value, ty, depth, leaf, out)` (new kernel
   export: `tools/build.lm2` 147 → 148 names) receives a runtime-typed reference at a pointer place whose static shape the
   translator knows -- `depth` pointer levels above a leaf of kernel type `leaf` (LMX: a Structure; DESC: an Array; a number
   type; NONE: a `void` leaf, no leaf check).  It judges the ACTUAL pointees, never the value's type code: at each level the
   addressed cell must be a reference cell (typed by its owning record or the arena's pool, `deref_actual`) holding the next
   level -- a Structure or Array met before the leaf is a chain too short, a number cell where a pointer cell is asked a wrong
   level: the implicit `convert`; a null ends the chain (nothing deeper to judge, as a null graph reference is received); at the
   leaf a Structure or Array is classified by the arena (a walked LMX/DESC-typed reference passes, as `receive_graph` admits it),
   a number by its cell's type.  The received value keeps its reference and referent and takes the place's type `ty`, as a
   received number takes the place's type.  A present value of another kind is `convert`, an absent one INVALID, a pointee the
   kernel cannot type UNSUPPORTED -- the honest limit, no invented type.
3. **Both executors call it.**  Natively, `emit_dyn_receive_full` prints the call for a pointer place whose shape the kernel's
   table cannot express (`lm_compiler_dyn_pointer_shape`: a foreign code whose word is a type of the language -- `Lmx` at depth 2
   and more (depth 1 is the graph place, `receive_graph` of slice 260), `LmxArray`, a number word at depth 3 and more, `void`);
   the kernel-table codes keep the receive by code (`lmx_walk_value_receive`, slices 257/258), a C door's record type stays a
   foreign value.  The walked body gets a new frame, `LMX_WALK_OP_RECEIVE` (63; `OP_COUNT` 64): [receive, value, witness, depth,
   leaf], width 5 -- `rw_reference_span` wraps a runtime-typed value (kind -20) at such a place in it (`rw_witness` writes the
   place's typed cell into slot 2, two `lmx_walk_store_size` numbers into slots 3 and 4; the textual twin
   `lm_compiler_rw_dyn_pointer_shape` decides as lower's does), `lmx_walk_eval_result` evaluates the value and calls
   `receive_pointer` with the witness's type; an absent value stays absent.  So both executors give one answer on a correct
   program and on a wrong one (`convert`), which the walker's blind reference store into a working cell (SET without a code
   check: the existing behaviour of typed pointer rows, kept for typed values) could not give.  `lmx_walk_shape_min` knows the
   width; the frame's code word stays `source * OP_COUNT + opcode` (every generation of the bootstrap uses the new count).

What stays open (the ledger entry names it): the raw-only consumer -- the address of a free name where a raw typed C operand is
required (a C door without a prototype, a machine operand) is the translator's located refusal «a runtime-typed address where a
typed native value is required», an implementation gap, not a norm (Codex ~21:12Z); the address of a descriptor place and the
DESC leaf are implemented in the kernel but have no witness: a descriptor place without a witness (a graph-valued field reached
through a free name) and a free name bound to an Array are unreachable in today's frontend -- slice 262 (the closures) and
later; the walker's blind receive of TYPED references into its rows (two spellings of one reference: LMX and the translator's
code) is the previous boundary, not this slice's.

### What the slice changes

- `tools/build.lm2`: enum LmxType gains `LMX_TYPE_CELL_POINTER 1088`; `decl_walk` gains `define: LMX_WALK_OP_RECEIVE 63` and
  `LMX_WALK_OP_COUNT 64`; `walk_value_names` 147 → 148 (`lmx_walk_value_receive_pointer`), the calloc and the module's count.
- `src/l2src/lmx_walk_values.lm2`: `lmx_type_pointer_to` (total but for NONE: CELL_POINTER for every type without a table
  code), `lmx_walk_value_deref_actual` (a CHILDREN/REF slot is typed by what it holds), `lmx_walk_place_address` (no descriptor
  refusal; the comment), `lmx_walk_value_receive_pointer` (new, exported, after `lmx_walk_place_address`: it uses
  `deref_actual` and `lmx_walk_place_load`), `lmx_walk_shape_min` (RECEIVE → 5), `lmx_walk_eval_result` (the RECEIVE handler
  before the prefix sign's).
- `src/l2src/l2_frontend_lower.lm2`: `lm_compiler_dyn_pointer_shape` (new, internal; before `emit_dyn_receive_full`);
  `emit_dyn_receive_full` -- the shape of a non-graph pointer target is asked after its type text, and the print site has three
  branches: graph → `receive_graph`, shaped → `receive_pointer(l2_program_arena, record, type, depth, c.<leaf>, @ l2_rv)`, else
  `receive`.
- `src/l2src/l2_frontend_emit.lm2`: `lm_compiler_rw_dyn_pointer_shape` (new, internal; before `rw_reference_span`);
  `rw_reference_span` -- a kind -20 value at a shaped pointer place is wrapped in the RECEIVE frame before the ordinary
  evaluation (fix02: the frame number through a plain local -- a `\out` after an identifier actual is glued into a path by the
  parser, «field path goes through a slot with no Structure»).
- `tests/dyn/free_graph_address.lm2` (new; `runs	dyn/free_graph_address.lm2	7	nf`): Point (y, x), Shape (y 2, x 1), Slim
  (pad), Thin (pad); `int: quote 11`; addr `@@: pp Point 0; pp: @ quote; @: p Point \pp` → p\y; addr3 `@@@: ppp Point 0; ppp: @
  quote; @@: pp Point \ppp; @: p Point \pp` → p\y; outer `(Point: p)` binds `@: quote Point p` and reads 2 by addr (81);
  outer_ptr `(Point: p)` binds `@@: quote Point` to `@ inst` and reads 2 by addr3 (82); outer_slim `(Thin: t)` binds Slim: addr
  is the implicit `implements` at the deref into the modelled own, caught (90 → 83); outer_num binds `int: quote 5`: addr is the
  implicit `convert` at the address's receive (91 → 84); outer_short `(Point: p)` binds a graph reference and calls addr3: the
  depth-3 receive meets the Structure before the leaf -- `convert`, caught (92 → 85); m calls outer(Shape), outer_ptr(Shape),
  outer_slim(Slim), outer_num(), outer_short(Shape); entry 7.
- `tests/full-suite.tsv`: the new row and its comment.

### The fix history (the candidate's tries; records in `pins/`, LF copies in [records/](records/))

Variant `variants/tp123` = the landed selfbuild (source-tp122 `8F34D77F…`) with the changed files; `inputs.list` 167 lines.
Final bytes (fix02): lmx_walk_values `EC14792F…`, l2_frontend_lower `8A08ED74…`, l2_frontend_emit `1F38205F…`, tools/build.lm2
`80C4ED19…`, full-suite.tsv `2FB7482D…`, free_graph_address `C559F1EB…`; source-tp123 `CB155E7E…`.

| try | what | result |
|---|---|---|
| fix01 | the kernel (CELL_POINTER, `pointer_to`, `deref_actual`, `place_address`, `receive_pointer`, the RECEIVE handler), the tool (the type code, the op, the export), lower (`dyn_pointer_shape`, `emit_dyn_receive_full`), emit (`rw_dyn_pointer_shape`, the RECEIVE frame in `rw_reference_span`), the fixture, the suite row; stage cold-tp123 (`tp123-prepare.command` 01, 21:49:50Z, fresh: source-tp123 `5A73996C…`), reuse set from cold-boot122a (`tp123-reuse.command`), `tp123-tool.command` 01 (21:50:07–21:52:20Z): tool123 `573B37F0…`, `REBUILD tool 0 failures`; rt123a (`tp123t-rt.command` 01, 21:54:15–21:55:11Z): the kernel with the regenerated headers compiles, driver.o `DAF6D813…`, driver-observe.o `FF6DCBD9…`, 84 headers regenerated | fe123a (`tp123t-fe.command` 01, 21:55:25–21:59:38Z) refused: `l2_frontend_emit.lm2:7911:281: field path goes through a slot with no Structure, atom=out` -- the actual list `\out, depth, \out, leaf` of the store_size print: a `\out` after an identifier actual is glued into the path `depth\out` (the P0 slash atom) |
| fix02 | the frame number through a plain local `frame` (`tp123_fix02.py`); stage refreshed (`tp123-prepare.command` fix02, 22:00:53Z, 4 steps: source-tp123 `CB155E7E…`) | fe123b (`tp123t-fe.command` 02, 22:01:06–22:07:17Z) OK, l2trans `F34020C6…`; `tp123t-suite.command` 01 (fe123b + rt123a, 22:07:28–22:09:00Z): 15 rows, 0 failures (free_graph_address native and forced, roots 0 and 1); `tp123t-probe.command` 01 (22:09:23Z): the seven probes of slice 260 -- 7 rows, 0 failures: probe_graph_address and probe_graph_deref green in both modes (on the landed code: `walk error: UNSUPPORTED`); `tp123t-obs.command` 01 (22:10:20Z, spec m=1,outer=1,addr=3,addr3=2,outer_ptr=1,outer_slim=1,outer_num=1,outer_short=1): forced -- all eight bodies walked with those counts, native -- none |

Two stage postures (fresh, fix02), one tool rebuild, one runtime, two frontends, one focus suite, one probe run, one observed walk.
The generated code of the witness (`tp123t-suite/focus123-01/free_graph_address-native/p.lm1`): addr -- `lmx_walk_place_address(l2_call_arena,
@ l2_ip7, @ l2_cv8)` then `lmx_walk_value_receive_pointer(l2_program_arena, @ l2_cv8, c.LMX_TYPE_POINTER_BASE + 100, 2,
c.LMX_TYPE_LMX, @ l2_rv10)`; addr3 -- the same with `c.LMX_TYPE_POINTER_BASE + 102, 3`; the walked view
(`free_graph_address-forced/p.lm1`): `LMX_WALK_OP_RECEIVE` frames of width 5 over the ADDRESS frames, `lmx_walk_store_size(…, 3U,
2U)` / `(…, 3U, 3U)` and `(…, 4U, (cast: (size_t) c.LMX_TYPE_LMX))`; outer_ptr's `quote: @ inst` keeps the plain ADDRESS frame with its
witness (a typed own).

## boot123a, the fixed point, the focus suite on G2, the landing

| step | record | result |
|---|---|---|
| stage | `boot123t-prepare.command` TP_TRY=a (22:10:31Z) | cold-boot123a = exactly source-tp123 (167 inputs; `source-boot123a.sha256` = `source-tp123.sha256` `CB155E7E…`); no generated input |
| bootstrap | `boot123t-detached.command` → `boot123t-quick.command` TP_TRY=a (22:10:54.015–22:30:21.212Z, 1167.20 s) | `bootstrap quick`: G0 = tool123 `573B37F0…`, BASE full48/g2/frontend, previous frontend boot122a's G2 `7795D04D…`; G1 built and tested by G0, G2 built by G1, the working binary promoted; `BOOTSTRAP quick 0 failures` |
| G1 = G2 | `boot123-compare.command` TP_TRY=a → `boot123a-compare.txt` | 248 receipt paths in both generations, 245 raw-equal, 3 differ -- the PE images at the link stamp bytes only (136–137, 216–217) |
| focus suite on G2 | `tp123-suite-g2.command`, list `focus123.tsv` | 15 rows, 0 failures on G2's frontend `8DD841A0…` and runtime objects (`DAF6D813…`, `FF6DCBD9…`), by the promoted working tool `1F12CDC1…` |
| landing | `land261.command` | source-tp123 verified in cold-boot123a and stage-copied over `selfbuild/` (167 paths); the variant's `inputs.list` copied; `selfbuild/inputs.sha256` rewritten and verified = `source-tp123.sha256` `CB155E7E…`; the 65 consumed sources of G1 and of G2 verified against the landed files |

The landing follows the rule of Codex's answer to FABLE-RESULT-S3-20261102T0100Z (choice (a): the whole tested set after an
actual quick PASS, no FULL, no ACK): `selfbuild/` = source-tp123 -- the 5 changed inputs and the new fixture over source-tp122;
`selfbuild/README.md` and `steps/current.md` updated; the design revision 22; this record.  `tools/build.lm2` changed, so the
next slice's isolated builds and bootstrap take G0 = boot123a's G2 working tool (`1F12CDC1…`) unless they change
`tools/` again.

## What B2b still owes (the next slices)

- **Slice 262, B2b-3:** the closures -- no forwarding of a callee's free input to its callers (`dyn_site_callee` /
  `dyn_site_held`), no static typing of free names (today a graph-typed unit field makes a TYPED hidden input, `dt_of_own`;
  only numeric sources make FREE ones -- the reason the witnesses of 260 and 261 bind a numeric unit field's name to a graph),
  the translation refusal «unbound dynamic input» replaced by the runtime inadmissibility of the call (book :727/:777), the
  `wait_*` / `note_call` / `dyk` paths for free names removed as dead.
- **Of P1-PTR-COVERAGE after this slice** (the ledger entry FREE-ADDRESS-REFERENCE-PLACE-UNSUPPORTED names them): the raw-only
  consumer (a free name's address where a raw typed C operand is required -- the translator's located refusal, not a norm); the
  address of a descriptor place and the DESC leaf of `receive_pointer` -- implemented, unreachable by a fixture until the
  closures/field paths of 262 (no witness is claimed for them); the walker's blind receive of TYPED references into its rows (two
  spellings of one reference) -- the previous boundary.
- Of the ledger `BITWISE-OPERATORS-NOT-CLASSIFIED` (unchanged by this slice): the typed native path's pre-operation refusal and
  unary `~`.

## Evidence and the docs check

`pins/docs261.command` ([record](records/docs261.command)): the raw manifest of the 205 listed originals under P
(`evidence.list` → `evidence.sha256`) and its verify, exit 0; 176 LF copies of the text records in [records/](records/).
Commit `8d9e025c` «Land the boot123a-tested tp123 address of a free name at any typed place and its receive by the actual
pointees in selfbuild (slice261)» (own files only: the design, `selfbuild/`, `steps/current.md`, this directory).
`pins/docs261-check.command` ([record](records/docs261-check.command)): the ordinary full docs check with the slice files in the
Git index, exit 0 (22:34:33-22:37:29Z): `OK: 35 paired semantic chapters, 14 implements cases, both source snapshots; 27 paired grammar sections, 44 verbatim source excerpts, 615 imported files, links, exact semantic opening; line endings LF in the index for all 14896 tracked files (verbatim imports exempt)`.
The ledger (steps/defects.md) gains the entry FREE-ADDRESS-REFERENCE-PLACE-UNSUPPORTED (Codex's P1-PTR-COVERAGE at the address
level, FIXED by this slice) in the records commit.
