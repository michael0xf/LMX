# Срез 289 — индекс другого числового типа у L3 INDEX через общий числовой приём (INDEX-NUMERIC-RECEPTION)

Опубликован 2026-11-06, Opus. Часть U3 [плана N4-U](../../../next_core_tasks_v3.md). Задание и норма: ответ Codex на результат 288 ([дословно](records/pins/codex-288-review-next.txt), CODEX-OPUS-288-REVIEW-NEXT-20261106-01): категория L3 выбирается независимо от наличия удобного преобразования; индекс принимается существующим общим числовым приёмом, его подготовкой и выполнением, без второго resolver преобразований, без особого исключения и без SOURCE_MACHINE при неудачном приёме; отсутствующий или отказавший преобразователь — обычный отказ принимающего выражения, без unchecked C fallback; текущая диагностика при трансляции новой нормой не объявляется. Книга, контекст преобразований ([provenance/semantics-book.md:198, :200](../../../provenance/semantics-book.md)): иное примитивное описание допустимо только через доступное в Message преобразование, при потреблении оно исполняется как обычное вызываемое выражение; отсутствующий преобразователь не заменяется скрытой цепочкой. Норма и книга не менялись.

P = build2/codex_fix250generationchain01. Копии в [records](records) сделал `lmxtool stage-copy` из P, проверив хэш каждой, затем git записал их из своего индекса с LF (`* text=auto eol=lf`, см. «Происхождение», п. 4); оригиналы связаны с [evidence.sha256](evidence.sha256).

## На опубликованном кортеже 288

Свидетели на рабочем tool, G2 frontend и runtime boot150a ([sep01](records/pins/tp151-probe-sep01.terminal.txt), [лог](records/pins/tp151-probe-sep01.log), список [probe289-a](records/pins/probe289-a.tsv)): `index_numeric_receive` — native и forced root0 `driver exit -1073741819` (0xC0000005: индекс C с отрицательным `int` за объектом), root1 обоих режимов — `lmx: walk error: UNSUPPORTED` (SOURCE_MACHINE в обходимом корне); `index_numeric_refused` транслируется без отказа и оставляет L1. 10 отказов из 12 рядов.

## Где был предел

Срез 288 впустил в маршрут L3 INDEX только индекс, который `size_t` принимает без преобразования (`lm_compiler_index_receivable`: `size_t`, значение с типом при исполнении, один литерал). Индекс `int` того же собственного или формального указателя оставался индексом C в native и SOURCE_MACHINE в обходчике. Оба эмиттера места при этом уже принимали индекс общим числовым приёмом с целью `size_t`: native — `lm_compiler_emit_actual_path_place_field` через `lm_compiler_emit_numeric_receive_span_full`, обходчик — `lm_compiler_rw_index_level` через `lm_compiler_rw_numeric_receive_span`; оба готовят приём одним `lm_compiler_numeric_receive_prepare`. Предел задавал только предикат.

## Механизм

- **Предикат без типа индекса.** `lm_compiler_index_l3_path` (l2_frontend_resolve.lm2) больше не смотрит на тип индекса; `lm_compiler_index_receivable` удалён. Категорию задают корень (собственное поле или формал), метод (не функция машинного модуля) и шаги (индекс указателя, чей указуемый тип ядро типизирует).
- **CHECK как у уровня Array.** Индекс L3 INDEX проходит в CHECK тот же общий приём, что индекс уровня Array: `lm_compiler_check_resolved_indices` (чтение, `@`) и `lm_compiler_check_indexed_write` (запись, до проверки immutable) — подготовка приёма, вид литерала, один объявленный вход приёмника и ребро вызова приёмника (`lm_compiler_convert_edge_to`). Хвост `lm_compiler_check_numeric_receive_span` после проверки выражения вынесен в `lm_compiler_check_numeric_receive_plan`: запись проверила выражения индексов как значения до выбора места и спрашивает только приём (`lm_compiler_check_index_l3_receive`).
- **Снижение не менялось.** Native вызывает приёмник программы (`lmx_call_prim_values` над текущим вызываемым значением приёмника), его отказ — возврат неявного `convert`; затем `lmx_walk_value_index_place` получает уже `size_t`. Обходчик строит EXEC приёмника (`lm_compiler_rw_numeric_receive`, отметка преобразования). Порядок — ELEM/ELEMPUT: держатель, индекс с преобразованием, выбор места, затем значение записи.
- **Отказ — обычный отказ приёма.** Программа без приёмника `int` → `size_t` получает при трансляции тот же отказ, что любое `size_t`-место, принимающее `int`: ``the program has no method `lm_stg_convert_int_size_t`, the receiver of this conversion`` (cv_gap 2, `lm_compiler_convert_norecv`); `unsigned` и другие типы без строки таблицы — `mixed numeric types (a conversion)`. Это текущее поведение реализации приёма, а не общий нормативный контракт (поправка 290 по ответу Codex на ревью 289; книга :198, :200, :241).
- **Ядро не менялось.** Runtime boot150a используется как есть.

Runner, cache, второй resolver, отдельный checker и интерпретатор L2 не вводились.

## Где программы берут приёмник

В selfbuild ни одна программа не определяет приёмников таблицы `primitive.convert` (`impl` строки — данные, транслятор ищет метод программы по имени, `lm_compiler_convert_method`); `convert_impl.lm2` есть только в старых деревьях. Поэтому:

- **Методы tools** собираются машинной библиотекой (`--library --machine tool_main`), их индексы — подлинный L2 при любом типе (`lm_compiler_m_machine`); срез их не трогает. Корни tools/lmxtool.lm2 и lmxchild.lm2 индексируют `size_t`.
- **L3-программы с частями tools** — дочерняя программа самотеста (lmxchild с частями text.lm2, os_native_path.lm2, os_file_open.lm2; её строят gate и bootstrap full) и фикстура `sha256_vectors` (часть tools/sha256.lm2) — получили точный тип индекса: [tools/text.lm2](../../../selfbuild/tools/text.lm2) `hex[(cast: (size_t) …)]` вместо `(cast: (int) …)`, [tools/sha256.lm2](../../../selfbuild/tools/sha256.lm2) — `size_t: i` в `sha_block` и `sha_finish` и `size_t: at` для позиции цифры (сдвиг по `int: q`, как был). Все digest прежние.
- **Свидетель**, которому нужно преобразование, определяет приёмник сам.

## Свидетели

[tests/dyn/index_numeric_receive.lm2](../../../selfbuild/tests/dyn/index_numeric_receive.lm2), native и forced, оба корня, первая ошибка не затирается. Программа определяет `lm_stg_convert_int_size_t (int: n) size_t` с `throws: range` при `n < 0`.

| Код | Что проверяет |
| --- | --- |
| 11 | `pc[one]` в корне, `int: one 1` |
| 12 | `pc[two]: value(ps)` — запись, значение вычислено один раз (`seen[0U]`) |
| 13, 14 | чтение и запись через формал `int: at`: `get(pc, one)`, `put(pc, one, 23)` |
| 15 | собственный указатель метода: `own_get(one)` |
| 16 | адрес через формал: `address_of(pc, two)` |
| 17 | `pc[neg]` (`int: neg 0 - 1`) — неявный `convert` |
| 18 | `pc[neg]: value(ps)` — `convert`, значение не вычислено, ничего не записано |
| 19–21 | `get`, `put`, `address_of` с `neg` — `convert` выходит из метода, пойман вызывающим |
| 22, 23 | `pc[far]` и `pc[far]: value(ps)` (`int: far 2147483647`) — индекс принят, место за интервалом — `interpreter`, значение не вычислено |
| 24 | `if: guard != 0 && pc[neg] = 5` при `guard 0` — приём под ложной охраной не исполняется |
| 25 | ячейки после неудачных записей прежние |

Отказы, native и forced, L1 не остаётся, в логе транслятора ровно одна ошибка:

- [tests/dyn/index_numeric_refused.lm2](../../../selfbuild/tests/dyn/index_numeric_refused.lm2): без приёмника `int: got pc[at]` с `int: at` — ``index_numeric_refused.lm2:9:13: the program has no method `lm_stg_convert_int_size_t`, the receiver of this conversion``. Следующая строка `int: later "text"` тоже ошибочна, но её отказ не приходит первым: приём индекса допущен в CHECK в порядке программы.
- [tests/dyn/index_numeric_write_refused.lm2](../../../selfbuild/tests/dyn/index_numeric_write_refused.lm2): `pc[at]: "text"` — тот же отказ на индексе (`7:4`), а не отказ значения: CHECK записи допускает индекс до значения, как ELEMPUT выбирает место первым.

Пробы P (не в пакете, в стейдже): [p289a](records/cold-tp140/tests/dyn/p289a_index_wide_literal.lm2) — литерал `18446744073709551616U` транслятор типизирует как `int`, поэтому и он получает отказ приёма `int` → `size_t` ([w01](records/pins/tp151-probe-w01.log), [лог](records/tp151-probe/w01/p289a_index_wide_literal-native.log)); вид литерала здесь не проверяется — типизация такого литерала вне этого среза. [p289b](records/cold-tp140/tests/dyn/p289b_receiver_hidden_input.lm2) — приёмник читает свободное имя корня `floor`; метод с индексом `int` получает этот вход: 7 во всех четырёх запусках ([h01](records/pins/tp151-probe-h01.log)).

## Мутанты

Ручные правки стейдж-файлов ([mut289](records/pins/mut289.tsv)), каждая — целый фронтенд ([tp151-fe](records/pins/tp151-fe.command)) и пробы на runtime boot150a; после каждой файл восстановлен копией из варианта и весь стейдж проверен `lmxtool verify` ([tp151-restore](records/pins/tp151-restore.command)).

| Мутант | Фронтенд | Итог |
| --- | --- | --- |
| m1: CHECK чтения и `@` без приёма индекса L3 INDEX | [fe151m1](records/pins/tp151-fe-m1.terminal.txt) | probe289-a не убил ([m1](records/pins/tp151-probe-m1.log), 12/0), p289b тоже 7 ([h01m1](records/pins/tp151-probe-h01m1.log)): при снижении тот же `lm_compiler_numeric_receive_prepare` даёт тот же отказ в том же месте и тот же вызов приёмника. Убит фикстурой порядка ([m1b](records/pins/tp151-probe-m1b.log)): `index_numeric_refused` первым отказом получает строку 10 `a text where a number is asked` ([лог](records/tp151-probe/m1b/index_numeric_refused-native.log)) — без CHECK приём индекса не допущен в порядке программы. Восстановление: [m1](records/pins/tp151-restore-m1.terminal.txt) |
| m2: CHECK записи без приёма индекса L3 INDEX | [fe151m2](records/pins/tp151-fe-m2.terminal.txt) | убит ([m2b](records/pins/tp151-probe-m2b.log), 2 отказа): `index_numeric_write_refused` первым отказом получает значение, `7:1: assignment value has incompatible type` ([лог](records/tp151-probe/m2b/index_numeric_write_refused-native.log)), а не индекс `7:4`; остальные 13 рядов, и запись с приёмником в `index_numeric_receive`, проходят — при снижении приём тот же. Восстановление: [m2](records/pins/tp151-restore-m2.terminal.txt) |
| m3: предикат 288 (resolve среза 288: индекс только `size_t`, со значением типа при исполнении или литерал) | [fe151m3](records/pins/tp151-fe-m3.terminal.txt) | убит ([m3b](records/pins/tp151-probe-m3b.log), 12 отказов в 4 рядах): `index_numeric_receive` — native и forced root0 0xC0000005, root1 `driver exit 3`, как на кортеже 288; оба отказа — с ошибкой значения или следующей строки вместо приёма индекса ([лог](records/tp151-probe/m3b/index_numeric_refused-native.log)); `p289b` — `exit 12` (индекс C без `convert`). Восстановление: [m3](records/pins/tp151-restore-m3.terminal.txt) |

Пробы m1–m3 (`probe289-b`) запущены на уже собранных фронтендах мутантов после prepare a02, который добавил фикстуры порядка; компилятор у a01 и a02 тот же (resolve `69301977…`, emit `6d30fd5b…`).

## Приёмка

| Проверка | Результат | Receipt |
| --- | --- | --- |
| Первый кандидат | prepare a01 (source-tp151 `7f5a4680…`, стейдж до копии равен landed `61cbda82…`); fe151a 16:46:38→16:50:03Z, l2trans `a01834c6…`; пробы 12/0 | [prepare](records/pins/tp151-prepare-a01.terminal.txt), [fe](records/pins/tp151-fe-a01.terminal.txt), [a01](records/pins/tp151-probe-a01.log), [список](records/pins/probe289-a.tsv) |
| Фикстуры порядка | prepare a02 (`d9f7391e…`, 221 вход; компилятор прежний); на fe151a пробы 14/0 | [prepare](records/pins/tp151-prepare-a02.terminal.txt), [b01](records/pins/tp151-probe-b01.log), [список](records/pins/probe289-b.tsv) |
| Tool и ребёнок кандидатом | `rebuild tool` 17:20:10→17:21:28Z, tool `c40c6f24…`, smoke и хэш файла; `build-child` 17:21:43Z, lmxchild `2dd9b932…`; `selftest` с этим ребёнком 0 failures (hex аргументов печатает txt_hex через L3 INDEX) | [toolfe](records/pins/tp151-toolfe-a01.terminal.txt), [лог](records/pins/tp151-toolfe-a01.log), [selftest](records/pins/tp151-selftest-a01.log) |
| Фокус на кандидате | fe151a: 68/0, 17:23:10→17:34:43Z | [f01](records/pins/tp151-probe-f01.terminal.txt), [лог](records/pins/tp151-probe-f01.log), [список](records/pins/focus149.tsv) |
| Полный список на кандидате | fe151a: 85/0, 17:35:12→17:45:58Z | [u01](records/pins/tp151-probe-u01.terminal.txt), [лог](records/pins/tp151-probe-u01.log), [список](records/pins/fullsuite149.tsv) |
| Наблюдение обходчика | os-walk-witness над `index_numeric_receive`, спека `touch=1,value=1,get=2,put=2,own_get=1,address_of=2`, 17:46:25→17:46:37Z, 46 PASS: forced в обоих roots обходит каждое тело точное число раз, `value` — один раз (значение отказавших записей не вычислено), L1 не даёт этим телам native-слов; native не обходит ни одно | [rcv01](records/pins/tp151-obs-rcv01.terminal.txt), [лог](records/pins/tp151-obs-rcv01.log), [рецепт](records/pins/tp151-obs.command) |
| Whole boot151a | стейдж — source-tp151-a02 (`same`); 17:47:05.5415435Z→17:57:52.7447572Z, BootstrapExit 0, 647.20 с; `BOOTSTRAP quick 0 failures`; smoke 9/0 в обеих генерациях; G0 — рабочий tool boot150a (tools/build.lm2 не менялся), предыдущий frontend — G2 boot150a | [terminal](records/pins/boot151a-quick.terminal.txt), [log](records/pins/boot151a-quick.log), [detached](records/pins/boot151a-detached.terminal.txt), [prepare](records/pins/boot151a-prepare.terminal.txt), [рецепт](records/pins/boot151-quick.command) |
| Приёмка whole командами lmxtool | 38 команд, 0 отказавших (поправка 290: было «37»; в рецепте 38 вызовов, в receipt 38 строк `exit=`; сравнения — команды lmxtool, но запуск, счёт отказов и накопление receipt — PS-функция `Check` рецепта, не L2/L3) ([рецепт](records/pins/boot151-check.command)): стейдж 221/0 (`verify`); записи producers G1 и G2 (frontend 126, runtime 130, tool 53 хэша) и запись сборки G2 (4) замкнуты на файлы (`verify-record`, 0 failed), ни один шаг не запускал script host (`deps`); G1 и G2: `exe-same` l2trans, l1trans, tool, `same` l2_libc.o, driver.o, driver-observe.o, L1 и C tool, consumed-inputs; рабочий tool и bundle — G2; runtime — байты G2 runtime boot150a (ядро не менялось); кандидат fe151a и G2: `exe-same` l2trans, l1trans, `same` l2_libc.o — фокус и полный список прошли на коде G2 | [check](records/pins/boot151a-check.terminal.txt) |
| Пробы на G2 | рабочим tool, G2 frontend и runtime boot151a, список probe289-b: 17:59:29→18:01:11Z, `SUITE 14 rows, 0 failures` | [sepg2](records/pins/tp151-probe-sepg2.terminal.txt), [лог](records/pins/tp151-probe-sepg2.log) |
| Посадка | land289 18:01:33→18:01:35Z, 9 шагов exit 0 ([рецепт](records/pins/land289.command)): стейдж whole против source-tp151-a02, манифест стейджа bootstrap и consumed G1 и G2 равны (`same`), стейдж держит байты, которые съел G2 (`verify`), список входов 221, `stage-copy` в selfbuild, `selfbuild/inputs.sha256` записан, проверен и равен source-tp151-a02 `d9f7391e…` | [terminal](records/pins/land289.terminal.txt) |

Кортеж: рабочий tool `6032766b2f5a7ec5…` (= G2 tool), G2 frontend `83f0be590ad84cca…`, l1 `c65a043bff6c88f9…`, l2_libc `af9fdae33655f8e6…`, driver `2cab6a2717653d4e…`, observe `47f74b3b39de2cd9…`. G0 — рабочий tool boot150a `eb11e493…`, previous frontend — G2 288 `c284f0a1…`.

## Стоимость

Индекс `int` у L3 INDEX теперь — вызов приёмника программы на каждый доступ (обычный вызов `lmx_call_prim_values` в native, EXEC в обходчике) перед `lmx_walk_value_index_place`; отдельно не замерено. Нового прохода и таблицы нет: CHECK спрашивает тот же приём, что у уровня Array. Код: G2 l2trans 1591985 байт (288 — 1591922), G2 tool 1922225 (288 — тот же размер), `lmxtool.lm1` 207523 (288 — тот же размер). Whole quick 647.20 с против 923.86 с у boot150a — измерение всего конвейера, не контролируемое сравнение.

## Что не сделано

- **Пределы маршрута** — шаг-член C ABI, машинная локальная, слот, C-константа, указатель на `void` или внешний тип — на прежнем пути (L3-INDEX-ROUTE-LIMITS, OPEN).
- **Приёмники преобразований** в пакете не определены (их нет ни в одной программе selfbuild); перенос тел Q33 из старого дерева — не задача этого среза.
- **Литерал вне диапазона типа** (`18446744073709551616U`) транслятор типизирует как `int`; вид такого литерала в приёме не проверяется (p289a) — вне этого среза.
- **Не свидетельствованы рядом:** двухуровневый индекс с преобразованием, индекс `unsigned` или `char` (у таблицы нет строки в `size_t`, отказ `mixed numeric types (a conversion)` — по коду, не рядом).

## Происхождение

Рецепты, списки, таблица мутантов и фикстуры записаны вручную инструментом Write, правки — инструментом Edit; мутанты — ручные правки стейдж-файлов с восстановлением и `lmxtool verify`. Рецепты 289 не содержат алгоритмов сверки на PowerShell: подготовка, сборки, пробы, посадка, архив записи и приёмка whole — последовательности команд lmxtool (`verify`, `manifest`, `stage-copy`, `same`, `exe-same`, `verify-record`, `deps`, `sha256`, `build-frontend`, `rebuild`, `build-child`, `suite`, `bootstrap`); результаты — их собственные логи, без фильтрации. Копии записи — байты оригиналов (`stage-copy`), без нормализации текста. Отступления:

1. Одна проверка существования пяти точных путей циклом `foreach` в начале среза и одно усечение вывода `ForEach-Object` при чтении хвоста defects.md — набраны в оболочке, не сохранены; дальше — `Test-Path` с массивом путей.
2. Одна фоновая команда запустила два рецепта подряд (фронтенд и пробу мутанта m1, вторую — после кода выхода первой) — то же отступление, что п. 2 записи 288; m2 и m3 запускались по одному рецепту.
3. Первая привязка записи ([docs289-1](records/pins/docs289-1.terminal.txt)) отказала на шаге 3: рецепт [docs289](records/pins/docs289.command) переписан (метка прогона) после того, как первый проход архива скопировал его прежний текст ([лог](records/pins/docs289-1-03.log)). Прежняя копия удалена из records, рецепт перенесён во второй проход, повтор [docs289-1b](records/pins/docs289-1b.terminal.txt) прошёл.
4. Первые два языковых docs check ([a](records/pins/docs289-check-a.log), [b](records/pins/docs289-check-b.log)) отказали: 88 находок `working copy is not LF` — байтовые копии receipts несли CRLF. Нормализацию текста не писал: копии из индекса (там git уже держит LF, `* text=auto eol=lf`) записал в рабочую копию сам git — `git checkout-index` по точному списку; первый вызов поверх существующих файлов их не переписал (b), второй — после удаления этих копий. После этого [docs check c](records/pins/docs289-check-c.terminal.txt) прошёл. Поэтому копии в records равны оригиналам с точностью до концов строк; `stage-copy` проверил хэш каждой копии до записи git ([pass 1](records/pins/docs289-archive-1.terminal.txt); receipt второго прохода — в P, `pins/docs289-archive-2.terminal.txt`), а [evidence.sha256](evidence.sha256) связывает оригиналы в P ([рецепт](records/pins/docs289-bind.command)).
5. `git diff --cached --check` нашёл одну строку с хвостовым пробелом — собственный байт receipt `tp151-selftest-a01.log` (`PASS ARG 2 ` у пустого аргумента); копия не исправлялась.

Порядок docs check: точный allowlist (140 путей: документы, пакет selfbuild, записки 288 и 289, evidence.list и evidence.sha256 первого прохода и 120 копий первого прохода) проиндексирован `git add --pathspec-from-file`, индекс сверен со списком (`diff`), затем языковой `docs check` рабочим tool boot151a: c 18:09:24.5719530Z→18:09:42.2486923Z, exit 0, «line endings LF in the index for all 19247 tracked files», ссылки ([log](records/pins/docs289-check-c.log), [рецепт](records/pins/docs289-check.command)). После него — второй проход архива (23 receipt), итоговый evidence-манифест (143 файла, проверен против P) и эта записка добавлены к индексу вторым точным списком; receipts финальной привязки остаются в P (`pins/docs289-bind.terminal.txt`, `pins/docs289-bind-0{1,2}.log`).
