# Срез 271 — фактическое место INDEX

Опубликован 2026-11-03, Opus. Кандидата подготовил Codex, его запись сохранена
ниже. Приёмку поколений, G2-проверки, посадку и документы выполнил Opus,
единственный writer/build по [передаче](../../../to_opus.md). Срез — зависимость
общего доступа N4-U, не завершение C, общего collector, трёх обходов, FULL или §§8/8a.

P = build2/codex_fix250generationchain01. Архивные копии в [records](records)
приведены к UTF-8 LF без BOM и хвостовых пробелов, исходные receipts в P/pins не
менялись и связаны хэшами [evidence.sha256](evidence.sha256).

## Что изменилось

Написанный INDEX на удержанном свободном значении сохраняется до достигнутой
операции. Раньше путь от FREE разрешал именной шаг общей операцией, а INDEX требовал
статический контракт (`lm_compiler_path_walk_steps_from`).

- Ядро: новая `lmx_walk_value_index_place` в `lmx_walk_values.lm2`. Array идёт в
  прежний `lmx_value_array_place`. Значение не-ссылка и Structure дают `convert`.
  Остальное классифицирует `lmx_walk_value_deref_actual`, как DEREF. Ненулевой индекс
  указателя считает шаг по интервалу `lmx_range_stride`, а без него по типу указуемого;
  переполнение и выход за интервал дают `interpreter`.
- Native: `lm_compiler_emit_actual_path_place` идёт по шагам в написанном порядке и
  вызывает для INDEX новую операцию, для имени `lmx_walk_value_named_place`. Индекс
  принимается обычным `size_t`. Чтение, запись и `@` выбирают этот путь по FREE-корню,
  а не по виду первого шага.
- Walker: `ELEM`/`ELEMPUT` в `lmx_walk_place_mode` вычисляют держателя и вызывают ту
  же операцию; запись через неизменяемую ссылку отказывает как и раньше.
- Привязка: `lm_compiler_own_bound` отделена от `lm_compiler_own_cached`. Собственный
  Array теперь обычная привязка активации полным Value существующего дескриптора, без
  кэша dirty. Поэтому свободное имя вызываемого достигает Array вызывающего, даже если
  тот его не читает. Walker использует прежнюю OWN/work запись.
- `tools/build.lm2`: экспорт двух новых имён и объявление операции.
- Свидетель: `tests/dyn/free_index_places.lm2` и строка `runs … 7 nf` в
  `tests/full-suite.tsv`, в `inputs.list` на одну строку больше. Скрытые `int*`,
  `size_t*`, Array; чтение, запись, `@`; удержанное голое значение; пойманные `convert` и
  `interpreter`; Array только у вызывающего через промежуточный вызов; индекс 1 через
  `int*`; смешанный путь `quote\items[at]`.

Новой семантики для var, нового графа, обхода полей, автообновления удержанного
голого значения и правки driver/oracle нет.

## Приёмка на замороженных байтах

Вход: 185 файлов, manifest `66b15db1b3ba4543c11cf99cd49f27c10677302e45b97f0b756fa38f0c43b5c8`,
`P/cold-boot133a`.

| Проверка | Результат | Receipt |
| --- | --- | --- |
| Whole boot133a | 12:08:22.5906238Z→12:27:02.0057253Z, BootstrapExit 0, 1119.42 с; `BOOTSTRAP quick 0 failures`; smoke 9/0 в обеих генерациях | [terminal](records/pins/boot133a-quick.terminal.txt), [log](records/pins/boot133a-quick.log) |
| Сверка source | 185/0 против manifest | [сверка](records/pins/boot133a-compare.txt) |
| Producers | g1 и g2: frontend 33, runtime 39, tool 6 шагов, все exit 0 | там же |
| Цепочка | G1 frontend собран G2 frontend среза 270 `fa22765b…`; G1 runtime/tool и G2 frontend — G1 frontend `7c59d3bc…`; G2 runtime/tool — G2 frontend `71f8b555…` | там же |
| Инвентари | 248/248, пересчитано 496 фактических хэшей, 0 stale; 245 raw-equal; 3 равных по размеру PE отличаются только байтами 136, 137, 216, 217 | там же |
| Consumed | 306/306, файлы raw-equal | там же |
| Рабочие артефакты | рабочий tool и bundle равны G2; runtime равен изолированному rt133a | там же |
| G2 focus | 12:33:17.9583254Z→12:39:36.3851812Z, SuiteExit 0, `SUITE 33 rows, 0 failures`, в списке новая строка | [terminal](records/pins/tp133a-suite-g2.terminal.txt), [log](records/pins/tp133a-suite-g2.log), [список](records/pins/focus133-final.tsv) |
| G2-наблюдение | 12:40:11.2031338Z→12:40:46.4549569Z, WitnessExit 0, 52 PASS; результат 7 во всех запусках; forced в обоих roots: m 1, read_int 12, write_nine 3, address_int 3, relay_nine 1, mixed_read 1, mixed_write 1; native этих тел не обходит | [terminal](records/pins/tp133a-obs-indexg2.terminal.txt), [log](records/pins/tp133a-obs-indexg2.log), [команда](records/pins/tp133a-var-obs.command) |

Сверку выполнила только читающая команда
[boot133-compare](records/pins/boot133-compare.command): ожидаемые числа она не
подставляет. Строки вида `l2trans <sha>` без пути в её выводе — артефакт самой команды
(перезапись `$Matches`), действительны строки с путём и хэшем. Заголовок
`tp133a-suite-g2.command` сохранил метку шаблона SUITE132CG2; пути и хэши в нём от 133.

Tuple G2, `P/cold-boot133a/quick133a`:

| Артефакт | SHA-256 |
| --- | --- |
| `lmxtool.exe`, `g2/tool/lmxtool-tool.exe` | `743fa9d478db1e18719140fd63a9e254b646ba28cd0762b9293470b2e2371850` |
| `g2/frontend/l2trans.exe` | `71f8b555695cbf8195ad5105d22a795e3d1ca5f5577f5700afe608a2f0b744d9` |
| `g2/frontend/l1trans.exe` | `dcd388fbd74eb292d948e330cb82e6df5a4831b4b1dbafdf77bae667e993a25e` |
| `g2/frontend/l2_libc.o` | `af9fdae33655f8e6235310720787102921450f0f88f9b7bb2f365d372f553d37` |
| `g2/runtime/driver.o` | `b27649dc650501c116e4e1162739f3c6c8cbbec70e7e3390d95d0512dc9dbcd0` |
| `g2/runtime/driver-observe.o` | `9dd49f04fb886b14fa8b76b39ffa5f1affdd5a42e94a89a6d3c9ada4edb3c8a8` |

## Посадка

[land271](records/pins/land271.command), 12:44:56.9871117Z→12:45:01.8033494Z, новым
рабочим tool, каждый шаг из своего CWD: verify, stage-copy, manifest и stage-copy
`inputs.list`, manifest, verify, verify обоих поднаборов consumed. Все 8 шагов exit 0
([terminal](records/pins/land271.terminal.txt)); 185 файлов, 0 сбоев, оба поднабора по
65 исходников проверены против `selfbuild`.

`selfbuild/inputs.sha256` побайтно равен frozen-манифесту: `66B15DB1…`. Все 9 изменённых
файлов уже LF, без лишней строки в конце и без хвостовых пробелов, поэтому нормализация
не потребовалась и отдельной дельты нет, в отличие от 270. `inputs.list` —
`b789659816eb2bdd6bf0b51562e40693b0d6144e6c5b4aecfcd42e07b101782b`.

## Границы

Открыто и этим срезом не закрывается: `s\[N]field` и другие source-occurrence пути;
descriptor/DESC address witnesses; raw-only consumer при известном C ABI; вывод throws;
остатки proof-only/preflight; общий collector/resolver; три прохода; FULL; §§8/8a.
FULL на этих байтах не запускался.

В свидетеле шаг указателя проверен только для `int` и `size_t`. Для типа указуемого вне
перечня в `lmx_walk_value_index_place` без интервала операция вернёт
`LMX_WALK_UNSUPPORTED`; такого случая в свидетеле нет.

## Документальная часть

Четыре остатка аудита OPUS-CODEX-DOCS-HANDOFF-20261103T1208Z, по ответу Codex:

1. В Git включены без изменения байтов `LMX_blog/2026-11-01.md` (`DA8EE2C5…`) и
   `optimization_three_passes_shared_runtime.md` (`CEDA4973…`). Сверка ссылок действующих
   документов с индексом показала ещё две цели: мои `optimization_proposal_from_opus.md`
   (`C4AAEE70…`) и `to_fable_design_from_opus.md` (`FABBFCD5…`), на которые ссылается
   дизайн с этими же хэшами. Они включены без изменений. Третья цель
   `optimization_design_review_from_codex_20261101.md` принадлежит Codex и не включена.
2. Команды `python tools/*` заменены ссылкой на [цикл документации](../../../READ.ME#docs-cycle)
   в плане и обеих README.
3. В блоке K10 плана прогноз будущих рёбер, алиасов и тела помечен историей, действующая
   норма записана перед ним. Общие карты допуска и снимки уже определённых мест допущенной
   активации не сняты.
4. В `to_opus.md` `steps/witnesses/fix249-20261101/notes.md` и `steps/witnesses/fix250-20261101/`
   названы моим прежним WIP; в этот срез они не входят.

В карте `CORE.md` возвращена строка про mail, children и collection. В `selfbuild/README.md`
описание выбранного G0 и границы приёмки заменено с boot115f на boot133a.

Книга и грамматика не менялись, поэтому `docs render` не запускался. Проверка новым
рабочим tool на проиндексированных путях среза,
[docs271-check](records/pins/docs271-check.command), 12:54:24.7275876Z→12:54:51.0271301Z,
exit 0: 35 парных глав, 14 случаев implements, 27 парных разделов грамматики, 44 дословных
фрагмента, 615 импортированных файлов, ссылки, начало книги; LF в индексе у 15957
файлов ([log](records/pins/docs271-check.log)). После неё менялись только эта запись,
`evidence.*` и архивные копии.

## История кандидата (запись Codex)

База: опубликованный 45cafc25519123f6b1343d40779342c8efeea686, selfbuild270
b9af771a661c8a2ecff90dcd881c055af974d301460d3493fa5cf9d69533a916, 184 входа.
Единственный writer/build — Codex. Fable остановлен; Opus ожидает.
Цель §§8/8a активна. Этот срез — зависимость общего доступа N4-U, не завершение
C, общего collector, трёх обходов, FULL или §§8/8a.

Рабочий кандидат P/variants/tp133, подготовленный P/cold-tp133;
P = build2/codex_fix250generationchain01. Публикация 270 и её frozen inputs
не меняются. Базовые хэши и точный набор изменений: pins/tp133-baseline.json.
Первоначальный manifest кандидата: faa09e9d15ec4500bd7f112534d0f5e24cc72e1e4b0e361ee29967dc0b7ae622.

Разрыв исходной реализации: путь от FREE разрешал именной шаг через общую
операцию, но INDEX раньше этого требовал статический контракт. Кандидат
сохраняет написанный INDEX и даёт native и ELEM/ELEMPUT одну операцию
lmx_walk_value_index_place. Array использует прежний lmx_value_array_place,
указатель — фактическую классификацию DEREF. Чтение/запись/адрес используют
полученное место; индекс принимается обычным size_t receive. Новой семантики
для var или скрытого изменения data нет.

Разделяющий fixture free_index_places.lm2: скрытые int*/size_t*/Array,
read/write/@, сохранение held bare value, пойманные convert и interpreter.
Результата пока нет. Исходные вхождения s\\[N]field и остальные открытые
границы не объявляются реализованными этим изменением.

Начальные prepare/reuse завершились 6/5 шагами exit 0. Новый tool собирается
обычной L3 rebuild-командой из boot132c/G2; затем runtime/component frontend
и малый фокус. Никакие старые успешные проверки не повторялись.

## Компонентная отладка

Tool133, rt133a и fe133a собраны exit0. Два первых фокуса красные:
suite01 — непойманный отказ; suite02 с временными catch-sentinel в m
локализовал convert в outer_array (160) одинаково native/forced.
До него проходят int*/size_t*: чтение, запись, @, held snapshot и convert
при узком receiving. Это частичное наблюдение, не PASS fixture.

Сгенерированный outer_array имеет физический Array в body/0, но не
регистрирует quote в activation bindings. Поэтому reached callee получает
лексический quote вместо собственного caller Array. Исправление fix04
отделяет общую own binding eligibility от native scalar dirty cache:
Array хранит полный Value существующего descriptor; walker использует
прежнюю OWN/work запись. Ни обход произвольных полей, ни новый граф не
добавлены. Новая функция экспортируется обычным tools/build.lm2.
Кандидат fix04: source manifest63791A42,185inputs,9changed files.
Результат fix04 ещё не проверен; tool133b находится в обычной пересборке.

## Фокус прошёл; цельная самосборка в работе

Tool133b9FC96760 завершён exit0. Component fe133bB609A8FD
(координаты/core/emit,171reuse/47unchanged ABI inputs) завершён exit0;
rt133aB27649DC/observe9DD49F04 сохранён, runtime не менялся.
Suite03 даёт7 в n/f обоих roots. Затем временные catch-sentinel сняты:
финальный fixture21F7582A добавляет caller-only Array через relay,
индекс1 через int* и смешанный named-field/INDEX путь.
Suite04 12:06:55–12:07:21Z:1row/0failures,все4запуска дают7.
OSWALK index01 exit0: в forced обоих roots m1/read_int12/write_nine3/
address_int3/relay_nine1/mixed_read1/mixed_write1; native их не walks.

185inputs заморожены в cold-boot133a; source manifest
66b15db1b3ba4543c11cf99cd49f27c10677302e45b97f0b756fa38f0c43b5c8.
Prepare4steps0. Единственный pipeline boot133a quick запущен из
tool133b + boot132c/G2; завершения пока нет. В selfbuild не посажено,
публикации271 нет. Frozen inputs не менять.

## Завершение процесса bootstrap перед передачей

Terminal boot133a-quick:12:08:22.5906238Z→12:27:02.0057253Z,
BootstrapExit0,1119.42s. Процесс завершён; нового compiler pipeline Codex
не запускал. Детальная проверка generations/inventories и G2 focus ещё
не выполнена и передана Opus по to_opus.md. Это не landing/publication271.
