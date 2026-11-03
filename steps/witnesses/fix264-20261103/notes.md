# Slice 264 — explicit code and data at the reached call

The compiler emits both written operands once. The kernel checks the selected
body's throws and the required data places, and scopes the admitted addresses to
the activation. A recursive or nested call restores its enclosing map on return.
A copied executable retains its compiled place interface. The 44 M2 forecast
functions, their closure state and producer exports have been removed. The older
address-escape and immutable-call forecasts have also been removed.

| Control | Observed result in native and forced execution |
| --- | --- |
| Formal data and held code | The actual formal data receives the write. A single held call changes x from 3 to 4, then y from 10 to 12 after rebinding. Padding remains 5. |
| Admission before entry | A missing declared place or an ambiguous unindexed head takes the caller's call handler before the body changes the data. |
| Nested calls and copy | Both outer calls update the supplied D. The original lexical Other ends at 13 when the second callable uses its copied graph, and at 16 when it receives the original Other explicitly. |
| Addressed copy | The original unit_copy_call_addressed control gives 7 on both roots. |
| Qualified code and data | Both fixtures with one qualified root passed in both modes and both root settings. |
| Model write | A nonconforming nested Structure takes implements when its write is reached. The earlier flag write is visible and the rejected field keeps its old value. A subsequent compatible write uses the same declared model after a previous rebind. |

The 178 frozen and installed source inputs match. The quick bootstrap took
766.90 seconds with smoke 9/0 for G1 and G2. The promoted G2 tuple passed
all 26 focused rows. Rehashing the real inventories gave 248 artifacts
per generation, 245 raw-equal and 3 PE differences confined to the
timestamp or checksum fields. The working bundle matches G2.

| Artifact | SHA-256 |
| --- | --- |
| Input list | `F6CCC5855DE67626D50819BA14C487D950D86A0959EF0C0C473028DB0C3046D3` |
| Input manifest | `35E501526D2BD1B1D2B54BECD626201A3F2A040259BB35C01847691007A65E8E` |
| Working tool | `CE43E24F740D7083C2C5D524DEAEC1A6FC8253AE2039420ADDA860A566B2EFD2` |
| G2 frontend | `BDCC42FF6C9CA0AA895DD7D0197A623FC0F7CECDC0D7775BFFC839AB2228AE1C` |
| Production runtime | `1DB4884783710CD4424F2FCF23A32A7A015BEB77EBD88BFB371B23BD7F4DBB1A` |
| Observation runtime | `F4EAFB53512301BFB64BAA0CC53D1884CB87D014ECBAF8DC0BD10B94803FB756` |

[Bootstrap](records/boot126a-quick.terminal.txt) · [generation comparison](records/boot126a-compare.txt) · [G2 focus](records/tp126-suite-g2.terminal.txt) · [model controls](records/tp126-model-07.terminal.txt) · [copied data](records/tp126-binding-07.terminal.txt) · [landing](records/land264.terminal.txt).

Remaining work includes lifting the specialized lowering for all dynamically
selected code with nested declarations, paths through unrestricted free roots,
model and descriptor coverage, the remaining compiler closures and the shared
collector. The final FULL and §§8/8a remain open.

The promoted G2 documentation check verified 35 paired semantic chapters, 14 implements cases, 615 imported files and index line endings for 15357 tracked files. [Documentation check](records/docs264-check.log).

## Development record


The base is published slice 263, commit 24d5c8291447c70bd6fbc5f477fbae7238b1e816. The selected code and data
are independent operands of the same call. The currently generated native
prologue and the walker select a precomputed slot row by the data layout token.

## Baseline with the self-built 263 G2 tuple

The exact receipt is `pins/tp126-split-base-01.terminal.txt` under
`build2/codex_fix250generationchain01`. The five-row suite and its fixtures
are in `tp126-split-baseline-01`. All expected results are 7 in native and
forced modes on both roots.

| Case | Actual result |
| --- | --- |
| unit_n4_split_address | Pass on both routes. Take the address of x in the supplied data while preserving pad. |
| unit_n4_split_admission_before_body | Pass on both routes. The caller catches the failed admission before the first body write. |
| unit_n4_split_free_name | Pass on both routes. The caller supplies the free k independently of the data field k. |
| split_formal_data | Both translations refuse at 10:13. The compiler requires proof of the formal d's layout. |
| split_selected_code | Both translations refuse at 17:5 at the call with a held code operand. |

Selection currently stops in the frontend. `lm_compiler_check_call_data`
requires `m2_fixed(place)` for data. The generated address example contains
the row [4, 0] under a layout token. Native and walked entry consume that row
through `lmx_implements_places`. The plan replaces this layout prediction
with the required fields of the selected code and the correspondence to the
actual data. Resolve once at admission. Both executors then address the same
physical slots. Keep the three passing controls and the historical refusal
receipts. The source of 263 remains the verified starting point.

## Actual layout of a formal data argument

On source fix02 the frontend emitted the names and machine types of the code's
declared data places. The shared kernel resolved these against the actual
data occurrence at the call. On fe126b/rt126a the formal data fixture passed
in both modes and on both roots. All three previous positive controls stayed
green. The held code operand was the one remaining translation refusal in
that five-row run. Both modes also caught the ambiguous repeated root head and
the missing declaration in a branch before its body started. An inline
declaration used the supplied data slot.

The two qualified fixtures each declare one independent root. The ordinary
suite passes expected root count zero. Its eight driver failures stopped at
that count check. The same four binaries with expected count one all passed
in both walkroot modes. No compiler, source fixture or driver was changed for
that run.

| Operation | Receipt below `pins/` |
| --- | --- |
| Formal data, three original controls, held selector | `tp126-split-02.terminal.txt` |
| Repeated name, branch, inline declaration and qualified invocation history | `tp126-names-02.terminal.txt` |
| Two qualified programs with their actual root count | `tp126-qualified-02.terminal.txt` |
| New package tool for the selected-code candidate | `tp126-tool-01.terminal.txt` |

The next candidate removes the M2 closure invocation from the frontend and
keeps the same current-code dispatch for both Structure call forms. Both
operands are held before publication. A stack-scoped coordinate map belongs
to the call, restores its parent after dispatch, and admits the actual selected
body before entry. The new tool built successfully. Verification of this
candidate and its copied interfaces is still in progress.

## Selected code on fix05

The single explicit call site now evaluates the first operand, holds it, then
evaluates its data. Both executors pass the pair to the same kernel dispatcher.
During admission the dispatcher records the physical places of this call and
restores the enclosing map on return. Its compiled input requirements belong
to the selected occurrence and copy along with it. A regular held code
occurrence uses the names and actual types on its physical root data slots.
The old M2 forecast, its state and its producer exports were removed. The
frontend also dropped the check which refused an addressed copy.

On fix05 (`e9acf95365fe3e9bafd5bbd74cf48bc9c0af5198028101b89a03061bb2a1b66c`),
the five split rows, three declaration/admission rows, the addressed-copy
case and the 21 previous regressions passed. The four qualified binaries also
passed, each in both root modes. The existing `unit_copy_call_addressed`
now gives 7. The original and rebound bodies in `split_selected_code` update
x and y of the selected data while pad stays 5.

In a nested split the original inner call changed Other.y from 10 to 13
and the outer data x from 5 to 7. Calling a copy then left the root
measurement at 193 (20*x + Other.y), while a fixture that explicitly passed
the inner data through a formal gave x = 9 and Other.y = 16. The original
test's expectation that the copy would update the root lexical Other is
preserved as a failed diagnostic. A paired check separates the copied
lexical graph from the caller-provided data.

The graph-valued destination tests found a genuine regression which prevents
landing this candidate. On the published G2 all four original fixtures passed.
On fix05, native failed to reject the incompatible graph value. Forced
execution failed during layout selection in three fixtures. `tp126-model-05`
records all eight failures. The earlier emitter selected an admission by a
predicted data layout. Fix06 instead records the receiving declaration's model
on its physical slot. Native and walker use one actual field admission when
the write is reached. The source manifest is
`1d2e76daf683d447bbda6b956626a4b8f28999faa94252b6f5d099b5ed4d944f`.
The candidate tool `tool126c` rebuilt successfully. Its runtime, frontend and
focused results must be checked before accepting that change.
