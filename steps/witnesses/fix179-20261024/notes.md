# Slice 179: a machine call takes the call's common binding (R178-1); machine operators keep C99's semantics

Opus, 2026-10-24, sole writer/build. The slice answers Codex's postfactum review of Verified178,
CODEX-OPUS-ROUTE178-20261024T020556Z:
- R178-1 [P1]: «l2_machine_call ... заново делает l2_find_method по written frame head ... C emitter ... не читает
  связанный L2ApplicationSite.arguments ... пропадают обычные связывание named args/конверсии и гарантированный lexical
  evaluation order». «Исправлять общую проекцию результата разрешённого вызова в C ABI, не machine-only повторный
  resolver/новый parser/whitelist.»
- Q1: «Не выводи новую норму signed int из поведения нынешнего numeric helper. L2_spec RU/EN §17 прямо сохраняет
  числовую семантику соответствующего C99 типа, §21 — overflow/raw index по машинному контракту, не гарантиям L3.»
  For declared exits: «Расположенный отказ как честный OPEN незавершённой поддержки допустим на этом шаге».
- Q2: a machine C layout of types waits for the author's answer to Codex's question; until then the types are not
  declared ported. Q3: «обычная правка публикации, не новая норма; делай компактно».
- «новые tiny probes/helpers не писать на C/Py/PS/shell с оправданием frozen record. C caller m_forward_main.c можно
  выразить L2 machine entry main; новые проверки/обработка — в имеющемся L2/L3 пути.»

Verified179 is a bounded slice: the frontend and the runtime were built by the runner, its smoke ran, a targeted corpus
replay ran and the witnesses below ran. The tool was NOT compiled with Verified178's recipe and the quick bootstrap was
NOT run, for memory. Verified179 does not close S8.2, S8.3 or §8 and is not the L3+L2 self-build.

The stage is `build2/opus_fix179`, a copy of Verified178's stage sources (`build2/opus_fix178`).
- Two inputs change. Each has a -U0 delta here, and GNU patch applied to the Verified178 input gives the stage's bytes
  (`u0-same.out`: `SAME 1` twice; the commands in `u0-same.command`).
- The list's generated module changes (its call sites and two type-code lines); its header does not, and the
  regenerated C headers equal Verified178's. `fe-04` regenerates the stage's module and header byte for byte
  (`regen-02`). The recipe and the lists do not change.

| Input | SHA-256 | Delta |
| --- | --- | --- |
| `src/l2src/l2trans.lm1` | `C96BDD8E1751F9FD37544FABA82A8B277B704662DEA4F459EDD388DE123C1BF6` | `l2trans.lm1.patch` |
| `src/l2src/lmx_list_owned.lm2` | `002D362210F73C706961A696C337EDFC994F15DAB8C4956D9C038F2AFA4E372C` | `lmx_list_owned.lm2.patch` |

The generated `lmx_list_owned.lm1` is `A0D2CADCCE4A276E15EB04950BB5C4CEFE540D52FFE6E8AA89944A46127F69E2`; the header
`lmx_list_owned.h.lm1` stays `91E02D1AD28B002A2B66BDA175AAEB75C374D2176D7327E216C703317C6E848D`.

## What changed

### A machine call is the call's common binding projected into the C ABI (R178-1)

A machine function's call of a machine function is resolved where every call is: `l2_prep_context` takes the check's
one resolution of the head (`l2_call_head_method`). It then goes to `l2_emit_machine_call_value`, which takes the
call's common binding as `l2_emit_call_value` takes it (`l2_application_actuals_use`): formal order, named actuals and
defaults as the check bound them.
- The actuals run in their written order (`l2_value_actual_written`). Each is received as an ordinary call receives
  it — a number by `l2_numeric_receive_prepare`, another value by its span — and fixed in a C local of its formal's
  type (`l2_formal_local_decl`) before the next one runs.
- The callee is called by its C name with those locals in formal order, into its result's local
  (`l2_emit_call_result_value`). A conversion receiver would be a graph call, which a machine function cannot make: it
  is refused where its actual stands.
- The name-based recognizer `l2_machine_call` and its two diversions (`l2_emit_primary_value`, `l2_eval_discard`) are
  gone, so a machine call no longer reaches the C door's emitter.

### Machine operators keep C99's semantics (Q1)

`l2_machine_arith_open` is removed: a machine function's `+ - * / %` is C's operator, as L2 sections 17 and 21 say
(MACHINE-STATUS-CHANNEL is narrowed to declared exits, which stay refused). The list computes its element type codes
in int again, as the hand-written list did.

### The address of a machine function's field (MACHINE-OWN-ADDRESS-GRAPH-CELL)

`@ counter` in a machine function was spelled as an ordinary method's graph cell (`l2_q0_from[0]`), which a machine
function does not have; found on the R178-1 witness. `l2_own_addr` now gives a machine function's field the address of
its C local (`(@ l2_q0)`).

### The header is published after the module (Q3)

The header is written to `FILE.tmp` and replaces `FILE` once the module is published; on any failure the temporary
files are removed. A failed publication of the module says where («the machine module cannot be published at its
output path»). Ordinary outputs keep `l2_pub_commit`'s unsaid failure (PUBLICATION-FAILURE-UNSAID, OPEN).

## Real runs

The tool is Verified176's `build2/opus_fix176/tool-01/lmxtool-tool.exe`. The runs are its commands and direct
invocations of the frontend, `bin/l1trans.exe` and the stage's gcc; no probe script was written.

| Run | Inputs | Result |
| --- | --- | --- |
| `rebuild-runtime-01` (`rt-01`) | the list generated by `fe-02` (`gen-list-01`), smoke with `fe-02` | `SUITE 6 rows, 0 failures` |
| `rebuild-frontend-04` (`fe-04`) | `rt-01` | `SUITE 6 rows, 0 failures`; the final frontend |
| `regen-02` | `fe-04` | the stage's list module and header, byte for byte |

Final builds: `fe-04/l2trans.exe` `6BC4FB25…` (its source is the stage's `l2trans.lm1`), `rt-01/driver.o`
`158565F1…` and `rt-01/driver-observe.o` `B5CF9958…`. Of the earlier frontends, `fe-02` lacks the address fix and
the publication message and `fe-03` the publication message; `fe-01` failed at l1trans (a missing tail cutter).

### Targeted corpus replay

`replay179-02` (`fe-04` + `rt-01`) runs Verified178's list (276 fixtures, both modes, 1121 checks): PASS 750, and every
check line equals Verified178's `replay178-03` (paths normalized). The L1 and C of every row are byte-equal to
`replay178-03`'s: the tool's `manifest` hashed the same 576 relative paths in both replays and its `same` compared the
two manifests (`l1same/`).

### The R178-1 witness

`order/order.lm2` is a machine module whose export `main` returns 0 when every check holds, else the number of the
first that fails; `next` is the module's own function, defined after its first use. It is translated by the frontend
and lowered by l1trans, compiled by the stage's gcc at -O2 and linked with nothing else — no driver, no Lmx instance.
- `fe-04` (`order-03`) and `fe-03` (`order-02`, the same L1): exit 0. `pack(next(@ counter), next(@ counter))` gives 12
  with counter 2, the permuted named actuals `pack(b: next(@ counter); a: next(@ counter))` 21, `pack(b: 4U; a: 3U)`
  34, and the C99 int arithmetic `k * 2 + 1` 11.
- Verified178's frontend refuses it at its named actual: «internal: a call the emitter does not know», frame=b
  (`order/control-178.out`).

| Mutant (`build2/opus_mut179`) | Change | Witness |
| --- | --- | --- |
| `fe-mutO` | the actuals in formal order, not written order (`mutants/mutO.patch`) | exit 2 |
| `fe-mutB` | the call's locals in reverse formal order (`mutants/mutB.patch`) | exit 1 |

Each mutant source differs from the final one in that one line; the mutant stage's source was reverted after each build
and checked equal to the final one. Their smoke is 6/0: the smoke has no machine module.

### The header witness

`q3/`: a directory stands where the module goes, so its publication fails after the header has been written. With
`fe-04` (`q3-new2`) the translation fails with the located message, the header is as it was and no temporary file is
left. With Verified178's frontend (`q3-old`) the header is rewritten by the failed translation. With `fe-03` (`q3-new`)
the header was kept but the failure was unsaid (exit 3) and `order.lm1.tmp` stayed: the reason for `fe-04`.

## Evidence

`evidence-179.list` names 90 files: the stage's inputs, their Verified178 parents and replayed copies, the final builds
and their runs, the replays compared and their manifests, the witnesses, the control and the mutants.
`evidence-179.sha256` holds their SHA-256, written by the tool's `manifest` (`runs/manifest-01`: `MANIFEST 90 files, 0
failed`); `sha256sum -c` checks all 90 OK. The packet's copies have LF line
ends and no trailing blanks; the manifest hashes the original bytes in `build2`.

## Not run (an explicit OPEN checkpoint)

- The tool compiled with Verified178's recipe, the runtime built through it, and the quick bootstrap: memory, as in
  Verified178.
- LATER: the kernel gate, the gate, `bootstrap full`, the full corpus replay, broad tests of the list.

## OPEN

- MACHINE-STATUS-CHANNEL: a declared exit of a machine function has no C ABI; it is refused at translation.
- PUBLICATION-FAILURE-UNSAID: `l2_pub_commit` fails without a located diagnostic for ordinary outputs.
- The machine C layout of types: Codex asked the author; the storage layer's types stay in `.h.lm1` until then.
- C-DOOR-MEMBER-ACTUAL-UNTYPED: the list reads its numeric C members by casts.
