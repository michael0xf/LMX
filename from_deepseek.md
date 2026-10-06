# from_deepseek: передача следующему агенту (2026-10-02, утро)

> Archive note — Codex, 2026-10-02: tracked at the author's request to preserve all documentation. The handoff below records its author's earlier session, not current ownership, acceptance or a new instruction. Unfilled checkpoint placeholders remain unverified; local paths are historical evidence locations. Use [the v2 queue](next_core_tasks_v2.md) and [current instructions](steps/current.md) for work. The later [address correction](steps/tickets/critical_pointer_to_struct_bug.md) and [reference-application refactoring](steps/tickets/structure_reference_application_refactor.md) supersede any earlier descriptor-address exemption or explicit-dereference-only call policy below. The original handoff text is retained.

> Editorial correction — Codex, 2026-10-06: the K02d claim below that `b: merge A C` is a "book form" is withdrawn. The missing colon was a conversational typo, not a receiver exception. Correct applications are `b: merge: A C`, `b: merge(A C)` and equivalent explicit Frames. Delete the entire atomic application reconstruction subsystem under the [mandatory v2 stage](next_core_tasks_v2.md#explicit-receiver-frames); historical counts and checkpoints below do not validate that syntax. See the [author's clarification](LMX_blog/2026-10-06.md#explicit-receiver-frames).

Писал `deepseek`, продолжив очередь fable по плану v2. Это рабочая передача, не спецификация:
нормы — в `docs/`, план — `next_core_tasks_v2.md`, словарь — `next_core_tasks_dictionary_v2.md`,
карта ядра — `CORE_L2_L3_v2.md`, инструкция переноса — `L2_L3_CODING_INSTRUCTION.md`.
Передача fable лежит рядом в `from_fable.md` — она не устарела: её §2 (как работать) и §5
(каталоги fable) по-прежнему верны, ниже только дополнения и то, что изменилось.

## 0. Вход и текущее состояние

1. `AGENTS.md` → `READ.ME` → `steps/current.md` (абзац «Возобновление 2026-10-01») → план v2 §1 (протокол), §2–3.
2. `git fetch origin main; git log --oneline -8 origin/main`. Работа — в `main`, без веток; автор
   читает `C:\Nyasha_Planet\LMX`, после push всё уже на месте.
3. На момент передачи `main` = **`26a116b`**, дерево чистое; незакоммичены только сами передачи —
   `from_fable.md` и этот файл (оба — рабочие записи, не источники спецификации).
4. **Вопросы — только Codex через `lmx_uds`** (шаблон DS-CODEX-NNN в `from_fable.md` §0;
   последний номер — **DS-CODEX-004**, новых я не задавал). Автору вопросов не задавать.
   Ответы Codex — финальные, не подтверждать (ACK запрещён).

Что посажено в этой сессии (все — bounded improvements на раскрытом красном baseline):

| Срез | Коммит | Суть |
| --- | --- | --- |
| K02d | `b7e7a87` | книжная запись merge `b: merge A C` понижается; обе записи дают байт-идентичный L1 |
| K04a | `980971e` | `l2_cf_actual`: фактический аргумент callable-формала разрешается в контексте вызывающего (пересылка формала) |
| K04b | `adf3d71` | эквивалентные нульарные формы — один принимающий контракт (+ строка 4 матрицы) |
| K04c | `0c35920` | no-result callable в числовом аргументе — ссылка; + исправлен приём именованной Structure верхнего уровня за число |
| — | `26a116b` | запись дефекта `CALLABLE-FORMAL-STATEMENT-CALL-INTERNAL` (OPEN) с бисекцией |

Полный гейт после K04c: **36 of 1143** (`build/l2_harness/dk_k04c_full_02`; до сессии было 37 of
1132). Красные — те же удержанные, список — `^FAIL` в `summary.txt`. Ядро и L3 этой сессией не
тронуты (менялся только `l2trans.lm1`), поэтому kernel/L3 гейты не перезапускались.

## 1. Что дальше (по зависимостям плана)

1. **Первый пункт — `CALLABLE-FORMAL-STATEMENT-CALL-INTERNAL`** (`steps/defects.md`, анкер
   `#callable-formal-statement-call-internal`): операторная форма вызова не-возвращающего
   callable-формала `f()` даёт `internal: a refusal said nothing`. Минимальная программа — в записи
   дефекта; фаза измерена: `l2_emit_body` метода с формалом, а `l2_discard_run` для кадра `f()`
   возвращает 0 (span = 1 не > 1), поэтому оператор не идёт путём отбрасываемого выражения, где
   работающая ветка для голого атома callable (`l2_eval_discard` → `l2_emit_call` sel 2). Правило
   автора: найденный дефект чинится сразу; здесь он записан с готовым воспроизведением.
2. **Матрица K04, строки 5, 6, 8** (`steps/callable-actual-projection-20260930.md`): две
   непримитивные записи формала; фактический аргумент через own-связывание или путь при затеняющем
   формале; контроль глубины указателя. Строка 6 — естественное продолжение моего резолвера:
   `l2_cf_actual` знает пока только формал и unit-метод (плюс нульарный кадр); own-связывание и путь
   — следующая категория.
3. **Walker-половина проекции.** `l2_rw_call` принимает фактический аргумент callable-формала
   только как атом unit-метода; пересланный формал и нульарный кадр там отвергаются
   (`a callable input that is not a method's name`), поэтому такие строки идут ТОЛЬКО нативно. Не
   выдавать нативное прохождение за walked (см. план §1 п.4 и `from_fable.md` §2).
4. **`CALLABLE-FORMAL-HIDDEN-CONTRACT`** (`steps/defects.md`): скрытые входы вызываемого берутся по
   требуемому образцу, а не по фактически выбранному callable. Мой срез разрешает фактический
   аргумент, но не перестраивает свободные входы вызываемого.
5. **Остаток K03** — снятие распознавателей `Model: fresh` / `T: b c` после переноса потребителей
   (блокер `w: merge Model` снят срезом K02d); затем **K05**.

## 2. Как работать: что реально сработало в этой сессии

- **Один writer/build на машине.** Полный гейт ~25 мин, фокусный ~3–5 мин (доминирует пересборка
  `l2trans` — тот же cc1 ~100–350 МБ). Перед запуском проверять, что не идёт чужой gcc.
- **`-OutDir` у `l2_harness.ps1` обязан быть АБСОЛЮТНЫМ.** Относительный (`build/l2_harness/<tag>`,
  как в `from_fable.md` §2) склеивается со staged `src/`: ран создаёт `<stamp>/src/build/…` и падает
  с `Could not find a part of the path …` и `l2_harness RED: l2trans itself did not build`. После
  такого падения удалить и пустой `-OutDir`, и `<stage>/src/build`.
- **Фокусный гейт** (имена строк — стемы, `.lm2` необязателен):
  `& .\tools\l2_harness.ps1 -Translator C:/Nyasha_Planet/LMX/build/opus_wt/bin/l1trans.exe -OnlyFixture @('row1','row2') -KeepAll -OutDir C:/Nyasha_Planet/LMX/build/l2_harness/<tag>`.
  `-OnlyFixture` несовместим с provenance-режимами и сам по себе их не включает: если ран упал на
  «cannot be used with provenance modes» — значит скрипт вызван через `powershell -File` (аргументы
  идут литералами); вызывать из PowerShell напрямую `& .\tools\l2_harness.ps1 …`.
- **Пробный транслятор без харнесса** (быстрее полного гейта, для «что скажет транслятор на этой
  форме»): stage `build/deepseek_k03d/stage` (src/headers/gen/bin скопированы из любого `-KeepAll`
  рана; в `src/l2src/l2trans.lm1` кладётся рабочая копия). Сборка:
  `cp dev/l2src_sandbox/l2trans.lm1 build/deepseek_k03d/stage/src/l2src/l2trans.lm1`
  → `(cd build/deepseek_k03d/stage/src && /c/Nyasha_Planet/LMX/bin/l1trans.exe l2src/l2trans.lm1 …/gen/l2trans.c)`
  → gcc по строке из `build/l2_harness/<любой полный ран>/logs/build.l2trans.link.log`.
  Запуск пробы — из каталога стампа: `cd build/l2_harness/dk_k04c_full_02/src &&
  <stage>/bin/l2trans.exe <полный путь к пробе> convert.lm2 primitive.lm2 <выход>`; **предопределения
  (`convert.lm2`, `primitive.lm2`) обязательны**, иначе `int:`/`size_t:` дают
  «the program has no source table `primitive.description`».
- **P0-формы проверять `printTree`** (`build/fable127_part1b/printTree.exe`): так найдено, что
  `recv (task)` — `structure[atom "task"]`, а `recv (task())` и `recv (task: ())` — один
  `structure[frame head="task" body=empty]`.
- **Байтовая идентичность двух записей — сильное свидетельство** (`cmp` выходов L1): обе записи merge
  и обе нульарные формы дают байт-идентичный L1. Но там, где L1 расходится (обходчик), это надо
  печатать и объяснять, а не называть эквивалентностью — см. «наблюдённое расхождение» в
  `steps/k04-callable-actuals-20261001.md`.
- **Мутанты** — скрипты, применяющие ЧАСТЬ патча к коммитнутым байтам (`build/deepseek_k04/mutate_cf.py`,
  `build/deepseek_k03d/mutate_atom.py`): M0 = коммитнутые байты + новые строки (воспроизведение),
  M1/M2 = только одна половина правки (доказывает, что нужны обе). Перед прогоном печатать
  `git hash-object`, после — восстанавливать и печатать хэш снова.
- **Патчи L1 — только скриптами с raw-строками** (`r'''…'''`) через Write, не heredoc: heredoc ест
  `\n` и `\a` в `\as` (дважды ловил «unescaped newline in string literal» и битую запись). Образцы:
  `build/deepseek_k03d/patch_merge_atom.py`, `build/deepseek_k04/patch_cf_forward.py`,
  `build/deepseek_k04c/patch_sub_refusal.py`.
- **Стиль `---` (правило автора, 2026-10-01).** `---` нужен только там, где лестница снижается
  больше чем на один уровень; при снижении на один — как в Python. В теле `fn`/`sub` трейлером может
  быть `return`. Запись — `steps/current.md` (раздел о стиле тел) и дословно
  `LMX_blog/2026-10-01.md`; мои новые функции написаны уже по этому правилу.
- **Коммит**: явный список путей, сообщение с гейтами и хэшами, `git push origin main`; `check_docs.py`,
  `gate_p0_header.ps1 -Root .`, `git diff --check` — перед каждым коммитом. `l2src/` (стабильный
  двойник) не трогать, как и K01–K04c.

## 3. Урок этой сессии: общая правка типа сломала 55 фикстур

Первый вариант K04c учил `l2_colon_bound_ty` типизировать имя именованной Structure верхнего уровня
как ссылку — чтобы то же правило отказа срабатывало сразу везде. Это изменило смысл имени для
посторонних потребителей: `build/l2_harness/dk_k04c_full_01` дал **91 of 1141 с 55 новыми красными**
(`unit_named_struct_exec_*`, `unit_named_struct_call*`, `unit_walk_named_struct_*`, `unit_s7_*`,
`unit_ns_noclose_*`, …), каждая — `…: not supported yet` с `detail: atom=<имя Structure>`. Правка
откачена, правило применено в принимающем контракте (`l2_check_call`), измеренная цена записана в
заметке среза и в сообщении коммита. **Не повторять этот путь, не меняя сначала всех читателей
«неизвестного» ответа этой функции.**

## 4. Мои каталоги (вне git)

- `build/deepseek_k03d/` — K02d: `src/` (пробы форм merge), `patch_merge_atom.py`, `mutate_atom.py`,
  `stage/` (пробный транслятор), `rows_atom.py` (скрипт добавления строк в харнесс).
- `build/deepseek_k04/` — K04a: `patch_cf_forward.py`, `mutate_cf.py`, `rows_atom.py`-подобные скрипты
  строк, `src/r2_forward.lm2`, `commit_k04a.txt`.
- `build/deepseek_k04c/` — K04c: `patch_sub_refusal.py`, `patch_unit_struct_ref.py` (**откаченный
  общий вариант — хранить как запись, не применять**), `src/o1…o6*.lm2` (пробы отказов),
  `commit_k04c.txt`.
- `build/deepseek_k04d/` — дефект `f()`: `src/s1…s8*.lm2` (бисекция), `instrument*.py` (временные
  печати — **в рабочем дереве их больше нет**), сам транскрипт бисекции в записи дефекта.
- Стампы гейтов: `build/l2_harness/dk_atom_focus_02`, `dk_atom_full_01|02`, `dk_k04_focus_*`,
  `dk_k04_full_01`, `dk_k04b_*`, `dk_k04c_*`. В каждом `summary.txt` — вердикт, `logs/` — точные
  команды, `src/l2src/l2trans.lm1` — байты, которые гейт видел (сверять с `git hash-object`).

## 5. Что я НЕ сделал (честно)

- Не запускал kernel и L3 гейты: менялся только `l2trans.lm1`, ядро и L3 не тронуты.
- Не проверял walked-прохождение ни одной строки K04: все они нативные, и это сказано в заметках.
- Не закрывал `CALLABLE-FORMAL-HIDDEN-CONTRACT` и строки 5/6/8 матрицы.
- `from_fable.md` оставлен в рабочем дереве незакоммиченным (это передача, не источник); мой
  `from_deepseek.md` — так же.
