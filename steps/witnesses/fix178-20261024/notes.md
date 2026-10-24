# Slice 178: the direct machine entry of L2 functions, and the growable list in L2 (S8.2)

Opus, 2026-10-24, sole writer/build. The slice carries out the author's decisions relayed by Codex:
- CODEX-AUTHOR-L2-CABI-EXPORT-20261023T235436Z: «Да, разрешаю такой общий экспорт. Передай Opus: тот же L2 и общий
  разбор, без отдельного языка и скрытого singleton.»
- CODEX-AUTHOR-DIRECT-MACHINE-ENTRY-20261023T235752Z: «доделать прямой машинный вход в существующем генераторе, без
  отдельного языка и второго разбора. Не раздувайте это в новую систему — продолжайте к самосборке.»

Codex authorized it in its review of Verified177 (CODEX-OPUS-REVIEW177-20261024T001232Z): «Продолжай разрешённый
прямой машинный вход в СУЩЕСТВУЮЩЕМ генераторе тем же L2/общим разбором, без отдельного языка/скрытого
singleton/новой системы, затем к самосборке небольшими шагами».

Verified178 is a bounded slice. The frontend and the runtime were built, the runner's smoke ran, and so did a targeted
corpus replay, the machine module probes and three mutants. The tool was NOT compiled with the new recipe and the quick
bootstrap was NOT run, for memory (below). Verified178 starts S8.2. It does not close S8.2, S8.3 or §8 and is not the
L3+L2 self-build.

The stage is `build2/opus_fix178`, a copy of Verified177's stage `build2/opus_fix177`.
- Two inputs change. Each has a -U0 delta here, and GNU patch applied to the Verified177 input gives the stage's bytes
  (`u0-same.out`: `SAME 1` twice; `probes/u0same178.sh`). `lmx_list_owned.lm2` is new, so its delta starts from an
  empty file.
- The list's `lmx_list_owned.lm1` and `lmx_list_owned.h.lm1` are no longer maintained sources: the build writes them from
  the L2 source. `regen-03` regenerates both with the final frontend, byte for byte (`regen-03.command`,
  `regen-03.log`). Of the regenerated C headers only `headers/l2src/lmx_list_owned.lm1.h` differs from Verified177's.
- The recipe changes in the repository: `tools/l2/build.lm2`, `suite.lm2` and `lmxtool.lm2`. The stage holds byte-equal
  copies. `smoke.tsv` does not change. The replay list `replay-178.tsv` is byte-equal to Verified177's `replay-177.tsv`.

| Input | SHA-256 | Delta |
| --- | --- | --- |
| `src/l2src/l2trans.lm1` | `F98D222B7BBB45598C7163E1B84710673C088051F3835575B5632CD4E56232C9` | `l2trans.lm1.patch` |
| `src/l2src/lmx_list_owned.lm2` | `825426B77AB4AA5E2F2CDCDADEC42FC8366EFCE30EFD2380F57CB451F6F56E74` | `lmx_list_owned.lm2.patch` |

| Build product | Verified177 (hand-written) | Verified178 (generated) |
| --- | --- | --- |
| `src/l2src/lmx_list_owned.lm1` | `B875719595F78946769D0CEA79B255DCD8C80E0B5EEBA3F128BB59580BD71702` | `CA52F6956AFD7886D0898262FC29A627BB5B5931EE0C4AD9CD171E9FC3EACE59` |
| `src/l2src/lmx_list_owned.h.lm1` | `14F13CD914A3E7478818F05EEE90B0B31A92A2BE580D7FC0957D762102A959E6` | `91E02D1AD28B002A2B66BDA175AAEB75C374D2176D7327E216C703317C6E848D` |

## What changed

### A machine module in the existing generator

`l2trans --library --machine NAME ... [--header FILE]` with no `--construct` translates a machine module
(`l2_machine_module`).
- Every function with a body at the module's root is a machine function (`l2_m_machine`): a C function of its own
  name, entered with its explicit arguments only. Its fields are C locals declared at its top. Its literals and
  operators are C's, and a call of another machine function is a C call by name, checked as every call is.
- Nothing is published, polled or guarded. The output has no graph, occurrence, root, Message or arena. The names a
  graph needs (`l2_unit_ref`, `l2_call_node`) are set to undeclared words, so a stray use fails the C compile instead
  of reading anything.
- The `--machine` names are the build's exports (`l2_m_machine_export`). Their prototypes are in the header, which holds
  C's `<stddef.h>`, the unit's predefs, includes and defines. The module predefs the header by its file name and
  declares its own functions in a `prototype:` block of its own, so a function may call one defined after it. Both
  files begin with the name of the L2 source they come from.
- The same L2 runs through the same structural parse, resolution and checks. `l2_emit_unit` turns to the machine
  module before any graph planning (`l2_emit_machine_module`); ordinary translation is untouched (`l1-same.out` below).

### What a machine function cannot hold

`l2_machine_validate` refuses each of these where it stands:
- a root statement or field: there is no entry to run it;
- a named Structure, and a method without a body or not at the root: there is no graph to hold them;
- a declared name: «a machine function raises a name: it has no status channel yet»;
- a Structure or callable formal or result, or an array field;
- a function named `l2_...`, the translator's own namespace.

An operation whose L2 exit the machine function could not raise is refused where the expression is written
(`l2_machine_arith_open`). In L2, `+ - * / %` over int, char or an opaque C operand is the shared numeric kernel's
(`lmx_walk_native_int_bin_apply`), which raises `interpreter` on an overflow or a zero divisor; C's operator would
silently replace that exit with undefined behaviour. Admitted are the operations where C's operator is L2's:
- unsigned arithmetic (size_t, unsigned, ulong, U literals), modular in both;
- a pointer offset, C address arithmetic in both;
- an int division or remainder by a positive int literal, which cannot fail.

A status channel for machine functions is OPEN (MACHINE-STATUS-CHANNEL, `steps/defects.md`).

### The growable list in L2

`src/l2src/lmx_list_owned.lm2` is the list's maintained source.
- Eight exports: `lmx_list_len`, `_cap`, `_data`, `_new_owned`, `_new_profiled`, `_append_owned`, `_remove_owned` and
  `_value`. `lmx_list_grow` stays internal, as in the hand-written list.
- A numeric C member is read into a typed local by a cast (`old_cap: (cast: (size_t) d\capacity)`), because L2 does
  not know C's members yet (C-DOOR-MEMBER-ACTUAL-UNTYPED). The list's arithmetic is therefore size_t.
- An element type code is computed in size_t. This is exact: the list's type is at least
  `LMX_TYPE_ARRAY_OF_POINTER_BASE` there, and the code fits an int. Its earlier int form is refused at its `+`
  (`machine-neg-05`, `list_int_codes`).
- The runtime's 30 call sites reach the list through the entry: `lmx_thread` 16, `lmx_graph_copy_owned` 6, the GC
  self-test 5, `lmx_root` 2 and `lmx_reparent` 1. The storage layer beneath it (`lmx_range`, `lmx_arena`) stays L1,
  called through the C door.

### The recipe

- `bld_runtime` (`tools/l2/build.lm2`) takes the frontend. It first translates the kernel's L2 modules
  (`bld_kernel_l2`: today the list, with its eight exports), then regenerates the C headers (`bld_headers`, steps in
  label/headers) and builds the driver.
- `bootstrap` builds the frontend first and the runtime with it. `rebuild runtime` passes its frontend, and
  `build-runtime` takes `REPO STAGE BASE FRONTEND LABEL`.

## Real runs

The tool is Verified176's `build2/opus_fix176/tool-01/lmxtool-tool.exe`, with the old recipe. The list module the
runtime builds use was generated by the recipe's own frontend command (`probes/gen178.sh`) and installed in the
stage's src (`install-03.txt`).

| Run | Inputs | Result |
| --- | --- | --- |
| `rebuild-runtime-03` (`rt-03`) | the list from `runs/fe-probe-08`, smoke with it | `SUITE 6 rows, 0 failures` |
| `rebuild-frontend-02` (`fe-02`) | `rt-03` | `SUITE 6 rows, 0 failures`; the final frontend |
| `regen-03` | `fe-02` | the stage's list module and header, byte for byte |

Final builds:
- `fe-02/l2trans.exe` `F5DBE0A1…`; its source is the stage's `l2trans.lm1`, and its C equals `fe-probe-08`'s.
- `rt-03/driver.o` `8FC94B0E…` and `rt-03/driver-observe.o` `B2C7C08E…`.

### Targeted corpus replay

The machine path changes nothing outside a machine module, which the replay of Verified177's list shows. Its 276
fixtures of `dev/l2src_sandbox/tests` run in both modes, 1121 checks.

| Run | Builds | PASS | Against Verified177's `replay177-04` |
| --- | --- | --- | --- |
| `replay178-03` | `fe-02` + `rt-03` | 750 | every check line equal (paths normalized); failures equal in class, check and reason |

`l1-same.out` (`probes/l1same178.py`): the L1 and C that both replays generated for every row are byte-equal, 576 files
in 552 row directories.

### Machine module probes

`machine-neg-05` translates each source of `machine-neg-05/src` with `fe-02` (`probes/machine_neg178.sh`;
`machine-neg-05/out.txt`).
- Fifteen located refusals: missing, statement, root_field, structure, bodyless, throws, unit_field, array_field, l2name,
  add, cond, actual, divide, remainder, and `list_int_codes` (the list's earlier int form, run from the stage's src as
  the build runs it).
- The positive, `forward`: its exports call the module's own `m_inc`, defined after them, and compute in size_t and by
  int literals. Its header and module are `machine-neg-05/forward/`. Lowered by l1trans and compiled with a C caller,
  it links with nothing else — no driver, no Lmx instance — and gives `m_twice(5)=7`, `m_half(-9)=-4`,
  `m_rest(10)=1` and `m_span(10, 4)=14` (exit 0).

### The tools with the new recipe

`tooltrans-04.steps.txt` (`probes/tooltrans178.ps1`): the stage's tools sources, as `bld_self` lists them, translated by
`fe-02` (L2 → L1, exit 0, 140 s, peak 97 MiB) and by `bin/l1trans.exe` (L1 → C, exit 0, peak 1.79 GiB). The tool was
not compiled.

## Mutants

`probes/mut178.py` writes each mutant from the final sources with one change, into the mutant stage
`build2/opus_mut178b`, a copy of the final stage's src, headers, tools and tests. The final stage is not touched.

| Mutant | Change | Outcome |
| --- | --- | --- |
| L2 | `lmx_list_value` returns 0; generated by `fe-02`, runtime `rt-mutL2` | `SUITE 6 rows, 20 failures`: every run of the five runtime rows, «lmx: the host could not schedule R0» |
| A | `l2_machine_arith_open` admits everything (`fe-mutA`) | the six int-arithmetic negatives translate (exit 0); the rest unchanged |
| P | the module declares none of its own functions (`fe-mutP`) | `forward` fails its C compile: implicit declaration of `m_inc`; the rest unchanged |

`rt-mutL2/driver.c` differs from `rt-03/driver.c` in the one return. The outputs are in `mutants/`.

## How the slice got here

- The list was first generated with nine exports, `lmx_list_grow` among them (`rt-01`, `replay178-01`, mutant
  `rt-mutL1` in `build2/opus_mut178`). The hand-written list keeps growth internal, so the export list became the
  build's names and the module declares its own functions (`rt-02`, `fe-01`, `replay178-02`).
- Then the machine operators were found to be C's for int as well, where L2 raises `interpreter` on an overflow (the
  ordinary lowering of the same expressions, `runs/arith-probe-01`). The arithmetic rule above, the list's size_t type
  codes and the header's `<stddef.h>` followed: `fe-probe-08`, `rt-03`, `fe-02`, `replay178-03`.
- `replay178-01` and `replay178-02` already matched `replay177-04` on every check. The first attempt of `fe-probe-08`
  failed at l1trans (a broken edit); its directory was removed and the label reused, against the new-label rule. The
  first tools translation (`tooltrans-01`) lost its exit code to Windows PowerShell, and the script was corrected.

## Evidence

`evidence-178.list` names 205 files: the stage's inputs, their Verified177 parents and replayed copies, the recipe,
the lists, the final builds and their runs, the replays compared, the probes, the tools translation and the mutants.
`evidence-178.sha256` holds their SHA-256. Verified176's tool's `manifest` wrote it (`runs/manifest-01`:
`MANIFEST 205 files, 0 failed`), and `sha256sum -c` checks all 205 OK. The packet's copies have LF line ends and no
trailing blanks; the manifest hashes the original bytes in `build2`. The probes here are frozen records of how these
runs were made, not a route beside the runner.

## Not run (an explicit OPEN checkpoint)

- The tool's compile with the new recipe, the runtime built through that recipe (`bld_kernel_l2` in `bld_runtime`), and
  the quick bootstrap. At 01:58Z the free physical memory was 6.37 GiB and the free commit 3.97 GiB, below the margin a
  tool compile needs (about 5.4 GiB free commit and 7.8 GiB free physical). They run once, as one pipeline, when a
  measurement shows the margin.
- LATER: the kernel gate, the gate, `bootstrap full`, the full corpus replay, broad tests of the list's growth, removal,
  addresses and the mail/root/child consumers (after the self-build).

## OPEN

- MACHINE-STATUS-CHANNEL: a machine function has no status channel. A declared name and an int operation whose exit it
  could not raise are refused at translation. The mechanism — a status channel of the machine entry, or the meaning of
  an exit that leaves a function C called — is a question for Codex.
- MACHINE-HEADER-WRITTEN-BEFORE-BODY: the header is written in place before the bodies are emitted. A failed emission
  leaves a new header beside the old module until the next build.
- C-DOOR-MEMBER-ACTUAL-UNTYPED: the list reads its numeric C members by casts.
- Machine entries exist only in machine modules: a unit with a construction, or a program, has none. A machine function
  takes no Structure or callable and holds no array field.
