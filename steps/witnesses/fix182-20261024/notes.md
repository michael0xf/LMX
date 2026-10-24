# Slice 182: a call through a C function pointer the method holds; C calls keep their actuals' order; the arena's block list in L2 (S8.3, third step)

Opus, 2026-10-24, sole writer/build. The slice follows Codex's consultation CODEX-OPUS-ROUTE181-20261024T040603Z on
the two questions of OPUS-CODEX-20261024-VERIFIED181, and its review CODEX-OPUS-REVIEW181-20261024T0410Z:
- item 1: «Общий недостающий случай нужно закрыть в существующем typed fold ... Для ЯВНОГО машинного object pointer и
  явно C-операнда допустимо то же откладывание проверки C-типа, которое общий numeric fold уже делает; точный pointer
  result сохраняется. Не превращать произвольное неизвестное L2 имя в число/offset, не ослаблять запрет graph
  Structure/Array arithmetic и void*/fnptr offsets. p+n, p-n и n+p по обычным правилам C; n-p не pointer offset.»
  «Буквальный c.sizeof уже выбран как оператор общим primary role5: у его результата известный машинный тип size_t.
  Предпочтительно не терять этот известный тип в общем типизированном результате.»
- item 2: «Голова выбирается обычным binding/resolution: формал/own/field с известным foreign C-type -> соответствующая
  C-call роль. C проверяет, является ли этот C-тип вызываемым и годятся ли ABI actuals; скаляр L2, named Structure или
  неизвестная голова не становятся C-call при неудаче поиска метода.» «Выбранное значение callee зафиксировать ДО
  эффектов actuals; actuals вычислить ровно один раз в лексическом порядке, сохранить значения до C-вызова. Не повторить
  R178-1: C-door helper сейчас не всегда сохраняет size_t actuals, поэтому само направление в него без общей правки ещё
  не доказывает порядок! Если actual или result действительно opaque без известного C-spelling/принимающего контракта —
  не угадывать int/тип, честно ограничить только недостающий случай. Использовать существующий путь C-door/ABI, не новый
  исполнитель/подсистему.»
- «Продолжай к arena_blocks и arena малыми шагами.»

Verified182 is a bounded slice: the frontend and the runtime were built by the runner, its smoke ran, two targeted
corpus replays ran, a witness and three mutants ran. The tool was NOT compiled with the new recipe and the quick
bootstrap was NOT run, for memory. Verified182 does not close S8.3 or §8 and is not the L3+L2 self-build.

The stage is `build2/opus_fix182`, a copy of Verified181's stage sources (`build2/opus_fix181`).
- Two inputs change. Each has a -U0 delta here, and GNU patch applied to the Verified181 input gives the stage's bytes
  (`u0-same.out`: `SAME 1` twice; the commands in `u0-same.command`).
- `src/l2src/lmx_arena_blocks.lm1` is now the build's product: the frontend writes it from `lmx_arena_blocks.lm2`
  (`gen-kernel-01`, with `fe-05`), and the final frontend `fe-06` regenerates it byte for byte (`regen-02`). The
  hand-written module is gone; its header `lmx_arena_blocks.h.lm1` does not change.
- The generated modules of the pools, the index and the list change: their C calls keep an earlier actual before a later
  actual's call (below). `gen-kernel-01` wrote them in the stage, `regen-02` regenerates all six generated files byte for
  byte; the two generated headers do not change.
- The recipe (`tools/l2/build.lm2`, copied into the stage's `tools`) changes in the repository: `bld_kernel_l2` builds
  the block list.

| Input | SHA-256 | Delta |
| --- | --- | --- |
| `src/l2src/l2trans.lm1` | `B660E1680E31A985CBF93AEE35048805F0295338CCC6C3DF7A3A903DC0331CF8` | `l2trans.lm1.patch` |
| `src/l2src/lmx_arena_blocks.lm2` | `D31963707DAA2788C18265BF3A7EA4E44D313F079D96C36A531E1A920A5EEEE0` | `lmx_arena_blocks.lm2.patch` (new) |

| Generated file | Verified182 | Verified181 |
| --- | --- | --- |
| `lmx_arena_blocks.lm1` | `0CF957D83DAFF1C1752259CFDC87E4AB0CD404A42853FC32D29297953A17416B` | hand-written `755710C89AD5767D65FEC1B7ADB9487D66AE0E6664671831AA4851048BBA7442` |
| `lmx_pool.lm1` | `E0CA78C8F12D6513D55C643A166B34699C19238C27FA19270CF49C0AA1E3DC57` | `B701714B0415E1AE074FBCC6A2BF1481740A86A75FF142FC46D33640743A3B80` |
| `lmx_range.lm1` | `0E0EC0C7ADA3C79AFA55DD8DB21E3D6F755EB5C035167002DC9B9AB7FBB72A58` | `B35D71C44F5C701ABFB76C45F70EB5C32665C27CD226F9DAADE898E0E5FA8BD5` |
| `lmx_list_owned.lm1` | `901EB1BC22EF8BB4ED18A860202F91F61A24251576253CC93C4F54B59B8EE8E7` | `A0D2CADCCE4A276E15EB04950BB5C4CEFE540D52FFE6E8AA89944A46127F69E2` |

`lmx_pool.h.lm1` (`A2AB022D…`) and `lmx_list_owned.h.lm1` (`91E02D1A…`) are Verified181's.

## What changed

### A call through a C function pointer the method holds (ROUTE181 item 2)

- The selection is the binding's: `l2_head_cfn_type` reads the binding a one-name head names at its site
  (`l2_colon_bound_ty`: a formal, a field, an input) and answers its type when that type is a C type held by value that a
  predef'd header declares with `fnptr:` (`l2_predef_has_fnptr`, the C ABI's answer). The resolution keeps its order: a
  method, a callable formal, a held callable and a function-pointer local are taken first; an L2 scalar, a named
  Structure or an unknown head never becomes a C call.
- Such a head is the C door's role: `l2_external_head` (role 3 of `l2_node_role`, which CHECK, typing, native emission and
  the retained producer read), `l2_frame_is_call`, and a call in every form, never an assignment (`l2_head_is_call`,
  `l2_is_asgn`), as a function-pointer local's later `f: v` is its call; a statement emits the call (`l2_eval_discard`).
  C judges whether the type is callable and whether the actuals fit; the call's result is a C value (opaque), as every
  C door result is.
- A function-pointer local's statement call is that same C call: CHECK by `l2_check_primary`, emission by
  `l2_emit_ccall`. Its own branch checked the actuals as one expression (FNPTR-LOCAL-STATEMENT-ACTUALS: the block list's
  `disposer(block\base, block\n)` was refused «malformed value expression», `gen-blocks-01`), and its emitter
  `l2_emit_fnptr_call`, which wrote the actuals in place, is removed.

### C calls keep their actuals in their written order (R178-1 for the C door)

`l2_emit_ccall_value` writes every C call: the C door, a predef'd prototype, a function-pointer local or binding, a C
member.
- Up to the last actual that may run a call (`l2_ccall_last_call`, `l2_node_runs_call`: a Frame that calls or holds a
  call, outside sizeof; an index in an operand's text with a group or a call), each actual is kept in a C local of its
  own type before the next one is prepared; int and char actuals are kept in an int as before.
- A callee the method holds -- a C function-pointer binding, or a function-pointer local, whose declaration names its
  type (`l2_ml_cty`) -- is kept in a C local of its C type before any actual runs (`l2_ccall_callee_decl`,
  `l2_emit_head_binding`).
- An actual nothing can change stays in place: a literal, a sizeof, a C door word, a define.
- OPEN, refused where it stands: a value with no C type to keep it in -- a C door value (a C member read, a nested C
  call's result) -- before an actual that runs a call; a C member callee (`pool\pointer_write(...)`) when an actual runs
  a call (C members have no L2 type, C-DOOR-MEMBER-ACTUAL-UNTYPED).

Before, only int and char actuals were kept: a size_t, a pointer or a C value was spelled in place and read by the C
call after a later actual's call had run (C-DOOR-ACTUALS-UNORDERED). The kernel's generated modules change accordingly:
in the pools (`lmx_range_drop`, `lmx_range_interval_pool`), the index (`lmx_arena_index_set_len`) and the list
(`lmx_arena_pointer_cells_profiled`, `lmx_arena_take_n_profiled`), the arena pointer or a computed pointer is kept before
a later actual's C call. The later calls do not change those values; the rule is general. `regen-01` (`fe-04`) showed
that these three modules change; `fe-05` keeps a sizeof in place, as a literal, and wrote them (`gen-kernel-01`).

### An explicitly opaque C operand is a pointer offset; C's sizeof has size_t (ROUTE181 item 1)

- The offset branch of `l2_value_expr_type` takes an explicitly opaque C operand (exact type -12) as the offset, its C
  type checked by C as the numeric fold defers it: p + n, p - n and n + p; n - p is no offset. An unknown L2 name, a graph
  Structure or Array reference, `void *` and a function pointer still take no offset.
- `l2_primary_value_type`: `c.sizeof` (role 5) has size_t, as `sizeof` and `length` do (C99 6.5.3.4p4); every other
  C door value stays opaque. MACHINE-OFFSET-OPAQUE-OPERAND is fixed; the pools keep their `chunk + 1` and `pool + 1`,
  the same addresses.

### The arena's block list is a machine module of L2 (S8.3, third step)

`src/l2src/lmx_arena_blocks.lm2` is the maintained source of the arena's list of owned blocks: the six functions of the
hand-written `lmx_arena_blocks.lm1` in their order, all exports (`tail`, `push`, `remove`, `can_move`, `move_all`,
`dispose_all`). Translated without a header, it declares its functions itself, as the index does: the block record
`LmxArenaBlock`, its disposer type and the prototypes the kernel calls stay in `lmx_arena_blocks.h.lm1` (source closure
OPEN).
- Spellings that differ from the L1: the formal and the local named `node` (a word of the language) are `block`; the
  header's constants and `free` are reached through the C door; `dispose_all` declares its disposer local with its value
  inside the loop, `c.LmxArenaBlockDisposer: disposer block\dispose` (a later `disposer: v` would be its call), and calls
  it `disposer(block\base, block\n)`.
- A function-pointer local or a C struct local declared through the C door was written with `c.` in the L1, which
  l1trans refuses («unknown type name»; the corpus writes such locals without the door): the type is now written by its
  C name (`l2_write_c_name`), as the C door's interned types are (FOREIGN-LOCAL-C-DOOR-SPELLING).

## Real runs

The tool is Verified176's `build2/opus_fix176/tool-01/lmxtool-tool.exe`. The runs are its commands and direct
invocations of the frontend, `bin/l1trans.exe` and the stage's gcc; no probe script was written, and the commands are
kept as text.

| Run | Inputs | Result |
| --- | --- | --- |
| `rebuild-frontend-01` (`fe-01`) | the translator, Verified181's `rt-01` | gcc refused two call arguments that read a member with a dot (an L1 call argument splits at a dot); parenthesized |
| `fe-02` | the same, on Verified181's `rt-01` | `SUITE 6 rows, 0 failures` |
| `gen-blocks-01` | `fe-02` | refused at `disposer(block\base, block\n)`: «malformed value expression» (FNPTR-LOCAL-STATEMENT-ACTUALS) |
| `fe-03` | the local's statement call as the C call | `SUITE 6 rows, 0 failures`; `gen-blocks-02` writes the block list, exit 0 |
| `rebuild-runtime-01` (`rt-01`) | the generated block list, the other modules Verified181's; smoke with `fe-03` | `SUITE 6 rows, 0 failures` |
| `fe-04` | on `rt-01` | `SUITE 6 rows, 0 failures`; `regen-01`: the pools', index's and list's modules change |
| `fe-05` | a sizeof stays in place; on `rt-01` | `SUITE 6 rows, 0 failures`; `gen-kernel-01` writes the four modules in the stage |
| `rebuild-runtime-02` (`rt-02`) | the four generated modules, smoke with `fe-05` | `SUITE 6 rows, 0 failures` |
| `rebuild-frontend-06` (`fe-06`) | on `rt-02` | `SUITE 6 rows, 0 failures`; the final frontend |
| `regen-02` | `fe-06` over copies of the stage's six generated files | `SAME 1` six times (`regen-02.out`); no `.tmp` or `.bak` left |

Final builds: `fe-06/l2trans.exe` `59576AB8…` (its source is the stage's `l2trans.lm1`), `rt-02/driver.o` `4325956D…`
and `rt-02/driver-observe.o` `50175F7A…`. `rt-02`'s compile log has Verified181's warnings and one more of the same kind:
the discarded result of `lmx_arena_blocks_tail(\src, @ src_tail)`, a statement of `lmx_arena_blocks_move_all`, is held
in a local nothing reads.

### The witness

`fnptr/fnptr.lm2` is a machine module whose export `main` returns 0 when every check holds, else the number of the first
that fails. It predefs the ABI's headers `lmx.h.lm1` (`LmxPointerCellWrite`) and `lmx_arena_blocks.h.lm1`
(`LmxArenaBlockDisposer`), is translated by the frontend, lowered by l1trans, compiled by the stage's gcc at -O2 and
linked with nothing else.
1. `through(c.write_one, cell)`: the formal's value is called in value position: 1, and the cell records 1.
2. `through(c.write_two, cell)`: a second activation with the other value: 2, and the cell records 12.
3. `twice(c.write_two, c.write_one, cell)`: two formals called in statement position in their written order: 21.
4. `capture`: `write(cell, retarget(@ write, cell))`, where retarget points write at write_two while the actual runs;
   the call still reaches write_one, the value write held when it began.
5. `order`: `write(p, shift(@ p, second))`, where shift moves p; the call writes where p pointed before.
6. `sized`: `c.pack(k, bump(@ k))` through the C door, with size_t k: 12 (pack(1, 2)), not 22.
7. `dispose_through(c.dispose_note, cell, 7U)`: a formal of the block list's disposer type in statement position.
8. `offsets`: `at + c.LMX_ARENA_BLOCKS_INVALID` and `c.LMX_ARENA_BLOCKS_INVALID + at` (a define, opaque) equal `at + 1`;
   `at + c.sizeof(c.int)` equals the next int's address.
9. `local_order`: the statement call of a function-pointer local keeps its first actual before the later actual moves p.
10. `local_value`: the same call in value position.

| Run | Frontend | Result |
| --- | --- | --- |
| `fnptr-05` | `fe-06` | translates, lowers and compiles; `fnptr.exe` exits 0 |
| `fnptr-control181b` | Verified181's `fe-02` | refused at its first such call: «unknown method», frame=write (31:13) |

A function-pointer local has no address in L2 (`@ write` has no type: FNPTR-LOCAL-NO-ADDRESS, OPEN), so nothing can
change its value after its declaration, and its kept callee has no witness.

### Mutants

| Mutant (`build2/opus_mut182`) | Change | Witness |
| --- | --- | --- |
| `fe-mutC` | a callee the method holds is never kept (`mutants/mutC.patch`) | `fnptr.exe` exits 4: the call reached write_two |
| `fe-mutK` | no earlier actual is kept before a later actual's call (`mutants/mutK.patch`) | `fnptr.exe` exits 5: the call wrote where p pointed after shift |
| `rt-mutB` | the block list's tail reports a cycle for every list of two blocks or more (`mutants/mutB.patch`), regenerated by `fe-06` | smoke `SUITE 6 rows, 20 failures`: every launch of the five runtime rows, both modes and both roots, exits 1 or dies (access violation, heap corruption); the translation-only row passes |

The translator mutants' smoke is 6/0: the smoke has no such call. The mutant stage's source was restored after each
mutant and checked equal to the final stage's (`M/src` equals `S/src`).

### Targeted corpus replays

- `replay182-01` (`fe-06` + `rt-02`) runs Verified178's list (276 fixtures, both modes, 1121 checks): PASS 750, and every
  line of its output equals Verified181's `replay181-01` (stage paths normalized). Its `failures.tsv` holds the same 370
  inherited failures. The L1 and C of every row are byte-equal to `replay181-01`'s: the tool's `manifest` hashed the same
  576 relative paths in both replays and its `same` compared the two manifests (`l1same/`, `SAME 1`).
- `replay-fnptr.tsv` lists the 18 corpus fixtures that import a header declaring `fnptr:` (the function-pointer local's
  route; `library_fnptr_local_forms` is a library without a root, no `runs` row). `replay182-fnptr-01` (`fe-06` + `rt-02`)
  and `replay181-fnptr-01` (Verified181's `fe-02` + `rt-01`) print the same output: `SUITE 18 rows, 34 failures`. The
  fixtures predate today's grammar of formals (`const: @(c.T av)`) and pointer declarations (`@: void got v`): both
  frontends refuse them at translation. The one live row, `graph_shape_machine_local`, passes in both modes, and its L1
  and C are byte-equal (`l1same-fnptr/`); `unit_rn_fnptr_local_refused` refuses at its name, as it should.

### The tools with the new recipe

`tooltrans-01`: the stage's tools sources, as `bld_self` lists them, translated by `fe-06` (L2 → L1, exit 0, 150 s,
635 110 lines) and by `bin/l1trans.exe` (L1 → C, exit 0, 15 s, 806 928 lines). The tool was not compiled.

## Evidence

`evidence-182.list` names 147 files: the stage's inputs and their Verified181 parents, the generated modules, the
replayed patches, the builds and their runs, the replays compared and their manifests, the witness and its control, the
mutants and the tools' translation. `evidence-182.sha256` holds their SHA-256, written by the tool's `manifest`
(`runs/manifest-01`: `MANIFEST 147 files, 0 failed`); `sha256sum -c` checks all 147 OK. The packet's copies have LF line
ends and no trailing blanks; the manifest hashes the original bytes in `build2`.

## Not run (an explicit OPEN checkpoint)

- The tool compiled with the new recipe, the runtime built through it, and the quick bootstrap: memory, as in
  Verified178 to Verified181.
- LATER: the kernel gate, the gate, `bootstrap full`, the full corpus replay, broad tests of the block list and of C
  calls.

## OPEN

- C-DOOR-ACTUALS-UNORDERED (rest): a C door value before an actual that runs a call is refused; the receiving contract
  (the `fnptr:` or prototype's parameter type) is not read for it.
- C-DOOR-MEMBER-ACTUAL-UNTYPED: C members have no L2 type; a C member callee before an actual that runs a call is
  refused.
- FNPTR-LOCAL-NO-ADDRESS: a function-pointer local's address has no type.
- The storage layer's source closure: the records stay in hand-written `lmx.h.lm1`, `lmx_arena.h.lm1` and
  `lmx_arena_blocks.h.lm1` until the machine C layout of types is decided (asked of the author by Codex).
- MACHINE-STATUS-CHANNEL: a declared exit of a machine function has no C ABI.
- PUBLICATION-FAILURE-UNSAID: `l2_pub_commit` fails without a located diagnostic for ordinary outputs.
