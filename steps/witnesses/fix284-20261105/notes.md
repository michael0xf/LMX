# Срез 284 — запятая как граница операнда: `T \q`, `f(a, \b)`, `f(a, -b)` (восьмая часть U2/U3)

Опубликован 2026-11-05, Opus. Часть U3 [плана N4-U](../../../next_core_tasks_v3.md#code-data-occurrences), поручение Codex по ревью 282, п.2 ([дословно](../fix283-20261105/records/pins/codex-282-review.txt)). Норма: [семантика](../../../docs/LMX_semantics.ru.md#resolved-head-consumption), «Одна модель, одно разрешение, одно потребление»: модель «голова — аргументы» формируется до того, как известна голова, и ни имя, ни категория её границ не задают; READ.ME, «Общее правило решений»; реплика автора от 2026-10-27 ([LMX_blog](../../../LMX_blog/2026-10-27.md)): пробелы вокруг `\` допустимы, примыкание префикса — стиль; грамматика §§10, 11, 21: пробел и запятая разделяют поля. Направление исправления записано в BARE-DEREF-ACTUAL-MERGED с 2026-10-27. Норма и текст грамматики не менялись.

P = build2/codex_fix250generationchain01. Архивные копии в [records](records) приведены к UTF-8 LF без BOM, хвостовых пробелов и цветовых кодов терминала; оригиналы в P связаны с [evidence.sha256](evidence.sha256).

## Сравнение на опубликованном кортеже 283

Пробы [p284a–o и p282z](records/cold-tp140/tests/dyn), кортеж boot145a, native и forced одинаково ([sep284](records/pins/tp146-probe-sep284.terminal.txt)); те же ряды на итоговом кандидате — [sep284c](records/pins/tp146-probe-sep284c.terminal.txt):

| Запись | 283 | Норма |
| --- | --- | --- |
| `@: p Box\Inner`, у `Box` есть `Inner` | путь, `p\v` = 4 | путь |
| `@: p Box \Inner` | путь | путь: те же поля |
| `@: p Box, \Inner` | путь: запятая потеряна | требование `Box` и разыменование |
| `@: p Inner \q`, у `Inner` нет `q` | требование и разыменование | путь `Inner\q`, отказ |
| `@: p Inner, \q` | требование и разыменование | то же |
| `add(x, \px)`, `two(\px, \py)`, `two(y, \px)` | `has no argument b`: актуалы слились | два актуала |
| `two(x, -y)` | `has no argument b`: бинарный минус | два актуала |
| `two(Twice\[0]t, \px)`, `two(px\[0U], \py)` ([p284i](records/cold-tp140/tests/dyn/p284i_occurrence_comma.lm2), [p284j](records/cold-tp140/tests/dyn/p284j_slash_index_comma.lm2)) | `has no argument b` | два актуала |
| формал и локальная метода перед запятой, `two(a, \py)` ([p284m](records/cold-tp140/tests/dyn/p284m_formal_before_comma.lm2)) | `has no argument b` | два актуала |
| `int: z int: x, -y` ([p284n](records/cold-tp140/tests/dyn/p284n_typed_value_comma.lm2)) | `z` = -1: запятая потеряна, прочитано `x - y` | два операнда: отказ `a numeric receiver requires one value`, 4:8 |
| `int: z int: x - y` ([p284o](records/cold-tp140/tests/dyn/p284o_typed_value_control.lm2)) | -1 | -1, контроль |
| p282z `@: x Box\absent` | `unresolved name`: `absent` прочитан разыменованием | отказ на пути |

Одни и те же поля `T \q` давали разные наборы операндов в зависимости от наличия поля (`lm_compiler_value_path_run`, срез 282), а запятая не доходила до модели.

Разделение: [sep284](records/pins/tp146-probe-sep284.terminal.txt), 25 рядов, 30 отказов на кортеже boot145a. comma_boundary не транслируется, comma_path_refused и comma_requirement_refused не отказывают; p284f, g, h, i, j, m — `has no argument b` при трансляции, p282z — `unresolved name`. p284c, d и n проходят на 283 с прежним смыслом (путь, требование, `x - y`). Переписанные free_*, place_write_form, p284a, b, e, l, o проходят на обоих кортежах. Те же ряды на итоговом кандидате ([sep284c](records/pins/tp146-probe-sep284c.terminal.txt)): 12 отказов, каждый в таблице выше или в границах: p284c, d, n и p282z отказывают при трансляции, p284j и p284k в обходимом корне — `walk error: UNSUPPORTED`, на 283 у p284k так же.

## Где терялась граница

P0 потреблял `,` и `;` (`p0_parser.lm2`, ветка `lm_p0_is_field_separator`) и ничего от них не оставлял: `f(a, \b)` и `f(a \b)` давали одни поля. Через это место операнд продолжали два общих читателя: цикл шагов пути `lm_compiler_path_steps_operand` и разбор значения `lm_compiler_value_fields_into`, который после операнда читает `-` бинарным оператором.

## Механизм

- **P0.** Разделитель оставляет метку на поле перед ним: `LM_P0_NODE_SEPARATOR_AFTER` (новый флаг узла, 8U, в тексте заголовка P0 в `tools/build.lm2`; новый G0). Дерево и поля не меняются, дамп флага не печатает.
- **Читатели.** Метку спрашивает `lm_compiler_separated`. Цикл шагов пути не продолжает цепочку за помеченным полем. Последнее прочитанное поле начинается с корня, поэтому корень с меткой стоит один. `lm_compiler_value_fields_into` после помеченного поля ждёт новый операнд, поэтому знак там — префикс. `lm_compiler_expr_span` не менялся: см. мутанты.
- **Без выбора по полю.** `lm_compiler_value_path_run` удалён: в `@:` второй операнд — путь, если поля образуют путь, что бы в нём ни нашлось. `@: p T \q` — путь при любых пробелах; требование и разыменование пишутся `@: p T, \q`.
- **Переписанные формы.** Одиннадцать строк, где имелось в виду требование и разыменование, получили запятую: free_graph_address (3), free_model_admit (1, и комментарий), free_pointer_paths (2), free_field_places (1), free_slot_rebind (1), native_closure_values (3). Перепись по 211 входам 283, строки без комментариев, где за именем или скобкой через пробел стоит `\`: 31. Из них 11 — эти объявления `@:` и `@@:`, 9 — `cast`, 11 — объявления `T: name \x`, у которых имя — одно поле; эти 20 не меняются. Кода, где перед разделителем стоит имя или индекс, а за ним `\имя`, во входах нет (строки без литералов и комментариев): каждое `, \x` стоит после строки, литерала или скобок. Знак после разделителя (`, -x`) в коде входов тоже не встречается.

Runner, cache, второй resolver и скрытые корни не вводились.

## Свидетели

[tests/dyn/comma_boundary.lm2](../../../selfbuild/tests/dyn/comma_boundary.lm2), native и forced, оба roots:

| Код | Что проверяет |
| --- | --- |
| 11–13 | `@: p Box\Inner`, `Box \Inner`, `Box \ Inner`: путь |
| 14 | `@: p Inner, \q`: требование и разыменование |
| 15, 16 | `add(x, \px)`, `add(x , \ px)` |
| 17, 18 | `two(\px, \py)`, `two(y, \px)` |
| 19, 20 | то же в методе с локальной и через формал |
| 21 | `two(x, -y)`: знак после запятой — префикс |
| 22 | запятая после шага пути: `two(glued\v, \px)` |
| 23, 25 | после индекса и после `\[0U]`, в методе: `two(px[0U], \py)`, `two(px\[0U], \py)` |
| 24 | после селектора вхождения: `two(Twice\[0]t, \px)` |

[comma_path_refused](../../../selfbuild/tests/dyn/comma_path_refused.lm2): `@: p Inner \q` без поля — отказ на объявлении, `unknown type`. [comma_requirement_refused](../../../selfbuild/tests/dyn/comma_requirement_refused.lm2): `@: p Box, \Inner` — требование `Box`, `p\v` — `unknown field path segment`.

## Мутанты

Десять мутантов фронтенда на fe146b, каждый отдельной сборкой FE; восемь рядов `mut284-list.tsv` в обоих режимах ([mut284.txt](records/pins/mut284.txt)). Отказ трансляции указан строкой свидетеля:

| Мутант | Что убрано | Итог |
| --- | --- | --- |
| p0mark | P0 не ставит метку | убит: comma_boundary :30 (код 19), free_pointer_paths, free_graph_address |
| pathstop | цикл пути не спрашивает метку | убит: :38 (код 23) |
| pathroot | корень не спрашивает метку | выжил |
| exprstop | `lm_compiler_expr_span` продолжает оператором за меткой | выжил |
| valuestop | разбор значения за меткой читает оператор | убит: :78 (код 21) |
| pathvalue | второй операнд `@:` — не путь | убит: :48 (код 11), place_write_form, comma_path_refused |
| namelast | шаг имени не двигает последнее поле | убит: :81 (код 22) |
| indexlast | индекс не двигает | убит: :38 (код 23) |
| occlast | селектор вхождения не двигает | убит: :88 (код 24) |
| slashindexlast | `\[0U]` не двигает | убит: :40 (код 25) |

Оба выживших сняты из кода.

- **pathroot.** Корень с меткой заканчивает и проверка цикла, потому что последнее поле начинается с корня. Без терма путь отвечает «не путь», и операнд идёт простым атомом, а не путём из одного имени. Все ряды и пробы p284m (формал и локальная метода перед запятой) проходят в обоих вариантах. Терм снят.
- **exprstop.** `lm_compiler_expr_span` служит только классификаторам: проверке одного значения у приёмника типа (`lm_compiler_fields_one_value`) и актуалам конструкции. Само значение потом читает `lm_compiler_value_fields_into`, а он метку видит сам. Проба p284n `int: z int: x, -y` отказывает `a numeric receiver requires one value` (4:8) и на fe146b, и на мутанте. Проверка снята, текст функции опубликованный.

На итоговом тексте (fe146c) pathstop стал единственной границей пути, включая корень. Его повтор: убит, 12 отказов: comma_boundary :30 (код 19), free_pointer_paths, free_graph_address, как у p0mark ([fpathstopc](records/pins/tp146-probe-fpathstopc.terminal.txt)).

## Приёмка на замороженных байтах

Вход: 214 файлов (65 source, 34 tools, 115 tests), manifest `2a1d385a7f06aaeddad60305f356698eebdf62ba48a6e095bc36c237c095ba1a`, `P/cold-boot146a`.

| Проверка | Результат | Receipt |
| --- | --- | --- |
| Focus на итоговом кандидате до whole | 21:49:40.6528139Z→22:05:37.3820274Z, SuiteExit 0, `SUITE 64 rows, 0 failures`; fe146c `db090559…`, рантайм G2 boot145a, tool146a | [terminal](records/pins/tp146-probe-a10.terminal.txt) |
| Whole boot146a | 22:15:42.9514930Z→22:33:59.0131237Z, BootstrapExit 0, 1096.06 с; `BOOTSTRAP quick 0 failures`; smoke 9/0 в обеих генерациях | [terminal](records/pins/boot146a-quick.terminal.txt), [log](records/pins/boot146a-quick.log) |
| Сверка | source 214/0; producers g1 и g2: frontend 33, runtime 39, tool 6 шагов, все exit 0; 248/248, 496 хэшей, 0 stale; 245 raw-equal; 3 равных по размеру PE отличаются только смещениями 136, 137, 216, 217; consumed 306/306 равны; working tool и bundle равны G2; driver и driver-observe равны G2 рантайму boot145a | [сверка](records/pins/boot146a-compare.txt) |
| G2 focus | 22:35:37.7276961Z→22:50:22.5172290Z, SuiteExit 0, `SUITE 64 rows, 0 failures` | [terminal](records/pins/tp146a-suite-g2.terminal.txt), [log](records/pins/tp146a-suite-g2.log) |
| Полный список на G2 | 22:50:40.3593264Z→23:04:44.9830668Z, SuiteExit 0, `SUITE 81 rows, 0 failures` | [terminal](records/pins/tp146-probe-fullg2.terminal.txt) |
| G2-наблюдение | `cbg2` 22:50:27.5533544Z→22:50:38.8685453Z, 40 PASS: `add` 2, `two` 8, `in_method`, `by_formal`, `by_index` по 1. WitnessExit 0, forced в обоих roots с точными счётчиками, native не обходит ни одно: 5 тел. До запуска по forced L1 кандидата проверено, что ни одно из пяти тел не держит native-слова; та же проверка на L1 `img2` среза 283 находит его у `write_index` | [cbg2](records/pins/tp146a-obs-cbg2.terminal.txt) |
| Разделение на кортеже 283 | см. выше | [terminal](records/pins/tp146-probe-sep284.terminal.txt) |

Tuple G2, `P/cold-boot146a/quick146a`:

| Артефакт | SHA-256 |
| --- | --- |
| `lmxtool.exe`, `g2/tool/lmxtool-tool.exe` | `ba82e4988ea88b8bda09a018818467b8f691b20f8cc1b9faf9d5a5148e4b4f13` |
| `g2/frontend/l2trans.exe` | `08db3ff3962531a000cf68995ecbe075a249dcd7c1ae2e5b6a73b606925e01e9` |
| `g2/frontend/l1trans.exe` | `ea0d785da0f6f76638921686e460022b85f9ea6369c7541eaf557ea491acd677` |
| `g2/frontend/l2_libc.o` | `af9fdae33655f8e6235310720787102921450f0f88f9b7bb2f365d372f553d37` |
| `g2/runtime/driver.o` | `194a251fd9815647a9f1e8643613f0429d78f75d5295e532710462ee9e9f68de` |
| `g2/runtime/driver-observe.o` | `9a8e1e053cd0de000920953a3d3d3c83a0090a6fca66b9d0a9d6ca69788a3eab` |

G0: `P/cold-tp140/tool146a/lmxtool-tool.exe` `41e2ea46f004b482cd2842cbb5d55ac424eebf89926eafabe80e82a86e320d8a`, собран `rebuild tool` из инструментов этого пакета: заголовок P0 в `tools/build.lm2` получил новый флаг. Предыдущий frontend — G2 среза 283, boot145a. Новый стенд не создавался: рабочий стенд `cold-tp140` совпадал с опубликованным selfbuild, изменения шли через `variants/tp146` и `pins/source-tp146.sha256`.

Посадка [land284](records/pins/land284.command): 8 шагов exit 0 ([terminal](records/pins/land284.terminal.txt)), 214 файлов, оба подмножества consumed равны frozen, `selfbuild/inputs.sha256` равен frozen.

## Границы и находки

- **Сообщение отказа.** `@: x Box\absent` и `@: p Inner \q` отказывают на объявлении общим `unknown type`: тип места берётся из листа пути, которого нет. Отказ при трансляции, но не на сегменте пути. Не менял.
- **native_closure_values.lm2** входит в пакет, но ни один из трёх списков пакета (`full-suite`, `smoke-kernel225`, `smoke`) его не запускает. Его три строки переписаны для согласованности; трансляцией они не проверены.
- **Индекс указателя на обходимом корне** (ROOT-POINTER-INDEX-WALKED, открыт). `int: a px[0U]` при `walkroot 1`: `walk error: UNSUPPORTED` в обоих режимах и на кортеже 283 ([p284k](records/cold-tp140/tests/dyn/p284k_root_pointer_index.lm2)); так же `two(px\[0U], \py)` в корне ([p284j](records/cold-tp140/tests/dyn/p284j_slash_index_comma.lm2)) при `walkroot 1`; путь через ссылку на корне проходит ([p284l](records/cold-tp140/tests/dyn/p284l_root_reference_path.lm2)). К запятой не относится, поэтому индексные случаи свидетеля стоят в методе. Не разбирал.
- **Классификаторы.** `lm_compiler_expr_span` метку не спрашивает. Проверка одного значения у приёмника типа и актуалы конструкции читают `x, -y` одним выражением, но значение затем читает разбор значения и отказывает (p284n). Свидетеля различия нет.
- **Точка с запятой в короткой форме.** `;`, завершающий короткую форму, помечает последнее поле внутри неё; сам Frame во внешней Structure не помечен. Путь от Frame не начинается, поэтому на чтение это не влияет.
- **Строка README.** `Input list` в `selfbuild/README.md` со среза 282 называла список 203 входов (`fc993576…`, пакеты 278–281): при 282 и 283 таблицу обновляли со строки manifest. Исправлено на список этого пакета.
- **Не закрыто.** U2 и U3 остаются открытыми. FULL на этих байтах не запускался.

## Документальная часть

Книга, L2 и грамматика не менялись, поэтому `docs render` не запускался. Проверка новым рабочим tool на проиндексированных путях среза, [docs284-check](records/pins/docs284-check.command): exit 0, [terminal](records/pins/docs284-check.terminal.txt), [log](records/pins/docs284-check.log). Evidence: [docs284](records/pins/docs284.command), оба шага exit 0, [terminal](records/pins/docs284.terminal.txt).
