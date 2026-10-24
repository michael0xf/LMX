# LMX — передача работы Codex (Opus, 2026-10-24)

Передача по прямому поручению автора от **2026-10-24** (сессия Opus): «после текущего шага напиши to_codex.md
инструкцию по передаче дел, скажи to codex что передаешь ему работу и останавливайся». Текущий шаг — срез 194 —
опубликован: Verified194 `03c5a3ee`, запись его SHA `bc3edf80`. После него Opus остановлен (§2). **Codex — следующий
единственный writer/build.** Opus больше не пишет, не собирает и не ревьюит; к работе возвращается только по поручению
автора. Этот файл заменяет передачу fable_pc от 2026-10-19 (`git show 8e982196:to_codex.md`).

## 1. Как работать

**Цель и поручения автора.**
- Поручение автора (`CODEX-AUTHOR-CORE-CONTINUE-20261024T091641Z`): «Пусть Opus продолжает перенос оставшегося ядра на
  L3 + L2 небольшими шагами через короткий bootstrap, не ожидая ревью. Все вопросы — тебе. Не увлекайтесь тестами:
  цель — работающая самосборка». Теперь эту работу ведёт Codex.
- Порядок (`CODEX-OPUS-ROUTE185-20261024T085140Z`): над перенесённым слоем хранения — значения и граф, затем
  copy/merge/call, mail/Thread и walker (план §8).
- Оба транслятора пишутся на L3 ([LMX_blog/2026-10-24.md](LMX_blog/2026-10-24.md)): «Транслятор написанный на L3 (L2 в
  этой  конкретно задаче избыточен) печатает L1 строки сгенерированные из L2-L3 файла, потом второй транслятор, тоже
  написанный на L3, печатает Си-строки сгенерированные из L1 файла».
- Объявления арены и пулов генерирует код L3 рецепта строками L1, без нового механизма в L2
  (`CODEX-AUTHOR-L3-DECLARATIONS-20261024T054617Z`). Тем же путём, по решениям Codex
  (`CODEX-OPUS-HEADER-SCOPE184-20261024T074034Z`, маршруты 189/193/194), пишутся остальные заголовки ядра. Рукописные
  копии удаляются со стадии до генерации и запасным входом не служат (`CODEX-AUTHOR-L3-HEADER-REVIEW-20261024T062211Z`).
- `const char *` — существующие формы автора (`CODEX-AUTHOR-CONST-FORMS-20261024-A`). Среди формалов — со скобками,
  по `CODEX-OPUS-ROUTE194-AND-CONST-GROUP-20261024-A`: «Используй существующую скобочную форму const: (@: text char)
  (либо эквивалентную const: (text: @: char)) среди формалов». Отказ без скобок измерен в срезе 193
  (`steps/witnesses/fix193-20261024/const/`).

**Тесты и честность.**
- Приоритет автора 2026-10-23 (`to_opus.md` §1): работающий проект и самосборка; широкие проверки — после неё.
  Минимальный сквозной результат текущего изменения достаточен.
- Это не разрешает выдавать RED за PASS, прятать известный RED/UNSUPPORTED или называть его ожидаемым отказом, менять
  норму ради удобства. Каждая пропущенная широкая проверка — долг LATER (§3).
- Новых тестов и служебных программ на L1/C/Python/PowerShell не писать и не прятать прежний runner в shell или
  строку (автор 2026-10-22, `to_opus.md` §2). Существующие поддерживаемые тесты и скрипты переносятся на L2/L3 без
  запасного маршрута к старым (`CODEX-AUTHOR-L2L3-NO-FALLBACK-20261022T223831Z`, S8.5).
- Проверки — командами `lmxtool`, программами L2 и текстовыми командами (diff, sed, perl, командные файлы gdb).

**Решения и вопросы.**
- Opus задавал все вопросы проекта Codex. Теперь их решает Codex сам; ревью постфактум нет, пока автор его не
  назначит.
- Если две утверждённые нормы противоречат друг другу: минимальная программа, обе нормы, измеренное поведение — вопрос
  автору в `LMX_blog/q/current/`. Останавливается только зависимый срез. Исключений по имени, типу, форме или месту в
  трансляторе нет (READ.ME, `L2_L3_CODING_INSTRUCTION.md`).
- Пауза goal Codex и напоминания `lmx-goal` — решение автора. Codex её не снимает
  (`CODEX-OPUS-REVIEW194-20261024-03C5A3EE`).

**Что читать.**
- По порядку: [AGENTS.md](AGENTS.md) → [READ.ME](READ.ME) → верх [steps/current.md](steps/current.md) → план
  [v3](next_core_tasks_v3.md) §§0/3/8/8a → [L2_L3_CODING_INSTRUCTION.md](L2_L3_CODING_INSTRUCTION.md) → L2 §17/§20/§21.
- Из [`to_opus.md`](to_opus.md) (передача 2026-10-22) в силе:
  - §1 — приоритет 2026-10-23, граница честности, коммиты в main без разрешения, правило прерванных процессов;
  - пункты-поручения автора §2 (строки 27–45): обходчик по живому дереву, `os` через общий конвейер без native-подмены
    и без позднего `#ifdef`, R169-1 (одно закрытое разрешение callee), общий допуск сигнатур, имена C;
  - остаток §5 и правила ресурсов и публикации §6.

  Точка старта §2 (168/169), §3–§4, маршрут вопросов через lmx_uds и фразы «Codex остановлен / консультант» — история.
- Цитаты автора: в `LMX_blog/` только технические ответы автора, дословно, с датой и источником вне цитаты
  (AGENTS.md, READ.ME); организационное — в `steps/`.
- Нормы правятся в первичных источниках, генерируемые документы руками не правятся: `provenance/semantics-book.md` →
  `python tools/build_semantics.py`, `provenance/grammar.json` → `python tools/build_docs.py`. Весь репозиторий — LF.

## 2. Точная точка старта

- **Репозиторий.** `C:\Nyasha_Planet\LMX`, ветка `main`: Verified194 `03c5a3ee`, запись `bc3edf80`, затем коммит этой
  передачи. Всё запушено, `origin/main` совпадает.
- **Чужие файлы.** Tracked tree чист; два чужих untracked: корневой `l2_driver_launch.err` и
  `steps/witnesses/used-scope-20261020/reference-producer117.patch`.
  - Первый basename не читать, не хешировать, не копировать и не стейджить нигде; в списках и циклах исключать
    (`ls -I`, `tar --exclude`, `diff --exclude`, `find ! -name`). **Драйвер каждой программы L2, `lmxtool` тоже,
    создаёт или усекает этот файл в своём рабочем каталоге** (`fopen("l2_driver_launch.err", "w+b")`,
    `src/l2_eternal_driver.lm1:2727`). Поэтому любую команду инструмента запускать из нового пустого каталога
    `runs/<label>`, никогда из корня репозитория, корня стадии или `stage/src`.
  - Второй файл не трогать и не коммитить. Не применять `git add .`, reset/clean и переписывание истории.
- **Где живые исходники.** Перенесённые `.lm2`, их сгенерированные `.lm1` и исходник транслятора есть только в цепочке
  стадий `build2/opus_fix194` ← `opus_fix193` ← …. Репозиторий `src/` не хранит: в нём `tools/l2`, `tests/l2` и пакеты
  срезов с создающими и `-U0` патчами. `l2src/` и `dev/l2src_sandbox/` репозитория — старые снимки с другими байтами,
  не входы сборки. Каталоги стадий — и живой исходник, и закреплённые манифестами свидетельства: их не удалять, не
  переименовывать, не переписывать; новая стадия копирует только входы. Перенесённые `.lm2` в `l2src/` и
  `dev/l2src_sandbox/` не добавлять.
- **Рабочий инструмент** — G2 среза 194: `build2/opus_fix194/boot-quick-01/lmxtool.exe`. Его фронтенд —
  `build2/opus_fix194/boot-quick-01/frontend/l2trans.exe`, runtime — каталог `build2/opus_fix194/boot-quick-01/runtime`
  (`driver.o`, `driver-observe.o`).
- **Стадия** `build2/opus_fix194`, входы — `src`, `headers`, `tests`, `tools`. Исходник транслятора
  `src/l2src/l2trans.lm1` — `D8F10E37…` (не менялся с Verified192). Рецепт `tools/l2/build.lm2` — `841AC4A5…`, его
  стадийная копия `tools/build.lm2` та же.
- **Остановка Opus.** Сборок и процессов Opus нет. Цепочка 194 (runtime, семя, bootstrap) и проверки завершились,
  сторож памяти вышел сам. В 16:38 `Get-Process gcc, cc1, cc1plus, as, ld, l1trans, l2trans, lmxtool, lmxtool-tool, gdb
  -ErrorAction SilentlyContinue` пуст. Вспомогательные агенты Opus — четыре read-only проверяющих этой передачи —
  завершились, их выводы учтены здесь; других агентов и фоновых задач нет. Срез 195 и новые сборки Opus не начинал.
  Перед своим запуском проверь снова той же командой: пустой вывод — живых сборок нет.

## 3. Цель, что перенесено и что осталось

**Готово, когда** (план §8, READ.ME) в поддерживаемых исходниках ядра, парсера, трансляторов и обычной цепочки сборки и
проверки нет рукописного L1/C/Python/PowerShell:
- S8.3 — замыкание ядра runtime;
- S8.4 — парсер и оба транслятора на L3;
- S8.5 — сборка и проверки на L2/L3, включая генераторы документов на Python, `check_docs.py` и старые PS/Python
  gates, без запасного маршрута;
- S8.6 — настоящие самозамещения G0→G1→G2, которые строят, проверяют и заменяют.

G1/G2 нынешнего bootstrap — не S8.6. Короткий и полный режимы сохраняются и после переноса.

**Перенесено.** Единица трансляции runtime — `src/l2_eternal_driver.lm1` → `driver.c`; её замыкание по `predef` — 35
модулей ядра в `src/l2src`. Перенесены 14 — машинные модули L2 (`l2trans --library --machine …`). Их L1 пишет рецепт
(`bld_kernel_l2`) на стадии на месте рукописного:

| Модуль | Срез | Заголовок |
| --- | --- | --- |
| `lmx_list_owned` | 178 | `--header` |
| `lmx_range` | 180 | нет: прототипы в `lmx_arena.h.lm1` |
| `lmx_pool` | 181 | `--header` |
| `lmx_arena_blocks` | 182 | нет: `lmx_arena_blocks.h.lm1` пишет L3 |
| `lmx_arena` | 183 | нет: `lmx_arena.h.lm1` пишет L3 |
| `lmx_chars` | 186 | `--header` |
| `lmx_chars_owned`, `lmx_array_ref_owned` | 187 | `--header` |
| `lmx_arena_refs`, `lmx_array_owned` | 188 | `--header` |
| `lmx_scratch` | 189 | нет: `lmx_scratch.h.lm1` пишет L3 |
| `lmx_value_owned` | 191 | `--header` |
| `lmx_source_names` | 193 | нет: `lmx_source_names.h.lm1` пишет L3 |
| `lmx_gc_graph` | 194 | нет: `lmx_gc.h.lm1` пишет L3 |

Код L3 рецепта (`decls_write_all`, первый шаг `bld_kernel_l2`) пишет шесть заголовков; номер — вид `decl_write`:

| Вид | Заголовок | Срез |
| --- | --- | --- |
| 0 | `lmx.h.lm1` | 185 |
| 1 | `lmx_arena_blocks.h.lm1` | 185 |
| 2 | `lmx_arena.h.lm1` | 185 |
| 3 | `lmx_scratch.h.lm1` | 189 |
| 4 | `lmx_source_names.h.lm1` | 193 |
| 5 | `lmx_gc.h.lm1` | 194 |

Остальные `.h.lm1` перенесённых модулей пишет `--header` их перевода. Только транслятор меняли срезы 179, 184, 190 и
192, только объявления — 185. Транслятор менялся и в срезах с модулями: 178, 180, 181, 182, 191 (их
`steps/witnesses/fixNNN-*/l2trans.lm1.patch`).

**Осталось на L1.**
- 21 модуль:
  - copy/merge/call: `lmx_implements`, `lmx_graph_copy_owned`, `lmx_merge_owned`, `lmx_call`;
  - ещё 17: `lmx_thread`, `lmx_post`, `lmx_turn`, `lmx_schedule`, `lmx_service`, `lmx_manager`, `lmx_manager_running`,
    `lmx_manager_running_lane`, `lmx_child`, `lmx_orphan`, `lmx_reparent`, `lmx_settle`, `lmx_process_deadline`,
    `lmx_clock`, `lmx_gc` (собиратель Thread), `lmx_root`, `lmx_walk`.
- Рукописный L1-модуль `src/l1src/libc_abi.lm1` и драйвер `src/l2_eternal_driver.lm1`.
- 24 рукописных заголовка:

  ```text
  lmx_call  lmx_child  lmx_clock  lmx_graph_copy_owned  lmx_implements  lmx_implements_resolve  lmx_manager
  lmx_manager_running  lmx_merge_owned  lmx_message  lmx_orphan  lmx_post  lmx_primitive  lmx_process_deadline
  lmx_reparent  lmx_root  lmx_schedule  lmx_service  lmx_settle  lmx_thread  lmx_turn  lmx_value  lmx_walk
  lmx_win32_api
  ```

  У пяти из них нет кодового модуля: `lmx_implements_resolve`, `lmx_message`, `lmx_primitive`, `lmx_value`,
  `lmx_win32_api`. Их уберёт не перенос модуля, а свой писатель `decl_X` в `decls_write_all`, как `lmx.h.lm1` в 185.
- Замыкание трансляторов: `src/l2src/l2trans.lm1`, `src/l1src/l1trans.lm1`, парсер P0 `src/l1src/parser.lm1` и
  остальные файлы `src/l1src`.

**Долг LATER** (честно не запущено; не готовность).
- В последних срезах не запускались kernel gate, gate, replay корпуса и мутанты.
- `bootstrap full` реализован, но ни разу не запускался.
- Доходит ли smoke до модулей 187, 193 и 194, не измерено.
- Строки gate LIBRARY-ROWS-OLD-PROFILE устарели.

## 4. Следующий шаг: срез 195 — каждый файл predef разбирается один раз (черновик, Opus его не начинал)

**Дефект** PREDEF-HEADER-REPARSED-PER-QUERY (`steps/defects.md`). Запросы транслятора к файлу predef (заголовку или
кодовому модулю) каждый раз заново разбирают файл и разрушают документ: снимок программы хранит только байты. Таких
запросов четыре — `l2_predef_file_has_type`, `_define`, `_has_function`, `_result_ty`; они идут и по вложенным
`predef`. Перевод `lmx_gc_graph.lm2` командой рецепта занимает 300 с (`gen-194-06`); в bootstrap 194 шаг модуля —
295 с. Все три выборки gdb — в `lm_p0_parse_bytes` под `l2_snap_parse`. С ростом перенесённых модулей цена растёт.

**Черновик Opus** — приложение A. Это `-U0` к `src/l2src/l2trans.lm1`, 24 куска. **Не транслирован и не собран.**
- База: `d8f10e375087296766a7bc1562a94d48d7e4dd1969ff94d5c10667a687844733`.
- Результат `patch -p1` с корня стадии: `7a1442f9bb7efcaf1b9a7c31675fc620197da5b28ecdccd5c45e8d5381490a77`.
- Рядом с байтами снимка — массив документов `l2_snap_doc`, растёт вместе с остальными в `l2_snap_bytes`.
- `l2_snap_document(path)` разбирает файл при первом запросе и дальше отдаёт тот же документ.
- Четыре читателя берут его и больше не разрушают; `l2_snap_free` разрушает документы вместе с байтами.
- Неудачный разбор не хранится; его документ теперь разрушается — прежде он утекал.
- Исходник и части по-прежнему разбираются через `l2_snap_parse`: трансляция пишет их деревья.
- Два комментария, которые говорили «документ разрушается здесь» и «разбирается заново», исправлены.

**Почему документ можно делить** (чтение кода; независимая read-only проверка подтвердила по строкам):
- Читатели только читают дерево (`l2_next_active`, `l2_count_active`, `l2_frame_head`, `l2_text_same`, `memcmp`). У
  `_define` есть ещё `l2_array_count_is`, а `l2_cnt_keep` копирует текст.
- `_result_ty` строит из узла заголовка контракт (`l2_ret_type_node` → `l2_contract_new`). Контракт держит указатель на
  атом заголовка в глобальном списке, но через него никто не пишет (`l2_foreign_intern_parts` копирует текст). До патча
  этот указатель после разрушения документа висел; теперь он жив до `l2_snap_free`.
- Документ получают только четыре читателя; вызывающим он не отдаётся. Разбор P0 зависит только от байтов: в
  `parser.lm1` нет переменных модуля.
- Единственный писатель флагов узла (`l2_tables_in`, INACTIVE) ходит по исходнику и частям, не по файлам predef.
- `lm_p0_parse_bytes` копирует байты в арену документа.
- Пиковая память — теперь сумма документов, а не максимум: сотни КБ исходника.

**Прогон.** Изменение только транслятора, поэтому достаточно `bootstrap quick` инструментом G2 среза 194. В 190 и 192
перед ним шёл быстрый `rebuild frontend` (192: 59 с), это по желанию.

```text
cd C:/Nyasha_Planet/LMX/build2 && test ! -e opus_fix195 && mkdir opus_fix195 &&
  tar -C opus_fix194 --exclude=l2_driver_launch.err -cf - src headers tests tools | tar -C opus_fix195 -xf -
mkdir -p opus_fix195/runs/packet
sed -n '/^```diff$/,/^```$/p' C:/Nyasha_Planet/LMX/to_codex.md | sed '1d;$d' > opus_fix195/runs/packet/appendix-a.patch
(cwd build2/opus_fix195) sha256sum src/l2src/l2trans.lm1        -> d8f10e37… (база)
(cwd build2/opus_fix195) patch -p1 < runs/packet/appendix-a.patch; sha256sum src/l2src/l2trans.lm1   -> 7a1442f9…
mkdir -p opus_fix195/runs/run-boot-01        (cwd этот пустой каталог)
C:/Nyasha_Planet/LMX/build2/opus_fix194/boot-quick-01/lmxtool.exe 0 entry 0 -- bootstrap quick C:/Nyasha_Planet/LMX
  C:/Nyasha_Planet/LMX/build2/opus_fix195 C:/Nyasha_Planet/LMX/buold_temp boot-quick-01
  C:/Nyasha_Planet/LMX/build2/opus_fix195/tests/smoke.tsv
```

Дельта пакета — по соглашению fix190/fix192, с метками стадий: (cwd `build2`) `diff -U0 --label
stage194/src/l2src/l2trans.lm1 --label stage195/src/l2src/l2trans.lm1 opus_fix194/src/l2src/l2trans.lm1
opus_fix195/src/l2src/l2trans.lm1 > opus_fix195/runs/packet/l2trans.lm1.patch`. Replay — как
`steps/witnesses/fix190-20261024/u0-same.command`: копия базы, `patch -p0` на явный файл, затем `same`. Конец прогона —
`boot-quick-01/bootstrap.txt` и строка `exit=` в `.out` (обёртка — §5.4).

**Ожидаемо: скорость меняется, байты прежние.** Проверки — инструментом G2 нового bootstrap, из пустого
`runs/checks-01`, набором по образцу `steps/witnesses/fix190-20261024/checks/commands.txt`.
- `BOOTSTRAP quick 0 failures`. Сам `bootstrap quick` G1 и G2 не сравнивает: `same` их `lmxtool.lm1` и
  `lmxtool.c`, `exe-same` их `lmxtool-tool.exe`.
- `same` трёх файлов `build2/opus_fix194/boot-quick-01/runtime/{driver.c,driver.o,driver-observe.o}` с такими же
  файлами 195.
- Всё, что переписал рецепт, — прежние байты: (cwd `build2`) `diff -rq --exclude=l2_driver_launch.err opus_fix194/src
  opus_fix195/src` даёт только `l2src/l2trans.lm1`, такой же `diff -rq` по `headers` пуст. Модули ядра префикса `l2_u…`
  не несут.
- L1/C инструмента отличаются от G2 среза 194 только префиксом единицы: (cwd `build2`)
  `E='s/l2_u[0-9A-F]\{16\}_/l2_uHASH_/g'`; `diff <(sed "$E" opus_fix194/boot-quick-01/tool-g2/lmxtool.lm1) <(sed "$E"
  opus_fix195/boot-quick-01/tool-g2/lmxtool.lm1)` пуст, так же для `lmxtool.c` (образец —
  `steps/witnesses/fix192-20261024/checks/normalized.command`).
- Время: после bootstrap, без других прогонов рядом, попытка `runs/gen-195-01` — команда `gen-194-06` с новым
  фронтендом `opus_fix195/boot-quick-01/frontend/l2trans.exe`, исходником и выходом новой стадии. Ждать exit 0 и
  `same` с `opus_fix194/runs/gen-194-06/lmx_gc_graph.lm1`. В 194 — 300 с; в bootstrap шаг модуля (от создания
  `boot-quick-01/runtime/lmx_gc_graph.L2.log` до публикации `src/l2src/lmx_gc_graph.lm1`) — 295 с.
- Пакет — по образцу fix190/fix192 (только транслятор): `l2trans.lm1.patch`, `u0-same.*`, `bootstrap-quick-01.*`,
  `chain-memory.*`, `gen/` (замер), `checks/`, `trace/runtime-record.txt` (вся запись), `manifest/`,
  `evidence-195.list|.sha256`. Документы: строка в разделе «Реализовано в указанном объёме» чек-листа (как 192),
  раздел E30, пункт closure-map без изменения счёта; дефект — «…, FIXED Verified195» и абзац «Исправлено в срезе 195 …»;
  из «Открыты …» его убрать.

Если какой-то байт изменился, это дефект черновика, а не новая норма. Затем PREDEF-HEADER-REPARSED-PER-QUERY — FIXED.

**Следом** (рекомендация Opus — срез 196, до copy/merge/call) исправить PREDEF-BARE-NESTED-PATH-FROM-CWD. Голый
вложенный путь `predef` разрешать рядом с включающим файлом, как l1trans (`l1_resolve_bare_import`), во всех четырёх
читателях. Без этого переносы упрутся в него: рукописные `lmx_graph_copy_owned.lm1` и `lmx_merge_owned.lm1` пишут
голые `predef` («"lmx_graph_copy_owned.h.lm1" "lmx_walk.h.lm1" …»), `lmx_merge_owned.h.lm1` — голый
`"lmx_graph_copy_owned.h.lm1"`. Иначе — в каждом `.lm2` все `predef` писать от `stage/src` (`l2src/…`, `l1src/…`), а
заголовок каждого типа двери C, до которого доходят голым вложенным `predef`, объявлять прямо. Прямой `predef`
заголовка списка блоков в `lmx_gc_graph.lm2` законен и может остаться.

**Открытые вопросы переносов copy/merge/call** (решает Codex).
- Какой модуль первым: `lmx_implements`, `lmx_graph_copy_owned`, `lmx_merge_owned` или `lmx_call`.
- Экспорты для `--machine` — функции с прототипом в рукописном заголовке (`grep -c '^fn: \|^sub: '` и блок
  `prototype:`): `lmx_implements` 51 из 90, `lmx_graph_copy_owned` 26 из 91, `lmx_merge_owned` 24 из 34, `lmx_call` 20
  из 22. Остальные — свои.
- Режим заголовка: заголовки всех четырёх держат записи и `define`. Похоже на 189/193/194: модуль без `--header`,
  заголовок пишет код L3.
- У `lmx_implements` два рукописных заголовка (`lmx_implements.h.lm1`, `lmx_implements_resolve.h.lm1` — только записи,
  читает только он). Переносить оба в срезе модуля, или оставить один рукописным до отдельного среза, как 180–183 до
  185.
- У `lmx_call` четыре переменные модуля (`lmx_call_walk_fn`, `lmx_call_walk_status_mode`, `lmx_call_prim_walk_fn`,
  `lmx_call_walk_fail_status_g`) — общие для процесса крючки. Ни у одного перенесённого модуля хранилища уровня модуля
  нет, а прямой машинный вход автора исключает скрытый singleton.

## 5. Рабочий цикл среза (как его вёл Opus)

1. **Новая стадия** — из предыдущей, командой `tar` из §4. Каждая попытка — новый label. Инструмент сам отказывается
   писать в существующий: «exists: a new label for every attempt».
2. **Модуль.** `src/l2src/M.lm2` — перенос рукописного `M.lm1`: те же функции в том же порядке. Переводится командой
   рецепта в новый каталог `runs/gen-NNN-0K`; запуск из этого каталога, имена файлов абсолютные:

   ```text
   FE --library --machine E1 ... --machine En [--header STAGE/src/l2src/M.h.lm1] STAGE/src/l2src/M.lm2
      C:/Nyasha_Planet/LMX/buold_temp/l2_harness/codex_consumer49_full_01/src/convert.lm2
      C:/Nyasha_Planet/LMX/buold_temp/l2_harness/codex_consumer49_full_01/src/primitive.lm2 OUT/M.lm1
   ```

   FE — фронтенд предыдущего G2. Удачный L1 копируется на стадию в `src/l2src/M.lm1`: `rebuild runtime` предыдущим
   инструментом нового модуля ещё не переводит.
3. **Рецепт.** Модуль добавляется в `bld_kernel_l2`: имена экспортов и `bld_machine_module(…, header)`. Новый
   заголовок L3 — это `decl_X`, новый вид в `decl_write` и в `decls_write_all`.
   - Писатель `decl_X` — куски `c.fputs`, разрезанные по концам строк и экранированные `\\`, `\"`, `\n`. У новых
     писателей (`decl_source_names`, `decl_gc`) куски не длиннее 900 символов; у старых — до 2 055.
   - Куски Opus резал временным неопубликованным помощником на Python в своей сессии и проверял обратным
     декодированием. Надёжнее: команда, сохранённая текстом, или программа L2, затем `same` против байтов рукописного
     заголовка.
   - **Порядок `decls_write_all`.** Он сначала удаляет все свои заголовки и их C-заголовки, затем пишет каждый и сразу
     переводит его l1trans. Поэтому новый заголовок L3 ставится раньше всех заголовков L3, которые читают его через
     `predef` — прямо или через рукописный: `lmx_scratch.h.lm1` (вид 3) читает `lmx_implements.h.lm1`, а
     `lmx_gc.h.lm1` (вид 5) — `lmx_thread.h.lm1`, который читает `lmx_call.h.lm1`. Добавленный в конец, такой
     заголовок сломает шаг C-заголовка вида 3 или 5. Тогда виды перенумеровать (и таблицу §3) или вести порядок
     отдельно.
   - Рецепт правится в репозитории и копируется на стадию `tools/build.lm2`.
4. **Цепочка при изменении рецепта** (команды среза 194; `T0 = build2/opus_fix193/boot-quick-01/lmxtool.exe`, FE0 —
   его фронтенд; `REPO = C:/Nyasha_Planet/LMX`, `BASE = C:/Nyasha_Planet/LMX/buold_temp`; каждый шаг — из своего
   пустого `runs/run-*`). В следующем срезе `T0`, `FE0` — G2 и фронтенд предыдущего среза (после 195 —
   `build2/opus_fix195/boot-quick-01/lmxtool.exe` и `…/frontend/l2trans.exe`):

   ```text
   T0 0 entry 0 -- rebuild runtime REPO STAGE BASE FE0 none rt-01 STAGE/tests/smoke.tsv         (194: 837 s)
   T0 0 entry 0 -- rebuild tool REPO STAGE BASE FE0 STAGE/rt-01 tool-01 STAGE/tests/smoke.tsv  (194: 605 s)
   STAGE/tool-01/lmxtool-tool.exe 0 entry 0 -- bootstrap quick REPO STAGE BASE boot-quick-01 STAGE/tests/smoke.tsv
   ```

   `tool-01` — семя G0 с новым рецептом. Bootstrap этим семенем делает по порядку:
   - строит фронтенд из L1 (`bin/l1trans.exe`);
   - строит runtime: пишет все заголовки L3 и переводит все модули;
   - прогоняет smoke;
   - строит G1; G1 строит G2.

   Рабочим `label/lmxtool.exe` становится сначала G1, затем G2. Вывод инструмента в файл виден только после конца:
   следить за каталогом label. Команды и выводы лежат в корне стадии (`STAGE/rebuild-runtime-01.command|.out`,
   `rebuild-tool-01.*`, `bootstrap-quick-01.*`); обёртка Opus (bash), по шагу на label:

   ```text
   run() { mkdir -p $B/runs/run-$1 && cd $B/runs/run-$1 && s=$(date +%s) && bash $B/$2.command > $B/$2.out 2>&1;
     x=$?; echo "elapsed $(( $(date +%s) - s ))s" >> $B/$2.out; echo "exit=$x" >> $B/$2.out; return $x; }
   run rt-01 rebuild-runtime-01 && run tool-01 rebuild-tool-01 && run boot-01 bootstrap-quick-01
   ```
5. **Сторож памяти** — фоновый цикл PowerShell рядом с цепочкой, текст —
   `steps/witnesses/fix194-20261024/chain-memory.command`.
   - Каждые 3 с он пишет в `runs/chain-memory.log` свободный commit и память cc1.
   - При свободном commit ниже 0.8 GiB он останавливает **все** cc1 машины.
   - Выходит через 10 с после конца `lmxtool`.

   Путь `$log` указывает на стадию 194, предел цикла — 3000 × 3 с, около 2.5 ч: для новой цепочки их поправить.
   Первой строкой лога Opus писал `--- chain <labels>`. Это вспомогательный наблюдатель оператора, не шаг сборки:
   файлом `.ps1` в репозитории не хранится; запуск отдельным процессом Windows PowerShell 5.1 до цепочки (например,
   `Start-Process powershell.exe -WindowStyle Hidden -ArgumentList '-NoProfile','-Command',$text`).
6. **Проверки** — `T 0 entry 0 -- same A B` и `exe-same A B`, из своего пустого `runs/checks-NN`. Набор как в
   `steps/witnesses/fix194-20261024/checks/commands.txt`:
   - L1 и C у `tool-01`, G1 и G2; `exe-same` G1 и G2;
   - runtime bootstrap равен `rt-01`;
   - модуль равен своей попытке `gen`;
   - заголовок и его C-заголовок равны рукописным байтам.

   C runtime сравнивается с предыдущим срезом: изменение должно ограничиваться модулем (`runtime-diff.command`).
7. **Пакет** — `steps/witnesses/fixNNN-20261024/`, образец — fix193 и fix194.
   - `notes.md`; создающий патч модуля (`diff -U0 --label /dev/null --label stageNNN/src/l2src/M.lm2 /dev/null M.lm2`).
   - `u0-same.*`: GNU patch в пустую стадию, затем `same`.
   - `gen/`, `checks/`, `trace/runtime-record.txt` (запись runtime bootstrap: генератор и перевод модуля),
     `chain-memory.*`, команды и выводы цепочки.
   - `manifest/`: `T 0 entry 0 -- manifest LIST C:/Nyasha_Planet/LMX OUT`, затем `sha256sum -c`.

   Список evidence — явные пути, без glob каталога прогона. Манифест хеширует оригиналы в `build2`. Копии в пакете —
   без CR, без хвостовых пробелов и пустых строк в конце; выводы инструмента их несут. Opus нормализовал так:

   ```text
   awk '{ sub(/\r$/, ""); sub(/[ \t]+$/, ""); lines[NR] = $0 } END { n = NR; while (n > 0 && lines[n] == "") n--;
     for (i = 1; i <= n; i++) print lines[i] }' IN > OUT
   ```
8. **Документы среза:**
   - `steps/current.md` — абзац «СрезNNN …» (RU), при изменении дефектов — абзац «Открыты …», и блок
     «**VerifiedNNN (`sha`) — …**» (EN) над предыдущим;
   - чек-лист — строка основания, строка S8.3 со счётом «перенесены N», раздел ENN;
   - `steps/closure-map.md` — пункт и счёт «N из 35»;
   - `steps/native-selfbuild-20260930.md` — фраза в пункте 4 списка «Concrete §8 route after clean-kernel»;
   - `steps/defects.md`.

   Затем `git add` явных путей и только после него `python tools/check_docs.py` (концы строк он проверяет по индексу),
   `git diff --check`, `git diff --cached --check`.
9. **Коммит:**
   - пути — из `git status --short`, только явные; после коммита ни одного изменённого tracked файла;
   - перед push: `git fetch`, `git log origin/main..HEAD` (только свои коммиты) и `git log HEAD..origin/main`
     (пусто). Сессии-соседи коммитят в основной checkout: чужой коммит однажды уехал с push (Verified177). Если что-то
     не так — не пушить и не делать merge или force, а установить, чей коммит и какие пути он трогает;
   - без веток, worktree и PR; автор читает сам `C:\Nyasha_Planet\LMX`;
   - без glob-удалений в репозитории: однажды `rm -f parser_*.lm1` в `dev/l2src_sandbox` удалил tracked заголовки;
     удалять только названные пути и сразу смотреть `git status`;
   - после push — отдельный коммит «Record the VerifiedNNN commit in the current state and checklist», вписывающий SHA
     («…, checklist and defects», если SHA вписывается и в дефект, как c1ec46e2).

## 6. Подводные камни переноса (измерено в срезах 178–194)

- **Режим заголовка модуля.**
  - `--header` кладёт в сгенерированный заголовок все `.h.lm1`-predef модуля; predef кодового `.lm1` остаётся в
    модуле (`l2_pd_is_header`).
  - Без `--header` модуль объявляет все свои функции сверху. Так делают модули, чьи прототипы в чужом заголовке
    (`lmx_range` в `lmx_arena.h.lm1`) или в заголовке L3.
  - Перенос прототипов в новый заголовок даёт цикл импорта и меняет replay (срез 180).
- **Порядок функций.** Ядро — одна единица C с `-Werror=implicit-function-declaration`. Функции перенесённого модуля
  объявляет сам l2trans: экспорты — в заголовке, свои — блоком prototype в начале модуля. Поэтому порядок внутри
  `.lm2` для C не важен. Функция без прототипа в заголовке видна только модулям, стоящим в единице после её модуля
  (`lmx_range_keep_chunk`). В рукописном `.lm1` своя функция стоит выше первого вызова.
- **Слова, которые нельзя связать** (`l2_bind_admit`, `l2_head_word`):
  - слова ресиверов: `sendMessage`, `receiveMessage`, `adopt`, `call`, `merge`, `table`, `catch`, `throw`, `throws`,
    `until`, `end`, `sub`, `fm`, `synchronized`, `length`, `cast`;
  - `fn`, `int`, `return`, `if`, `else`, `while`, `for`, `node`;
  - `break`, `continue`, `sizeof`, `const`, `immutable`, `independent`, `implements`, `test`, `post`, `external`,
    `short`, `long`, `float`, `double`, `signed`, `_Bool`;
  - слова единицы: `predef`, `define`, `include`, `profile`, `prototype`, `os`;
  - слова типов: `char`, `size_t`, `void`, `unsigned`, `ulong`.

  Прочие ключевые слова C (`struct`, `static`, `switch`, `typedef`, …) допуск не отвергает. Переименовывать:
  `node` → `block`, `length` → `text_length`.
- **P0:** `;` на одной строке закрывает только внутренний фрейм. Формал-фрейм, за которым идёт другой формал, берётся в
  скобки.
- **Чтения членов C без типа C** (C-DOOR-MEMBER-ACTUAL-UNTYPED).
  - Приводить при использовании: `(cast: (size_t) x\n)`.
  - Адрес члена по значению и его возврат — через типизированный локал: `va: @ x\member`, затем `return: va`.
  - Фактические вызова C хранятся в лексическом порядке; фактический без типа перед фактическим с вызовом
    отвергается. Тогда привести его или вычислить вызов в локал.
- **Указатель на функцию.**
  - Применение `f(v)` — то же дерево, что `f: v`, и всегда вызов. Поэтому локал получает значение только в объявлении:
    `c.LmxArenaBlockDisposer: disposer block\dispose`.
  - Вызов члена отдельным оператором (`block\dispose(block\base, block\n)`) отвергнут «a native value requires one
    complete expression» (`gen-194-04`). Вызов члена в `return:` работает: срез 191, `fnptr.lm2`, проверка 17,
    `return: pool\pointer_write(cell, 0)`. Причина отказа формы оператора не прослежена; это не общий запрет языка.
- **Хранилище** (поведение L1, измерено в ранних срезах): агрегата по значению на уровне модуля нет — писать
  `@: T name 0`. Дверь `c.*` даёт вызовы, типы и константы и хранилища не объявляет.
- **Тип за голым вложенным `predef`** l2trans не находит (PREDEF-BARE-NESTED-PATH-FROM-CWD). Заголовок такого типа
  объявлять прямо: `predef: "l2src/X.h.lm1"`.
- **Сгенерированные копии.**
  - C-заголовки ядра `STAGE/headers/l2src/X.lm1.h` — копии; bootstrap и `rebuild runtime` пересоздают их
    («HEADERS N regenerated»).
  - После изменения транслятора модули ядра надо перегенерировать первыми: они — входы runtime.
- **Инструмент.**
  - Список частей `bld_self` вкомпилирован: новый код рецепта — в существующую часть (`build.lm2`).
  - Сравнение L1/C инструмента между стадиями требует маски префикса `l2_u<16 hex>_`: он хеширует путь исходника.
  - С Verified192 имена C несут имя привязки; сравнение через 192 — после обратной замены
    (`steps/witnesses/fix192-20261024/checks/normalized.command`).
- **Транслятор.** В `l2trans.lm1` функция сначала названа в блоке прототипов. Правку привязывать к определению с
  колонки 0.

## 7. Открытые дефекты

**Открыты по абзацу «Открыты …» в `steps/current.md`** (статусы — `steps/defects.md`):
- MACHINE-STATUS-CHANNEL: решение о C ABI объявленного выхода теперь за Codex;
- PUBLICATION-FAILURE-UNSAID;
- C-DOOR-MEMBER-ACTUAL-UNTYPED;
- остаток C-DOOR-ACTUALS-UNORDERED;
- WALKED-ROOT-C-DOOR-UNSUPPORTED;
- C-DOOR-POINTER-RESULT-INT-OPERAND;
- ARENA-LOOKUPS-LINEAR;
- LIBRARY-ROWS-OLD-PROFILE;
- NAMED-ACTUAL-ADMISSION-NO-SOURCE;
- PREDEF-BARE-NESTED-PATH-FROM-CWD и PREDEF-HEADER-REPARSED-PER-QUERY (новые в 194).

**Кроме того, с линии Opus:** C-DOOR-DEREF-UNLOCATED, остаток GENERATED-CODE-SIZE, R169-1 (чек-лист K08). Более ранние
OPEN/IN WORK в `steps/defects.md` (2026-09-30…2026-10-20) остаются обязательствами. Дефекты, которые вёл Opus,
переходят к Codex.

**Препятствия масштаба** для переноса трансляторов:
- GENERATED-CODE-SIZE: около 122 строк L1 на строку L2; инструмент собирается только при `-O0`.
- ARENA-LOOKUPS-LINEAR: линейный поиск массивов арены на выделение и просмотр таблицы имён источника.
- PREDEF-HEADER-REPARSED-PER-QUERY — до среза 195.

## 8. Ресурсы и запреты

- **Только `build2`.** Корневой `C:\Nyasha_Planet\LMX\build` не читать, не сканировать, не восстанавливать, выходов там
  не создавать.
- **Без рекурсивных обходов.** `build2` и `buold_temp` — сотни ГБ: никаких рекурсивных grep, find, `ls -R`, du от корня
  репозитория или по `build2`. Поиск — `git grep` по tracked файлам или точные пути. `diff -rq` — только по названным
  подкаталогам стадии, с `--exclude=l2_driver_launch.err`.
- **`buold_temp`** — сохранённые зависимости:
  - части `l2_harness/codex_consumer49_full_01/src/convert.lm2` и `primitive.lm2`;
  - каталог включений `codex_header98_source_control_06/includes`;
  - объект `l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o`.
- **Один GCC pipeline, без `-g`.** GCC — `C:/Qt/Tools/mingw1310_64/bin/gcc.exe`, L1 → C — `bin/l1trans.exe`.
  Трансляции, gcc и запуски инструмента не идут рядом с работающей цепочкой.
- **Память.** С Verified184 инструмент при `-O0` собирается в доступной памяти. В цепочке 194 свободный commit в начале
  — 4.05 GiB, при работающем cc1 не ниже 1.93 GiB (193: 1.29 GiB); cc1 держит до ~1.6 GB. Порог «около 5.4 GiB»
  относился к срезам 176–183, когда инструмент не собирался. Цепочку Opus начинал, когда не было других gcc и cc1 и
  свободного commit было около 4 GiB; ниже 0.8 GiB сторож останавливает cc1 — прерванный шаг повторять с новым label.
- **Процессы.** Остановка родительского shell или задачи оставляет gcc, cc1, l1trans, l2trans и lmxtool живыми: найти
  их по имени (`Get-Process`), проверить время старта и остановить по PID. Прерванное не перезапускать вслепую, а
  установить, что завершилось.
- **Длительность** (193/194): `rebuild runtime` 761/837 s, `rebuild tool` 601/605 s, `bootstrap quick` 1 933/2 298 s.

## Приложение A. Черновик среза 195

`-U0` к `src/l2src/l2trans.lm1` (`D8F10E37…` → `7A1442F9…`, 24 куска); с корня стадии — `patch -p1`.

```diff
--- a/src/l2src/l2trans.lm1
+++ b/src/l2src/l2trans.lm1
@@ -1005 +1005,2 @@
-# frees it (l2_snap_free).
+# frees it (l2_snap_free). A predef file's queries only read its tree, so its P0 document is parsed once too
+# (l2_snap_document) and kept beside its bytes (l2_snap_doc; 0 while that file has not been parsed so).
@@ -1008,0 +1010 @@
+@@: LmP0Document l2_snap_doc 0
@@ -2861,0 +2864 @@
+    fn: l2_snap_document (const: @(char path)) @: LmP0Document
@@ -8562 +8565,2 @@
-    if: l2_snap_parse(path, @ document) = 0 && document != 0
+    document: l2_snap_document(path)
+    if: document != 0
@@ -8621 +8624,0 @@
-        lm_p0_document_destroy(document)
@@ -8739 +8742 @@
-# follows). The literal is kept, because this document is destroyed here.  With
+# follows). The literal is kept as a copy (l2_cnt_keep); the document is the snapshot's (l2_snap_document).  With
@@ -8760 +8763,2 @@
-    if: l2_snap_parse(path, @ document) = 0 && document != 0
+    document: l2_snap_document(path)
+    if: document != 0
@@ -8785 +8788,0 @@
-        lm_p0_document_destroy(document)
@@ -9137 +9140,2 @@
-    if: l2_snap_parse(path, @ document) = 0 && document != 0
+    document: l2_snap_document(path)
+    if: document != 0
@@ -9165 +9168,0 @@
-        lm_p0_document_destroy(document)
@@ -9314 +9317,2 @@
-    if: l2_snap_parse(path, @ document) = 0 && document != 0
+    document: l2_snap_document(path)
+    if: document != 0
@@ -9360 +9363,0 @@
-        lm_p0_document_destroy(document)
@@ -11414 +11417 @@
-    # same file l2_is_known already re-parses for the yes/no check) -- a
+    # same file l2_is_known already reads for the yes/no check) -- a
@@ -68908,0 +68912 @@
+    @@: LmP0Document nv
@@ -68929 +68933,2 @@
-        if: np = 0 || nd = 0 || nl = 0
+        nv: (cast: (@@: LmP0Document) l2_xmalloc((cast: (size_t) cap) * c.sizeof(@: LmP0Document)))
+        if: np = 0 || nd = 0 || nl = 0 || nv = 0
@@ -68935,0 +68941,2 @@
+            if: nv != 0
+                l2_xfree((cast: (@: void) nv))
@@ -68942,0 +68950 @@
+            nv[i]: l2_snap_doc[i]
@@ -68950,0 +68959,2 @@
+        if: l2_snap_doc != 0
+            l2_xfree((cast: (@: void) l2_snap_doc))
@@ -68953,0 +68964 @@
+        l2_snap_doc: nv
@@ -68967,0 +68979 @@
+    l2_snap_doc[l2_snap_n]: 0
@@ -68982,0 +68995,26 @@
+# The P0 document of the snapshot's bytes of the file at path, parsed on its first use and then the same document for
+# every later query of the program: a predef file -- a header or a code module -- whose queries only read its tree
+# (l2_predef_file_has_type, _define, _has_function, _result_ty). 0 when the file cannot be read or does not parse; such
+# a parse is not kept. The snapshot owns the document: l2_snap_free destroys it.
+fn: l2_snap_document (const: @(char path)) @: LmP0Document
+    int: i 0
+    size_t: n 0U
+    const: @: char data
+    @: LmP0Document document 0
+    data: l2_snap_bytes(path, @ n)
+    if: data = 0
+        return: 0
+    while: i < l2_snap_n && l2_snap_data[i] != data
+        i: i + 1
+    if: i >= l2_snap_n
+        return: 0
+    if: l2_snap_doc[i] = 0
+        if: lm_p0_parse_bytes(data, n, @ document) != 0 || document = 0
+            if: document != 0
+                lm_p0_document_destroy(document)
+            return: 0
+        ---
+        l2_snap_doc[i]: document
+    ---
+return: l2_snap_doc[i]
+
@@ -69014,0 +69053,2 @@
+        if: l2_snap_doc[i] != 0
+            lm_p0_document_destroy(l2_snap_doc[i])
@@ -69024,0 +69065,2 @@
+    if: l2_snap_doc != 0
+        l2_xfree((cast: (@: void) l2_snap_doc))
@@ -69027,0 +69070 @@
+    l2_snap_doc: 0
```
