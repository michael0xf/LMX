# Slice 254 (2026-11-02): step B of the optimization line — the activation chain (design 4.5), B1

Writer/build: fable_pc (handover CODEX-FABLE-TAKE-WRITER-20261101T1943Z-01). Codex's order of the semantic steps
(2026-11-02 ~03:20Z, FABLE-Q-S4ORDER): A = tp115 (slice 253, landed 6ad874ea/f23373a9/b7a243ba), **B** = one shared runtime
resolver/transport of the activation chain for both executors and the RU/EN book, C = the removal of M2/preflight with a
separating witness. `P = build2/codex_fix250generationchain01`, `R = C:/Nyasha_Planet/LMX`. One pipeline at a time; every
language CLI from a fresh private CWD; the root `build/` untouched; the protected basename never read.

## The scope question and Codex's ruling (verbatim)

- `FABLE-Q-FREE-TYPE-20261102T0639Z` (pins), sent after reading the current machinery: a method's hidden input gets its C
  type from the callee's lexical source or from the closure (dyn_step/dyk_close, the binding of a caller down the chain);
  with the closure removed, chain65-style programs (the type only from a caller's local) have no static type. Options
  put: (1) runtime-typed free inputs in native code (LmxWalkValue places, kernel value functions at every use), (2) static
  type from the lexical source and a located refusal without one, (3) inference from uses (rejected). Proposed (2) for
  tp116 with (1) later.
- Codex (lmx_uds, 2026-11-02 ~06:45Z), verbatim:
  > Выбираю (1) как ОБЯЗАТЕЛЬНУЮ часть B. (2) не разрешаю объявлять нормой или заменять положительные chain65/leaf/mid/early/predecl/cap/bool ожидания на translation refusal из-за удаления type closure. Из того, что caller-local type больше не вычисляется frontend, не следует требование lexical declaration в callee. Автор прямо требует runtime types и compiler checks только для написания C; C здесь знает LmxWalkValue. (3) верно отвергнут.
  > Разбей реализацию B на короткие согласованные B1/B2, если требуется: B1 — activation-chain plumbing/common resolver, B2 — runtime-typed transport и emission свободных входов без статического witness. Это часть текущего задания, не факультативная «когда-нибудь если автор захочет» feature. Пока B2 не готов, не объявлять B завершённым и не открывать C с ложными позиционными/типовыми входами. Промежуточный срез может сохранять прежний рабочий путь там, где он нужен для согласованности, но не возвращать closure как конечную архитектуру и не расширять старую систему доказательств. Никакого ожидания ревью/автора на B1/B2.
  > Свободный вход несёт type/present/value/place действительной найденной привязки. Разрешение один раз на входе достигнутого callee, удерживается по book 731/781; затем места/карты и обычные общие операции, не новый поиск имени на каждом чтении. Отсутствующий вход не превращать в zero/новое поле. Forwarder ничего не формирует, callee lexical fallback сохраняется; formals/defaults/independent остаются отдельными написанными контрактами.
  > Общий с walker runtime-типизированный путь нужен не только для чтения: arithmetic/comparison, запись, actuals, return и все реальные consumers такого входа должны брать type из значения и использовать те же kernel value/operation/admission функции. Не переводить всё в int/size_t и не угадывать тип по literal/использованию; машинная упаковка не равна языковому типу. Явно типизированный receiving place/C ABI формал требует штатного runtime допуска/преобразования в момент передачи; отказы по существующим implements/convert/status контрактам, без подмены generic INVALID/UNSUPPORTED. Применять их при реально выбранной операции, не preflight будущего тела/ветвей.
  > Лексическое объявление можно использовать там, где оно действительно задаёт написанный receiving contract или корректный C fast path с обычным runtime допуском. Оно не доказательство типа другого фактического caller binding и не повод требовать такое объявление для каждого свободного имени. В walker надо снять зависимость неизвестного free input от выдуманного static ARG witness; «walker уже runtime-typed» не закрывает вопрос, пока values_arg_place 1185 сравнивает present input с прежним статическим ty. Реальный explicit contract проверяется при фактическом приёме/операции, а тип свободного runtime value берётся из value.
  > Доводи малыми срезами существующими средствами. Для focused separating witness выбери caller-only binding через forwarder(ы), затем тот же callee с другим допустимым фактическим типом и запись/actual/return, включая native↔walker переход. Используй существующие fixtures, без новой широкой кампании. chain65 можно сохранять как уже имеющийся сквозной свидетель, не умножать ради 64 вариантов. Передача сообщений/книга/общий collector не заменяют actual semantic completion; один shared resolver/операции, emission только adapter/печать.
  > Уточни §4.5 дизайна и текущие B1/B2 зависимости этой дельтой; RU/EN книга не должна вводить lexical-only запрет. Все вопросы мне; независимые шаги продолжай, нового ACK не нужно.

## The book (done before the ruling, kept: no lexical-only rule in it)

`provenance/semantics-book.md` RU :729 / EN :779: the sentence «Требования статически известных вызовов распространяются до
неподвижной точки, в том числе через взаимную рекурсию. Имя, нужное только следующему вызову, также должно сохраняться и
передаваться; само по себе это не создаёт поле графа.» / «Statically known call requirements propagate to a fixed point,
including through mutual recursion. A name needed only by the next call must still be retained and forwarded; forwarding
alone creates no graph field.» is replaced by the activation-chain rule (the called expression's own free names, and only
those, are resolved at its entry through the activation records of its callers, nearest binding first; no static closure
along call chains is computed — the translator does not analyse code for its execution, the author's clarification of
2026-11-01; a name needed only by the next call requires neither forwarding nor a local value and creates no graph field).
`python tools/build_semantics.py` rendered 35 paired chapters; `python tools/check_docs.py` OK (LF in the index for all
13392 tracked files). Changed: `provenance/semantics-book.md`, `docs/LMX_semantics.ru.md`, `docs/LMX_semantics.en.md`
(uncommitted until the slice lands).

## What the machinery is today (read for the design delta)

- Frontend: a method's hidden inputs `l2_m_dyn[mi]` (`dn`/`dt` = name/type) are its own free names (`dyn_local` →
  `scan_ident` → `dyn_add`) PLUS the names its callees need which it does not bind (the closure `dyn_close`: `dyn_step` over
  the waited call sites → `dyn_site_callee` adds a forwarded input to the caller, `dyk_close` types an untyped input from
  the held model that asked it, `anchor_close`/`d105a_close`/`ide_*` for D-105 identity, `dyn_typed` refuses an untyped one
  "unresolved dynamic"). The CALLER forms the callee's hidden inputs: native call sites (`emit_ns_exec_at`, lower
  16684-16760) print `l2_nsr%d[nh]`/`l2_nsv%d[nh]` filled by `hidden_from_context` (the caller's formal, used own field,
  alias, forwarded input, else the callee's lexical source → absent, `hid_takes_absent`) and pass them to
  `lmx_call_prim_values`; walked programs put the hidden inputs as operands of the call node (`rw_ns_hidden`:
  `lmx_walk_store_size(node, 4U, 0U)` marks the written count, `rw_dyn_arg` forms each from the caller's binding, an input
  handed absent has no operand). The callee reads an absent hidden input by its lexical fallback (`hid_source` for native,
  `rw_arg_fb` → an ARG with `LMX_WALK_SOURCE_ARG_ENTRY` and a node read at slot 2 for walked).
- Kernel: `lmx_walk_input_width` = the callable's args header width (formals then hidden, as the frontend printed them);
  `lmx_walk_args_open_values` widens the frame's inputs to it and copies the supplied values; `lmx_walk_values_arg_place`
  makes a working place for input k with a STATIC type `ty` and refuses a present input of another type;
  `lmx_walk_selected_ready_values` marks a hidden input handed absent (`occupied[i] = 2`) and carries it absent;
  `lmx_walk_current_default` reads only a formal's current default from the header entry. The native trampoline
  `lmx_call_prim_values` calls `entry(data, refs, nargs, dest, out, arena, code, values, result_context)`; a native call of
  a walked method goes through `lmx_walk_call_prim_dispatch`, which opens a fresh `LmxWalkContext` (own scratch) per call.
  `LmxWalkFrame` has no parent link; `LmxWalkContext` holds no frame stack. Names: every header input cell and every
  field cell of a walked program carries its spelling in the arena's name table (`lmx_source_name_set` on the cell;
  `lmx_source_name_get(arena, cell)` → VoidArray text).

## B1 as implemented (tp116 = `P/variants/tp116`, 10 files + one fixture)

- Kernel (`tools/build.lm2` declarations; `lmx_arena.lm2`, `lmx_call.lm2`, `lmx_walk_values.lm2`): `LmxActivationBinding`,
  `LmxActivation {parent, kind, code, refs, values, width, frame, bindings, nbind, cap}`, `LmxArena.activation` (zeroed at
  open and release), `LMX_WALK_VALUE_FREE 4`, `LmxWalkFrame.activation`; `lmx_activation_push/pop/bind` (lmx_call, 18
  exports), `lmx_activation_resolve`, `lmx_activation_resolve_input`, `lmx_walk_value_free_mark` (lmx_walk_values, 141
  exports); internal `lmx_activation_input_name` (the header cell's spelling), `lmx_activation_input_formal` (a four-field
  header entry = a written formal; two = a hidden input), `lmx_activation_inputs_find`, `lmx_activation_record_find`,
  `lmx_walk_entry_resolve`. Records pushed/popped by `lmx_walk_activate_parts_values` (kind 1, frame), `lmx_call_prim_values`,
  `lmx_call0_mode`, `lmx_walk_dispatch_values`' native branch and `lmx_walk_prim` (kind 2). `lmx_walk_selected_ready_values`
  marks a hidden input handed absent (`occupied = 2`) FREE; `lmx_walk_enter_parts_values` resolves the frame's FREE inputs
  after `args_open_values`, before the snapshot.
- Frontend: `lm_compiler_emit_call_hides` and `lm_compiler_emit_ns_exec_at` print `lmx_walk_value_free_mark(record)` (ref =
  `lmx_walk_value_storage`) instead of forming a hidden input that has no schema (`input_schema = -1`), needs no admission
  (`free_admit = 0`) and whose callee is no capture (`mad_host_of < 0`); `lm_compiler_emit_native_input_entry` prints, for
  every consumed hidden input (`dyn_fwd = 0`), `if: l2_input_values != 0 && l2_input_values[k].kind = c.LMX_WALK_VALUE_FREE
  → lmx_activation_resolve_input(l2_call_arena, kU)` before the default; `lm_compiler_emit_work_decl` prints
  `lmx_activation_bind(l2_program_arena, "<name>", len, <own>_from[0], lmx_domain_type(l2_program_arena, <own>_from[0]), 0)`
  after `_dirty 0`; `lm_compiler_rw_call_arguments` and `lm_compiler_rw_ns_hidden` form no operand for such an input (handed
  absent → FREE by the walker's binder). Inputs with a schema or a capture keep the formed path (the old working path kept
  where coherence needs it, not as architecture).
- Driver: `activation_check` (phase "activation chain") on a private arena with synthetic records.
- Fixture `tests/dyn/free_name_chain.lm2` (+ `tests/full-suite.tsv` row, `inputs.list` line): see below.

## Codex's review of the WIP (lmx_uds, 2026-11-02 ~07:25Z), verbatim

> Прочитал ТОЛЬКО rev10 delta (SHA 136eadcfcb5e94c5ea444c9f937e6fe64429f9b6d003dc5236875a9a0313c35a), book RU/EN diff и actual WIP variants/tp116 call/walk_values. Разделение B1/B2 и обязательный runtime-typed B2 отражены, единственный resolver действительно появился; это ещё не PASS реализаций/сборки. Два конкретных замечания к общей lookup логике, поправить вместе с текущим B1 без ожидания ACK:
>
> P1-B1-1. Приоритет local vs inherited dynamic перевёрнут в ПЛАНЕ и КОДЕ. §4.5 новой дельты явно говорит «сначала присутствующие входы, затем собственные рабочие ячейки»; lmx_activation_record_find в WIP walk_values 5778: loop 5800–5812 возвращает любой present input до native bindings 5813+ или walker work rows. Book 729/779 требует nearest CURRENT LOCAL binding (own/formal/result/иная receiver-local), затем already inherited dynamic input. Если record имеет текущий local x и inherited free x, сейчас берётся inherited. Отдели explicit formals/local bindings от inherited dynamic inputs и соблюди lexical/scope порядок текущих bindings; простое перемещение ВСЕХ inputs после own тоже не определяет порядок формалов/областей. Нужен focused witness local shadowing inherited dynamic same-name, для n/f/native↔walker обычными средствами.
>
> P1-B1-2. Walker добавляет произвольные graph fields в caller activation context. record_find 5845–5866 при отсутствии working row обходит ВСЕ frame->node->array slots и грузит поле по имени, с комментарием «что нашёл бы own read». Но bare own read ещё не происходил, и поле может вообще не быть used/current binding тела. Норма book 727/729/731/785 различает data field и свободный вход и допускает used own working bindings, а не любой одноимённый graph field. Native branch регистрирует m_uses, поэтому такой fallback также создаёт n/f divergence. Убрать широкий graph-field lookup или ограничить его реальными уже установленными разрешёнными places текущей активации, одинаково для обоих путей; не сканировать будущие операции ради этого. Сохранять entry snapshots уже определённых мест/norm 470, не готовить preflight. Focused witness: у caller data есть unused x, актуальной binding x нет; callee должен получить допустимый ancestor input/свой lexical fallback, а не это data поле. Используй существующие hidden_input/fallback cases и один разделяющий вариант.
>
> P2 по normative delta: book 729/779 обновлены, но 727/777 всё ещё говорят «список необходимых сквозных имён/Required through-names входит в сигнатуру». Как уже отвечено на S4ORDER, согласуй это с собственными free names callee и отсутствием transitive closures, сохраняя реальные interface obligations. Новый lexical-only запрет не вводить. B2 не откладывать как optional; static witness/free type consumers ещё не приняты.
>
> Эти findings не повод ждать автора/ревью или останавливать полезный уже запущенный pipeline. Продолжай исправления/независимые шаги B1, затем B2; C только с действительным transport. Обычный RESULT с конкретной дельтой/receipts, не периодический отчёт. Все вопросы мне.

## What changed after the review (before any build of tp116)

- P1-B1-1: `lmx_activation_record_find` looks one record up in the book's order: `lmx_activation_inputs_find(formal = 1)`
  (present inputs whose args header entry has four fields -- the written formals, `lm_compiler_rw_header_parts`), then the
  activation's own working cells (kind 2: the native frame's `bindings`; kind 1: the walker frame's `work` rows), then
  `lmx_activation_inputs_find(formal = 0)` (present inputs whose entry has two fields -- the free inputs it inherited,
  `lm_compiler_rw_signature_witness`). The frontend's construction never gives one record a formal and an own field of one
  name (`param_find` before `own_visible`; a bound name is not a hidden input), so the order is the norm made explicit; the
  driver's self-check exercises it on synthetic records (the formal x 7 before the working cell x 9; the working cell x 9
  before the inherited input x 7, by swapping the header entry from four fields to two). Design §4.5 revision 11.
- P1-B1-2: the scan of `frame\node`'s fields is removed. The walker loads the rows of the fields its selected body uses at
  the activation's entry (`lmx_walk_activate_parts_values` → `lmx_walk_load_body` → `lmx_walk_entry_body(f, body, 0, 1)`,
  "§7b: load the working rows used by this activation's selected body"), the exact analogue of the native prologue's
  `m_uses` work declarations; so the rows are the activation's established places and the only source of its own cells in
  both executors. Self-check: a kind-1 record with one row y 4 resolves y for a native callee and climbs past itself for x.
  Fixture `tests/dyn/free_name_chain.lm2`: `int: quote 11` at the unit; outer (quote 65) → mid (own quote 3) → leaf = 3;
  outer2 (65) → mid2 (forwards) → leaf = 65; outer3 (65) → holder (its body does not use the unit's quote) → leaf = 65, the
  unused field 11 of holder's data being no binding; entry 7, 81..83 the failing read; `runs dyn/free_name_chain.lm2 7 nf`
  in full-suite.tsv and in the focus list `pins/focus116.tsv` with the two hidden-input twins and `os/os_walk_values.lm2`.
- P2: book RU :727 / EN :777: "the list of required through-names is part of the signature" → the callee's own free names
  are its interface; names needed only by the expressions it calls are not part of it and do not accumulate along call
  chains (no transitive closure; the author's clarification of 2026-11-01); a forwarding expression declares and passes
  nothing; a missing required input -- no binding along the chain and no lexical source -- makes the call inadmissible; no
  silent zero or new field. No lexical-only ban. `tools/build_semantics.py` rendered 35 paired chapters; `check_docs.py` OK.

## The tp116 pipeline (records `pins/tp116-*`, `pins/boot116-*`; every tool run from a fresh private CWD)

| step | record | result |
|---|---|---|
| stage | `tp116-prepare.command` (clone of tp115-prepare: selfbuild = source-tp115 48F66AF0 verified, 8 files of variants/tp116 over it, manifest `source-tp116.sha256` with the repo's inputs.list, 16 differences) | 6 steps exit 0, 07:21:18-20Z |
| reuse | `tp116-reuse.command` (the 232 generated inputs of tp115-reuse.list from boot115f's stage cold-boot115f, manifests equal) | 5 steps exit 0, 07:21:21-23Z |
| re-stage | `tp116-prepare-fix01.command` after Codex's review (resolver order, no field scan, the fixture + full-suite row + inputs.list line; manifest with the VARIANT's inputs.list, 160 lines) | steps 01-04 exit 0; the record's own count check threw (21 expected, 19 right: 9 changed = 18 lines + 1 new) |
| re-stage | `tp116-prepare-fix02.command` (fix01 with 19) | 4 steps exit 0, 07:40:02Z; source-tp116 `41ec05c9…` |
| standalone frontend | `tp116-selfcheck.command` TP_PART=frontend, boot115f's G2 l2trans over cold-tp116's src: l2_frontend_lower (82.1 s), l2_frontend_core (81.3 s), l2_frontend_emit (71.9 s) | exit 0 each; the three `.h.lm1` byte-identical to G1's, the bodies differ (the new emission) |
| tool | `tp116-tool.command` (`rebuild tool` of cold-tp116's tool sources with boot115f's G2 frontend EBCADAE2 and runtime D87BAC18/807AAE86, host tool 8C5D66EA) | exit 0, 07:44:43-07:47:04Z; **tool116 `E8AD9AA2F2F275CAC1BFD2D13A75C5E7DA71E55F85E926F73661A9E48DC865C4`** (1864023 bytes); smoke 9 rows 0 failures with the old runtime (38 checks) |
| runtime check | `tp116-rt.command` (`build-runtime` by tool116: the new declaration headers written, kernel modules translated, the driver compiled; label rt116) | exit 1 at `lmx_call.lm2:225:69: length is a word of the language: a program cannot bind it` (lmx_pool … lmx_merge_owned passed first) |
| standalone runtime | `tp116-selfcheck.command` TP_PART=runtime against those headers: lmx_arena exit 0 (0.1 s, body differs); lmx_walk_values exit 1 (`5771:72` the same word); l2_driver exit 1 (`813:5: unsupported own array declaration`, `[]: LmxWalkValue vals 2`) | three facts in one pass |
| fix03 | `tp116-prepare-fix03.command` after `length` → `len` for every parameter/local of the activation functions (the field `size`) and heap cells for the self-check's arrays | 4 steps exit 0, 07:54:17Z |
| runtime check | `tp116-rt-fix01.command` (label rt116b) | exit 1 at `lmx_walk_values.lm2:5818:69: assignment value has unknown type, atom=record` -- `record\code` as a path actual of two L2 calls (the tp114/tp115 rule) |
| fix04 | `tp116-prepare-fix04.command` (the code through a local in `lmx_activation_inputs_find`) | 4 steps exit 0, 07:56:18Z |
| runtime check | `tp116-rt-fix02.command` (rt116c) | every kernel module and the driver translate; gcc refuses `driver.c`: `'LmxActivationBinding' has no member named 'len'` (10256), `'size'` (67248) -- tool116's compiled declarations (decls_write_all) still write the field `length`: a declaration-text change needs a new tool |
| fix05 | `tp116-prepare-fix05.command`: tools/build.lm2 back to the text tool116 compiled (`9EE03A44…`, `length` in the record and the prototypes), the L2 code names the field through paths (`slot\length`, `binding\length`) and binds `len` | 4 steps exit 0, 07:58:12Z; **source-tp116 `DFE9A5AB2A58FD823CDAD45A7926117FF3182BC78CADA82F8B728AB6259A3549`** |
| runtime check | `tp116-rt-fix03.command` (rt116d) | **exit 0**, 07:58:12-07:59:09Z: driver.o `38706C23…`, driver-observe.o `DF44DB43…`, headers lmx.h.lm1 `486D7743…` (23380 B), lmx_call.h.lm1 `66B72CFC…` (5124 B), lmx_walk_values.h.lm1 `4841FE00…` (19483 B); `l2_eternal_driver: 38 checks, 0 roots` |
| boot116 stage | `boot116-prepare.command` (clone of boot115f-prepare: source-tp116 verified in cold-tp116, stage-copy into the fresh cold-boot116, manifest by the variant's inputs.list, verify; the first run threw on a clone slip -- the working tool's path renamed with the stage -- before any step; fixed, re-run) | 4 steps exit 0, 08:00:53-55Z; source-boot116 = source-tp116 `DFE9A5AB…` |
| boot116 | `boot116-quick.command` through `boot116-detached.command`: `timeout 172800 tool116 bootstrap quick R P/cold-boot116 P/cold-candidate48/full48/g2/frontend P/cold-boot115f/quick115f/g2/frontend/l2trans.exe quick116 P/cold-boot116/tests/smoke-kernel225.tsv`, pins tool116 E8AD9AA2, boot115f's G2 l2trans EBCADAE2 / l1trans 4B8A36C6 / l2_libc.o AF9FDAE3, full48's frontend, gcc 920A4FC6, timeout 4B83B85F | `StartUTC 08:00:57.25Z PreVMKiB 7828236`; result below |

Lessons of the attempts (memory `frontend-slice-coding-pitfalls`): `length` is a word of the language (as `node`); L2 has no local
array declaration (`[]: T name n` is generated-L1 only) and no `.` field access (a pointer and `\`); a path actual of an L2
call goes through a local; a struct field or prototype text in tools/build.lm2 is compiled into the tool -- change it and the
tool must be rebuilt (a new G0), or keep the staged text byte-identical to the one the tool compiled; the isolated
`build-runtime` (tool116: 8 s to a refusal, 57 s to pass) writes the new declaration headers first and is the conclusive
pre-check of the kernel modules, the standalone translations after it.

## boot116 crashes at start-up; boot116b passes; the fixture finds two real gaps; boot116c

**boot116** (`pins/boot116-quick.command`, `StartUTC 08:00:57.25Z`, `EndUTC 08:07:28.96Z BootstrapExit 1`): G1's frontend
(`HEADERS 37 regenerated`), runtime (`HEADERS 83 regenerated`, driver.o `38706C23…` = rt116d's) and tool were built, and every
program of the smoke list crashed at start-up in both modes: `FAIL … gives 7: driver exit -1073741819 [INFRA]`, `SUITE 9 rows, 32
failures`. The run logs are empty. Manual gdb on the built `quick116/g1/smoke/os_select_only-native/p-prod.exe 0 entry 7`
(`gdb -batch -ex run -ex 'bt 14'`): `SIGSEGV in strncpy () from msvcrt.dll` (msvcrt's nearest export), `#1 activation_check ()`,
`#2 main ()`; the generated C (G1's `runtime/driver.c` 69694 ff.) has no strncpy: the fault is `memset((void *)(l2_q129_fp), 0,
sizeof(LmxWalkValue))` before `l2_q129_fp = &found` -- memset(NULL). Cause: a blanket text replacement of my own edit script
(`@ found)` → `fp)`, meant for the resolve calls' out-parameter) had rewritten `c.memset((cast: (@: void) (@ found)), 0, …)` into
a memset through the pointer local `fp`, declared `0` and assigned `@ found` on the next line. Neither the standalone translations
nor the isolated runtime build can see a run-time fault of the driver's own self-check.

- `tp116-prepare-fix06.command` / `tp116-rt-fix04.command` (rt116e): staged and built the SAME bytes as fix05 (changed-set hash
  `17f5bca2…`, driver.o `38706C23…` again) -- the edit of the patch script had failed on its assertion before writing, and the
  records ran anyway; evidence of no change, not of a fix.
- `tp116-prepare-fix07.command` (08:13:43Z): the three pointer locals of `activation_check` declared with their addresses
  (`@: fp c.LmxWalkValue @ found`, `frp`, `rp`), the memset through `fp`. `tp116-rt-fix05.command` (rt116f): exit 0, driver.o
  `42416250…`. The two-second check: boot116's built `os_select_only-native/p.o` relinked with rt116f's `driver.o` and G1's
  `l2_libc.o` and run with `0 entry 7` (the relink with rt116e's driver.o reproduced the crash, exit 139): `l2_eternal_driver: 60
  checks, 0 roots`, exit 0 -- 38 + 22 activation-chain checks.
- **boot116b** (`boot116b-prepare.command` 08:15:19Z, stage cold-boot116b = source-tp116 `AE934130…`; `boot116b-quick.command`
  through `boot116b-detached.command`): `StartUTC 08:15:21.34Z`, `EndUTC 08:28:44.71Z BootstrapExit 0` (803 s), `BOOTSTRAP quick
  0 failures`, smoke 9/0 in both generations; `boot116b-compare.command` ([output](records/boot116b-compare.txt)): 248 paths,
  245 raw-equal, the three PE images at the 4 stamp bytes; working tool `605C16B1…`, G2 l2trans `04136FBF…`, driver.o
  `42416250…` both. A passing bootstrap of the package -- but its fixture had not run yet (the quick list does not run it).
- **The focus suite on boot116b's G2** (`tp116-suite.command`, 08:29:24Z; list `pins/focus116.tsv`: the twins forward_header
  and hidden_input, os_walk_values, the fixture; n and f): the twins and os_walk_values pass in both modes (every `gives 7`, every
  "the body … walked as the twin's"); the fixture is refused at translation: `free_name_chain.lm2:15:13: incompatible entry
  signature, frame=leaf` -- the unit's `int: quote 11` and the methods' `char: quote` gave leaf's one hidden input two types (in
  B1 a free input's type is still the closure's; B2 lifts this). `tp116-prepare-fix08.command` (char quote 11);
  `tp116-suite-fix01.command` copied the list into the wrong tests directory and read no list (a clone slip; kept);
  `tp116-suite-fix02.command` (stage cold-tp116's tests): `free_name_chain.lm2:11:13: the program has no method
  lm_stg_convert_char_int, the receiver of this conversion` -- a char returned as int needs a conversion receiver.
  `tp116-prepare-fix09.command` (int throughout); `tp116-suite-fix03.command` (08:32:33Z): the fixture builds in both modes and
  **exits 81 in both** (`outer() != 3`): the first real finding of the slice.
- **gdb on the native fixture** (`focus116d/free_name_chain-native/p-prod.exe 0 entry 7`, command files `gdb_resolve*.txt`,
  `gdb_value.txt`; the Bash tool loses `$registers` even in quotes, so gdb reads them from a file): breakpoints on
  `lmx_activation_push/pop/record_find` never fire -- gcc inlined them (`lmx_activation_record_find.part.0`); at
  `lmx_activation_resolve` (hit from `lmx_activation_resolve_input` ← `l2_m0` = leaf ← `l2_m0_tr` ← `lmx_call_prim_values`):
  text `71 75 6f 74 65` = "quote", len 5, `from` = mid's record (kind 2, nbind 1, binding "quote" length 5, storage = a cell
  holding int 3, type 2 = LMX_TYPE_INT), its parent = outer's record (kind 2, nbind 1), return value rax = 1 -- **the resolver is
  right and returns 3**. At `lmx_walk_value_number` in leaf's body the value record is `present 1 kind 1 type 2 number 0xb` = 11,
  reached through `lmx_walk_value_store_with_writer` -- the lexical default ran after the resolve. The generated wrapper
  `l2_m0_tr` (`fn: l2_m0_tr (owner, refs, nargs, dest, out, arena, code, lmx_input_values, …)`) projects the caller's arrays
  into its own: `lmx_walk_values_project(lmx_input_values, refs, nargs, 0U, l2_received, l2_received_refs, 1U)` and calls the
  method with `l2_received`/`l2_received_refs`: the record (pushed by `lmx_call_prim_values` with the caller's arrays) and the
  method's inputs were different arrays, so the resolved value went where the method never looked and its `l2_input_refs[0]`
  stayed 0 -- the default path.
- **The walked side**: the walked program names an own field's VALUE storage, not its cell (`l2_entry_slot: lmx_arena_ref_cell(
  l2_sc9, 0U)`, `l2_entry_slot[0]: lmx_int_new_profiled(…)`, `lmx_source_name_set(arena, l2_entry_slot[0], "quote", 5U)`), while
  the walker row's `slot` is the cell: the row lookup by the cell's name found nothing.
- **fix10** (`tp116-prepare-fix10.command`, 08:48:49Z; source-tp116 `DC4E8C62E5CBE8F9BEB3F6A522E9AABD0E6A640CC2307ADE0DAB4DE075D419B5`):
  `lmx_activation_resolve_input(arena, k, refs, values, width)` -- the native prologue hands `l2_input_refs`, `l2_input_values`
  and its declared width (`lm_compiler_emit_native_input_entry`), and the record takes them as its inputs (for this resolution
  and for the callees' lookups); the walker and the self-check pass none (the record's stand). The walker-row lookup tries the
  cell's content after the cell. (An export's signature change in a header=1 module touches no declaration text of
  tools/build.lm2: tool116 stays G0.) `tp116-rt-fix06.command` (rt116g): exit 0, driver.o `BCC59C4C…`. Relink of the two fixture
  programs built by boot116b's G2 against rt116g's driver.o: **forced exits 0 (60 checks)** -- the walker path end to end; native
  still 81, as it must: its `p.o` was emitted by the old frontend with the two-argument resolve call, a new frontend is needed.
- **boot116c** (`boot116c-prepare.command` 08:50:23Z, stage cold-boot116c = source-tp116 `DC4E8C62…`; `boot116c-quick.command`
  through `boot116c-detached.command`): `StartUTC 08:50:24.73Z`, `EndUTC 09:03:40.99Z BootstrapExit 0` (796 s), `BOOTSTRAP quick 0 failures`,
  smoke 9/0 in both generations, every program with the driver's 60 checks; G1 l2trans `F60F8C9F…`, G2 l2trans `25EDB0D0…`;
  driver.o `BCC59C4C…` in both; working `quick116c/lmxtool.exe` **`18C898AC3D86869E781A6DFEE8BFFF20C9892DF572D9443D23BBA280CC212BA3`** (G2's).
  `boot116c-compare.command` ([output](records/boot116c-compare.txt)): 248 receipt paths, 245 raw-equal, the PE images at the 4
  stamp bytes only. The fixed point G1 = G2 holds.
- **The focus suite on boot116c's G2** (`tp116-suite-fix04.command`): `SUITE 4 rows, 0 failures` (09:04:14-31Z; tool 18C898AC, fe 25EDB0D0, prod BCC59C4C): the twins, os_walk_values and the fixture pass in both modes -- free_name_chain native and forced `root0: gives 7`, `root1: gives 7` (60 and 64 checks); the record's terminal also echoed the first run's failures file (a path slip of the clone), the suite's own summary line is the result.

## The landing: source-tp116 is the selfbuild package

By the rule of Codex's answer to FABLE-RESULT-S3 (the whole tested set after an actual quick PASS; the ordinary
verify/stage-copy/manifest/verify route; only the actually changed inputs and the manifest in the commit) after boot116c and the
focus suite on its G2: `pins/land254.command` ([record](records/land254.command), [terminal](records/land254.terminal.txt); the
land253 record with the names, the manifest hash `DC4E8C62…`, the tool, and two steps more -- the variant's `inputs.list` of
160 lines is copied into `selfbuild/` by a one-line manifest (`land254-inputs-list.list` → `land254-inputs-list.sha256`) before
the package manifest is rewritten) with the promoted working tool of boot116c (G2's, `18C898AC…`), 09:06:17-19Z: the two
subsets `land254-g1/g2-consumed-sources.sha256` (65 lines each, identical, every line in `source-tp116.sha256`; 306 consumed
inputs in each generation), then

| step | command | result |
|---|---|---|
| 01 | `verify P/pins/source-tp116.sha256 P/cold-boot116c` | exit 0 (160 files) |
| 02 | `stage-copy P/pins/source-tp116.sha256 P/cold-boot116c R/selfbuild` | exit 0 (160 files) |
| 03 | `manifest P/pins/land254-inputs-list.list P/variants/tp116 P/pins/land254-inputs-list.sha256` | exit 0 (1 file) |
| 04 | `stage-copy P/pins/land254-inputs-list.sha256 P/variants/tp116 R/selfbuild` | exit 0 (inputs.list) |
| 05 | `manifest R/selfbuild/inputs.list R/selfbuild R/selfbuild/inputs.sha256` | exit 0 (160 files) |
| 06 | `verify R/selfbuild/inputs.sha256 R/selfbuild` | exit 0 (160 files) |
| 07 | `verify P/pins/land254-g1-consumed-sources.sha256 R/selfbuild` | exit 0 (65 files) |
| 08 | `verify P/pins/land254-g2-consumed-sources.sha256 R/selfbuild` | exit 0 (65 files) |

`selfbuild/inputs.sha256` is byte-equal to `source-tp116.sha256` and to `source-boot116c.sha256`
(`DC4E8C62E5CBE8F9BEB3F6A522E9AABD0E6A640CC2307ADE0DAB4DE075D419B5`); `selfbuild/inputs.list` is 160 lines
(`A4415DAA4BAB1701F3398C7EE8B36A95EB58DCF76C1DFDC97FF2FFED92F6B89C`: 65 source, 34 tool, 61 test files; the one new line
`tests/dyn/free_name_chain.lm2`). Git sees 12 changed paths under `selfbuild/`: `inputs.list`, `inputs.sha256`, the 9 changed
inputs of tp116 -- three kernel modules (`lmx_arena`, `lmx_call`, `lmx_walk_values`), `l2_driver`, three frontend modules
(`l2_frontend_lower`, `_core`, `_emit`), `tools/build.lm2` (byte for byte the text tool116 compiled), `tests/full-suite.tsv`
(the fixture's row) -- and the new `tests/dyn/`. `selfbuild/README.md` names the package, the G0 (tool116 `E8AD9AA2…`), the
previous frontend (boot115f's G2 `EBCADAE2…`), the promoted working tool and the acceptance boundary (quick + the focus suite,
not FULL). Evidence: `evidence.list` (246 originals under P: the tp116/boot116/boot116b/boot116c records, terminals and logs,
the variant sources and the fixture, the self-check outputs, the runtime-check attempts' logs, tool116, the previous frontend and
working tool, boot116c's receipts and binaries, the suite receipts) and `evidence.sha256` (`docs254.command`: manifest + verify),
LF copies of the text records in `records/` (208 files). Design document revisions 10-12; book :727/:729/:777/:779;
`steps/current.md` slice-254 entry; `build_performance_profile_from_fable.md` tp116 section.

Not in this slice (B2, next): the closure (`dyn_close`/`dyn_step`/`dyk_close`/…) and the static type of a free input (one
type per name; `incompatible entry signature` for two), the static `ty` comparison in `lmx_walk_values_arg_place`, the
runtime-typed transport and emission of free inputs without a static witness (every consumer through the kernel's value
functions), the separating witness (caller-only binding through forwarders, the same callee with another admissible actual type,
write/actual/return, native↔walker). C only after B2.

Repaired before the evidence was taken: the comment lines of `tp116-prepare-fix04..fix10.command` (inserted with sed, whose
backslash-c and backslash-l escapes turned the spellings of a path actual and two field paths into a control byte and two
lowercased words) now read `record` + backslash + `code`, `slot`/`binding` + backslash + `length`; the records' commands are
untouched and had run before the repair (the docs gate refuses control bytes in tracked text, as slice 253's docs check did).
