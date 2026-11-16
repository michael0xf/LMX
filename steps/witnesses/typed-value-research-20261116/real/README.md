# TypedValue research: a bench of the CURRENT runtime (FABLE-R-TV-D)

opus, 2026-11-16, at fable_pc's request on the author's order. This is the comparison base for the TypedValue
research. It measures the runtime as it is: the arena's range index, classification of an address, Structures and
cells made by their constructors. It does not use a model of the runtime.

It calls only the exported C entries of the runtime, the way generated code calls them. It reimplements nothing.
The one row that calls nothing is `floor_direct(no runtime call)`, and it is marked as a floor.

**Compile and run only on fable_pc's signal**, because memory is limited during bootstrap.

## Files

| File | What it is |
|---|---|
| `tv_real_bench.c` | Items 0–4. One source, two builds: `bench-time` and `bench-mem`, which is built with `-DTV_WRAP=1` and `--wrap` of the heap. |
| `tv_cyg_hooks.c` | Item 5, `cyg` variant: counts function entries under `-finstrument-functions`. |
| `build.sh` | Builds `bench-time.exe` and `bench-mem.exe` in `$OUT`. |
| `run.sh` | Runs items 0–4 in five processes. Writes the TSV and the run record, and copies them to `results/`. |
| `prof.sh` | Item 5: driver.c with `-pg` and with `-finstrument-functions`, a fixture against a control, `summary.tsv`. |
| `results/` | Created by the runs: copies of the TSV and the records. |

Binaries and intermediate files go only to `$OUT`. The default is
`C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01/opus/tv-real`.
Nothing in `selfbuild` or in the accepted stage is written.

## How it is linked

- **Same as an emitted fixture.**
  - Compile: the flags of `p.CC.log` (`-std=c99 -O2 -fstrict-aliasing ... -I $S/headers -Dmain=l2_generated_main` and the other renames), without `-H`.
  - Link: `bench.o driver.o l2_libc.o -Wl,--strip-debug`, as in `p-prod.LD.log`.
- **Runtime.** The G2 of slice 410 (fable_pc's decision FABLE-R-TV-I; the revision under study is b795a69d + slice
  410), one coherent set:
  - `$S/boot-f410-02/g2/runtime/driver.c` (sha256 `3e6b904d…`);
  - `driver.o` (`20069522…`, byte-identical to `o410-rt-01`);
  - `driver-observe.o` (`d0cd3d64…`);
  - `g2/frontend/l2_libc.o` (`af9fdae3…`);
  - the current `$S/headers`, written by the bootstrap `boot-f410-02`;
  - full run `FIXDIR=$S/f410-g2-full-01`.

  Another G2 is selected with `G2=`, or with `RT=` and `FE=`.
- **Who calls the bench.** The driver's `main` runs its self-checks (ids, code links, activation). Then it calls the
  bench's `main` (= `l2_generated_main`) with the arguments after `--`, so a run looks like
  `bench-time.exe 0 -- <mode> key=value ...`.
- **Driver exit status.** After the bench returns, the driver reports that no host was launched and exits with a
  non-zero status. **That is not the bench's result.** The result is the TSV rows and the line
  `#tv-real done status=0`. `run.sh` checks for that line.
- **Heap counting.** `bench-mem` is linked with `-Wl,--wrap=calloc,--wrap=malloc,--wrap=realloc,--wrap=free`.
  - In driver.o these four functions are plain undefined symbols (`nm -u driver.o`: `U calloc`, `U free`,
    `U malloc`, `U realloc`, not `__imp_`), so the wrapping covers the whole runtime.
  - The tracker keeps an address→size table (`track=`, 2^20 entries by default, 16 MB) and counts:
    - live bytes, i.e. requested and not yet freed;
    - cumulative requested bytes;
    - calls to calloc/malloc, realloc and free.

## Build and run (Git bash)

```bash
cd C:/Nyasha_Planet/LMX/steps/witnesses/typed-value-research-20261116/real
bash build.sh      # bench-time.exe, bench-mem.exe + $OUT/build-record.txt (sha256 of driver.o, l2_libc.o, source, header tree)
bash run.sh        # items 0-4 -> $OUT/tv-real-<UTC>.tsv, $OUT/run-record-<UTC>.txt, copies in results/
bash prof.sh       # item 5 -> $OUT/prof/summary.tsv, prof-record.txt, copies in results/
```

Environment parameters:
- all scripts: `S`, `G2`, `RT`, `FE`, `HDR`, `OUT`, `GCC`;
- run.sh: `EXTRA="R=21 calls=400000"`, appended to every run;
- prof.sh: `FIXDIR`, `FIX`, `CTRL`, `VARIANTS="pg cyg"`.

Single runs by hand:

```bash
OUT=.../opus/tv-real
$OUT/bench-time.exe 0 -- sizes out=$OUT/x.tsv
$OUT/bench-time.exe 0 -- classify N=100,1000,10000 R=15 calls=200000 out=$OUT/x.tsv
$OUT/bench-time.exe 0 -- slot N=100,1000,10000 F=4,16,64 structs=8 R=15 calls=200000 out=$OUT/x.tsv
$OUT/bench-mem.exe  0 -- mem K=10000 KN=1000 out=$OUT/x.tsv
$OUT/bench-time.exe 0 -- create ints=100000 cstructs=10000 CR=7 out=$OUT/x.tsv
```

Keys and their defaults:

| Key | Default | Meaning |
|---|---|---|
| `N` | `100,1000,10000` | Target number of ranges. |
| `F` | `4,16,64` | Number of fields per Structure. |
| `R` | `15` | Repetitions for items 1 and 2. |
| `CR` | `7` | Repetitions for item 4. |
| `calls` | `200000` | Calls per repetition. |
| `structs` | `8` | Structures in item 2. |
| `K` | `10000` | Objects per item-3 row. |
| `KN` | `1000` | Named Structures in item 3. |
| `ints` | `100000` | Int cells in item 4. |
| `cstructs` | `10000` | Structures in item 4. |
| `ptrtype` | `1035` | `LMX_TYPE_POINTER_BASE + 11`: the cell of a native `@: px int @ x`, as in root_pointer_index p.c. |
| `cpu` | `1` | Pins the thread to that CPU and sets HIGH_PRIORITY_CLASS. `-1` turns this off. |
| `seed` | — | Seed of the shuffle. |
| `track` | `2^20` | Size of the heap tracker's table. |
| `out` | — | File the TSV rows are appended to. |

Expected cost, estimated from the code and not measured:
- items 1–2 take a few seconds per N×F;
- item 3, the named row, is quadratic in names (KN=1000 gives 4000 rows);
- item 4 with `ints=100000` holds about 30–40 MB per repetition, released between repetitions;
- prof.sh compiles the 128k-line driver.c twice at -O2, which is the heaviest step.

## The TSV

Comment lines start with `#`. Each run writes:
- `#tv-real ...` with the parameters and `tick_ns`;
- `#item ...` with the column header;
- `#checksum`;
- `#tv-real done status=N`.

Columns: `item metric variant n_target n_ranges pools fields count reps median min max unit`.
- `n_ranges` is the actual `lmx_arena_index_len` at the time of measurement.
- `pools` is the length of the `arena->arrays` list.

| item | What | Rows |
|---|---|---|
| 0 | `sizeof` of the records | LmxRange, LmxPool, LmxChunk, LmxArenaBlock, LmxArena, Lmx, LmxWalkValue, LmxWalkPlace, LmxSourceName, LmxActivationBinding (B) |
| 1 | One classification, ns/call | Functions: `lmx_range_type_of`, `_classify`, `_stride`, `_cell_pool`, `_entry_at`, `_profile`. Address orders: `random` (shuffled), `alloc_order`, `repeat` (one address), `interior` (second byte of a cell), `foreign` (a static of the program, outside the arena). The arena is filled with `lmx_int_new_profiled(arena, 0)` until `index_len ≥ N`. Also `arena/int_cells` and `arena/index_capacity_bytes`. |
| 2 | One slot read, ns/read, for `structs` Structures × F int fields | `lmx_graph_node_in`, `lmx_graph_cell_in`, `lmx_graph_value_in`, `value_in+lmx_walk_value_cell` (slot → kind/type → int, as the walker reads it), `lmx_source_name_get(slot)`, `floor_direct(no runtime call)`. Structures are built as in p.c: `lmx_struct_new_profiled`, `lmx_arena_refs_open_profiled`, then `slot[0] = lmx_int_new_profiled(arena, lmx_range_profile(arena, slot))` and `lmx_source_name_set(slot, code)`. After that, background int cells are added up to N. |
| 3 | Heap per object (bench-mem) | `live_bytes`, `requested_bytes`, `alloc_calls`, `realloc_calls`, `free_calls`, `ranges`, `pools` (all per object), `index_capacity_bytes`, `live_after_release` (B; non-zero means not everything was freed). Kinds are listed below. |
| 4 | Creation time | `create` (ns/obj, median/min/max over CR) and `create_total` (ms). Kinds: int_single and int_bulk (`ints`), struct4_single and struct4_bulk (`cstructs`), ptr_single and uninit_int (`ints`). |

Item 3 kinds:

| Kind | Made by |
|---|---|
| `int_single` | `lmx_int_new_profiled` per cell. |
| `int_bulk` | One `lmx_arena_take_n_profiled(..., LMX_TYPE_INT, K)`. |
| `ptr_single` / `ptr_bulk` | The same for the pointer cell `ptrtype`. |
| `struct4_single` | As p.c makes it, with 4 int fields. |
| `struct4_named` | The same plus 4 names, for KN Structures. |
| `struct4_bulk` | Headers and int cells in one take each; the children array is still one pool per Structure (`lmx_arena_refs_open_profiled` has no multi-Structure request). |
| `uninit_int` | `lmx_graph_uninit_int` of the clean graph. |
| `graph_int` | `lmx_graph_int`, the same for comparison. |

The `_single` against `_bulk` pairs separate the cost of the scheme from the cost of pools of capacity 1. A pool born
from a one-cell take gets `chunk_capacity = 1`, so every later cell is a new chunk, four callocs and a new range.

## Item 5 (prof.sh)

Scenario: `private_hidden_binding`, forced. It is an ordinary frontend fixture with 20 methods, bindings and private
fields. It passes on 409 for both roots (`f410-baseline-full-01`: exit 0, 82/86 checks); on the 410 G2 it is taken
from `f410-g2-full-01`. Default `VARIANTS=cyg`: fable_pc takes "entries × the call price from items 1–2" plus the
difference in whole forced run time against the control; `pg` (gprof) remains an option.

Control: `assign_known`, forced, the minimal one. The scenario minus the control removes the driver's self-checks,
which run in both.

The fixtures with loops are excluded because they do not translate on 409; `f410-baseline-full-01` has only `p.L2.log`
for them. They are `var_own_nested`, `place_write_form`, `written_path_form` and `written_form`. No fixture has a loop
of more than a few iterations.

Two variants:
- **`pg`.** driver.c with `-pg`, then gprof:
  - `flat.txt` and `graph.txt`;
  - in `summary.tsv`: %time, self seconds and calls, for the target functions and the top 20.
  - Limits:
    - The run takes milliseconds while gprof samples every 10 ms, so the time shares are close to zero and
      unreliable.
    - driver.c is one translation unit, so `-O2` inlines many functions (`lmx_range_entry_at`,
      `lmx_arena_index_data`, …) and mcount does not see their calls. A target function that is absent from `pg`
      was inlined, not left uncalled.
- **`cyg`.** driver.c with `-finstrument-functions` plus `tv_cyg_hooks.c`:
  - exact entry counts of every function, including inlined copies;
  - linked with `--disable-dynamicbase`, and the hooks' own address corrects for a relocation;
  - addresses are named by `nm` of the exe (`cyg_tsv` needs gawk's `strtonum`; Git bash's awk is gawk);
  - the instrumentation slows the run, so this variant gives counts only, not time.

**Second scenario, the clean graph's interpreter (optional).** With `GRAPHDIR` set to a `build-graph` output of the
same G2 and headers (it holds `graph_trans.o`), prof.sh relinks the graph tool from that object with the instrumented
driver, as `build-graph` links it with `driver.o`. It then runs `-- run $GSRC/<name>.lm2 1` (graph-check's interp
mode) for `GFIX=control_flow` (7 loops, 8 functions) and the control `GCTRL=data_write` (two statements); rows carry
`fixture=graph:<name>`, `root=rootinterp`. No new code in selfbuild. Unset `GRAPHDIR` skips it.

Counting with `--wrap` of the target functions cannot replace `cyg`. `--wrap` covers only undefined references, and
the calls inside driver.o between its own functions are resolved inside the object.

**Header and build coherence.** driver.c compiles against the headers in `$HDR` (`-I $S/headers`). The fixture's p.o
was compiled against the headers of its own time. `$S/headers` is rewritten by every bootstrap; at 09:41 on
2026-11-16 it was written by `boot-f410-02`, and the defaults name exactly that set. Run prof.sh with an RT, HDR and
FIXDIR set that comes from one build:
- the accepted G2's `driver.c`;
- the headers its build-runtime wrote;
- the full run (`FIXDIR`) whose p.o was linked with that G2.

If driver.c does not compile against `$HDR`, prof.sh stops at that step and reports it.

## Notes on the inventory (typed-value-inventory.txt)

- `ulong` is `unsigned long`, which is 4 bytes on Win64. So `LmxWalkValue` is 104 bytes, not the ≈112 the inventory
  gave. Item 0 measures the real sizes.
- Every name write (`lmx_source_name_set`) first scans every row (`lmx_source_name_row_at`). The new row is taken by
  `lmx_arena_take`, a one-cell take, so it is a chunk and a range of its own. Each set therefore costs a linear scan
  plus one range.
- A Structure's children array is a pool of its own (`lmx_arena_refs_open_profiled` → `lmx_pool_make_profiled`). That
  accounts for most pools in an arena dump (the `kind 4 type 7` pools).
