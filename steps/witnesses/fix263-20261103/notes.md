# Slice 263 — selected Structure calls and numeric receiving places

The unary `call: code` now enters the actual selected occurrence through
`lmx_call_selected_structure` on both routes. A named Structure carries its
own hidden input names through copy and merge. Its physical fields keep their
original ordinals. At a reached call the common kernel checks the selected
callable's declared throws before dispatch. Missing required formals raise
`implements` before the first body write.

| Checked case | Result |
| --- | --- |
| Written numeric place and exit letter | An int arrives as 7. Passing a pointer triggers the caller's convert handler in both operations. |
| Same call through a name and a held reference | With one free input it returns 3. After rebinding, the two inputs of the selected body sum to 9. |
| Declared Bad with and without an enclosing handler | The refused body leaves the counter at zero. The admitted body can complete or throw Bad with payload 5. |
| Missing required argument | The attempted entry leaves the counter unchanged and raises implements. |
| Static unhandled call inside Counter | The existing unit_named_struct_throw_refused fixture gives its expected translation refusal for Oops in both modes. |
| Regression and final focus | 18 existing regression rows passed. fe125d/rt125i and the self-built G2 tuple each passed all 21 final rows. |
| Actual copy/merge | Three paths ran the copied occurrence in both modes and both roots, updating only the copy. The nested copy with an explicitly qualified root saw the caller's 7, the direct root case saw 13, and the simple copy saw the caller's 7. |
| Observed invocation after rebinding | In each native root the invoking methods first used their native bodies. After rebinding both walked once. Forced execution walked each twice. The stable note and read_seen bodies ran four times in forced mode and zero times via the walker in native mode. |

The generic os-walk witness initially expected zero walked invocations even
after rebinding. Its four route mismatches are preserved in the first receipt.
All program exits in that observation were 7. The second observation measured
the stable helper bodies. A separate failed component probe also remains open.
Inside a method, an unqualified `Copy\Inner` through a free merge-result root
is refused during path lowering. The explicit `node\Copy\Inner` control succeeds.

The quick bootstrap took 807.96 seconds. Both generations passed nine smoke
rows. Rehashing 248 paths in each inventory found 245 byte-identical
artifacts and 3 PEs differing only at timestamp or checksum bytes. G1 and G2
consumed the same bytes and the working tool and bundle match G2.

| Selected artifact | SHA-256 |
| --- | --- |
| Input list | `41E70A3EE8717678FA0A45C133166639ED116D2302F4AECC317EF69B96BCC7EF` |
| Input manifest | `48951CA277B822FF35997A07D33AA72D44660044276DE5A0A9B563A4316E6EC2` |
| Working G2 tool | `9E5798D8BD55E57A89242FDAD0624C2AF9BDF5CE27396624A79F72DCEA0766EA` |
| G2 frontend | `567EDCE7D75B6C8A79EA245640FDA2D7CDA78E11DD5D2148E60B96CFF14AE7A2` |
| G2 runtime | `A05DB426EECB50A079615944DCC23363B57438C9562AB194F721ED0DD26C68AC` |
| G2 observation runtime | `2EC4A637D0B7B6BF4523C7899557C4677D8B05BFDCFC91B4901D31967A271E33` |

[Bootstrap](records/boot125a-quick.terminal.txt) · [generation comparison](records/boot125a-compare.txt) · [G2 focus](records/tp125-suite-g2.terminal.txt) · [static throw](records/tp125-static-01.terminal.txt) · [copy controls](records/tp125-copy-02.terminal.txt) · [observed execution](records/tp125t-obs-02.terminal.txt) · [landing](records/land263.terminal.txt).

The explicit `call: code data` still requires a body certificate and a table of
known data layouts. The next step is runtime admission of that selected pair
and its address map. Common collection, three compiler traversals, the final FULL
and §§8/8a remain open.

The promoted G2 documentation check verified 35 paired semantic chapters, 14 implements cases, 615 imported files and index line endings for 15183 tracked files. [Documentation check](records/docs263-check.log).

## Development record

Published base `e6df40d97074903ca8f6e561cc979e48908bb3ab` is slice 262.
The single pipeline is owned by Codex. All paths below are relative to
`build2/codex_fix250generationchain01`. The candidate is `variants/tp125`.
The original probes are in `tp125-call-probe-01`.

## Baseline on published slice 262

The four-row baseline used the actual 262 working tool, G2 frontend and runtime.
`unit_empty_pointer_rebound_call` already runs B and exits 7 through both roots
and both executors. Three other cases had the same translation refusals in
native and forced mode. The exact record is `pins/tp125-structure-before-01.terminal.txt`.

- Reading a root-bound free name for the message's declared int payload reached
  the raw-value emitter (`unit_named_struct_call_method_rebound_hidden`).
- Assigning a free value to the typed declaration's place in `seen: total`
  stopped at `lm_compiler_check_receiving_value_at`.
- The held-pointer expression in `call: target` had no supported selected-place
  route inside the method. The companion `struct_named_selected.lm2` uses the
  named place directly. It reaches exactly the M2 refusal “the current Structure
  body is not proved at this call”. One call site must first read first_key and
  later read second_key plus add_key from the caller (3, then 9).

## Checked changes

The frontend allows a FREE source into a written numerical receiving place.
Native message emission uses the existing numeric receive at its int field.
An initial component run passed the named rebound body in both modes, but the
walked message's wrong-kind argument still gave INVALID. A debugger trace from
the built forced binary showed the earlier assignment's caught convert (11),
then `lmx_walk_argument_storage` returning INVALID (1) from `lmx_walk_prim`.
See `tp125-call-probe-01/diagnose-02` for the compiler traces and
`tp125-call-probe-01/diagnose-03/forced-actual.log` for the runtime trace.

The primitive now admits a present argument with a numeric witness through
`lmx_walk_value_receive` before the physical ABI storage check. Other kinds of
witness follow their existing paths. The shared receiver reports convert for
a present foreign value of an incompatible base type. Both executors now catch
a pointer supplied as an int at the assignment and at the message field.
A matching int reaches the actual letter with exit code 7.

| Immutable operation or input | Result |
| --- | --- |
| Prepared candidate, three changed files, 170 inputs | `D9DD8C0CBA1BC0E2741D28E4C412FEFF133DB51B83D4F0D98A15DFE50DA35988` |
| `pins/tp125t-fe-01.terminal.txt` | fe125a, `6425C1533A5BF766EA8EBB1C3C1E64776791F5FA1D4B7EDE71ADCCB0588FE75B` |
| `pins/tp125t-rt-01.terminal.txt` | rt125a production `CE04B42A9FC6E1C17DA75BCCD5120DF5EC48FE487E3B6772BC357B6BB6A21F7D` |
| `pins/tp125-receive-01.terminal.txt` | Intermediate. The forced wrong-kind message stopped with INVALID. Both direct named-Structure gaps reproduced. |
| `pins/tp125-numeric-02.terminal.txt` | 2 rows, 0 failures, each built natively and forced and ran on both roots. `free_number_places` and the historical rebound body both exited 7. |
| `pins/tp125-focus-01.terminal.txt` | The 18 regression rows on fe125a and rt125a all passed, ending 01:02:47 UTC on 2026-11-03. |

## Intermediate result before the input map fix

The original `unit_named_struct_hidden_input` now translates, but gives 0
where the author’s existing case expects 7. Its native and walked calls need
the selected Counter's real free input and its caller's active binding.
An ordinary named Structure contains its own data and executable statements.
The emitter skips a synthetic args header for it (`lm_compiler_rw_header_parts`),
while `lmx_activation_input_cell` addresses a fn/sub header. The current native
call site still uses `ns_proc[ni]` and `m_dyn[pr]`. The walked EXEC still embeds
the predicted contract. Replace these dependencies using the actual selected
occurrence, preserve ordinary field ordinals, entry snapshots and explicit
split-data admission. Verify the two successive selected bodies at one call
site before removing the M2 preflight. The production sources in `selfbuild`
remain the verified 262 package.

The generated native caller binds `total`, passes a FREE row, and the selected
Counter prologue calls `lmx_activation_resolve_input` for slot zero. The
debugger trace in `tp125-call-probe-01/diagnose-04` records the same three
resolution results (1, 0, 0) in both executors of the original case. The
comparison still returns 0. A true selected input map for an ordinary
Structure must cover the physical occurrence used by both calls.


## Ordinary Structure owns its free input map

Fix06 added ordered input names to the arena's existing physical source-name
service. Port zero retains the ordinary occurrence/field spelling. Positive ports
name the input cells of a named Structure. This preserves the source-visible
field ordinals. Copy and merge prepare the source-name rows together and only
publish them once the destination graph succeeds. The existing copy/merge ABI
is preserved. The selected named Structure's entry projects its own missing
rows and resolves them through the existing caller activation chain.

The tool was rebuilt as tool125. rt125b failed its C compile because an existing
merge consumer still required the public copy function's original signature.
The private per-spelling implementation and retained public wrapper produced
rt125c. fe125b stopped at a missing local FILE output declaration in the new
emission clause. fe125c compiled the corrected source. Component receipts are
`pins/tp125t-rt-02/03.terminal.txt` and `pins/tp125t-fe-02/03.terminal.txt`
(the two suffixes denote distinct files).

On fe125c/rt125c the author's original `unit_named_struct_hidden_input` changed
from 0 to the expected 7 in native and forced modes on both roots. The rebound
hidden input, empty-pointer rebound, held rebound, catch/payload and numeric
receive cases also passed. The only two failures of the seven-row
`pins/tp125-structure-02.terminal.txt` were translation of `struct_named_selected`
in the two modes. Both reported the existing M2 single-body refusal.

The next candidate routes a unary `call:` through its selected operand, checks the
actual declared throws against the reached caller's declarations and enclosing
pads, and dispatches that body. Its controls include a declared Bad whose body
would succeed, a caught Bad with a payload, and two successive different hidden
input lists at the same call site. The old split-data certificate path is still
separate. The new call code is WIP until these tests pass.

The selected-call kernel is in fix12 (seven changed files). tool125b rebuilt
successfully from the 262 G2 frontend and runtime. The first runtime translation
stopped on the reserved name node, followed by two field types the seed frontend
needed explicitly. The final diagnostic was a machine function capturing temp:
replaying the compiler command in its actual source CWD showed exactly that free
name. The function now owns its result storage in its prologue. rt125h completed
with production SHA-256 8A4F7B407B64EA226402BA0930F7E8C5E084475346FCFD6EF43691ABDD3F4ADA.
The original diagnostics and all attempts remain under the named pins.

Fix12 source manifest 1fe3f7ec2834245560ebabcfe5afdc48b0c0813a38e8c3935e8396e7b2e1d6d5.

## Component checks on fix13

The final component tuple was fe125d/rt125i/tool125b. It passed all 21 final
rows. The selected-call probe on fix12 had already returned 3, then 9 at one
reached site. The maintained fix13 case also checks missing required arguments
and a declared throw before entry. The dedicated observation recorded two
forced invocations per calling method. Native walked each caller once after the
body was rebound. The all-native expectation for the entire mutation probe
therefore failed. On the same tuple the stable helpers note and read_seen passed
the separate observation with four forced executions per root and zero walked
executions in native mode.

The three copy controls passed natively and forced on both roots. Calling a
simple copied Structure from a method and calling its nested occurrence via
an explicit root preserved the free input of the caller. The nested root call
read the root input. Only the copy changed. The separate unqualified nested
operand through a free merge-result root was refused during lowering. It
remains an input-path issue. Raw receipts are tp125-copy-01/02, tp125-final-01
and tp125t-obs-01/02 under pins.

The frozen source-boot125a manifest matches all 173 files and the 11 individual
candidate changes. On 2026-11-03 at 01:41:02 UTC the single quick bootstrap
started with tool125b and the boot124a G2 frontend.
