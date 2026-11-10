# Индекс Structure `S[i]` в чистом графе (план M6, шаг 4) — 2026-11-10

Исполнитель: fable. Норма — решение автора 2026-11-10 ([журнал](../../../LMX_blog/2026-11-10.md),
[книга](../../../docs/LMX_semantics.ru.md#structure-index)): `S[i]` читает i-й слот Structure — непосредственное поле в
порядке записи, с нуля — и даёт адрес значения поля без типа; `S[i] := p` записывает в слот другой адрес после допуска
по требованию поля; `length(S)` читает число полей; индекс вне `0 <= i < length(S)` — ошибка исполнения. Шаг —
четвёртый в [разделе M6 плана](../../../next_core_tasks_v3.md#m6). Как прочитаны «адрес без типа», допуск записи, имя
поля после записи и ответы на ошибки — [ответы исполнителя А5–А8](../../../LMX_blog/q/fable-self-answers-20261110.md).

## Изменение

1. **Построитель** (`src/l2src/l2_graph_build.lm2`). В хвосте P0 отдаёт `S[1]` атомами `S`, `[`, поля индекса, `]`:
   цикл операторов `lm_graph_build_expression` строит из них выражение `[база, слово "[]", индекс]` со связыванием
   сильнее арифметики, индекс — выражение. В голове P0 хранит текст целиком (`S[1]`, `S[i + 1]`, `S\a[1]`):
   `lm_graph_build_indexed` разбирает такой текст тем же парсером и строит то же выражение; так левая часть
   `S[i] := p` и аргумент `getType(S[i])` — одно дерево.
2. **Ядро графа** (`src/l2src/lmx_graph.lm2`). Слова состояния `w_index` (`[]`) и `w_length`. Новый участок
   `LMX_TYPE_GRAPH_REF` — «ссылка без типа», род 7 в `lmx_graph_kind`: ячейка-указатель с любым адресом арены, значение
   вычисления, в слотах графа не хранится. Операции — по одной на оба потребителя: `lmx_graph_index` (чтение слота),
   `lmx_graph_index_write` (запись с допуском: слот сохраняет род того, что держит, — место `int`, Structure, слово,
   ссылочное место своего рода), `lmx_graph_length`, `lmx_graph_int_ref_of` (место `@: p int` принимает ссылку без
   типа, когда адрес принадлежит ячейке `int`), `lmx_graph_index_form` (узнаёт левую часть-индекс), а также общая
   `lmx_graph_address_of`, через которую теперь идёт и `lmx_graph_address_type` среза 343. `lmx_graph_target` следует
   за ссылкой без типа к Structure.
3. **Интерпретатор** (`src/l2src/lmx_graph_run.lm2`). Чтение индекса в `lmx_graph_eval_value`; `length(S)` и индекс в
   числовой позиции в `lmx_graph_eval_number`; запись — `lmx_graph_eval_index_write` из `lmx_graph_eval_assignment`;
   слова `[]` и `length` известны `lmx_graph_language_word`. Новый ответ 7 — индекс вне полей.
4. **Эмиттер** (`src/l2src/l2_graph_tool.lm2`). Те же операции ядра в выпускаемом коде: чтение в
   `lm_graph_emit_operand`, `length` в `lm_graph_emit_number`, запись в `lm_graph_emit_assignment`, приём ссылки
   местом `@:` корня.
5. **Рецепт и инструмент.** `tools/build.lm2`: константа `LMX_TYPE_GRAPH_REF`, поля `w_index` и `w_length` в шаблоне
   `LmxGraphState`, пять новых имён экспорта модуля `lmx_graph` (всего 64). `tools/lmxtool_methods.lm2`: команда
   `graph-check` принимает ответ интерпретатора 0..7 — прежде 0..6.
6. **Фикстуры** `tests/graph/struct_index.lm2` с ожиданием, `struct_index_range.lm2`, `struct_index_admit.lm2`,
   `struct_index_base.lm2`; `inputs.list` — 412 входов.

## Значения

`struct_index`, дамп после исполнения — одинаков в interp, native и forced. `S` объявлена блоком с полями `int: a 1`,
`int: u` и вложенной `N` с `int: x 7`; рядом `int: j 40`.

| Строка | Значение | Что проверяет |
| --- | --- | --- |
| `int: n length(S)` | 3 | число непосредственных полей |
| `int: t_cell getType(S[0])` | 2 | слот поля со значением — ячейка `int` |
| `int: t_uninit getType(S[1])` | 1001024 | слот поля без значения — его указатель «без инициализации» |
| `int: t_nested getType(S[2])` | 13 | слот вложенной Structure — её заголовок |
| `@: p int S[0]`, `int: v_first \p` | 1 | место `int` принимает ссылку без типа; чтение через неё |
| `S\a := 5`, `int: v_same \p` | 5 | `S[0]` и `S\a` — одна ячейка |
| `int: x_nested S[2]\x`, `int: n_nested length(S[2])` | 7, 1 | индекс как основание пути и аргумент `length` |
| `int: t_computed getType(S[k + 1])` при `k` = 1 | 13 | индекс — выражение |
| `int: t_method kind_of(2)` при `return: getType(S[i])` | 13 | индекс в теле `fn` |
| `S[0] := @j`, `@: q int S[0]`, `int: v_moved \q` | 40 | запись адреса в слот и чтение после неё |
| `int: v_kept \p` | 5 | прежняя ячейка осталась у того, кто на неё ссылается |
| `S[1] := S[0]`, `int: t_filled getType(S[1])` | 2 | слот без значения принимает место `int` |
| `int: n_after length(S)` | 3 | число слотов не изменилось |

После `S[0] := @j` и `S[1] := S[0]` дамп печатает оба слота как `int: j 40`: поле отвечает именем того, что держит
слот. 2, 13 и 1001024 — нынешние значения констант ядра; нормой они не закреплены.

Отрицательные фикстуры: `struct_index_range` (`getType(S[2])` при двух полях) — ответ 7; `struct_index_admit`
(`S[1] := @j`, где слот держит Structure) — ответ 4; `struct_index_base` (`getType(i[0])` для `int`) — ответ 4.
В режимах native и forced все три останавливают R0.

## Кортеж и проверки

Каталог `P` — `build2/codex_fix250generationchain01`; все команды инструмента — из `P/runs/fable-m6-01`; стадия —
`P/fable-main01`.

- **Manifest** `fable-source08` — 412 файлов.
- **Инструмент** `tool-f04` `f9de0c13…` (собран `boot-f03/lmxtool.exe` `2813b499…` на `rt-f03`: шаблоны рецепта);
  `tool-f05` `165fc733…` (собран `tool-f04` на `rt-f04`: граница ответа `graph-check`).
- **Runtime** `rt-f04` — `driver.o` `692c6b1a…`; **транслятор графа** `graph-f04` `0dc38fdf…`.
- **graph-check, первый прогон** (`tool-f04`, список `fable-graph-check-f04.tsv`): `CHECKS 88 lines, 1 failed` —
  строка `struct_index_range` отказала на входе команды: «interpreter answer must be 0..6». Остальные 87 строк прошли.
- **graph-check** (`tool-f05`, список `fable-graph-check-f05.tsv`, 88 строк — 84 прежние и четыре новые):
  `CHECKS 88 lines, 0 failed`, 264 PASS в режимах interp, native и forced.
- **Мутант:** `lmx_graph_index` читает слот `index + 1` (`rt-f04m` `a77351ff…`, `graph-f04m` `8a0a4366…`).
  `struct_index` падает во всех трёх режимах (`CHECKS 1 lines, 1 failed`); в дампе интерпретатора `t_cell` = 1001024,
  `t_uninit` = 13, `t_nested` = 0, `@: p int @u`, исполнение отвечает 3. Стадия восстановлена `stage-copy` из того же
  manifest и сверена с репозиторием.
- **bootstrap quick** `boot-f04` (инструмент `tool-f05`, hosted frontend `boot-f03/g2/frontend/l2trans.exe`
  `9f3003fb…`): `BOOTSTRAP quick 0 failures`, 19:05:16Z–19:17:58Z. Runtime G1 и G2 — `692c6b1a…`, побайтно `rt-f04`;
  frontend (`l2trans`, `l1trans`) и инструмент G1 и G2 — один образ, кроме штампа линковки (`exe-same` 1 для трёх
  пар). Рабочий инструмент дальше — `P/fable-main01/boot-f04/lmxtool.exe` `37a8a343…`, hosted frontend —
  `boot-f04/g2/frontend/l2trans.exe` `be7f2325…`.
- **Документы:** перегенерация книги и `docs check` на индексе — метка `docs108-fable01`, выход 0.

## Не сделано

- Прежний путь понижения — рабочий frontend с его `native` и обходчиком — индекса Structure не знает.
- Допуск записи сверяет род того, что держит слот; структурное соответствие двух Structure (`implements`) он не
  выполняет.
- Определение места значением `q: S[i]` не исполняется; по норме место объявляет ресивер (`@: q int S[i]`). Ссылочное
  место без требования `int` — `@: q S[i]` — корень чистого графа не исполняет: он знает только `@: имя int значение`.
- Отрицательный индекс проверен только границей в ядре; фикстуры с ним нет.

## Записи

[records.sha256](records.sha256): sha256 исходного файла, sha256 копии и путь копии. Копии в `records/` приведены к LF
(журналы инструмента пишут CRLF); имена файлов журналов режимов — `native-run.log`, `forced-run.log`.

- `records/pins/` — manifest исходников и списки graph-check;
- `records/runs/` — терминалы и выводы сборок, проверок, мутанта, bootstrap и сравнения поколений;
- `records/check-f05-struct_index*/`, `records/check-f05m-struct_index/` — записи запусков и журналы четырёх новых
  строк и мутанта.
