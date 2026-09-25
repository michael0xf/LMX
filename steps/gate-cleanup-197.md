# GATE cleanup (-197)

FABLE-OPUS-GATE-CLEANUP-20260926-197 (Opus): ticket (8) of steps/next-phase-195.md §7, for the GATE's
cleanliness items (next_core_tasks.md :760: no header scanners or C-name dictionaries, no dead
helpers, no contradictory tests).  Branch opus/gate-cleanup-197, base main 1929199.  Four commits,
each checked per row.

## (a) 3e2cefb: the C-header scans go

Removed from l2trans.lm1 (-323 lines):
- `l2_list_has_simple_typedef` / `l2_include_has_simple_typedef`: read the unit's quoted C includes
  for a `typedef`;
- `l2_c_header_walk` / `l2_c_header_chain_has(_typedef)`: followed a predef header's plain C
  includes transitively;
- `l2_hdr_seen_has` / `_add`, with their seen-set.

That was a dictionary of C entities, which the raw-C door forbids (§7a, AUTHOR-C-RAW-DOOR-20260922-14):
a type only C knows is spelled `c.Type`.

Kept, by the same rule:
- `l2_predef_has_function` / `_type` / `_fnptr` and `l2_predef_file_define`: they read DECLARATIONS
  of `.h.lm1` headers, which is how a predef declares;
- `l2_foreign_intern`: types `c.Name` values;
- `l2_c_stmt_door`: the door's syntax.

Measured before removal, with a variant whose scans answered «not found»: no tracked `.lm2` (1017)
changes outcome, and neither does the mixa corpus, translated from its own directory.

## (b) 4b1ada5: `<string.h>` only where the program's own emission uses it

The preamble names the C headers of the program's OWN mechanics, which the translator emits.
- `<stdio.h>` and `<stdlib.h>` go into every program.
  - An X1 invariant is `fprintf(stderr)` then `abort`.
  - The launch hands the host root `stdout`/`stderr`.
  - A send's arena is `calloc`'d.
  - Measured: all 201 translating rows use both.
- `<string.h>` goes in only for:
  - the library profile's `memset`;
  - a send copying a text field (`memcpy`; `l2_send_copies_text` over the root's and the methods'
    send registries, both filled before the preamble is written).
- What the source uses through `c.*` comes with its own `include:` / `predef:`.

Rows:
- new unit_send_text: an exit letter with `stdout: "hi"`;
- unit_root_bare_callable_call pins the include line without `<string.h>`.

Mutants:
- never `<string.h>`: unit_send_text goes red;
- always `<string.h>` (main's translator): unit_root_bare_callable_call goes red.

On this toolchain `<windows.h>` (through lmx_clock) declares `memcpy` as well, so gcc cannot catch a
missing `<string.h>`; the pins do.

## (c) cfee7d1: harness kind `translates`

`translates` is for a translation SHAPE that is the point itself, not a gap.  The translator chain
succeeds, the L1 is read (Absent gone, Debt there), and nothing runs.  22 rows:
- the fnptr / raw-field / struct-local form-parity batches (20);
- unit_bad_sizeof (a deletion's absence);
- unit_define_actual (links against a prototype only).

`translates-with-debt` keeps only the two real gaps:
- unit_admit_letter_formal (D-60);
- unit_s1_merge_uncaught_entry (D-55).

## (d): dead helpers and dead state

The inventory found every function of l2trans.lm1 with no reference outside its definition and
prototype (by whole word, so a function passed as a value counts), plus globals that are only
declared and reset.

Removed functions, each with 0 references:
- `l2_ns_last_value`, `l2_ns_last_kind`: their callers, the flat merge's end checks, went with
  -193 T1;
- `l2_emit_own_pointer_temp_decl`;
- `l2_rw_int_lit`.

Removed state:
- `l2_need_string`, `l2_need_stdlib`, `l2_need_own`: declared and reset, never set since -155;
- `l2_ml_cap`: declared and reset only;
- `l2_merge_n`: counted, never read.

Kept: `l2_call_k`, the out-parameter a path check writes into.  After (d), the inventory finds 0
dead functions; nothing new cascaded.  The generated output is byte-identical to (b)'s over the
tracked corpus.
