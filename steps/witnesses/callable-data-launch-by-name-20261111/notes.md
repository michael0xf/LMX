# Части вызываемого, Structure данных запуска, один связыватель форм, запуск Structure по имени — срез 356, 2026-11-11

Исполнитель: fable (чат «fable2»); правки исходников и фикстур писал помощник — чат «opus2» (Opus 5.5) — по заданию
исполнителя. Норма — решения и уточнения автора 2026-11-11:
[Structure в коде вызывается по имени](../../../LMX_blog/2026-11-11.md#structure-call-by-name),
[части описания вызываемого видят друг друга](../../../LMX_blog/2026-11-11.md#callable-parts-visibility),
[роли `data` и `code`](../../../LMX_blog/2026-11-11.md#data-code-roles),
[`data` перед `code`](../../../LMX_blog/2026-11-11.md#data-before-code). План — раздел
[M11](../../../next_core_tasks_v3.md#m11), шаг 5, подшаг 5б, первая часть. Чтения исполнителя — Р16 и Р20–Р23 в
[ответах](../../../LMX_blog/q/fable-self-answers-20261110.md).

Срез меняет только чистый граф (интерпретатор, выпускаемый `native`) и его фикстуры. Рабочий frontend этих правил не
исполняет — шаг 8.

## Что изменено

Подробно, по файлам и процедурам, — [итог помощника](../../handoff/m11-step5b-result-20261111.md) (раздел 1). Коротко:

1. **Имена частей вызываемого из его кода.** При поиске имени собственные записи кода пропускаются только у обычной
   Structure, запущенной над поданными данными. У вызываемого собственные поля — его части `args`, `data`, `code`,
   `return`, и в его коде они отвечают (`lmx_graph_resolve`).
2. **Structure данных запуска.** Строка кадра заводится только для места (`lmx_graph_work_open_parts`); именованная
   Structure модели данных строки не получает — её находит реестр данных запуска (`lmx_graph_data_find`), который
   `lmx_graph_resolve` читает у каждого запуска цепочки активаций: строки → формалы → реестр данных запуска →
   лексические уровни (Р20). Structure отвечает ссылкой: экземпляр один, запись пути пишет его самого, чтение снаружи
   и следующий вызов видят запись. Имя Structure данных — не место: захвата (`lmx_graph_work_capture`) и записи в
   голое имя нет; две записи имени и больше не отвечают ничем.
3. **Один связыватель форм** (`lmx_graph_receiver_form_of`). Контракты (`lmx_graph_receivers_open`): `call` —
   `[code]`, `[data code]`, `[args data code]`; `fncall` — `[return code]`, `[data return code]`,
   `[args data return code]`; запись запуска Structure — `[]`, `[data]`. Форма выбирается по написанным фактическим —
   по позиции или по имени через `:=` — до вычисления любого из них; операнды вычисляются в порядке записи.
   Связывание частей `fn` и `sub` переведено на тот же выбор формы. Выпускаемый код связывает запись при трансляции
   той же функцией (`lmx_graph_launch_formals` — экспорт; в списке экспорта интерпретатора 45 имён).
4. **Запуск Structure по имени** (`lmx_graph_launch_head`, `lmx_graph_eval_launch_record`). Запись с головой —
   обычной Structure запускает её в коде, отделённом от данных, — в коде вызываемого и в коде над поданными данными:
   `S()` — над собой, `S(D)` и `S(data := D)` — над `D`; запуск — тот же, что у ресивера `call`. Голова — место со
   ссылкой на обычную Structure запускает её везде, корень включая; голова — место числа — ответ 8; нет формы (два
   позиционных аргумента, аргумент другого имени) — 5; запись запуска на месте операнда — 5.
5. **Обход кода при открытии кадра** (`lmx_graph_work_scan`, `lmx_graph_scan_launch`). В записи запуска имя слева от
   `:=` выбирает формал запуска, а не свободный вход кода; написанная в скобках безымянная Structure — данные, как
   написаны: обход из неё ничего не читает (Р23).

## Фикстуры

21 новая и одна переписанная — таблицы в [итоге помощника](../../handoff/m11-step5b-result-20261111.md) (раздел 2).
Новые положительные: `callable_part_names`, `callable_data_structure`, `callable_data_write`,
`callable_data_path_write`, `callable_data_call`, `given_data_structure`, `callable_data_shadow`,
`caller_data_dynamic`, `callable_if_write`, `inner_write_local`, `inner_reads_outer` (последние три — проверки слов
автора о подструктурах `if` и о внутреннем методе), `struct_launch_method`, `struct_launch_given`,
`place_reference_launch`, `struct_launch_literal`, `call_named`. Новые отрицательные: `struct_launch_two` (5),
`struct_launch_args` (5), `struct_root_declares` (3), `struct_launch_operand` (5), `place_reference_unknown` (3 —
прежний текст `declare_place_reference`). Переписана `declare_place_reference`: ссылка на число, запись `p: other` —
ответ 8; ссылка на обычную Structure теперь запускает её. В `inputs.list` 536 входов.

## Проверки

Команды помощника — из `P/runs/opus-m11-5b`, исполнителя — из `P/runs/fable-m6-01`; `P` —
`build2/codex_fix250generationchain01`; сборки шли по одной, под замком `P/runs/pipeline.lock`. Времена — UTC.

| Метка | Кто | Что | Итог |
|---|---|---|---|
| `checks-o17` | opus2 | graph-check на его итоговой сборке (`rt-o16`, `graph-o16`, инструмент `tool-o03`), манифест `opus-source17`, 151 строка | `CHECKS 151 lines, 0 failed`; 453 `PASS` |
| `manifest56`, `stage56` | fable | манифест и наполнение стадии (21:22:55) | `MANIFEST 536 files, 0 failed`; `STAGED 536 files, 0 failed`; манифест 56 равен `opus-source17` |
| `tool-f21` | fable | переходный инструмент (`build-self`): список экспорта интерпретатора вырос до 45 имён | `lmxtool-tool.exe` `fbfa34c8…` |
| `boot-f25` | fable | `bootstrap quick` от `boot-f24` инструментом `tool-f21` (21:24:21–21:39:36) | `BOOTSTRAP quick 0 failures`; G1 и G2 собраны и испытаны; `SUITE 9 rows, 0 failures`; инструмент `boot-f25/lmxtool.exe` `eff2080c…`, hosted frontend `boot-f25/g2/frontend/l2trans.exe` `4d06b324…`, runtime `boot-f25/g2/runtime/driver.o` `d5e73aef…` — побайтно равен `rt-o16/driver.o` помощника |
| `graph-f27` | fable | транслятор графа инструментом и frontend `boot-f25` | `graph_trans-prod.exe` `fdb5bb80…` |
| `check-f27` | fable | graph-check на итоговом кортеже, список `fable-graph-check-f27.tsv` — строки списка помощника `o17` с путями кортежа (21:40:10–21:43:01) | `CHECKS 151 lines, 0 failed`; 453 `PASS` |
| `suite-f20` | fable | полный набор рабочего frontend на кортеже `boot-f25` (21:43:15–22:00:34) | `SUITE 162 rows, 0 failures`; 1240 `PASS` |
| `docs135-fable01` | fable | `docs check` на отдельном рабочем дереве `P/wt/docs135` с содержимым индекса среза (patch-id индекса тот же, что в основном checkout): документы в основном checkout в это время правит помощник «sonnet2» | строка `OK` |

Промежуточные сборки помощника (`o11`–`o16`) и их итоги — в его итоге, раздел 3: метка `rt-o14` сожжена отказом
трансляции (путь поля `state\w_call` на месте аргумента функции модуля рабочий frontend не типизирует — слово
кладётся в локальную переменную, как в остальном коде); `checks-o15` и `checks-o16` роняли одну строку —
`declare_place_reference` с прежним текстом, задуманный переворот.

## Мутанты

Семь мутантов помощника; каждый — правка файла стадии, сборка runtime и транслятора графа, свой список,
восстановление стадии из манифеста со сверкой. Все убиты (квитанции `checks-omK.out`):

| Мутант | Правка | Строки | Итог |
|---|---|---|---|
| m1 | пропуск собственных записей кода и у вызываемого | `callable_part_names` | `CHECKS 1 lines, 1 failed` |
| m2 | строка кадра и для Structure модели данных | `callable_data_structure`, `callable_data_write`, `callable_data_call` | `CHECKS 3 lines, 3 failed` |
| m3 | реестр данных запуска в цепочке активаций снят | `caller_data_dynamic`, `given_data_structure`, `struct_launch_given`, `callable_data_shadow` | `CHECKS 4 lines, 4 failed` |
| m4 | Structure поданных данных требуется как место | `given_data_structure` | `CHECKS 1 lines, 1 failed` |
| m5 | запись с головой — обычной Structure отказывает, как прежде | `struct_launch_method`, `struct_launch_given`, `place_reference_launch`, `struct_launch_literal`, `place_reference_unknown` | `CHECKS 5 lines, 5 failed`; у `place_reference_unknown` падает режим interp (ответ 8 вместо 3), native и forced отрицательной строки требуют только выход 1 |
| m6 | именованный аргумент читается операндом, как прежде, — интерпретатор | `call_named`, `struct_launch_method`, `struct_launch_literal` | `CHECKS 3 lines, 3 failed` в режимах interp и forced; native проходит — `:=` разворачивает эмиттер (m7) |
| m7 | то же в эмиттере | `call_named`, `struct_launch_method`, `struct_launch_literal` | `CHECKS 3 lines, 3 failed` в режиме native; interp и forced проходят — `:=` разворачивает интерпретатор (m6) |

Шаги «`call: Point` из кода метода» и «запись пути снаружи» своего кода не имеют: `callable_data_call` убита мутантом
m2, `callable_data_path_write` ни в один список мутантов не входила.

## Что проверил исполнитель сам

Прочитаны в интерпретаторе: реестр данных запуска в `lmx_graph_resolve`, строки кадра и захват
(`lmx_graph_work_open_parts`, `lmx_graph_work_capture`, `lmx_graph_work_load`), обход кадра (`lmx_graph_work_scan`,
`lmx_graph_scan_launch`), контракты (`lmx_graph_receivers_open`), выбор формы (`lmx_graph_forms_width`,
`lmx_graph_receiver_form_of`) и его вызов в `lmx_graph_receiver_bind`, формалы и операнды запуска
(`lmx_graph_launch_formals`, `lmx_graph_launch_actual`, `lmx_graph_launch_operand`), `lmx_graph_code_apart`,
`lmx_graph_launch_head`, `lmx_graph_eval_launch_record`, `lmx_graph_eval_explicit_call`, ветви запуска в
`lmx_graph_block`, `lmx_graph_exec_statement`, `lmx_graph_root_declares`, `lmx_graph_eval_number`; фикстуры
`call_named`, `struct_launch_method`, `place_reference_launch`, `declare_place_reference`. Решения помощника сверх
задания приняты ответом Р23. Эмиттер (`l2_graph_tool.lm2`), `lmx_graph_eval_fncall` и остальные фикстуры с ожиданиями
приняты по проверкам помощника и по итоговым сборкам этой записи.

## Пределы

- До подшага 5г корень единицы и Structure над собой роль кода у записи с головой — обычной Structure не исполняют:
  `S()` в корне рядом с объявлением `S` — ещё одно вхождение имени (`struct_root_declares`, ответ 3). Это состояние
  реализации, а не правило (Р22).
- Запись `data()` в коде пропускается (Р21, пункт 7) — вторая часть подшага 5б.
- `Add((int: v 7))`: P0 разворачивает единственную Structure в скобках в хвост записи (долг раздела M8); до его
  снятия безымянная Structure подаётся по имени (`Add(data := (int: v 5))`) или ресивером `call`
  (`call((int: v 3); Add)`).
- Чтение аргументов «целиком» и подача головой (`name: value`) остаются у частей `fn` и `sub`; подачу головой
  снимает подшаг 5е.
- Слово ресивера `call` или `fncall` на месте операнда находит строку контракта, как прежде `fn`, — состояние
  реализации (Р23).
- Голова — пустая ссылка (ответ 8 по Р22) фикстурой не показана: `@: p 0` отвечает 4, `@: p` — 5 на своей строке.
- Многострочная часть `data` в скобках с блоком `end:` читается с лишней записью `end: Имя` — вторая часть подшага
  5б; фикстуры этого среза пишут Structure данных вызываемого одной строкой.
- Слова `node` чистый граф не знает — вторая часть подшага 5б.

## Записи

`records/helper-runs` и `records/helper-pins` — квитанции и списки помощника (итоговая сборка `o16`/`o17`, инструмент
`tool-o03`, семь мутантов с восстановлениями стадии); `records/runs` и `records/pins` — квитанции и списки
исполнителя. Копии сняты с `tr -d '\r'`; контрольные суммы — [records.sha256](records.sha256).
