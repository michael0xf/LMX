# Срез 283 — поля под местом callable, значение в этом месте, именованный отказ записи в immutable, написанная форма через голову-путь (седьмая часть U2/U3)

Опубликован 2026-11-05, Opus. Часть U3 [плана N4-U](../../../next_core_tasks_v3.md#code-data-occurrences). Норма: книга :322 (`Outer\Model: ()` адресует поле и даёт ему Structure), :437 и :451 (части метода — поля одной Structure, собственное поле физически в части `var`), :439 (допуск фактически выбранного вызова, отсутствие места — ошибка вызова), :441 (при двух и более головах голое имя не выбирает первое), :401, :409, :578 (достигнутая запись в immutable — неявный `interpreter`, объект не меняется). Норма не менялась.

Приёмка прошлого среза: Codex подтвердил поставленный объём 282, [дословно](records/pins/codex-282-review.txt). Его п.1 выполнен здесь: вопрос к норме в CALL-SELF-ASSIGNED-PLACE снят, код не менялся. П.2, граница `T \q`, — следующий срез.

P = build2/codex_fix250generationchain01. Архивные копии в [records](records) приведены к UTF-8 LF без BOM, хвостовых пробелов и цветовых кодов терминала; оригиналы в P связаны с [evidence.sha256](evidence.sha256).

## Что было неверно на кортеже 282

- `Callables\f\x` после `@: Callables\f replaced` читал прежнюю позицию в теле нового метода и получал чужое значение без отказа ([p282f](records/cold-tp140/tests/dyn/p282f_callable_path.lm2)). Запись шла туда же.
- Свободный `Hc\f\x` отказывал `implements` и до перепривязки: чтение по имени поля тела метода не находило ([p282ah](records/cold-tp140/tests/dyn/p282ah_free_callable_field.lm2)).
- Значение, записанное в место callable свободным держателем и не являющееся вызываемым с такими данными, падало при вызове: `invariant: a split-called code reached data without its place row` в native, `walk error: INVALID` в forced.
- Достигнутая запись в immutable: `walk error: INVALID`, обработчик её не получал.
- `Box\k: (int: a 8)` и `@: Box\k (int: a 8)`: отказ трансляции `int has no value` ([p281c](records/cold-tp140/tests/dyn/p281c_written.lm2), [p282ac](records/cold-tp140/tests/dyn/p282ac_at_inline.lm2)).

Разделение [sep283](records/pins/tp145-probe-sep283.terminal.txt): 38 рядов, 116 отказов на кортеже boot144b. Три фикстуры среза отказывают: callable_place_fields код 13, immutable_reached_write `walk error: INVALID`, written_path_form `int has no value` при трансляции; так же p282f (код 14), p282ah (R0 остановлен), p282ac и p281c (`int has no value`), пробы immutable, свободного значения в месте callable и написанной формы. Контроли map_chain, place_write_form, written_form, p283ac, p283ad и p283u проходят на обоих кортежах. Неизменные дефекты p283ah, p283ae, p283aa, p283aq, p283aj, p283h_im_ref дают на кортеже 282 то же, что на кандидате; p283af на кортеже 282 падает `invariant`, на кандидате проходит.

## Механизм

- **Поля под местом callable.** Сигнатура места ничего не говорит о полях стоящего там callable, поэтому хвост пути ниже callable-поля читается по имени над тем, что там стоит. `lm_compiler_path_walk_steps_from` делает шаги хвоста шагами по имени, если метод не machine; первое имя хвоста получает приставку `[]`, которую исходник написать не может (`lm_compiler_path_selector_text`), держатель читается типизированным префиксом (`lm_compiler_path_typed_prefix`). Чтение, запись и адрес идут общим маршрутом свободного пути, второго resolver нет.
- **Поиск в частях.** `lmx_walk_value_field_place` спрашивает обычный ответ, затем части: `lmx_implements_own_field`, а при `[N]` `lmx_implements_own_head_slot`. `lmx_implements_own_part`: `fn` держит собственные поля в `var` и `body`, другой callable в себе и в написанной части `var`. Здесь реестр голов не выводит имя из употребления: у места одно имя, сколько бы операторов ни стояло у этой головы; явный `Hc\f\body\x` при двух головах по-прежнему отказывает по реестру (книга :441). Свободный путь над `fn` спрашивает так же, поэтому `Hc\f\x` теперь находит.
- **Значение в месте callable.** Что там стоит, видно только при вызове. Книга :439 говорит об обычной Structure прямо: она исполняется явным ресивером `call`, `call: code` выбирает её `var`, недостающее место — ошибка допуска, и исполняемый код не входит. `lmx_implements_unary_admission` делает этот допуск: строка мест стоящего значения против его `var`; `fn` отвечает сразу, строки мест у него нет. Сайты: `lm_compiler_emit_call_arguments_full` в native, `lmx_walk_call_in` в обходчике. Отказ — неявный `call`, как у самого ресивера. Значение с нужными местами в `var` и значение без мест работают как при `call:` (коды 35, 36). Статически известное не-callable по-прежнему отказывает при трансляции (срез 282). Формы я не проверяю: первые пять попыток различать значения по форме провалились, см. находки.
- **Достигнутая запись в immutable.** Неявный `interpreter` до всякого изменения, RHS не вычисляется. Native: `lm_compiler_emit_path_write_guard` у записи через путь, `lm_compiler_emit_lvalue_write_guard` у записи через указатель и индекс, `lm_compiler_emit_own_store_guard` у записи полного значения в рабочую ячейку (`x: x + 3` кода над immutable-данными), ответ store у свободного указателя (`lmx_walk_value_store_with_writer`). Публикация сохраняет прежнюю фатальную охрану: она работает, когда оператор уже закончен, а сама неявная выдача публикует, так что иначе трансляция зациклилась бы; значение туда не дойдёт, потому что грязной ячейку делает только оператор, прошедший охрану. Обходчик: `lmx_walk_slot_place`, индекс, корень, `lmx_walk_field_target` и адрес в `PUT`.
- **Написанная форма через голову-путь.** Те же два акта, что у простой головы (срез 278): определение остаётся в теле, строка присваивает месту ссылку. `lm_compiler_written_path_form` узнаёт форму первой в `lm_compiler_repeated_form`, имя определения берётся по листу пути. `lm_compiler_place_write_lower` разворачивает единственную Structure, поэтому `@: Box\k (int: a 50)` даёт то же. Потреблённый Frame без объявления написанной формой не считается: `@: Holder\p Inner: Other` остаётся значением с требованием, а `var\caught: int: var\p` не читается как объявление. Свободный корень получает форму по объявлению в хвосте, без разрешения пути.

Runner, cache, второй resolver и скрытые корни не вводились.

## Свидетели

[tests/dyn/callable_place_fields.lm2](../../../selfbuild/tests/dyn/callable_place_fields.lm2), native и forced, оба roots:

| Код | Что проверяет |
| --- | --- |
| 11 | чтение до перепривязки |
| 12, 13 | после `@: Callables\f replaced`: вызов и поле на другой позиции |
| 14–17 | формал, локальная, свободный держатель, в выражении |
| 18 | запись через путь видна в `replaced\x` |
| 19–21, 37 | `with_var`: своя `var`, чужая `var` с полем на другой позиции, поле в теле; `[0]v` |
| 22–24 | `sub` с двумя головами, перепривязка, запись |
| 25, 26 | поля нет — `implements`; Structure в числе — `convert` |
| 27–29 | значение без нужного места (`Other`, две `int`, две Structure) в месте callable: `catch: call ()` |
| 30–32 | `Occurs\f\[0]x` и перепривязка, через свободный путь `Ho\f\[1]x` читает слот второй головы и даёт `convert` |
| 33, 34 | `Subs\t()` у `sub` без собственного поля и перепривязанный |
| 35, 36 | Structure с местом в `var` и без мест работают через место callable |

[tests/dyn/immutable_reached_write.lm2](../../../selfbuild/tests/dyn/immutable_reached_write.lm2):

| Код | Что проверяет |
| --- | --- |
| 21–23 | число, вложенное поле, слот через формал: обработчик получает, объект стоит |
| 24, 25 | то же через свободного держателя |
| 26 | отказ покидает метод и принимается вызывающим |
| 27, 28 | `\p: 9`, `p[0U]: 9` |
| 29, 30 | свободный указатель и индекс |
| 45 | собственный слот перепривязан на immutable, запись `Part\q` |
| 34, 35, 43 | код над immutable-данными пишет место по голому имени: с чтением, без него, результатом вызова C |
| 46 | код над immutable-данными перепривязывает слот по голому имени |
| 31–33, 36–42, 44, 47 | те же записи над обычным значением проходят |

[tests/dyn/written_path_form.lm2](../../../selfbuild/tests/dyn/written_path_form.lm2):

| Код | Что проверяет |
| --- | --- |
| 11–13 | поле-Structure, ссылочное поле, вложенный путь |
| 14–16 | метод, формал, именованная Structure |
| 17, 18 | другой порядок полей, повторное достижение |
| 19 | свободный корень |
| 20 | `@: Box\k (int: a 50)` |
| 21, 22 | значение без читаемого поля — `implements`, старое стоит |

Мутанты ([правки](records/pins/mut283.py.txt), [прогон](records/pins/runmut283.sh.txt), [результаты](records/pins/mut283.txt)):

| Мутант | Результат |
| --- | --- |
| `freefn`: свободный путь над `fn` не смотрит в части | пойман, callable_place_fields, native и forced: R0 остановлен |
| `ownfield`: помеченное имя не смотрит в части | пойман, то же |
| `ownhead`: `[N]` не смотрит в части | пойман, то же |
| `headcount`: вхождения не считаются | пойман, то же |
| `subself`: поле `sub` ищется только в `var` | пойман, то же |
| `fnbody`: поле `fn` ищется только в `var` | пойман, то же |
| `admitdata`: `var` не спрашивается, любой код над данными отказывает | пойман, то же |
| `admitrow`: интерфейс не спрашивается | пойман: native `invariant: a split-called code reached data without its place row`, forced `INVALID` |
| `callwalk`: обходчик не спрашивает допуск | пойман, forced `INVALID` |
| `callexec`: допуск только у `op = CALL` | пойман, forced `INVALID` |
| `callname`: отказ обходчика под именем `interpreter` | пойман, forced: R0 остановлен |
| `callnative`: native не спрашивает допуск | пойман, native `invariant` |
| `walkholder`, `walkindex`, `walkaddress`, `walkroot`, `walktarget`: охрана обходчика снова `INVALID` | пойманы, immutable_reached_write, forced `INVALID` |
| `storeplace`: store снова `INVALID` | пойман, immutable_reached_write, native `INVALID` |
| `pathguard`: охрана пути снова фатальна | пойман, immutable_reached_write, native `INVALID` |
| `lvalueguard`: охрана указателя и индекса снова фатальна | пойман, native и forced `INVALID` |
| `ownstore`, `ownvalue`: запись полного значения в рабочую ячейку снова фатальна | пойманы: `ownstore` native `INVALID`; `ownvalue` на fe145q native и forced `INVALID` |
| `namedtail`: хвост под callable снова позиционный | пойман, callable_place_fields, native и forced: код 13 |
| `marktext`: первое имя хвоста без пометки | пойман, callable_place_fields: R0 остановлен |
| `typedprefix`: корень хвоста снова привязка пути | пойман: `unknown field path segment` при трансляции |
| `pathvalue`: значение под требованием читается написанной формой | пойман, explicit_data_var_field |
| `writtenpath`, `writtenroot`, `writtenbody`: форма через голову-путь не узнаётся на своём сайте | пойманы: `int has no value` при трансляции |
| `leafname`: определение называется всей головой | пойман: `a binding needs a name` |
| `atparens`: скобки в `@: Box\k (...)` остаются одним операндом | пойман, written_path_form: R0 остановлен |
| `composes`: потреблённый Frame читается написанной формой | пойман, place_write_form |
| `declares`: объявлению нужен разрешённый путь | пойман: `a numeric receiver requires one value` |
| `admitfn`: `fn` тоже спрашивает строку мест | выжил по замыслу: ветка о стоимости, строки у `fn` нет |
| `headplace`, `callnocontract`, `walkslot`, `walkfree`, `walkstorage`, `walkput`, `storenumber` | выжили, код снят или возвращён к опубликованному |
| `ownwork`, `owncellvalue`, `ownctx`, `ownfresh`, `defrole` | выжили, код возвращён к опубликованному |

Мутанты шли на кандидате своего момента, `headcount` повторён на итоговом ядре, потому что его текст менялся. Первый прогон ядра не поймал 11 из 24. Разбор такой. `headplace`: часть метода всегда имеет строки голов, поэтому ветка для части без них не нужна, снята. `callnocontract`: ответ `interpreter` у вызова с аргументами не был никем достигнут и по смыслу был бы `call`, ответ возвращён к опубликованному, случай записан в CALLABLE-PLACE-FREE-SIGNATURE. `walkfree`, `storenumber`, `walkstorage`, `walkput`, `walkslot`: перед ними стоит охрана того же значения либо программы я не нашёл, ответ возвращён к опубликованному `INVALID`. `walkholder`, `walkindex`, `walkaddress`, `storeplace` получили свидетелей: и это вскрыло, что native на `\p: 9`, `p[0U]: 9` и собственной ячейке всё ещё падает. Поэтому появились `lm_compiler_emit_lvalue_write_guard` с именем и `lm_compiler_emit_own_store_guard`. `admitfn` выживает по замыслу: ветка только о стоимости, строки мест у `fn` нет.

Мутанты frontend я разнёс по всем пяти сайтам собственной ячейки, потому что общий мутант `ownstore` сайты не различал. Поймана только запись полного значения в рабочую ячейку (`ownvalue`). `ownwork`, `owncellvalue`, `ownctx`, `ownfresh` выжили, `ownwork` также на `x: 3`, результате вызова C и char-месте ([p283ar](records/cold-tp140/tests/dyn/p283ar_im_own_char.lm2)), поэтому эти сайты возвращены к опубликованному тексту. Параметр catch над именем места отказывает при трансляции `a catch parameter hides a visible name` ([p283au](records/cold-tp140/tests/dyn/p283au_im_catch_param.lm2)), а параметр с новым именем в данных места не занимает, и код над immutable-данными проходит ([p283aw](records/cold-tp140/tests/dyn/p283aw_im_catch_free.lm2)); перепривязка слота ([p283ay](records/cold-tp140/tests/dyn/p283ay_im_own_slot_top.lm2), теперь код 46) проходит и на мутантах `ownfresh`, `ownctx`, `owncellvalue`. Форма catch в Structure не транслируется: `throws:` стоит только первым пунктом головы метода ([p283as](records/cold-tp140/tests/dyn/p283as_im_own_catch.lm2)). `defrole`, снятие роли 4096 с определения, тоже выжил и снят: определение идёт по имени, которое ни одно чтение роли не находит.

## Приёмка на замороженных байтах

Вход: 211 файлов (65 source, 34 tools, 112 tests), manifest `44404a528737263c5871277adc92c83f87f820929b0001bf976b974ecff62b76`, `P/cold-boot145a`.

| Проверка | Результат | Receipt |
| --- | --- | --- |
| Whole boot145a | 18:33:17.0533815Z→18:46:47.2344071Z, BootstrapExit 0, 810.18 с; `BOOTSTRAP quick 0 failures`; smoke 9/0 в обеих генерациях | [terminal](records/pins/boot145a-quick.terminal.txt), [log](records/pins/boot145a-quick.log) |
| Сверка | source 211/0; producers g1 и g2: frontend 33, runtime 39, tool 6 шагов, все exit 0; 248/248, 496 хэшей, 0 stale; 245 raw-equal; 3 равных по размеру PE отличаются только смещениями 136, 137, 216, 217; consumed 306/306 равны; working tool и bundle равны G2; driver и driver-observe равны изолированному rt145o | [сверка](records/pins/boot145a-compare.txt) |
| G2 focus | 18:48:19.5596910Z→19:00:54.7629969Z, SuiteExit 0, `SUITE 61 rows, 0 failures` | [terminal](records/pins/tp145a-suite-g2.terminal.txt), [log](records/pins/tp145a-suite-g2.log) |
| Полный список на G2 | 19:02:51.8220070Z→19:14:53.2955751Z, SuiteExit 0, `SUITE 81 rows, 0 failures` | [terminal](records/pins/tp145-probe-fullg2.terminal.txt) |
| G2-наблюдение | `cpg2` 19:00:59.7093493Z→19:01:36.9010370Z, 106 PASS: `by_formal`, `by_local`, `read_free`, `by_free`, `write_free`, `non_callable`, `write_free2`, `non_callable2`, `write_free3`, `non_callable3`, `absent`, `other_kind`, `over_var`, `no_data`, `free_first`, `free_second` по 1; `img2b` 19:17:15.3853232Z→19:18:11.5932167Z, 100 PASS: `write_slot`, `through_slot`, `takes`, `leaves` по 1, `write_number`, `write_nested`, `through_number`, `write_deref`, `through_deref`, `through_index`, `write_own`, `write_own_only`, `write_own_c`, `write_hosted`, `write_own_slot` по 2; `wpg2` 19:02:36.4604737Z→19:02:50.1347434Z, 58 PASS: `in_method`, `by_formal`, `other_order`, `repeated`, `written_free`, `through_free`, `refused`, `reader` по 1. WitnessExit 0 у всех, forced в обоих roots с точными счётчиками, native не обходит ни одно: 39 тел. Первый прогон `img2` с `write_index` отказал: в forced L1 у этого метода native-слово, тело не обходится, и так же на кортеже 282; в теле `p[0U]: 9`, причину не разбирал; receipt сохранён | [cpg2](records/pins/tp145a-obs-cpg2.terminal.txt), [img2b](records/pins/tp145a-obs-img2b.terminal.txt), [wpg2](records/pins/tp145a-obs-wpg2.terminal.txt), [img2](records/pins/tp145a-obs-img2.terminal.txt) |
| Разделение на кортеже 282 | см. выше | [terminal](records/pins/tp145-probe-sep283.terminal.txt) |
| Все пробы среза на кандидате | 56 рядов: 20 дают другой код, все записаны в границах и находках | [terminal](records/pins/tp145-probe-final283.terminal.txt) |

Tuple G2, `P/cold-boot145a/quick145a`:

| Артефакт | SHA-256 |
| --- | --- |
| `lmxtool.exe`, `g2/tool/lmxtool-tool.exe` | `6d0c44248c1e5b2de37990ea1875d29591c8f475391dc4f4dc7e011f8efbe0a2` |
| `g2/frontend/l2trans.exe` | `568b28408d93a51f69182d259e6bbc0eacb00a5b22d232a8c12023f275575281` |
| `g2/frontend/l1trans.exe` | `3650b5c7356aa115e462482ce5c41de123f519cc75c496ffcde8223345b0ecdc` |
| `g2/frontend/l2_libc.o` | `af9fdae33655f8e6235310720787102921450f0f88f9b7bb2f365d372f553d37` |
| `g2/runtime/driver.o` | `194a251fd9815647a9f1e8643613f0429d78f75d5295e532710462ee9e9f68de` |
| `g2/runtime/driver-observe.o` | `9a8e1e053cd0de000920953a3d3d3c83a0090a6fca66b9d0a9d6ca69788a3eab` |

G0: `P/cold-tp140/tool145g/lmxtool-tool.exe` `f48be9f496aae490f4d0df26a982d90e4e97ec8948d3a1fddd2824d5072b8a4b`. Предыдущий frontend — G2 среза 282, boot144b. Новый стенд не создавался: рабочий стенд `cold-tp140` совпадал с опубликованным selfbuild, изменения шли через `variants/tp145` и `pins/source-tp145.sha256`.

Посадка [land283](records/pins/land283.command): 8 шагов exit 0 ([terminal](records/pins/land283.terminal.txt)), 211 файлов, оба подмножества consumed равны frozen, `selfbuild/inputs.sha256` равен frozen.

## Границы и находки

- **Не закрыто.** U2 и U3 остаются открытыми. FULL на этих байтах не запускался.
- **`sub` с собственным полем при вызове** (SUB-OWN-FIELD-CALL). При любом вызове, в том числе прямом ([p283ah](records/cold-tp140/tests/dyn/p283ah_sub_own_direct.lm2)): native `walk error: UNSUPPORTED`, forced `INVALID`, на обоих кортежах. Поля `sub` читаются и пишутся этим срезом (коды 22–24), но вызвать такой `sub` нельзя. `sub` без поля работает, в том числе перепривязанный (коды 33, 34).
- **`fn` другой сигнатуры через свободного держателя** (CALLABLE-PLACE-FREE-SIGNATURE, [p283ae](records/cold-tp140/tests/dyn/p283ae_other_signature.lm2)): native `invariant: a trampoline was called outside its method's signature`, forced `UNSUPPORTED`, на обоих кортежах. Статически такая запись отказывает при трансляции (срез 282). Вызов с аргументами обычной Structure в месте callable по-прежнему `INVALID`.
- **Прямой вызов именованного тела со строками.** `Proc()` останавливает R0 необработанным отказом ([p283aa](records/cold-tp140/tests/dyn/p283aa_procedure_named_body.lm2)), на обоих кортежах. Не разбирал.
- **Что осталось фатальным в immutable.** Публикация по замыслу, см. механизм. Сайты собственной ячейки без свидетеля: значение без записи `LmxWalkValue` (`lm_compiler_own_work_store_context`) и прямая ячейка (`lm_compiler_own_cell_store_value`, `lm_compiler_own_cell_store_context`). Обход рабочей ячейки через вычисленного держателя и второй контур store (`lmx_walk_work_cell`, `lmx_walk_store_numeric_into`, запись дескриптора, `PUT_REF`) остались с `INVALID`, потому что программы, которая дошла бы до них мимо первой охраны, я не нашёл; значит, и утверждать про них нечего. Ссылочное поле: [p283h_im_ref](records/cold-tp140/tests/dyn/p283h_im_ref.lm2) в native `INVALID`, в forced `PRIMITIVE` (IMMUTABLE-REFERENCE-CELL-WALKED).
- **Array в immutable-значении** (IMMUTABLE-ARRAY-FIELD). Даже чтение: [p283aq](records/cold-tp140/tests/dyn/p283aq_im_array_read.lm2) в native `INVALID`, в forced `PRIMITIVE`, на обоих кортежах. Поэтому запись в элемент такого Array ([p283aj](records/cold-tp140/tests/dyn/p283aj_im_elem.lm2)) не проверена. Запись через указатель и индекс на число проверена кодами 27–30.
- **Ссылочное место кода над прямым слотом данных.** `@: Inner Other` в коде и `Inner:` в данных: `call: held Data` отказывает `call` и без immutable ([p283ap](records/cold-tp140/tests/dyn/p283ap_own_slot_plain.lm2), [p283am](records/cold-tp140/tests/dyn/p283am_im_own_slot.lm2)). gdb: `lmx_implements_call_field` спрашивает `Inner` типа 1124, типизированная ссылка, а в данных прямая Structure. Норму совместимости здесь не разбирал, записываю как факт. Слот только в `var` данных ([p283ax](records/cold-tp140/tests/dyn/p283ax_own_slot_var_plain.lm2), [p283at](records/cold-tp140/tests/dyn/p283at_im_own_slot_var.lm2)): тоже `call`, `lmx_implements_call_field` спрашивает `Inner` типа 8 у самих данных. С `Inner` на верху данных проходит (код 46 и [p283az](records/cold-tp140/tests/dyn/p283az_own_slot_top_plain.lm2)).
- **Границы формы места.** Типизированный `Callables\f\[1]x` при трансляции `unknown field path segment`, объявление одно; свободный читает слот второй головы. Callable на конце пути и machine-метод типизированы: `Callables\outer\inner()` читается позиционно. Свободный путь через `sub` с двумя головами: `implements` (книга :441). Запись `Box\n: (int: a 8)` в число: `a reference where a number is asked` при трансляции ([p283y](records/cold-tp140/tests/dyn/p283y_boundary_number.lm2)), WRITTEN-FORM-OVER-NUMBER.
- **`lm_compiler_part_root`** строит безымянный корень. Не воспроизводилось, это рассуждение, а не замер.
- **Стоимость допуска.** Обходчик спрашивает допуск при каждом вызове без данных: `fn` отвечает сразу, `sub` проходит линейный поиск строк имён. Отдельно не измерялось.
- **Шесть попыток формы, пять неудачных.** Я начал с вопроса «это callable?»: `fn` или две первые Structure (`Other3` с двумя Structure проходит, native падает `invariant`); проверка только у `op = CALL` (`Places\f()` идёт через `EXEC`, forced остаётся `INVALID`); фреймы, не части (только forced); `var` по имени (у `sub` нет `var`, `sub` падает); безымянные первые части (слоты `sub` называются `args` и `return`). Книга :437 это и говорит: обычная Structure вправе иметь те же части, проверка не по четырём именам. Правильным оказался допуск выбранного вызова. Первая версия отказа называлась `interpreter`; это ошибка вызова, а не операции над графом, поэтому `call`.
- **Ошибка диагноза.** `INVALID` без `EVAL` после `ACTIVATE` я принял за запись `@: Places\f Hv`; трасса `lmx_walk_entry_node` и `lmx_walk_place_open` показала активацию следующего вызываемого.
- **Регрессия, найденная пробой.** [p283u](records/cold-tp140/tests/dyn/p283u_occurrence_after_callable.lm2): `Callables\f\[0]x` проходит на кортеже 282 и падал на кандидате, селектор `[][0]x` искал имя `[0]x`. Разбор `[]` и `[N]` разделён.
- **Нарушение границ.** В начале среза `ls` без аргументов в каталоге запуска пробы напечатал защищённый basename. Содержимое не читалось. Сообщено Codex, память обновлена.
- **Остановка по памяти.** Прогон мутантов frontend был снят защитой харнесса, но `bash runmut283.sh` и его цепочка продолжали жить без родителя на стенде с мутацией. Цепочка снята по сверенным командным строкам, стенд восстановлен через prepare, Codex проверил независимо. Источник давления замером не установлен. По правилу Codex дальше перед каждым тяжёлым шагом читается свободная физическая и виртуальная память, запас не менее 4 GiB каждой; мутанты возобновлены с места остановки под новыми метками. Неполный прогон `ownfresh` сохранён.

## Документальная часть

Книга, L2 и грамматика не менялись, поэтому `docs render` не запускался. Проверка новым рабочим tool на проиндексированных путях среза, [docs283-check](records/pins/docs283-check.command): exit 0, [terminal](records/pins/docs283-check.terminal.txt), [log](records/pins/docs283-check.log). Evidence: [docs283](records/pins/docs283.command), оба шага exit 0, [terminal](records/pins/docs283.terminal.txt).
