# Slice 173: an index entry keeps its chunk (RANGE-CELL-POOL-LINEAR)

Opus, 2026-10-23, sole writer/build. Following the author's CODEX-AUTHOR-SELFBUILD-NEXT-20261023T134403Z and
Codex's answer to OPUS-CODEX-20261023-SLICE172 («Продолжай 173 как устранение измеренного общего блокера»): every
graph read walked a chunk chain, so an L2 loop over bytes was quadratic in practice, and a parser or translator
ported to L2 needs exactly such loops.

The stage is `build2/opus_range173`, a copy of Verified172's stage `build2/opus_slice172`. Five kernel inputs change.
Each has a -U0 delta here, and GNU patch applied to the Verified172 input gives the stage's bytes (`u0-same.out`, by
the working binary's `same`):

| Input | SHA-256 | Verified172 | Delta |
| --- | --- | --- | --- |
| `src/l2src/lmx.h.lm1` | `F7DE75894D67CC03E05B0C9756A4B97D3BEA16A44602FD3810743C644F2DC62C` | `14E44C74…` | `lmx.h.lm1.patch` |
| `src/l2src/lmx_range.lm1` | `1D70C72EEAB247A04E752B22DE3448BF7CA22B75CD7C11F0EDCF79DF281E32C6` | `1FE9B29F…` | `lmx_range.lm1.patch` |
| `src/l2src/lmx_pool.lm1` | `CABAB7C0C77CA614F5725CD192F6422BC773E88F3BB85487597A047A164CFE05` | `EEA210D7…` | `lmx_pool.lm1.patch` |
| `src/l2src/lmx_arena.lm1` | `97FC2D1363908D83A99FDD77580CF4D7F5B23297DC21B91CFBDAE86EA57F7E3C` | `AE9123BB…` | `lmx_arena.lm1.patch` |
| `src/l2src/lmx_gc_graph.lm1` | `E205899F5B9473FDEF0B653830C9A79BB39F40ADE18F7FC61C510B4D9F41C9FB` | `7C1552DC…` | `lmx_gc_graph.lm1.patch` |

The frontend, the runner (`tools/l2`) and the lists do not change.

## Measured before the change

A 3-byte `sha256` run of Verified172's working binary took 118.5 s, nearly all of it the launch (`launch-times.txt`).
Stack samples of one such run (`samples-172.txt`, 21 samples 5 s apart, the main thread's top four frames):

| Top frame | Samples |
| --- | --- |
| `lmx_range_cell_pool` (graph reads: `lmx_graph_*_in`, `lmx_reparent_scan`, the program build's `lmx_range_profile`, the collector) | 16 |
| `lmx_arena_find_profiled` (allocation: a walk over the arena's arrays) | 3 |
| `lmx_pool_chunk_at` (the collector's mark) | 2 |

`lmx_range_cell_pool` found the entry by bisection and then walked the entry's array's chunk chain to find the chunk
whose storage starts at the entry's `lo`. The chain grows over a run, so each read cost O(chunks).

## What changed

- `LmxRange` (`lmx.h.lm1`) gains `chunk` and `chunk_gen`; `LmxPool` gains `chain_gen`.
- `lmx_range_entry_chunk` (`lmx_range.lm1`): the chain walk, kept in the entry with the array's `chain_gen` of that
  walk. The kept chunk answers again only while `chain_gen` is unchanged and its storage still starts at `lo`.
  Otherwise the answer is a walk, and that one walk keeps every chunk of the chain in its own entry of the index.
  `lmx_range_cell_pool` calls it; its cell checks are unchanged.
- `lmx_range_keep_chunk`: a chunk is kept in its entry as soon as it is linked and registered (`lmx_pool_add_chunk`,
  `lmx_pool_make_profiled`, `lmx_pool_over`), so a new chunk costs no walk.
- `chain_gen` grows whenever a chunk leaves a chain or a chain is replaced: `lmx_pool_chunk_drop`,
  `lmx_pool_release`, `lmx_pool_over` (`lmx_pool.lm1`), and the reset of an array whose block an arena drops
  (`lmx_arena_drop`, `lmx_arena.lm1`). A chain that only grows keeps it. A new array starts at 0 from its zeroed
  record; it is never reset. (A by-value pool's first value is whatever its record holds; only a change of it
  matters.)
- Entries keep both fields when the index shifts them (`lmx_range_add_view`, `lmx_range_drop`); a new entry starts
  with none.
- `lmx_range_cell_chunk`: the chunk of a live cell, from the index. The collector's mark and its admission liveness
  test (`lmx_gc_graph.lm1`) use it instead of `lmx_pool_chunk_at`: at both places the cell has just been found live in
  that pool, so the chunk the walk finds is that same chunk.

Why a generation and not a plain cached pointer: a chunk's record and its storage are two arena blocks. The record
block is pushed after the storage block, so a revert frees the record first while the storage interval is still in
the index. The walk then answers 0. A plain pointer would read a freed record. The generation makes the kept chunk
stand for the walk only while no chunk has left the chain. An imported entry keeps the foreign array's generation the
same way.

## Results

The same command by each working binary (`launch-times.txt`; wall time, no sampling; the same digest each time):

| Binary | Time |
| --- | --- |
| Verified172 | 118.5 s |
| 173, first version: entries keep their chunk | 32.0 s |
| 173, second version: also kept when linked, one walk per array on a miss | 23.2 s |
| 173, third version: also the collector's chunk from the index | 15.6 s |

Samples of each version's launch: `samples-173a.txt`, `samples-173b.txt`, `samples-173c.txt`. Since the second version
no graph read appears in them, and since the third no chain walk of the collector. The third version's 12 samples: 9
in `lmx_arena_find_profiled` (allocation, reached from the program build and from the source-name table), 2 in the
source-name table's scan (`lmx_source_name_local`), 1 in the collector's cell walk.

Runs, each a quick bootstrap of the stage (`bootstrap-quick-0N.out`, `.command`):
- `rebuild-runtime-01` (first version; the 172 working binary with the 172 frontend): `HEADERS 51 regenerated` (only
  `lmx.lm1.h` changed), the runtime built, smoke `SUITE 5 rows, 0 failures`, `REBUILD runtime 0 failures`.
- `boot-quick-01` (first version; G0 = the 172 working binary), 11:30–11:53: `BOOTSTRAP quick 0 failures`.
- `boot-quick-02` (second version; G0 the same), 11:59–12:21: `BOOTSTRAP quick 0 failures`.
- `boot-quick-03` (third version, the committed sources; G0 = the second version's working binary), 12:25–12:40:
  `BOOTSTRAP quick 0 failures`; smoke `SUITE 5 rows, 0 failures`; G1 and G2 each hash a file and exit 0 with the same
  L1 and C. Their L1 equals Verified172's G1 except the unit hash, which hashes the stage path.

The runner itself, an L2 program, paid the same cost. In `boot-quick-03` the header step (51 `l1trans` runs with
their records) took about 3 s and the smoke list 9 s; in Verified172's `boot-quick-02` they took about 1:48 and
2:40. The whole quick bootstrap took 15:45 instead of 28:18 (its G0, too, ran on the new runtime); gcc's compiles of
G1 and G2 are most of what is left.

## Not run (LATER, by the author's priority of 2026-10-23)

- the kernel gate: its L3 type budget pins the kernel records' sizes, and `LmxRange` and `LmxPool` grew;
- the gate with its controls; `bootstrap full`; a full corpus replay;
- the walker live-tree evidence.

## Defects (steps/defects.md)

| Defect | Status |
| --- | --- |
| RANGE-CELL-POOL-LINEAR | fixed |
| ARENA-LOOKUPS-LINEAR | new, OPEN: the allocation's array search and the source-name table's scan, measured above |
| WALKED-ROOT-C-DOOR-UNSUPPORTED | Codex's ruling recorded: a test-configuration error, root1 is not a C-body walk |

## Process

- The protected basename `l2_driver_launch.err`, written by every launch into its cwd, was excluded from every copy
  and comparison. Every run had a directory of its own, and the stage did not change during a run: the second and
  third versions were made between runs.
