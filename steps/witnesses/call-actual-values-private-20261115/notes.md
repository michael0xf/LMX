# call/fncall actuals and private: — documentation, 2026-11-15

## Scope

Documentation and implementation plans only. No compiler/runtime code was changed in this package.
Author quotations: [launch args](../../../LMX_blog/2026-11-15.md#call-actual-values),
[private:](../../../LMX_blog/2026-11-15.md#private-binding).

- Document all six call/fncall forms. Args is actual supplied values; data describes input places.
  Omitting args adds no actuals; omitting data selects code itself.
- Ordinary and explicit calls use the same binding, admission, frame, dispatch and result path.
  Known native-to-native calls remain direct C calls.
- Private excludes a field from dynamic binding, while preserving direct and ordinary lexical access.
  Reuse the common binder/hidden arguments; do not add an access-control subsystem.
- Remove obsolete formal-args interpretations from the semantic source, paired specifications,
  guide/kernel/implementation notes, active plans and instructions. Historical implementation
  evidence remains linked as history; it does not establish readiness for the new contract.

## Implementation audit

The six receiver forms are already registered in lmx_graph_receiver_form.
Registration does not implement this clarified meaning: lmx_graph_launch_value still consumes
given_args as declared places, lmx_graph_work_open_parts implements the old frame path, and
lmx_graph_invoke_data_value is a separate route. M10 requires refactoring those existing paths
with the current Walk reader/binder and full Value handling, without a third dispatcher.
Private is specified and planned; this package does not claim it is implemented.

## Verification

Normal accepted Tool03:
build2/codex_fix250generationchain01/sol-m14-field-values-01/tool-field-03/lmxtool-tool.exe
SHA256 aed079b8814716847a34a8fc5af66ac64e2d1922ab9ee704ddc3bf46decee37b.

Private run output: build2/call-actual-values-private-20261115.

- docs render semantics: PASS, 35 paired chapters, 14 cases, both source snapshots.
- docs render grammar: PASS, 27 paired sections, 47 source excerpts.
- Final staged docs check: PASS35/14/27/44/615, links/opening, LF28302; exit 0.
- Working and staged diff checks: PASS.

Only this documentation package is staged. Concurrent native-signature code and its
metadata-reader/compiled-place additions in the main plan remain outside this commit.
