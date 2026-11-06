# Срез 292 — собственные поля тела в `var` (VAR-PATH-OF-SHORT-FN) и места `var` у native под явными данными

Опубликован 2026-11-06, Opus. Часть U3 [плана N4-U](../../../next_core_tasks_v3.md). Задание: ответ Codex на результат 291 ([дословно](records/pins/codex-291-review-next.txt), CODEX-OPUS-291-REVIEW-NEXT-20261106-01) — VAR-PATH-OF-SHORT-FN с рамкой: физическое место собственного поля принадлежит `var`, исходный оператор и инициализатор остаются в `body` и исполняются при достижении; предварительная компоновка не открывает имя раньше объявления и не вычисляет правую часть; второго слота между `body` и `var` нет; обычные `var`, голый атом и `@free` не переопределяются. Норма — книга ([docs/LMX_semantics.ru.md](../../../docs/LMX_semantics.ru.md), раздел о частях метода): :437 «явные поля `var` и собственные поля, обнаруженные в `body`, составляют набор полей … отсутствующие в явной части добавляются к `var` … Инициализация, записанная в `body`, остаётся там и исполняется при достижении своей строки … поле, добавленное из `body`, сохраняет точку своего исходного объявления»; :451 «Собственное поле метода физически принадлежит части `var` … оператор `body` обращается к этому месту и не создаёт второй ячейки»; :439 — обращения тела к полям `code\var` — требования к выбранной `data`; ответ Codex на вопросы нормы 285, п. 1. Норма и книга не менялись.

P = build2/codex_fix250generationchain01. Копии в [records](records) сделал `lmxtool stage-copy` из P, проверив хэш каждой; оригиналы связаны с [evidence.sha256](evidence.sha256).

## На опубликованном кортеже 291

Пробы P на рабочем tool, G2 frontend и runtime boot153a ([probe292-a](records/pins/probe292-a.tsv), [лог](records/pins/tp151-probe-p292b.log)):

- `m\var\a` у `fn` ([p292a](records/cold-tp140/tests/dyn/p292a_var_fn.lm2)), `s\var\w` у `sub` ([p292b](records/cold-tp140/tests/dyn/p292b_var_sub.lm2)), поле тела рядом с написанной `var` ([p292i](records/cold-tp140/tests/dyn/p292i_explicit_var.lm2)) — отказ трансляции `unknown field path segment`;
- `call: s D` ([p292e](records/cold-tp140/tests/dyn/p292e_call_data.lm2)) — код 81: тело пишет свою ячейку в части `body` кода, `D\a` остаётся 0 у обоих исполнителей ([p292j](records/cold-tp140/tests/dyn/p292j_call_data_value.lm2): 100 и 100, [лог](records/pins/tp151-probe-p292c.log));
- поле написанной `var` под `call: m D` ([p292k](records/cold-tp140/tests/dyn/p292k_written_var_data.lm2)): native оставляет `D\k` = 10, обходчик даёт 15 ([лог](records/pins/tp151-probe-p292d.log)) — исполнители уже расходились;
- проходят: чтение до объявления как скрытый вход ([p292c](records/cold-tp140/tests/dyn/p292c_before_decl.lm2)), порядок эффектов ([p292d](records/cold-tp140/tests/dyn/p292d_effect_order.lm2)), рекурсия ([p292f](records/cold-tp140/tests/dyn/p292f_recursion.lm2)), `m\body\a` ([p292g](records/cold-tp140/tests/dyn/p292g_body_path.lm2)) — прежняя раскладка.

Первый прогон ([p292a](records/pins/tp151-probe-p292a.log)) ошибался в двух пробах: корень читал голое `log`/`seen` — свою рабочую копию, которую по правилу публикации не перезагружают; пробы переписаны чтением через метод.

## Где было

`lm_compiler_rw_fn_parts` строит контейнер `var` из написанной части, а `lm_compiler_rw_stmts_in` ставит хранилище каждого прямого объявления тела в контейнер `body` перед его инициализатором; резолвер (`lm_compiler_method_part_own_seg`) спрашивал `lm_compiler_method_part_contains_own` по исходной Structure части, поэтому поле тела было полем `body`. Native-код метода с частями корнирует свои места от кода (`lm_compiler_emit_graph_places`: `lmx_arena_ref_struct(l2_call_code, …)`), а обходчик отображает держатель `f\source` (часть `var`) на данные (`lmx_walk_slot_place`, `lmx_implements_code_slot`) — отсюда разное поведение под `call: m D`.

## Механизм

- **Один предикат для проверок и раскладки.** `lm_compiler_method_part_contains_own` (l2_frontend_context.lm2) отвечает по раскладке: часть 2 — поля написанной `var` и собственные поля тела, часть 3 — остальные поля исходного тела; часть 12 — только написанная `var`, часть 13 — только поля тела, которые держит `var`. Решает `lm_compiler_body_own_in_var` (в конце модуля): метод с частями (`fn`, `sub`), прямое объявление тела (`own_host` = 0) и не определение (метод, Structure), не выход ресивера, не ссылка на графовую Structure (записанные формы тоже такие ссылки), не callable merge и не конструктор части. Он читает только таблицы источника, поэтому проверки (до раскладки) и раскладка отвечают одинаково; признак split-вызова для этого не годится — он появляется после проверок.
- **Место — в `var`, оператор — в `body`.** `lm_compiler_rw_body_var_slots` (в конце l2_frontend_emit.lm2) ставит место каждого такого поля в контейнер `var` после полей написанной части, в порядке тела, и называет слот головой; ячейку с именем поля делает оболочка источника. `lm_compiler_rw_stmts_in` для этих объявлений в `body` не ставит слота хранения и имени головы на слот оператора: оператор и инициализатор остаются на своей позиции и исполняются при достижении строки. Скан связывает при входе только поля написанной `var` (часть 12; l2_frontend_core.lm2).
- **Native: места `var` — места выбранных данных.** `lm_compiler_own_from_expr` (l2_frontend_useplan.lm2): ячейка места части `var` текущего метода с частями — `lmx_arena_ref_cell(self, lmx_call_index(l2_call_arena, self, l2_gp<var кода>, слот))`: при прямом вызове `self` и есть `var` кода (`lmx_call_unary_data`), при явных данных — данные, слот по допущенному соответствию, как у OWN обходчика. Это касается и полей написанной `var`.
- **Фикстура 285 переведена.** `sub_parts.lm2` проверяла `direct\body\w` (код 93) — старую раскладку; теперь `direct\var\w`.

## Свидетели

[tests/dyn/var_own_fields.lm2](../../../selfbuild/tests/dyn/var_own_fields.lm2), native и forced, оба корня:

| Код | Что проверяет |
| --- | --- |
| 81–85 | `fn`: `m()` = 6, `m\var\a` = 6 после вызова, запись `m\var\a: 40` видна, следующий вызов снова ставит 6 (инициализатор тела исполняется при достижении строки), `m\a` = 6 |
| 86–88 | `sub`: `s\var\w` = 7, `call: s s\var` |
| 89, 97 | чтение до объявления — скрытый вход (своя привязка вызывающего первой): 45; то же в методе с написанной `var` — 46 |
| 90, 91 | эффекты в порядке источника: инициализатор вызывает метод при достижении строки — журнал 12 |
| 92 | рекурсия: одно место, рабочее значение на активацию — `fact(5)` = 120 |
| 93, 94 | поле написанной `var` и поле тела — оба поля `var` |
| 95, 96 | явные данные: `call: t D` пишет `D\a` = 6, `call: wv E` — `E\k` = 15 (поле написанной `var`) |

Пробы на кандидате fe154c ([probe292-d](records/pins/probe292-d.tsv), [лог](records/pins/tp151-probe-p292f.log)): все прежние пробы и `sub_parts` проходят; p292e проходит у обоих; p292j — 106 у обоих, p292k — 115 у обоих; [p292g](records/cold-tp140/tests/dyn/p292g_body_path.lm2) (`m\body\a`) и [p292h](records/cold-tp140/tests/dyn/p292h_nested.lm2) (поле, объявленное внутри `if`) отказывают при трансляции `unknown field path segment` — следствие и граница среза (не закреплены).

## Мутанты

Ручные правки стейдж-файлов (инструмент Edit), каждая — целый фронтенд ([tp154-fe](records/pins/tp154-fe.command)) и фикстура ([mut292](records/pins/mut292.tsv)) на runtime boot153a; после каждой изменённые файлы стейджа возвращены из варианта и весь стейдж проверен `lmxtool verify` (225/0: [m1](records/pins/mut292-m1-restore.log), [m2](records/pins/mut292-m2-restore.log), [m3](records/pins/mut292-m3-restore.log), [m4](records/pins/mut292-m4-restore.log)).

| Мутант | Сборка | Итог |
| --- | --- | --- |
| m1: перенос выключен (`lm_compiler_body_own_in_var` всегда 0) | [fe154m1](records/pins/tp154-fe-m1.terminal.txt) | убит ([m292a](records/pins/tp151-probe-m292a.log)): отказ трансляции `var_own_fields.lm2:77:23: unknown field path segment` в обоих режимах |
| m2: скан снова связывает часть 2 при входе | [fe154m2](records/pins/tp154-fe-m2.terminal.txt) | выжил и после усиления фикстуры кодом 97 ([m292b](records/pins/tp151-probe-m292b.log), [m292c](records/pins/tp151-probe-m292c.log)): эквивалентный — в этой точке скана строки собственных полей тела ещё не собраны (сначала сканируется написанная `var`), так что части 2 и 12 там совпадают; правка оставлена как явный смысл, независимый от порядка сбора |
| m3: native снова адресует `var` через код | [fe154m3](records/pins/tp154-fe-m3.terminal.txt) | убит ([m292d](records/pins/tp151-probe-m292d.log)): native — код 95 (`call: t D` не дошёл до `D\a`), обходчик проходит |
| m4: второй слот хранения в `body` при месте в `var` | [fe154m4](records/pins/tp154-fe-m4.terminal.txt) | убит ([m292e](records/pins/tp151-probe-m292e.log)): обходчик — код 82 (`m\var\a` ≠ 6: запись ушла во второй слот), native проходит |

## Приёмка

| Проверка | Результат | Receipt |
| --- | --- | --- |
| Кандидат | a01: изменённые файлы сняты и скопированы, стейдж `b50044de…`; fe154a не скомпилировался — `lm_compiler_own_written` модуля types идёт в frontend.c после context и не имеет там прототипа ([компиляция](records/cold-tp140/fe154a/COMPILE.log), строка 409); проверка убрана (записанные формы — ссылки на графовые Structure, их исключает следующая). a02 `b6bf9363…` → fe154b 21:16:34→21:19:50Z: раскладка верна, но под явными данными native расходился с обходчиком (p292e native 81, p292j 100/106; [лог](records/pins/tp151-probe-p292e.log)). a03 `7dc53e44…` (+ useplan) → fe154c 21:23:31→21:26:49Z, l2trans `e1555224…`, l1trans `b7d1d492…`, l2_libc `af9fdae3…` | [a01](records/pins/tp154-prepare-a01.terminal.txt), [a02](records/pins/tp154-prepare-a02.terminal.txt), [a03](records/pins/tp154-prepare-a03.terminal.txt), [fe154b](records/pins/tp154-fe-b01.terminal.txt), [fe154c](records/pins/tp154-fe-c01.terminal.txt) |
| Пакет кандидата | a04 `c3527112…`: + фикстура, ряд реестра, список входов (225); a05 `e9d6ebae…`: фикстура усилена кодом 97 после m2. Изменённые файлы — [список](records/pins/tp154-changed-b.list) | [a04](records/pins/tp154-prepare-a04.terminal.txt), [a05](records/pins/tp154-prepare-a05.terminal.txt) |
| Реестр на кандидате | рабочий tool и runtime boot153a, fe154c, весь поддерживаемый реестр ([копия](records/pins/registry292-c.tsv), байты `selfbuild/tests/full-suite.tsv`): 102 ряда, 0 отказов, 880 проверок, 21:28:43.4379087Z→21:41:47.9024973Z (784.46 с); усиленная фикстура на fe154c — 1/0 | [terminal](records/pins/tp151-probe-r292c.terminal.txt), [лог](records/pins/tp151-probe-r292c.log), [v292a](records/pins/tp151-probe-v292a.log) |
| Стейдж bootstrap | `steps` рабочего tool boot153a по [boot154a-prepare](records/pins/boot154a-prepare.tsv): 5/0, source-boot154a = source-tp154-a05 | [terminal](records/pins/boot154a-prepare.terminal.txt), [лог](records/pins/boot154a-prepare.log) |
| Whole boot154a | 21:59:52.0549505Z→22:10:39.3633333Z, BootstrapExit 0, 647.31 с; `BOOTSTRAP quick 0 failures`; smoke 9/0 в обеих генерациях; G0 — рабочий tool boot153a `165666e8…`, предыдущий frontend — G2 boot153a `1e829732…` | [terminal](records/pins/boot154a-quick.terminal.txt), [log](records/pins/boot154a-quick.log), [G2](records/cold-boot154a/quick154a/g2-build.log), [рецепт](records/pins/boot154-quick.command) |
| Приёмка `checks` | рабочий tool boot153a, [список](records/pins/boot154a-check.tsv): 38/0 — стейдж 225/0; записи producers G1 и G2 и запись сборки G2 замкнуты, без script host; G1 и G2: `exe-same` l2trans, l1trans, tool, `same` l2_libc.o, driver.o, driver-observe.o, L1 и C tool, consumed-inputs; рабочий tool и bundle — G2; runtime — байты G2 runtime boot153a; кандидат fe154c и G2: `exe-same` l2trans и l1trans, `same` l2_libc.o — поэтому реестр на G2 не повторялся | [terminal](records/pins/boot154a-check.terminal.txt), [лог](records/pins/boot154a-check.log) |
| Самотест G2 tool | рабочий tool boot154a `08d1866c…` (= G2 tool): 0 failures | [selftest](records/pins/tp152-selftest-g292.log) |
| Посадка | `steps` рабочего tool boot154a по [land292](records/pins/land292.tsv), 22:11:51→22:11:52Z: 9/0, `selfbuild/inputs.sha256` = source-tp154-a05 `e9d6ebae…` (225 входов) | [terminal](records/pins/land292.terminal.txt), [лог](records/pins/land292.log) |

Кортеж: рабочий tool `08d1866c5145893d…` (= G2 tool), G2 frontend `f43e1878e617ce51…`, l1 `759e3bb90d303d4a…`, l2_libc `af9fdae33655f8e6…`, driver `2cab6a2717653d4e…`, observe `47f74b3b39de2cd9…`. Изменились l2_frontend_context, l2_frontend_core, l2_frontend_emit, l2_frontend_useplan, фикстура `sub_parts`, реестр, список входов и новая фикстура `var_own_fields`.

## Что не сделано и находки

- **Граница раскладки** (VAR-OWN-NESTED-AND-REFERENCE, OPEN): поле, объявленное во вложенном теле (`if`/`for`; p292h), определение Structure или метода в теле, выход ресивера, ссылка на графовую Structure, поля callable merge и конструктора части остаются на прежнем месте. Книга :441 требует готовить в `var` и места записей внутри `if`/`for`, и места объявляющих форм Structure; FN-OWN-PLACE-AT-CALL-DATA (`T:` в теле `fn` под `call: m D`) поэтому открыт.
- **`m\body\a` отказывает при трансляции** (p292g): тело больше не держит поля; закреплять отказ не стал — норма называет место поля, но не путь к оператору тела.
- **Развилка native и обходчика под явными данными найдена и закрыта** (VAR-PLACE-EXPLICIT-DATA-NATIVE): она была и для полей написанной `var` до среза (p292k), перенос распространил бы её на поля тела.
- **Значение места до первого вызова** не закреплено: ячейку делает оболочка источника, и литеральный инициализатор даёт ей начальное значение (`Callables\f\x` = 3 в фикстуре 283), но :437 не обещает значения до инициализации.
- **m2 эквивалентный** (см. «Мутанты»).

## Стоимость

Раскладка: тот же обход тела ещё раз при построении `var` и один предикат на объявление. Native: доступ к ячейке места `var` — вызов `lmx_call_index` (при прямом вызове — путь `value = code`). Отдельно не замерено. Код: G2 l2trans `f43e1878…`. Whole quick 647.31 с против 656.49 с у boot153a — измерение всего конвейера, не контролируемое сравнение.

## Происхождение

Пробы, фикстура, рецепты и списки записаны вручную инструментом Write, правки — инструментом Edit; мутанты — ручные правки стейдж-файлов с возвратом из варианта (`stage-copy`) и `lmxtool verify` всего стейджа. Сбор результатов и последовательность подготовки кандидата, стейджа bootstrap, приёмки, посадки и архива — `lmxtool checks`/`steps`; PS-рецепты — запуски одной команды инструмента с охранниками: `tp154-fe` (новый), `tp151-probe` (289), `tp152-selftest` (290), `boot154-quick`, `boot154-detached`. Отступления:

1. Карту раскладки собственных полей составил агент Explore (только чтение исходников, без запусков); выводы проверены чтением кода.
2. Код native и L1 проб читались `grep`/`sed`/`awk` оболочки по явным путям вывода проб; каталоги вывода и каталог fe154a просмотрены `Get-ChildItem` с исключением защищённого имени.
3. `pins/tp154-changed.list` получил пятую строку (useplan) между a02 и a03; манифесты a01/a02 держат прежний состав (4 файла). Для a04/a05 заведён отдельный список `tp154-changed-b.list`.
4. Метка пробы `m1p` уже была занята пробой мутанта 290: рецепт отказал (`exists`), выведенные строки были старым логом 290; проба повторена с меткой `m292a`.
5. `boot154a-prepare.tsv` и `land292.tsv` переключены с a04 на a05 командой `sed` до первого запуска.
6. Строки логов отобраны для чтения `Select-String`; receipts — сами логи.

Архив и docs check — `steps`/`checks` рабочего tool boot154a. Первый проход ([docs292-archive-1](records/pins/docs292-archive-1.tsv), [terminal](records/pins/docs292-archive-1.terminal.txt), [лог](records/pins/docs292-archive-1.log)): манифест 109 путей P из [records292.list](records/pins/records292.list), их байтовые копии `stage-copy` в [records](records), [evidence.sha256](evidence.sha256) проверен против P и против копий. Затем точный allowlist ([allow292-1](records/pins/allow292-1.list), 128 путей) проиндексирован `git add --pathspec-from-file`, индекс сверен со списком (`diff`); 63 копии с CR (receipts PowerShell; [список](records/pins/crlf292-1.list)) удалены по точному списку и записаны git из индекса с LF (`git checkout-index --stdin`), CR пересчитаны по байтам (0 из 128) — поэтому они равны оригиналам с точностью до концов строк. Каталог PRIVATE_OUT языкового docs check создан до запуска (DOCS-CHECK-SILENT-PRIVATE-OUT). Docs check ([список](records/pins/docs292-check-a.tsv)): 22:18:10→22:18:31Z, `CHECKS 1 lines, 0 failed`, «line endings LF in the index for all 19566 tracked files» ([terminal](records/pins/docs292-check-a.terminal.txt), [лог](records/pins/docs292-check-a.log)). Второй проход (`pins/docs292-archive-2.tsv`) скопировал receipts первого прохода и docs check, манифест первого прохода, allowlist и список CR; итоговый evidence-манифест проверен против P; эта записка и копии второго прохода добавлены к индексу вторым точным списком, после чего docs check повторён над итоговым индексом. Receipts второго прохода и повторного docs check остаются в P (`pins/docs292-archive-2.*`, `pins/docs292-check-b.*`).
