# Slice 191: the values module in L2 (S8.3, values and the graph); a call through a function-pointer binding has the C ABI's result

Opus, 2026-10-24, sole writer/build. The order (Codex, CODEX-OPUS-ROUTE185-20261024T085140Z): above the storage layer,
values and the graph. Codex moved the readable C names after this slice
(CODEX-OPUS-REVIEW190-AND-C-NAMES-ORDER-20261024-A: «Сначала перенос lmx_value_owned, затем читаемые C-имена
отдельным следующим небольшим срезом. Работающая самосборка — приоритет автора.») and found no defect in Verified190
(the same message).

The stage is `build2/opus_fix191`, from Verified190's stage. Its inputs:

| Input | SHA-256 | Delta |
| --- | --- | --- |
| `src/l2src/lmx_value_owned.lm2` (new) | `FC649F57…` | `lmx_value_owned.lm2.patch` |
| `src/l2src/l2trans.lm1` | `D70C197B…` (Verified190: `2DA8141D…`) | `l2trans.lm1.patch` |
| `tools/l2/build.lm2` (the recipe, in the repository) | `5E53F5FA…` | the commit |

GNU patch gives the stage's bytes (`u0-same.out`: `SAME 1` twice). The generated files replace the hand-written ones:

| File | hand-written (Verified190) | generated |
| --- | --- | --- |
| `lmx_value_owned.lm1` | `D3CB5EF3…` | `F3100A18…` |
| `lmx_value_owned.h.lm1` | `2B6387F5…` | `8C891429…` |

## What changed

- `src/l2src/lmx_value_owned.lm2`: the 54 functions of the hand-written module, in the same order; 53 are exports, and
  `lmx_value_allocate_owned`, which nothing calls and no header declares, is the module's own. The bindings named
  `profile` (a word of the language) are `value_profile`; in `lmx_field_place_new` the profile of the field's cell is
  kept in a typed local (`place_profile`) before the call that takes it. The arena's, pools', graph's, interned
  table's and C library's acts are reached through the C door; their pointer results and the C members read at a use
  are cast to their C types. A by-value `VoidArray` member is written through its address (`va: @ value\array`, then
  `va\size`, `va\data`), as in slice 188. A pointer difference is taken between the two addresses as `size_t`
  (`lmx_pointer_cell_context`), as the index's module does.
- The forms slice 190 typed: `lmx_value_cell_store` passes `@ read` (its function-pointer local), `@ write` (its
  formal) and `@ saved` (its by-value `LmxWalkValue`) to the module's own typed formals; `lmx_value_cell_access` writes
  the callbacks through its out-parameters by index (`read[0]: …`). The snapshot copy before the single physical write
  and the two copies after it keep their order.
- Translated with `--header`, after the temporary-frame store. Its header holds the predefs of headers and the
  prototypes of the 53 exports; the module keeps its predefs of code modules (`lmx_chars.lm1`, `libc_abi.lm1`), as the
  translator splits them (`l2_pd_is_header`). The 52 prototypes of the hand-written header keep their names, return
  and parameter types; the 53rd, `lmx_value_context_copy`, is the same declaration `lmx_value.h.lm1` holds, which the
  walker's and the call's headers read.
- The translator (FNPTR-BINDING-CALL-RESULT-UNTYPED): the store's `status: write(cell, raw)` -- a call through a formal
  of a C function-pointer type, assigned to a typed local -- was refused «assignment value has unknown type». The value
  type of a call (`l2_colon_simple_ty`) gave the C ABI's opaque result (-12) only to a call through a function-pointer
  local; it now gives it to a call through a C function-pointer binding as well (`l2_head_cfn_type`: a formal, a field,
  an input), slice 182's rule («the call's result is a C value (opaque)»): the receiving C type checks it.
- `bld_kernel_l2` names the module's 53 exports and translates it last.

## Real runs

The tool is Verified190's `build2/opus_fix190/boot-quick-01/lmxtool.exe`. The runs are its commands and direct
invocations of the frontends, `bin/l1trans.exe` and the stage's gcc; no probe script was written, and the commands are
kept as text.

| Run | Inputs | Result |
| --- | --- | --- |
| `rebuild-frontend-01` (`fe-01`) | the translator with the call's result, on Verified190's runtime | `SUITE 6 rows, 0 failures` in 56 s |
| `gen-191-01` | `fe-01` with the recipe's command; l1trans for the C header | the module, its header and C header, exit 0 |
| `gen-control190` | Verified190's frontend on the module | refused at `status: write(cell, raw)` (373:5): «assignment value has unknown type», frame=status |
| `fnptr-191-01` | `fe-01` on slice 190's witness with check 18 | translates, lowers and compiles; `fnptr.exe` exits 0 |
| `fnptr-control190` | Verified190's frontend on it | refused at check 18's `status: write(cell, 0)` (199:5), the same refusal |
| `rebuild-runtime-01` (`rt-01`) | Verified190's tool with `fe-01` | `SUITE 6 rows, 0 failures` in 703 s; the C differs from Verified190's only in the module (lines 13673-14446; the lines before and after are byte-equal) |
| `rebuild-tool-01` (`tool-01`, the seed G0) | Verified190's tool; the stage's tools by `fe-01`, linked with `rt-01` | built in 595 s; its smoke 6/0 |
| `bootstrap-quick-01` (`boot-quick-01`) | G0 runs `bootstrap quick` on the stage | `BOOTSTRAP quick 0 failures` in 1 823 s; the runtime's record shows the recipe translating the module (`trace/runtime-record.txt` lines 153-164) into `gen-191-01`'s bytes, and every other module and header is Verified190's; the smoke 6/0; G1 and G2 built and working |
| `checks-01` | the bootstrap's tool: `same`, `exe-same` | G0, G1 and G2's L1 (`74068FBD…`) and C (`9BF9FBF1…`) `SAME 1`; G1 and G2 `EXE-SAME 1`; the bootstrap's `driver.c` (`955C7683…`), `driver.o` and `driver-observe.o` are `rt-01`'s bytes; the module, its header and C header are `gen-191-01`'s |

Check 18 of the witness (`fnptr/fnptr.lm2`): `assign_through(c.write_two, cell)` assigns `write(cell, 0)`, a call
through its formal `c.LmxPointerCellWrite: write`, to `int: status` and returns it: 2, and the cell records 2.

Memory (`chain-memory.log`): cc1 at most 1 572 MB, the free commit at least 2.33 GiB while cc1 ran and 2.01 GiB at its
lowest. Nothing else ran beside the chain.

## Evidence

`evidence-191.list` names 92 files; `evidence-191.sha256` holds their SHA-256, written by the tool's `manifest`
(`manifest/manifest-191.out`: `MANIFEST 92 files, 0 failed`; `sha256sum -c` checks all 92 OK). The packet's copies
have LF line ends and no trailing blanks; the manifest hashes the original bytes in `build2`.

## Not run

The kernel gate, the gate, `bootstrap full`, the corpus replays, a mutant (the author: «Не увлекайтесь тестами»).

## OPEN

The L3+L2 self-build (plan section 8): 23 more kernel modules of the runtime's translation unit, the driver and both
translators are L1. Next: the generated C names with the source name after their index
(CODEX-AUTHOR-C-IDENTIFIER-SUFFIX-20261024-A, CODEX-OPUS-C-NAMES-PLAN-20261024-A), then the graph's modules.
