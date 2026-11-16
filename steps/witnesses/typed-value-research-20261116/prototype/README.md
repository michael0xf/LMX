# TypedValue research prototype (C99)

Research artifact by the author's order of 2026-11-16 (model C99); not a maintained project test, outside `selfbuild/`.
Compiler: `C:/Qt/Tools/mingw1310_64/bin/gcc.exe` 13.1.0, flags `-std=c99 -O2 -fstrict-aliasing -Wall -Wextra` (all builds are
warning-free). Pure C99, 64-bit LP64 and LLP64 (static asserts: `int` 4 bytes, `double`/`size_t`/pointers 8 bytes).
The only GNU extension is `__attribute__((noinline))` (macro `NOINLINE`) on the benchmark kernels.

## Representations (`-DREP=<name>`, one executable each, identical static inline API)

| REP | slot holds | record / cell | tag |
|---|---|---|---|
| `tv_align` (**the layout recorded in the documents**) | tag address (start of the record) | tv_word's format with optimal universal alignment: `[tag][value aligned to its type]`, value at +4 always; int-valued records start at a multiple of 4, 8-byte values at tag address 4 mod 8; sizes int 8, double/size_t/ref 12 (+4 padding -> 16 in a stream), Lmx 28 (+4) -> 32 (36 -> 40 NW), uninit:int nested 12, uninit:T (8-byte T) nested 16 (formula only). Padding between records, before the tag. **64-byte line rule**: a record never crosses a line; a skipped line tail of >= 8 bytes is kept as one hole per arena and given to the next record with a 4-byte value. No start map | `*(const int *)rec & 0xFF` |
| `tv_align_noline` (`-DTA_LINE_RULE=0`) | same | tv_align without the line rule and the hole (price and benefit of the rule) | same |
| `tv_word` (author's exact layout) | record start (8-aligned) | `[int type][content at +4][filler to 8]`: int 8, double/size_t/ref 16, Lmx 32 (40 NW), **uninit:int nested 16** (`[UNINIT_INT][INT|EMBEDDED][value]`; flat single record 8 shown in sizes only). One untyped bump stream per arena, raw blocks (slot arrays, Array data) in the same stream, no start map | `*(const int *)rec` |
| `tv_prefix` | content address (struct Lmx address for Structure / Array) | classes 8 / 12 (uninit: `[tag_uninit][tag_int][value]`, slot at `tag_int`, @u = slot + 4) / 16 / 32 (40 NW), natural alignment, 4 reserved/type bytes before the content | `*(const int *)((const char *)p - sizeof(int))` |
| `tv_tagged` | record start | `TvInt{type,value}` 8, `TvReal/TvSize/TvRef` 16, `TvLmx` 32 (40 NW), `TvUninit{type; TvInt inner}` nested, 12 bytes in the 16-byte class (flat 8 in sizes only), pools by class | `*(const int *)rec` (C99 6.7.2.1p13) |
| `cur_range` | cell address | untyped cells in typed pools; type = ONE binary search of the sorted range table `{lo,hi,pool}` (24 B), then pool type + stride + used check | none (address range) |
| `cur_chunkhdr` | cell address | same cells in 64 KB-aligned chunks with a header; trusted handle: header by mask; arbitrary address: hash set of block bases first | none (chunk header) |
| `tv_packed` | record start (4-aligned) | `[tag][value]` with no alignment and no padding: int 8, uninit:int nested 12, wide 12, Lmx 28 (36 NW); bump from chunks; **no start map** | `*(const int *)rec` |
| `tv_packed` + `-DPK_START_MAP=1` (built as `tv_packed_map`) | same | same, plus a record-start bitmap in each chunk header kept at every allocation; `type_of_address` becomes the checked version (nearest start bit, tag, record start / content / inner byte) | same |
| `tv_full` | record start | the author's conditional `TypedValue` verbatim (Lmx inside the union): 32 B (40 NW) for every value | `->type` |
| `tv_compact` | record start | `{type, union{int,double,size_t,void*}}` 16 B; Structure / Array = `value.reference` to a separately allocated Lmx | `->type` |

Common to all: `struct Lmx { struct Lmx *parent; size_t length; void *storage; }` (24 B; `-DLMX_NATIVE_WORD=1` appends
`void *native` = 32 B, built as `bench_<rep>_nw`). Dense data (slot arrays, `Array<int>` data, Array-of-handle data) is dense and
untagged in every representation (cells of the typed pools in `cur_*`, raw chunks in `tv_full/compact/tagged/prefix/packed`,
raw blocks of the same stream in `tv_word`).

## API (every header; names identical)

`arena_new/arena_free`, `set_straddle(a, on)`, `new_int/new_real/new_size/new_uninit_int/new_refcell(target)/new_struct(nslots,
parent)/new_array_int(n)/new_array_ref(n)`, `slots(S)` -> `void **`, `length(S)`, `int_get/int_set/int_addr`,
`real_get/real_set`, `size_get/size_set`, `ref_get/ref_set`, `uninit_ref/uninit_get/uninit_set` (`uninit_ref(u)` = the value of `@u`), `array_int_data(A)`,
`array_ref_data(A)`, `type_of_ref(a, h)` (trusted handle), `type_of_address(a, p)` (arbitrary address), `bytes_live(a)`,
`gc_mark(a, root)`, `graph_copy(dst, src, root)`, `graph_digest(a, root)`. Additions beyond the specification (needed by the shared
algorithms): `lmx_storage/lmx_key/parent_key/set_parent_key` (no representation has to expose an addressable `struct Lmx`;
`tv_packed/tv_word` keep it unaligned), `size_get/size_set`, `uninit_*`, `array_ref_data`, `set_straddle`, `rep_print_layout`.

`type_of_address` semantics (the protocol in `bench selftest` prints exactly this):
* `NULL` and an address outside the arena -> `T_NONE`;
* a slot value (what `slots(S)[i]` holds, which is also `@x` and the value of `S[i]`) -> its type, in **every** representation (`tya_slot_*`
  and `fx_*` lines): for the tagged records (`tv_word`, `tv_tagged`, `tv_packed`, `tv_full`, `tv_compact`) the single reference value is the
  pointer to the record start, the content address (record + 4 / + 8) exists only inside the machine read / write (`int_get`...);
  for `tv_prefix` and `cur_*` it is the content / cell address everywhere;
* content address (`int_addr`), element of a dense array, inner byte -> typed / `T_NONE` in the `cur_*`, `tv_full/compact/tagged/prefix` and
  `tv_packed_map` builds; **`tv_word` and the default `tv_packed` answer for record starts only** (no start map, by the author's
  design): these lines print `n/a` (macro `REP_INTERIOR_ADDR`);
* `uninit:int` (`int: u` without initializer; protocol lines `uninit_*` and `fx_*`): typeof(slot) = `uninit:int` (8) and typeof(`@u`) = `int` (1), both
  unchanged by writes, `@u` is the same address, a read through the saved `@u` gives the written value -- in EVERY representation.
  `cur_*`: pointer cell of pool UNINIT_INT pointing to its own int cell; `tv_full/compact`: an outer record pointing to its own inner int record
  (as now, two allocations); `tv_word/tv_tagged/tv_packed`: ONE allocation with a nested record `[UNINIT_INT][INT|EMBEDDED][value]`
  (16 / 16 (class) / 12 bytes), slot = outer start, `@u` = outer + 4 (a constant, no memory read) = the start of the nested record; its tag carries
  `T_EMBEDDED`, masked out when a type is reported, and `gc_mark` steps back 4 bytes to the allocation start (`gc_with_at_u_in_slot_ok`);
  `tv_prefix`: one block `[tag_uninit][tag_int][value]`, slot at `tag_int`, `@u` = slot + 4. The flat form `{UNINIT_INT; int}` (8 bytes) is built
  only by `new_uninit_int_flat` for the sizes table: typeof(`@u`) would be `uninit:int`, so it fails the protocol.
  Limitation: `graph_copy` of a graph in which a slot holds `@u` of an uninit variable copies that nested address as an independent int
  (no graph of the benchmarks stores `@u`).

GC / copy policy (one algorithm, `graph_algos.h`): `gc_mark` follows slot targets, Array-of-handle elements and reference-cell targets
(the parent link is not an edge), one mark bit per object in a per-chunk (per-range) bitmap, returns the number of marked objects;
`graph_copy` keeps shared targets and cycles with one source->copy open-addressing map (key = the object's Lmx for Structures / Arrays,
the handle otherwise) and restores parent links of copied Structures / Arrays; `graph_digest` is a representation-independent hash of types,
values, sharing and parents (used by T5 and the selftest to prove the copy isomorphic). A sequential sweep over a `tv_word` chunk is NOT implemented
(raw blocks carry no tag, so it needs block descriptors); only reachability marking exists, with the same policy in every representation.

`bytes_live(a)`: issued cells / records / raw runs in bytes, chunk headers (+ start bitmap), range table capacity (`cur_range`), hash set of
chunk bases and chunk list (`cs_bytes`), the `Arena` struct. Unused chunk capacity is not counted; transient mark bitmaps are not counted.

## Controls (what the nanoseconds of the 8-byte access are made of)

| build | addresses of 8-byte values | access | notes |
|---|---|---|---|
| `tv_word` | 4 mod 8 (unaligned) | `memcpy` of 8 bytes | the author's layout |
| `tv_word_typed` (`-DTW_TYPED_UNALIGNED=1`) | the same | typed lvalue of alignment 1 (`typedef double tw_u_double __attribute__((aligned(1)))`, GNU extension, this control only) | keeps strict aliasing, so the compiler need not reload the context |
| `tv_align_memcpy` (`-DTA_MEMCPY=1`) | 0 mod 8 (aligned) | `memcpy` | |
| `tv_align` | 0 mod 8 (aligned) | typed `double` / `size_t` / `void *` lvalues; descriptor as `(struct Lmx *)(rec + 4)` | the layout recorded in the documents |

Dense storage (slot arrays, `Array<T>` data) starts on a 64-byte boundary in every `tv_*` representation (`TV_RAW_ALIGN`, default 64; the padding is part of
`bytes_live`); `-DTW_RAW_ALIGN=8` / `-DTA_RAW_ALIGN=8` (builds `tv_word_raw8`, `tv_align_raw8`) reproduce the earlier 8-aligned placement, `-DTV_RAW_ALIGN=8` does it for
the other `tv_*` headers. `cur_*` are unchanged.

## Build

```
sh build.sh                 # all: tv_align tv_align_noline tv_word tv_prefix tv_tagged cur_range cur_chunkhdr tv_packed tv_packed_map tv_full tv_compact
sh build.sh tv_word tv_prefix   # some
```
Outputs: `bin/bench_<rep>.exe`, `bin/bench_<rep>_nw.exe` (native word), `bin/sizes_<rep>[_nw].exe`, `asm/bench_<rep>.s` (`gcc -S`).
Compile only; `build.sh` runs nothing. Key kernels (noinline): `t1_known_rw`, `t1w_known_rw`, `t2a_dyn_read` (listings of the last two
representations of interest are cut out in `asm/key/`).

## Run

`bin/bench_<rep>.exe selftest > out.txt` and `diff` between representations (expected differences: only the `n/a` lines of `tv_word` /
`tv_packed`). `bin/sizes_<rep>.exe` prints sizeof / alignof / offsetof of the records, the full storage cost of typical values, for the stream representations (`tv_align*`, `tv_word`) the mixed T2 stream (bytes per record, waste split into alignment padding / skipped line tails / holes reused) and the
walker-record comparison (`WalkValueNow` vs `WalkValueTv`); `out/sizes_all.txt` has all variants.

```
bench [--straddle] t1  <nstruct> <nfields> <passes> <R> <seed>     known-type int read-modify-write through a ready index map (no tag, no classification)
bench [--straddle] t1w <nstruct> <nfields> <passes> <R> <seed>     same, fields double (even index) and size_t (odd index)
bench [--straddle] t2  <nstruct> <nfields> <passes> <R> <seed>     mixed fields in random order: t2a dynamic type, t2b expected type with 1/1000 mismatches
bench [--straddle] t3  <nstruct> <nfields> <nchain> <steps> <passes> <R> <seed>    t3a sequential pass, t3b dependent chase (nodes allocated in order, linked shuffled)
bench [--straddle] t3w <nstruct> <nfields> <nchain> <steps> <passes> <R> <seed>    same over double / size_t fields (chase ids are doubles)
bench [--straddle] t4  <nstruct> <passes> <R> <seed>               two slots on one int cell; replace a slot by a double cell; read content with its type
bench [--straddle] t4w <nstruct> <passes> <R> <seed>               same with a double cell replaced by a size_t cell
bench [--straddle] t5  <nnodes> <fanout> <R> <seed>                rows t5_build, t5_copy, t5_gc_mark (ns per node / per object); copy checked isomorphic
bench [--straddle] t6  <n> <passes> <R> <seed>                     control: dense Array<int> through array_int_data; loop over C locals (rows t6_array_sum, t6_locals)
bench [--straddle] t7  <nstruct> <nfields> <passes> <R> <seed>     type_of_address over slot values in shuffled order
```
Output: one TSV line per measurement: `rep test params ops R median_ns/op min max bytes_live checksum(hex) fill` (`fill` = share of padding, fillers and unused line tails in the issued stream for `tv_align*` and `tv_word`, `-` for the others; the T5 rows show it for the built graph). The checksum is identical in
every representation for the same arguments (verified by tiny runs of every test in all builds; no timing was taken). `--straddle`
(placement for the 16-byte wide records): `tv_word` starts every 16-byte record at 56 mod 64 so that its 8-byte content crosses a 64-byte
cache line (padding included in `bytes_live`); `tv_packed` does the same for its 12-byte records; for the aligned representations
(`tv_tagged`, `tv_prefix`, `tv_full`, `tv_compact`, `cur_*`) the same order of records gives aligned content and `--straddle` is a no-op,
which is the comparison asked for. T2 and T4 contain wide fields (double, size_t, reference) as well; `t1w`, `t3w`, `t4w` are the wide-only subtests.

### Suggested sizes (checksums and ops are independent of the representation; memory is for the largest, `tv_full`, below ~400 MB)

| test | small (fits L1/L2) | large (live data far above 16 MB L3) |
|---|---|---|
| t1 | `64 8 20000 9 1` | `500000 8 1 5 1` (~176 MB in `tv_full`) |
| t1w | `64 8 20000 9 1` | `300000 8 1 5 1` (~106 MB `tv_full`, ~182 MB `tv_word --straddle`) |
| t2 | `64 12 10000 9 1` | `200000 12 1 5 1` (~122 MB) |
| t3 / t3w | `64 12 256 2000000 10000 9 1` | `150000 12 2000000 4000000 1 5 1` (~250 MB `tv_full`) |
| t4 / t4w | `64 100000 9 1` | `1000000 1 5 1` (~112 MB; ~176 MB `tv_word --straddle`) |
| t5 | `200 5 2000 1` | `600000 5 3 1` (src+dst+copy map ~350 MB in `tv_full`) |
| t6 | `1024 10000 9 1` | `50000000 1 5 1` (200 MB of ints, identical everywhere) |
| t7 | `64 12 10000 9 1` | `200000 12 1 5 1` |

`run_matrix.sh` prints the full command matrix (reps x tests x {small, large} x {natural, --straddle}); it only echoes unless given `RUN=1`.

## C99 notes (no UB, no packed attributes)

* `tv_tagged/full/compact`: tag = first member of the record struct; read through the struct (6.7.2.1p13).
* `tv_prefix`: `p` points to a member (`value`, `lmx`, `tag_int`) of a struct object; the four bytes before it are the member `type` / `tag_uninit` of the **same**
  object (compile-time asserts `offsetof(value) - offsetof(type) == sizeof(int)`); the access reads that member as an `int` (6.5p7) and the address
  arithmetic is on the character representation of the enclosing struct object (6.3.2.3p7, 6.5.6p8) -- the container_of idiom.
* `tv_word`, `tv_packed`: records are written and read with ordinary `int` accesses at 4-aligned addresses (tag, 4-byte content) and with
  `memcpy` of a fixed size for 8-byte content and Lmx fields; gcc emits single `mov`/`movsd` (see `asm/key/tv_word_t1w_known_rw.s`: `movsd 4(%rdx), %xmm1`,
  `movq 4(%r9), %rdx`, `movq %rdx, 4(%r9)`, storage pointer `movq 20(%rax), %r10`). Memory is `malloc`'d storage written once per type before it is read.
* Address comparisons go through `uintptr_t`.
