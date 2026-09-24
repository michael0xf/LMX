# FABLE-GROKBOT-SELFTESTS-20260925-187 C1 READ-ONLY

Base main `260c6ce`. Greps: 86 `tests/lmx_*_selftest.lm1`; no builds.

## (1) Old-model inventory

Markers: working-copy, dirty/checkpoint, own-load, LmxCallable/Method child[0], thread-mode. 57 files hit a string; many "publish" = turn/mail/child boundary (current), not dirty.

**DELETE** (after c3b-3 drops units):
- `tests/lmx_dirty_selftest.lm1` ? sole `lmx_dirty_*` API checks.
- `lmx_own_selftest.lm1` (sandbox root) ? sole L2 `lmx_own_*` checks.

**REWRITE** (child[0] descriptor fixtures ? Lmx.native at k.4; keep intent):
- Core: `lmx_call_selftest`, `lmx_callable_selftest`, `lmx_shared_method_selftest`, `lmx_plan_selftest`, `lmx_walk_selftest` (also old "dirty published before a call" comment).
- Walk ops (~15): admit, admit_throw, arith_mul, call_dest, deref, fresh_call, lt_signed, merge_model, off_instance (mutant comment "working-copy-only"; assert graph cell is current), put_of, put_ref, receive_if/take, ref_put, typed.
- Also: `lmx_interp_walk`, `lmx_runtime_implements`, `lmx_fresh`, `lmx_root_host`, `lmx_root_before_turn`, `lmx_thread_turn`, 9? `lmx_app_*`, plus close/orphan/manager/schedule/argv/arena_attach/merge/primitive callable fixtures.

**KEEP**:
- Turn-publish sense (not dirty): `lmx_turn`, `lmx_deliver`, `lmx_post_*`, `lmx_settle*`, `lmx_service`, `lmx_child`, `lmx_close_chain`, `lmx_gc`, `lmx_runtime`, `lmx_arena_table`.
- `lmx_mail_cascade` ? dirty named only in a comment.
- `lmx_primitive_thread_selftest` ? documents Thread-mode *removal*.
- ~29 unmarked selftests ? current model.

Counts: DELETE 2; REWRITE ~40; KEEP ~45.

## (2) Root `.err`/`.out` writer + fix

Writers (bare `fopen` ? inherits CWD; `tools/ps51_proc.ps1` `Invoke-ProcBounded` sets no WorkingDirectory ? gate/repo cwd = tree root):
- `tests/lmx_root_host_selftest.lm1:387-388` ? `lmx_root_host_selftest.{out,err}`
- `tests/lmx_root_before_turn_selftest.lm1:268-269` ? before_turn names

Fix: `fopen` under `build/selftest_streams/` (mkdir), or absolute path from `build_l2src -Run`; optional WorkingDirectory=`<out>` in ps51_proc. Gitignore stray root files. Not ps51 stream capture (in-memory).

## (3) `lmx_own` / `lmx_dirty` after c3b-2

Still staged units. Links:
- **own**: `lmx_own_selftest.lm1`; `dev/l3_interp/l3_exec.lm1` (predef .h+.lm1); `l3_recv.h.lm1` / `l3_thread.h.lm1`; `l3_interp/tests/l3_02_selftest.lm1`; comment `lmx_walk.h.lm1:41`.
- **dirty**: `tests/lmx_dirty_selftest.lm1` only. Walk checkpoint already no-op (-188).

No other lmx_* selftest predefs. Remove after c3b-3.

## (4) k.4 sites (LmxCallable/Method/child[0] ? Lmx.native)

Build: `lmx_value_owned.lm1:45` method_new; `:53` callable_new (+`.h:15-16`).
ABI: `lmx.h.lm1:180-196`; `lmx_call.h.lm1:9-92`; `lmx_call.lm1:103-192`.
Walk: `lmx_walk.lm1:19/45` callable_addr; `:160/:918` ref_value(,0); `:1758-1776` walk_descriptor; prepare `:1819/:1936/:1980`.
Copy/impl/plan/interp/pool: `lmx_graph_copy_owned.lm1:374,441-452,502-506`; `lmx_implements.lm1:87-160`; `lmx_plan.h.lm1:10-20`+`.lm1`; `lmx_interp.lm1:8,33,48`; `lmx_pool.lm1`+selftest.
Translator: `l2trans.lm1` ~21915-22009 (method_new_owned, slot-0 callable).
lmx_root: slot-0 Array/children only (`:158,1084,1088,1162`) ? not descriptor ABI.
Selftests: ~40 REWRITE rows in ?1; densest call/walk/runtime_implements/root_host/shared_method/plan/thread_turn.
