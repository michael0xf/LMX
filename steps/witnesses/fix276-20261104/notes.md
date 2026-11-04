# Срез 276 — реестр корневых голов, `s\[N]field` и отказ голого имени (N4-U U1, U2)

Опубликован 2026-11-04, Opus. U1 и U2 [плана N4-U](../../../next_core_tasks_v3.md#code-data-occurrences) на действующих маршрутах чтения, записи, адреса, допуска и копирования. U3 — следующий срез, закрытие U2 для записи через статический путь зависит от него.

Нормы: [книга](../../../docs/LMX_semantics.ru.md), абзацы об индексном шаге пути и о карте полей выбранной `data` («При одном вхождении имени возможен голый путь, при двух и более нужен `data\[N]field`, а автоматического выбора первого нет. Несколько одноимённых полей данных при этом не создаются.»); [реплика автора 15 октября](../../../LMX_blog/2026-10-15.md): «головы считаем тупо на корневом уровне, всё, "if" считается головой!!!». Что читает индекс и как выбирается шаг карты, разобрал Codex: `CODEX-OPUS-OCC-VALUE-20261103T220837Z-01`, `CODEX-OPUS-275-MAPS-20261103T214114Z-01`.

P = build2/codex_fix250generationchain01. Архивные копии в [records](records) приведены к UTF-8 LF без BOM и хвостовых пробелов, исходные receipts в P/pins не менялись и связаны хэшами [evidence.sha256](evidence.sha256).

## Что было неверно на кортеже 275

Прогон новых строк на G2 boot137b ([terminal](records/pins/tp138-probe-sep276c.terminal.txt)):

- `s\[N]field` отказывал при трансляции: `named field occurrence selectors are removed`.
- Голое имя при двух головах проходило: статический путь, допуск `call`, `node\x`. Выбиралось одно из вхождений.
- Пара, впервые достигнутая ниже отображённого держателя, всегда получала новый полный допуск, а не композицию уже сделанных записей: `map_chain` падал кодом 83.
- `named_call_below` падал на обоих кортежах: см. ниже.

## Механизм

**Реестр вхождений**, порт -2 таблицы имён ([lmx_implements_head_name](../../../selfbuild/src/l2src/lmx_implements.lm2)). Ключ — ячейка слота `lmx_arena_ref_cell(S, slot)`, текст — имя головы. Строка стоит на первом физическом слоте исходного поля: на месте или на операторе. Вспомогательный SET первого объявления вхождением не считается. Голова-путь (`node\x: 1`) строки не получает. Реестр отделён от порта 0, имени места: он не создаёт полей. Транслятор пишет строки в [lm_compiler_emit_root_head](../../../selfbuild/src/l2src/l2_frontend_emit.lm2), чтение головы одно для ядра и транслятора: [lm_compiler_root_head_text](../../../selfbuild/src/l2src/l2_frontend_resolve.lm2). `if:` — голова `if`, головы внутри тела принадлежат телу. [lmx_copy_name_prepare](../../../selfbuild/src/l2src/lmx_graph_copy_owned.lm2) копирует реестр: копия отвечает так же, как источник.

**Две половины карты.** Ребро `j < width` — вхождение `[N]`, ребро `j + width` — голое имя. Две и более головы в значении: голая половина -1. Две и более в требовании: голого использования такого поля нет, половины равны. Правило одно в трёх местах: время исполнения ([lmx_implements_named_view](../../../selfbuild/src/l2src/lmx_implements.lm2)), статические таблицы и допуск ([lm_compiler_schema_two_heads](../../../selfbuild/src/l2src/l2_frontend_resolve.lm2)), данные `call` ([lmx_implements_call_field](../../../selfbuild/src/l2src/lmx_implements.lm2)). Проверка схемы идёт через `lm_compiler_schema_token_slot`: строка каталога для `Copied: merge: D` имеет токен layout источника и отвечает за него.

**Отказ голого имени.** Статический путь, `node\x` и путь через результат `merge`: отказ при трансляции, `this name has two or more root heads: an index selects one (s\[N]name)`. Свободный путь и путь по карте: неявный `implements` на операторе. Голый лексический `hits` остаётся обычной привязкой: это не путь.

**Индекс** читает текущее содержимое места исходного вхождения. Первое вхождение — единственный слот объявления, следующие — слот своего оператора. `D\[1]y` читает сохранённый оператор как Structure, числовой приёмник получает обычный `convert`. Явная запись `quote\[1]y: Other` заменяет содержимое общим допуском и записью, координата не сдвигается, `native` снимается по фактической записи кода. Для статического пути без собственного места добавлен локус 9: слот через `lm_compiler_ps_lookup`, шаг дальше через него невозможен.

**Достижение ребра**, [lmx_implements_reach](../../../selfbuild/src/l2src/lmx_implements.lm2). Различены три ситуации, которые раньше все давали UNKNOWN. Нет записи пары: сначала композиция уже сделанных записей `(V, I)` и `(I, M)` без новых имён и доказательств (`lmx_implements_chain`), и только без такой цепочки обычный допуск. Запись есть, числа для этого ребра нет: спрашивается только это ребро (`lmx_implements_edge_named`), ни других полей, ни будущих тел. NO — отрицательный ответ, неявный `implements` на операторе вместо прежнего invariant и abort.

**Находка сборки.** Неявный бросок теперь может возникнуть в `return:` на уровне открытия. Этот trailer стоит после закрытия pad тела: участок обработчика кончается с его блоком. `lm_compiler_catch_find` всё равно находил обработчик тела и падал с `internal: a catch without its pad`. Теперь то, что брошено в trailer, выходит из метода ([lm_compiler_emit_deliver](../../../selfbuild/src/l2src/l2_frontend_useplan.lm2)). Выявила строка `lib_owner`, в наборе проверок на `source_occurrences` такого случая не было, теперь есть (код 112).

## Переписанные фикстуры

Oracle не менялся, менялись явные пути, которые теперь неоднозначны, и форма вызова там, где прежняя противоречит норме.

| Фикстура | Изменение | Основание |
| --- | --- | --- |
| `dyn/struct_call_throws` | `node\raising` → `node\[0]raising`, у корня две головы `raising` | Решение Codex: `node` — обычная Structure, исключения для её голов нет |
| `dyn/unary_data_selection` | `S\x` → `S\[0]x`; `call: held S` теперь отказ `call`, добавлены `X` и `call: held X` = 4 | [L2](../../../docs/L2_spec_ru.md) и книга: при двух головах голое использование отказывает |
| `os_twins/named_call_below_{os,unit}` | `Counter` получил часть `var`, вызов `call: Counter`, oracle 7 и сравнение двойников прежние | L2: одноаргументный `call: code` выбирает его `var`; «отсутствие `var` не означает неявное `data = code`, а запись в локальные поля данных тогда отказывает» |

## Свидетели

[tests/dyn/source_occurrences.lm2](../../../selfbuild/tests/dyn/source_occurrences.lm2), коды называют проверку:

| Случай | Код |
| --- | --- |
| `[0]y`: чтение, запись, адрес, типизированная ссылка | 81–84 |
| `quote\[1]y` — `convert`; `quote\y` и `quote\[5]y` — `implements`; `quote\[0]y`; `@: held Empty D\[1]y` | 85–89 |
| `call: D One`; замена `quote\[1]y: Other`; координата на месте; `call: D One` после замены | 90–93 |
| Отказы `call` при двух головах, `Twice One`, вложенная голова не считается, копия `merge` | 94–99 |
| Голова-оператор, одна и две; `if` | 100–103 |
| `node\[0]hits`, `node\[1]hits`, голый `hits` как привязка, `call: hits_writer node` | 104–107 |
| Через карту: `take_first(W)`, свободное `D` с двумя головами, `Two\[0]y` при `Two: Lone`, незаполненное ребро | 108–111 |
| Trailer после тела; вторая голова с подходящим содержимым; повторное `@:`; копия по индексу | 112–115 |

[tests/dyn/map_chain.lm2](../../../selfbuild/tests/dyn/map_chain.lm2): `Near: Far` допущен, пока в `Far\b` стоит полный `Fat`, потом там встаёт `Thin` без поля `extra`. С записями `(Thin, I)` и `(I, Near\b)` чтение `Near\b\y` идёт по составленной карте (82, 83). Без них то же чтение — обычный допуск и `implements` (84). Только так удалось разделить композицию и прямой допуск: при именной карте они дают одни числа, а полный допуск держателя проверяет вложенные поля.

Отказы при трансляции: [bare](../../../selfbuild/tests/dyn/occurrence_bare_refused.lm2), [write](../../../selfbuild/tests/dyn/occurrence_write_refused.lm2), [node](../../../selfbuild/tests/dyn/occurrence_node_refused.lm2), [glued](../../../selfbuild/tests/dyn/occurrence_glued_refused.lm2), [copy](../../../selfbuild/tests/dyn/occurrence_copy_refused.lm2).

| Кортеж | Результат | Receipt |
| --- | --- | --- |
| Срез 275, G2 boot137b | 7 строк, 32 отказа: `source_occurrences` не транслируется (`named field occurrence selectors are removed`), `map_chain` даёт 83 в native и forced на обоих roots, строки отказов не дают своего текста | [terminal](records/pins/tp138-probe-sep276c.terminal.txt) |
| Кандидат 276, полный список | `SUITE 76 rows, 0 failures`, native и forced, оба roots | [terminal](records/pins/tp138-probe-q02.terminal.txt) |
| G2 boot138b | `focus138-final` 48/0 | [focus](records/pins/tp138b-suite-g2.terminal.txt) |

Мутанты ([правки](records/pins/mut276.py.txt), [прогон ядра](records/pins/runmut276.sh.txt), [прогон фронтенда](records/pins/runmutfe276.sh.txt)), результат одинаков в native и forced на обоих roots, кроме отмеченного:

| Мутант | Результат |
| --- | --- |
| `call_field` не смотрит на две головы (`callheads`) | 86 и `unary_data_selection` |
| Копия теряет реестр (`copyrows`) | 99 |
| Голая половина берёт последнюю голову (`halfrule`) | Первая редакция фикстуры не поймала: отказывала проверка типа, а не правило половин. Добавлен код 113, [теперь 113](records/pins/tp138-probe-o04.terminal.txt) |
| Нет `edge_named` (`edge`) | walk error UNSUPPORTED |
| Нет допуска при первом достижении (`reachadmit`) | 84 |
| Нет композиции (`chain`) | 83 |
| Обходчик не читает индекс (`walkindex`) | R0 stopped |
| Нет строк реестра (`rows`, фронтенд) | R0 stopped и `unary_data_selection` |
| Статический путь не выбирает голову (`nshead`, фронтенд) | отказ трансляции `source_occurrences`, отказы не срабатывают |
| `node`-путь не выбирает голову (`nodehead`, фронтенд) | то же для `occurrence_node_refused` |
| `two_heads` всегда 0 (`twoheads`, фронтенд) | 109 |
| Строка копии отвечает по своей схеме (`origin`, фронтенд) | 109: это и был последний дефект кандидата |
| Запись без своего места называет голову первым словом (`contractown`, фронтенд) | ложный отказ `data_source_cells`, `explicit_data_var_field` |
| Голое имя над копией берёт строку копии (`mresbare`, фронтенд) | `occurrence_copy_refused` не отказывает |

Мутант `word` (проверка слова языка в `lm_compiler_root_head_text`) выжил. Причина: `@:` уходит раньше через `own_by_decl`, а `if:` даёт запись без своего места. Проверка не имела свидетеля и удалена. `atword`, та же проверка в обратную сторону, тоже ничего не меняет. [Сводка ядра](records/pins/mut276.txt), [сводка фронтенда](records/pins/mut276fe.txt).

## Приёмка на замороженных байтах

Вход: 198 файлов (65 source, 34 tools, 99 tests), manifest `c34d71222ec22cc60bcd4ebffc85956b834c2c75f1c36276bed63a1f7eeddd27`, `P/cold-boot138b`.

| Проверка | Результат | Receipt |
| --- | --- | --- |
| Whole boot138b | 02:11:44.4899726Z→02:28:21.8842378Z, BootstrapExit 0, 997.39 с; `BOOTSTRAP quick 0 failures`; smoke 9/0 в обеих генерациях | [terminal](records/pins/boot138b-quick.terminal.txt), [log](records/pins/boot138b-quick.log) |
| Сверка | source 198/0; producers g1 и g2: frontend 33, runtime 39, tool 6 шагов, все exit 0; 248/248, 496 хэшей, 0 stale; 245 raw-equal; 3 равных по размеру PE отличаются только смещениями 136, 137, 216, 217; consumed 306 равны; runtime равен изолированному rt138e | [сверка](records/pins/boot138b-compare.txt) |
| G2 focus | 02:28:44.3975320Z→02:35:27.1867485Z, SuiteExit 0, `SUITE 48 rows, 0 failures` | [terminal](records/pins/tp138b-suite-g2.terminal.txt), [log](records/pins/tp138b-suite-g2.log), [список](records/pins/focus138-final.tsv) |
| G2-наблюдение | `source_occurrences` 02:35:31.2476723Z→02:36:31.1037064Z, WitnessExit 0, 52 PASS: forced в обоих roots places, stored, replaced, data_role, heads, over_node, through_map по 1. `map_chain` 02:36:32.1927875Z→02:36:42.9587316Z, WitnessExit 0, 40 PASS: records, thin_in_far, composed, not_composed, read_i по 1. В native ни одно тело не пройдено обходчиком | [source_occurrences](records/pins/tp138b-obs-occg2.terminal.txt), [map_chain](records/pins/tp138b-obs-chaing2.terminal.txt) |

Tuple G2, `P/cold-boot138b/quick138b`:

| Артефакт | SHA-256 |
| --- | --- |
| `lmxtool.exe`, `g2/tool/lmxtool-tool.exe` | `603b63979c585433832b6ff3810857ff371e2bc46f1aaa1880b1b37af4d45d1f` |
| `g2/frontend/l2trans.exe` | `484d37f330df5bcecde2f604702b409cb3e21d135dfcf6e9fd36377ca827acf2` |
| `g2/frontend/l1trans.exe` | `afb4c380a71330f4d2b284a47b23b6a2340f0e82396e85cfb68c7774cdc0e8a8` |
| `g2/frontend/l2_libc.o` | `af9fdae33655f8e6235310720787102921450f0f88f9b7bb2f365d372f553d37` |
| `g2/runtime/driver.o` | `c7299a3ce8202d22285258ff97873123f34aea3f410c0ac7a6870016d855df63` |
| `g2/runtime/driver-observe.o` | `ab1e79736e67e01bc8b2981923b05136c3058818e796ab2fb00841aa25a49be4` |

G0: `P/cold-tp138/tool138d/lmxtool-tool.exe` `a4b1f7db8032bc6c2d1d8e55121ec0860e73f1e9a2852c48eff1798b1a035705`. Предыдущий frontend — G2 среза 275 `549d1d4d…`. Первый bootstrap boot138a ([terminal](records/pins/boot138a-quick.terminal.txt), 0 отказов, G1/G2 сошлись) прошёл до усиления фикстуры и двух правок фронтенда, в приёмку не входит.

Посадка [land276](records/pins/land276.command): 8 шагов exit 0 ([terminal](records/pins/land276.terminal.txt)), 198 файлов, оба подмножества по 65 исходников проверены. `selfbuild/inputs.sha256` побайтно равен frozen `C34D7122…`, `inputs.list` — `a18d4388a89cfedde27e1ee2179042ed62551b3a34e15bc4c411726cf03e92a8`.

## Границы и находки

Не сделано этим срезом:

- **`toLmx`** в selfbuild нет, поэтому строка N4-U про него остаётся OPEN. Реестр к выводу текущего графа готов, но это не закрытие.
- **U5** остаётся PARTIAL, три остатка из 274 не менялись.
- **U3**. На финальном G2 ([terminal](records/pins/tp138-probe-g2open.terminal.txt), [список](records/pins/probe276-open.tsv)) падают как описано: `Box\kid: Other` и `D\[1]y: Other` — `more arguments than X has formals` (PATH-HEAD-WRITE-READ-AS-CALL); `T: Other` в `fn`; `T: Bad` в `S1` — запись через вычисляемого держателя (DIRECT-SLOT-WRITE-EVALUATED-HOLDER); `First: @: First: 0` (ROOT-TYPED-NULL-ASSIGNMENT); кандидат с полем-ссылкой против вложенной модели (IMPLEMENTS-REFERENCE-FIELD-NESTED-MODEL). Плюс повторные формы `var: (int: x 2); var: (int: x 5)`, пустые `A()`, `A: ()`, `Outer\Model()`, позиционные hidden input и callable, `x: var\i`. Запись в выбранное вхождение из исполняемого кода работает только через свободный путь.
- **Полный допуск при записи.** `First: V` без поля модели, `Near: Far` при неполном вложенном поле отказывают `implements` на записи: у слота нет известного Consumer, и он получает весь интерфейс. Предмет U3, отдельно спрошу, если там понадобится иное.

Новая запись: `return: g()` в trailer, где обработчик объявленного `throw` есть только в теле, проходит `lm_compiler_check_throws_handled` и падает при выводе с `internal: a callee's declared throw is not handled by its caller` ([свидетель](records/cold-tp138/tests/dyn/p276m_trailer_throw.lm2), [вывод](records/tp138-probe/n01/p276m_trailer_throw-native/p.L2.log)). По книге это необработанный throw на вызове. [TRAILER-CALL-THROW](../../defects.md).

Закрыта запись SPLIT-FREE-PLACE-TYPE: это не дефект. По книге `x: j` без видимого места «определяет именованную Structure, а не присваивает примитиву», поэтому `S1: x: 6` с `int: x` в данных отказывает `call` по норме.

## Документальная часть

Книга, L2 и грамматика норму уже содержат и не менялись, поэтому `docs render` не запускался. Проверка новым рабочим tool на проиндексированных путях среза, [docs276-check](records/pins/docs276-check.command): 02:42:12.9126897Z→02:42:40.0656457Z, exit 0: 35 парных глав, 14 случаев implements, 27 парных разделов грамматики, 44 дословных фрагмента, 615 импортированных файлов, ссылки, LF в индексе ([log](records/pins/docs276-check.log)). Запуск до индексации файлов среза тоже прошёл, его вывод — `P/pins/docs276-check-try1.*`. После проверки менялись только эта запись, `evidence.*` и архивные копии.
