# Generated diagnostic migration: frozen 43-row inventory

Date: 2026-09-30. Status: section A's fourteen fixture/expectation migrations are verified WIP (thirteen pass, one production defect remains); sections B–D remain a read-only worklist. The frozen inventory below records the original failure, not the current result.

<a id="diagnostic14-results"></a>

## First fourteen: measured migration result

`build/l2_harness/diagnostic14_20260930_final/summary.txt` reports **17 targets,
one failure**: thirteen of the fourteen selected fixtures pass, plus three
build/scope targets. Thirteen source files and their harness rows changed;
the send-reference source already had a bare root return and needed only its
diagnostic expectation corrected. Translator/runtime bytes did not change.

The remaining failure is `unit_value_call_sub_refused`: `g(s)` still rejects
the non-returning callable as having no value before checking the receiving
int formal. The row expects the common incompatible-argument diagnostic, not
the withdrawn blanket ban on sub references. Read-only inspection confirmed
that ordinary reference-formal transport also reaches the wrong value-call
route. This is recorded as SUB-ACTUAL-REFERENCE-CLASSIFICATION in
[the defect list](defects.md); neither production code nor the expected rule
was weakened to obtain a green fixture count.

Counterfactual evidence:

- `diagnostic14_counterfactual_20260930_01/summary.txt`: eleven corrected
  negatives translate; both inverted positive readback/sizeof comparisons
  fail at runtime. These failures prove the positive witnesses execute their
  assertions; the unmodified witnesses both return success 7.
- All eleven corrected negatives subsequently pass L1 translation and C99
  compilation individually, including all four `2147483647` overflow controls
  and raw `c.sizeof(c.int)`. No invalid program was executed.
- The original untyped sender-path control exposed an unrelated pre-layout
  limitation; it is not positive evidence. The final typed MainLetter sender
  control separately passes both translators and C99 compilation in
  `diagnostic14_counterfactual_send_20260930_01`.
- Commands, per-case logs and object paths are in
  `diagnostic14_counterfactual_20260930_01/counterfactual-results.txt`
  (SHA256 `46021382CDEACF62316403E54AF2BBDDA470DA7B886E046C90CFFCD72E5728E0`).

All fourteen positive/negative fixture files were restored before the final
focused gate and match its staged bytes. Scoped diffcheck passes. Final
translator source SHA256 is unchanged
`0D25E51BA38B077989168BA3202FB3F9A3DD2E2A45D30BC10D5B4F8C041B4C78`;
harness SHA256 is
`E5403BDE151CD1D73897B0C4FEFAB24BD92062C16D33A4DD1C67B98B8B591CBA`.
The pinned L1 executable is bootstrap evidence only, not an L2 self-build.
These focused results do not certify the full generated corpus or close
sections B–D.

<a id="scope-evidence"></a>

## Scope and evidence

This is an implementation worklist, not a language specification. It classifies the **43** rows reporting `refused, but not with ...` in the frozen generated-harness run:

```text
C:\Nyasha_Planet\LMX\build\l2_harness\after_return_full_20260930_01\summary.txt
```

For each fixture stem below, the exact evidence is:

```text
<run>\src\<stem>.lm2
<run>\logs\fixture.<stem>.l2trans.log
```

The frozen translator is `<run>\src\l2src\l2trans.lm1`, recorded by that run as Git blob `9d5fc38fed49153379a3718493cf0d2a5f6cc79e`. Translator symbol line numbers in this note refer to that frozen file unless explicitly marked current. Windows PowerShell wraps native error text; reconstruct a diagnostic across line breaks before comparing it.

At audit time, all 43 fixture files in `build/opus_wt/dev/l2src_sandbox/tests/` were byte-identical to their frozen copies. The translator and harness have subsequent changes; the frozen refusal is evidence of that run, not a claim about a later executable. This audit ran no translator, compiler, or test.

- **34** rows were preempted by `return with a value in a callable that returns nothing` at the file root. That diagnostic is correct for those written returns, but it does not test the property the fixture intended.
- **9** rows reached another first-order diagnostic.
- The implementation partition is **14 + 13 + 10 + 6 = 43**: independently fixable current-contract candidates; raw-C/string migrations; withdrawn unknown-head assumptions; production gaps or obsolete-construction combinations.
- None of these is one of the separate 19 generated-text/graph-observer migrations. Do not expand this ticket to those rows.

The counts classify evidence; they do not mean 43 defects have been fixed or that all proposed fixture corrections are already known to pass.

<a id="current-contract-14"></a>

## A. Independently fixable current-contract candidates: 14

### A1. Five negative tests masked by unrelated root returns

The minimal correction preserves the intended negative property. Do not replace its expected diagnostic with the observed void-return error. After correcting the source, keep a newly exposed production failure visible rather than weakening the assertion.

| Fixture (`.lm2`) | Intended witness | Frozen actual | Minimal correction and counterfactual |
| --- | --- | --- | --- |
| `unit_s2_vis_branch_refused` | A qualified branch below a method does not supply that method's unresolved lexical input. | Void-return rejection at `16:5`. | Replace the root conditional/value-return tail with the same `read_branch()` call and bare return. Preserve the missing-`cfg` diagnostic. Counterfactual: move the branch before the method; the intended unresolved-input diagnostic must disappear without an unrelated refusal. |
| `unit_value_call_sub_refused` | `g(int)` cannot obtain an integer result from the non-returning `s`. | Void-return rejection at `14:1`. | Use the expression `g(s)` followed by bare return. Correct the stale comment: the specification allows a non-returning callable to be passed by reference; that does not make its reference an integer result. Preserve the incompatible-actual rejection, not a claim that sub references are forbidden. Counterfactual: pass an integer to `g`; the intended failure must disappear. |
| `unit_arg_addr_dyn_nocell` | A foreign by-value `c.LmP0Text` cannot travel through the existing dynamic-input value-cell mechanism. | Void-return rejection at `18:1`. | Change final `return: 0` to bare return; retain `outer` and `leaf`. Counterfactual: replace the foreign by-value formal with supported `int`, preserving the dynamic-input route. |
| `unit_colon_graph_unknown_value_refused` | Unknown RHS of a known graph-reference assignment. | Void-return rejection at `6:1`. | Make the final return bare; retain unresolved `missing_graph`. A bounded valid control can assign literal `0` instead of the missing reference. |
| `unit_invalid_implements_used_field` | The candidate lacks `equals`, which the receiving callable actually uses. | Void-return rejection at `17:1`. | Replace root `return: takeEq(Plain)` with expression `takeEq(Plain)` and bare return. Counterfactual: add the required typed `equals` field to `Plain`; preserve the receiving method's use. |

The original expected diagnostics and exact locations must be rechecked after the source edits. The `sub` test must not introduce a new argument-classification rule to preserve an old phrase.

### A2. Four overflow negatives

| Fixture (`.lm2`) | Frozen void-return location | Intended property to retain |
| --- | --- | --- |
| `entry_overflow` | `2:5` | Int result literal range in the explicit L2-profile form. |
| `unit_return_literal_body_overflow` | `2:1` | Int result literal range in an ordinary body containing another statement. |
| `unit_return_literal_entry_overflow` | `5:1` | Int result literal range with another declared method in the unit. |
| `unit_return_literal_trailer_overflow` | `4:1` | Int result literal range in trailer form, with another method present. |

These fixtures currently put `2147483648` in a void root return. Place the overflowing return inside an explicitly `int`-returning `fn`, retaining the respective profile/body/trailer/beside-another-method distinction, and invoke it from a valid void root. A root cannot acquire an int result contract merely to preserve these tests.

Keep the intended `literal not representable as int` assertion. The counterfactual `2147483648` to `2147483647` must pass translation, not merely change the first error. Do not let the common void-return guard mask representability again.

### A3. Two formerly blocked positive tests

| Fixture (`.lm2`) | Frozen actual | Required positive witness and mutant |
| --- | --- | --- |
| `unit_named_addr_gap` | Void-return rejection at `20:5`. | The write through `@: A\e` must be followed by direct readback of `A\e == 9U`. Replace failure/success tails with exit messages and a nonzero success code. Preserve the readback; an inverted comparison must fail. The separate qualified-eternal address negatives remain negative. |
| `unit_own_find_last_sizeof` | Void-return rejection at `22:5`. | `bump` must resolve lexical `x` and return its size, equal to `sizeof(int)`. Replace root valued returns with observable exit messages. Preserve the comparison; its inversion must fail. This witnesses successful lookup, not which of two equivalent lookup helpers supplied it. |

Do not turn either row into an expected refusal. Native execution now makes their original runtime properties independently testable; actual success still needs a focused gate.

### A4. Two diagnostic refinements

- `unit_send_ref_root_type_refused`: actual `7:14: a Ref that is not a reference`. The operand really is `int n`. Remove only the obsolete `root operation not walkable yet:` prefix from the expected diagnostic. A corrected counterpart must supply a genuine sender reference. This is **not** the Message-versus-Thread case in section D.
- `unit_csizeof_type_frame_refused`: actual `5:19: unresolved addressable name`. `c.sizeof(@: void)` supplies an ordinary L2 address expression, but there is no addressable value named `void`. The more precise address-resolution diagnostic is valid; it is not special semantics for `sizeof`. Also remove the unrelated final valued root return. Counterfactual: ordinary raw-C `c.sizeof(c.int)` must translate and compile under the raw-C contract.

### A5. One unrelated conversion obstacle

`unit_asgn_fallback` intends to reject the root's `inc()` at `21:1` because no root binding supplies hidden input `x`. The frozen actual is at `14:5`:

```text
the program has no method `lm_stg_convert_int_char`, the receiver of this conversion
```

C99 char promotion makes `x + 1` an int expression; assigning it back to char needs the unavailable converter before the intended missing-input check. The fixture's property is scope, not char conversion.

Change `first_x`'s local and `with_caller`'s formal from `char` to `int`. Preserve the root `inc()` and its unbound-input assertion. Counterfactual: declare root `int: x` before that call; the intended diagnostic must disappear. Do not alter the primitive conversion table to repair a scope test.

<a id="raw-c-13"></a>

## B. Raw-C and string migrations: 13

All 13 are masked by valued returns in void E. Their former `L2 operation outside a method body` expectation is obsolete under uniform native compilation.

### B1. Three wrong-C-ABI negatives: compilation only

| Fixture (`.lm2`) | Intended C constraint |
| --- | --- |
| `entry_puts_bad_arg` | `puts(1)` passes an integer where the declared C function needs a character pointer. |
| `entry_puts_extra_arg` | `puts("a", "b")` supplies too many arguments for the C prototype. |
| `entry_puts_nested` | The outer `puts` receives the inner `puts`'s integer result. |

Make root returns bare and provide explicit `<stdio.h>`. Require **both translators to succeed**, followed by the intended **C compilation constraint failure**. Never execute these invalid programs. Use `-Werror=int-conversion` for the bad/nested argument cases; the extra-argument case is a prototype constraint. Corrected argument/arity counterfactuals must compile.

The existing `toolchain-refuses` mode is insufficient unchanged: it treats an arbitrary L1 translation failure as success, and its `$kflags` do not make integer-to-pointer warnings fatal. Any harness addition must be a small generic compile-only constraint expectation that requires generated C and matches the intended compiler diagnostic. It must not add C-name knowledge, a `puts` exception, or a blanket acceptance of unrelated compile errors.

### B2. Ten valid runtime/output witnesses

| Fixture (`.lm2`) | Property to preserve |
| --- | --- |
| `entry_puts_triple` | Decoding an internal run of matching quotes. |
| `entry_puts_triple_lead` | Leading double quote as raw-string content. |
| `entry_puts_triple_lead_sq` | Leading single quote as raw-string content. |
| `entry_puts_triple_long` | Full long raw-string length and content, without truncation. |
| `entry_puts_triple_runs` | Mixed one-, two-, and longer matching quote runs. |
| `entry_puts_triple_seven` | Double-quote opener followed by a longer content run. |
| `entry_puts_triple_seven_sq` | The corresponding single-quote form. |
| `entry_puts_triple_single` | Internal longer run in the single-quote form. |
| `entry_ret_tr_puts` | Exact `MUST PRINT` output before a valid bare root return. |
| `entry_ret_tr_two` | Exact `one`, then `two` output ordering before return. |

Replace the invalid returns, then assert exact stdout. Derive triple-string bytes from [grammar section 7](../docs/LMX_grammar.en.md#raw-quotes), not from whatever the current emitter happens to produce: a content run of N >= 4 matching quotes contributes N - 1 quotes. Preserve leading content, both delimiter kinds, mixed runs, and length. A changed decoded character or dropped output must fail the witness.

Leave the separate `entry_puts_triple_fence4` parser-debt row unchanged; it is not in this 43-row inventory.

### B3. Pending harness mechanics and exact expectations

The following is the prepared implementation design, not measured coverage. The fixture bytes to edit are the authoritative active-worktree inputs under
`build/opus_wt/dev/l2src_sandbox/tests/`; `tools/l2_harness.ps1` stages those files for a run. Do not infer the pending fixture state from the stable/mirrored
`l2src/tests/` tree. A final gate must name the staged source and translator bytes it actually used.

For the three compilation negatives, add one generic product-step helper that removes a previous product, invokes the tool exactly once, and returns the
actual process exit code together with whether a fresh nonempty product exists. Preserve `Step-Made` as the small compatibility adapter with its existing
product-existence behavior for all current callers. Only the new compile-constraint expectation is strict: L2 translation and L1 translation must each exit
zero and produce a nonempty output, then C99 `-fsyntax-only` compilation must exit nonzero and contain every row-specific diagnostic fragment. The
bad-argument and nested-result rows add row-local `-Werror=int-conversion`; the extra-argument row relies on the prototype constraint. The harness facility
knows no C function name and supplies no language fallback. The rows, not the translator, identify their intended diagnostics. No invalid program is linked
or executed.

For the ten positive rows, use the established nonempty root witness
`sendMessage: exit(exit_code: 7; stdout: ""; stderr: "")` followed by bare `return`. Require process exit zero, driver entry 7, native-root attachment, and a
scoped exact-output property. This property must normalize only platform line endings (`CRLF`/`CR` to `LF`), remove the two positional harness header lines
and the positional terminal `exit: N` line, require exactly one successful driver-completion line with no suffix, and compare the complete preceding program
payload case-sensitively. It must not discard empty lines or filter lines by their text. Keep the older line-oriented `Says` behavior unchanged for its
existing consumers.

The grammar-derived exact payloads below include the newline written by `puts`; `x` repeated 100 times means exactly the 100 `x` bytes already present in
that fixture's raw literal, followed by one `LF`:

| Fixture | Exact normalized program payload |
| --- | --- |
| `entry_puts_triple` | `a"""b\n` |
| `entry_puts_triple_lead` | `"hello\n` |
| `entry_puts_triple_lead_sq` | `'hello\n` |
| `entry_puts_triple_long` | `x` repeated 100 times, then `\n` |
| `entry_puts_triple_runs` | `a"b""c"""d\n` |
| `entry_puts_triple_seven` | `"""x\n` |
| `entry_puts_triple_seven_sq` | `'''x\n` |
| `entry_puts_triple_single` | `a'''b\n` |
| `entry_ret_tr_puts` | `MUST PRINT\n` |
| `entry_ret_tr_two` | `one\ntwo\n` |

Pending counterfactuals are part of acceptance, not current evidence. Correct `puts(1)` to a string argument, remove the extra second argument, and replace
the nested integer result used as the outer argument with a valid string argument; each corrected program must pass both translators and C99 compilation
under the same row flags. Output mutants must change a decoded character, reverse or drop an output line, and inject an extra blank line. Harness mutants
must remove and duplicate the driver-completion marker. Strict-product mutants must make either translator fail after leaving a product path, and the C
negative must reject an unrelated compiler diagnostic that does not contain the row's intended constraint. Restore the exact positive and negative fixture
bytes before the final focused run.

<a id="unknown-head-10"></a>

## C. Withdrawn unknown-head assumptions: 10

The following fixtures all have a masking void-root return, but their intended refusal additionally assumes that an unknown head cannot define a Structure:

1. `unit_s2_vis_structure_below_refused.lm2`
2. `unit_next_message_word_refused.lm2`
3. `entry_ret_tr_bad.lm2`
4. `unit_universal_absent_paren.lm2`
5. `unit_universal_absent_colon.lm2`
6. `unit_universal_absent_vertical.lm2`
7. `unit_decl_unknown_type_refused.lm2`
8. `unit_colon_undeclared_refused.lm2`
9. `unit_matrix_absent_prim_refused.lm2`
10. `unit_matrix_absent_arrayish_refused.lm2`

Examples include `idle: 1`, `Nope: x`, `arg: 7`, and absent `buf(3)`. Do not repair these by pinning the observed void-return diagnostic or by preserving a withdrawn unknown-head refusal as a language rule.

Re-author the intended visibility/form-equivalence/no-special-receiver witnesses in the declaration/resolution slice, respecting [Q57](../LMX_blog/q/q57.md). The later answer [Q58](../LMX_blog/q/q58.md) preserves a known nested callable's ordinary operator in the complete tree without executing the outer definition; no separate saved-call object is introduced. Not every unknown-head row itself requires a new author decision, but none belongs to a mechanical tail-only migration.

`unit_next_message_word_refused` can eventually become a positive ordinary-binding witness that `nextMessage` is not reserved. Failure of its present absent-head form is not proof of that property.

<a id="production-gaps-6"></a>

## D. Production gaps or obsolete-construction combinations: 6

### D1. `unit_send_ref_root_fail`: pre-layout reference misclassification

Frozen actual: `5:14: a Ref that is not a reference`. Intended witness: the reference returned by `receiveMessage: m` is a plain Message, not a Thread addressee, so the Message-versus-Thread check must reject it. It must not pretend `m` is a non-reference.

Concrete frozen source path:

- `l2_check_body:20092` calls `l2_msend_register`.
- `l2_msend_register:26343` uses `l2_rw_fields_ty` to classify the addressee.
- `l2_rw_own_ty:23009` requires assigned graph-layout metadata, including nonnegative `l2_own_uchild`.
- `l2_layout_owns` runs later in `l2_emit_unit:32834`.

Thus a pre-layout semantic check relies on post-layout walker metadata and misclassifies a real reference. The relevant path remained in the current translator at audit time. Fix the common semantic typing dependency, not the expected message. Preserve the companion integer-negative test and successful sender-reference tests. A mutation removing addressee type admission must not pass the negative witness.

### D2. `unit_capture_struct_whole_refused`: captured whole-Structure lowering

Frozen actual at `22:17`:

```text
a callable merge needs a walkable body: root operation not walkable yet: a Structure argument that is not a field's name
```

The old expectation was throwing-body ineligibility at `21:5`. The captured-whole-Structure lowering gap is now reached first. The fixture also uses withdrawn implicit `Model: loc` construction and Q57-sensitive `r40: makeReader 40`.

Do not replace the expected phrase alone. Establish an explicit current-contract construction/capture witness in the relevant production slice, then test passing the complete retained Structure to `probe` and preserving the returned result. A field-only capture must not accidentally satisfy the whole-Structure test.

### D3. `unit_walk_d105_nested`: nested correspondence/admission

Frozen actual: `25:6: an admission to a Structure type through a Structure field of another type`. This is the same underlying nested-correspondence limitation without the obsolete root-walker prefix.

The fixture still constructs through `Other: o`; prefix replacement does not close its semantics. Its receiving method only reads `m\a`, so a blanket requirement to admit unused nested `x` also needs consumer-aware review. Re-author explicit current construction and distinguish a consumer that actually traverses nested `x` from one that does not. Do not turn the old implementation limit into a normative refusal.

### D4. `unit_value_formal_call_refused`: obsolete formal distinction

Frozen actual: `12:5: graph assignment admission requires receiving-expression tests`. The old fixture treats `(Model: v)` as callable but `(@: Model v)` as a different reference class. Accepted nonprimitive signature semantics makes those forms synonyms.

Rebinding/admission must be tested with explicit current reference construction. Both `Model: w` and `Model: mo` are withdrawn implicit constructors. The old call-refusal expectation is invalid. A repaired witness must compare both signature spellings under the same assignment/admission operation, not assert a difference between them.

### D5-D6. Terminal Structure-path handling

- `unit_field_path_struct_rebind_refused`: actual `22:1: a field path must end at a primitive field`.
- `unit_matrix_path_struct_rebind_refused`: actual `13:1: a field path must end at a primitive field`.

Terminal nonprimitive-path handling remains a production gap. Both fixtures additionally rely on implicit `Outer: o` / `Model: a` construction and `Model: inner`. Update setup to explicit composition/reference declarations in the production slice; use an explicitly reference-valued target when testing rebinding, rather than silently treating a callable Structure field as an assignable reference binding.

Preserve actual target admission and a readback proving the reference changed; an incompatible candidate must fail. Do not canonize the current primitive-only limitation by changing the expected text alone.

<a id="writer-boundaries"></a>

## Writer boundaries and acceptance

1. Start with section A's **14 rows**, modifying only their fixture files and corresponding harness rows. This is a candidate bounded ticket, not evidence they already pass.
2. Migrate section B's **13 rows** separately. The three wrong-ABI cases require a narrow generic compile-only constraint facility; the ten valid cases require exact output witnesses.
3. Keep sections C and D's **16 rows** outside those fixture-only tickets. They depend on declaration/resolution decisions or actual production repairs.
4. Do not change the translator/runtime to force a fixture-only ticket green. Report any newly exposed production failure with exact source and generated artifacts.
5. Every negative counterfactual must eliminate the intended failure without merely substituting an unrelated parser/type/compiler failure. Every runtime witness must reject an inverted expectation or a mutation removing the observed property.
6. Preserve exact restored source bytes, then run a final focused gate on those bytes and scoped `git diff --check`. A focused run is not a full-corpus certificate.

Use the existing `-OnlyFixture` interface from PowerShell, for example:

```powershell
& .\tools\l2_harness.ps1 -KeepAll `
  -OutDir C:\Nyasha_Planet\LMX\build\l2_harness\diagnostic_tail_migration_20260930_01 `
  -OnlyFixture @('entry_overflow', 'unit_return_literal_body_overflow')
```

Choose a new output directory for each final run or mutant; do not overwrite frozen evidence. Run only after acquiring the sole writer/build slot. This document grants no slot by itself.

### Nearby evidence that is not part of the 43

- `unit_ptr_local_scope` and `unit_unsigned_ptr` were previously unregistered source probes, not green rows in the frozen full harness. Their separate diagnostic runs exposed respectively a valued root return at line 34 and a missing int-to-size_t converter at line 7. Do not cite them as unchanged positive regressions or count them among these 43. The newer pointer-declaration witness covers the intended null cases separately.
- The subsequent pointer-null correction uses the existing integer-literal decoder and checks zero magnitude, rather than admitting numeric variables or arbitrary numeric-to-pointer conversion. Full C99 integer constant expressions and remaining unsupported literal spellings remain explicit common debt; this note does not declare them implemented.
- The subsequent raw-C dependency patch distinguishes opaque raw-C results from numeric literals and retains typed Structure referent admission. Its focused evidence does not rerun or close this entire 43-row inventory.
- The 19 safe generated-text graph-observer migrations have a different owner and acceptance boundary. No row is silently transferred into that work by this document.
