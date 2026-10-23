# Slice 174: executable L2 library instances (S8.1)

Opus, 2026-10-23, sole writer/build. §8 step 1 of `steps/native-selfbuild-20260930.md`: make separately compiled L2
libraries executable. This follows the routes Codex fixed:
- CODEX-OPUS-20261023-SLICE173: the S8.1 route is owner-supplied construction.
- CODEX-OPUS-20261023-S81-OWNER: the provider binding is explicit, in the owner's build configuration.
- CODEX-OPUS-20261023-S81-ADMIT: admission uses the general analytical correspondence.

The author's two review directives are taken up below: CODEX-AUTHOR-S81-INDEPENDENT-REVIEW-20261023T160927Z and
CODEX-AUTHOR-RUNTIME-ADMISSION-REVIEW-20261023T164724Z.

Before this slice, a library exported one wrapper per method. Each wrapper opened the library on its first call
(`l2_library_open`) and failed by construction (`l2_library_unit: 0`). The library kept a singleton root, Message, unit
and opened flag. A library unit executed no statement, so it could hold no state.

The stage is `build2/opus_lib174`, a copy of Verified173's stage `build2/opus_range173`.
- Two sources change. Each has a -U0 delta here, and GNU patch applied to the Verified173 input gives the stage's bytes
  (`u0-same.out`).
- The runner (`tools/l2`) and the lists (`tests/l2`) change in the repository itself. The witness sources are
  `tests/l2/lib/`.

| Input | SHA-256 | Verified173 | Delta |
| --- | --- | --- | --- |
| `src/l2src/l2trans.lm1` | `C109747147D80D45FA1249E6B948F35A8AF2E68BF2C7FEFB07C305F7C994575E` | `ECD7146A…` | `l2trans.lm1.patch` |
| `src/l2src/lmx_implements.lm1` | `03A6F714FD94291D7E4B23FE50EA7F2E318B1246A110517AD70DDE86B25CC8CB` | `007CAC18…` | `lmx_implements.lm1.patch` |

## What changed

### Library side (`l2trans --library --construct NAME`)

- **A library unit has its entry E** (`l2_make_entry`). It is translated by the program pipeline (`l2_parse_unit`), not
  the old reduced `l2_parse_library`, which is gone.
  - `l2_library_checks` keeps the library's own refusals: reserved symbols, and hidden inputs or declared `throws:`
    names of a method. Since the status channel of the uniform ABI carries the implicit exits for every call, a method
    with implicit exits only is no longer refused.
  - It refuses where it stands any root statement that declares no field of the unit: "a library's construction runs
    only the declarations of its unit: this root statement is not built yet". This is an implementation state, not a
    norm.
  - A qualified branch is refused as not built yet: its roots live in one per-module table.
  - The branches that stood for "a library has no E" now take the program path: local named-Structure procedures,
    source layout, root fields, the walked root's typed reference, the shell anchor, and the callable-merge
    constructors.
- **The construction export NAME** has the uniform adapter ABI (`LmxPrimitiveEntry`, `lmx_primitive.h.lm1`).
  - It builds one unit in the arena of its call (`lmx_call_arena`): the same construction code as a program's build,
    with no process-wide bind of walker roles or qualified roots.
  - It calls the unit's E once through the unit's native word, as R0's turn calls a program's entry
    (`lmx_call_prim(arena, unit, unit, ...)`), so the declarations initialize this instance's fields.
  - It returns the unit in `out`. E's status and thrown record pass through, as a trampoline's do.
  - It opens or turns no root, and no Message or Thread learns of the unit.
- **No module state.**
  - A library has no `l2_program_arena` or `l2_program_unit` global, no `l2_program_graph()`, and no qualified-root
    accessors.
  - It has no `l2_library_open`, no wrappers, and no `l2_library_root`, `_message`, `_unit` or `_opened`.
  - The C compiler confirms that no generated code reads such state: the library C compiles without the globals.
  - Its one module-level object is the immutable `l2_layout_tokens` table.
  - The unused locals `l2_current` and `l2_message` are gone from every build function, programs' too.

### Owner side (`l2trans --provider NAME`, repeatable)

- A bodyless method declared at the unit's root whose name is NAME (`l2_m_provider`) takes the export NAME as its
  occurrence's native word, with a prototype of the uniform ABI.
  - Every call of it reaches the provider's construction through ordinary dispatch, native or walked.
  - Nothing else about it changes: an unbound bodyless method stays a descriptor and is refused as "not callable".
  - A provider that no such method takes is refused (`l2_providers_check`), and so is a provider given twice.
- `a1\m()`, a call whose head path follows a value (`l2_head_follows_value`: a reference binding, a formal, a computed
  Structure), reaches the admitted candidate's own callable. The model's method, with or without a body, is that
  call's contract. The emitter already dispatched such a call on the candidate's occurrence through the implements
  slot (`lmx_implements_slot`, then `lmx_call_prim_values` on the selected occurrence's native word). The check alone
  refused a bodyless contract.

### The general analytical admission (kernel, `lmx_implements.lm1`)

`lmx_implements_resolved_view` gains a last resort for the case where no evidence of any kind relates the value to
the requirement. Evidence here means a template, a stored proof, pending rows, identity or a composition.
- In that case `lmx_implements_named_view` finds each field of the requirement in the value by the name of its place
  in the arena's external source-name table (`lmx_implements_place_name`): the slot's name, or a primitive cell's own
  name.
  - The ordinal half takes the same-numbered occurrence of the name, and the last half takes its last occurrence.
  - An unnamed place matches the same-numbered unnamed place.
  - A name the value lacks is a hole.
- These are coordinates only. The existing analytical walk checks the used fields' contracts against them, and the
  record it publishes is the ordinary one, so no access looks a name up again.
- A failed or conflicting proof is never replaced by it.

The translator now names the header parts `args` and `return` of every occurrence, not only of four-part ones. A
descriptor's parts are thereby found among an implementation's.

## The witness (A1/A2/B1)

`tests/l2/lib/lib_a.lm2` (`int: count 40`, `lib_a_next`), `lib_b.lm2` (`int: count 41`, `lib_b_next`), and
`lib_owner.lm2`. The owner declares the models `LibA` and `LibB` and the descriptors `fn: lib_a_new () LibA` and
`fn: lib_b_new () LibB`. Its `run()` then does the following:
- constructs `a1`, `a2` (A) and `b1` (B);
- calls them interleaved, and reads each count;
- writes `a1\count: 100` through A1's admitted map;
- calls A1 and A2 again.

The smoke row is `links lib/lib_owner.lm2 7 nf lib/lib_a.lm2=lib_a_new,lib/lib_b.lm2=lib_b_new`. The runner builds
each library with `--library --construct NAME` as an object, builds the owner natively and with `--walk-methods`, with
`--provider` for each library, links them, and runs each at the root and walked.

## Results

The quick bootstrap of the stage, `boot-quick-01`, ran 14:07–14:42 (`bootstrap-quick-01.out`, `.command`). G0 was the 174
tool built first by `rebuild tool` (`tool-01`), because 173's runner has no `links` rows. It reported `BOOTSTRAP quick 0
failures`:
- the headers were regenerated (`HEADERS 51 regenerated`), and the runtime and the frontend were built;
- smoke gave `SUITE 6 rows, 0 failures`;
- G1 and G2 each hash a file with the same digest of the tool's L1 (`64db96b8…`);
- the working binary is G2.

| Built by `boot-quick-01` | SHA-256 |
| --- | --- |
| `frontend/l2trans.exe` | `F95F99B1B87EAD86D49B2296C9C578CFA80466313278C086BD4A13B5448E8F5C` |
| `runtime/driver.o` | `E84EDDCFA867B17972D267AE73EB21E8BBCD84B5DD62CDF7BEE43251F29B0841` |
| `lmxtool.exe` (G2) | `55AA24BABBBA9FA74C693528060721A2D51A10FAEF29E1FB73CE000C069B6BF4` |

The witness, as the bootstrap's smoke ran it (`witness-native-root0.log` … `witness-forced-root1.log`). These are the
owner built natively and with `--walk-methods`, each run at the root and walked; all four print the same values:

```
S81 calls A1=41 A2=41 B1=42 A1=42 B1=43 A2=42
S81 counts A1=42 A2=42 B1=43
S81 after A1 count 100: A1=101 A2=43
```

- Independent states: two instances of A and one of B advance separately under interleaved calls. The reads after the
  writes see each instance's own cell.
- The owner wrote `a1\count: 100` through A1's admitted map. A1's own method, which reads its cell by its library's
  child index, then gives 101, and A2 gives 43. The map's physical place is therefore the instance's own cell.
- `a1 = a2` is false (exit 18 otherwise).
- One owner close: the run ends by the owner's exit Message, with a clean close (`l2_eternal_driver: 13 checks, 0 roots`
  at the root, 17 walked).

The control, `control173-01` (`control173-root0.out`), takes the same witness objects of the bootstrap's smoke, linked
with Verified173's runtime, which has no analytical correspondence. R0 is stopped by an uncaught throw at the first
admission (`exit 1, expected 7`), before any value is printed. The instances' admission therefore comes from the
general branch, and from nothing library-specific.

No library state and no root. The generated library L1 (`lib_a.lm1`, `lib_b.lm1` of the smoke) calls no `lmx_root_*`
or `lmx_thread_*` and binds nothing process-wide. Its one module-level object is the `l2_layout_tokens` table. Its
only Message contact is the ordinary stop poll `lmx_msg_poll_escape()` of the calling activation. The C compiler
accepts it without the module arena and unit globals.

The actual callable: the owner's call `a1\lib_a_next()` reads `a1`, then takes the slot of `lib_a_next` from the
record (`lmx_implements_slot`), then the instance's occurrence at that slot. It calls that occurrence through its own
native word, the library's trampoline (`lmx_call_prim_values`). The construction is the native word of the owner's
`lib_a_new` occurrence (`l2_entry_leaf\native: (cast: (LmxEntry) lib_a_new)`).

Patch replay: GNU patch applies each delta to a copy of its Verified173 input, and the working binary's `same` gives
`SAME 1` twice (`u0-same.out`).

A measured non-witness, `runs/rtc-01` (`rtc-probe.lm2`, `rtc-probe-173.out`, `rtc-probe-174.out`): a Structure made by
`merge` in the same translation and passed opaquely (`@: q void`) to `Model` formals. Its fields are permuted (`pad, y,
x` against `x, y`). It reads `x=1`, writes `y=42`, and the written value reads back through `p`. It does so under the
173 kernel as well: the translator's catalog holds the `Point` -> `Model` template. So it does not witness the general
branch, and it is not a row.

Evidence: `evidence-174.list` names 53 files of the stage and its runs: the two inputs, the stage's copies of the
runner and the witness, the G0 tool, the bootstrap's records and binaries, the witness's L1, objects, executables and
logs, and the control. `evidence-174.sha256` holds their SHA-256, written by the working binary's `manifest` and
checked by `sha256sum -c` (53 OK).

## Internal review

After the bootstrap, a review in four areas (runner, owner, library, kernel) read the stage's sources, and a second
agent checked each finding against the code. The findings were traced in the code; none was run. These are on paths
the witness does not use, and `steps/defects.md` records them OPEN for slice 175:
- NAMED-VIEW-RELAXES-CALLABLE-SIGNATURE: the named view also applies to a method field's `args` and `return` parts.
  An implementation whose formals (count, order) or result differ from the model's descriptor is admitted, and the
  positional call then aborts in the trampoline or swaps the arguments.
- PROVIDED-CONSTRUCTION-CONTRACT-UNCHECKED: a provider binds any bodyless root method of its name, whatever its
  formals and result. A bound descriptor is not on the status channel.
- LIBRARY-FIELD-PLACES-UNNAMED: a library unit's Array and Structure fields are named on their values, not on their
  slots, so the named view finds no place for them.
- LIBRARY-EXPORT-HEADER-SPLIT: the export's header is written before the helper emitters, whose definitions land
  inside its parameter list.
- LIBRARY-HELPER-NAMES-UNHASHED: fixed helper names (`l2_send_fail`, `l2_msend<k>`, …) collide at link.
- LIBRARY-ROOT-STATEMENT-TEST: a root `receiveMessage:` passes as a declaration, and a repeated root declaration is
  refused. The verifier rejected the first point, since `receiveMessage:` declares the name it binds (K03 S5). It is
  kept because Codex's S8.1 route says the construction runs no root Message code.
- RUNNER-LINKS-ROW-CHECKS: LIBS items are not checked one by one, `argv_words` cuts at 60 words, same-stem libraries
  share object names, and `suite_split_rows` leaves LIBS relative.

Not confirmed:
- Bare `--library` replay rows now fail. That is the new command-line contract, recorded as LIBRARY-ROWS-OLD-PROFILE.
- A construction failure returns status 1, read as `merge`. It is an allocation failure in the caller's arena,
  reported as a failed native merge already is.
- The export name check accepts C keywords. The build then fails at a named step, so this is hardening, not a wrong
  program.

The route for the signature fixes is the author's, CODEX-AUTHOR-COMMON-SIGNATURE-ADMISSION-20261023T181842Z: through
the common admission mechanism, without special rules for libraries.

## Not done (honest boundary)

- **A runtime-created candidate** (the author, CODEX-AUTHOR-RUNTIME-ADMISSION-REVIEW-20261023T164724Z) stays OPEN.
  - The general branch is not library-specific: any candidate with no prepared correspondence reaches it.
  - But this slice shows it only on library instances, whose layout the owner's translation never saw.
  - The structure the directive asks for, created at runtime with a permuted field order and admitted where no
    translator prepared its correspondence, needs its own small case.
  - Nearest route: a library method with a Structure formal receives a Structure the owner built. The library's
    method reads it through its own model's record, which today only the caller registers for the caller's model, so
    the callee-side admission is the missing piece.
- **Admission route change.** Admissions that returned UNKNOWN for want of a template now go through the named
  correspondence. Their corpus replay and the gate are LATER.
- **Old library rows.** The gate's `library-links` rows (`unit_lib_pair_a/b`, `unit_lib_callable_formal`), the
  replay of library rows, and `unit_lib_stmt_refused` / `unit_lib_part_root_refused` pin the old profile: wrappers,
  no `--construct`, and "a library unit executes no statements". They change with the gate (LATER).
- **Not covered yet.**
  - Walked library bodies: an instance's walker roles are its own, the walker's bound roles are the owner's.
  - Library methods with hidden inputs or declared throws, library parts, and qualified branches: all refused.
  - The free sibling and qualified-reference projection for copied callables.
  - The mutants of the acceptance paragraph.
  - The kernel gate, `bootstrap full`, corpus replay, and every LATER item of Verified173.
