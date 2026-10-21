# Common reference-value producer — private115–117 WIP

Baseline:`c0519291`;stage114 kernel/context and compiler110 bytes. Codex is
sole writer/build;goal ACTIVE. Public dev unchanged. This continues K01/K02
and the common path/value dependency before clean kernel/self-build.

Initial source:private `build/codex_value_producer_115/src/l2src/l2trans.lm1`.
The merge operand adapter currently selects `l2_emit_path_run(...,arr_ok=2)`
instead of the ordinary reference-value producer,and its walker adapter
independently selects a path-value route. Replace both by their existing
common reference-value producers,without parsing/index/name/backend cases.
That also retains the common producer's stable result instead of exposing
the shared native path register to later metadata work.

Witnesses:unchanged typed-copy-index-once/opaque-current-model/Model=value;
new indexed copy of ordinary declared data checking one effectful index,
actual values,write,taken-address dereference and source immutability in
native/forced methods and both root routes. The new control does not replace
or weaken the still-red opaque7 oracle. Run old compiler110 differential,
inherited compiler metadata suites and original154 source-value cells.

115 actual compiler/metadata336 checks pass after using the already corrected
root110 fixture02. Build01 reused the old fixture01 by mistake;read-only GDB
identifies its missing `l2_m_dn` row at `l2_dn`,not the modified producer.
Original crash preserved;production115 source/C unchanged for finish02.

The new indexed positive is L2 RED in both translation modes. The early
`span>=3` hypothesis was NOT the measured cause:later GDB proves a4-field
run. No154-value verdict exists for115. Continue in
numbered116,keeping115 bytes/evidence:classification and merge field/code
metadata must consume the common `L2ReferenceSource`,not names versus
path-versus-call heuristics;native/walker non-declaration operands must all
enter the same ordinary producer. Remove the old named-operand fallback too.
Touched116 source remains `l2trans.lm1`;runtime is exact114. Add the deep
mixed reference/index source alongside the indexed control,with unchanged
opaque and original154 witnesses.

116 source classification,field-schema construction,code-use metadata and
native/walked operand loading use `L2ReferenceSource` plus the ordinary
value producers. The separate named candidate-constructor fallback and
namespace/formal loads are removed. The common native descriptor producer
also uses `l2_tok_formal` so a rebound formal reads its current working cell.

116 build01/02 fail strict GCC at a dotted L1 member in a call argument;
parentheses produce the SAME invalid C. Build03 uses one scalar field read,
source50E3C2A5...,C208EBCE2...,and passes336 metadata checks. Both indexed
translation modes still refuse at L2. Read-only `indexed-source.gdb01/02`
shows:the source query gives schema-1/path0 BEFORE typing;ordinary
`l2_native_group_ty` naturally returns graph-reference type-5 and creates a
stage1/source_use0 bound INDEX query with run_count4,indexed1,leaf_Model0.
That is a query,not a fabricated Consumer use. The missing step is ordinary
value typing BEFORE source selection,not another merge-only path adapter.

117 performs that order;diagnostics consume its already computed type
instead of typing again. Source
`1BF5FEBD021E553F320153B9F1EF6B7698321C4475B14D2DAA5BE197ACE3EE9E`,
generated C`FEE84A446769591FB9B7DA5F896E024F1FC9E67E2EE4D6979161B6CA19244010`.
Actual117 compiler/336 metadata checks GREEN. New indexed positive now
really translates,compiles and executes all4 translation/root cells,but
returns81 rather than7 in both engines. This is **RED**,not completion.

Native read-only `value.gdb02` proves Counter.calls=1 and copy physical
extent6,with the source E admission still retained (proof2,width4,physical
Wide token). The read of `copy\\v` returns19,while physical slot0 holds9.
The field read uses the inferred result's direct slot,not the giving E's
retained correspondence. Thus a successful copy/layout token is insufficient:
the CURRENT giving Model must accompany the once-evaluated/copied value
and drive all later field/address projections. Do not restore the old
candidate-Model fallback or add a native-only guard to hide it.

117 primary pipeline/session54800 is TERMINAL1 at that positive. Independent
serial inventory PID4244,startUTC2026-10-21T10:15:59.4994540Z is also terminal:
original154 source/root value cells GREEN. Copy inventory now has12 RUN
observations,8 RED:opaque4 and index-once4 remain runtime RED;Model=value4
GREEN. Its former2 L2 refusals became4 actual runtime observations,not an
extra pair of behavioral regressions. The new declared-index and deep mixed
sources each run all4 cells and give program81/driver exit1,not7. The first
failed check prevents their write/address assertions from executing.

`codex_producer117_controls_03.ps1` executes the exact same two new sources
with unchanged110:both translation modes refuse at L2 (four measured
refusals). This phase advancement is not GREEN. Native/forced-method/root
bindings are recorded separately in each `results.json`;successful
translation is not a test of values or evidence of pure walked methods.

Terminal receipt:`build/codex_producer117_terminal_01.inputs.sha256`,7846 pins,
SHA256 `C75A9CCE2962619132DA4099418F3B81D595FCBAEA00BDF0640415081A523D47`.
All6566 upstream116 prepared pins were checked. Complete compiler delta from
exact114 is [reference-producer117-u0.patch](witnesses/used-scope-20261020/reference-producer117-u0.patch),
SHA256 `4502BBCB9E0DDDD19420E9EE32346D6175FECC5183240B6FD62B220C9BCA461D`;
`git apply --unidiff-zero --check` passes on that exact base. The original
context-bearing private patch remains byte-identical under its117 receipt
(B6DB206A...);the published zero-context form avoids treating blank context
markers as trailing source whitespace. Runtime is unchanged114.
No full117 gate was run;public dev is not promoted.

This producer-route change alone does NOT transport
the current giving Model/reference sheet through copies. Keep that connected
work open;do not infer Model from a first admission,physical token or parent,
re-evaluate an indexed prefix,or add a native-only guard.
