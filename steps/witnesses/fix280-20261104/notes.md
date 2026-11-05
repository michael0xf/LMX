# Срез 280 — приём слота по используемым полям (SLOT-RECEPTION-USED-FIELDS, четвёртая часть U2/U3)

Опубликован 2026-11-04, Opus. Часть U2/U3 [плана N4-U](../../../next_core_tasks_v3.md#code-data-occurrences).

Нормы, [книга](../../../docs/LMX_semantics.ru.md): «При наличии Consumer учитываются его известные обращения к `bVar` во всех видимых ветвях; неиспользуемые поля `bVar` не сравниваются», «Неизвестный вычисляемый путь не объявляется проверенным, но сама неизвестность не является основанием для запрета: ошибка несовместимости выдаётся только при гарантированно невыполнимом требовании», «Замена ветви сначала допускает нового кандидата к прежнему принимающему месту и лишь затем записывает его; отказ оставляет старое значение». Codex, `CODEX-OPUS-276-REVIEW-CONSUMER-20261104T024655Z-01`: «internal uses=0/неизвестное coverage НЕ доказывает, что программа предъявила весь интерфейс». Норма не менялась, менялась реализация.

Приёмка прошлого среза: Codex независимо проверил 279 и закрыл P1-SOURCE-OCCURRENCE в проверенном объёме вместе с распознаванием по префиксу, compiler и тесты при этом не запускал; остальное U2/U3 и `arg_place` за пределами проверенных маршрутов открыто, [дословно](records/pins/codex-279-verified.txt).

P = build2/codex_fix250generationchain01. Архивные копии в [records](records) приведены к UTF-8 LF без BOM, хвостовых пробелов и цветовых кодов терминала; оригиналы в P связаны с [evidence.sha256](evidence.sha256).

## Что было неверно на кортеже 279

Разделение [sep280](records/pins/tp142-probe-sep280.terminal.txt): 13 строк, 34 отказа. `structure_slot_write` и `p280d_full` в native не транслируются (`internal: the admission of a dynamic candidate was not checked`), в forced останавливают R0; `p280a_root`, `p280b_nested`, `p280c_copy`, `p280h_below`, `p280j_reffree` отказывают во всех четырёх конфигурациях; `p280e_null` и `p280f_nullcall` дают `walk error: INVALID`; контроли `map_chain`, `place_map` и положительная `p280g_deep` проходят. `p280i_refstatic` даёт 80 и здесь, и на кандидате: это строка OPEN, а не разделение.

- Слот проверял всю модель: `Alt\k: V`, где у `V` нет `q`, а `q` никто не читает, отказывал. В фикстуре `V` поэтому нёс лишний `q`. Проба [p280a_root](records/cold-tp140/tests/dyn/p280a_root.lm2): `UsedRoot: OnlyU`, у `OnlyU` нет поля `w`, которое никто не читает, [останавливает R0](records/tp142-probe/sep280/p280a_root-native/run-root0.log) необработанным отказом.
- Значение, прочитанное из слота и отданное как статический кандидат, у транслятора считалось доказанным. На кортеже 279 такая программа не транслировалась: [p280d_full](records/tp142-probe/sep280/p280d_full-native/p.L2.log), `internal: the admission of a dynamic candidate was not checked`. На первых сборках среза то же место падало при исполнении: `lmx: invariant: the record of a proved admission was not kept`. После приёма по чтениям это обычный случай: в слоте значение, допущенное по чтениям места, а новый приёмник — другой Consumer.
- `NullBox\k: 0` в обходимом коде: [`walk error: INVALID`](records/tp142-probe/sep280/p280e_null-native/run-root1.log), в native запись проходила. Это отдельный дефект ядра, его нашла проба среза, а не цель среза.

## Механизм

- **Требование места.** План того же collector, `lm_compiler_use_scope_get(e, ключ корня, schema=ni)`. Ключ не пересекается с ключами формалов и локальных: `lm_compiler_d105_ns_key`. План корня собирает пути от самого корня из любого живого метода (`lm_compiler_use_plan_begin`), шаг пути портом не считается.
- **Режим «известное»**, `known` в `lm_compiler_use_plan_build`, `lm_compiler_ruse_append`, `lm_compiler_use_scope_get`. Неизвестное обращение не останавливает сбор и ничего не отнимает; поле, которое оно берёт, считается потреблённым, а не требуется целиком. План Consumer формала прежний: там неизвестное отменяет план целиком. Одно поле уровня даёт одно ребро (`lm_compiler_use_plan_known_edge`), таблица размером с различные пути.
- **Требование вложенного места** `(ni, row)`: объединение уровней под рёбрами, выбирающими строку, плюс достижимые уровни (`lm_compiler_place_uses_open`, `lm_compiler_place_row_set`). Два Consumer одного поля объединяются.
- **Таблицы.** Статические `[]: size_t` на корень и поле, та же раскладка ячеек, что у покрытия Consumer. `lmx_source_place_uses_set` ставит таблицу в строку места, копия её не наследует.
- **Чтение.** Один [lmx_implements_receive_cell](../../../selfbuild/src/l2src/lmx_implements.lm2): проверка вида, затем `lmx_implements_admit_receiving_templates` по таблице. Таблицы нет — только вид. Отказ `implements`, старое значение стоит.
- **Запись не чтение.** `lm_compiler_use_written` ставит бит роли у пути-головы записи: `p\k: NoQ` ничего не читает у прежнего значения, и уровень ниже без рёбер даёт «потреблено». Поэтому null в поле запись через формал не отказывает.
- **Именованный отказ.** `lm_compiler_on_status_channel`, `lm_compiler_d105_refusable`, `lm_compiler_admit_return`: кандидат, прочитанный из слота, отказывает `implements`. Машинному методу отказать нечем, там прежний invariant.
- **Обходчик.** Записи в слот (`lm_compiler_rw_path_write_rec`, две ветки именованного корня в `rw_stmt`) больше не проводят полный `ADMIT_AS` перед store: слот сам допускает значение, как native. Иначе forced отказывал там, где native принимает.
- **Ядро, NULL-PATH-WRITE-WALKED.** Ветка PUT над OF пускает типизированный null в `lmx_walk_value_field_store`: одна присутствующая ячейка, как native.

Нового прохода, runner, cache и второго resolver нет. Hidden root не вводился.

## Свидетели

[tests/dyn/structure_slot_write.lm2](../../../selfbuild/tests/dyn/structure_slot_write.lm2): `V` больше не несёт `q`, новые коды, старые остались:

| Код | Что проверяет |
| --- | --- |
| 95, 96 | корень: подходящее значение принято; без читаемого поля отказ, старое значение стоит |
| 97, 98 | вложенное поле: отказ и успех |
| 99, 100 | свободный держатель и формал: отказ, старое значение стоит |
| 101, 102 | копия принимает значение, её чтение отказывает на своём ребре |
| 103, 104 | результат и формал, возвращающий значение, над значением уже модели: именованный отказ |
| 105 | неизвестное обращение перед известным чтением ничего не отнимает |
| 106 | поле, взятое неизвестным обращением, потреблено: не спрашивается ни у значения поля, ни у поля значения корня |
| 107 | объединение двух Consumer одного поля |
| 108, 109 | запись через формал не чтение, в том числе поверх null |
| 110 | формал с неизвестным использованием: именованный отказ на статическом актуале |
| 111, 112 | глубокое чтение требуется от значения места выше |

103, 104 и 110 закрепляют именованность отказа, а не его необходимость: см. RECEIVING-UNKNOWN-COVERAGE-WHOLE ниже.

Отдельные пробы вне списка, все на [кандидате](records/pins/tp142-probe-d04.terminal.txt) и по [спискам](records/pins/probe280-sep.tsv): `p280a_root`, `p280b_nested`, `p280c_copy`, `p280d_full`, `p280e_null`, `p280f_nullcall`, `p280g_deep`, `p280h_below` (сравнение, `void`-локальная, чтение через локальную: ни одна форма не отказывает, [факты](records/pins/probe280-h02-facts.txt)), `p280j_reffree`.

| Кортеж | Результат | Receipt |
| --- | --- | --- |
| Срез 279, G2 boot141a | 13 строк, 34 отказа. `structure_slot_write` и `p280d_full` в native не транслируются (`internal: the admission of a dynamic candidate was not checked`), в forced останавливают R0; `p280a_root`, `p280b_nested`, `p280c_copy`, `p280h_below`, `p280j_reffree` отказывают во всех четырёх конфигурациях; `p280e_null` и `p280f_nullcall` дают `walk error: INVALID`; контроли `map_chain`, `place_map` и положительная `p280g_deep` проходят. `p280i_refstatic` даёт 80 и здесь, и на кандидате: это строка OPEN, а не разделение | [terminal](records/pins/tp142-probe-sep280.terminal.txt) |
| Кандидат 280, полный список | `SUITE 81 rows, 0 failures`, native и forced, оба roots; фикстура до усиления кода 106 | [terminal](records/pins/tp142-probe-full01.terminal.txt) |
| G2 boot142a | `focus142-final` 53/0 | [focus](records/pins/tp142a-suite-g2.terminal.txt) |

Мутанты ([правки](records/pins/mut280.py.txt), [прогон](records/pins/runmut280.sh.txt), [результаты](records/pins/mut280.txt)), все на `structure_slot_write`, native и forced на обоих roots. Там, где поймал более ранний код, он это и показывает:

| Мутант | Результат |
| --- | --- |
| Неизвестное останавливает сбор (`stopfull`) | код 83: `call: S1 D` больше не отказывает |
| Неизвестное ниже поля требует поле целиком (`belowfull`) | сначала выжил, код 106 писал только в само поле, а целое поле требуется от значения корня. Проверка усилена записью в корень, тот же бинарник теперь [останавливает R0](records/pins/tp142-probe-fbelow2.terminal.txt) |
| Путь от корня не читает его место (`noroot`) | код 83 |
| Один Consumer вместо объединения (`rowone`) | код 107 |
| Запись читает прежнее значение (`written`) | R0 остановлен необработанным отказом |
| Уровень без чтений всё равно входит в поле (`emptybelow`) | R0 остановлен |
| Статический кандидат снова не отказывает (`refusable`) | native на обоих roots: `invariant`; forced не задет |
| Слот корня без требования (`rootsite`) | код 85 |
| Слот поля без требования (`rowsite`) | код 83 |
| Обходчик снова проводит полный допуск (`rwwhole`) | forced на обоих roots и native root1: R0 остановлен |
| Ниже места ничего не требуется (`nodeep`) | код 111 |
| Ядро снова не пускает null (`kernelnull`) | `walk error: INVALID`, две из четырёх конфигураций, как на кортеже 279 |
| Ядро не читает требование (`kerneluses`) | код 83 |

## Приёмка на замороженных байтах

Вход: 203 файла (65 source, 34 tools, 104 tests), manifest `1e5584c9e360981ddfdeb90f00227b2974fc606b8da82ff860bef1ad92655e19`, `P/cold-boot142a`.

| Проверка | Результат | Receipt |
| --- | --- | --- |
| Whole boot142a | 20:13:46.5847167Z→20:32:51.4473608Z, BootstrapExit 0, 1144.86 с; `BOOTSTRAP quick 0 failures`; smoke 9/0 в обеих генерациях | [terminal](records/pins/boot142a-quick.terminal.txt), [log](records/pins/boot142a-quick.log) |
| Сверка | source 203/0; producers g1 и g2: frontend 33, runtime 39, tool 6 шагов, все exit 0; 248/248, 496 хэшей, 0 stale; 245 raw-equal; 3 равных по размеру PE отличаются только смещениями 136, 137, 216, 217; consumed 306/306 равны; working tool и bundle равны G2; driver и driver-observe равны изолированному rt142b | [сверка](records/pins/boot142a-compare.txt) |
| G2 focus | 20:33:48.8514820Z→20:46:31.3809652Z, SuiteExit 0, `SUITE 53 rows, 0 failures` | [terminal](records/pins/tp142a-suite-g2.terminal.txt), [log](records/pins/tp142a-suite-g2.log) |
| Полный список на G2 | 21:00:08.9130453Z→21:14:00.4460851Z, SuiteExit 0, `SUITE 81 rows, 0 failures` | [terminal](records/pins/tp142-probe-fullg2.terminal.txt) |
| G2-наблюдение | чистые прогоны `structure_slot_write`, спек режется на 16 имён: `form3g2` 20:51:05.0642044Z→20:53:04.6429235Z, 15 тел, 100 PASS; `form4g2` 20:57:59.7965910Z→20:59:48.4369562Z, 5 тел и `take_full`, `formal_unknown` со счётчиком 0 (отказ у вызова, тело не входит), 52 PASS. WitnessExit 0, forced в обоих roots с точными счётчиками, native не обходит ни одно: 20 тел. Два прогона красные и оставлены: `formg2` на моём спеке `take_full=1`, `form2g2` на `copy_read_q`, см. ниже; остальные счётчики в них сошлись | [form3g2](records/pins/tp142a-obs-form3g2.terminal.txt), [form4g2](records/pins/tp142a-obs-form4g2.terminal.txt), [formg2](records/pins/tp142a-obs-formg2.terminal.txt), [form2g2](records/pins/tp142a-obs-form2g2.terminal.txt) |
| Время | whole вырос с 846.95 с до 1144.86 с. Замер не показывает заметного замедления на этих строках и поддерживает объяснение средой, но один не доказывает, что средовая каждая часть роста (поправлено в записи среза 281 по замечанию Codex). Одни и те же 4 строки поочерёдно на обоих G2 разницы не дают, а при сборках рост начался между fe142c (271,9 с) и fe142d (362,7 с), которые строил один транслятор, причём на неизменённых шагах `l2_receiving_source` и `l1_backend_platform_win` и в самом gcc. 4 строки поочерёдно на G2 279 и G2 280, три пары: 279 — 318.5, 322.0, 321.0 с; 280 — 320.4, 319.4, 319.9 с | [сравнение](records/pins/timing280.txt) |

Tuple G2, `P/cold-boot142a/quick142a`:

| Артефакт | SHA-256 |
| --- | --- |
| `lmxtool.exe`, `g2/tool/lmxtool-tool.exe` | `47089440d6673295df3fd9fcaea55a3fcfffcbc787ce5d77b63926a0fa97bfc1` |
| `g2/frontend/l2trans.exe` | `b1d5b4f8f1bb407489b86fdb26d2599323ca79940d5c57cd356ea190bb10f64c` |
| `g2/frontend/l1trans.exe` | `ea41688939bb9d3f788d94ff9f6fc872b4aac771bf59ae98b5232ac38e35c196` |
| `g2/frontend/l2_libc.o` | `af9fdae33655f8e6235310720787102921450f0f88f9b7bb2f365d372f553d37` |
| `g2/runtime/driver.o` | `d7f1e5158cf1bfe33fe65577c469841185c72d912d7de0da9bf09416b52181ce` |
| `g2/runtime/driver-observe.o` | `7bd2bf279a421ad7f9388d499b4fb132fd54fb3a46adfda81dc236870b695cbe` |

G0: `P/cold-tp140/tool142a/lmxtool-tool.exe` `6a3e66803f6d69e95367aafd3774e8c29f28e127ecc57f447323f22c22046582`. Предыдущий frontend — G2 среза 279, boot141a. Новый стенд не создавался: рабочий стенд `cold-tp140` совпадал с опубликованным selfbuild, изменения шли через `variants/tp142` и `pins/source-tp142.sha256`.

Посадка [land280](records/pins/land280.command): 8 шагов exit 0 ([terminal](records/pins/land280.terminal.txt)), 203 файлов, оба подмножества consumed равны frozen, `selfbuild/inputs.sha256` равен frozen.

## Границы и находки

- **Не закрыто.** U2 и U3 остаются открытыми: `@: Box\f two`, `@: x a\b`, `x: var\i`, позиционные hidden input и callable. FULL на этих байтах не запускался.
- **REFERENCE-FIELD-STATIC-WRITE, следующий.** [p280i_refstatic](records/cold-tp140/tests/dyn/p280i_refstatic.lm2): `Holder\p: OnlyQ`, у `OnlyQ` нет поля `a`, которое никто не читает, отказывает, и через корень, и через типизированную локальную, код [80](records/tp142-probe/i01/p280i_refstatic-native/run-root0.log) на кортежах 279 и 280: все четыре записи отказаны. Свободный путь по чтениям уже идёт: [p280j_reffree](records/cold-tp140/tests/dyn/p280j_reffree.lm2) проходит на кандидате, типизированное чтение после свободной записи видит значение; на кортеже 279 та же проба даёт [190](records/tp142-probe/sep280/p280j_reffree-native/run-root0.log).
- **RECEIVING-UNKNOWN-COVERAGE-WHOLE.** Формал с неизвестным использованием, типизированная локальная и результат всё ещё спрашивают весь интерфейс, хотя правило Codex 276 это отвергает. В этом срезе отказ стал именованным, полнота не снята. Коды 103, 104 и 110 при снятии меняются.
- **COPY-PLACE-KNOWN-CONSUMERS.** У копии `merge` требования нет: запись принимается, чтение отказывает позже на своём ребре.
- **Где требования нет, только проверка вида.** Локальные Structure, которые не корень цепочки; `eternal`; библиотечный режим при `e < 0`; методы, не достижимые от `e`, Consumer не считаются. Чтение там отказывает на своём ребре. Ложного отказа нет, отказ поздний.
- **MERGE-PUBLICATION-DROPS-READER-WORD, старое поведение, найдено наблюдением.** Метод, читающий результат `merge` по пути, в native-программе обходится. [p280k_copyread](records/cold-tp140/tests/dyn/p280k_copyread.lm2): `copy_read` обходится, `src_read` рядом сохраняет слово, одинаково на G2 [280](records/pins/tp142a-obs-copyg2.terminal.txt) и [279](records/pins/tp142a-obs-copy279.terminal.txt). [Стек](records/pins/gdb280g.txt) сброса слова в фикстуре среза: `lmx_code_reset_from` < `lmx_code_rebind_commit` < `lmx_graph_ref_fill_in` < `lmx_walk_slot_bind` < `lmx_walk_slot_rebind` < корень. Значение верное, теряется только скорость, поэтому `copy_read_q` не входит в счёт тел ниже.
- **Поправка к записи 279.** В `fix279-20261104/notes.md` стояло «Отрицательную ветку программой не достать». Этого я не измерял, только не достал в своих пробах. Формулировка исправлена.
- **Сборки.** Все сборки кандидата прошли, `fe142a`–`fe142d` и `rt142a`, `rt142b` — последовательные правки. Промежуточные пробы красные и оставлены: [a01](records/pins/tp142-probe-a01.terminal.txt): код 83 в `structure_slot_write`, 96 в `place_map`; [b01](records/pins/tp142-probe-b01.terminal.txt): `invariant` в native root0, R0 остановлен в root1; [c01](records/pins/tp142-probe-c01.terminal.txt), [c02](records/pins/tp142-probe-c02.terminal.txt): R0 остановлен в forced и в root1, лишний полный допуск обходчика; [d02](records/pins/tp142-probe-d02.terminal.txt), [d03](records/pins/tp142-probe-d03.terminal.txt): `walk error: INVALID`, дефект ядра с null.
- **Нарушение границ.** Один раз `ls -la` собственного каталога строки пробы вывел строку с защищённым basename (имя, размер, дата; содержимое не читалось). Сообщено Codex и автору. Дальше каталоги строк не перечисляются, только явные пути.

## Документальная часть

Книга, L2 и грамматика норму уже содержат и не менялись, поэтому `docs render` не запускался. Проверка новым рабочим tool на проиндексированных путях среза, [docs280-check](records/pins/docs280-check.command): exit 0, [terminal](records/pins/docs280-check.terminal.txt), [log](records/pins/docs280-check.log).
