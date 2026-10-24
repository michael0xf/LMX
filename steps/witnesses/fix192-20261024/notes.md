# Slice 192: a generated C name of a source binding keeps its index and adds the binding's name

Opus, 2026-10-24, sole writer/build. The author's words are archived in `LMX_blog/2026-10-24.md`; Codex's rules
(CODEX-OPUS-C-NAMES-PLAN-20261024-A) and order after the values module
(CODEX-OPUS-REVIEW190-AND-C-NAMES-ORDER-20261024-A); the author's go after slice 191's bootstrap, through Codex
(CODEX-AUTHOR-POST191-C-NAMES-CONTINUE-20261024-A: «пусть Opus добавляет читаемые C-имена и продолжает перенос ядра к
самосборке, не ожидая ревью»).

The stage is `build2/opus_fix192`, from Verified191's stage. Its input:

| Input | SHA-256 | Delta |
| --- | --- | --- |
| `src/l2src/l2trans.lm1` | `D8F10E37…` (Verified191: `D70C197B…`) | `l2trans.lm1.patch` |

GNU patch gives the stage's bytes (`u0-same.out`: `SAME 1`). The recipe does not change.

## What changed

- One producer of the name, `l2_tx_cname`: the family's prefix and index, which alone keep the name unique, then `_`
  and the binding's name when that name is an ordinary identifier of C's set (`l2_ident_word`), then a derived name's
  tail. The name is appended to an `L2Tx` and has any length; only the index is formatted in a buffer, which two
  ints' digits bound. Three wrappers give it the binding: `l2_tx_input_cname` (input `fi` of method `mi`, a formal
  `l2_fn` or a hidden input `l2_dn`), `l2_tx_own_cname` (own field `k`, `l2_own_name`), `l2_tx_slot_cname` (slot `j`
  of method `mi`, `l2_sn`).
- The families: `l2_p` (a formal: signatures, the foreign trampolines, stores, contexts, the address), `l2_pr` (a
  forward-only input: its declaration, its test and its `REF:` texts), `l2_fv` (a formal's working pair), `l2_q` (an
  own field; its `_from` and `_dirty` follow the named base), `l2_wv` (an own field's pair), `l2_s` (a slot). Every
  declaration, reference, `REF:` text and derived name goes through its family's producer; no format spells these
  prefixes any more. So the witness's formal `cell` of method 0 is `l2_p0_0_cell`, and the tool's own field 101
  `words` is `l2_q101_words`, `l2_q101_words_from`, `l2_q101_words_dirty` and `l2_wv101_words`.
- The fixed buffers a name now reaches grow (`L2Tx`): a Structure's place text, which held a path load naming an own
  field's cell in 320 bytes (`l2_split_data_at` writes an `L2Tx`; `l2_emit_bound_exec` and `l2_emit_empty_struct_call`
  keep theirs, `l2_emit_ns_exec_at` and `l2_emit_empty_struct_at` their data's), and the payload of a `REF:` entry
  record (`l2_admit_entry_record`, 1 100 bytes). The other formats into fixed buffers (42 with `%s`) hold temporaries,
  holders, unit references, types, paths and messages; none receives a binding's name. The L1 translator keeps
  function, throw, catch and type names in 64-byte buffers; a local's or a formal's name does not pass through them.
- An exact identifier adds nothing: its spelling (with its backquotes) is not of C's set. No binding takes one today --
  `l2_bind_admit` refuses it at the name («an exact identifier cannot name a binding yet»), the boundary Codex set; the
  language is not extended. Temporaries and exports do not change.
- No method has a slot today: the count `l2_collect_decls` passes down is never raised, so `l2_m_sn` is 0 everywhere.
  The slot family's emitters go through the producer and are not reached.

## Real runs

The tool is Verified191's `build2/opus_fix191/boot-quick-01/lmxtool.exe`. The runs are its commands and direct
invocations of the frontends, `bin/l1trans.exe` and the stage's gcc; no probe script was written, and the commands are
kept as text.

| Run | Inputs | Result |
| --- | --- | --- |
| `rebuild-frontend-01` (`fe-01`) | the translator, on Verified191's runtime | `SUITE 6 rows, 0 failures` in 59 s; gcc's warnings are Verified191's (143, the same kinds) |
| `fnptr-192-01` | `fe-01` on slice 191's witness (`fnptr/`) | translates, lowers, compiles with the same warnings (names aside) and exits 0; its L1 and C differ from slice 191's run in 428 lines each, and in none once every family name is mapped back to its index |
| `exact-192-01` | `fe-01` on `exact/exact_formal.lm2`, a formal named `` `n` `` | refused at 3:17, «an exact identifier cannot name a binding yet»; no L1 |
| `exact-control191` | Verified191's frontend on it | the same refusal |
| `long-192-01` | `fe-01` on `long/long_names.lm2`: a formal of 62 bytes (the longest l2trans admits) and a machine local of 150 bytes | translates, lowers, compiles without a warning and exits 0; their C names are 70 and 156 bytes, whole |
| `bootstrap-quick-01` (`boot-quick-01`) | Verified191's tool runs `bootstrap quick` on the stage | `BOOTSTRAP quick 0 failures` in 1 861 s; the recipe rewrote the twelve machine modules, their headers and C headers in the stage (`trace/runtime-record.txt`); the smoke 6/0; G1 and G2 built and working |
| `replay-names-01` (`replay/`) | the bootstrap's G2 `suite` on `unit_absent_input_forward.lm2` (corpus), with its frontend and runtime | `SUITE 1 rows, 0 failures`: native and walked built, both roots give 7; its L1 holds the forward-only family (`l2_pr1_0_other`, `l2_pr4_0_k`, …) |
| `checks-01` (`checks/`) | the bootstrap's G2: `same`, `exe-same`; `diff`, `sed`, `perl` as text | G1 and G2: L1 (`5BECF987…`) and C (`058EA7E6…`) `SAME 1`, `EXE-SAME 1`. Against Verified191's bootstrap, with the family names mapped back to their index and the path-hashed unit prefix masked: the tool's L1 (187 516 raw diff lines), its C (187 636) and the runtime's C (`5BCABA67…`, 6 070) differ in no line; with the derived tails kept, the tool's L1 and the runtime's C in none either. The 28 files the recipe rewrote in the stage differ from Verified191's in names only (`modules-names.out`) |

The names the bootstrap's programs carry: the tool's L1 483 formals' (`l2_p`), 418 pairs' (`l2_fv`), 2 448 own fields'
(`l2_q`, with their derived names) and 504 own pairs' (`l2_wv`); the runtime's C 388 formals' and 305 own fields'.
Neither holds a forward-only input or a slot; the targeted replay reaches the first.

Memory (`chain-memory.log`): cc1 at most 1 568 MB; the free commit at least 2.48 GiB while cc1 ran and 2.17 GiB at its
lowest. Nothing else ran beside the chain.

## Evidence

`evidence-192.list` names 145 files; `evidence-192.sha256` holds their SHA-256, written by the tool's `manifest`
(`manifest/manifest-192.out`, the second run `manifest-02` after the long names' witness: `MANIFEST 145 files, 0
failed`; `sha256sum -c` checks all 145 OK). The packet's copies
have LF line ends and no trailing blanks; the manifest hashes the original bytes in `build2`.

## Not run

The kernel gate, the gate, `bootstrap full`, the corpus replays beyond the one row, a mutant (the author: «Не
увлекайтесь тестами»).

## OPEN

The L3+L2 self-build (plan section 8): 23 more kernel modules of the runtime's translation unit, the driver and both
translators are L1. Next: the graph's modules, first the source names (`lmx_source_names`, with its header from L3 code
of the recipe).
