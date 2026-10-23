# Slice 176: a candidate built at run time, received by the callee's formal; a walked receiving body

Opus, 2026-10-23, sole writer/build. The slice answers the author's directive
CODEX-AUTHOR-RUNTIME-ADMISSION-REVIEW-20261023T164724Z («И проверь потом на реальных значениях, что общий допуск
работает и для структур, созданных во время исполнения, а не только для библиотек, заранее известных транслятору»)
and Codex's review of slice 175:
- R175-RUNTIME: a value built at run time is admitted by the callee's formal, before the body, native and walked. No
  prepared template, identity or manual registration; a non-positional layout; reads, writes and a read-back through
  the map obtained, and an access through a taken address; no name looked up again.
- R175-WALK: a positive witness where the ordinary body of the receiving method runs in the walker (no native word).
- The old comment of `lmx_implements.lm1` (lines 119-124) contradicted the norm.
- The limits are not presented as complete Q49.

Verified176 is a bounded slice (Codex, CODEX-OPUS-RESOURCE-DECISION176-20261023T212017Z). The frontend, the runtime
and the tool were built, and the minimal end-to-end run finished. The new quick bootstrap chain of 176 (its own
runtime, frontend, G1 and G2) was NOT run: it is deferred for memory, below. Verified176 does not close Q49 or §8 and
is not the L3+L2 self-build.

The stage is `build2/opus_fix176`, a copy of Verified175's stage `build2/opus_fix175` (`src`, `headers`, `tests`,
`tools`).
- Two inputs change. Each has a -U0 delta here, and GNU patch applied to the Verified175 input gives the stage's bytes
  (`u0-same.out`: `SAME 1` twice). The regenerated headers are byte-equal to Verified175's.
- The runner (`tools/l2/suite.lm2`) and the lists and fixtures (`tests/l2`) change in the repository. The stage holds
  byte-equal copies.

| Input | SHA-256 | Delta |
| --- | --- | --- |
| `src/l2src/l2trans.lm1` | `29ECC9E90F759F13C2B4608B98A0A6864AD5CD2CC5E7C6222BB566749DD9B9A9` | `l2trans.lm1.patch` |
| `src/l2src/lmx_implements.lm1` | `A6F91A48E3650DA126133A609B1E3BB27CCBDED3DA0017DD0C1A4666793FD785` | `lmx_implements.lm1.patch` |

## What changed

### A reception's requirement is the selected callee's own formal

A call through a model's callable field (`m1\lib_m_bump(p)`) selects its callee at run time. The call's receiving
admission of a Structure input (the RECEIVING admission, native and walked) read its requirement "in the selected
occurrence's space". But it found it as the description's declaration along the occurrence's parents. That is the
callee's model only where the callee has the description's lexical shape. A library's method has its own model, in
its own unit (RECEIVING-REQUIREMENT-FROM-PARENTS, `steps/defects.md`).
- Native, `l2_emit_formal_admit` (form 3, by name): a declared formal's requirement is the model the selected
  occurrence's header holds at the formal's place (`l2_emit_model_input`). That is the model the callee's body reads
  the formal's fields through.
- Walked, `l2_rw_admit_project_at` (RECEIVING): the model operand is `OF(OF_EDGE(NODE(0), 0), k)`
  (`l2_rw_model_input`), which `lmx_walk_admit_in` evaluates in the selected occurrence's space.
- A free (hidden) input keeps its lexical unit's declaration.
- For a callee of the same translation the header holds the declaration itself (`l2_declared_graph_witness` stores
  `l2_nsp[model]`), so those admissions keep their requirement.

### A description's formal is no Consumer's coverage

The formal of a bodyless method (a model's callable field) has a use plan that reads nothing: the description has no
body. Its receiving record carried that empty coverage, so the admission consumed nothing and published no record
(DESCRIPTION-FORMAL-EMPTY-COVERAGE).
- `l2_receiving_scope`: the port of a bodyless method asks for the full interface, as a port of unknown use does.
- The callee's own coverage at such a reception is OPEN: the caller does not see the selected callee's uses, so the
  whole model is asked.

### A refusal there is the caller's implicit `implements`

The translation saw no callee of a call through a description, so it proved no admission to the callee's model
(DESCRIBED-RECEPTION-REFUSAL-ABORTS).
- The CHECK pass marks such a site as one that can refuse (`l2_check_call_arguments`: a Structure actual of a call to a
  bodyless method, `l2_admit_site`).
- The native site's refusal is the caller's implicit `implements` (`l2_emit_formal_admit`).
- The walked RECEIVING admission already threw it.

### The binding leaves a data Structure position to the reception

`lmx_implements_call_positions` (the check that a called field's value takes the written call):
- a data Structure position of another model is not decided at the binding; the reception above admits the value;
- a callable position of another description stays UNKNOWN, since a callable formal's reception is OPEN. A callable
  position holds an occurrence, whose header names part 1 `return` (`lmx_implements_is_occurrence`); no field of a
  model has that name.

The old comment of `lmx_implements.lm1` (lines 119-124) now states the norm: only the calls the Consumer writes are
checked, by `lmx_implements_call_takes`, with no equality of signatures; a callable only named, passed or stored is
consumed whole.

### The runner builds libraries walked in the forced mode

A `links` row builds each library in each mode of the owner: natively, and with `--walk-methods` in the forced mode.
So the forced runs of the smoke and the suite walk the libraries' method bodies, as the owner's are walked.

## The witness

- Library M (`tests/l2/lib/lib_m.lm2`): its model `Model` (x, y); `lib_m_bump (Model: m)` writes `m\y` through the
  map, then through an address it takes (`@: py int @ m\y`, `\py: \py + 10`), and reads `m\x` and `m\y` back.
- The owner (`tests/l2/lib/lib_owner.lm2`): `Point` (pad, y, x), the owner's `Model` (y alone), and `LibM` with the
  method `lib_m_bump (Model: m) int`.
  - `try_m` builds `p: merge: Point` while it runs and calls `m1\lib_m_bump(p)`. No translation saw the Point and M's
    model together.
  - `try_n` gives the method a `Thin` (pad, y) built the same way.
  - Neither has a C call, so both run walked in the forced mode; `run` prints.
- The links row of `smoke.tsv` and `suite.tsv` gains `lib/lib_m.lm2=lib_m_new`.

Values, in every run below, natively and with `--walk-methods`, at the root and walked:
- `S81 runtime candidate r=142 p.y=42 p.x=1 p.pad=9`: M read x (1) and y (2), wrote y (32), wrote it again through the
  taken address (42), and read both back (142); the owner then reads its Point's y as 42.
- `S81 a Thin without x refused where M receives it: 33`: the reception refuses the Thin, and `try_n`'s handler takes
  the `implements`.
- Slice 175's lines are unchanged: `S81 calls A1=41 A2=41 B1=42 A1=42 B1=43 A2=42`, `counts A1=42 A2=42 B1=43`,
  `after A1 count 100: A1=101 A2=43`, `S81 C refused at its binding: 30`.

The record that serves the reception (`probes/record-dump-03.out`). The probe adds a dump to a scratch copy of M's C
before the method's first read (`probes/add_dbg.py`) and prints the arena's records whose value is the Point or whose
model is M's: the Point's own record, M's model's own record, and `(Point, M's Model)` with the map `4 1 2 3 | 4 5 2 5`,
holes 1, a full receiving proof (2).
- x reads the Point's slot 4 and y its slot 2 (each declaration takes two slots).
- That map is neither identity, nor the owner's template: the owner's Model has y alone.
- The method's reads go through `lmx_implements_slot` on that record; no name is looked up again.

## Real runs

- `fe-01` (`rebuild frontend`, smoke on Verified175's runtime): every row translates; the links row fails at run time,
  because Verified175's kernel refuses M at its binding.
- `rt-01` (`rebuild runtime` with `fe-01`): the links row's runs end at M's first read, "a field of an admitted
  reference is not carried by its value" (DESCRIPTION-FORMAL-EMPTY-COVERAGE, fixed after it).
- `fe-02` (`rebuild frontend` of the final translator, smoke on `rt-01`): `SUITE 6 rows, 0 failures`. Its links runs
  print the values above.
- `tool-01` (`rebuild tool` with `fe-02` and `rt-01`; G0 = Verified175's tool). Claude Code stopped this run at 20:47Z
  because the system was critically low on memory. The stop killed only the shell: its processes went on, and I ended
  them (20:48-20:49Z). `rebuild-tool-01.out` is empty, because the shell holding it was killed.
  - Before the stop the run had finished its translation, C compile and link. `tool-01/record.txt` pins each step's
    inputs and outputs, and all 15 pinned files check OK: `lmxtool.lm1` `CC158CC6…`, `lmxtool.c` `9A75882F…`,
    `lmxtool.o` `4011F117…`, `lmxtool-tool.exe` `425C5FF9…`. The translator was `fe-02` `B34C2291…`.
  - The tool's self-check had finished too (`tool-01-sha256.log`: its sha256 of `lmxtool.lm1` is the pinned one).
  - The interrupted run as a whole is not called GREEN. The one step it never started is the last step of
    `rebuild tool` (as in 175's `tool-01/smoke-record.txt`): the new tool's `suite` on the smoke list. That exact
    command ran separately, with `tool-01/lmxtool-tool.exe`, into the new directory `tool01-smoke-01`
    (`tool01-smoke-01.command`, `.out`): `SUITE 6 rows, 0 failures`, 44 PASS.
  - With the new runner the links row builds M per mode. The forced build is
    `l2trans --walk-methods --library --construct lib_m_new`, and its L1 keeps one native word, the unit's; the native
    build keeps three. The runs' logs are `witness-*.log` here.
- Probes (`probes/probe176.sh`, built by hand with the probe frontend of the final translator `runs/fe-probe-02` and
  `rt-01`, the same commands as the runner's): `probes/p176-native-04.out` and `p176-forced-04.out`, every step exit 0.
- Walked bodies (`probes/observe176.sh`, the same objects linked with `rt-01/driver-observe.o`, `observe-05.out`):
  natively no body is walked; with `--walk-methods`, `lib_m_bump`, `try_m` and `try_n` are each walked once per run.

## Controls

`controls-176.out` reads them from the saved logs:

| Build | Outcome |
| --- | --- |
| Verified175's frontend and runtime | R0 stops by an uncaught throw (exit 1): M refused at `try_m`'s binding |
| Verified175's frontend, the 176 runtime | `lmx: walk error: INVALID` (exit 3): the requirement read along M's parents |
| `fe-01` (header requirement only), `rt-01` | "a field of an admitted reference is not carried by its value" (exit 3) |
| `fe-probe-01` (no described refusal), `rt-01` | native: "the record of a proved admission was not kept" at `try_n` (exit 3); walked: passes |

## Evidence

`evidence-176.list` names 106 files of the stage, its runs and the Verified175 parents used by the controls, and
`evidence-176.sha256` holds their SHA-256. `tool-01/lmxtool-tool.exe`'s `manifest` wrote it (`MANIFEST 106 files,
0 failed`), and `sha256sum -c` checks all 106 OK. The packet's copies of run outputs have LF line ends and no trailing
blanks; the manifest hashes the original bytes in `build2`.

## Not run (an explicit OPEN checkpoint)

- The quick bootstrap of 176 (its own runtime, frontend, smoke, G1 and G2 with one L1 digest). It compiles the tool's
  39 MB C twice at -O0. At that stage of the stopped run all build processes held about 2.44 GiB of commit, with free
  commit 1.67 GiB and free physical memory 3.59 GiB, and the system stopped the job. At 21:17Z the free commit was
  3.36 GiB and the free physical memory 5.99 GiB, so a compile would have left about 0.9 and 3.2 GiB. The bootstrap
  runs once, with G0 = `tool-01`, as one pipeline, when a measurement shows the margin (about 5.4 GiB free commit
  and 7.8 GiB free physical memory).
- LATER: the kernel gate, the gate, bootstrap full, a corpus replay (the receiving route changed), mutants,
  LIBRARY-ROWS-OLD-PROFILE.

## OPEN

- The callee's own coverage at a description's reception: the full interface is asked.
- A callable position of another description (a callable formal's reception).
- The reference catalog of a reception through a description is the description's, so a reference field of the
  callee's own model has no declared pointee there.
- Q49 beyond the current ABI: inputs formed from defaults, dynamic inputs, conversions, declared exits.
- Cost: a call with a Structure actual reads the callee's header through one more `lmx_implements_exec_index`, a
  linear search of the arena's records, as each read of a formal's field already does (ARENA-LOOKUPS-LINEAR).
