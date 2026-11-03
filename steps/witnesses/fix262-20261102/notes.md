# Slice 262 — free inputs of the selected activation

## Verified package

`boot124a` rebuilt the 170-input package from G0 tool124d (`BED0142D…`) and the
published boot123a G2 frontend (`8DD841A0…`). G1 built the complete G2. The
bootstrap ran from 2026-11-03T00:33:52.1415657Z to 2026-11-03T00:47:10.5065756Z (798.37 seconds).
The source manifest is `A148F03F4FBC39FC7D5964A41569053855070D29BFF826E3E60E43D69B80004C`. The frozen inputs, the 14 candidate changes and
the landed files were checked against their hashes. G1 and G2 each passed nine
smoke rows. Both consumed-input manifests match byte for byte. Rehashing the two
artifact inventories gave 248 paths each and 245 byte-identical files.
The 3 differing PE files have matching sizes. All differing bytes belong to
TimeDateStamp or CheckSum in their actual PE headers.

| Tuple or check | Result |
| --- | --- |
| Promoted tool | `62DF51CF4749013AF111D1916C24419493AD0582AA5C20B3FF18DD7B003D2D3F` |
| G2 frontend | `1D77DC7F42B8DD17A327FC62F3C07A85AF79E94345F460032FDDEFA9A2AD70B3` |
| G2 production runtime | `701FD14C5B6687F0735166B90706D91BC0925DD1742CAF9F38AF3F86F6BB1FDE` |
| G2 observation runtime | `ABC17D42240472AFC6D28294580C8755F268054688B28803DFD9276CF7478044` |
| Component and G2 focus | 18 rows each, 0 failures |
| Component observed held calls in forced mode, per root | check_held 1, relay 1, outer 2, relay_bound 2, relay_reader 2 |
| Held numeric conversion | Original 1001/141, modified receiver 146, out-of-range caught as convert |
| Held model | Copied Point 2, conforming Other 9, number caught as convert, missing field caught as implements |
| Width of the same held call | One free row returns 3, two different rows return 9, native and forced on both roots |

The selected held occurrence supplies its own header. Ordinary free inputs resolve
at reached entry and a missing binding with no lexical source raises `implements`.
The ordinary Structure `call:` path still gets a positional ABI from M2. Also open
are descriptor/DESC address witnesses, raw C operands where a concrete ABI is
available, the typed native shift guard and unary complement. FULL and §§8/8a remain open.

[Bootstrap](records/boot124a-quick.terminal.txt) · [generation comparison](records/boot124a-compare.txt) · [G2 focus](records/tp124-suite-g2.terminal.txt) · [landing](records/land262.terminal.txt).

The promoted tool verified all 239 named evidence files. Its repository documentation
check completed at 00:50:24 UTC on the staged slice. It verified 35 paired semantic
chapters, 14 implements cases, 27 paired grammar sections, 44 verbatim excerpts,
615 imports and LF in 15,056 indexed files. The driver reported 60 checks.
[Documentation check](records/docs262-check.log).

## Candidate history


Codex owns this slice from published main `5f554406`. The landed package is
source-tp123 (`CB155E7E…`, 167 inputs). Its working G2 tool is `1F12CDC1…`
and its G2 frontend is `8DD841A0…`. The previous slice's graph address witness,
G2 focus and package receipts are in [the 261 record](../fix261-20261102/notes.md).

The candidate is `variants/tp124` under `build2/codex_fix250generationchain01`.
`pins/tp124-changed.list` names its eight changed inputs. The label `fix02`
identifies the staged source manifest
`d5aed95845a73d80062116cb7c9c4c8373391fe9cec26a15540b7105c5aecc6b`.

The collector records a method's own free names. The candidate removes the
call-site worklist for transitive free names and its type propagation. Lookup
uses the existing activation chain. A free row that still lacks a binding
after lexical defaults have been taken returns the named `implements` status
at entry. The emitted native entry and the walker call the same kernel check.
The model projections still used for other receivers have separate consumers.

`tests/dyn/free_entry_binding.lm2` checks a caller-only binding across an
intermediate method, a path which never calls the consuming method, and a
caught missing binding. A graph-typed lexical source and a caller's numeric
binding also exercise the same consuming method. The existing chain, model,
numeric, pointer and mixed-mode checks remain in `pins/focus124.tsv`.

The candidate's tool rebuild passed with the tp123 frontend and runtime
(`pins/tp124-tool-01.terminal.txt`, 22:43:33–22:45:15 UTC). Tool124 SHA-256
is `4e3e2f157615c51f42fd3f67a134da13b8fcee1f7443174d6dec8bdc39f7f522`.
Component receipts and the focused suite determine the remaining changes
before a coherent bootstrap and landing.

`rt124a` stopped in the L2 translator at `lmx_walk_values.lm2:2795` on
the opaque frame argument-row pointer. Fix03 spells out the typed view of
the owned rows at the common admission call. Its source manifest is
`38762db1b40184879d7f530e77af70d833e146103684276f52ee0aa875ece3fa`.
`rt124b` built from it at 22:47:10–22:47:59 UTC, exit 0. Production driver
`02A582B6…`, observation driver `1EC53C27…`. `fe124a` started at 22:48:00 UTC
on the same stage, recorded in `pins/tp124t-fe-01.terminal.txt`.

`fe124a` built successfully (`8EBDFDA9…`). Focus 01 passed all 15 prior rows.
The new row failed translation in both modes. With the same frontend the
caller-only case translated on its own, and the graph-typed lexical case
reproduced the refusal. `tp124-entry-diagnose-01/trace-graph.log` locates it
at `lm_compiler_rw_input_witness` from `lm_compiler_rw_arg_fb`. The input
model query was still using the lexical source's model for the hidden
argument. Fix04 changes `l2_frontend_context.lm2` so that a free row carries
the caller's actual value, while formal and explicit capture models retain
their contracts. This ninth changed input is in source manifest
`8752ac0c67386e7a0b2a7384af74a02de19c6d8647dee4bb64f53ad6170cf51a`.
The runtime still matches `rt124b`. The frontend and suite receipts are
`pins/tp124t-fe-02.terminal.txt` and `pins/tp124t-suite-02.terminal.txt`.

Fix04 reached 16/16 passing rows on the component tuple. `fe124b` is
`0ADCF17F…`. Focus 02 finished at 23:04:04 UTC. Both roots in both modes
returned 7 for `free_entry_binding`. In the emitted `free_name_chain` graph
the input headers of `mid2` and `holder` went from one slot to zero. `leaf`
retains its single `quote` slot, and the existing reads of 3, 65 and 65 pass.

Two additional cases use the historical sandbox sources and the supplied
`convert_impl.lm2` part. The held-call case uses the original source bytes.
The chain65 diagnostic replaces its historical root `return: 0` with an exit
message calling `m0`. That first diagnostic expected 3, which also requires
the `char` free value at `m64` to enter an `int` result. The two-mode result
on fix04 and the same inputs on published boot123a are retained separately
in `tp124t-compat/focus124-compat-01` and `tp124-compat-baseline-01/suite`.
Both tuples refused the held program and closed the chain's R0 unsuccessfully.
On fix04 the held refusal was a raw read of the free callable. Fix05 routes
the held target's complete value record through the same graph receive as
other typed consumers. A missing held actual is marked for entry resolution.
Fix05 manifest `e31b5b4717f19eb725c22d2df635d93362d52920f5c5a0647cf74587fe535ce4`.
Its pending component receipts are `tp124t-fe-03` (`fe124c`) and
`tp124t-compat-02` (still `rt124b`). A separate diagnostic keeps the caller's
`char` and calls the supplied `lm_stg_convert_char_int` explicitly at the
leaf to isolate value transport across the 65 frames.

With `fe124c` and `rt124b` the held-call fixture translates in both modes and
returns 7 natively on both roots (both inner numeric checks pass). Forced
execution returns `LMX_WALK_INVALID`. A debugger on that exact `p-prod.exe`
locates the first invalid status in `lmx_walk_values_arg_place`, called by
`lmx_walk_snapshot_args` at entry from `l2_mad_call`. Argument 0 of 1 is a
present numeric `LMX_TYPE_INT` (2), value 40. The capture's witness requires
`LMX_TYPE_SIZE_T` (3). Details are in `tp124-entry-diagnose-01/trace-input.log`
and `pins/tp124t-compat-02.terminal.txt`. The remaining fix is to apply the
declared capture's normal conversion to the actual binding in the common
held-call path before either executor consumes the typed row. Conversion
failure must retain the language's named status and absent bindings must
continue to select their own capture defaults. Keep the verifier and oracle.

`pins/tp124t-chain-01.terminal.txt` confirms the explicit-converter chain
diagnostic returns **3 across 65 calls**, native and forced, roots 0 and 1.
Apart from the executable root, its only change to the historical source is
that `m64` calls `lm_stg_convert_char_int(quote)` at its `int` result. The
earlier expected 3 conflated transport with implicit conversion. Original
sandbox bytes, candidate attempts and both sets of observations are retained.

Final component tuple for fix05: `fe124c` (`E0E3BE77…`), `rt124b`, `tool124`.
The full 16-row focus on that tuple passed at 23:19:12 UTC, recorded in
`pins/tp124t-suite-03.terminal.txt`. Keep the additional held conversion case
open. Next inspect the existing `l2_mad_call` adapter shared by native and
forced dispatch, its `lmx_walk_values_project` boundary, and the declared
`primitive.convert` receiver for the reached capture. Verify the actual
converted full record, including its type, before consuming it at entry.
The latest published selfbuild is still 261.

## Native capture trace and forwarding cleanup

The debugger also inspected the exact fix05 native executable (SHA-256
`B91351C5CFFFCB4523796C36EF45EC96F044FD9285051E018651B2EBD625CB62`).
In `tp124-entry-diagnose-02/native-resolve.log` the first entry of `f3`
arrives absent and reads its copied default. At the second entry the common
resolver hands it a present INT 40. The ordinary int-to-size_t receiver
never runs. In the native `p.lm1`, `l2_m3` reads that INT's storage as
a size_t pointer. Thus the positive native exit alone does not establish a
valid conversion. The forced trace shows the identical row failing the
size_t witness. Prospective `pins/focus124-held.tsv` runs the original and
a separate negative-input case. The latter should catch the converter's
range refusal as `convert`.

Fix06 removes the remaining recursive read/forward classification from the
three emitters after tracing every producer of a hidden input back to
the collector's own occurrence or typed capture. Entry, actual transport
and model evidence now consume the declared rows. It drops the old
conditional-transitive `site_needs` logic and the disconnected
`dyr/dyc/dys/dyp` producers and predicates. The candidate and new tool
inventory are pinned by `tp124-prepare-fix06.terminal.txt`. The source
manifest is `C9B51BAB1EB983713B4711E3873DFE8B942284E507BCFE4E8D6A0B84CD046BE6`.
The rebuilt tool is `F1D60FC0CD16523B17110FB28752901B4F4778F3CF75E5B1EBEB6EC5F040F77F`
(`tp124-tool-b-01.terminal.txt`, exit 0).

Fix06's frontend `fe124d` is `D525DC5E78140B612C2A51F303FC037512AAE05207A963F0FE2D83446B6863C1`
(`tp124t-fe-04`, build exit 0). The unchanged runtime is `rt124b`.
The same tool/frontend/runtime tuple passed the main focus, 16 rows, at
23:39:55 UTC and the explicit-converter 65-call fixture at 23:40:17 UTC.
The original held program and the separate negative case both translated
in both modes. The original still reached 7 only natively. The negative
case missed its named handler natively and raised INVALID under forced
walking on both roots. `tp124t-held-01.terminal.txt` records all six
mismatches at 23:40:30 UTC. Its negative input is
`tp124-entry-diagnose-02/held_range.lm2`, SHA-256
`AD3392F3EA53B1C0E4CFEB4178DCD60B644748E72AC7E083717F67B257059752`.
The pipeline ended after this focus. The previous published selfbuild still
owns source 261.

For the held fix, the selected callable's actual input descriptor determines
the receiving type. Conversion must call the ordinary receiver supplied by
this program's `primitive.convert` row at the reached operation, preserve
full-value transport and map receiver refusal to the implicit `convert`.
Both roots and both executors must pass the positive and range cases before
landing. Do not encode a private converter registry or hold an entire unit
through a capture. Remaining unused `dyr/dyc/dys/dyp/dyk` state declarations
and resets are in the core/emit sources and the state generator in tools/build.

## Held numeric captures consume the program's converter

On fix11, the previously failing held case passes on roots 0 and 1 with
native and forced walking. The original source observes 1001 with an
absent binding and 141 with the caller's int 40. The negative int reaches
the caller's convert handler. An ordinary replacement receiver that adds
five changes the expected 141 to 146. All twelve executions passed in
pins/tp124t-capture-01.terminal.txt at 23:58:12 UTC. The separate caller
that itself reads the free input before calling the held method passes
on all four routes (pins/tp124t-held-input-01.terminal.txt). The 16-row
focus and positive 65-call chain also pass on this tuple.

Both executors enter the same held adapter. The kernel reads the selected
header's numeric capture witness, resolves the pending row from the live
caller, and admits the record with its actual type. A resolved absence
waits for its copied lexical default. A present mismatch selects an
ordinary callable by the declared primitive.convert row and the caller's
graph coordinates. The walker retains the lexical distance as part of the
held primitive's physical contract. No unit reference is retained there.
The selected receiver consumes and returns full value records through
lmx_call_prim_values. Receiver refusal reaches the calling operation as
convert. The fallback, direct local binding, and changed converter result
are all observed independently.

The successful component tuple was tool124c F59F9A5F, rt124f production
B07B5291 and observation DE82227F, fe124f 8A2E0B72. The first runtime
attempts and the first frontend attempt record translator refusals. The
corrected runtime spells its machine bindings in L2 and the frontend
sequences the typed lookup arguments. The fix11 source manifest is
ADFDAD308D756BA5699BCD0CE1E3B54CDB5B0D2D2DCC98C51189FAFE64442A96.
Published main still contains 261.

A returned method that reads ticket, which the factory neither declares
nor copies, still hit the historical formal-only refusal in both modes
(pins/tp124t-nested-01.terminal.txt, line 4). Fix12 removes that refusal
for a free read after the actual host captures have been classified.
Its maintained free_held_receive fixture combines the nested caller-only
case with the held conversion and gives the receiver its own dynamically
bound increment. The new source list contains 169 inputs. Its named
focus is pins/focus124-all.tsv. The three-case and chain receipts above
belong to fix11 until the new tuple is checked.

The returned caller-only case then passed on both roots in both modes
with fe124g (20BDA096). Fix12's combined test reused the name relay for
a second helper and refused translation. Fix13 renames that test helper
to relay_reader. The frontend and runtime bytes did not change. The new
source manifest is 46D7C466713A72F1FEDE3F749985A0689B1B7BD2A5F821BC076251BC446BDF6D.
All 169 actual staged hashes match it, including all ten candidate inputs
against the variant. The maintained test passed in isolation and in the
17-row component focus at 00:09:43 UTC on Nov 3. Its conversion method
also consumes increment=5 from the caller. The no-binding case reaches
the implements handler. See pins/tp124t-held-unit-02.terminal.txt and
pins/tp124t-all-02.terminal.txt.

The forced observation of the maintained test records check_held once,
relay once, outer twice, relay_bound twice and relay_reader twice on each
root. The native run records none of those walked bodies. The observation
protocol names returned nested occurrences fn, without their source
declaration's name. The initial attempt to count read_wide by that name
was inconclusive. See pins/tp124t-obs-01 and pins/tp124t-obs-02 (exit 0,
00:11:21 UTC) and their actual run logs.

An extra typed held model case then reproduced INVALID on both routes
and both roots (tp124t-held-model-01). The native debugger stopped inside
read_point. The caller's admissible Other object, passed through a
Point formal, arrived as a present LMX reference (8), with both model and
references populated. The selected input expected the translator's typed
Lmx pointer code (1124). Both executors rejected that row in
lmx_walk_values_arg_place. The complete trace and the first failing stack
are in tp124-held-model-diagnose-01. The required split is a good Point
(2), another conforming object (9), an integer (convert), and a Thin
object without y (implements).

Fix14 retains the actual model capture's normal receiving operation in
its selected hidden header. The common adapter reads its model and use
record, calls the kernel graph receive and existing implements admission,
and then stores the admitted reference with the physical witness code.
The previous static call-site conversion wait no longer runs. This remains
under component verification. No bootstrap or landing is implied here.

Fix14's held graph test passed in both modes on roots 0 and 1 at
00:21:01 UTC. It observes 2 and 9 for the two admitted candidates and
catches convert for the integer and implements for the missing field.
The 17-row existing component focus also passed. The production object
of rt124g is 1DD9EB54; fe124h is 3826F42D. The fix14 manifest is
9034E24F9C376266788251279BA68BD8FFB41338C586FB3CEBCCC9E80B67C99B.

The next change removes a separate old assumption in the held adapter:
the caller used to emit a row for every name in its predicted model,
then bound the selected vector by mad_max_inputs. The new kernel
dispatcher sizes rows from the selected header, projects written
operands, and initializes the selected hidden rows itself. The generated
adapter supplies its program's conversion selector. The same row
allocation serves a converter with free inputs. The test package adds
the graph case as tests/dyn/free_held_model.lm2. Verification of this
new candidate is recorded separately.

The pre-change width witness, held_selected_width, reproduces the old
assumption at the same invoke() call site. One returned method needs
first_key and another needs more_key and second_key. The same caller
should observe 3 and then 9. The fix14 frontend and runtime built both
versions, and both exited with INVALID on both roots. The fixture is
retained at tp124-entry-diagnose-02/held_selected_width.lm2. Its assertions
also appear in the fix15 free_entry_binding fixture. The old receipt is
pins/tp124t-width-01.terminal.txt.

Fix15 uses source manifest A148F03F4FBC39FC7D5964A41569053855070D29BFF826E3E60E43D69B80004C,
170 actual inputs verified, 14 changed versus 261. The rebuilt tool124d
is BED0142D82FA31575E9F2846576A00960823AFCB1D92BA911553443B4E99F24C.
The complete runtime compiled with production object 701FD14C at
00:26:49 UTC (rt124h). The new working frontend is fe124i if its own
tp124t-fe-09 receipt succeeds. The 18-row list is pins/focus124-final.tsv.
The prepared whole quick uses boot124d-prepare, boot124d-detached and
boot124d-quick, followed by boot124-compare and tp124d-suite-g2. Only
run these after checking the current component results. The accepted
selfbuild remains published 261 until actual landing.

The width witness now returns 3 and then 9 through the same invoke()
on both roots with native and forced walking. The previous build returned
INVALID on all four executions. Its generated held-call operand span has
one slot (the callable alone). The dispatcher projects zero written
arguments into the selected header's actual width and resolves that
occurrence's free inputs. Component fe124i 76FEF83C, rt124h 701FD14C,
tool124d BED0142D. See tp124t-width-02.terminal.txt (00:30:57 UTC).
