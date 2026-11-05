# Срез 282 — форма `@` с путём как местом и значением, `x: var\i` (шестая часть U2/U3)

Опубликован 2026-11-05, Opus. Часть U3 [плана N4-U](../../../next_core_tasks_v3.md#code-data-occurrences). Норма: книга :313–:315 и :373 (двухполевой `@`, голый атом не вызов), :353 (неизвестная голова определяет Structure), план U3: «Это же правило применяется к явному пути принимающего места, без runtime-типа „ресивер“ по одному написанию». Норма не менялась. Книга пишет о первом поле как об атоме имени места; расширение на путь записано только в плане, текст книги этот срез не менял.

Приёмка прошлого среза: Codex независимо проверил 281 и подтвердил поставленный объём, строки реестра остаются открытыми, [дословно](records/pins/codex-281-verified.txt).

P = build2/codex_fix250generationchain01. Архивные копии в [records](records) приведены к UTF-8 LF без BOM, хвостовых пробелов и цветовых кодов терминала; оригиналы в P связаны с [evidence.sha256](evidence.sha256).

## Что было неверно на кортеже 281

- `@: Box\f two`: отказ трансляции `unknown type`. Форма читалась как объявление, вторым полем шёл `\`.
- `Box\f: two` у callable-поля по книге вызов, поэтому поменять ссылку на метод в поле через путь было нечем, кроме свободного держателя.
- `@: seen Outer\Model` читалось как требование `Outer` и значение `\Model`, поэтому `seen\v` даёт `unknown field path segment` (BARE-PATH-REQUIREMENT-READ).
- `got: var\i` при объявленном `got`: отказ `a free name is read where a typed native value is required`. Путь через свободный корень шёл типизированным маршрутом копирования. `int: got var\i` работал и раньше.

Разделение [sep282](records/pins/tp144-probe-sep282.terminal.txt): 17 строк, 26 отказов. Десять программ не транслируются: `unknown type` у формы `@` с путём, `unknown field path segment` у `@: x a\b`, `a free name is read where a typed native value is required` у `got: var\i`. Три фикстуры отказа отказывают другими словами. Контроли `p282o_var_rebound`, `p282r_two_heads_self`, `map_chain`, `written_form` проходят: эти случаи кортеж 281 уже умел.

## Механизм

- **Понижение.** [lm_compiler_place_write_lower](../../../selfbuild/src/l2src/l2_frontend_core.lm2): форма `@` с путём первым операндом и чем-то после него становится записью этого места: голова — текст пути, тело — значение, флаг роли кадра 4096 (`lm_compiler_place_write_node`). Форма сама говорит, что она такое, поэтому понижение идёт одним проходом по телам в начале `lm_compiler_translate_unit`, после сброса памяти трансляции: сначала на проходе разбора оно не годилось, память понижения освобождалась сбросом ([красный прогон](records/pins/tp144-probe-a01.terminal.txt)). Невыбранные ветви `os` не трогаются. Один операнд (`@: Box\f`) остаётся адресом.
- **Ничего не вызывается.** Просто `Box\f: two` у callable — вызов, поэтому роль на узле: `lm_compiler_head_is_call` отвечает 0, сбор фактических, связывание и обходчик не связывают форму как вызов.
- **Запись.** Callable-поле идёт store слота, как поле, держащее Structure: `lm_compiler_path_write_by_slot` и `lm_compiler_rw_path_write_rec`. Значения допускаются по правилу именованной ссылки: метод другой сигнатуры и значение, известное как не callable, отказывают при трансляции теми же словами (`lm_compiler_method_candidate_for`, `lm_compiler_method_source_guard_for`). Числовое поле: `a number field is no reference place`.
- **Null в callable-поле.** Вызов через путь теперь проверяет слот: `@: Box\f 0`, затем `Box\f()` — неявный `interpreter`. Раньше null туда записать было нечем.
- **`@: place Model: value`.** Книга :315: потреблённый Frame даёт кандидата с требованием `Model` и в `Model` не пишет (`lm_compiler_place_write_value`). Native и обходчик проводят оба допуска, свободный держатель тоже.
- **`@: x a\b`.** `lm_compiler_value_path_run`: второй операнд — путь, если он находит поле. Лист даёт требование (`lm_compiler_path_type_model`, `lm_compiler_requirement_method` для callable), сам путь — значение, как у голого `@: x Model`. После пути может стоять отдельное значение: `@: held Source\r Second`.
- **Различение `@: x a\b` и `@: p T \q`.** P0 даёт одни и те же поля, пробелы вокруг `\` — стиль (автор, 2026-10-27), запятая границы пока не даёт (BARE-DEREF-ACTUAL-MERGED). Поэтому решает разрешение, как у любой головы: путь, дошедший до поля, — путь; `@: p int \q` и `@: p Model \q` без поля `q` в `Model` — требование и разыменование. Первая версия читала как путь всё подряд и уронила пять фикстур `free_*`, см. находки. Следствие: `@: p Model \q` при поле `q` в `Model` теперь путь.
- **`x: var\i`.** `lm_compiler_path_store_general_resolved`: путь через свободный корень идёт общим store полной записью значения, как начальное значение объявления.

Нового прохода по смыслу, runner, cache и второго resolver нет. Понижение чисто синтаксическое.

## Свидетели

[tests/dyn/place_write_form.lm2](../../../selfbuild/tests/dyn/place_write_form.lm2), native и forced, оба roots:

| Код | Что проверяет |
| --- | --- |
| 11 | `@: Holder\f two` в корне: поле зовёт новый метод |
| 12, 13 | то же у поля-Structure и ссылочного поля |
| 14 | `@: Holder\p 0`: чтение через поле даёт `interpreter` |
| 15 | `@: Holder\p Inner: Other` |
| 16–20 | метод, типизированный формал, локальная, вложенное тело, тело именованной Structure |
| 21 | `@: Holder\last 0`, вызов даёт `interpreter`, запись в обработчике чинит |
| 22 | `@: g Holder\f` держит то, что стояло, следующая запись поля `g` не двигает |
| 23 | свободный держатель: `@: Hb\h two`, `@: Hb\p Inner: Other` |
| 24–26 | `@: seen Source\Model`, ссылочный лист, повтор `@` через другой путь |
| 27–29 | в методе, callable на листе, путь с отдельным значением |
| 30 | `got: var\i` с данными вызова |
| 31 | поля нет в данных: чтение отказывает `implements`, запись перед ним стоит |
| 32 | `got: var\i` без `got` в коде: голова определяет Structure (книга :353), число данных ей не место, `call` отказывает до исполнения |
| 33 | `int: got var\i` после записанной `var` |
| 34 | элемент Array ссылок как место: `@: refs[1] Other` |
| 35, 36 | отказ допуска: `Inner: NoQ` и `@: Holder\k NoQ` при известном читателе `q`, старое значение стоит |
| 37 | запись callable-поля, затем перепривязка держателя |

Строки отказа: [place_write_number_refused](../../../selfbuild/tests/dyn/place_write_number_refused.lm2), [place_write_signature_refused](../../../selfbuild/tests/dyn/place_write_signature_refused.lm2), [place_write_struct_refused](../../../selfbuild/tests/dyn/place_write_struct_refused.lm2), [value_path_number_refused](../../../selfbuild/tests/dyn/value_path_number_refused.lm2).

Мутанты ([правки](records/pins/mut282.py.txt), [прогон](records/pins/runmut282.sh.txt), [результаты](records/pins/mut282.txt)):

| Мутант | Результат |
| --- | --- |
| Голова формы снова вызов (`headcall`) | `more arguments than Holder\f has formals` в `place_write_form`, другие слова у `place_write_signature_refused` |
| Сбор фактических связывает форму как вызов (`scancall`) | то же |
| Связывание вызова читает форму (`bindcall`) | то же |
| Обходчик читает форму как вызов (`rwcall`) | `more arguments than Holder\f has formals` в `place_write_form` |
| Callable-поле теряет store слота в native (`byslot4`) | `internal: a refusal said nothing`: трансляция падает без диагностики |
| Обходчик не принимает callable-место (`rwleaf4`) | `root operation not walkable yet: a field path` |
| Требование пути снова целое слово (`pathmodel`) | `unknown type` на `@: seen Source\Model` |
| Callable на листе не требование (`pathmethod`) | `unknown type` на `@: g Holder\f` |
| `@: x a\b`: путь больше не значение (`pathvalue`) | все четыре конфигурации: R0 остановлен |
| `x: var\i` снова типизированным маршрутом (`freegeneral`) | `a free name is read where a typed native value is required` |
| `@: place Model: value` без требования (`asserted`) | `root operation not walkable yet: this operand` |
| Null в callable-поле вызывается без проверки (`nullcall`) | native на обоих roots: `invariant: a dynamic call of a value that is not a Structure`, forced проходит |
| Нет отказа по сигнатуре (`signature`) | `place_write_signature_refused`: другие слова |
| Нет отказа не-callable (`guard`) | `place_write_struct_refused`: трансляция проходит |
| Нет отказа числового поля (`number`) | `place_write_number_refused`: трансляция проходит |
| Роль в `lm_compiler_frame_is_call` (`frameiscall`) | **не пойман**, код убран |
| Держимый callable в обходчике и в сборе (`rwheld`, `scanheld`) | **не пойманы**, код убран |
| Лист вида 4 в `lm_compiler_src_path_write` (`srcwrite4`) | **не пойман**, код убран |
| `lm_compiler_use_written` у callable-места (`usewritten4`) | **не пойман дважды**, код убран |

Четыре мутанта не были пойманы программой, и я убрал сам код: проверка роли в `lm_compiler_frame_is_call` (`frameiscall`), две проверки держимого callable (`rwheld`, `scanheld`: у головы-пути его не бывает), лист вида 4 в `lm_compiler_src_path_write` (`srcwrite4`: классификация и так отвечает да). Пятый, `usewritten4`, выжил и после свидетеля 37: план места ничего не спрашивает ниже callable, код тоже убран. После этого фикстуры прогнаны заново.

## Приёмка на замороженных байтах

Вход: 208 файлов (65 source, 34 tools, 109 tests), manifest `2370e8f5748e2f4c96bfd10e36c35932a094e340fd417ed465767bd18d198420`, `P/cold-boot144b`.

| Проверка | Результат | Receipt |
| --- | --- | --- |
| Whole boot144b | 04:34:42.1669525Z→04:54:20.4543469Z, BootstrapExit 0, 1178.29 с; `BOOTSTRAP quick 0 failures`; smoke 9/0 в обеих генерациях | [terminal](records/pins/boot144b-quick.terminal.txt), [log](records/pins/boot144b-quick.log) |
| Сверка | source 208/0; producers g1 и g2: frontend 33, runtime 39, tool 6 шагов, все exit 0; 248/248, 496 хэшей, 0 stale; 245 raw-equal; 3 равных по размеру PE отличаются только смещениями 136, 137, 216, 217; consumed 306/306 равны; working tool и bundle равны G2; driver и driver-observe равны изолированному rt144a | [сверка](records/pins/boot144b-compare.txt) |
| G2 focus | 04:54:43.0470032Z→05:08:10.9513113Z, SuiteExit 0, `SUITE 58 rows, 0 failures` | [terminal](records/pins/tp144b-suite-g2.terminal.txt), [log](records/pins/tp144b-suite-g2.log) |
| Полный список на G2 | 05:09:06.0165376Z→05:23:07.4741602Z, SuiteExit 0, `SUITE 81 rows, 0 failures` | [terminal](records/pins/tp144-probe-fullg2b.terminal.txt) |
| G2-наблюдение | `formg2` 05:08:15.9480501Z→05:09:04.3703660Z, 100 PASS, WitnessExit 0: `in_method`, `by_formal`, `by_local`, `nested`, `null_called`, `chain`, `hidden_writes`, `through_hidden`, `value_in_method`, `value_callable`, `value_with_initial`, `var_absent`, `var_new`, `asserted_refused`, `store_refused` по 1. Forced в обоих roots с точными счётчиками, native не обходит ни одно: 15 тел | [formg2](records/pins/tp144b-obs-formg2.terminal.txt) |

Tuple G2, `P/cold-boot144b/quick144b`:

| Артефакт | SHA-256 |
| --- | --- |
| `lmxtool.exe`, `g2/tool/lmxtool-tool.exe` | `e7c5cec1d2042c47fd54cb82643d97fe24fdef12b28c565a7a980b2dc0db1398` |
| `g2/frontend/l2trans.exe` | `ba51e5946b90eabc2bd4cf9d22686bcce788e9993d44d2da4afbd305df959d07` |
| `g2/frontend/l1trans.exe` | `f1036dc8b7c2162e1a2b83ca90b23ce384f8de1a8adad5ea4d311066e7a4e804` |
| `g2/frontend/l2_libc.o` | `af9fdae33655f8e6235310720787102921450f0f88f9b7bb2f365d372f553d37` |
| `g2/runtime/driver.o` | `2909cd9f66bf682110f68b051d7f18c06d8019e7c1ad542e96ab03e3d8cf0bc4` |
| `g2/runtime/driver-observe.o` | `c2cdff5bcc352495c56565401fa0fcbd7baa4956e15374f2377e1e075479a673` |

G0: `P/cold-tp140/tool144a/lmxtool-tool.exe` `880c011e6024b949a9eff23397681d1d4d4ab0189cb6523066aa4a76101c43a6`. Предыдущий frontend — G2 среза 281, boot143a. Новый стенд не создавался: рабочий стенд `cold-tp140` совпадал с опубликованным selfbuild, изменения шли через `variants/tp144` и `pins/source-tp144.sha256`.

Посадка [land282](records/pins/land282.command): 8 шагов exit 0 ([terminal](records/pins/land282.terminal.txt)), 208 файлов, оба подмножества consumed равны frozen, `selfbuild/inputs.sha256` равен frozen.

## Границы и находки

- **Не закрыто.** U2 и U3 остаются открытыми. FULL на этих байтах не запускался.
- **Типизированный путь через перепривязанный callable читает по позиции** (TYPED-PATH-THROUGH-REBOUND-CALLABLE, S10). [p282f](records/cold-tp140/tests/dyn/p282f_callable_path.lm2): после `@: Callables\f replaced` вызов `Callables\f()` даёт 7, а `Callables\f\x` читает вторую позицию у метода с другими полями и получает 9, код [14](records/pins/tp144-probe-a07.terminal.txt). Это тихое неверное значение. Форма записи стала проще, но сам путь существовал и раньше через свободного держателя. Через свободного держателя `Hc\f\x` отказывает `implements` и до перепривязки ([p282ah](records/cold-tp140/tests/dyn/p282ah_free_callable_field.lm2)): чтение по имени поля тела метода не находит. Следующий срез.
- **Поле корня части как скрытый вход** (`lm_compiler_own_ctr`, S10): не воспроизводилось и не менялось.
- **Свободное значение в callable-поле** (CALLABLE-PLACE-FREE-NONCALLABLE). Статически известное значение отказывает при трансляции, а свободное, держащее обычную Structure, записывается, и вызов падает: `invariant` в native, `walk error: INVALID` в forced, [p282al](records/cold-tp140/tests/dyn/p282al_at_free_value.lm2), [прогон](records/pins/tp144-probe-a17o.terminal.txt). В рантайме нет готового ответа «это callable»: роль FN есть только у `fn`, у `sub` её нет. Форма со свободным держателем существовала и раньше.
- **Вызов через свободный корень**: `Hb\f()` отказывает при трансляции `a call path must end at a callable field` ([p282x на прошлой правке](records/pins/tp144-probe-a08.terminal.txt)). Запись работает, вызов нет.
- **Границы формы.** Прогон [a17o](records/pins/tp144-probe-a17o.terminal.txt): индекс с вызовом `@: refs[first()] Inner` и `@@: Box\p Inner` остаются с прежним `unknown type`; `@: refs[1] Inner: Other` отказывает `root operation not walkable yet: this operand` ([p282ak](records/cold-tp140/tests/dyn/p282ak_at_index_asserted.lm2)). `@: Box\k (int: q 8)` даёт то же `int has no value`, что и WRITTEN-FORM-THROUGH-PATH-HEAD ([p282ac](records/cold-tp140/tests/dyn/p282ac_at_inline.lm2)). `@: x Box\absent` по новому чтению остаётся требованием и разыменованием, отказа при трансляции нет ([p282z](records/cold-tp140/tests/dyn/p282z_value_absent.lm2)).
- **Вопрос: две головы при `call: Code Code`.** `int: got 0; got: 5` под `call: Code Code` отказывает `call` ([p282r](records/cold-tp140/tests/dyn/p282r_two_heads_self.lm2), тот же отказ у [p282q](records/cold-tp140/tests/dyn/p282q_var_self.lm2) с `var\i`), с отдельными данными проходит (код 30). Это согласуется с решением Codex о двух головах, но книга :337 говорит о двух вхождениях, что это не два поля данных. Не менял, строка реестра CALL-SELF-ASSIGNED-PLACE.
- **`y: var\i` при записанной `var` в том же теле**: [p282e](records/cold-tp140/tests/dyn/p282e_var_new.lm2) отказывает `unknown field path root`. По книге :353 голова определяет Structure с удержанным телом; корень `var` в процедуре `y` не разрешается. Не разбирал.
- **Порядок эффектов U4.** Код 31 закрепляет нынешнее поведение: запись до отказа чтения остаётся. План U4 этот порядок ещё не решил, поэтому это запись факта, а не норма.
- **Первая приёмка не прошла.** Whole [boot144a](records/pins/boot144a-quick.terminal.txt) прошёл, но [G2 focus](records/pins/tp144a-suite-g2.terminal.txt) дал 10 отказов: пять фикстур `free_*` с `@: p int \quote` читались как путь `int\quote`. Я проверял только свои пробы. Квитанции оставлены, чтение исправлено разрешением, собран boot144b.
- **Ошибки в моих пробах.** Несколько проб ждали не то: `p282n` с полем кода, которого нет в данных, `p282c` первой редакции с `call: Code`, который выбирает `Code\var`, `p282h` с catch трёх других имён, `p282x` с формалом без типа. Причины разобраны, ожидания поправлены, красные прогоны оставлены.
- **Нарушения границ.** В начале среза я выполнил `ls` с glob, `grep -r` по стенду и `git status` без точных путей; последний напечатал защищённый basename. Содержимое не читалось. Сообщено Codex, его ответ в [приёмке 281](records/pins/codex-281-verified.txt), память обновлена.

## Документальная часть

Книга, L2 и грамматика не менялись, поэтому `docs render` не запускался. Проверка новым рабочим tool на проиндексированных путях среза, [docs282-check](records/pins/docs282-check.command): exit 0, [terminal](records/pins/docs282-check.terminal.txt), [log](records/pins/docs282-check.log). Evidence: [docs282](records/pins/docs282.command), оба шага exit 0, [terminal](records/pins/docs282.terminal.txt).
