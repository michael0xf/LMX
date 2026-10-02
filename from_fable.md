# from_fable: передача следующему агенту (2026-10-01, вечер)

> Archive note — Codex, 2026-10-02: tracked at the author's request to preserve all documentation. The handoff below records its author's earlier session, not current ownership, acceptance or a new instruction. Unfilled checkpoint placeholders remain unverified; local paths are historical evidence locations. Use [the v2 queue](next_core_tasks_v2.md) and [current instructions](steps/current.md) for work. The later [address correction](steps/tickets/critical_pointer_to_struct_bug.md) and [reference-application refactoring](steps/tickets/structure_reference_application_refactor.md) supersede any earlier descriptor-address exemption or explicit-dereference-only call policy below. The original handoff text is retained.

Писал `fable` (Claude Code, Fable 5.1), продолжая очередь deepseek по плану v2. Это рабочая передача,
не спецификация: нормы — в `docs/`, план — `next_core_tasks_v2.md`, словарь — `next_core_tasks_dictionary_v2.md`,
карта ядра — `CORE_L2_L3_v2.md`, инструкция переноса — `L2_L3_CODING_INSTRUCTION.md`.

## 0. Вход

1. `AGENTS.md` → `READ.ME` → `steps/current.md` (абзац «Возобновление 2026-10-01») → план v2 §1 (протокол) и §3.
2. `git fetch origin main; git log --oneline -10 origin/main`. Работа идёт в `main`, без веток; автор читает
   этот checkout (`C:\Nyasha_Planet\LMX`) — после push он уже на месте.
3. Заметки среза: `steps/k01-selector-identity-20261001.md`, `steps/k02-merge-values-20261001.md`,
   `steps/k03-head-roles-20261001.md`; дефекты — `steps/defects.md` (правило автора: нашёл — записал — чинишь сразу).
4. Вопросы автору задаёт Codex: `SendMessage` в сессию `lmx_uds` по шаблону
   «From <you>. Request DS-CODEX-NNN. Forward to Codex through codex_inbound.py. Question: … Return Codex's
   substantive reply to <you> through native SendMessage, preserving request ID DS-CODEX-NNN. This is communication
   only; do not resume project work.» Номера последовательные (последний: DS-CODEX-004). Ответ — финальный, не
   подтверждать (ACK запрещён); ответ записывать в заметку среза (пример — `k02-merge-values-20261001.md` §4).
   Спрашивать только когда нормы действительно противоречат друг другу; обычно общее правило уже решает
   (`READ.ME`, «Общее правило построения спецификаций»).

## 1. Что посажено сегодня (все — bounded improvements на раскрытом красном baseline, не clean-kernel checkpoint)

| Срез | Коммит | Суть | Полный гейт |
| --- | --- | --- | --- |
| K01a–e | `65e4cf4`…(deepseek) | селектор вхождения через допуск/доступ, growable used-path | — |
| K02a, K02b | `32836cb`, `6e5f84b` | merge проецирует фактический операнд; формал как операнд merge | — |
| K03a | `7f54dfb` | отказ арности разрешённой Structure вместо «not built yet» (Q59) | 49/1121 → далее |
| K03b | `e5186f2` | `(T: v)` и `(@: T v)` — один ссылочный транспорт; фикстура «вызов value-формала» была неверна | 47/1122 |
| K02c | `4b2035c` | merge-результат единицы — обычный скрытый вход (caller → inherited → lexical); tagged-схема как метаданные; ядро: ADMIT_AS/OF вычисляют кадр на месте модели | 47/1128; kernel 286/286; L3 11 ok |
| K03c | `K03C_SHA` | вложенная неизвестная голова — вложенная Structure (поле kind 2); хвост из одного вызова метода — тело (Q58); 10 строк раздела C без маски | K03C_FULL |

Остаток красных строк полного гейта: 47 до K03c (список — `summary.txt` любого полного прогона, `^FAIL`).
Их категории описаны в `steps/generated-diagnostic-migration-20260930.md` (A — маскированные отрицательные,
B — raw-C/строковые, D — производственные пробелы); раздел C (10 строк) закрыт срезом K03c.

## 2. Как работать (что реально сработало)

- Один writer/build на машине: один конвейер gcc (`cc1` на сгенерированном C — 100–350 МБ). Гейты —
  последовательно; тяжёлые запуски — в фоне с логом в свой каталог `build/<agent>_<slice>/`.
- Фокусный гейт: `tools/l2_harness.ps1 -Translator C:/Nyasha_Planet/LMX/build/opus_wt/bin/l1trans.exe
  -OnlyFixture @('row1','row2',…) -KeepAll -OutDir build/l2_harness/<tag>`; только зарегистрированные строки
  (иначе `unknown fixture`). Полный — без `-OnlyFixture`. Kernel: `tools/build_l2src.ps1 -Run -KeepAll -OutDir
  build/l2src/<tag>` (только если трогал `dev/l2src_sandbox/lmx_*.lm1`). L3: `python tools/run_l3_selftest.py`.
- Сравнивать отказы по точному ID и диагностике: `python build/fable_k03b/compare_full.py <before summary>
  <after summary>` (printed: newly failing / newly passing / changed diagnostics).
- Байты: `git hash-object` исходника до гейта и перед `git add`; staged blob в `summary.txt` должен совпасть с
  коммитом. Мутант применять к `dev/l2src_sandbox/…`, после прогона восстанавливать и ПЕЧАТАТЬ хэш.
- Пробный транслятор без харнесса: скопировать `src/`, `headers/`, `gen/l2_libc.o` из любого `-KeepAll`
  прогона в свой stage, положить `l2trans.lm1` в `stage/src/l2src/`, `l1trans l2src/l2trans.lm1 gen/l2trans.c`
  (cwd `stage/src`), gcc по строке из `logs/build.l2trans.link.log`. Образец — `build/fable_k02c/stage`.
- Патчи L1 — только скриптами с raw-строками `r'''…'''` (файлом через Write, не heredoc): текст с `\` в
  обычных строках Python ломается молча или с `unicodeescape`. Образцы: `build/fable_k02c/patch_*.py`.
- Перед починкой строки из retained-списка: `grep -rn <fixture> steps/ docs/` — её ожидание может быть уже
  признано неверным (так было с `unit_value_formal_call_refused`: два фокусных прогона впустую).
- Свидетель, читающий поле корня после вызова: рабочее значение корня не перечитывается после вызова (§7b),
  запись через путь из callee видна только через ячейку — читать `node\field` из метода (K03c, Q58-свидетель).
- Кадры обходчика строятся в прологе единицы; указатель модели там «запекается». Значение, построенное
  позже (merge-результат), моделью быть не может — ядро теперь вычисляет кадр на месте модели
  (`lmx_walk_model_operand`, K02c). Любая новая «модель» в обходчике — спросить «существует ли на этапе
  сборки кадров?».
- Коммит: явный список путей (`git add <paths>`), сообщение с гейтами и хэшами, `git push origin main`;
  документы среза — в том же коммите. `python tools/check_docs.py`, `tools/gate_p0_header.ps1 -Root .`,
  `git diff --check` — перед каждым коммитом.

## 3. Что дальше (по зависимостям плана v2)

1. **K03 — остаток** (`steps/k03-head-roles-20261001.md`, «Remaining K03 acceptance items»): строки «explicit
   ref assignment versus `\ref` call» и «declarations without return/trailer»; снятие распознавателей
   `Model: fresh` / `T: b c` только после переноса их потребителей (сейчас `w: merge Model` в методе —
   `unresolved name merge`: сначала K02-пробел receiver-разрешения `copy: merge Model`).
2. **K04** (`steps/callable-actual-projection-20260930.md`, матрица свидетелей; дефекты
   CALLABLE-FORMAL-HIDDEN-CONTRACT, SUB-ACTUAL-REFERENCE-CLASSIFICATION, CAPTURED-STRUCTURE-ADDRESS-CATEGORY):
   начать с воспроизведения первой строки матрицы — `sub task` принимается формалом `(task: f)` по ссылке,
   счётчик не меняется при передаче и меняется один раз при явном вызове; `l2_check_value_call` сейчас
   запрещает любое callable без результата как значение. Воспроизвести ДО ремонта (план §1 п.4).
3. **K05** — LOCAL-REFERENCE-PATH-ROOT, NESTED-CALLABLE-OWN-FIELD-PATH, NAMED-PRIMITIVE-OMITTED-INITIALIZER.
4. Открытое из K02: runtime-выбираемый операнд merge (B на одном вызове, C на другом) — `k02-merge-values…` §2.
5. Остаток `l2_dslot`: метод, читающий ЧУЖУЮ помеченную own-строку по own-корню, получит `l2_dslot` без
   объявления (достигнуто только мутантом M1 среза K02c) — при первом реальном попадании добавить guard.

## 4. Вопросы автору, которых я НЕ задавал (решены общим правилом; при сомнении — через Codex)

- `Batch: put 7` (два атома) остаётся «значение вызова» (callable-first), `Batch: (put: 7)` / `Batch: put: 7`
  (один кадр) — определение с сохранённым оператором (Q58). Это различие формы P0, ответ автора по Q58 его
  по имени не трогал; если проявится в корпусе — спросить одним минимальным примером.

## 5. Мои каталоги (вне git)

`build/fable_k03b/` (пробы и мутант K03b, `compare_full.py`), `build/fable_k02c/` (stage пробного транслятора,
`kstage` ядра для одиночного селфтеста `one_selftest.sh`, патчи `patch_k02c.py`, `patch_k02c_kernel.py`,
`patch_k03c.py`, мутанты, черновики сообщений коммитов). Артефакты гейтов — `build/l2_harness/k0*_…`,
`build/l2src/k02c_kernel_20261001_01`.
