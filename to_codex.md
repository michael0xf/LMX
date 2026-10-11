# to_codex: передача дел от `fable_pc` Codex (2026-10-11)

Писал `fable_pc` (Claude Code, Fable 5.1, на машине автора) — единственный writer/build ядра с передачи
`to_fable.md` (2026-10-10, 15:00 по Сан-Паулу) и директивы Codex CODEX-FABLE-OWNERSHIP-20261011-085231. По указанию
автора 2026-10-11 («напиши файл to_codex по передаче дел и заканчивай текущий шаг») текущий шаг — срез R6-2 (4) —
закончен коммитом `b4af3447`, и **слот единственного writer/build освобождён в пользу Codex** вместе со STATUS
FABLE-STATUS-20261011-27. `fable_pc` больше не кодит, не собирает и не запускает гейты — только отвечает на вопросы.
Это рабочая передача, не спецификация: нормы — `docs/`, план — `next_core_tasks_v2.md`, словарь —
`next_core_tasks_dictionary_v2.md`, карта ядра — `CORE_L2_L3_v2.md`, рабочие указания — `steps/current.md`, дефекты —
`steps/defects.md`, тикеты — `steps/tickets/`.

## 0. Вход

1. `AGENTS.md` → `READ.ME` → `steps/current.md` → план v2 §1 (протокол перезапуска и приёмки).
2. Тикет [critical_general_receiver_routes_bug](steps/tickets/critical_general_receiver_routes_bug.md) (OPEN) и его
   перепись [steps/receiver-routes-census-20261010.md](steps/receiver-routes-census-20261010.md): разделы «Slice RR1»,
   «Slice R6», «Slice R6-2 (1)», «(3)», «(1b)», «(4)», «Slice R5 — design before code», «R5-1», «R5-3a», «R5-2»,
   «R5-3b», «R5-4» и заключительный «The general rule the implementation has to meet». Каждый раздел называет
   замер до кода, построенное, свидетелей, ворота (OutDir) и мутантов.
3. Тикет [critical_qualifier_receivers_bug](steps/tickets/critical_qualifier_receivers_bug.md) и его дизайн
   [steps/qualifier-receivers-20261010.md](steps/qualifier-receivers-20261010.md) (срезы RR2a–RR2f, 2026-10-10/11).
4. Записи дефектов моих срезов в `steps/defects.md`: MERGE-REFERENCE-TO-OPERAND (OPEN, ядро), OCTAL-LITERAL-NO-PRODUCER
   (OPEN, пробел производителя), MERGE-BODY-SYNTHETIC-UNIT-CHILD (FIXED, 1b), NS-REF-FIELD-VALUE-DROPPED (снят — не
   дефект), COPIER-POINTEE-SHARED (FIXED, 2026-10-10).
5. Мои STATUS-сообщения Codex (FABLE-STATUS-20261011-01…-27) и ответы Codex — в транскрипте почтальона
   `C:\Users\mtkra\.claude\projects\C--Nyasha-Planet-LMX\65338a6e-5029-460e-b48e-0e0fa7685b54.jsonl`; тексты STATUS
   -23…-27 продублированы в `build/fable_handoff_20261011/messages/` (каталог не отслеживается git).

## 1. Git

- Контрольная точка кода и записей: `b4af34475dc82e4f61f6f6e7c1b88bd584179d23` на `main`, отправлена обычным push; `HEAD = origin/main` на
  момент отправки. Этот файл и два файла вопросов автору коммитятся следом отдельным документным коммитом.
- Коммит `b4af3447` меняет 3 пути (`dev/l2src_sandbox/l2trans.lm1`, `tools/l2_harness.ps1`, заголовок
  `dev/l2src_sandbox/tests/unit_merge_body_ref_value_refused.lm2`) и добавляет 7 фикстур
  (`unit_merge_body_ref_zero`, `unit_ns_ref_statement`, `unit_ns_ref_var`, `unit_ns_ref_zero`,
  `unit_ns_ref_other_refused`, `unit_ns_ref_num_refused`, `unit_merge_ref_cooperand_refused`), 5 записей
  (`steps/receiver-routes-census-20261010.md`, `steps/defects.md`, `next_core_tasks_v2.md`, `steps/current.md`,
  тикет) и 3 файла вопросов (`LMX_blog/q/current/README.md`, `reference-candidate-timing.md`,
  `merge-result-admitted-to-operands.md`).
- WIP нет, staged нет. Неотслеживаемый `l2_driver_launch.err` — артефакт драйвера, не коммитится никогда (не
  удалять, не добавлять). Мои процессы: ни одного (цепочка ворот 04 завершена, фоновых задач нет).
- Все 48 моих коммитов 2026-10-10/11 — `git log --since="2026-10-10 14:00"`; каждый срез — один коммит с проверенными
  байтами (плюс один коммит-довесок `478f5ee3`: фикстура, забытая в списке путей среза (1); с тех пор пути коммита
  берутся из `git status` и проверяются по списку разрешённых).

## 2. Проверенные байты и доказательства среза R6-2 (4)

- `dev/l2src_sandbox/l2trans.lm1`: SHA256 `7AE652014FE2F60E5973EECC96A9D6051D08815F69603A0CA392633EB8D2F5E2`; `tools/l2_harness.ps1`: SHA256 `5B022BF45BB45CAFF44EE8176977D6D69939F2B8CF717B67EFDFC42966E73481`;
  ядро (`dev/l2src_sandbox/lmx_*.lm1`) в срезах R6-2 не менялось; `bin/l1trans.exe` SHA256 `601d350e853ca16a…`.
- Ворота среза (цепочка `gates_r6_2_04.ps1`: ядро → две половины сфокусированного harness над списком
  `focus_r6_2d.txt` (1703 строки) → L3): ядро `build/l2src/fable_r6_2_kernel_04` GREEN (300 целей, 0 отказов); harness `build/l2_harness/fable_r6_2_focus_04a` 834 OK / 21 FAIL из 855 целей и `fable_r6_2_focus_04b` 834 OK / 20 FAIL из 854 (staged-транслятор — байты дерева, blob 8602e3aa); L3 `build/l3/fable_r6_2_l3_04` — все 11 наборов ok, бюджет типов ok (4 юнита). Сравнение с цепочкой 03 по тождеству строк и исходу: добавлено 11 строк (новые свидетели, все OK), удалено 0, FAIL→OK 0, OK→FAIL 0, 41 известная красная строка без изменения деталей (`compare_summary.py` над склеенными summary половин: `build/fable_handoff_20261011/summaries/r6_2_03_merged_summary.txt` и `r6_2_04_merged_summary.txt`).
- Мутанты на staged-трансляторе половины A: M1 (типизированная пустота не исключена — `l2_merge_body_typed_null` отвечает 0): `unit_merge_body_ref_zero` отказан 10:9 native и walk (строка ждёт прогона); M2 (отказ у merge снят): `unit_merge_ref_cooperand_refused` транслируется и падает в ядре — native инвариант, walked INVALID (строка ждёт отказа); контроль на реальном трансляторе — как закреплено.
- Проверка охвата (translation sweep, диагностика на изолированных байтах): 96 фикстур с типизированным кандидатом
  ссылки на любой глубине и 66 фикстур со строкой связывания и merge транслируются на `2a711a13` и на байтах среза
  одинаково (вывод и первая диагностика).
- Полный прогон harness (план, пункт 8 и 8a) в моих срезах не запускался — по указанию хоста «start it again only when
  asked»; каждая цепочка сравнивалась с предыдущей по тождеству строк (additions / removals / FAIL→OK / OK→FAIL явно).

## 3. Линия задач тикета critical_general_receiver_routes_bug (по кластерам переписи)

- Кластер 1 (merge в хвосте решает роль головы): закрыт срезом RR1 (`511c9ae4`).
- Кластер 2 (квалификаторы — одна статическая цепочка): срезы RR2a–RR2f (2026-10-10/11); открыты вопросы автору
  Q1 ([eternal-without-const](LMX_blog/q/current/eternal-without-const.md)) и Q3
  ([runtime-immutable-shared-pools](LMX_blog/q/current/runtime-immutable-shared-pools.md)); цепочка над существующим
  значением остаётся located-пределом (RR2e).
- Кластер 3 (`[]: []:` — не фиксированная двухуровневая форма): R5-1, R5-3a, R5-2, N1, N2, R5-3b, поправка
  flat/nested (`1d8ffe4d`: `a[i][j]` — плоский прямоугольный индекс по страйдам источника, не шаги `a[i]\[j]`), R5-4
  (мёртвые маршруты) — закрыты. OPEN: прямоугольный этап — обязательный свидетель `matrix[i][j]` над Array,
  построенным источником (R5-3b/R5-4), и OCTAL-LITERAL-NO-PRODUCER (пять `unit_own_array_*` — обязательные позитивы;
  located-предел `l2trans.lm1` у literal-producer).
- Кластер 4 (тело результата merge): R6 (`4899a173`), R6-2 (1) `6d6c003e`+`478f5ee3`, (3) `433f3da7`, (1b) `2a711a13`,
  (4) `b4af3447`; задача (2) (поле-ссылка, вложенная Structure) вышла из (1). OPEN: (5) — выбор тела операндом по
  §13 (постановление Codex CODEX-MERGE-CODE-20261011-205155: неименованные исполнимые операторы позднего операнда
  ЗАМЕНЯЮТ операторы модели целым телом; побеждает последний операнд с операторами; дописанное тело только с данными
  сохраняет операторы модели; `native` — по §13); до него located-пределы тела merge: оператор тела (в том числе
  вычисляемое объявление и поле-ссылка с кандидатом, кроме типизированной пустоты `0`), поле-callable, удержанное
  содержимое. Свидетели (5): код только модели, код дописанного тела, тело только с данными — native и walked.
- Кластер 5 (структурный операнд merge): RR2c-1 проложил типизированное объявление-операнд одним маршрутом; голое
  поле `v: 9` (именованный аргумент автора), группа из двух и анонимный операнд T7 — located-пределы.

## 4. Открытые вопросы автору (файлы `LMX_blog/q/current/`, переданы через Codex)

1. Q1 `eternal-without-const.md` (RR2, 2026-10-10) — удерживает ли merge ветвь `independent: immutable:` без `const`.
2. Q3 `runtime-immutable-shared-pools.md` (RR2f, 2026-10-11) — RuntimeImmutable над существующим деревом в общих пулах
   (двухступенчатый, формулировка Codex FABLE-Q-RUNTIME-IMMUTABLE-MARK-20261011).
3. `reference-candidate-timing.md` (R6-2 (4), 2026-10-11) — поле-ссылка тела Structure с кандидатом-Structure:
   связывание при построении (`p: Model` сегодня) или при выполнении тела (`@: Model p Model` сегодня); §12 приравнивает
   формы. До ответа транслятор оставлен как есть.
4. `merge-result-admitted-to-operands.md` (R6-2 (4), 2026-10-11) — что именует скопированная ссылка на со-операнд и
   допущен ли результат к моделям поглощённых операндов (дефект ядра MERGE-REFERENCE-TO-OPERAND).

## 5. Дефект ядра MERGE-REFERENCE-TO-OPERAND — что заготовлено

Запись: `steps/defects.md#merge-reference-to-operand`; вопрос автору — п. 4.4. Заготовки (каталог не отслеживается
git): `build/fable_handoff_20261011/kernel/edit_kernel_absorb.py` — проход `lmx_copy_absorb` по ячейкам-ссылкам,
правка комментариев контракта (`lmx_graph_copy_owned.h.lm1`, `lmx_merge_owned.lm1`, `lmx_merge_owned.h.lm1`) и
случай 1c self-test `tests/lmx_merge_selftest.lm1` (ссылка держателя на модель: скопированная ячейка именует результат;
контроль на старом ядре красный, исправленное зелёное — 117 проверок); `probe_kernel.sh` — сборка пробного ядра
(драйвер + self-test) в пробном staging; `evidence/` — выводы контроля/исправления и падений на живых байтах. **Не
отправлять один проход absorb**: без чтения требования/ребра для поглощённой модели и обхода он превращает падение в
молчаливое неверное чтение (`R\p\v` → 81). Нужны вместе: absorb, записи соответствия результата операндам (или иное
решение автора), `l2_model_inst_selected`/ребро K01 для поглощённой модели, walked read; затем снять located-отказ
`l2_mrs_operand_reference` и перевести `unit_merge_ref_cooperand_refused` в позитив.

## 6. Как я работал (инструменты в `build/fable_handoff_20261011/scripts/`)

- Пробы — только на изолированных байтах: staging копируется из stamp предыдущей цепочки (`src/`, `headers/`,
  `gen/*.o`), живой транслятор копируется внутрь, правка применяется к копии (`edit_r6_2_*.py`: точные якоря, каждая
  правка с assert), сборка флагами harness (`probe_r6_2*.sh build|run|l1`); живое дерево не трогается до `apply`.
  `probe_live.sh` — тот же бег на байтах последней зелёной цепочки для сравнения «было/стало».
- Фикстуры и строки harness пишет один скрипт (`write_fixtures_r6_2_*.py`, режим `--probe DIR` для проб); Needle
  измеряется пробой, не вычисляется; заголовок фикстуры меняется только с сохранением числа строк; апострофа в Needle
  нет; PSParser после правки harness; LF везде.
- Ворота — цепочкой с абсолютными путями (`gates_r6_2_0N.ps1`): ядро `build_l2src.ps1 -Run -OutDir … -KeepAll`, две
  половины `l2_harness.ps1 -OutDir … -KeepAll -OnlyFixture <половина списка>`, `python tools/run_l3_selftest.py
  --output <абс. каталог>`; один тяжёлый gcc в момент времени; сравнение `compare_summary.py OLD NEW` над
  склеенными summary половин; `row_args.py NAME` — Args строки (первый аргумент драйвера — число квалифицированных
  корней; проба с чужими Args даёт ложный FAIL).
- Мутанты (`mutant_r6_2*.sh <OutDir половины A>`) — на staged-трансляторе ворот, каждый должен покраснить своего
  свидетеля; сравнивается диагностика, не код выхода.
- Запись и коммит — `fill_r6_2*.py` (плейсхолдеры `@@…@@` обязаны исчезнуть), `commit_r6_2*.sh` (пути из `git
  status` против списка разрешённых, `git diff --check`, `check_docs.py`, обычный push, `HEAD = origin/main`,
  проверка, что отслеживаемых изменений не осталось).
- Кернел-правка — свой staging: заголовки `.h.lm1` → `headers/l2src/*.lm1.h` перегенерировать все тронутые,
  драйвер `l2_eternal_driver.lm1` → `gen/l2_eternal_driver.o` пересобрать флагами ядра; self-test собирать строкой
  гейта (`.selftest.o` + `obj/l2_libc.o` + `obj/lmx_source_names.o`); перед гейтом grep self-tests на опровергаемое
  правило.

## 7. Рекомендуемый следующий шаг

Дизайн среза (5) по §13 — общий маршрут выбора кода тела результата merge (операторы позднего операнда заменяют
операторы модели целым телом; `native` по §13), с тремя свидетелями native/walked; одновременно он снимает
located-пределы тела merge (оператор тела, вычисляемое объявление, поле-ссылка с кандидатом). Затем прямоугольный
этап R5 (`matrix[i][j]`). Срез ядра по MERGE-REFERENCE-TO-OPERAND — после ответа автора на п. 4.4 (или решения Codex по
книге); Q1/Q3 — по ответам автора.

## 8. Директивы Codex, действовавшие на момент передачи

CODEX-FABLE-OWNERSHIP-20261011-085231 (слот у fable_pc; каждый срез — запись, коммит/push проверенных байтов,
следующий выполнимый пункт по зависимостям — снимается этой передачей), CODEX-OCTAL-GAP-20261011-202442 (OCTAL —
пробел производителя, OPEN, пять обязательных позитивов, без вопроса автору), CODEX-MERGE-CODE-20261011-205155
(постановление по (5) и требование убрать синтезированное дитя юнита — выполнено срезом (1b)),
CODEX-REF-INIT-20261011-211822 (поправка дизайна (4): без правила «только именованная Structure»; типизированная
пустота; `@: b A` после implements; вычисляемый кандидат — оператор тела — замер показал, что это уже построено).
