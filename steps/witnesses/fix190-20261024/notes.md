# Slice 190: a local of a C type the declaration names is typed by it -- the address of a function-pointer local and of a by-value C record local (FNPTR-LOCAL-NO-ADDRESS)

Opus, 2026-10-24, sole writer/build. The slice follows Codex's route CODEX-OPUS-VALUE-OWNED-ROUTE-20261024-A (choice
(a), a small translator slice before the values module):
- «У typedef указателя на функцию есть собственная типизированная C-ячейка. @ local и @ formal должны давать адрес
  именно этой ячейки; @: c.LmxPointerCellRead — указатель на объект такого typedef, не ещё один графовый callable и не
  void**. Через обычные разыменование/индекс/target можно читать и писать эту ячейку. Сохраняй тип typedef и
  дополнительную глубину через общий путь адреса/lvalue/передачи, без исключения по именам read/write/value_owned и без
  промежуточного изменения walker ABI.»
- «Не меняй утверждённую роль головы: `read: v` у привязки с fnptr остаётся вызовом, как ROUTE181.»
- «Проверка минимальная: используй/дополни существующий короткий L2-свидетель fnptr из182 так, чтобы были реальные
  прочитанные значения после записи выходных callbacks, вызов обновлённого callback и адрес по-значению записи.»

Its review of Verified188 (CODEX-OPUS-REVIEW188-20261024-5117AA87) scoped the repair: «если by-value C
record/member-call/out-index уже работают, не переделывай их, исправь только измеренный разрыв role40 versus
value-type из объявления общей типизацией.» The first frontend of this slice did that for role 40, and its witness
then measured that the address of a by-value C record local had no type either (below); Codex
(CODEX-OPUS-RECORD-ADDRESS-ROUTE-20261024-A, on the question OPUS-CODEX-20261024-Q-RECORD-ADDRESS): «выбирай(1).»
«Единое правило: отдельно роль строки40/41, отдельно тип значения из её объявления через C-дверь; l2_ml_value_ty
возвращает общий foreign_byvalue, и @ добавляет указательный уровень того же объекта. Записывай исходный C-тип и
для41. Роли вызова40, by-value хранения41 и общий выбор callee не меняются».

The stage is `build2/opus_fix190`, from Verified189's stage. One input changes:

| Input | SHA-256 | Delta |
| --- | --- | --- |
| `src/l2src/l2trans.lm1` | `2DA8141D…` (Verified189: `F8AB4925…`) | `l2trans.lm1.patch` |

GNU patch gives the stage's bytes (`u0-same.out`: `SAME 1`). The recipe does not change.

## What changed

A machine local's row in the translator's table of locals has a code: a type code, or a role. Two codes are roles,
not types: 40, a function-pointer local, whose name is a call in every form (ROUTE181: `f: v` calls), and 41, a
by-value local of a C struct the predef'd header declares. Where a type was asked of such a local -- the binding's type
(`l2_colon_bound_ty`) and the selected root's type of a path (`l2_path_selected_binding_ft`) -- the answer was the role
code, which no type table knows: its address had no type (`l2_address_type(40)` and `(41)` are -1), and a typed place
refused it, «assignment value has unknown type».

- `l2_ml_value_ty(i)`: the value type of machine local i is its row's code, or for a row whose code is a role, the C
  type its declaration names through the C door, held by value: the code a formal of that type has
  (`l2_foreign_byvalue`). The declaration's head is kept for both roles (`l2_ml_add`, `l2_ml_cty`); it was kept for 40
  only, for the callee a call keeps (`l2_ccall_callee_decl`).
- The two type answers read `l2_ml_value_ty`. The role checks read the row's code itself and do not change: a
  function-pointer local's name stays a call in every form, its callee is still kept before its actuals, and a by-value
  struct local stays ordinary C storage of the activation.
- So `@ write` of `c.LmxPointerCellWrite: write c.write_one` is a pointer to `LmxPointerCellWrite`, the code of the
  formal `@: target c.LmxPointerCellWrite`, and `@ saved` of `c.LmxWalkValue: saved` a pointer to `LmxWalkValue`, the
  code of `@: v c.LmxWalkValue`. They are written and read through as any pointer is (`\p: f`, `p[0]: f`), and a call
  of the local reaches the value written. A declaration that names its type without the C door keeps the row's code,
  as before.

## Real runs

The tool is Verified189's `build2/opus_fix189/boot-quick-01/lmxtool.exe`. The runs are its commands and direct
invocations of the frontends, `bin/l1trans.exe` and the stage's gcc; no probe script was written, and the commands are
kept as text.

| Run | Inputs | Result |
| --- | --- | --- |
| `rebuild-frontend-01` (`fe-01`) | the translator with the type of role 40 only, on Verified189's `rt-01` | `SUITE 6 rows, 0 failures` in 67 s; its compile log has Verified189's warnings |
| `fnptr-190-01` | `fe-01` on the witness | refused at `record_set(@ saved, 42)` (184:16): «assignment value has unknown type», atom=@ |
| `probe-record-01` | `fe-01` and Verified189's frontend on `record.lm2` | both refuse `record_set(@ saved, 42)` at 21:16; the address kept first in a typed pointer local (`p: @ saved`) is accepted |
| `fnptr-190-m2` | `fe-01` on a copy of the witness whose two record addresses go through typed pointer locals | translates (a second run writes the same L1), lowers, compiles; `fnptr.exe` exits 0 (the gcc output was not kept) |
| `rebuild-frontend-02` (`fe-02`) | the translator with both roles (the stage's), on Verified189's `rt-01` | `SUITE 6 rows, 0 failures` in 55 s; the final frontend |
| `fnptr-190-02` | `fe-02` on the witness | translates, lowers and compiles; `fnptr.exe` exits 0 |
| `fnptr-control189` | Verified189's frontend on the witness | refused at its first `@ write` of a local, `retarget(@ write, cell)` (122:14): «assignment value has unknown type», atom=@ |
| `bootstrap-quick-01` (`boot-quick-01`) | Verified189's tool runs `bootstrap quick` on the stage | `BOOTSTRAP quick 0 failures` in 1 827 s; every module and header SHA-256 in the runtime's record (`trace/runtime-record.txt`) is Verified189's: the recipe translates the whole kernel into the same bytes; the smoke 6/0; G1 and G2 built and working |
| `checks-01` | the bootstrap's tool: `same`, `exe-same` | G1 and G2's L1 (`CFA6E697…`) and C (`18AE5F84…`) `SAME 1`, `EXE-SAME 1`; the runtime's `driver.c` (`AC8DFCAA…`), `driver.o` and `driver-observe.o` are Verified189's bytes; the tool's L1 and C differ from Verified189's G2 only in its own names' prefix (below) |

### The witness

`fnptr/fnptr.lm2` is the witness of slice 182 with seven checks more; `main`, the export, returns 0 when every check
holds, else the number of the first that fails. Checks 1-10 are slice 182's.
11. `local_retarget`: `retarget(@ write, cell)` writes `c.write_two` into the local's cell through the formal
    `@: target c.LmxPointerCellWrite`; `write(cell, 0)` then reaches write_two: 2, and the cell records 2.
12. `local_pass(@ got, cell)`: the retargeted local's value written through an out-parameter (`\out: write`) and passed
    to a formal of its type (`through(write, cell)`): 2.
13. `got(cell, 0)` in `main`: the value written through the out-parameter is called: 2.
14. `outputs_used`: `outputs(@ read, @ write)` writes `read[0]: c.read_back` and `\write: c.write_two`; the caller's
    locals then hold them: `read(cell)` gives the cell back and `write(cell, 0)` reaches write_two.
15. `null_checks(c.write_one)`: a local initialised to 0 (`c.LmxPointerCellRead: read 0`) compares equal to 0, a formal
    holding a function does not.
16. `record_local`: `record_set(@ saved, 42)` writes the by-value record through its address, `record_number(@ saved)`
    reads 42.
17. `member_call(@ pool, cell)`: a by-value `c.LmxPool` of `main` passed by its address; the callee writes
    `pool\pointer_write: c.write_two` and calls `pool\pointer_write(cell, 0)`: 2.

The C (`fnptr-190-02/fnptr.c`) passes `(LmxPointerCellWrite *)(& write)`, `(LmxWalkValue *)(& saved)` and
`(LmxPool *)(& pool)`, and writes the out-parameters as `(*p) = read_back` and `(*p) = write_two`. gcc's eight warnings
are unused formals and statement calls' discarded results.

### What else changed

Nothing the build makes but the frontend. The tool's L1 and C differ from Verified189's G2 (`F1504614…`, `AD67F8D0…`)
in one thing: the prefix of the names the frontend gives the unit's own functions, `l2_u41C19E12315695BB_` in
Verified189 and `l2_u98019E2CA58F02F1_` here; with the prefix masked, both files are byte-equal. The prefix is the
unit's hash of its source's path (`l2trans.lm1` lines 7208-7212), and the path names the stage
(`build2/opus_fix189/tools/lmxtool.lm2`, `build2/opus_fix190/tools/lmxtool.lm2`); the code's sums over the two paths
give these two prefixes. No module of the kernel changes: none of them takes the type of such a local where the two
answers are read.

Memory (`chain-memory.log`, the bootstrap): cc1 at most 1 589 MB, the free commit at least 2.7 GiB while cc1 ran. At
10:08 the free commit fell from 3.3 GiB to 0.63 GiB for about 30 s with no cc1 running, during the bootstrap's runtime
step, and rose to 7 GiB at 10:08:35: another process of the machine held memory then. Nothing else of this slice ran
beside the bootstrap; the frontends were built before it, one at a time.

## Evidence

`evidence-190.list` names 72 files: the translator and its Verified189 parent, the delta and its replay, the two
frontends' builds, the witness and its runs, the record probe and the measurement copy, the bootstrap, the checks
and the Verified189 files they compare with. `evidence-190.sha256` holds their SHA-256, written by the tool's
`manifest` (`manifest/manifest-190.out`: `MANIFEST 72 files, 0 failed`; `sha256sum -c` checks all 72 OK). The
packet's copies have LF line ends and no trailing blanks; the manifest hashes the original bytes in `build2`.

## Not run

The kernel gate, the gate, `bootstrap full`, the corpus replays, a mutant (the author: «Не увлекайтесь тестами»;
Codex: «без полных gates/корпуса»).

## OPEN

The L3+L2 self-build (plan section 8): 24 more kernel modules of the runtime's translation unit, the driver and both
translators are L1. Next: the generated C names with the source name after their index (the author's instruction,
CODEX-AUTHOR-C-IDENTIFIER-SUFFIX-20261024-A), then the values module (`lmx_value_owned`).
