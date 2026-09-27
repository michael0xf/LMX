# §GATE — замер «чистого ядра» по транслятору, фикстурам и harness (Opus, 2026-09-27, `93ba9d5`)

Read-only. Охват: `dev/l2src_sandbox/l2trans.lm1` (26823 строки), `dev/l2src_sandbox/tests/*.lm2` (680), `tools/l2_harness.ps1`, документы плана. Файлы обходчика и ядра — вне охвата (их остатки — `a0add35`, Sonnet). Замер сделал агент Opus; строки, помеченные **[проверено]**, ведущий перепроверил сам по `git show 93ba9d5:…`. Номера строк — на `93ba9d5`.

Итог: на `55799d8` §GATE **не закрывается**. Пункты «нет name-special / словарей / fallback», «нет дублей discard/call», «нет мёртвого кода и устаревших exclusions» нарушены; ниже — факты и срезы.

## 1. Словарь типов ядра в трансляторе и скрытые переименования

- **[проверено]** `l2_kernel_ptr_word` :5413–:5428: `"LmxMsgRuntime"`→28, `"LmxRoot"`→28, `"LmxMsg"`→29, `"LmxMsgCopy"`→30, `"L2ImmutQuery"`→6 с `l2_need_query: 1`. Тот же словарь — `l2_typed_formal` :13973–:13988 (`LmxMsgBlock`, `LmxArenaBlock`, `LmxOwnedRange`, `LmxMsgCopy`), :14008–:14016 (`L2ImmutQuery`→7), `l2_ret_type_word` :4840 (`LmxMsgAddr`→33). Противоречит доктрине «Translator tests no concrete C names» (`next_core_tasks_dictionary.md` :43) и прецеденту `a2cf69eb` (коды LmP0* сняты, типы идут дверью `c.LmP0*`).
- **[проверено]** Пять имён — `LmxMsgRuntime`, `LmxMsgCopy`, `LmxOwnedRange`, `LmxMsgAddr`, `LmxMsgBlock` — не объявлены и не используются нигде, кроме транслятора (grep по `dev/l2src_sandbox`, `l1src`, `dev/l3_interp`: 0 файлов). Транслятор выпускает их под другими именами (`LmxMsgRuntime` → `@: LmxRoot`, `LmxMsgCopy` → `@@: unsigned`, `LmxMsgBlock` → `@@: LmxArenaBlock`; :17818–:17826, :23441–:23451) — скрытое сохранение снятых имён. Потребители — только два непрогоняемых источника: `tests/unit_msg_adapter.lm2`, `parser_text_views.lm2`.
- `L2ImmutQuery` по имени включает `predef l2_text_hash.lm1` и `include l2_immut_query.h` (:25890, :25976); ветки `l2_prep` для `"l2_immut_query_fill"` / `"l2_hash_compare_q"` (:16975–:17030) недостижимы (predef перехватывается раньше, :16954).
- Таблица членов `data`/`length`/`columns`/`count`/`capacity` в `l2_raw_path` (:8066–:8107) и :25610–:25623 — поля `LmP0Text`/`LmP0IndentStack`, чьи коды сняты в `a2cf69eb`; `l2_ty_raw_c_members` :8032 открывает сырой доступ к членам кодам 28/29/30 — правило (3) плана :778 разрешает его только корню `c.*`.
- Список исключений `l2_scan_ident` :7433 держит `"alloc_next"` — имя больше нигде не встречается.

Спорно (автору, не срезом): `l2_prim_kind` :10278–:10292 — зашитая таблица 23 примитивов из `lingvamyxa_prev/lm2/primitive.lm2`; переписывание `.lm1.h` → `.h.lm1` в читателе predef :4495–:4504.

## 2. `c.puts` / `c.array`

Особой семантики нет: `grep -c "c\.puts"` — 0; `c.array` — 4 строки, все комментарии «что стояло здесь» (:5520–:5525, :9855); двери `l2_c_door` / `l2_c_stmt_door` проверяют только префикс `c.`. Условие «ноль словарей C-имён» не выполнено из-за п. 1.

## 3. Параллельные пути вызова в позиции оператора

Общий механизм — `l2_eval_discard` (`5a77cb2`). Рядом живут старые прямые пути из первой песочницы (`8eb8b97`): голова `c.*` → `l2_emit_ccall(stmt)` (:25462–:25466), predef-функция → `l2_emit_ccall(stmt)` (:25507–:25512). Ветка `l2_is_known` → `l2_eval_discard` (:25601–:25604) мертва: обе её половины перехвачены раньше. Та же развилка в проверке: голова-вызов идёт через `l2_check_primary` (:15963), у predef-вызова проверяются только аргументы (:15965). Вывод по чтению; мутантом не проверено.

## 4. Мёртвый код

- Мёртвых `fn:` нет: 722 определения, 576 прототипов, прототипов без определения 0, функций без вызова 0, недостижимых от `external: main` 0 (разбор агента; помощники, которые транслятор выпускает строкой, учтены отдельно).
- **[проверено]** Сироты `a2cf69eb`: коммит снял строки `if:`, оставив их тела — операторы сразу после `return:` в том же блоке: :17183–:17185 (три `return: l2_prep_drop(...)` в `l2_emit_call`), :24041 и :24115 (`return: 2`), :26222–:26223 и :26227–:26228 (`fclose` + `return: 1`).
- Флаг `l2_need_p0` не получает ненулевого значения (писатель снят в `9878e6b7`): ветки :25890 (его половина) и :25973 (`p0.lm1.h`) мертвы.
- Коды без писателя в пространствах результата и формала (производитель прослежен у места записи: `l2_m_ret` — :3140, :14382, :14462 и `l2_ret_type_word`; `l2_ft` — :14346 из `l2_typed_formal`): 5 и 13 в :17186, :17953, :18013, :23492; 4, 5, 13, 14, 15 в :23462, :23467; 30 в пространстве результата — :5515, :17167, :17909, :17935, :18001, :23474; 13 и 23 в указательном local — :24134. Живые (own-массивы): 4/5 в :9150, :15115, :16489, :17290, :17359, :19580, :25682.

## 5. Фикстуры и строки harness

- **[проверено]** Для строк `l2trans-refuses` / `root-pending` harness делает `continue` сразу после сверки needle (`tools/l2_harness.ps1` :2579–:2584): `Says`, `Debt`, `Absent` таких строк не проверяются никогда. Такие поля стоят у строк :522–:526 (`entry_puts_*`, `Says`; комментарий :519–:521 утверждает, что программы «say what they print»), :1836–:1839 (`unit_puts_main_beside_method`, `Debt`), :2225 (`Absent`). Проверка, которая не может упасть.
- 15 фикстур с `c.puts` не прогоняются нигде: `entry_puts_after_return`, `_bad_arg`, `_extra_arg`, `_nested`, девять `entry_puts_triple*`, `entry_ret_tr_puts`, `entry_ret_tr_two`.

## Срезы

- **G1 (ведущий, `l2trans`):** мёртвое — сироты `a2cf69eb`, `l2_need_p0` и его ветки, коды без писателя (п. 4), недостижимые ветки `l2_prep` и `l2_is_known`→discard, `"alloc_next"`. Свидетель — корпус 680 × 2 режима побайтно и гейт.
- **G2 (ведущий, после замера потребителей):** словарь типов ядра — типы ядра дверью `c.*`, как LmP0* в `a2cf69eb`; снять пять необъявленных имён и их переименования (потребители — два непрогоняемых источника); `L2ImmutQuery` без включения по имени; сырой доступ к членам только у корня `c.*`.
- **G3 (ведущий):** один путь вызова в позиции оператора — `l2_eval_discard`; снять прямые `l2_emit_ccall(stmt)`; проверка головы-вызова — одна.
- **G4 (Sonnet, harness и фикстуры):** строка-отказ с `Says`/`Debt`/`Absent` — отказ самой строки harness (форма строки), поля убрать или перенести в бегущие строки; 15 непрогоняемых `c.puts`-фикстур — в строки harness или удалить.

## G1 — сделано (Opus, 2026-09-27)

Снято мёртвое в `l2trans.lm1`: сироты `a2cf69eb` (три лишних `return: l2_prep_drop(...)` в `l2_emit_call`, два лишних `return: 2` в `l2_emit_loc_stmt`, две лишние пары `fclose` + `return: 1` в выпуске слотов); флаг `l2_need_p0` с объявлением, сбросом и обеими ветками; коды без писателя — 5 и 13 в пространстве результата (`l2_emit_call`, `l2_emit_sig`, `l2_tramp_class`, `l2_emit_public_sig`), 30 в пространстве результата (`l2_ret_uns`, `l2_emit_call`, `l2_emit_sig` дважды, `l2_tramp_class`, `l2_emit_public_sig`), 4, 5, 13, 14, 15 среди формалов (`l2_emit_public_sig`), 13 и 23 среди указательных local (`l2_emit_loc_stmt`); ветки `l2_prep` для `l2_immut_query_fill` / `l2_hash_compare_q` и два неиспользуемых local там же (`n`, `s4`); `"alloc_next"` в списке исключений `l2_scan_ident`.

Производители прослежены у места записи, не по виду условия: `l2_m_ret` пишут :3140 (0), :14382 (8), :14462 (16) и `l2_ret_type_word` — {0, 1, 2, 3, 8, 16, 32, 33, 35, 36} и коды ≥ 100; `l2_ft` пишет только `l2_typed_formal` через себя, `l2_ptr_type_word`, `l2_kernel_ptr_word`, `l2_resolve_type_atom` — {0, 1, 2, 3, 6, 7, 9, 11, 12, 16–20, 24–31, 34, 36, 38, 39} и ≥ 100; указательный local — `l2_ptr_type_word`. Код 30 в пространстве формалов живой (`LmxMsgCopy` в словаре п. 1) — остаётся до G2.

Корпус (680 фикстур × без knob / `--walk-methods`, `93ba9d5` против среза): 1360 из 1360 побайтно. Гейт в копии `build/opus_g1`: build 283/283 (103 селфтеста ran, exit 0), harness 476/476 (`build/l2_harness/g1`), L3 11/11, check_docs OK.

Замечено попутно: коды иностранных типов — `100 + i` без верхней границы (`l2_foreign_intern`), а `l2_sig_ret` читает результат ≥ 1001 как указательный own-код (`l2_own_of_dt` = dt − 1, затем − 1000). После 900 иностранных типов код совпал бы с указательным кодом формала. Не достигается корпусом; записано здесь, не исправлено.

Корпус `.lm2` верхнего уровня `dev/l2src_sandbox` (31 файл × 2 режима) тоже равен до и после среза. Попутный факт: 16 из них — порты парсера — сегодня отказывают на переводе (`parser_alloc_port`, `parser_c_quote_diagnostics`, `parser_c_surface`, `parser_dash_fence`, `parser_dump_port`, `parser_field_parse_port`, `parser_indent_stack`, `parser_matching_bracket`, `parser_matching_paren`, `parser_python_diagnostics`, `parser_quoted_diagnostics`, `parser_stack_stream_port`, `parser_text_heap`, `parser_text_port`, `parser_text_views`, `parser_trailer_role`; чаще всего «unknown type» на голом `LmP0*` — миграция на `c.LmP0*` из `a2cf69eb` их не дошла), и ни один не стоит строкой harness. Это непрогоняемые и устаревшие источники — к пункту §GATE «нет противоречивых docs/tests»; решение (перевести на дверь `c.*` и поставить строками или снять) — отдельным срезом.

Тестовый knob `--walk-methods` после `a6de5a9`: located-отказ есть только у метода с callable-результатом или callable-формалом; метод, который не проходит `l2_rw_may` по другой причине (throws, динамические входы, нечисловой результат) или проходит его, но падает в подсчёте шагов, под knob по-прежнему молча остаётся нативным. Это граница тестового knob, не семантический fallback языка; записано, чтобы не читать `steps/merge-parts-193.md` :439 («the build says so») шире, чем он верен.

## Копии `parser.lm1` — вариант, не дрейф (замечание fable_pc к REVIEW 32a3329)

`l1src/parser.lm1` и `dev/l1src_sandbox/parser.lm1` побайтно равны. `dev/l2src_sandbox/l1src/parser.lm1` и её близнец `l2src/l1src/parser.lm1` отличаются от них на 47 строк, одинаково до и после B1: одна строка `predef: "l1src/libc_abi.lm1"` и 23 вызова libc голыми именами (`memset`, `memcpy`, `strlen`, `memcmp`, …), объявленными в `libc_abi.lm1`, вместо двери `c.*`. Это вариант для цепочки ядра, которая объявляет libc через `libc_abi.lm1`; перенос строки между вариантами — руками в обе.

## G2 — факты до правки

Код 29 (`LmxMsg`) нужен самому транслятору: синтезированная модель письма `{sender: @: LmxMsg; payload: …}` (:276, :6605) типизирует поле через тот же словарь, выпуск пишет `const LmxMsg *` (`l2_pointer_decl_text`, :9176), а проверка адресата D-80 сравнивает статический тип с `1000 + 29` (:20884, :20993). Поэтому G2 — не «снять словарь», а развести: тип, который транслятор строит сам (письмо, его отправитель), — внутренний код без написания; имена типов ядра в источнике — только дверью `c.*`. Однозначная часть — пять необъявленных имён (`LmxMsgRuntime`, `LmxMsgCopy`, `LmxOwnedRange`, `LmxMsgAddr`, `LmxMsgBlock`) и их переименования при выпуске; потребители — `tests/unit_msg_adapter.lm2` и `parser_text_views.lm2`, оба не прогоняются. `LmxRoot`, `LmxArenaBlock`, `L2ImmutQuery` в источниках `.lm2` — только `parser_text_views.lm2` (`L2ImmutQuery`) и `unit_msg_adapter.lm2` (`LmxArenaBlock`).

## G2 — сделано (Opus, 2026-09-27)

Из транслятора сняты все написания типов ядра: `LmxRoot`, `LmxMsg`, `L2ImmutQuery` (`l2_kernel_ptr_word` — осталось только `char`), `LmxArenaBlock`, `L2ImmutQuery` (`l2_typed_formal`) и пять необъявленных — `LmxMsgRuntime`, `LmxMsgCopy`, `LmxOwnedRange`, `LmxMsgBlock`, `LmxMsgAddr` (с их переименованиями при выпуске). Тип ядра в источнике пишется дверью `c.*`, как LmP0* после `a2cf69eb`. Снят флаг `l2_need_query` и включение `l2_text_hash.lm1` / `l2_immut_query.h` по имени типа. Коды без писателя после этого — 6, 7 (`L2ImmutQuery`), 26, 27, 28, 30, 31 — сняты во всех местах пространств формала, слота, local и сигнатуры (`l2_ty_raw_c_members`, `l2_pointer_depth`, `l2_emit_formal`, `l2_emit_public_sig`, `l2_emit_loc_stmt`, `l2_check_body`, три списка исключений); код 29 в этих пространствах тоже без писателя и снят.

Остаётся код 29 как own-код 1029 поля `sender` модели письма: транслятор кладёт его сам (`l2_letter_ns_for`, `l2_nsf_push(10, 0U, 29, ni)`), без написания; его читают проверка адресата D-80 (`refty != 1000 + 29`), выпуск указателя (`l2_pointer_decl_text`, `const LmxMsg *`) и `l2_pointer_depth`. Это тип, который транслятор строит для своей же структуры, а не словарь имён источника.

Фикстура `tests/unit_msg_adapter.lm2` (оба близнеца) снята: единственный потребитель пяти необъявленных имён, строкой harness не стояла; прежний транслятор и так отказывал на ней («root operation not walkable yet: mixed numeric types», корень), новый отказывает раньше — «unknown type» на `LmxMsgRuntime`. `parser_text_views.lm2` (`L2ImmutQuery`) отказывает, как и прежде, на `LmP0Text` в первой строке. Из заголовка выпуска сняты четыре фразы об адаптере `L2ImmutQuery`.

Корпус (`971b5fa` против среза): `tests/*.lm2` 679 × 2 режима — 1358 из 1358 равны, 768 побайтно, 590 отличаются только снятыми фразами заголовка; `.lm2` верхнего уровня 34 × 2 — 0 различий. Гейт в копии `build/opus_g1`: build 283/283 (103 селфтеста ran, exit 0), harness 476/476 (`build/l2_harness/g2`), L3 11/11, check_docs OK.

Не этот срез (G2c): таблица членов `data`/`length`/`columns`/`count`/`capacity` в `l2_raw_path` — для формалов она теперь недостижима (формал без сырого доступа отказывается в `l2_check_body`), но та же таблица стоит в ветке слотов (`l2_st`), и её снятие требует переписи производителей типов слота.

## G3 — факт до правки

`l2_eval_discard` для вызова `c.*` / predef в позиции оператора идёт через `l2_prep`, а тот ставит `l2_ccall_into` — `l2_emit_ccall` тогда кладёт текст вызова в `l2_tok` и не выпускает его. Прямые ветки разбора операторов (`l2_c_stmt_door` → `l2_emit_ccall(stmt)`, predef-функция → `l2_emit_ccall(stmt)`) поэтому не дубль, а единственное, что сегодня вообще выпускает такой вызов оператором; снять их, не научив общий путь выпускать вызов, — значит молча терять вызов. Порядок G3: `l2_eval_discard` выпускает вызов `c.*` / predef оператором; затем прямые ветки и мёртвая ветка `l2_is_known` → discard снимаются; свидетель — корпус побайтно.

## G3 — сделано (Opus, 2026-09-27)

Вызов в позиции оператора теперь выпускает один механизм — `l2_eval_discard`: для кадра, чья голова — дверь `c.*` или predef-функция (и не метод единицы), он сам зовёт `l2_emit_ccall` и выпускает вызов оператором, вместо того чтобы через `l2_prep` положить текст вызова в `l2_tok` без потребителя. Прямые ветки `l2_emit_stmts` из первой песочницы (`8eb8b97`) — голова `c.*` → `l2_emit_ccall(stmt)` и predef-функция → `l2_emit_ccall(stmt)` — сняты; оператор `c.*` доходит до ветки `l2_head_is_call` → `l2_eval_discard`, predef-оператор — до ветки `l2_is_known` → `l2_eval_discard` (прежде «мёртвой»: её перехватывала прямая ветка). `l2_c_door` — обёртка над `l2_c_stmt_door` с тем же телом — снята, её четыре вызова зовут `l2_c_stmt_door`.

Корпус (`dc15482` против среза): `tests/*.lm2` 679 × 2 режима — 1358 из 1358 побайтно; `.lm2` верхнего уровня 34 × 2 — 0 различий. Что новый путь исполняется, показывает мутант: ветка `l2_eval_discard` возвращает 0, ничего не выпустив, — 54 прогона (27 фикстур, среди них `unit_puts_method_body`, `unit_raw_root_c_control_compound`, `unit_sizeof_type_frame`, `unit_p0_without_include`) расходятся с срезом. Гейт в копии `build/opus_g1`: build 283/283 (103 селфтеста ran, exit 0), harness 476/476 (`build/l2_harness/g3`), L3 11/11, check_docs OK.

Не этот срез: проверка остаётся развилкой — голова-вызов идёт через `l2_check_primary`, у predef-вызова проверяются только аргументы.

## G2c — к очереди (REVIEW dc15482-1)

Код 29 у `sender` модели письма читается по числу в трёх местах (`1000 + 29` в проверке адресата D-80, `l2_pointer_decl_text`, `l2_pointer_depth`) — «число вместо ссылки». Правка: модель письма — обычная Structure транслятора со своим `nsty`, поле `sender` — ссылка на её описание, а не код. Вместе с таблицей членов `l2_raw_path` (перепись типов слота).

## 16 устаревших портов парсера (Sonnet, 2026-09-27) — измерено, `l2trans.lm1` не трогал

Задание Opus: для каждого из 16 непрогоняемых верхнеуровневых `.lm2`-портов измерить первую причину отказа (одна диагностика = нижняя граница, «только X» проверять пробой «снял X → перевёл снова»); голые `LmP0*`/`LmOwn*` — перевести на `c.LmP0*`/`c.LmOwn*` (как в `a2cf69eb`) и, если после этого переводится, поставить строкой `harness` (`Expect = 'translates'`); если причина глубже — отказ-строка с needle и `steps/defects.md`, или снять файл с измеренной причиной (форма `REVIEW dc15482-2`, `unit_msg_adapter.lm2`). Использован уже собранный `l2trans.exe` (`build/l2_harness/g4/bin`, коммит `6e8728e`, до G1/G2/G3 — эти срезы не касаются пространства LmP0*/LmOwn*/predef, только словаря типов ЯДРА и путей вызова, замер ими не задет).

**3 файла — правка на месте, теперь переводятся, строки harness `translates`:**

- **`parser_alloc_port.lm2`** — 15 голых `LmP0*` (`LmP0NodeKind`, `LmP0Node`, `LmP0Structure`, `LmP0Frame`, `LmP0Span`, `LmP0NodeAs`) → `c.LmP0*`; переводится начисто.
- **`parser_trailer_role.lm2`** — 3 голых `LmP0TrailerRole`/`LmP0Node`/… → `c.*`; переводится начисто.
- **`parser_text_heap.lm2`** — 4 голых `LmP0Text` → `c.LmP0Text` (перевод сам по себе не хватило: без `predef: "l1src/own.h.lm1"` — «unknown method» на `lm_own_new_zero`, тот же класс, что и `unit_bad_sizeof.lm2`); добавлена строка `predef:` (уже существующий, гейтованный прототип-заголовок, ничего нового не изобретено); переводится начисто после обеих правок.

**13 файлов — сняты (оба близнеца), не referenced ни один (`grep` по всему дереву `.lm2`/`.lm1`, кроме собственных комментариев с историческими «Stage N» пометками — ни одного функционального `predef:`/вызова извне):**

| Файл | До (голая причина) | Правка типов | После правки типов (если применялась) | Решение |
| --- | --- | --- | --- | --- |
| `parser_c_quote_diagnostics.lm2` | `unknown type` (`LmP0Document`, :6:27) | 2× → `c.*` | `assignment value has unknown type` (`end_index`, :12:5) — тот же класс, что D-84 | снят |
| `parser_dump_port.lm2` | `unknown type` (`LmP0Dump`, :16:25) | 40× → `c.*` | `assignment value has unknown type` (`data`, :41:5) — D-84 | снят |
| `parser_field_parse_port.lm2` | `unknown type` (`LmOwnPtrStack`, :24:97) | 22× → `c.*` | `a callable without a result has no value` (`p0_field_parse_loop_frame_delete_any`, :30:34) | снят |
| `parser_indent_stack.lm2` | `unknown type` (`LmP0IndentStack`, :4:34) | 20× → `c.*` | `assignment target must be a declared typed mutable value` (`lm_own_delete`, :7:5) | снят |
| `parser_matching_bracket.lm2` | `unknown type` (`LmP0Document`, :1:37) | 1× → `c.*` | `unknown method` (`lm_p0_is_line_break`, :17:17) — определена в 4 других файлах (`parser_c_quoted`, `parser_dash_fence`, `parser_physical_line`, `parser_text_predicates`), ни разу не за `prototype:`-заголовком — предеф `.lm2`-тела не читается (`l2_predef_file_has_function`, -155) | снят |
| `parser_matching_paren.lm2` | `unknown type` (`LmP0Document`, :1:35) | 1× → `c.*` | `unknown method` (`lm_p0_is_line_break`, :15:17) — тот же случай | снят |
| `parser_python_diagnostics.lm2` | `unknown type` (`LmP0Document`, :8:34) | 1× → `c.*` | `unknown method` (`lm_p0_find_python_string_end`, :4:9) — определена в `parser_python_string.lm2`, не за `prototype:` | снят |
| `parser_quoted_diagnostics.lm2` | `unknown type` (`LmP0Document`, :2:27) | 2× → `c.*` | `unknown method` (`lm_p0_starts_python_string`, :11:9) — определена в `parser_text_starts_python.lm2`, не за `prototype:` | снят |
| `parser_stack_stream_port.lm2` | `unknown type` (`LmP0Stack`, :27:24) | 99× → `c.*`, затем `uchar` → `c.uchar` (2 места) | `a callable without a result has no value` (`p0_stack_free_any`, :46:26) | снят |
| `parser_text_views.lm2` | `unknown type` (`LmP0Text`, :1:33) | 4× → `c.*` | `unknown method` (`l2_immut_query_fill`, :21:13) — определена в `l2_text_hash.lm1`, включавшийся по имени типа `L2ImmutQuery`; это включение по имени СНЯТО в G2 («без включения по имени») — файл проверяет уже удалённый механизм, не оставшийся недоделанным | снят |
| `parser_c_surface.lm2` | `unknown method` (`lm_p0_is_field_space`, :8:13) — 0 голых типов, правка типов неприменима | — | — (нет своего `predef:` вообще; функция — в `parser_text_predicates.lm2`, не за `prototype:`) | снят |
| `parser_dash_fence.lm2` | `unresolved name` (`closed`, :123:22) — 0 голых типов | — | — | снят |
| `parser_text_port.lm2` | `field path goes through a slot with no Structure` (`out_payload\data`, :24:5) — 0 голых типов | — | — | снят |

**Общий вывод по 10 файлам «unknown method» после правки типов:** причина — не тип, а `l2_predef_file_has_function`'s собственное правило (-155): предеф читает объявления только из `prototype:`-блока или цепочки `predef:`, никогда из простого `fn:`/`sub:`-тела `.lm2`-файла. Ни у одной из недостающих функций (`lm_p0_is_line_break` и т. п.) нет отдельного `prototype:`-заголовка — создание пяти новых заголовков для пяти хелперов вышло за рамки «перевести голый тип» (задание явно разводит эти два случая); граница та же, что D-86 называет для L2-библиотек в принципе, только для предеф-объявлений, а не линковки. Не заводил новый D-номер — граница уже названа в -155/D-86, здесь просто ещё один симптом того же класса.

**По просьбе Opus — норма или расхождение?** «Голый `fn:`/`sub:`-тело в предеф-файле — объявление?» Норма есть, и найденное поведение ей соответствует, не расходится: `docs/L1_spec_en.md:155` — «`external` exports the declared function/procedure; `prototype` declares it» (объявляет именно `prototype`, не тело); сам транслятор несёт явный комментарий (`l2trans.lm1:4786-4788`, над `l2_predef_has_function`, :4789 — обход списка предефов; правило -155 читает файл строкой ниже, в `l2_predef_file_has_function`, :4733, вызываемой из :4794): «Functions declared by a predef header are external ABI leaves. They are not callable Structures owned by this unit, so calls go through the ordinary C seam while the generated predef header supplies the checked prototype.» Оба места независимо называют один и тот же контракт (декларация — через `prototype:`, тело — не декларация), и код ему следует (fable_pc, REVIEW 01f56f3, замечание 1: имя функции в первой версии этой записи было не то, строки верны). Не D-номер (нет расхождения с нормой) и не `LMX_blog/q/` (норма уже названа, автора спрашивать не о чем) — 10 файлов упёрлись в отсутствие заголовков-прототипов для своих хелперов, а не в баг транслятора.

**Осиротевшие после снятия, не трогал (вне заданных 16):** `parser_dump_port_l2.h.lm1`, `parser_field_parse_port_l2.h.lm1`, `parser_stack_stream_port_l2.h.lm1` — заголовки-прототипы единственных снятых потребителей; упоминаются только в комментариях друг друга («Stage N», «same shape as»), не в рабочем предефе. Не снимал — задание называло 16 `.lm2`, не заголовки; отдельный пункт для координатора.

Корпус и гейт — см. коммит.

## G2c — таблица членов снята (Opus, 2026-09-27)

`l2_raw_path` больше не знает имён `data`/`length`/`columns`/`count`/`capacity` (обе ветки — формалы и слоты): это поля `LmP0Text`/`LmP0IndentStack`, чьи коды сняты в `a2cf69eb`, а последний потребитель, `L2ImmutQuery` (код 7), ушёл в G2. Сняты и семь записей оператором через эту таблицу (`l2_pN_M\data:` … `\capacity:`, `l2_sN_M\data:`/`\length:`): формал или слот без сырого доступа `l2_check_body` отвергает раньше. Корень, который не открыт двери `c.*`, теперь всегда идёт в разбор путей L2. Отказ через слот сменил фразу: `q\data` у `@: char q` — «unknown field path root» вместо «unknown foreign field».

Корпус (`436833d` против среза): `tests/*.lm2` 679 × 2 — 1358 из 1358 побайтно; `.lm2` верхнего уровня 34 × 2 — 0 различий. Гейт в копии `build/opus_g1`: build 283/283 (103 селфтеста ran, exit 0), harness 479/479 (`build/l2_harness/g2c`), L3 11/11, check_docs OK.

Попутно измерено (D-97): путь у формала-указателя на примитив (`p\length`, `p\whatever` у `@: size_t p`) принимается и выпускается как доступ к члену C — и до среза, и после; неверный C ловит только gcc.

Код 29 у `sender` (REVIEW dc15482-1, решение с fable_pc): сейчас — граница (C): одна именованная константа `l2_msg_ref_ty()` и одно место выпуска в C (`l2_pointer_decl_text`, `const LmxMsg *`); все шесть мест, читавших число — запись в модель письма, D-80 (дважды), `l2_pointer_depth`, `l2_pointer_decl_text`, ячейка `sender` в выпускаемом `sendMessage` (`LMX_TYPE_POINTER_BASE + …`), — берут его оттуда. Цель (B) — строкой в §7 плана: Message как описание транслятора без полей источника, `sender` — ссылка на него, D-80 по тождеству описания; не (A): типизация иностранным `LmxMsg` открыла бы `m\sender\x` как сырой C-доступ.

Остаток: список исключений `l2_scan_ident` ещё держит `columns`, `count`, `capacity`, `slots`, `addr` — следы тех же полей, перепись отдельно.
