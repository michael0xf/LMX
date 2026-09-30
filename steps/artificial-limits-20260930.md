# Removal of artificial language limits

Author decision: [Q56](../LMX_blog/q/q56.md). Audit of the 2026-09-30 WIP in
build/opus_wt. This is implementation debt, not a list of language limits.
Source lines move during the ongoing rewrite; the symbols below are anchors.

## Acceptance rule

Follow source/graph structure until its actual end. Use existing dynamically
sized temporary storage where traversal requires state. Never replace a cap
with a larger cap or add one more fixed-dimensional branch. Resource failure
and C99 representability/overflow are not invented syntax limits. Preserve
invalid-type/path/arity diagnostics; test successful cases beyond old caps.

## Current source work

Independent runtime work removes the implements depth cap and the walker
holder-parent cap. The translator repair is broader than depth: replace its
special source-shape recognizers with [general receiver resolution](receiver-resolution-20260930.md).
An arbitrary-depth Array-only scanner is not the intended replacement. No new
index-suffix semantics is chosen by this cap-removal task.

## Remaining families and repair order

| Family | Actual artificial cap / symbols | General repair and witnesses |
| --- | --- | --- |
| P0 parser | LM_P0_MAX_FENCE_LENGTH=80, LM_P0_LAYOUT_DELIMITER_STACK_LIMIT=256 in l1src/p0.h.lm1; delimiter stacks in parser.lm1 can silently stop recording | Grow delimiter state using the existing LmP0Stack/lm_p0_stack_ensure or owner allocation; consume the complete fence. Test >256 nested delimiters and >80-character fences; preserve shallow trees and genuine syntax errors. |
| L1 throws/catches | l1_th_names[2048], l1_th_ar[32], l1_ca_*[32], l1_cur_th[8]; payload limit 8 | Dynamic records and source-derived generated ABI; test >32 declarations/catches, >8 declared throws and payload fields. |
| L1 names/types/ternaries | 63-byte names, l1_hdr_types[8192], kinds[128], emitted/pending[2048]; qmark[64] clamps deeper state into one slot | Reuse l1_fn_grow/import vectors/output-buffer patterns. Test long identifiers, >128 header types, >64 nested parentheses around ternaries. |
| L2 expressions/paths/control | tok[64], n>63; path[40] with l2_rw_path n>=12; l2_rw_cblk/l2_lpk/l2_lpp/l2_padb/l2_padi/l2_rw_pcf/l2_rw_pid[64] | AST spans and dynamic traversal records, not reparse/truncate into text. Test >63 tokens, >12 field hops and >64 nested controls. Coordinate with current Array writer. |
| L2 method/message/table metadata | method/formal name length 63; inline callable formal arrays[8]; send sites 64 and message fields 16; tables 8, columns 32, cells 4096 | Dynamic compiler metadata. Test cases crossing each former boundary; retain field/arity/type meaning. |
| L2 callable merge/admission | l2_t7* fixed 8/16; l2_d105* fixed 64/128/256, some report false OOM; captured fields fixed 32 and some deep paths refused | Extend existing dynamic capture/admission storage. Test wider/deeper captures and more sites/rows without changing call/merge semantics. |
| L2 generated text | l2_tok[1024], l2_ctok[2048], l2_addr_path[1024], local 128/256/1024 buffers and fixed name/path/expression refusals | Shared compiler-side growable text builder, then migrate producers and consumers by call graph. No truncation and no silent fallback. |
| Runtime admission traversal | lmx_implements_walk: LMX_IMPLEMENTS_DEPTH=32 | Operation-local worklist plus visited (candidate, model, Consumer) triples; same constraints, cycles revisited once. Test deep matching/mismatching graphs and cycles. |
| GC traversal | lmx_gc_mark_value: depth 64 returns PARTIAL and suppresses sweep | Growable pending work; retain existing generation marks as cycle memo. Test deep reachable graph and unreachable storage reclaimed after full marking. |
| Simple arena range storage | lmx_range_reserve fixes simple arenas to 32 ranges | Separate storage/lifetime policy from an arbitrary range count; use common reserve without moving live values. Verify simple-arena consumers and stable addresses. |

## Existing reusable mechanisms

- Parser: LmP0Stack, lm_p0_stack_ensure, lm_own_resize. Check size arithmetic
  before allocating; do not reuse an unchecked grow product blindly.
- L2: l2_mul_ok/l2_mul3_ok and l2_xmalloc/l2_xfree; l2_own_reserve,
  l2_slot_reserve, l2_meth_reserve, l2_hidden_reserve, l2_intern_reserve,
  l2_scope_reserve, l2_indent_reserve, l2_for_reserve, dynamic l2_mcap_add.
- Runtime copier already uses an operation-local dynamic identity map and
  worklist. Its single-address map is not an implements triple relation.

## Do not turn missing type evidence into another exception

All current kind-6 model Arrays are empty ARRAY_OF_DESC descriptors, regardless
of terminal type. Traversing actual elements cannot recover the declared inner
type of an empty model. Static compiler AST retention fixes static checks, not
this runtime evidence gap. Receiving-expression/Consumer requirements or
already defined typed-range profiles must carry the actual contract. Never
guess from the first element or add a rank/shape field to base Array.
unit_admit_letter_coarse remains a known failing semantic obligation until the
runtime contract is checked, not a special permission to admit incompatible T.

Diagnostic display truncation (lmx_root_report_cell, 64 characters) is a
separate presentation policy, not a traversal/type rule; audit separately.
LMX_ROOT_CLOSE_LIMIT is a time deadline, not source length. Machine integer
widths and decimal representation domains are not removed by this task.

## Verification

Each family requires targeted positive and negative witnesses, then the full
parser/L1/kernel/generated/L3/docs gates affected by it. Regenerate seeds only
through the checked bootstrap; synchronize stable/dev exact bytes before code
checkpoint. The current 278-target kernel and 11-suite L3 successes precede
these cap removals and do not certify them.
