# Срез 277 — запись Structure через путь и вычисляемого держателя, пустые формы, шаг карты по используемому ребру (N4-U U3, первая часть)

Опубликован 2026-11-04, Opus. Первая часть U3 [плана N4-U](../../../next_core_tasks_v3.md#code-data-occurrences) и находка P1-REACH-CONSUMER из [разбора Codex](records/pins/codex-276-review.txt). Повторные структурные формы, `var`-формы и позиционные hidden input — следующий срез, U3 этим срезом не закрыт.

Нормы, [книга](../../../docs/LMX_semantics.ru.md): «Путь `Outer\Model()` или `Outer\Model: ()` адресует поле и даёт ему пустую Structure по тому же общему правилу непотреблённого результата; голый `Outer\Model` читает ссылку без вызова. Для исполнения выбранной обычной Structure служит `call: Outer\Model`.»; «При наличии Consumer учитываются его известные обращения к `bVar` во всех видимых ветвях; неиспользуемые поля `bVar` не сравниваются.» [Автор 26 октября](../../../LMX_blog/2026-10-26.md): «мы проверяем не полное соответствие, а используемые поля». [Автор 3 ноября](../../../LMX_blog/2026-11-03.md): «атом не является вызовом».

P = build2/codex_fix250generationchain01. Архивные копии в [records](records) приведены к UTF-8 LF без BOM, хвостовых пробелов и цветовых кодов терминала, исходные receipts в P/pins не менялись и связаны хэшами [evidence.sha256](evidence.sha256).

## Что было неверно на кортеже 276

Прогон новых строк на G2 boot138b ([terminal](records/pins/tp139-probe-sep277.terminal.txt), [список](records/pins/probe277-sep.tsv)):

- Голова-путь к полю-Structure читалась как вызов: `BoxFn\kid: Other` — `more arguments than BoxFn\kid has formals`. То же у свидетеля из реестра `node\A: B` ([проба](records/cold-tp139/tests/dyn/p277c_unit_node_a.lm2)).
- Все четыре строки останавливаются на этой первой ошибке трансляции, поэтому остальные случаи фикстур на этом кортеже не видны. Что они давали, записано раньше: `T: Other` в `fn` и `T: Bad` при `call: S1 D` — `a named Structure written through an evaluated holder`; `First: @: First: 0` — `assignment value has unknown type`; поле-ссылка кандидата против вложенной модели — `implements` ([записи 276](../fix276-20261104/notes.md)).
- Шаг карты без записи запускал полный допуск: чтение `Near2\b\y` при `Thin` без неиспользуемого поля `extra` отказывало `implements`. Это находка Codex P1-REACH-CONSUMER, [разбор](records/pins/codex-276-review.txt).

## Механизм

**Шаг карты по используемому ребру.** Когда у пары нет ни записи, ни цепочки, [lmx_implements_reach](../../../selfbuild/src/l2src/lmx_implements.lm2) больше не запускает полный допуск с нулевым покрытием. Consumer здесь есть: это выполняемая операция, и использует она только достигнутое ребро. [lmx_implements_admit_edge](../../../selfbuild/src/l2src/lmx_implements.lm2) ведёт обычный приём с покрытием из этого одного ребра, без обхода ниже, NO — обычный неявный `implements`. Запись пары возвращается к прежним числам плюс это, поэтому следующее ребро — своё использование со своей проверкой, а числа для поля, на которое никто не смотрел, в записи нет. Композиция уже сделанных записей стоит первой и не менялась. Голая половина при двух головах на этом пути даёт NO.

**Запись Structure через путь.** Голова-путь к полю-Structure ([lm_compiler_head_is_call](../../../selfbuild/src/l2src/l2_frontend_lower.lm2), [lm_compiler_head_method](../../../selfbuild/src/l2src/l2_frontend_resolve.lm2)) больше не вызов: хвост присваивается месту, прежнее значение не исполняется. Путь к методу остаётся вызовом. Проверка допуска при трансляции и пустые формы — [lm_compiler_check_path_write, lm_compiler_empty_path_structure](../../../selfbuild/src/l2src/l2_frontend_emit.lm2), native [lm_compiler_emit_structure_path_store](../../../selfbuild/src/l2src/l2_frontend_lower.lm2), обход [lm_compiler_rw_path_write](../../../selfbuild/src/l2src/l2_frontend_emit.lm2). Работает от корня, из `fn`, от формального параметра, от `node\` и в выбранное вхождение `D\[1]y: Second`. Голое чтение и `call:` разведены: `count(Outer\Runs)` тело не исполняет, `call: Outer\Runs` исполняет.

**Вычисляемый держатель.** В обходчике `PUT` над цепочкой `OF`/`OF_EDGE` со значением-ссылкой и местом LMX идёт в [lmx_walk_value_field_store](../../../selfbuild/src/l2src/lmx_walk_values.lm2), то есть в ту же перепривязку слота, что и остальные пишущие. `PUT` над `AT` остаётся отказом ([put-ref-186](../../put-ref-186.md), `lmx_walk_put_ref_selftest`). Отказ «evaluated holder» во фронтенде снят: `T: Other` в `fn` и `T: Bad` в теле при разделённом `call: S1 D` дают обычный кадр `PUT`. В native оператор над кэшированным слотом допускает значение сразу ([lm_compiler_emit_slot_receive](../../../selfbuild/src/l2src/l2_frontend_useplan.lm2)): раньше первый допуск наступал при публикации, и отказ становился invariant. Модель локальной Structure теперь берётся из слота (`lmx_walk_slot_model`), а не из рабочего значения; чтение пути в той же активации видит незапубликованное значение.

**Типизированный null.** `First: @: First: 0` — присутствующее ссылочное значение места ([lm_compiler_typed_null_value](../../../selfbuild/src/l2src/l2_frontend_useplan.lm2)). В слоте с моделью такой null получает тип LMX, поэтому следующая перепривязка находит ячейку того же вида. Следование за ним — неявный `interpreter` у именованного корня тоже.

**Поле-ссылка кандидата.** [lmx_implements_low_candidate](../../../selfbuild/src/l2src/lmx_implements.lm2): типизированная ссылка на Structure считается держателем при сравнении с вложенной моделью и на пути чтения.

**Слот локальной Structure объявляет модель**, как именованный корень и вложенное поле: [lm_compiler_emit_local_place_model](../../../selfbuild/src/l2src/l2_frontend_emit.lm2). Без этой строки модель читалась из текущего значения слота. `T: Swapped` при другом порядке полей давал неверное поле: в обходчике сразу, в native после публикации. Первая редакция фикстуры этого не видела: при `T` из одного поля и `Other` из двух номера ребра совпадали, и мутант `modelslot` выжил. Разбор выжившего и нашёл дефект, теперь в фикстуре поля идут в другом порядке (93, 94).

Что снято из кода по ходу приёмки: ветка `lmx_walk_slot_store_ref` для присутствующего null. Мутант показал, что она ничего не меняет, запись нулевой ссылки уже сохраняет объявление слота.

## Свидетели

[tests/dyn/structure_path_write.lm2](../../../selfbuild/tests/dyn/structure_path_write.lm2):

| Случай | Код |
| --- | --- |
| `Box\kid: Other` от корня, из `fn`, от формального параметра, от `node\` | 81–84 |
| `D\[1]y: Second`, чтение через `@: held Second D\[1]y` | 85 |
| Отказ `BoxRefused\kid: Bad`: `implements`, значение на месте | 86 |
| `Outer\Model()` при непустой модели и `Taken()`: `implements`, значение на месте | 87, 88 |
| Голое `Outer\Runs` как аргумент не исполняет, `call: Outer\Runs` исполняет | 89, 90 |
| Новые пустые `A()`, `B: ()`; `Outer\Empty()` и `Outer\Empty: ()` проходят | 91 |

[tests/dyn/structure_slot_write.lm2](../../../selfbuild/tests/dyn/structure_slot_write.lm2):

| Случай | Код |
| --- | --- |
| `T: Other` в `fn`: чтение нового значения в той же активации и запись в него | 81, 82 |
| `T: Swapped` с другим порядком полей: чтение до и после публикации | 93, 94 |
| `T: Bad` в теле при `call: S1 D`: `implements`, значение на месте | 83, 84 |
| Корневой `First: Bad`: `implements`, значение на месте | 85 |
| `Alt\k: V`, модель `p\k` читается через карту до и после | 89, 90 |
| `First: @: First: 0`: чтение бросает `interpreter`; `First: Second` после него | 91, 92 |
| Поле-ссылка кандидата против вложенной модели, `b: Inner2` и `@: b Inner2 Inner2` | 86–88 |

[tests/dyn/map_chain.lm2](../../../selfbuild/tests/dyn/map_chain.lm2): положительный `Near2\b\y` при `Thin` без `extra` (84, 85) теперь проходит. Это прежний случай `not_composed`, который Codex не велел закреплять как норму. Использованное ребро `Near2\b\extra` отказывает своим `implements` (86), нет использованного `y` (87), `y` другого вида (88), более позднее ребро другого вида при уже принятом первом (89, 90). Композиция по записям (82, 83) осталась.

| Кортеж | Результат | Receipt |
| --- | --- | --- |
| Срез 276, G2 boot138b | 4 строки, 8 отказов, ни одна не транслируется: `more arguments than … has formals` | [terminal](records/pins/tp139-probe-sep277.terminal.txt) |
| Кандидат 277, полный список | `SUITE 78 rows, 0 failures`, native и forced, оба roots | [terminal](records/pins/tp139-probe-full06.terminal.txt) |
| G2 boot139 | `focus139-final` 50/0 | [focus](records/pins/tp139a-suite-g2.terminal.txt) |

Мутанты ([правки](records/pins/mut277.py.txt), [прогон ядра](records/pins/runmut277.sh.txt), [прогон фронтенда](records/pins/runmutfe277.sh.txt)), результат одинаков в native и forced на обоих roots, кроме отмеченного:

| Мутант | Результат |
| --- | --- |
| Нет приёма достигнутого ребра (`reachedge`) | walk error UNSUPPORTED |
| Приём ребра без покрытия этого ребра (`edgecontract`) | 85 и R0 stopped |
| Запись пары не возвращается к прежним числам (`keptnumbers`) | 90 и R0 stopped |
| Голая половина при двух головах остаётся без ответа (`twoheadsedge`) | UNSUPPORTED в `source_occurrences` |
| `PUT` над вычисляемым держателем в обычное хранилище значений (`putover`) | walk error INVALID |
| Типизированная ссылка не считается держателем (`lowcand`, `holding`) | 88 |
| Путь не идёт через типизированную ссылку (`cellplace`) | native invariant |
| Присутствующий null в слоте сохраняет написанный тип (`nulltype`) | root1: walk error INVALID |
| Путь к Structure с пустым хвостом — вызов (`headcall`, фронтенд) | отказ трансляции `structure_path_write`: `internal: a call the emitter does not know` |
| Нет приёма на операторе (`slotreceive`, фронтенд) | native: `invariant: own field 3 store failed` |
| Модель локальной Structure из текущего значения (`modelslot`, фронтенд) | Первая редакция фикстуры не поймала, см. выше. [Теперь 93](records/pins/tp139-probe-n03.terminal.txt) |
| Нет строки модели на слоте локальной Structure (кортеж без этой правки, `fe139k`) | [native 94, forced 93](records/pins/tp139-probe-n02.terminal.txt) |
| Объявление места считается записью (`declares`, фронтенд) | отказ трансляции `T: Other`: `a value that is not a number` |
| `@: Model: 0` не null (`nullvalue`, фронтенд) | отказ трансляции: `assignment value has unknown type` |
| Запись через вычисляемого держателя снова отказ (`rwholder`, фронтенд) | отказ трансляции: `a named Structure written through an evaluated holder` |
| Присутствующий null у именованного корня — invariant (`rootnull`, фронтенд) | native: `invariant: a field path met no Structure` |
| Незапубликованный слот читается со старого места (`dirtyread`, фронтенд) | native 81 |

Результаты без отказа. `putat` (`PUT` над `AT` тоже идёт в перепривязку) на этих фикстурах не виден: запрет закрепляет только `lmx_walk_put_ref_selftest`, в этом прогоне он не запускался. `nullstore` показал лишнюю ветку, она удалена. `pathguard` (нет проверки места перед записью по пути) не виден ни на рядах, ни на пробах: запись в immutable через `h: b` отказывает `walk error: INVALID` и без него, уже в хранилище ([проба](records/cold-tp139/tests/dyn/p277c_path_imm2.lm2), [с проверкой](records/pins/tp139-probe-l01.terminal.txt), [без неё](records/pins/tp139-probe-l02.terminal.txt)). Я его оставил: он держит порядок, как в обходчике, где место проверяется до вычисления значения. Этот порядок ряд не показывает, потому что отказ останавливает программу. Отдельного мутанта композиции в этой таблице нет: при именной карте композиция и приём ребра дают одни числа, а прежнее разделение держалось на лишнем полном допуске. Codex велел не вводить искусственное отрицательное требование ради него, поэтому поведением они не разделены.

Первый запуск `nulltype` был недостоверен: метки уже существовали от прежнего запуска, и прогон прочёл старый лог. Результат в таблице — со свежими метками. [Сводка ядра](records/pins/mut277.txt), [сводка фронтенда](records/pins/mut277fe.txt).

## Приёмка на замороженных байтах

Вход: 200 файлов (65 source, 34 tools, 101 tests), manifest `a82f39ac50798a66d8614da34f849add46406861f62eca8cd0d8290ec7cecbd1`, `P/cold-boot139a`.

| Проверка | Результат | Receipt |
| --- | --- | --- |
| Whole boot139a | 07:20:27.0341670Z→07:33:15.4709688Z, BootstrapExit 0, 768.44 с; `BOOTSTRAP quick 0 failures`; smoke 9/0 в обеих генерациях | [terminal](records/pins/boot139a-quick.terminal.txt), [log](records/pins/boot139a-quick.log) |
| Сверка | source 200/0; producers g1 и g2: frontend 33, runtime 39, tool 6 шагов, все exit 0; 248/248, 496 хэшей, 0 stale; 245 raw-equal; 3 равных по размеру PE отличаются только смещениями 136, 137, 216, 217; consumed 306 равны; runtime равен изолированному rt139j | [сверка](records/pins/boot139a-compare.txt) |
| G2 focus | 07:33:45.4038375Z→07:40:24.9685028Z, SuiteExit 0, `SUITE 50 rows, 0 failures` | [terminal](records/pins/tp139a-suite-g2.terminal.txt), [log](records/pins/tp139a-suite-g2.log), [список](records/pins/focus139-final.tsv) |
| G2-наблюдение | `structure_path_write` 07:40:29.0059692Z→07:40:42.7951093Z, WitnessExit 0, 58 PASS: forced в обоих roots write_fn, write_formal, write_node, read_occurrence, write_refused, empty_refused, taken_refused по 1, count 3. `structure_slot_write` 07:40:43.8306061Z→07:41:01.1259295Z, WitnessExit 0, 64 PASS: local_rebound, other, local_order, split_refused, put_bound, put_declared, reference_fields по 1, follow и read_k по 2. В native ни одно тело не пройдено обходчиком | [structure_path_write](records/pins/tp139a-obs-pathg2.terminal.txt), [structure_slot_write](records/pins/tp139a-obs-slotg2.terminal.txt) |

Tuple G2, `P/cold-boot139a/quick139a`:

| Артефакт | SHA-256 |
| --- | --- |
| `lmxtool.exe`, `g2/tool/lmxtool-tool.exe` | `fe4b36561d357ab234936863ca3de990e29a0fdc65744ca20da9b98ced6f77df` |
| `g2/frontend/l2trans.exe` | `da492cef1f750bf6690e2b63ca0eff7d519435f97cb533724609b62a186dc0e4` |
| `g2/frontend/l1trans.exe` | `97dc6203be49fc3a76e1202bc416f9335ffa7e89582d50af972eac481e23fadc` |
| `g2/frontend/l2_libc.o` | `af9fdae33655f8e6235310720787102921450f0f88f9b7bb2f365d372f553d37` |
| `g2/runtime/driver.o` | `447cad4ab5c7a15f0583976404f551f2727b0650571dc981c1aba3cd379ff0fa` |
| `g2/runtime/driver-observe.o` | `18ae5a4bf1e263be22fd0a89d990f1d6ec7e7796fdb7554a9400f0223c7bdb67` |

G0: `P/cold-tp139/tool139a/lmxtool-tool.exe` `8fe22fd8175adccb8a1387dc7e4681971f48f881618894c5951505410c06945e`. Предыдущий frontend — G2 среза 276 `484d37f3…`.

Посадка [land277](records/pins/land277.command): 8 шагов exit 0 ([terminal](records/pins/land277.terminal.txt)), 200 файлов, оба подмножества по 65 исходников проверены. `selfbuild/inputs.sha256` побайтно равен frozen `A82F39AC…`, `inputs.list` — `b0db12b968029783f69f1ef602e24814e42c06c214d28371199ecb1db7140513`.

## Границы и находки

Не сделано этим срезом ([открытые строки на G2](records/pins/tp139-probe-g2open.terminal.txt), [список](records/pins/probe277-open.tsv)):

- **Повторные структурные формы** `t: (int: x 5)` и `var: (int: x 2); var: (int: x 5)` у уже объявленного места. Первая часть следующего среза.
- **`var:` и `call: code code`.** Проба `p277a_var_call` падает, R0 stopped.
- **`@: Box\f two` и `@: x a\b`.** `@: seen Outer\Model` читается как `@: seen Outer \Model`: требование `Outer`, значение — prefix deref свободного `Model`, поэтому `seen\v` даёт `unknown field path segment` ([свидетель](records/cold-tp139/tests/dyn/p277c_outer_bare.lm2)). [BARE-PATH-REQUIREMENT-READ](../../defects.md). Предмет того же среза U3.
- **Позиционные hidden input и callable**, `x: var\i`, не начинались.
- **Приём слота по используемым полям.** `Alt\k: V` без поля `q`, которое никто не читает, отказывает `implements` на записи: слотовый приём идёт с нулевым покрытием и проверяет всю модель. По ответу Codex «internal uses=0/неизвестное coverage НЕ доказывает, что программа предъявила весь интерфейс». Поэтому в фикстуре у `V` пока есть `q`, и это остаточное завышение, а не норма. [SLOT-RECEPTION-USED-FIELDS](../../defects.md).
- **Immutable-значение в формальный параметр.** `b: immutable: merge(Holder)`, затем `read(b)` с `@: h Holder`: native падает `invariant: the record of a proved admission was not kept`, обходчик даёт `implements`. На кортеже 276 так же, вложенное поле ни при чём. Книга: «Передача, возврат и сохранение неизменяемого значения сохраняют его идентичность». [IMMUTABLE-ACTUAL-TO-FORMAL](../../defects.md), [свидетель](records/cold-tp139/tests/dyn/p277c_imm_flat.lm2). Нашлось при поиске свидетеля для `pathguard`.
- **`toLmx`** нет, строка OPEN. **U5** PARTIAL. **TRAILER-CALL-THROW** остаётся до снятия вывода throws: по решению Codex это обычный отказ трансляции. Общий collector, три прохода, FULL впереди.

Наблюдение: локальная `T` в `fn` живёт в слоте кода, поэтому её перепривязка видна следующей активации. Фикстура вызывает такой метод один раз. Спрошу Codex отдельно, это не блокирует срез.

## Нарушение границ

В отладке этого среза я перечислил каталог проб: `cd <каталог> && ls | head`. В вывод попал защищённый basename, то есть произошло именно то, что запрещено: запрет автора включает перечисление, а не только содержимое. Содержимое не читалось и не копировалось. Там же были `ls -la` каталога `cold-tp139/fe139a`, `ls | wc -l` каталога `cold-tp139/fe139b` и glob `pins/tp139-fe-a01*`, имя в их вывод не попало. Codex указал на это в `CODEX-OPUS-EXACT-PATHS-20261104T032541Z-01`. С того места я обращаюсь только к точным именам из recipes и manifests.

## Документальная часть

Книга, L2 и грамматика норму уже содержат и не менялись, поэтому `docs render` не запускался. Проверка новым рабочим tool на проиндексированных путях среза, [docs277-check](records/pins/docs277-check.command): 07:50:05.3969082Z→07:50:28.4021954Z, exit 0: 35 парных глав, 14 случаев implements, оба снимка источников, 27 парных разделов грамматики, 44 дословные выдержки, 615 импортированных файлов, ссылки, окончания LF. Первый запуск отказал: 6 `DOCS-CTRL` на цветовых кодах pwsh в архивной копии `mut277.txt`. Рецепт архива теперь их снимает, оригинал не менялся; receipt того запуска я удалил при повторе.
