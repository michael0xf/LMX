# Slice 175: the review defects of slice 174, signatures through the common admission

Opus, 2026-10-23, sole writer/build. This slice fixes the seven defects of slice 174's internal review
(`steps/defects.md`). Two of them concern signatures, and by the author's directive
CODEX-AUTHOR-COMMON-SIGNATURE-ADMISSION-20261023T181842Z they go through the common admission mechanism, with no
special rule for libraries. The route was sent to Codex as OPUS-CODEX-20261023-ROUTE175, and Codex's corrections
(CODEX-OPUS-20261023-ROUTE175) are applied:
- only the calls the Consumer writes are checked: a transported callable is not asked about future calls;
- the exact signature equality of today's calls is a measured limit of the current ABI, not Q49;
- a Structure position is proved only at the value's real reception;
- the pool role of an occurrence is not how a callable is recognized.

The stage is `build2/opus_fix175`, a copy of Verified174's stage `build2/opus_lib174`.
- Four inputs change. Each has a -U0 delta here, and GNU patch applied to the Verified174 input gives the stage's
  bytes (`u0-same.out`).
- The runner (`tools/l2`) and the lists (`tests/l2`) change in the repository. The stage holds byte-equal copies.

| Input | SHA-256 | Delta |
| --- | --- | --- |
| `src/l2src/l2trans.lm1` | `BEAD4E4E3B345EB0B89644DFDBFF5661C64E2FCB71410A8A5D23E2995398A814` | `l2trans.lm1.patch` |
| `src/l2src/l2_application.h.lm1` | `24324717A06DB7D3C497AF6FB67EE0A8D8B85155FBB8AAE874AE8ED48416A861` | `l2_application.h.lm1.patch` |
| `src/l2src/lmx_implements.lm1` | `6AB2D90E6236857EA46BD3C4AA4D9A9548C121530C6967EFC9D528F906200A6F` | `lmx_implements.lm1.patch` |
| `src/l2src/lmx_implements.h.lm1` | `78ECF3BEFB53F6AC0061CBC3835FB5D36A91D5BAD29E7EB0A18F8A4EDF8209AE` | `lmx_implements.h.lm1.patch` |

## What changed

### A written call is the Consumer's use of a callable field

The norm (book §7, #three-argument-implements; Q49) checks a callable field against the calls the Consumer writes.
Before this slice, the Consumer's coverage marked every callable field consumed whole: the walk entered the
model's descriptor as a plain Structure and matched its `args` and `return` parts by the names of their places
(174's named view). So it admitted implementations that the call cannot run.

- CHECK marks the head path of a written call through a value (`a1\m()`, `x\m()` of a formal) invoked: bit 2 of the
  path fact's CHECK roles (`l2_use_invoked`).
- The Consumer's use plan gives that field a called edge (`below = SIZE_MAX - 1` in the receiving record's coverage,
  `lmx_implements.h.lm1`, LmxImplUses). Any other use of a callable field is consumed whole, as before.
- The kernel's walk (`lmx_implements_walk_project_resolve`) does not enter a called field. It asks whether the
  candidate's value takes the call that the caller forms from the model's description of the field
  (`lmx_implements_call_takes`). Those are the header parts of every occurrence: `args`, the inputs supplied by
  position, and `return`, the result read.

The call check in its current implementation state:
- the formed call passes exactly the description's inputs (`refs[j]`, `nargs`) and forms no omitted input from a
  default. The candidate's `args` part therefore has the description's width. This follows from Q49's "accepts the
  supplied inputs" with today's ABI; it is not a rule that callables have equal signatures;
- each position keeps one kind and type;
- a Structure or callable position is proved only when both name the same model. A value of another model would be
  admitted where it is received, and a callee's formal does not do that yet, so that position is UNKNOWN;
- a call that reads no result takes a candidate that gives one: the native trampoline now drops a scalar result when
  `dest = 0`, as a walked call already did. Before, it aborted;
- declared exits are not described at run time (OPEN).

### A provided construction's own description

The callable that a provided descriptor's known calls reach is the construction export. Its description is fixed by
the S8.1 construction ABI: no input, the instance as a Structure reference, E's status as its exits.
- `l2_providers_check` checks the descriptor against it with the one signature rule of a known call
  (`l2_sig_takes`). `l2_method_sig_compatible`, the rule a callable formal's actual meets, now calls it too.
- A mismatch is refused at the descriptor: "incompatible entry signature: a provided construction takes no input and
  gives its instance, a Structure".
- A provided descriptor's calls are on the status channel, as a held call's and a callable formal's contract are.

### The library-side defects

- LIBRARY-EXPORT-HEADER-SPLIT: the construction export's header is written after every helper definition, as the
  program builder's is.
- LIBRARY-HELPER-NAMES-UNHASHED: in a library, the fixed helper names are renamed by the unit hash before the first
  prototype (`l2_emit_library_helper_names`): `l2_send_fail`, `l2_msend<k>`, the held-call helpers,
  `l2_mad_construct_<i>`, `l2_view_build_<s>`, `l2_t7_make_<s>`, `l2_t7_construct_<s>`, `l2_merge_body_build_<r>` and
  `l2_kx<oi>`.
- LIBRARY-FIELD-PLACES-UNNAMED: a unit's Array field and its Structure fields name their owning slot too, as a model's
  fields do.
- LIBRARY-REPEAT-DECLARATION-REFUSED: the library's root test also takes a repeat declaration, which the reuse list
  records.

### The runner (RUNNER-LINKS-ROW-CHECKS)

- Each LIBS item is checked as PATH=NAME (`libs_ok`).
- `argv_words` takes its capacity and fails instead of cutting.
- A library's files are named by the item's index too.
- `suite_split_rows` makes a links row's LIBS absolute.

## The witness

The links row of the smoke list gains library C (`tests/l2/lib/lib_c.lm2`). Its `lib_c_next` takes an input
(`int: by`) that the owner's model of it does not describe. The owner's `try_c` writes the call `c1\lib_c_next()`,
so the admission of C's instance to `LibC` is refused where `try_c` binds it. That is `try_c`'s implicit
`implements`, and its handler takes it (30). The A1/A2/B1 part is unchanged.

## Results

Three rebuilds came first:
- `rebuild frontend` (`fe-02`, `rebuild-frontend-02.out`): the 175 frontend with Verified174's runtime gave
  `SUITE 6 rows, 4 failures`, only the owner's four runs. The 174 kernel reads the called mark as a level it does not
  have. An earlier attempt, `fe-01`, did not compile: an argument path needed its parentheses.
- `rebuild runtime` (`rt-01`, `rebuild-runtime-01.out`): the 175 frontend and runtime, still with Verified174's
  runner, gave `SUITE 6 rows, 0 failures`.
- `rebuild tool` (`tool-01`, `rebuild-tool-01.out`): the 175 tool reported `REBUILD tool 0 failures`. Its own smoke,
  with the 175 runner, names the library files by index (`lib_a-0`, `lib_b-1`, `lib_c-2`).

The quick bootstrap `boot-quick-01` then ran 16:26–16:46 (`bootstrap-quick-01.out`, `.command`), with `tool-01` as G0.
It reported `BOOTSTRAP quick 0 failures`:
- the headers were regenerated (`HEADERS 51 regenerated`), and the runtime and the frontend were built;
- smoke gave `SUITE 6 rows, 0 failures`;
- G1 and G2 each hash a file with one digest of the tool's L1 (`6a68fec2…`), the L1 that `tool-01` had;
- the working binary is G2.

| Built by `boot-quick-01` | SHA-256 |
| --- | --- |
| `frontend/l2trans.exe` | `95E75437D7A0C4D3C7A5E55206AC75DF92179F7662DAD3478D10C344BC8E4ED8` |
| `runtime/driver.o` | `D7379004503A76CAD97D44E4ADFBAB940F54841A4232D534670B10C2C7B87503` |
| `lmxtool.exe` (G2) | `F3153DF04A77968D625AEAE2379100665B4216B0A3E207D83388D23FBAF7CC63` |

The runtime's bytes equal `rt-01`'s. The frontend's C equals `fe-02`'s (`3652d4c1…`); only the executable's PE stamp
differs.

The witness, as the bootstrap's smoke ran it (`witness-native-root0.log` … `witness-forced-root1.log`). The owner was
built natively and with `--walk-methods`, and each was run at the root and walked. All four print:

```
S81 calls A1=41 A2=41 B1=42 A1=42 B1=43 A2=42
S81 counts A1=42 A2=42 B1=43
S81 after A1 count 100: A1=101 A2=43
S81 C refused at its binding: 30
```

- A1, A2 and B1 keep their values and their independent states. The write through A1's map reaches only A1.
- C's instance is refused where `try_c` binds it. The coverage of `c1` marks `lib_c_next` called; the candidate's
  `args` part has one input where the formed call supplies none; the admission answers NO. That is `implements`,
  taken by `try_c`'s handler.
- The owner's L1 carries the called mark (`(cast: (size_t) -2)`, 18 coverage cells, native and forced alike).
- The control, `control174-01.out` (`control174.sh`), builds the same witness with Verified174's frontend and
  runtime: its owner has no called mark. A1/A2/B1 print the same values, and then the call of C's method aborts:
  "lmx: invariant: a trampoline was called outside its method's signature" (exit 3).

The probes (`probes/`, not suite rows) were run by `probes/probe.sh`:
- with the bootstrap's frontend and runtime (`probes-175.out`);
- as the control, with Verified174's (`probes-174.out`).

| Probe | 175 | 174 |
| --- | --- | --- |
| `lib_t7.lm2`: a library with a callable merge (T7) | its L1 and C compile | l1trans: "unclosed parenthesized form" (`lib_t7-174.L1.log`) |
| `lib_s.lm2`: a library method that sends, linked with a sending owner | linked, 0 multiple definitions | 2 multiple definitions (`probe_owner-174.LD.log`) |
| `lib_r.lm2`: `int: count 40`, then `int: count 41` | the instance reads 41 | refused at the second declaration (`lib_r-174.L2.log`) |
| `lib_d.lm2`: an Array field; `d1\hist[1]: 5` written and read back through the admitted map | 5, at the root and walked | the admission refuses (exit 1) |
| `bad_provider.lm2`: `fn: lib_a_new (int: seed) LibA` with `--provider lib_a_new` | refused: "incompatible entry signature: a provided construction takes no input and gives its instance, a Structure" (`bad_provider-175.L2.log`) | translated without refusal |

The runner probes (`runner/`) are two malformed links rows: one whose second LIBS item has no `=` (`bad-libs.tsv`),
and one with an empty NAME (`empty-name.tsv`).
- The 175 tool reports `FAIL row 1 of the list: LIBS is no comma-separated list of PATH=NAME [SCHEMA]` for both.
- The 174 tool, given the witness sources, ends in a segmentation fault (exit 139), with no SCHEMA line and no
  summary (`bad-libs-174.out`).

Patch replay: GNU patch applies each delta to a copy of its Verified174 input, and `same` gives `SAME 1` four times
(`u0-same.out`).

Evidence: `evidence-175.list` names 94 files of the stage and its runs, and `evidence-175.sha256` holds their
SHA-256. The working binary's `manifest` wrote it, and `sha256sum -c` checks all 94 OK. The packet's copies of run
outputs have LF line ends; the manifest hashes the original bytes in `build2`.

## Not done (honest boundary)

- The runtime-created candidate (author, CODEX-AUTHOR-RUNTIME-ADMISSION-REVIEW-20261023T164724Z) stays OPEN.
  - It needs a Structure formal received at the callee: a value of another model at a called position is UNKNOWN
    today.
  - Non-positional maps of formals belong to that case as well.
- Q49 beyond the current ABI: omitted inputs formed from the candidate's defaults, dynamic inputs, conversions, and
  declared exits at run time.
- A transported callable field is still entered whole as a Structure, a structural check of its parts by their names.
  It is not a call check, but it can refuse a transport the norm admits.
- `suite_split_rows` with a links row is not run (the gate is LATER).
- The kernel gate, the gate, `bootstrap full`, the corpus replay, LIBRARY-ROWS-OLD-PROFILE and the mutants are LATER.
