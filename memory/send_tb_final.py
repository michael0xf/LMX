#!/usr/bin/env python3
import subprocess
import os

# Set PATH for Node.js
old_path = os.environ.get('PATH', '')
node_bin = r'C:\Users\mtkra\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin'
os.environ['PATH'] = node_bin + ';' + old_path

msg = """FINAL-OPENROUTER-TB-NESTED-NODE-PREFLIGHT-20260922-02

HEAD: a36719ad10b0cc5b466f5078a209d27614990743
REAL current HEAD (Codex pin f858cea is 4 commits behind)

== DEFINITIONS ==
FIXED ABOVE-METHOD NODE: declaration in a Structure body or module scope,
residing above all fn/sub definitions. Lives at structural level, not created
per-activation. Examples: unit_root_fields.lm2 L2: counter/total/tag/flags.
unit_named_nested.lm2 Shape: x/y (declared in Structure).

NESTED OWN PUBLICATION: assignment to an own field from inside a nested
executable body (if/while/for/each). The canonical cell exists above the
method, but publication happens through a nested activation. Examples:
- unit_forj_parent.lm2: acc: j inside for loop publishes to parent canonical cell
- unit_asgn_branch.lm2: x: 65 inside if publishes to formal param slot
- unit_own_eq.lm2: node\\quote: v publishes through path target
- lmx_walk_selftest.lm1:683-689: looper publishes acc and i after nested computation

== DISTINGUISHING THE TWO ==
Key code citations (verified at HEAD a36719ad):
- lmx_walk.lm1:159 lmx_walk_own_in(set, count, from) deduplicates by @:@ void from ADDRESS
- l2trans.lm1:5454 l2_is_asgn returns 0 when l2_find_method(h) >= 0 OR l2_is_known(h)
- lmx_walk.h.lm1:254-279 LmxWalkFrame: has @: Lmx node, NO self/subject (unlike L3Frame)
- l2trans.lm1:10212-10214 form test precedes method resolution

Observable difference: fixed above-method node is RESOLVED at entry (stable
address, known to plan). Nested own publication is RECORDED at the point of
assignment within the nested body, carrying a distinct publication PATH even
when the canonical cell is shared. l2_plan_slot_known(occurrence, plan, index)
returns the slot address per-occurrence, identifying which declaration site
produced the publication.

== EXISTING FIXTURES ==
Fixed above-method declarations:
- unit_root_fields.lm2 (counter, total, tag, flags in L2 structure)
- unit_named_nested.lm2 (Point x/y, Shape tag/origin/corner/sides)
- unit_array_field.lm2 (fixed immutable () E with [] int arrays)
- unit_throwing_callable.lm2 (A B structures with fn M fields)

Nested own publications:
- unit_forj_parent.lm2 (for-loop: acc: j to parent canonical cell)
- unit_asgn_branch.lm2 (if-body: x: 65 to formal param slot)
- unit_own_eq.lm2 (node\\quote: v path publication)
- unit_own_dirty_rhs.lm2 (quote: 88 inside if-else)
- lmx_walk_selftest.lm1:671-705 (recursion, nested body fields, dirty publication)

== GAP: NO FIXTURE DISTINGUISHES FIXED vs NESTED PUBLICATION ==
Existing tests exercise each separately. NONE cross them in ONE body to show:
a field declared above-method, assigned inside a nested frame, with observable
canonical-cell identity vs path-distinct publication.

== PROPOSED T-B FIXTURE ==
unit_tb_nested_node_publication.lm2

Body:
  Counter:
      size_t: count 0U
      fn: inner (int: flag) int
          if: flag != 0
              count: count + 1
          return: count
      end: fn
  fn: main () int
      Counter: c
      c\\count: 0U
      c\\inner(1)
      if: c\\count != 1U
          return: 81
      return: 0
  end: fn

Evidence to assert:
- Before nested call: c\\count == 0 (canonical cell, fixed above-method node)
- After nested call returns: c\\count == 1 (nested own publication succeeded)
- The publication path inside inner() resolves to the SAME canonical cell

== UNIQUE-OUTDIR COMMAND (SCRATCH COPY) ==
Critical: run_l3_selftest.py line 21 sets ROOT=Path(__file__).resolve().parents[1],
so invoking the repo copy uses repo sources. bin/l1trans.exe is untracked.

Command (PowerShell, from repo root):

$env:PATH = node_bin + ';' + $env:PATH
python tools/run_l3_selftest.py --translator <scratch_exe> --l1src dev/l2src_sandbox/l1src --test dev/l3_interp/tests/l3_n9_walk_selftest.lm1 --output build/tb_nbp_scratch_TIMESTAMP

Key: --translator must point to the SCRATCH bin/l1trans.exe, not repo.
--output must be unique (timestamped) to avoid clobbering evidence.
--test targets any l3_* selftest exercising nested own walks.

For T-B fixture evidence (when built):
python tools/run_l3_selftest.py --translator <scratch_exe> --l1src dev/l2src_sandbox/l1src --test tests/l3_walk_selftest.lm1 --output build/tb_nbp_evidence_TIMESTAMP

== TYPE BUDGET IMPACT ==
If fixture adds to l3_interp tree: monitor via tools/l3_type_budget.py
Current: 62/64 names, 818/4096 bytes (baseline)
Fixture adds structure Counter with fn inner and field count: ~2 type names max
No build attempted. No edits to tracked files.

Read-only audit complete. All citations verified at HEAD a36719ad."""

result = subprocess.run(
    ['python', 'claude_chat/uds.py', '--name', 'lmx_uds', 'send', msg],
    capture_output=True, text=True
)
print(result.stdout)
if result.stderr:
    print("STDERR:", result.stderr)
print("Exit code:", result.returncode)
