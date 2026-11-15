# Slice399: written SOURCE and hidden-input transport

Baseline398 `72b7438ef49531306ef23bc73c1e8e3371b48d20`, main. Goal remains ACTIVE.
Root is the only code/test/build writer; helpers reviewed without modifying files or running producers.

## Common cause and change

Call-contract emission passes written formal ordinals first, then hidden input ordinals after arity.
`rw_signature_input` previously requested original declared SOURCE for both. The shared header reader correctly
refuses an ordinal that is not a written formal, producing `a declared header lost its original receiving source`.
Accepted397 and398 reproduce exactly this L2 refusal for struct_call_selected:21, unary_data_selection:20 and place_map:87.

Emit now requests `rw_declared_source` only for0<=input<arity. A hidden input retains its existing named two-field
transport entry: empty SOURCE plus the existing witness (empty for FREE), with the same free/foreign/scalar guards. This is the SOURCE
of the input description, not the actual Value: actual complete SOURCE/context transport remains unchanged.
The separate callee header retains Model-capture admission. Core/header_source/formal_decl_at still require
original SOURCE for a real written formal. No synthetic formal or per-test workaround is introduced.

Unblocking L2 exposes two old defects in Lower's emitted absent FREE default block. Indexed struct `.field:`
assignment targets are invalid L1; they now use the surrounding default path's canonical typed pointer projection,
after ABI validation. The scalar_abi call argument also needs a typed cast Frame to prevent L1 splitting its
member expression into multiple C arguments. Presence checks and all three ABI/SOURCE metadata writes are unchanged.
Generated L1/C remain artifacts; only maintained L2 emitters are edited. Runtime398 is reused unchanged.

## Pipeline

Stage: `build2/codex_fix250generationchain01/sol-m11-hidden-source-01`.
Run directory: `build2/codex_fix250generationchain01/runs/sol-m11-hidden-source-20261115-01`.
Seed: genuine398 G2; seed stage verify933 PASS. Fresh stage copies its generated src/headers, then overlays
the maintained inputs through normal manifest/stage-copy. Canonical manifest remains398 until final freeze.

- Source01:933 SHA256 `f8a4f185131ae106d4d64178042cd6100afa7a915b072c583c108141c3fbccac` adds only the Emit guard.
  Frontend01 Emit-only PASS, raw SHA256 `45eca79b37c50cbaf9eb1229d945cdb68bde9eeae79838fc6c8a2330e9f8e332`.
- Repair01 passes all six native/forced L2 translations, then refuses at L1 malformed assignment targets.
- Source02:933 SHA256 `cec35fbe734d49bd64979f42c6d829dd26536d79cbf3e83faacc71c849072eb9` adds the typed alias writes.
  Frontend02 Lower-only PASS, raw SHA256 `36fd814ac8f36805eb08b74ce2e4b4df81002ac58a3799f4c6351f0ee568a85e`.
- Repair02 passes L2/L1 for all six variants, then CC refuses only the ungrouped scalar_abi argument;
  expected-dot/incompatible-arg4/too-many-args/undeclared-field diagnostics are one common cause.
- Source03:933 SHA256 `ef6243a84ec74f814e71c6f955098141ac7786c005a8e557bb6111db5c7477f1` adds that typed ABI projection.
  Frontend03 Lower-only PASS, raw SHA256 `8036fbdb0067fcbb19cd1f96dc7088a6de3cb6cf4dba32ebd33fa46ca9e74135`.

Each partial invocation verifies reuse102 and ABI24, regenerates97 C headers, and uses the explicit verified
backend/libc bundle. The successful Emit01 translation is retained by Frontend02/03; unchanged runtime/kernel
translations are not repeated. Both fprintf lists in the alias change have12 matching arguments; independent
read-only review confirmed the pointer projection and ABI cast grouping. Earlier failed records remain intact.

## Acceptance checkpoint

Repair03 runs the original three programs with unchanged expected7 under native/forced/root0/root1.
Controls01 runs free_model_admit, free_held_model, entry_admission_order and whole_field_refused, preserving
runtime Model/conversion refusals and the original static whole-field refusal.
Private repair03 SUITE3/0 PASS n/f/root0/root1. Controls01 SUITE4/0 PASS, including both static refusal variants
with the original needle and no L1 left. Expected results remain unchanged.
Source03:933 is frozen/canonical, verify repo/stage PASS. Genuine Whole01 G1/G2 quick PASS9/0 each, consumed360.
Fixedpoint03 CHECKS30/0 PASS, including canonical933/verify and unchanged runtime398 bytes.
Actual G2 frontend SHA256 `56159699fca90dc01d3d57bce95129bc9fa0bea798f314266ce44fdb0aefcc95`;
Tool SHA256 `360694d8208294c2154edb8ceacba270e050cd5073443e8d72e430f06abc7355`.
G2 targeted01 SUITE13/0 PASS:12 positive rows n/f/root0/root1 and both original whole-field refusal variants.
The three original header-source refusals are closed with their original expected7.
Graph01 SHA256 `64c7e3549b85ae84244ebf8b6fd812efe4fd90f17ee9a265c0f14db711d9f2be`;
Graph3 triple CHECKS3/0 PASS, including the original missing-model build4 refusal.
All code/test producers are terminal. Actual G2 render01 PASS35 paired chapters/14 cases/both source snapshots;
generated semantics and grammar unchanged. Fresh docs-check01 with separate precreated cwd/private directories
PASS35/14/27/44/615, links/LF28287. Final indexed01 with separate fresh cwd/private PASS35/14/27/44/615,
links/LF28288;11 owned files staged, working/index diff checks PASS. Both foreign untracked files and original
hashes are retained and excluded. These receipt lines are verification outputs, not new semantic inputs.
Commit/push follows directly on main.
This slice neither completes common native M14 nor typed construction/copier work; continue the main v3 plan.
