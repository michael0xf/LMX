# Slice 177: the selected callee receives its Structure formals at its entry, by its own records

Opus, 2026-10-23, sole writer/build. The slice answers Codex's review of Verified176,
CODEX-OPUS-REVIEW176-20261023T2133Z, along the route CODEX-OPUS-ROUTE177-20261023T213911Z:
- R176-1 [P1]: the receiving record of a call through a model's callable field took its model from the selected
  callee's header, but its reference contracts and coverage from the caller's catalog. Codex: «нужно исправлять общую
  receiving-запись как единое требование (model + её ссылочные контракты + используемые места), не добавлять
  library/native guard или name lookup на доступе».
- R176-2 [P2]: `lmx_implements_is_occurrence` recognized a callable position by a header part named `return`.

Route, Q1: «приём фактического значения формалом выбранного callable на его entry — подходящий ОБЩИЙ маршрут
исправления… Контракт берётся как одно целое: actual model + её reference contracts + actual Consumer coverage. Один
worker для native trampoline и walked activation, до первого доступа тела».

Verified177 is a bounded slice, like Verified176: the frontend and the runtime were built, the runner's smoke ran, and
a targeted corpus replay ran. The quick bootstrap was NOT run, for memory (below). Verified177 does not close Q49 or §8
and is not the L3+L2 self-build.

The stage is `build2/opus_fix177`, a copy of Verified176's stage `build2/opus_fix176`.
- Four inputs change. Each has a -U0 delta here; GNU patch applied to the Verified176 input gives the stage's bytes
  (`u0-same.out`: `SAME 1` four times; `probes/u0same177.sh`).
- `lmx_implements.h.lm1` is byte-equal to Verified176's. Of the regenerated headers one file differs from
  Verified176's: `headers/l2src/lmx_walk.lm1.h` gains `LMX_WALK_SOURCE_RECEPTION 8` and `LMX_WALK_SOURCE_COUNT 9`.
- The witness fixtures change in the repository (`tests/l2/lib/lib_m.lm2`, `tests/l2/lib/lib_owner.lm2`). The stage
  holds byte-equal copies. The runner and `smoke.tsv`, `suite.tsv` do not change.
- Two lists live in the stage only, copied here: `links-177.tsv` (the links row alone) and `replay-177.tsv`
  (the replay below).

| Input | SHA-256 | Delta |
| --- | --- | --- |
| `src/l2src/l2trans.lm1` | `E935161685CB862F5F29167486F9D48F654434C06AF48F6164B02198021C809D` | `l2trans.lm1.patch` |
| `src/l2src/lmx_implements.lm1` | `B8C5AA5C5DA432F47A4CAFD9BFBAAAC4450B3B08269B4FA09EBD0CF36593588F` | `lmx_implements.lm1.patch` |
| `src/l2src/lmx_walk.lm1` | `D5ED54084201EFBD82ED466996EDC101F73380AA82428C5B4E77BBF32475AA21` | `lmx_walk.lm1.patch` |
| `src/l2src/lmx_walk.h.lm1` | `369813D619363867F3B665A521BD1797AC17325C5C2C9E2C68E21B11F1DAEF2B` | `lmx_walk.h.lm1.patch` |

## What changed

### A formal receives its input at the selected callee's entry (R176-1)

Every method with a body receives each declared Structure formal itself, at its entry, by its own record. That record
is the formal's receiving record in the method's own translation:
- the model its header holds at the formal's place;
- that model's reference contracts, with their declared pointees;
- its body's coverage of the formal;
- the catalog of the formal's own place (`l2_reception_source`, D-105 key k): the candidates the translation sees
  reaching the formal and, the place being dynamic, the bridges to its model.

One record serves both modes:
- Walked: a RECEPTION step per formal after the body's trailer (`l2_rw_receptions`, `l2_rw_reception`):
  `[set_arg, k, [admit_as, record, 0, [arg, k], model], witness]`, source role `LMX_WALK_SOURCE_RECEPTION`
  (`lmx_walk.h.lm1`). The activation runs these steps at its entry (`lmx_walk_receive`, from
  `lmx_walk_enter_parts_values`), after its inputs are open and before the entry load and the body; the body skips
  them. They run outside the body's pads: a PAD child of a body catches a throw of any step of that body, the steps
  before it included, and a refusal at the entry is the caller's, the call's implicit `implements`.
- Native: the trampoline (`l2_emit_tramp_receptions`) copies the inputs' values and admits each formal by the record
  its walked reception retains (`l2_admission_site`, `l2_emit_live_code_place`), with `lmx_walk_value_admit`, to the
  model the selected code's header holds at the formal's place. A refusal returns the implicit `implements` status
  before the body runs; the body takes the received values.

Calls:
- A call through a description (a bodyless method's, as a model's callable field is) selects a callee this translation
  does not see. It admits nothing; the selected callee's entry does. The CHECK pass marks the caller as a site that can
  refuse, so it reads the call's status (`l2_check_call_arguments`). A description has no entry and no reception
  steps (`l2_reception_formal` asks `l2_m_native`).
- A known call (static, or a class of a callable formal) keeps its admission where it forms the input (the 175
  mechanism): the same callee's contract in the same translation, run early. Codex: «caller-side подготовка может
  остаться только ранним выполнением/оптимизацией ТОГО ЖЕ receiving-контракта, не конкурирующим допуском». The order
  is pinned by `unit_formal_recv_models` (refused where run forms the input, before the next actual `tick()`). The
  interim build `fe-03` left those inputs to the entry and changed that order (`replay177-02`), so the formation
  admission stays.
- Natively a static call enters the body directly, so its formation admission is its only one. A walked known call,
  and a native method entered through its trampoline after a walked formation, is admitted again at the entry (OPEN).
- At a call's input a null value is typed by the input's witness where the selected callee receives it at its entry,
  as it already was under an ADMIT_AS operand (`lmx_walk_actuals_values`, `receiver != 0`).

Verified176's caller-side requirement read from the selected header (`l2_emit_formal_admit`, the RECEIVING branch of
`l2_rw_admit_project_at`) and the bodyless line of `l2_receiving_scope` are reverted: they served the caller's
admission of a description call, which no longer exists.

### The binding leaves an input of another object to that reception (R176-2)

`lmx_implements_is_occurrence` is removed. `lmx_implements_call_positions` (the check that a called field's value
takes the written call) gets `received`:
- 1 for the args part: a position whose two objects differ is left to the reception at the selected callee's entry;
- 0 for the return part: such a position stays UNKNOWN.

That reception is the formal's, whatever the formal is:
- A Structure formal's is its model's admission, above.
- A callable formal's asks the callable passed for the calls the callee's body writes (only written calls are
  checked). Those are proved where they are translated. Every callable that reaches a called formal is one the
  translation follows, through the classes of formation that select it (`l2_cfl_classes`), and a call through a formal
  reached by a callable it does not follow is refused there (`callable-neg-01`). A formal the body does not call asks
  nothing. So no run-time reception of a callable formal is emitted.

Measured and removed: a first attempt checked `lmx_implements_call_takes` at the entry against the formal's
description. It refused 13 valid K04 formations with hidden inputs (`replay177-01`).

## The witness

Library M (`tests/l2/lib/lib_m.lm2`):
- `Node` (v, w); `Model` (x, y, a reference `@: next Node 0`); the description `unary (int: a) int`.
- `lib_m_bump (Model: m)` writes `m\y` through the map, then through an address it takes. It writes `m\next\w` the
  same two ways and returns `m\x * 100 + m\y`.
- `lib_m_take (unary: f)` does not call `f` and returns 3.

The owner (`tests/l2/lib/lib_owner.lm2`):
- `Leaf` (v 6, pad 3, w 4); `Point` (pad 9, y 2, x 1, `@: next Leaf 0`); `Thin` (pad 5, y 6); `Bare` (v 8, pad 2);
  `Far` (pad 7, y 2, x 1, `@: next Bare 0`); the owner's `Model` (y alone); `nullary () int`.
- `LibM`: `lib_m_bump (Model: m) int`, `lib_m_take (nullary: f) int`.
- `try_m` builds a Point and a Leaf while it runs, sets `p\next: q` and calls `m1\lib_m_bump(p)`. No translation saw
  them and M's model together.
- `try_n` gives the method a Thin; `try_k` gives it a Far whose Bare has no w.
- `try_f` calls `m3\lib_m_take(seven)`: the description's input is `nullary`, M's is `unary`, two objects. It adds
  `plus1(seven)`, which calls the `seven` it receives.

Values, in every run below, natively and with `--walk-methods`, at the root and walked:
- `S81 runtime candidate r=142 p.y=42 p.x=1 p.pad=9 q.w=10`. M read x (1) and y (2) and wrote y twice (42). It
  wrote the Leaf's w through the Node's map twice (4 + 5 + 1), and the owner reads both back. The Leaf's w is its
  third field and the Node's second, so a positional map would have written its pad.
- `S81 a Thin without x refused where M receives it: 33`.
- `S81 a Far whose Bare has no w refused before M's body: 34 y=2`. The reference's declared pointee is checked, and M's
  body did not run: its first statement writes y.
- `S81 seven taken by a formal M's body does not call: 3, called by plus1: 8`. M binds although its callable input
  is another object.
- Slice 175's and 176's lines are unchanged: `S81 calls A1=41 A2=41 B1=42 A1=42 B1=43 A2=42`,
  `counts A1=42 A2=42 B1=43`, `after A1 count 100: A1=101 A2=43`, `S81 C refused at its binding: 30`.

With `--walk-methods` M's L1 keeps one native word, the unit's; natively it keeps five (`lib_m-forced-3.lm1`,
`lib_m-native-3.lm1` in `fe-05/smoke`). The owner's L1 has no reception: its only Structure formal is a
description's.

## Real runs

The tool is Verified176's `build2/opus_fix176/tool-01/lmxtool-tool.exe`. Every build ran its smoke (`smoke.tsv`,
6 rows).

| Run | Inputs | Result |
| --- | --- | --- |
| `rebuild-runtime-01` | Verified176's `fe-02` | `SUITE 6 rows, 0 failures` (Verified176's witness) |
| `rebuild-frontend-01`, `-02` | `rt-01` | 0 failures; `fe-02` with the new witness |
| `rebuild-runtime-02` | `fe-02` | 0 failures |
| `rebuild-frontend-03` | `rt-02` | 0 failures |
| `rebuild-runtime-03` | `fe-03` | 0 failures; the final runtime |
| `rebuild-frontend-04`, `-05` | `rt-03` | 0 failures; `fe-05` is the final frontend |

Final builds: `fe-05/l2trans.exe` `54E338CA…` (its source is the stage's `l2trans.lm1`), `rt-03/driver.o`
`A1A2EB0C…`, `rt-03/driver-observe.o` `13117375…`. The runs' logs are `witness-*.log` here.

### Targeted corpus replay

The receiving route changed, so the fixtures it reaches ran again (`replay-177.tsv`): 276 rows of
`dev/l2src_sandbox/tests`, every fixture with a Structure-typed or callable formal, both modes, 1121 checks.

| Run | Builds | PASS | Against `replay176-01` |
| --- | --- | --- | --- |
| `replay176-01` | Verified176 `fe-02` + `rt-01` | 750 | — |
| `replay177-01` | `fe-02` + `rt-02` | 702 | 79 checks in 19 fixtures differ |
| `replay177-02` | `fe-03` + `rt-03` | 758 | 16 checks in 3 fixtures differ |
| `replay177-03` | `fe-04` + `rt-03` | 750 | no check differs |
| `replay177-04` | `fe-05` + `rt-03` | 750 | no check differs; the failures' classes are equal |

- `replay177-01`: the callable entry check (removed), a null input at the CALL edge (the null rule above), and an
  empty reception catalog (`unit_s7_arg_call_ok`; the reception's source became the formal's own place).
- `replay177-02`: `unit_formal_recv_models` (the order, above). Two fixtures that fail at translation in Verified176
  passed there: `unit_matrix_empty_named_value` and `unit_named_actual_forms`. With the formation admission restored
  they refuse as in Verified176, «internal: an admission has no original source construction» (`l2_admission_note`).
  That is pre-existing, OPEN (`steps/defects.md`, NAMED-ACTUAL-ADMISSION-NO-SOURCE).
- The 370 failing checks of `replay177-04` are Verified176's 370 (`replay176-01-failures.tsv`,
  `replay177-04-failures.tsv`: equal class, check and reason).

## Controls and mutants

`controls-177.out` reads them from the saved logs (`probes/controls177.py`).

| Build | Outcome |
| --- | --- |
| Verified176's frontend and runtime (`control-c1`) | native: "a field of an admitted reference is not carried by its value (no record, or a hole)"; walked: `walk error: INVALID` |
| Verified176's frontend, the first 177 kernel `rt-01` (`control-c3`) | the same |
| Verified176's frontend, the final kernel `rt-03` (`control-c4`) | the same |
| K2: `received` 0 for the args too (`rt-mutK2`, run on `fe-05`) | R0 stops by an uncaught throw in all four runs: M refused at `try_m`'s binding |
| W2: the activation runs no reception (`rt-mutW2`, on `fe-05`) | walked: `walk error: INVALID` at `try_m`; native passes |
| T3: the trampoline admits nothing (`fe-mutT3`, on `rt-03`) | native: "not carried by its value" at `try_m`; walked passes |

Each control's runs reach `try_m` and print slice 175's four lines first. `rt-mutK2` and `rt-mutW2` were built from the
final sources with one mutation each (`probes/mut177.py`); their `driver.c` differ from `rt-03/driver.c` in that line
alone. Their own smoke used `fe-04`, and the runs in the table use `fe-05` (`mutants/smoke-*-fe05`). `fe-mutT3` is
the final `l2trans.lm1` with one mutation. Each stage source was reverted after its build and checked equal to the
final one.

The callable negative (`callable-neg-01`): M with `lib_m_take`'s body `return: f(1)`, translated by `fe-05` as the
runner translates M. It is refused at translation, exit 1: `lib_m_calls_f.lm2:26:13: a call through a callable formal
that receives a callable this translation does not follow is not built yet`.

## Evidence

`evidence-177.list` names 126 files: the stage's inputs, the four Verified176 parents and their replayed copies, the
lists and fixtures, the final builds and their smoke, the replays, the controls, the mutants and the callable
negative. `evidence-177.sha256` holds their SHA-256. Verified176's tool's `manifest` wrote it
(`runs/manifest-02`: `MANIFEST 126 files, 0 failed`), and `sha256sum -c` checks all 126 OK. The packet's copies have
LF line ends and no trailing blanks; the manifest hashes the original bytes in `build2`. The probes here are frozen
records of how these runs were made, not a route beside the runner.

## Not run (an explicit OPEN checkpoint)

- The quick bootstrap of 176/177 (runtime, frontend, smoke, G1 and G2 with one L1 digest). At 23:43Z the free
  physical memory was 6.35 GiB and the free commit 3.74 GiB, below the margin (about 5.4 GiB free commit and 7.8 GiB
  free physical memory). It runs once, as one pipeline, when a measurement shows the margin.
- LATER: the kernel gate, the gate, bootstrap full, the full corpus replay, LIBRARY-ROWS-OLD-PROFILE.

## OPEN

- Cost: a walked known call is admitted where it forms the input and again at the callee's entry. The second
  admission reuses the proof for a full receiver and repeats the check otherwise.
- A run-time call admission of a callable formal, with the forms it needs (Q49: dynamic inputs, defaults,
  conversions, declared exits). A library method whose body calls its callable formal is refused at translation.
- Code built while the program runs carries a reception only where its builder writes one. Codex: «"Только
  translation знает модель" — ограничение нынешней реализации, не новая норма».
- NAMED-ACTUAL-ADMISSION-NO-SOURCE (above).
- A model's reference field is written `@: next Node 0`; the form `@: Node next` is refused as an unknown type.
- Each received formal reads the callee's header through `lmx_implements_exec_index`, a linear search of the arena's
  records (ARENA-LOOKUPS-LINEAR).
