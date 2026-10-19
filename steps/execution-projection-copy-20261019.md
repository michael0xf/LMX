# Copying execution projections: implementation verification

This is a kernel-copy implementation slice, separate from the
[root-category change](path-root-categories-20261019.md). It is not proof of
the complete common path algorithm, current-graph executable-copy analysis
or general `native` invalidation.

## Measured cause and repair

The old copier carried an execution projection only while carrying the
corresponding receiving record. That policy excluded a copied operand root;
it could also exclude a copied child when its receiving frame was not copied
into another arena. A whole copy retained the exact native word and source
edge coordinates, but lost the projection those coordinates required. The
copied data and its unchanged native address were not the error.

`lmx_copy_carry_records` now transfers existing execution projections through
the actual copy map independently of receiving-frame/required-graph transfer.
This is one rule for unchanged-slot copied Structures, whether root or child.
A retained value has no copied target; an absorbed/reassembled operand root
still requires composition's coordinate proof and is not treated as an
unchanged-slot copy. No runtime field-name search, opcode, new graph marker
or new arena-record kind is introduced.

Ordinary receiving-record copies clear their execution fields. After ordinary
and partial records are carried, the existing `lmx_implements_exec_save`
clones each source self-record's execution map into its copied target's
self-record. It proves no new external reception. Source or newly partial
holes are preserved; the partial record is not upgraded to full reception.
The existing two-pass reservation and outer copy transaction remain in
force, including truncation/freeing of appended maps on rollback. A record
pointer is reacquired after a potentially growing write.

The added header declaration exposes this already-existing storage operation;
it is not a second implementation of projection or admission.

## Exact candidate inputs

| Input | SHA256 |
| --- | --- |
| `lmx_graph_copy_owned.lm1` | `609162102b2aa0138b8dc102cf7d4b31e740fae16a7553683da1b76b73e35d2f` |
| `lmx_implements.h.lm1` | `8409a464e7c8c84eecadd4e4700745bfc99e3cd4486057aaf37eb3c3f2dd587b` |
| `tests/lmx_exec_projection_copy_selftest.lm1` | `4ffc6c5b0614311c72b8f5f38fbed6d4f2a23822de4a1ea8281b5842effeb2ca` |
| `tests/lmx_exec_projection_copy_test.h` | `7d568c0a1a4ac049471ccdba4a6454fc088241c35881de65ef5cacb558b4ed6f` |
| `tests/lmx_walk_output_place_selftest.lm1` | `e869567ea076f368121dcdf9f0ea3adbb1cc3d4a4cd8d4f134a1bed35aceaffe` |
| `tools/build_l2src.ps1` | `9e4e6684f38c63eec95f106bf1650fbd170f2329dc708136326f38e3a4ef90de` |

The first five paths are under `dev/l2src_sandbox/`. The frontend/header/
L2-harness inputs are the root-category snapshot, not a further frontend
change. `build_l2src` now freezes test C-builder headers beside its frozen
L1 test sources, so the test cannot accidentally consume a live mutable helper.

## Positive tests and distinguishing controls

The permanent C header is a test graph builder using public kernel APIs,
not another language-path resolver. Its graph is unchanged by copying.
Source edge0 maps to physical slot1; the code and value have different orders.
Both dispatch modes must read9, store13 and take an address then write21,
while preserving neighbour77. Each engine starts from9 independently.

The24-case full-copy matrix covers original, distinct same-arena copy,
cross-arena copy and a nested copied child, each through real
`lmx_call_prim` with the retained nonzero native adapter and forced
`lmx_walk_run`. Cross-arena and nested values run after releasing the source
arena, including the unrelated receiving frame registered before projection.
Copy cells must be distinct and native addresses equal; the code graph is
not rewritten after copying to conceal lost source coordinates.

The public used-copy API additionally omits the unused neighbour. That
existing partial-copy policy clears native: its three read/store/address
checks are walker evidence only, not a native claim. Hole metadata must
survive, source edge0 must still select1, and the absent edge2 must not map
to a live slot. The earlier diagnostic that invoked `lmx_call_prim` on this
partial copy also used its walker fallback, not native dispatch.

Independent prototype controls retained under `build/`:

- `codex_mapped_copy_places_general_04`:24-case full matrix, zero failures.
- `codex_mapped_copy_places_root_only_04`:six failures on the nested child;
  therefore a root-only repair was rejected.
- `codex_mapped_copy_places_baseline_04`:18 failures, every copied-value case.
- `codex_mapped_root_copy_read_only_01` and the later complete read-only probe
  retain ordinary-copy, second-copy, one-operand-merge and post-source-release
  controls. They do not replace write/address tests.

The old output-place self-test asserted loss of the copied root's projection
and then rewrote its graph to physical coordinates. It now positively checks
retention and the distinction between physical OF and source OF_EDGE. That
test still deliberately edits its graph; unchanged-graph/native evidence
comes from the independent27-case test above, not from that rewrite.

A further kernel diagnostic, `codex_copy_exec_split_data_probe_09`, invokes
copied code over distinct admitted data. Its source-edge projection first
maps0 to the copied code's physical1; the separately admitted data maps that
required field1 to its own physical0. Both native `lmx_implements_code_index`
and walker activation give read9/store13/address-write21, keep neighbour77
and leave the copied code's different value5 untouched: six passing cases.
This checks composition with a receiving map, not just equal code/data.
It remains a kernel-builder diagnostic, not compiler M2 completion.

That diagnostic deliberately uses OWN for the activation-data place and
reads the actual stored result through a taken address. Earlier attempts
used `NODE(0)`, which explicitly targets code, or an OWN read of the working
snapshot after a direct PUT; neither matches the native physical-read
expectation. They are invalid parity setups, not kernel findings. A separate
old-driver baseline attempt crashed and supplies no completed counterfactual
matrix; use the completed root-only/general/baseline controls listed above.

## Gate state

Verification of this limited kernel-copy slice is complete.
`codex_copy_exec_kernel_03` passed306 targets with
zero failures,119 executed self-tests, and L3 all11 suites/four type budgets.
The new27-case test and the existing39-check output-place test both pass.
The exact frozen wrapper/header were also separately packaged as
`codex_exec_projection_copy_packaged_02`; its retained log has27 passing
value cases. This preserves detailed evidence despite the kernel script's
normal cleanup of GREEN-run objects and logs.

Focus `codex_copy_exec_focus_01`:84 targets/11 failures, exactly the root
predecessor's rows, states and common FAIL notes/diagnostic signatures.
Zero regressions or removed rows. Full `codex_copy_exec_full_01` started
16:09:13Z after the preceding root corpus completed. Its frozen copier,
implements header and C-builder header match this candidate. Its pregate
HEAD is8e982196 because the separately verified root slice was published
after launch as3f02e189; actual frontend/header/harness pins identify the
root-category inputs. The full completed at17:05:10Z with3616 targets/1027
failures, observed harness exit1. These are exactly the root predecessor's
rows and states: zero regressed/fixed rows, changed common FAIL notes or
diagnostics, added or removed rows. Against the walker predecessor3615/1027,
the sole extra OK is the already accepted root-category compiler test.
Minimum free physical memory3127 MiB. The Bash launcher and both comparisons
completed normally; unlike the preceding root run, no wrapper return code
had to be reconstructed.

Before publication, six staged inputs were matched to live files, the five
kernel inputs to frozen kernel03 sources, and eight runtime inputs to the
complete full snapshot using Git-normalized source hashes. The frontend and
application header were compared to the accepted root HEAD, not the newer
unstaged compact-head WIP. All pins matched. This verifies the exact copy
candidate independently of that subsequent frontend work. It is not a GREEN
L2 corpus or closure of the remaining language migration.

Two additional source diagnostics retain the original mixed-path fixture
assertions but add32 nested holders before their reference/final index:
`codex_deep_path_32_probe_01` and
`codex_permuted_deep_path_32_probe_01`. The latter also uses the permuted
formal map and a copied Wide candidate. Both give expected exit7 under
normal/forced-method translation and native/cleared-root dispatch (all eight
driver runs pass). Inspected forced-method output keeps only native root
m36/m37 respectively; the actual methods walk. This exercises the dynamic
walker record allocation beyond its42-cell inline buffer. It does not cover
a field after an index, an independently mapped element or every path shape.
The driver's `0 roots` denotes its configured count of qualified roots, not
zero execution: it checks one builder/launch and the actual exit value.

The independent `codex_copy_exec_alloc_failure_probe_03` instruments entry
to the real frozen kernel's `lmx_implements_exec_save` and wraps malloc/free
at link time. It injects failure at the first or second transferred map,
both in the same arena and across arenas. All four copies return NOMEM
with no result, restore destination block/record marks, and free the earlier
cloned map when the second allocation fails (one tracked allocation/one free).
Both source values still pass native/walker read/store/address checks after
rollback, and a subsequent uninjected copy retains both projections.
Zero failures. These diagnostic compiler/linker hooks add no production
runtime failure switch. They test this allocation path, not every allocator
failure in the kernel.

Earlier runs are not acceptance:

- Kernel01:306 targets/one failure,118 executed self-tests; L3 all11+4.
  The new self-test failed to link because its wrapper omitted its PREDEF
  implementation closure. The old output-place self-test passed. The wrapper
  was fixed; a separately packaged24-case executable passed, but that alone
  is not the complete kernel gate.
- Kernel02 stopped before compilation: Windows PowerShell loaded the bundled
  PowerShell module rather than its Windows utility module, so Get-FileHash
  was unavailable. L3 still passed. The ignored launchers now explicitly
  import the Windows module; the hash/pin check was not disabled. No source
  regression or memory failure is inferred from that preflight failure.

Still open: ancestor-owner projections (including the node-field positive
that returns2 instead of3), mixed field/index paths, computed roots, compiler
M2/current-graph copy proof, incompatible graph mutation/native invalidation,
M1-M4/N4, self-build and mail. Unrelated allocator failures and all-consumer
path unification are not certified by this limited rollback probe.
