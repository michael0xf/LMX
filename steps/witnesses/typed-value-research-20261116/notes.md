# Value record research: the physical type beside the value

Written 2026-11-16 by Fable (fable_pc). The inventories of the runtime and the harness on the real
runtime are by the peer session opus; the inventory of native lowering and the C99 prototype are by
the peer session sonnet; the inventory of documentation sites is by the peer session haiku. Fable
set the questions and the prototype specification, ran the prototype timings and wrote the norm.

## The task and the decision

The author asked to study a move from the present scheme — a cell without a type tag, whose
physical type the arena learns by classifying the cell's address through registered ranges — to a
record that keeps the type next to the value, and to compare memory and speed honestly.

The task gave a C declaration with a `union` that contains `Lmx`. Read literally it sizes every
record by its largest member: 40 bytes with the present 32-byte header. The author corrected this
the same day ([journal](../../../LMX_blog/2026-11-16.md#typed-value-raw-layout)): the declaration is a
conventional notation; the record is `int type` and, right after it, the raw bytes of a value of
that type's own size; nobody searches for record starts by an arbitrary address.

The author then decided ([journal](../../../LMX_blog/2026-11-16.md#typed-value-decision)): the record
is adopted; typing and the extraction of a value go through it, without checking addresses; the
alignment is left to the implementation ("optimal and universal, not by the rules of a C union");
typed chunks of the arena may stay; arenas attach other arenas within a Message and one arena is
never accessed from several threads. The norm is written in
[L2 §3–§4](../../../docs/L2_spec_en.md#value-record) and in
[the kernel specification §2.0](../../../docs/kernel-implementation.en.md#value-record); the order
of work is [plan M15](../../../next_core_tasks_v3.md#typed-value-records). The language does not
change.

Revision studied: `main` b795a69d with slice 410 (published as a0d5705a). Host: AMD Ryzen 7 5800H
(8 cores, 512 KB L2 per core, 16 MB L3), 15.4 GB RAM, Windows 11, gcc 13.1.0 MinGW-w64 x86_64 with
the project's flags `-std=c99 -O2 -fstrict-aliasing`. Only this ABI (x86-64, LLP64) was measured;
nothing below is a claim about another platform.

## The present scheme on the real runtime (`real/`)

The harness links the accepted G2 runtime of slice 410 (`driver.o` 20069522) and calls its ordinary
entries; commands and the TSV format are in `real/README.md`, raw results in `real/results/`.
Medians; the spread is in the TSV.

Sizes of the service records, bytes: `LmxRange` 96, `LmxPool` 104, `LmxChunk` 48, `LmxArenaBlock`
40, `Lmx` 32, `LmxWalkValue` 104, `LmxSourceName` 72.

| What | 100 intervals | 1000 intervals | 10 000 intervals |
| --- | --- | --- | --- |
| `lmx_range_type_of`, random addresses, ns | 10.6 | 14.5 | 80.2 |
| the bisection alone (`lmx_range_entry_at`), ns | 5.8 | 9.8 | 68.6 |
| `lmx_graph_node_in`, ns | 23 | 30 | 35 |
| `lmx_graph_value_in` (one read of a graph slot), ns | 107 | 151 | 170 |
| the same with `lmx_walk_value_cell`, ns | 154 | 211 | 241 |
| `lmx_source_name_get` for a slot, ns | 145 | 688 | 3374 |

The same loop without kernel calls costs 0.35–0.53 ns. The name lookup grows linearly with the
number of name rows (32, 128, 512 in these columns).

| Object allocated on its own | Live heap bytes | Allocator calls | Intervals |
| --- | --- | --- | --- |
| `int` | 289 | 4 | 1 |
| reference cell | 397 | 4 | 1 |
| Structure of four `int` fields | 1581 | 24 | 6 |
| the same with names | 3324 | 40 | 10 |
| place `uninit:int` of the clean graph | 686 | 8 | 2 |

In one bulk request an `int` takes 4 bytes and a reference cell 112 (8 and a 104-byte context). A
pool born by a single-cell request keeps a chunk capacity of one, so every further cell gets a
chunk, an interval and two block records of its own (`lmx_pool_add_chunk`). Creation is superlinear:
35.5 µs per `int` over 10^5 separately allocated cells, 277 µs per Structure over 10^4, 155 µs per
`uninit:int`.

Whole scenarios, exact numbers of function entries from an instrumented build of the same runtime.
`private_hidden_binding`, forced, root0: 27.5 million entries in all; `lmx_range_entry_at` 685 093,
`lmx_range_cell_pool` 280 988, `lmx_range_classify` 108 478, `lmx_range_stride` 59 600,
`lmx_range_type_of` 31 239, `lmx_arena_index_data` 10.9 million (one per bisection step),
`lmx_chunk_data` 12.0 million (mostly the block-liveness pass of the collector, which walks every
pool for every block). The clean-graph fixture `control_flow` in interp mode: `lmx_range_entry_at`
485 366, `lmx_range_cell_pool` 430 190, `lmx_range_classify` 163 114, `lmx_range_type_of` 90 354.
Uninstrumented wall time of the forced scenario: 108.6 ms against 55.8 ms of the control program
(31 runs each).

Reading. The cost of the present code is far above the principle "type by range": about ten
bisections for one slot read, a chunk and an interval for every separately allocated cell, linear
searches of pools and names. So the comparison below has three columns: the code as it is, the same
scheme done well (the prototype's `cur_range` and `cur_chunkhdr`), and the record.

## What the code takes from an address today (`inventory/`)

- `runtime-current-scheme.txt` — pools, chunks, intervals, the classification path, the hot paths of
  the walker, `uninit:T`, names, collection, copying.
- `runtime-side-data.txt` — everything that rests on typed chunks of equal step: the contexts of
  reference cells (104 bytes per cell, found by chunk arithmetic), pool profiles, code links, the
  scalar ABI rows, pointer callbacks, capacity, collection, import views, rollback.
- `native-lowering.txt` — what emitted native code asks of the classifier: mostly write rights, the
  context of a cell and "is this address alive"; the type of a number comes from the translator as
  a constant; `sys\typeof` exists only in the clean graph.
- `doc-sites.md` — documentation passages about physical placement by class; not verified by Fable
  beyond the sections changed with this record.

## The prototype (`prototype/`)

Sources, build and run commands are in `prototype/` (`README.md`, `build.sh`, `run_matrix.sh`); raw
timings in `prototype/out/results-*.tsv` (first run) and `results2-*.tsv` (second run), sizes in
`out/sizes_all.txt`, protocols in `out/selftest_*.txt`, the read kernels in `asm/key/`. Executables
and full listings are not kept.

Nine representations in the first run, with one inline API and one benchmark driver, a separate executable each:
`cur_range` (untagged cells in typed pools, one binary search of 24-byte range rows — the present
layout at its best), `cur_chunkhdr` (the same cells, type from the header of a 64 KB-aligned
chunk), `tv_full` (the literal `union`), `tv_compact` (16-byte record, large values by reference),
`tv_tagged` (code first, value at its natural offset, pools by step), `tv_prefix` (the slot holds
the address of an aligned value, the code is in the four bytes before it), `tv_word` (the author's
description: one untyped stream, record start word-aligned, value at offset 4), `tv_packed` (no
alignment at all) and `tv_packed_map` (the same with a bitmap of record starts).

Behaviour is compared by a text protocol of 67 lines that repeats the pinned results of the fixtures
`tests/graph/typeof.lm2` and `struct_index.lm2`: `typeof(@i)` is `int`, `typeof(@u)` of a place
without an initializer is `int` while the type of its slot is `uninit:int`, both before and after a
write, the address of the cell does not change, `S[0] := @j` makes a typed reference read `j`,
`S[1] := S[0]` does not inherit `uninit:int`, a write through an alias is visible, a dense array stays
dense. Seven builds give identical protocols; `tv_word` and `tv_packed` differ in six lines where
they answer for record starts only, as designed. Checksums of every benchmark are equal in all
builds. The compiled kernels were read: the loads, stores and the switch on the code are in place.

Storage, bytes per value with chunk headers (a slot is 8 more):

| Representation | `int` | 8-byte value | `uninit:int` | Structure, 4 `int` fields, all included |
| --- | --- | --- | --- | --- |
| `cur_range`, `cur_chunkhdr` | 4 | 8 | 12 | 72 |
| `tv_word`, `tv_tagged` | 8 | 16 | 16 | 96 |
| `tv_prefix` | 8 | 16 | 12 | 96 |
| `tv_packed` | 8 | 12 | 12 | 92 |
| `tv_compact` | 16 | 16 | 32 | 136 |
| `tv_full` | 32 | 32 | 64 | 192 |

Against the present layout at its best a record costs 4 bytes per `int` and 8 per eight-byte value;
against the present code it saves two orders of magnitude for separately allocated values.

Timings, ns per operation, median of 9 runs (small, fits the cache) and of 5 runs (large, live data
of 45–170 MB). `stream` is `tv_word`, `pools+code` is `tv_tagged`/`tv_prefix`.

| Test | Size | stream | pools+code | `cur_chunkhdr` | `cur_range` | `tv_full` |
| --- | --- | --- | --- | --- | --- | --- |
| read and write of a known `int` field | small | 0.61 | 0.59–0.62 | 0.63 | 0.64 | 0.62 |
| | large | 10.8 | 19.5 | 19.8 | 19.2 | 19.8 |
| read and write of a known 8-byte field | small | 1.80 | 0.74–0.83 | 0.90 | 0.81 | 0.75 |
| | large | 21.5 | 18.4–20.7 | 22.6 | 22.1 | 18.7 |
| read with the type found at run time | small | 3.84 | 2.80–3.38 | 1.66 | 5.50 | 3.53 |
| | large | 36.1 | 46.4–52.7 | 47.2 | 115.8 | 51.5 |
| sequential pass over fields | large | 8.1 | 8.0–8.1 | 8.2 | 16.7 | 9.1 |
| dependent chase of scattered records | large | 137 | 247 | 242 | 236 | 243 |
| alias write, slot replacement, read | large | 89.5 | 131 | 136 | 260 | 122 |
| collector marking, per object | large | 25.0 | 35–43 | 32.9 | 40.8 | 32.9 |
| graph build / copy, per node | large | 123 / 157 | 124–130 / 144–159 | 119 / 138 | 119 / 152 | 135 / 161 |
| dense `Array<int>` sum (control) | large | 0.55 | 0.30 | 0.30 | 0.32 | 0.31 |
| loop over C locals (control) | large | 0.96 | 0.96–1.00 | 0.97 | 1.01 | 0.97 |

With every 16-byte record of the stream forced to start 8 bytes before a 64-byte boundary the
known 8-byte read and write takes 2.48 ns small and 32.4 ns large; the aligned representations do
not change.

What the numbers say:

1. A read or a write of a known type costs the same in every representation: the code is not
   touched and costs nothing.
2. When the type is found at run time, the code in the record and the type in a chunk header cost
   the same; both are 2.2–2.5 times cheaper than one bisection on large data, and the present code
   pays about ten bisections where the prototype's best pays one.
3. An eight-byte value at offset 4 is read and written 2.2–3 times slower than an aligned one while
   the data fits the cache (1.80–2.48 ns against 0.74–0.90). The second run below separates the
   causes: most of it is the copying of bytes, not the offset. Hence the norm: the value at its
   natural alignment, read by an ordinary typed access.
4. On data beyond the cache one stream of records is 1.3–1.8 times faster than pools by type —
   10.8 against 19.5 ns for a known `int`, 137 against 247 for the chase — because the descriptor,
   the slots and the fields of one Structure lie side by side. This is locality, not the code: the
   pools with a code are no faster than the pools without one. It is the reason for step 7 of M15.
5. The dense array sum is twice slower in the stream of this run. The first version of this record
   blamed the 8-byte alignment of the stream's raw blocks; that was wrong. The second run shows the
   cause is again the copying of bytes: the build that reads the descriptor by `memcpy` cannot keep
   the storage pointer in a register, and a stream with 8-aligned blocks and typed access is as
   fast as the pools.
6. The literal `union` record costs 2.4 times the memory of the chosen record for a Structure of
   `int` fields and is not faster in any test.

## Second run: the layout of the norm and the control builds

Added after the first run: `tv_align` (one stream; the value at an address that is a multiple of
`max(alignof(T), 4)`, the code in the four bytes before it, the slot holds the address of the code,
typed access; a record of up to 64 bytes does not cross a 64-byte block boundary, and the skipped
tail is given to the next 8-byte record), `tv_align_noline` (the same without the block rule),
`tv_align_memcpy` (the same addresses, access by `memcpy`), `tv_align_raw8` (dense storage aligned
to 8 instead of 64), `tv_word_typed` (the addresses of `tv_word`, typed access through a pointer of
reduced alignment — a GNU extension used for this control only). The machine was busier than in
the first run, so compare within a run, not across runs.

Read and write of a known 8-byte field inside the cache, ns:

| | typed access | access by copying bytes |
| --- | --- | --- |
| value aligned (`tv_align`, `tv_align_memcpy`) | 0.97 | 2.20 |
| value at offset 4 (`tv_word_typed`, `tv_word`) | 1.23 | 2.49 |
| value at offset 4, every record crossing a block boundary | 1.75 | 3.34 |

Copying bytes costs about 1.2 ns here, the offset 0.3 ns, a crossing 0.5–0.9 ns. The copying makes
every store a store through a character type, so the compiler reloads the map pointer and the loop
bound on every iteration (visible in `asm/key/tv_word_t1w_known_rw.s`). The same shows in the
control test: the dense array sum takes 0.83 ns in `tv_align_memcpy` and 0.61 in `tv_word` against
0.37 in `tv_align`, `tv_align_raw8` and `tv_word_typed`.

Large data, ns per operation:

| Test | `tv_align` | `tv_align_noline` | `tv_word` | `tv_tagged` (pools) |
| --- | --- | --- | --- | --- |
| known `int` field | 13.5–17.2 | 13.7–16.4 | 13.9–16.4 | 21.6–24.4 |
| known 8-byte field | 18.2–21.1 | 19.0–21.1 | 24.6 (35.8 crossing) | 20.4 |
| type found at run time | 39.4–44.2 | 46.0–49.3 | 39.9–42.5 | 52.0–53.0 |
| dependent chase | 138 | 138 | 139 | 271 |
| alias and slot replacement | 79–98 | 91 | 72–75 | 145–147 |
| collector marking | 42 | 42–45 | 29–33 | 53–54 |

What the second run adds:

1. The layout of the norm in one stream keeps the locality gain of the first run and removes the
   penalty of the 8-byte values.
2. The block rule gives nothing measurable: `tv_align_noline` is within the noise of `tv_align`. It
   skips 93 KB of 8 MB in the mixed stream of the dynamic-read test and gets 84 % of that back
   through the remembered hole, so it is cheap, but it has no measured ground and is not in the
   norm.
3. Aligning dense storage to 64 bytes gives no speed (`tv_align_raw8` is not slower) and costs
   memory: 18.5 against 14.8 bytes per record of that mixed stream, a Structure of four `int`
   fields 128 bytes against 96. Dense storage keeps the natural alignment of its element.

## Alignment: the calculation

With the start of a record aligned to the machine word and an 8-byte value at offset 4, the value
crosses a 64-byte block boundary when the record starts at 56 modulo 64 — one position of eight,
12.5 % under a uniform distribution; in an actual stream it is 0 % after an even and 25 % after an
odd number of preceding 8-byte records. A descriptor has three such fields. With the value aligned
and the code right before it, the value never crosses, but the code may stay in the previous block
with the same frequency (a remark by Codex, passed on by the author). The first version of the norm
therefore had two parts: the value at an address that is a multiple of `max(alignof(T), 4)` with the
code in the four bytes before it, and a record that fits into 64 bytes not crossing a 64-byte block
boundary. The second run found no measurable effect of the second part, and the norm keeps the
first only; in pools of equal power-of-two step the second holds by itself anyway.

## The order decided by the author

After the first large run the author ordered two stages
([journal](../../../LMX_blog/2026-11-16.md#typed-value-two-stages)): first the records inside the
present typed chunks, then the typed chunks removed and one stream. Plan M15 has them as steps 1–6
and step 7.

## Open and not done

- The encoding of a reference was asked of the author and answered the same day: a stored
  reference is the address of the value, the code is four bytes before it
  ([question and answer](../../../LMX_blog/q/typed-value-reference-encoding-answered-20261116.md)). In the prototype this is
  the convention of `tv_prefix`; `tv_align` keeps the address of the code in the slot and differs
  from the norm by that constant only.
- The timings are single-machine and single-session; the second run was taken on a busier machine
  and differs from the first by up to 40 % in absolute numbers. Ratios within a run are what the
  conclusions use.
- In the prototype a Structure and its fields are created one after another, as the graph builder
  does; on a long-lived arena with reused free places the neighbourhood, and the gain of the
  stream, will be smaller than measured.
- No hardware counters were available; cache misses are inferred from the small/large difference.
- A whole LMX scenario on records can be measured only after steps 1–2 of M15; the scenario
  numbers above are the baseline for it.
- The clean-graph fixtures `control_flow` and `post_loop` fail on the graph tools of both 409 and
  410; they are recorded in `steps/current.md` and are not part of this research.
