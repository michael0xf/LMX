# Срез 274 — запись снимает только те native, которые она реально затрагивает (U5)

Опубликован 2026-11-03, Opus. Пункт U5 плана N4-U, найден в срезе 272, порядок и условия — ответы Codex
CODEX-OPUS-272-REVIEW-U5-20261103T154220Z-01 и CODEX-OPUS-273-CLOSED-U5-EDGES-20261103T163109Z-01. Норма —
[книга :445](../../../docs/LMX_semantics.ru.md) и L2 spec (абзац о записи и `native`).

P = build2/codex_fix250generationchain01. Архивные копии в [records](records) приведены к UTF-8 LF без BOM и хвостовых
пробелов, исходные receipts в P/pins не менялись и связаны хэшами [evidence.sha256](evidence.sha256).

## Найденный случай

Проба [probe272_i_slot_size](records/pins/u5-probe272_i_slot_size.lm2), трассировка gdb [команды](records/pins/u5-gdb274a.txt),
[вывод](records/pins/u5-trace272.txt) на кортеже 272:

- Запись: `quote\items: Fresh\items`, слот `items` у `Box`. Старое значение — именованный Array `items`, новое — low cell.
- Классификация: запись кода по старому правилу (2), потому что адрес Array является ключом таблицы имён («именованное вхождение»).
- Подъём: `Box` → корень (связь по тому же правилу) → кадры `AT(root, k)` и `OF(root, …)`, держащие корень операндом → тела
  `put_items`, `via`, `through`, `m`, корневой `sendMessage`.
- Итог: `WALK dispatch code=…a4b0 native=0` — это неизменённый `through` с cast — и `walk error: UNSUPPORTED`.

Случай не связан со свободными именами. Минимальный типизированный свидетель
[probe274_data_call](records/pins/u5-probe274_data_call.lm2): обычный `call: S1 D` публикует именованную `T` в слот `D`,
после чего посторонний метод с cast, читающий поле корня, даёт тот же отказ в обоих режимах
([вывод](records/tp136-probe/f02/probe274_data_call-native/run-root0.log)).

## Что реально содержит нативное слово

Измерено на сгенерированном L1 (`P/tp136-probe/*/p.lm1`):

- Вызов идёт через `lmx_call_prim_values`, который читает `code\native` в момент вызова. Прямые вызовы `l2_mN(` есть только в
  собственных трамплинах `l2_mN_tr`, тело вызываемого в вызывающего не включается.
- Именованная Structure, именованный Array и callable читаются из слота при исполнении (`lmx_arena_ref_struct`,
  `lmx_walk_value_cell`). Инициализатор вложенной `Inner` при `call: Runner Runner` слово `Runner` не исполняет
  (`P/tp136-probe/b01/probe274_body_stmt-*`), запись `S1\T\v: 5` видна следующему `call: S1 D` без сброса (`a01/probe274_nested_value`).
- Операнд `AT(unit, k)` хранит адрес корня: слово читает слот по месту исполнения и не содержит кода корня.
- В слово входит только собственный код: кадры операций и безымянные узлы, построенные для них (блоки, списки вызова, формалы),
  и части callable. Даже литерал читается из графа (`lmx_walk_native_numeric_lit`), кроме машинных выражений: стоит заменить тело
  с cast, и устаревшее слово вернёт старое значение (мутант ниже).

## Что изменилось

Ядро, [lmx_arena_refs.lm2](../../../selfbuild/src/l2src/lmx_arena_refs.lm2):

- `lmx_code_write`, что считать записью кода. Правило (2) сужено до операции. Именованный узел и callable в слоте — значение этого
  слота, его замена — данные. Правило (4) применяется только к узлу без собственного имени (формал, описание результата, часть `sub`)
  и не применяется к месту, откуда уходит именованный узел. Правила (1) и (3) не менялись.
- `lmx_code_holds`, куда подниматься. Замена самого операнда остаётся записью кода держателя. Изменение внутри объекта, на который указывает
  неизменённый операнд, — нет. По связи поднимается сброс только от операции (где бы она ни стояла, в том числе в двух телах сразу),
  от части callable и от безымянного узла, построенного для этого держателя. Это не запрет по типу: операция и часть callable
  проходят при любом имени, а безымянный узел с чужим `parent` является ссылкой.
- `lmx_code_words_admit`, отказ до публикации. Перед записью кода для каждого слова, которое будет снято, просматривается фактический код
  под ним уже с новым значением в записываемом слоте (`lmx_code_machine_in`). Если там есть `SOURCE_MACHINE` или неизвестная операция,
  запись отказывает неявным `interpreter` (книга :578): граф, слово и связи не меняются. Просмотр идёт только при наличии слова, поэтому
  построение программы не платит за него. Прогноза пути исполнения нет: важно содержание тела, а не достижимость оператора.
- `lmx_code_write_admit`, для записи по имени из программы: кроме слов отказывает и машинному коду, приходящему в место кода
  без слова, потому что пустой `native` не даёт права обходчику. Конструкторы её не спрашивают: они ставят код до установки слов.
- `lmx_code_cell_admit`, то же для значения, записываемого в ячейку, стоящую в коде. Вызывается до записи.
- Снятие слов перенесено из `prepare` в `commit`. Отказ и неудача записи теперь не меняют слов; после записи нет шагов, способных
  отказать, и нет диспетчеризации между записью и снятием.

Физическая форма места, [lmx_walk_values.lm2](../../../selfbuild/src/l2src/lmx_walk_values.lm2): слово теперь работает после
перепривязки, поэтому читает её форму.

- `lmx_walk_value_field_store` и walked `PUT_REF` пишут в слот, держащий Structure или Array, сам узел. Так делает нативный оператор
  `First: Second`, и так читают слот нативные чтения. Первый прогон полного фокуса показал необходимость этого: `struct_call_selected`
  в root1 (walked корень, нативный метод) падал на low cell. Low cell поля-указателя остаётся, null тоже.
- `lmx_walk_code_part_in` и `lm_compiler_emit_live_code_place`: живое чтение места кода нативным словом понимает low cell публикации
  `call: S D`. Без этого `quote\T: src\T`, затем `call: S1 D` давало `walk error: INVALID` в native и 7 в forced.

Новые экспорты: `lmx_code_cell_admit`, `lmx_code_write_admit`, `lmx_walk_code_part_in`. Поэтому изменился `tools/build.lm2` и нужен новый G0.

## Свидетели

[tests/dyn/code_write_words.lm2](../../../selfbuild/tests/dyn/code_write_words.lm2), строка `runs … 7 nf`, 1 новый вход. Каждый случай
проверен в native и forced, root0 и root1:

| Случай | Что показывает | Код отказа |
| --- | --- | --- |
| `data_call` | публикация `T:` в данные не снимает ни слово метода с cast, ни слово `sub` с cast | 81 |
| `part_rebound` | `quote\T: src\T`: слово `S1` остаётся и читает новую часть, `call: S1 D` публикует её | 88, 89 |
| `swap_body` | замена `body`: `target()` идёт новым телом другой формы, вызывающий `caller` с cast сохраняет слово и диспетчеризует, `binder` с cast не страдает | 82, 83, 84 |
| `refuse_arriving` | машинный код, приходящий в `body`: `catch: interpreter`, старое тело и слово на месте | 85 |
| `refuse_args_fn`, `refuse_args_sub` | замена формалов у `fn` и `sub` с машинной операцией: тот же отказ | 90, 91 |
| `machine_leaving` | замена всего тела с машинной операцией обычным: допустимо, тело идёт обходчиком | 86, 87 |

[free_slot_rebind](../../../selfbuild/tests/dyn/free_slot_rebind.lm2) дополнен телом `machined`. Его перепривязки теперь данные, поэтому
фикстура доступна наблюдению: в native ни одно тело не проходит обходчиком.

Самопроверка драйвера ([code_links_check](../../../selfbuild/src/l2src/l2_driver.lm2)) выросла с 60 до 73 проверок: замена операнда,
запись внутри объекта-ссылки, запись внутри построенного для операции узла, одна операция в двух держателях, именованный узел в слоте,
отказ по имени с неизменными словом, слотом и связями, допуск записи, убирающей машинную операцию. Прежние проверки цикла, разделения и
код + данные сохранены без изменения.

| Кортеж | Результат | Receipt |
| --- | --- | --- |
| Срез 273, G2 boot135a | `code_write_words`: `walk error: UNSUPPORTED` в обоих режимах; `free_slot_rebind` с `machined` так же | [terminal](records/pins/tp136-probe-sep02.terminal.txt), [native](records/tp136-probe/sep02/code_write_words-native/run-root0.log), [forced](records/tp136-probe/sep02/code_write_words-forced/run-root0.log) |
| Кандидат 274 | 7 в обоих режимах и обоих roots | [terminal](records/pins/tp136-probe-s05.terminal.txt) |
| G2 boot136a | исходная `probe272_i_slot_size`, `probe274_data_call` и `probe274_part_rebound`: 7 везде | [terminal](records/pins/tp136-probe-u5g2.terminal.txt) |

Мутанты ядра (собраны на рабочем stage, [правки](records/pins/u5-mutants.txt), stage восстановлен и перепроверен манифестом):

| Мутант | Native | Forced | Самопроверка |
| --- | --- | --- | --- |
| Запись кода не снимает слова | `walk error: INVALID`: устаревшее слово `target` читает кадр другой формы | exit 87: устаревшее слово `leaving` вернуло старое значение | 10 проверок |
| Ничего не отказывает | exit 90 | exit 90 | 2 проверки |
| Подъём по всем связям | 7 | 7 | 1 проверка |

Записи: [устаревшее слово, native](records/tp136-probe/mstale2/code_write_words-native/run-root0.log) и
[forced](records/tp136-probe/mstale2/code_write_words-forced/run-root0.log), [без отказа](records/tp136-probe/mnoadmit/code_write_words-native/run-root0.log),
[подъём](records/tp136-probe/mclimb/code_write_words-native/run-root0.log).

Третий мутант программой не отделяется, и это фактический предел свидетеля: после сужения правила (2) запись кода по имени не начинается на
объекте, стоящем операндом кадра, а кадр программа получить как значение не может. Подъём по ссылочному операнду отделяет только самопроверка ядра.

Полный список `tests/full-suite.tsv` на кандидате ([terminal](records/pins/tp136-probe-full01.terminal.txt)): 68 строк, упала одна,
`named_call_below`. На кортеже 273 она падает так же ([terminal](records/pins/tp136-probe-h01.terminal.txt)), к срезу не относится.

## Приёмка на замороженных байтах

Вход: 190 файлов, manifest `c1dc96bba7fce6ce11057f36e078d7522f9278736c2296fb5b3af0f546877c04`, `P/cold-boot136a`.

| Проверка | Результат | Receipt |
| --- | --- | --- |
| Whole boot136a | 17:47:03.2298107Z→18:03:51.9011088Z, BootstrapExit 0, 1008.67 с; `BOOTSTRAP quick 0 failures`; smoke 9/0 в обеих генерациях | [terminal](records/pins/boot136a-quick.terminal.txt), [log](records/pins/boot136a-quick.log) |
| Сверка | source 190/0; producers g1 и g2: frontend 33, runtime 39, tool 6 шагов, все exit 0; 248/248, 496 хэшей, 0 stale; 245 raw-equal; 3 равных по размеру PE отличаются только байтами 136, 137, 216, 217; consumed 306/306 raw-equal; рабочий tool и bundle равны G2; runtime равен изолированному `rt136e` | [сверка](records/pins/boot136a-compare.txt) |
| G2 focus | 18:04:43.0334151Z→18:08:59.8595940Z, SuiteExit 0, `SUITE 38 rows, 0 failures` | [terminal](records/pins/tp136a-suite-g2.terminal.txt), [log](records/pins/tp136a-suite-g2.log), [список](records/pins/focus136-final.tsv) |
| G2-наблюдение free_slot_rebind | 18:09:26.1526457Z→18:09:36.2215013Z, WitnessExit 0, 82 PASS; результат 7 во всех запусках; forced в обоих roots: m 1, outer_kid 1, outer_items 1, put_kid 1, put_kid_wrong 1, read_kid 2, kid_address 1, put_items 1, put_items_struct 1, put_items_bytes 1, read_items 2, size_items 2; native не обходит ни одного из этих тел, в том числе после перепривязок: слова остались | [terminal](records/pins/tp136a-obs-rebindg2.terminal.txt), [log](records/pins/tp136a-obs-rebindg2.log) |

Tuple G2, `P/cold-boot136a/quick136a`:

| Артефакт | SHA-256 |
| --- | --- |
| `lmxtool.exe`, `g2/tool/lmxtool-tool.exe` | `e3310451333d8016c93adf41507eadd3c2ef4b8c5db6ae52d9d9cca809faa340` |
| `g2/frontend/l2trans.exe` | `0dfce2c902ca26646c5938e26f6109adcaa91c1170b9a13a89a635092b39e0c4` |
| `g2/frontend/l1trans.exe` | `b99c7084062c525b6c919b99dad588029df63e0a0c1f617360e1335a8e928c40` |
| `g2/frontend/l2_libc.o` | `af9fdae33655f8e6235310720787102921450f0f88f9b7bb2f365d372f553d37` |
| `g2/runtime/driver.o` | `62ef3ff529e96cb363ebfbfff45ebcb0e05a230590d67d6d6991d1e6bd348a1a` |
| `g2/runtime/driver-observe.o` | `60ba941ae61a83b6729c9de95ecf7662e2e9d46367b2eb09b52ba947a0d0b09c` |

G0: `P/cold-tp136/tool136b/lmxtool-tool.exe` `d49b9f99a2e136675ca98178d15e517014a2aa01d480b08aa201be083c07731c`. Предыдущий frontend — G2 среза 273
`e53a3b01…`.

Посадка [land274](records/pins/land274.command): 8 шагов exit 0 ([terminal](records/pins/land274.terminal.txt)), 190 файлов, оба
поднабора по 65 исходников проверены. `selfbuild/inputs.sha256` побайтно равен frozen `C1DC96BB…`, `inputs.list` —
`98a1de8cec730c8f1b4acfbeb36920ab289520f65ec2a22909c586fbbcd84884`.

## Границы и находки

Открыто и не проверено:

- Запись части тела, сохраняющая другую машинную операцию, из программы недостижима: `quote\if` — `implements`, потому что операторы не поля.
  Этот случай проверяет только самопроверка ядра.
- Тело с `lm_compiler_rw_may = 0` не содержит `SOURCE_MACHINE`, но и не проверено под обходчиком (`m_walkable = 0`). Запись кода снимет его слово без
  отказа. Такой записи в свидетелях нет.
- Запись по типизированному пути в части callable транслятор не допускает (`a field path must end at a primitive field`), поэтому `lmx_code_write_admit`
  спрашивает только `lmx_walk_value_field_store`.
- Нативная публикация (`lmx_publish_*`, `lmx_arena_ref_store` сгенерированного кода) не имеет канала для именованного отказа: числовые снимают слова
  после записи, запись графа при отказе остановится как нарушение инварианта. В измеренных программах ячейки и слоты публикации в коде не стоят.
- Нативная публикация `T:` оставляет low cell. Чтения пути и живого места его понимают, прямые чтения `lmx_arena_ref_struct` по слоту корня — нет. Такой слот
  получается при `call: S node`, в свидетелях этого нет.
- Значение, записанное в ячейку-операнд, по-прежнему снимает слова (самопроверка это фиксирует), хотя нативный литерал читается из графа. Это консервативно: в теле с
  L2 такая запись теперь отказ.

Новые находки, не исправлены:

- [probe274_layout](records/pins/u5-probe274_layout.lm2): после `quote\kid: Other`, где `y` у `Other` стоит на другой позиции, типизированный `Box\kid\y` читает
  чужое поле по зафиксированной позиции в обоих режимах, exit 81 на кортеже 273 и на G2 ([terminal](records/pins/tp136-probe-layg2.terminal.txt)). L2 spec не разрешает считать позиции равными.
  Это единая физическая карта U1, не U5.
- `named_call_below_os/unit`: `call: Counter` без `var` с чтением собственного поля — неперехваченный отказ на обоих кортежах. Не разбирал, фикстура или код.
- `probe274_var_init` (`P/tp136-probe/g01`): явный `var` с инициализатором в короткой записи не дал ожидаемого по книге :437 значения, exit 81 в обоих режимах. Не разбирал, тема U3.

Дальше: source-occurrence U1–U3, снятие вывода throws, остатки proof-only/preflight, общий collector/resolver, три прохода, FULL, §§8/8a. FULL на этих байтах не запускался.

## Документальная часть

Книга и грамматика не менялись, поэтому `docs render` не запускался. Проверка новым рабочим tool на
проиндексированных путях среза, [docs274-check](records/pins/docs274-check.command),
18:12:44.0190935Z→18:13:12.8161783Z, exit 0: 35 парных глав, 14 случаев implements, 27 парных разделов
грамматики, 44 дословных фрагмента, 615 импортированных файлов, ссылки
([log](records/pins/docs274-check.log)). После неё менялись только эта запись, `evidence.*` и архивные
копии.
