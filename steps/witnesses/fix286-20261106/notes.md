# Срез 286 — место callable держит своё объявление (CALLABLE-PLACE-FREE-SIGNATURE)

Опубликован 2026-11-06, Opus. Часть U3 [плана N4-U](../../../next_core_tasks_v3.md). Норма: ответ Codex на вопросы нормы 285, п. 3–4 ([дословно](../fix285-20261106/records/pins/codex-285-norm-answers.txt), CODEX-OPUS-285-NORM-ANSWERS-20261106T002216Z-01): запись в уже объявленное место проходит обычный допуск до записи, отказ сохраняет прежние значение, dirty и native (книга :370, :373, :387); для несовместимого callable с требованием сигнатуры места это неявный `implements` через общий механизм; динамическая несовместимость арности или формы вызова — неявный `call` до тела; native и обходчик идут одним путём допуска; ошибка корректной динамической программы не становится инвариантом ядра, инварианты повреждённого графа не ослабляются. Норма и книга не менялись.

P = build2/codex_fix250generationchain01. Копии в [records](records) — байты оригиналов из P, строки приведены git к LF (`* text=auto eol=lf`); оригиналы связаны с [evidence.sha256](evidence.sha256).

## На опубликованном кортеже 285

Одни и те же 12 рядов ([sep286b.tsv](records/pins/sep286b.tsv)) на кортеже boot147a — [sep286b](records/pins/tp148-probe-sep286b.terminal.txt), 09:11:05.5152484Z→09:11:59.3406106Z, 46 отказов, — и на G2 boot148b — [sep286d](records/pins/tp148-probe-sep286d.terminal.txt), 09:12:00.5636378Z→09:12:54.9548408Z, 22 отказа. Native и forced отвечают одинаково, если не сказано иное:

| Запись | 285 | 286 |
| --- | --- | --- |
| свидетель `callable_place_signature` | 31: первая же запись принята | 7 |
| `struct_call_throws` | R0 остановлен: `call: missing` даёт `implements`, а ряд ловит `call` | 7 |
| [p286b](records/cold-tp140/tests/dyn/p286b_place_write_arity.lm2): `fn` с одним входом записан свободным значением в `Places\f` без входов, запись в блоке с `catch: implements` | 30: запись принята молча | 7 |
| [p286f](records/cold-tp140/tests/dyn/p286f_call_receiver_arity.lm2): `call: Hw` над `fn` с формалом без умолчания | 24 (`implements`) | 7 (`call`) |
| [p286l](records/cold-tp140/tests/dyn/p286l_node_root_place.lm2): место `fn` единицы, `@: node\f0 Hw` и `node\f0()` | native `invariant: a trampoline was called outside its method's signature`, forced `walk error: UNSUPPORTED` | 7 |
| [p286o](records/cold-tp140/tests/dyn/p286o_place_declared_throws.lm2): `fn` с `throws: Bad` в место без `throws` | native R0 остановлен непойманным `Bad`, forced `walk error: INVALID` | 7 |
| [p283ae](records/cold-tp140/tests/dyn/p283ae_other_signature.lm2), [p286j](records/cold-tp140/tests/dyn/p286j_free_root_write.lm2): та же запись вне обработчика, через путь места и через свободный корень, затем вызов | native invariant, forced UNSUPPORTED | R0 остановлен непойманным `implements` записи |
| [p286m](records/cold-tp140/tests/dyn/p286m_sub_fn_places.lm2): `sub` в место `fn`, затем `fn` в место `sub` | 31: `sub` принят молча | 32: первая запись отказана, вторая тоже |
| [p286g](records/cold-tp140/tests/dyn/p286g_call_receiver_default.lm2): `call: Hw` над `fn gd (int: a 5)` | 24 | 22: умолчание не взято (FORMAL-DEFAULT) |
| [p286d](records/cold-tp140/tests/dyn/p286d_default_formal.lm2): `d()` у `fn: d (int: a 5)` | отказ трансляции `d has no argument a` | так же |
| [p286n](records/cold-tp140/tests/dyn/p286n_named_actual_renamed.lm2): `Places\f(x: 5)` над `fn g (int: y)` | native 5, forced `walk error: INVALID` | так же (CALLABLE-PLACE-NAMED-ACTUALS) |

Первые замеры тех же проб на 285 шли до кандидата: [g01](records/pins/tp147-probe-g01.terminal.txt)–[g10](records/pins/tp147-probe-g10.terminal.txt) (рецепт [tp147-probe](records/pins/tp147-probe.command)). [p286h](records/cold-tp140/tests/dyn/p286h_structure_formal_arity.lm2) и [p286i](records/cold-tp140/tests/dyn/p286i_structure_called_with_args.lm2) проходили уже на 285 ([g04](records/pins/tp147-probe-g04.terminal.txt), [g05](records/pins/tp147-probe-g05.terminal.txt)): структурный формал без требуемого поля — `implements` (п. 4 ответа), обычная Structure в месте callable с аргументом — `call`. Пробы p286a, p286c, p286e, p286k — ниже, в «Что не сделано».

## Где был дефект

Слот поля callable не держал никакого объявления: у слота поля данных есть строка модели (`lmx_source_place_model_set`, срез 275), у слота callable — ничего, и `lmx_implements_receive_cell` при модели 0 пропускал любую запись. Статическое правило 282 (`lm_compiler_sig_takes`) проверяет только записи, где транслятор знает обе стороны. Свободное значение или свободный держатель клали в место `fn` другой сигнатуры, вызов затем доходил до трамплина нового метода с чужой арностью.

## Механизм

- **Объявление.** Строка места (порт −1, ключ — ячейка слота) получает поле `place_callable`: вызываемое, которое туда положило определение (`lmx_source_place_callable_set`, новый экспорт `lmx_source_names`). Пролог ставит его там, где определение кладёт FN-вызываемое (`fn` или `sub`) в слот: оболочка метода в слоте владельца (`lm_compiler_source_shell_emit`; методы пространств имён и локальных Structure), слот вхождения в единице (`fn` корня), заимствованное вхождение в поле корневого пространства имён (`lm_compiler_emit_ns_refs`), поле вложенного `l2_fkid`.
- **Допуск записи.** `lmx_implements_receive_cell` первым читает строку слота. Есть объявление — `lmx_implements_place_callable`: значение роли FN должно принимать вызов, который описывает объявление (`lmx_implements_call_takes`, направленная проверка Q49); NO — неявный `implements` до любого изменения. Обычная Structure стоит в месте как прежде и проверяется допуском выбранного вызова (срез 283). Через это место идут все писатели слота: native (`lmx_walk_value_field_store`), обходчик (PUT/OF), перепривязка (`lmx_walk_slot_rebind`) — один путь для native и обходчика.
- **`lmx_implements_call_takes`.** У `sub` трёх частей нет заголовка результата: часть 1 у него — `var`, прежде она читалась заголовком результата. `sub` и `fn` друг друга не принимают — равный результат статического правила.
- **GC.** Объявленное вызываемое — живая зависимость живого слота, как модель записанного допуска: `lmx_gc_mark_place_callables` в фиксированной точке `lmx_gc_mark_impl`. Слот жив, когда жив его chunk (тот же тест слабого ключа, что у `lmx_source_names_mark`). `lmx_source_names_drop` снимает объявление, уходящее со своим диапазоном.
- **Вызов.** `call: code` над `fn` с записанным формалом, которому он не формирует входа и у которого нет умолчания, — неявный `call` (срез 263 называл это `implements`); `struct_call_throws` переписан на `catch: call ()`. Тем же именем отвечают два места `lmx_walk_call_rows`: лишний записанный вход и вход на месте свободного.
- **tools/build.lm2.** `LmxSourceName` получил поле `place_callable`, `source_names[14]` — `lmx_source_place_callable_set` (счёт 15). Новый G0: tool148a.

Runner, cache, второй resolver и скрытые корни не вводились.

Отброшено по ходу среза: поле объявления в обходимом кадре PUT (оно закрывало только пути, известные транслятору, и давало native и обходчику две отдельные проверки) и проверка ширины входов при диспетчеризации (`lmx_call_prim_values`) и в выбранном вызове обходчика. После допуска записи корректная программа не приводит трамплин к чужой арности, поэтому `invariant: a trampoline was called outside its method's signature` снова означает повреждённый граф и остаётся инвариантом.

## Свидетель

[tests/dyn/callable_place_signature.lm2](../../../selfbuild/tests/dyn/callable_place_signature.lm2), native и forced, оба roots. Каждый свободный держатель держит одно вызываемое:

| Код | Что проверяет |
| --- | --- |
| 31, 51 | `@: Places\f Hw`, `Hw` — `fn g (int: a)`: `implements`, `Places\f()` по-прежнему 1 |
| 32, 52 | то же через свободный корень `@: Hq\f Hw` (`Hq` держит `Places`) |
| 33, 53 | место `fn` единицы: `@: node\f0 Hw`, затем `node\f0()` — 1 |
| 34, 54 | `sub` в место `fn`: `implements` |
| 35, 55 | `fn h ()` в место `Fit\f`: стоит там, `Fit\f()` — 5 |
| 36 | `fn` в место `sub`: `implements`, `Subs\t()` вызывается |
| 37 | `sub` в место `sub`: стоит там, `Subs\t()` вызывается |
| 38, 58 | `fn bad` с `throws: Bad` в место `Places\f` без `throws`: `implements` |
| 39, 59 | `fn bad2` с `throws: Bad` в место `Risky\f` с `throws: Bad`: стоит там, вызов `Risky\f()` бросает, `catch: Bad (int: value)` вызывающего получает 6 |
| 40+ | `call: Hh` над `fn h ()`: вызов проходит |
| 60+ | `call: Hw` над `fn g (int: a)`: неявный `call` (22) |

[struct_call_throws](../../../selfbuild/tests/dyn/struct_call_throws.lm2): `call: missing` над `needs_input (int: amount)` теперь ловится `catch: call ()`; срез 263 закреплял здесь `implements`, ответ Codex (п. 3) это правило переворачивает.

## Цепочка кандидата

Инструмент и входы — boot147a (`P/cold-boot147a/quick147a`). Стадия `P/cold-tp140` обновлялась из `P/variants/tp148` рецептом [tp148-prepare](records/pins/tp148-prepare.command): ровно восемь файлов отличаются от selfbuild 285 (`pins/tp148-changed.list`), 217 входов.

| Шаг | Результат | Receipt |
| --- | --- | --- |
| prepare a01 | 06:16:57Z, source-tp148 `bdf56ca6…` | [a01](records/pins/tp148-prepare-a01.terminal.txt) |
| tool148a | `rebuild tool`, 06:17:13.0779710Z→06:19:09.2142829Z, `ab54d8b4…` | [a01](records/pins/tp148-tool-a01.terminal.txt) |
| rt148a | отказ трансляции `lmx_gc_graph.lm2:296:62: assignment value has unknown type` (`atom=row`): поле C-структуры фактическим аргументом функции L2 требует приведения | [a01](records/pins/tp148-rt-a01.terminal.txt), [журнал модуля](records/cold-tp140/rt148a/lmx_gc_graph.L2.log) |
| prepare a02, rt148b | 06:19:59.0915024Z→06:21:03.0995535Z, driver `b47f8d2f…`, observe `f3e97b3e…` | [a02](records/pins/tp148-prepare-a02.terminal.txt), [b01](records/pins/tp148-rt-b01.terminal.txt) |
| fe148a | весь фронтенд, 06:21:24.0135347Z→06:27:39.6850591Z, l2trans `c5b95de5…` | [a01](records/pins/tp148-fe-a01.terminal.txt) |
| пробы и фокус | 14 рядов [c01](records/pins/tp148-probe-c01.terminal.txt); фокус 67/0, 06:31:01.3253834Z→06:46:38.6214404Z ([f01](records/pins/tp148-probe-f01.terminal.txt)) | |
| boot148a | whole 07:06:35.8034024Z→07:24:26.0096975Z, `BOOTSTRAP quick 0 failures`; сверка 245/3; G2 focus 67/0; полный на G2 84/0 | [terminal](records/pins/boot148a-quick.terminal.txt), [сверка](records/pins/boot148a-compare.txt), [g2focus](records/pins/tp148-probe-g2focus.terminal.txt), [fullg2](records/pins/tp148-probe-fullg2.terminal.txt) |
| разделение на boot148a | [p286o](records/cold-tp140/tests/dyn/p286o_place_declared_throws.lm2): `fn` с `throws: Bad` в месте без `throws` допускался — native «R0 was stopped», forced `walk error: INVALID`, на 285 так же ([sep286](records/pins/tp148-probe-sep286.terminal.txt), [sep286c](records/pins/tp148-probe-sep286c.terminal.txt)). Статическое правило 282 сравнивает `throws` (`lm_compiler_throws_same`), динамический допуск — нет | |
| prepare a03, rt148c | `lmx_implements_same_throws` и два случая свидетеля (38, 39); 08:00:20Z source-tp148 `cdb1fb25…`; runtime до 08:01:28.3691456Z, driver `2cab6a27…`, observe `47f74b3b…` | [a03](records/pins/tp148-prepare-a03.terminal.txt), [c01](records/pins/tp148-rt-c01.terminal.txt) |
| пробы и фокус | 11 рядов [c02](records/pins/tp148-probe-c02.terminal.txt); фокус 67/0, 08:04:48.4901411Z→08:19:55.2856866Z ([f02](records/pins/tp148-probe-f02.terminal.txt)) | |

boot148a и его приёмка — история: они шли до сравнения `throws` и не относятся к опубликованным байтам. Фронтенд и инструмент после a02 не менялись: `fe148a` и `tool148a` вошли во второй whole как есть (G0 и проверка кандидата).

## Мутанты

Каждое место отдельно, правкой файла стадии вручную; после каждой сборки файл стадии восстановлен из варианта и сверен с `pins/source-tp148.sha256` до следующего мутанта. Мутанты ядра — своей сборкой runtime на fe148a, мутанты фронтенда — своей сборкой FE на rt148b; инструмент tool148a; ряды [mut286.tsv](records/pins/mut286.tsv) (свидетель и `struct_call_throws`) в обоих режимах. Первые пять шли со свидетелем до случаев `throws` (`4e4d768e…`), шестой — с итоговым (`f89aae50…`).

| Мутант | Место | Итог |
| --- | --- | --- |
| kdeclared | `lmx_implements_receive_cell` не читает объявление места | убит: 31 в обоих режимах ([m1](records/pins/tp148-probe-m1.terminal.txt)) |
| ksubfn | `lmx_implements_call_takes` принимает `sub` за `fn` и наоборот | убит: 34 ([m2](records/pins/tp148-probe-m2.terminal.txt)) |
| kcallname | выбранный вызов называет отсутствующий вход `implements` | убит: свидетель 84, `struct_call_throws` — непойманный `implements` ([m3](records/pins/tp148-probe-m3.terminal.txt)) |
| shelldecl | оболочка метода в слоте владельца без объявления | убит: 31 ([m4](records/pins/tp148-probe-m4.terminal.txt)) |
| unitdecl | слот `fn` единицы без объявления | убит: 33 ([m5](records/pins/tp148-probe-m5.terminal.txt)) |
| kthrows | допуск без сравнения `throws` | убит: 38 ([m6](records/pins/tp148-probe-m6.terminal.txt)) |

Мутантами не проверены, ни один ряд их не различает: правило GC (`lmx_gc_mark_place_callables`; ни одна фикстура не собирает мусор между заменой вызываемого в месте и следующей записью туда), снятие объявления в `lmx_source_names_drop`, объявление заимствованного вхождения поля корневого пространства имён и поля `l2_fkid`, два места `lmx_walk_call_rows` (после допуска записи транслируемая программа не приводит туда вызываемое другой ширины).

## Приёмка на замороженных байтах

Вход: 217 файлов (65 source, 34 tools, 118 tests), manifest `cdb1fb259b7305f0434f8e32e898940e22ee102dd6dc5f1bf6131166d85d1d9b`, `P/cold-boot148b`.

| Проверка | Результат | Receipt |
| --- | --- | --- |
| Whole boot148b | 08:20:25.5851370Z→08:39:23.5598476Z, BootstrapExit 0, 1137.97 с; `BOOTSTRAP quick 0 failures`; smoke 9/0 в обеих генерациях | [terminal](records/pins/boot148b-quick.terminal.txt), [log](records/pins/boot148b-quick.log), [G2](records/cold-boot148b/quick148b/g2-build.log) |
| Сверка | source 217/0; producers g1 и g2: frontend 33, runtime 39, tool 6 шагов, все exit 0; 248/248, 496 хэшей, 0 stale; 245 raw-equal; 3 равных по размеру PE отличаются только смещениями 136, 137, 216, 217; consumed 306/306 равны; working tool и bundle равны G2; driver и driver-observe G1 и G2 равны рантайму кандидата rt148c | [сверка](records/pins/boot148b-compare.txt) |
| G2 focus | 08:40:04.4472460Z→08:56:17.9230150Z, SuiteExit 0, `SUITE 67 rows, 0 failures` | [terminal](records/pins/tp148-probe-g2focusb.terminal.txt) |
| Полный список на G2 | 08:56:36.5465500Z→09:10:35.6375120Z, SuiteExit 0, `SUITE 84 rows, 0 failures` | [terminal](records/pins/tp148-probe-fullg2b.terminal.txt) |
| Разделение | см. выше | [sep286b](records/pins/tp148-probe-sep286b.terminal.txt), [sep286d](records/pins/tp148-probe-sep286d.terminal.txt) |

Tuple G2, `P/cold-boot148b/quick148b`:

| Артефакт | SHA-256 |
| --- | --- |
| `lmxtool.exe`, `g2/tool/lmxtool-tool.exe` | `17afcadc9661d54a1fa6d4e3d52916c66fe20957ffc5083482844dad7be53a69` |
| `g2/frontend/l2trans.exe` | `3480b4deb7495365ac146964e3813e82501821c39d2e6b68d7cd870faa9e049c` |
| `g2/frontend/l1trans.exe` | `b1e2092894495470cead4e49f4ca2d4f83ca053e6fbc0ea63c270c4f375f3eb2` |
| `g2/frontend/l2_libc.o` | `af9fdae33655f8e6235310720787102921450f0f88f9b7bb2f365d372f553d37` |
| `g2/runtime/driver.o` | `2cab6a2717653d4e89f87fb977ce61e75bf60b6c406917ddf4cde8c2d4f66b9a` |
| `g2/runtime/driver-observe.o` | `47f74b3b39de2cd98aa1103d515b511840035df6e90247c776ce9e8b5b2d43cf` |

G0: `P/cold-tp140/tool148a/lmxtool-tool.exe` `ab54d8b438399b7a0ff1d6d6a5d6411162cc2a9e06ecbfcc571ce7219747d85e`, собран `rebuild tool` из инструментов этого пакета ([receipt](records/pins/tp148-tool-a01.terminal.txt)). Предыдущий frontend — G2 среза 285, boot147a.

Посадка [land286](records/pins/land286.command): 8 шагов exit 0 ([terminal](records/pins/land286.terminal.txt)), 217 файлов, оба подмножества consumed (65 строк) равны frozen, `selfbuild/inputs.sha256` равен frozen.

Порядок docs check. Первый `docs286-check` (09:17:11.9527206Z→09:20:20.7421860Z, exit 0) шёл до `git add` allowlist и читал индекс без среза: его ссылки и «LF в индексе» не покрывали документы среза (правило записи 276 — индексировать allowlist до docs check). Повтор `docs286-check2` после коммита и push, индекс = HEAD `bbc688280274bc0fe058f633faa33c6b33794601`: 09:26:16.5988429Z→09:26:45.1011325Z, exit 0, `line endings LF in the index for all 18859 tracked files`, ссылки ([terminal](records/pins/docs286-check2.terminal.txt), [log](records/pins/docs286-check2.log), [рецепт](records/pins/docs286-check2.command), [список копий](records/pins/docs286-text4.list)). Эти четыре файла добавлены следующим коммитом и в `evidence.sha256` не входят; SHA-256 оригиналов в P: `docs286-check2.command` `e36dd34ecc985589282b842bc3cd072e9e9bdd9adf6d04a1903e3d042e70b46c`, `docs286-check2.log` `2e3496c534ec81c8e0d7da901a7bd0070a7250db73255b797e6f8cc2e5f4aea2`, `docs286-check2.terminal.txt` `71745ce966eb870fe1fefe4e757318e379da6a087b289cf7fab0710b65bbb033`, `docs286-text4.list` `bebca5b26a73a2bce7567616651fa807971ca49d2b87a75a7ebe877d7cb50e56`.

## Что не сделано и записано

- **FORMAL-DEFAULT.** Записанное умолчание формала (`fn: gd (int: a 5)`) определение принимает, но не берёт ни один вызов: `d()` отказывает при трансляции `d has no argument a` ([p286d](records/cold-tp140/tests/dyn/p286d_default_formal.lm2)), `call: Hw` над таким `fn` — неявный `call` ([p286g](records/cold-tp140/tests/dyn/p286g_call_receiver_default.lm2); на 285 — `implements`).
- **CALLABLE-PLACE-NAMED-ACTUALS.** `fn: g (int: y)` проходит в место `fn: f (int: x)` (позиции и типы те же). `Places\f(x: 5)`: native связывает `x` с объявленной позицией — 5, обходчик — `walk error: INVALID`, на 285 так же ([p286n](records/cold-tp140/tests/dyn/p286n_named_actual_renamed.lm2), [n01](records/pins/tp148-probe-n01.terminal.txt), [n02](records/pins/tp148-probe-n02.terminal.txt)). По ответу Codex применяется контракт фактически выбранного вызова.
- **Копия пространства имён.** `Q: merge(Places)` и `Q\f()` отказывают при трансляции `a call path must end at a callable field` ([p286k](records/cold-tp140/tests/dyn/p286k_merge_copy_place.lm2)): путь к месту копии не транслируется, у ячеек копии своих строк объявления нет.
- **Прямой динамический вызов значения.** `Hw()` — `unknown method` ([p286a](records/cold-tp140/tests/dyn/p286a_free_call_arity.lm2)), `Hp\f()` — `a call path must end at a callable field` ([p286c](records/cold-tp140/tests/dyn/p286c_free_path_call_arity.lm2)), callable-формал из свободного держателя — `incompatible entry signature` ([p286e](records/cold-tp140/tests/dyn/p286e_callable_formal_arity.lm2)): эти формы транслятор не строит. Транслируемый прямой динамический вызов — ресивер `call: Hw`: он отвечает неявным `call`.
- **Старые пробы.** [p283ae](records/cold-tp140/tests/dyn/p283ae_other_signature.lm2) и [p286j](records/cold-tp140/tests/dyn/p286j_free_root_write.lm2) пишут вне обработчика и теперь останавливают R0 непойманным `implements` записи; [p286m](records/cold-tp140/tests/dyn/p286m_sub_fn_places.lm2) ждала, что `fn` встанет в место `sub`, и выходит с 32.

## Происхождение

Рецепты `.command` этого среза написаны вручную по рецептам 285, кроме [boot148b-compare](records/pins/boot148b-compare.command): он получен из `boot148-compare.command` подстановкой `sed` трёх меток — это копирование рецепта скриптом, запрещённое с 286; содержимое сверено построчно, отличаются только метки. Мутанты ставились и снимались правкой файла стадии вручную. Нарушения границы путей: `grep` с glob `src/l2src/*.h.lm1`; поиск Grep с путём-каталогом `variants/tp148/src/l2src`; `ls` каталога scratchpad. Защищённое имя в выводе не появлялось.
