# Slice 184: each method's frames in a builder of their own (GENERATED-CODE-SIZE, second step)

Opus, 2026-10-24, sole writer/build. The slice follows Codex's work order on Verified183
(CODEX-OPUS-ROUTE183-20261024T064656Z): «сначала снять измеренное препятствие сборке самого инструмента (огромная
l2_program_build), затем обычный L3-код печати L1-объявлений в существующем recipe, реальная сборка инструмента и
короткий bootstrap с фактическими заголовками». Its guidance: «Разделение этого вывода по функциям — обычное изменение
генерации, без новой языковой семантики/разбора/механизма. Сохрани существующий порядок построения и единственные
COUNT/EMIT и FILL ... Нужные текущие зависимости передавай явно, не заводи ради разбиения отдельную систему
контекстов. Учитывай внутренние/inline-вхождения: окончательное заполнение всех кадров должно оставаться до
l2_emit_parts/sealing/publication, как сейчас.» «Главный результат здесь: инструмент реально компилируется в
доступной памяти и запускает существующий минимальный сквозной путь».

## The measured obstacle

Verified183's tools translate to 638 610 lines of L1 (`tooltrans-01` there); one function, `l2_program_build`, is
336 639 of them, with 38 382 locals, 36 512 of them walker frames. The tool did not compile in the memory available
(3.3 to 4.3 GiB of free commit against about 5.4 needed, Verified178 to Verified183).

Read from that L1 before the change (`analysis/commands.txt`): the function declares its 1 145 source containers'
shells before any frame, then the frames of each of the 148 walkable methods as one section. The source containers a section
names form one contiguous run shared with no other section; in that L1 a section names no frame of another section,
and it writes the build's scratch handles before it reads them. So each method's frames can be a function of their
own, given explicitly the build function's arena, unit, shared roles and named Structures and the handles they name.
The handles are noted where the translator writes them, not inferred from that reading: the first build (`fe-01`)
met a second kind, a computed output's storage, in `lib_owner`.

## What changed

`src/l2src/l2trans.lm1` (the one input that changes):
- In the build function (R0's `l2_program_build`, or a library's construction export), each walkable method's frames
  (`l2_rw_methods_emit(2)`, the same `l2_rw_method_emit_one`) are written into a function of their own,
  `l2_u<hash>_frames<i>` (`l2_frames_build_emit`), and the build function calls it where the frames stood -- after
  FILL, before the header parts (`l2_emit_parts`), the seeds, sealing and publication, in the methods' order. The
  frames are the same steps the count pass made, built into the same occurrence in the same arena; nothing is built
  twice, and no graph object, flag, lexical parent or singleton is added. A method with no frames has no builder.
- A builder takes, explicitly, the build function's arena, unit, shared roles (`l2_rw_roles`) and named Structures
  (`l2_nsp`), and the build function's handles its frames name, in the order they first name them
  (`l2_frames_note`): a source container's shell (`l2_sc<id>`, kind 0) and a computed output's storage (`l2_rw<id>`,
  kind 1, which FILL allocates in `l2_source_cells_emit`). It declares the build's scratch handles as
  `l2_merge_body_build_<n>` does. The handles are noted where they are written (eleven `l2_sc` sites, two storage
  sites); a shell or a body's cells declared inside a builder is an internal error.
- The name carries the module's hash, as the pointer-cell writers' do (`l2_u%08X%08X_pc%d_write`): a program and the
  libraries it links each have their builders.
- So that each builder precedes the build function, the build function's text goes into `OUT.build.tmp` until it is
  complete (`l2_build_text_begin`, `l2_build_text_end`), and a builder's frames into `OUT.frames.tmp` until its
  parameters are known; both are copied into the output and removed.

## Real runs

The tool is Verified176's `build2/opus_fix176/tool-01/lmxtool-tool.exe` (until the new one is built). The runs are
its commands and direct invocations of the frontend and `bin/l1trans.exe`; no probe script was written, and the
commands are kept as text. The runtime of the smoke and the replay is Verified183's `rt-01`: the kernel's sources do
not change, and its machine modules have no build function.

| Run | Inputs | Result |
| --- | --- | --- |
| `rebuild-frontend-01` (`fe-01`) | the frame builders, the source containers as parameters; smoke on `rt-01` | `lib_owner` (both modes) refused by gcc: its frames name computed outputs' storages (`l2_rw798`), which FILL declares in the build function |
| `fe-02` | the storages as a second kind of noted handle | `lib_owner` refused by the linker: the program and the libraries it links each defined `l2_frames_build_0`, `_1`, `_5` |
| `fe-03` | the builder's name carries the module's hash | `SUITE 6 rows, 0 failures`; the final frontend |
| `rebuild-tool-01` (`tool-01`) | the stage's tools sources by `fe-03`, linked with `rt-01`'s `driver.o` | the tool is built: L2 → L1 3:29 (with the runner's launch), L1 → C 0:21, C → object 7:19 at -O0, cc1 at most 1 498 MB, free commit at least 2.02 GiB while cc1 ran (1.85 GiB during L1 → C); it hashes a file as the old tool does; it runs the smoke list itself: `SUITE 6 rows, 0 failures` |

### Targeted corpus replay

`replay184-01` (`fe-03` + Verified183's `rt-01`) runs Verified178's list (276 fixtures, both modes, 1121 checks): PASS
750, and every line of its output equals Verified183's `replay183-01` (stage paths, frontend and replay names
normalized). Its `failures.tsv` holds the same 370 inherited failures. The L1 and C of every row change shape, as
Codex foresaw («Новые L1-байты после выделения функций ожидаемы»): the tool's `manifest` hashed the same 576 relative
paths, and all 576 differ from Verified183's manifest (`l1diff/`), since every row has at least its root's frames.

### The tools' translation

`tooltrans-01`: the stage's tools sources, as `bld_self` lists them, translated by `fe-03` directly (L2 → L1, exit 0,
157 s, 640 238 lines; Verified183's `fe-06` on the same sources: 161 s, 638 610 lines) and by `bin/l1trans.exe`
(L1 → C, exit 0, 19 s, 813 179 lines; 20 s, 811 403 lines). The L1 and C are byte-equal to `tool-01`'s: the
builders cost no translation time, and `tool-01`'s 3:29 includes the runner's launch.

| Measure, the same tools sources | Verified183's frontend | `fe-03` |
| --- | --- | --- |
| L1 lines | 638 610 | 640 238 |
| C lines | 811 403 | 813 179 |
| `l2_program_build`, lines of L1 | 336 639 | 23 410 |
| the largest function, lines of L1 | 336 639 (`l2_program_build`) | 26 990 (the root's frames) |
| frames builders | 0 | 148 |
| C → object at -O0 | not compiled (memory) | 7:19, cc1 at most 1 498 MB |
| object, executable | -- | 23 937 085 and 20 008 803 bytes |

## Evidence

`evidence-184.list` names 69 files: the stage's input and its Verified183 parent, the replayed patch, the frontend
builds and their smoke failures, the tool's build, check, smoke and memory log, the replays compared and their
manifests, the tools' translations and the reading of Verified183's build function. `evidence-184.sha256` holds
their SHA-256, written by the tool's `manifest` (`runs/manifest-01`: `MANIFEST 69 files, 0 failed`);
`sha256sum -c` checks all 69 OK. The packet's copies have LF line ends and no trailing blanks; the manifest hashes
the original bytes in `build2`.

## Not run (an explicit OPEN checkpoint)

- The quick bootstrap: next, with the arena's and pools' declarations written by L3 code of the recipe (the
  author's direction; CODEX-AUTHOR-L3-HEADER-REVIEW-20261024T062211Z).
- No mutant: the split's failures are the compiler's and the linker's (`fe-01`, `fe-02`), and Codex asked for no
  new mutant or runner for this step.
- LATER: the kernel gate, the gate, `bootstrap full`, the full corpus replay.

## OPEN

- GENERATED-CODE-SIZE's rest: about 122 lines of L1 per line of L2 (the jumps to the code's place and the publication
  calls at every boundary); during L1 → C of the tool's L1 the free commit fell to 1.85 GiB (l1trans itself not
  measured).
- The storage layer's declarations (next), C-DOOR-ACTUALS-UNORDERED (rest), C-DOOR-MEMBER-ACTUAL-UNTYPED,
  FNPTR-LOCAL-NO-ADDRESS, MACHINE-STATUS-CHANNEL, PUBLICATION-FAILURE-UNSAID.
