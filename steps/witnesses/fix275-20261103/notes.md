# Срез 275 — Structure другого layout в слоте читается и пишется через карту допущенной пары (P1-PLACE-MAP, начало U1)

Опубликован 2026-11-03, Opus. Первый шаг U1 плана N4-U и общий дефект чтения low cell при `call: S node`, заказ — ответ Codex
CODEX-OPUS-274-SCOPED-U1-20261103T181531Z-01. Норма: [книга, «Проверка используемого интерфейса»](../../../docs/LMX_semantics.ru.md#analytical-tree)
(при положительном результате каждому использованному полю модели сопоставляется физическое поле кандидата, возможно на другой
позиции; это общая карта, чтение, запись, взятие адреса и публикация используют эти места, доступ не ищет имена заново), L2 spec,
строка 86 («equal ordinal positions are not assumed»), [реплика автора 15 октября](../../../LMX_blog/2026-10-15.md): присваивание ссылок на
структуры происходит только через implements.

P = build2/codex_fix250generationchain01. Архивные копии в [records](records) приведены к UTF-8 LF без BOM и хвостовых
пробелов, исходные receipts в P/pins не менялись и связаны хэшами [evidence.sha256](evidence.sha256).

## Что было неверно на кортеже 274

Измерено пробами на G2 среза 274 ([probe275-c.tsv](records/pins/probe275-c.tsv), [terminal](records/pins/tp136-probe-pm01.terminal.txt)):

- `quote\kid: Other`, где `y` у `Other` стоит на другой позиции: `Box\kid\y` читает и пишет чужое поле по зафиксированной позиции, exit 81
  в обоих режимах. Сломанная проба 274 [probe274_layout](records/cold-tp137/tests/dyn/probe274_layout.lm2) — этот случай.
- `First: Second` в корне пишет узел без допуска и без карты, `First\x` читает чужое поле. Неподходящий `First: Bad` проходит молча.
- `call: S1 node` останавливал R0 неявным `call`: у корневого слота нет имени места (`lmx_implements_place_name` читает ключ-ячейку,
  а корень назван только по адресу узла). Предположение в записи 274 о low cell было неточным: до публикации дело не доходило.
- Запись в слот, которому ридер сразу следует прямым `lmx_arena_ref_struct`, читала low cell публикации как `Lmx`.

## Механизм

Один путь места вместо частных обходов представления. Отвергнуто: поле в `Lmx`, глобальный счётчик арены, `parent = holder` как признак
(соседи имеют тот же parent), запрет различия layout, текстовый поиск после допуска, перевод каждого шага на поиск модели в таблице.

**Слот объявляет модель.** Вложенное поле уже имело строку `lmx_source_place_model_set`. Именованный корень получил её же и имя места
([lm_compiler_source_layouts_emit](../../../selfbuild/src/l2src/l2_frontend_core.lm2)): теперь `call: S1 node` находит поле, а слот знает свою модель.
Новое чтение строки — `lmx_implements_cell_model`, им же пользуется `lmx_implements_receive_cell`.

**Одна перепривязка**, [lmx_walk_slot_rebind](../../../selfbuild/src/l2src/lmx_walk_values.lm2). Её зовут все пишущие в слот: нативный оператор (`lmx_walk_slot_store_ref`
из `lm_compiler_own_cell_store_context`), нативная публикация, walked `PUT_REF`, walked публикация kind 3. `lmx_walk_value_field_store` после своих
проверок вида идёт в ту же `lmx_walk_slot_bind`. Порядок: допуск к модели слота, потом форма:

- значение объявленного layout (тот же токен или сам model) либо слот без модели: сам узел, чтение по объявленным позициям, цена прежняя;
- другой layout: low cell, в контексте которой `model` — модель слота. Слот, уже держащий ячейку, её сохраняет: поле-ссылка так объявлено, у пары карта есть в любом случае;
- присутствующий null: своя ячейка с той же моделью (`lmx_walk_value_field_store` теперь идёт сюда же, раньше он опустошал слот, и native не мог прочитать место).

Отказ нативного оператора — неявный `implements`, `convert` или `interpreter` на месте оператора, до изменения. Walked `SET` делает допуск на операторе, не на публикации.

**Карта на шаге пути**, `lmx_walk_value_slot`. Значение без `model` стоит по объявленному layout. С `model` шаг читает `lmx_implements_slot(V, model, ребро)`, для голого имени вторая половина.
Типизированный шаг уже загружал запись места (`l2_cvN`), поэтому новый признак O(1): `l2_cvN.model`. Транслятор добавляет шаг только там, где держатель прочитан из именованного слота и нет статической `view_model`
([lm_compiler_emit_place_slot](../../../selfbuild/src/l2src/l2_frontend_lower.lm2)). Обходчик делает то же в `OF`/`PUT_OF`/`SET_OF` без модели в коде, только если держатель получен из места (`OF`, `OF_EDGE`, `AT`): рабочее значение own разложено по собственному объявлению и карту не читает.

**Глубина.** Поле ниже отображённого держателя объявлено полем модели: `l2_cvN.model` заменяется на `lmx_walk_slot_model(model, slot)`, в обходчике то же через `lmx_walk_place_mode` и `lmx_walk_projection_step`.
Пара, которую ещё никто не допускал (поле перепривязано после допуска держателя), допускается один раз в месте первого достижения обычным `lmx_implements_admit_receiving_templates`; дальше читается её карта. Это новая запись пары, не поиск после допуска, но и не композиция двух карт: см. границы.

**Чтения слота как значения и как модели разведены.** `lmx_walk_slot_struct` (бывший `lmx_walk_code_part_in`) — то, что стоит сейчас: данные `call`, значение именованной Structure, скрытый вход, чтение живого кода.
`lmx_walk_slot_model` — то, что объявлено: требование типизированной ссылки (`lm_compiler_type_inst`, `lm_compiler_model_child`, выбранная модель, `l2_child_model`), в обходчике `lmx_walk_model_project`. `ptr: Model` как значение читает слот сырым и декодирует запись (`lm_compiler_type_value`). Чтения кода и построения не менялись: там нет строк модели, поэтому нет и low cell.

Новые экспорты: `lmx_implements_cell_model`, `lmx_walk_slot_struct`, `lmx_walk_slot_model`, `lmx_walk_value_slot`, `lmx_walk_slot_rebind`, `lmx_walk_slot_store_ref`, поэтому изменился `tools/build.lm2` и нужен новый G0.

## Свидетель

[tests/dyn/place_map.lm2](../../../selfbuild/tests/dyn/place_map.lm2), строка `runs … 7 nf`, 1 новый вход. Коды 81–108 называют проверку:

| Случай | Что показывает | Код |
| --- | --- | --- |
| `nested` | неподходящая Structure: `implements`, слот прежний; null: `interpreter` при следовании в обоих исполнителях; второй перепривязкой чтение и запись идут в новую пару; чтение, запись и `@` через карту, соседние поля целы; значение из слота допускается дальше (`take_req`, `@: r Req Box\kid`); данные `call: Writer Box\kid` | 81–84, 100–105 |
| `deep` | два уровня другой раскладки, поле не первое ни у модели, ни у значения; формал с тем же путём; Array другой длины за перепривязанным слотом | 85–88 |
| `rooted` | `First: Second`, поле модели не первое: путь, формал, own-ссылка и адрес попадают в одно поле | 89–91, 106 |
| `split` | `call: S1 D` и `call: S1 node`: публикация Structure другого layout в слот данных и в корень, чтение из корня, метода и `node\T\v` | 92, 93 |
| `split_rebound` | данные `call` — сама перепривязанная Structure: поле находится в том, что стоит, третий layout читается через обе пары | 94, 95 |
| Корень | `First: Bad` — `catch: implements`, `First\x` прежний; `First: Second` | 96, 97 |
| Копия | `merge` держателя с другой раскладкой на одном и двух уровнях: чтение, запись, оригинал цел | 98, 99, 107, 108 |

Первая редакция фикстуры брала модель с первым полем и пропустила дефект: `lmx_walk_model_project` отдавал значение вместо модели, формал читал чужое поле. Усиление дало `exit 89` (t = 9 у [пробы r1](records/cold-tp137/tests/dyn/probe275_r1.lm2)), исправлено, поле модели теперь не первое.

| Кортеж | Результат | Receipt |
| --- | --- | --- |
| Срез 274, G2 boot136a | native root0 и forced root0 exit 96, native root1 `invariant: a field path met no Structure`, forced root1 exit 101 | [terminal](records/pins/tp136-probe-sepfinal.terminal.txt), записи [native](records/tp136-probe/sepfinal/place_map-native/run-root1.log), [forced](records/tp136-probe/sepfinal/place_map-forced/run-root1.log) |
| Кандидат 275 | 7 в native и forced, root0 и root1 | [terminal](records/pins/tp137-probe-c21.terminal.txt) |
| G2 boot137b | `focus137-final` 39/0; [31 проба](records/pins/probe275-final.tsv): 24 положительные проходят, 7 открытых падают как ниже | [focus](records/pins/tp137b-suite-g2.terminal.txt), [пробы](records/pins/tp137-probe-g2final.terminal.txt) |

Мутанты, все пойманы, stage восстановлен и перепроверен хэшами ([правки](records/pins/mut275.py.txt), [прогон](records/pins/runmut275.sh.txt)):

| Мутант | Native root0 / root1 | Forced root0 / root1 |
| --- | --- | --- |
| Шаг читает объявленную позицию (`nomap`) | 101 / 101 | 101 / 101 |
| Любая Structure стоит сама (`direct`) | invariant / invariant | INVALID / INVALID |
| Нет допуска в перепривязке (`noadmit`) | 96 / 7 | 96 / 7 |
| Нет первого достижения (`noreach`) | UNSUPPORTED / UNSUPPORTED | UNSUPPORTED / UNSUPPORTED |
| Обходчик: нет наследования модели (`nowalkinherit`) | 7 / 107 | 85 / 85 |
| Обходчик: нет карты в `OF` (`nowalkmap`) | 7 / 99 | 101 / 101 |
| `lmx_walk_slot_model` даёт значение (`modelvalue`) | invariant / invariant | invariant / 7 |
| Обходчик: модельный операнд даёт значение (`walkmodel`) | 89 / 89 | UNSUPPORTED / UNSUPPORTED |
| Null опустошает слот (`nullslot`) | invariant / invariant | 7 / 7 |
| Native: нет наследования модели (`noinherit`, фронтенд) | 85 / 85 | 7 / 7 |
| У корня нет модели слота (`norow`, фронтенд) | 96 / 89 | 96 / 89 |
| У корня нет имени места (`noname`, фронтенд) | R0 stopped / R0 stopped | R0 stopped / R0 stopped |

[Сводка ядра](records/pins/mut275.txt), [сводка фронтенда](records/pins/mut275fe.txt). `noadmit` на root1 не ловится фикстурой потому, что walked корень дополнительно допускает значение в `lm_compiler_rw_reference_receive_at`: это второй настоящий допуск, не обход.

Полный список на финальном G2 ([terminal](records/pins/tp137-probe-f02.terminal.txt)): 69 строк, 20 отказов, все в строке `named_call_below`, как и на кортеже 274. Строка падает из-за `call: Counter` без `var`, это U3; зелёным полный список не считается, FULL на этих байтах не запускался.

## Приёмка на замороженных байтах

Вход: 191 файл (65 source, 34 tools, 92 tests), manifest `fbc3fa4e395f63d6b9645dfece34909a840fcff62eca5f7d1a83c27f21918cee`, `P/cold-boot137b`.

| Проверка | Результат | Receipt |
| --- | --- | --- |
| Whole boot137b | 20:52:09.0295527Z→21:10:23.9890957Z, BootstrapExit 0, 1094.96 с; `BOOTSTRAP quick 0 failures`; smoke 9/0 в обеих генерациях | [terminal](records/pins/boot137b-quick.terminal.txt), [log](records/pins/boot137b-quick.log) |
| Сверка | source 191/0; producers g1 и g2: frontend 33, runtime 39, tool 6 шагов, все exit 0; 248/248, 496 хэшей, 0 stale; 245 raw-equal; 3 равных по размеру PE отличаются только смещениями 136, 137, 216, 217 (TimeDateStamp, CheckSum); consumed inputs 306/306 равны; рабочий tool и bundle равны G2 | [compare](records/pins/boot137b-compare.txt) |
| G2 focus | 21:11:03.5190411Z→21:16:07.8052453Z, SuiteExit 0, `SUITE 39 rows, 0 failures` | [terminal](records/pins/tp137b-suite-g2.terminal.txt), [log](records/pins/tp137b-suite-g2.log), [список](records/pins/focus137-final.tsv) |
| G2-наблюдение place_map | 21:16:11.5707413Z→21:16:54.1563640Z, WitnessExit 0, 106 PASS; результат 7 во всех запусках; forced в обоих roots: nested 1, deep 1, rooted 1, split 1, split_rebound 1, put_bad 1, put_null 1, put_third 1, put_kid 1, put_far 1, read_typed 1, follow_kid 2, take_req 1, through 1, take 2, read_root_t 1, read_node_t 1; native ни одно тело не проходит обходчиком | [terminal](records/pins/tp137b-obs-placeg2.terminal.txt), [log](records/pins/tp137b-obs-placeg2.log) |

Tuple G2, `P/cold-boot137b/quick137b`:

| Артефакт | SHA-256 |
| --- | --- |
| `lmxtool.exe`, `g2/tool/lmxtool-tool.exe` | `3717f62bb0e65568bc187b59d6c316f16187c2bb9e405b7630c28f6c7659a507` |
| `g2/frontend/l2trans.exe` | `549d1d4d82edbb0cee008df0a28f86adc1bc4d11b1f9bf14c5ed8f0a4aa5326e` |
| `g2/frontend/l1trans.exe` | `6e2cb52852c01e45270d332bc3f4d17f5882a31408e7cb269b941e8add3df709` |
| `g2/frontend/l2_libc.o` | `af9fdae33655f8e6235310720787102921450f0f88f9b7bb2f365d372f553d37` |
| `g2/runtime/driver.o` | `6602da8d77a0e6871c1be1bed9a4a767f7a4f77bb0d7caa960de204659f23759` |
| `g2/runtime/driver-observe.o` | `c317e400bc1772edf44154e6af2f5811a835606405500411da98b2f2da02f19a` |

G0: `P/cold-tp137/tool137a/lmxtool-tool.exe` `d47770db3f567b943b3de29d66041dfb653e272424ebde60b6ec39fbb3b40cb9`. Предыдущий frontend — G2 среза 274
`0dfce2c9…`. Первый bootstrap boot137a ([terminal](records/pins/boot137a-quick.terminal.txt), 1019 с, 0 отказов) прошёл до усиления фикстуры и двух правок ядра и в приёмку не входит.

Посадка [land275](records/pins/land275.command): 8 шагов exit 0 ([terminal](records/pins/land275.terminal.txt)), 191 файл, оба
поднабора по 65 исходников проверены. `selfbuild/inputs.sha256` побайтно равен frozen `FBC3FA4E…`, `inputs.list` —
`bb0ab45e0ce5c74fdfb6c0239869ea0872da0bdb495eed8b8a57e29a92db4ff7`.

## Границы и находки

U5 остаётся PARTIAL, эти три остатка из 274 срезом не закрыты:

- Нативная публикация по-прежнему не имеет канала для именованного отказа: `lmx_walk_slot_rebind` на публикации при THROWN останавливается как нарушение инварианта. Отказ на операторе теперь доходит до `catch`, поэтому пути к этой остановке в измеренных программах нет, но это не контракт.
- Отсутствие `SOURCE_MACHINE` не доказывает возможность обхода (`rw_may = 0`).
- Консервативный отказ записи в ячейку-операнд при сохраняющемся совместимом слове.

Открытые случаи, каждый проверен на финальном G2 ([terminal](records/pins/tp137-probe-g2final.terminal.txt)), не исправлены:

- [Типизированная перепривязка](records/cold-tp137/tests/dyn/probe275_i_typed.lm2) `Box\kid: Other`: `more arguments than Box\kid has formals` (PATH-HEAD-WRITE-READ-AS-CALL). По книге (голова — значение для присваивания, `Outer\Model: ()` адресует поле) это присваивание, U3.
- [Повторное присваивание в теле](records/cold-tp137/tests/dyn/probe275_g_own.lm2) `T: Other` в `fn`: `root operation not walkable yet: a value that is not a number`. Реплика автора 3 ноября: уже объявленная Structure получает новое значение, U3.
- [Запись во вложенный слот из тела данных](records/cold-tp137/tests/dyn/probe275_k_refuse.lm2) `T: Bad` в `S1`: DIRECT-SLOT-WRITE-EVALUATED-HOLDER, открыт с 15 октября. Теперь есть общая операция записи, не хватает выбора места с вычисляемым держателем.
- [Типизированный null в корень](records/cold-tp137/tests/dyn/probe275_n2.lm2) `First: @: First: 0`: `assignment value has unknown type`.
- [Поле кода без типа](records/cold-tp137/tests/dyn/probe275_h6.lm2) `S1: x: 6`, `call: S1 First`: неявный `call`, потому что место свободной own считается типом LMX (`l2_cpt`), а у данных `int`. На G2 среза 274 так же ([terminal](records/pins/tp136-probe-pm03.terminal.txt)).
- Кандидат с полем-ссылкой против вложенной модели, [`b: Inner2`](records/cold-tp137/tests/dyn/probe275_f6.lm2) и [`@: b Inner2 Inner2`](records/cold-tp137/tests/dyn/probe275_f7.lm2): `implements` на записи. `lmx_implements_graph_holding` не признаёт типизированную указательную ячейку держателем Structure. Книга разрешает сужающий поиск на любую глубину, это дефект допуска.

Известные ограничения реализации:

- Пара первого достижения допускается заново, а не композицией двух карт (книга: «при последовательных композициях соответствия составляются»). Результат совпадает, пока имена уникальны; индексные вхождения U2 потребуют проверить это снова.
- Поле корня части программы, читаемое снаружи как скрытый вход (`lm_compiler_own_ctr`), теперь идёт за low cell, но читает объявленную позицию. Свидетеля нет: корень части в перепривязке не наблюдался.
- Типизированный путь через перепривязанный callable (`lm_compiler_own_ctr`, occurrence метода) остаётся позиционным: у callable нет строки модели.
- Шаг обходчика без модели в коде доверяет `model` значения только для держателя из места. Ссылочное поле с известной моделью всегда идёт со статической `view_model`, поэтому случая с расхождением не наблюдалось; условие закреплено только мутантом `nowalkmap`.
- `heads` в `lmx_implements_call_field` считает слоты по имени узла. Прямо перепривязанная копия того же layout может дать лишнюю голову. Это часть карты вхождений U1/U2.

Дальше: остаток U1 (карта вхождений и голов), U2 `s\[N]field` и отказ голого имени, U3 с `named_call_below`, `probe274_var_init` и перечисленными случаями присваивания. Потом снятие вывода throws, proof-only/preflight, общий collector/resolver, три прохода, FULL, §§8/8a.

## Документальная часть

Книга и грамматика не менялись, поэтому `docs render` не запускался. Проверка новым рабочим tool на
проиндексированных путях среза, [docs275-check](records/pins/docs275-check.command),
21:31:29.8374866Z→21:34:50.8622122Z, exit 0: 35 парных глав, 14 случаев implements, 27 парных разделов
грамматики, 44 дословных фрагмента, 615 импортированных файлов, ссылки
([log](records/pins/docs275-check.log)). Первая попытка отказала на ссылке с фрагментом на заголовок без `id`, она исправлена, вывод первой попытки
оставлен в `P/pins/docs275-check-try1.*`. После проверки менялись только эта запись, `evidence.*` и архивные копии.
