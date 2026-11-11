# Имена `data` и `code`, порядок `data` перед `code` в чистом графе — срез 354, 2026-11-11

Исполнитель: fable. Норма — решения автора 2026-11-11:
[роли `data` и `code`](../../../LMX_blog/2026-11-11.md#data-code-roles) (особое имя данных запуска и часть
вызываемого называются `data`, прежде `var`; часть с исполняемыми записями — `code`, прежде `body`) и
[`data` перед `code`](../../../LMX_blog/2026-11-11.md#data-before-code) (двухаргументная запись — `call: data code`).
План — раздел [M11](../../../next_core_tasks_v3.md#m11), шаг 4.

Срез меняет только чистый граф — построитель, ядро, интерпретатор, выпускаемый `native` — и его фикстуры. Рабочий
frontend и его фикстуры (`tests/dyn`, `tests/os_twins`) читают прежние имена `var`, `body` и прежний порядок
`call: code data` — шаг 8 того же раздела. Чтение по ролям (реестр данных, атом-указатель, структурная запись в коде
— вызов) в срез не входит — шаг 5.

## Что изменено

1. **Имена** (`tools/build.lm2`, `src/l2src/lmx_graph.lm2`, `lmx_graph_run.lm2`, `l2_graph_build.lm2`,
   `l2_graph_tool.lm2`, `l2_frontend_graph.lm2`). Слова состояния графа `w_var` и `w_body` заменены словами `w_data`
   (текст `data`) и `w_code` (текст `code`) — в шаблоне заголовка состояния (`tools/build.lm2`) и в ядре; из списка
   слов языка чистого графа `var` и `body` убраны, `code` и `data` в нём есть. Операции ядра
   `lmx_graph_method_var` и `lmx_graph_method_body` называются `lmx_graph_method_data` и `lmx_graph_method_code`
   (список экспорта `graph_names[35]`, `[36]`). Контракты ресиверов `fn` и `sub` называют свои аргументы
   `name, args, return, data, code` (`sub` — без `return`); части созданной Structure — `args`, `return`, `data`,
   `code`. Прежние написания слов не имеют особого смысла: `var` и `body` — обычные имена.
2. **Порядок** (`lmx_graph_run.lm2`, `l2_graph_tool.lm2`). Двухаргументный `call` читает первым аргументом данные,
   вторым код: `lmx_graph_eval_explicit_call` вычисляет операнд 0 как данные, операнд 1 как код — в порядке записи;
   `lm_graph_emit_explicit_call` выпускает то же. Операция ядра стала
   `lmx_graph_call_data(g, given_data, given_code, shorthand)` (данные перед кодом); одноаргументная запись зовёт её
   с данными 0 и признаком короткой записи. Трёхаргументный `call` (`args data code`) и `fncall`
   (`return code`, `data return code`, `args data return code`) порядок не меняли: данные в них уже стояли перед
   кодом.
3. **Фикстуры `tests/graph`.** Изменено 60 отслеживаемых файлов — 44 исходника и 16 ожиданий: `var` → `data`,
   `body` → `code` в частях, блоках, путях и именованных аргументах (в `merge_arguments` имя `body` — переменная и
   осталось). Переставлены 18 двухаргументных строк `call` в 11 фикстурах — `call_data_whole`, `call_returns_value`,
   `code_data`, `code_data_missing`, `control_flow`, `control_missing`, `known_assignment`,
   `known_assignment_selected`, `post_loop`, `sub_calls`, `var_copy_nesting` — и те же строки в шести ожиданиях
   (`call_data_whole`, `code_data`, `control_flow`, `known_assignment`, `post_loop`, `sub_calls`). Поправлены
   комментарии, называвшие прежние имена и порядок. Имена файлов `call_var_not_selected`, `code_data_no_var`,
   `var_copy_nesting` прежние.
4. **Новые отрицательные фикстуры** (внесены в `inputs.list`, 469 входов):

   | Фикстура | Запись | Ответ | Почему |
   |---|---|---|---|
   | `former_var_part` | `fn: f () int (int: x 5)` и чтение `f\var\x` | 3 | `var` — обычное имя, части `f` с таким именем нет |
   | `former_body_part` | `fn: name := k1; args := (int: a); return := int; body := (return: a + 1)` | 5 | у контракта `fn` нет формала `body` |
   | `former_var_block` | блок `var:` внутри `Code`, `call: Code\var Code` | 3 | голова `var` в коде `Code` — обычное имя, запуск его не находит |
   | `former_call_order` | `call: Code Data` при коде в `Code` и месте в `Data` | 3 | первым аргументом читаются данные: данными служит `Code`, кодом — `Data` |

   Отрицательная строка graph-check в режимах `native` и `forced` транслируется и отказывает при исполнении.

## Проверки

Все команды — из `P/runs/fable-m6-01`, `P` — `build2/codex_fix250generationchain01`; сборки шли по одной. Времена — UTC.

| Метка | Что | Итог |
|---|---|---|
| `manifest53`, `stage53` | манифест текстов и наполнение стадии | `MANIFEST 469 files, 0 failed`; `STAGED 469 files, 0 failed` |
| `rt-f17`, `graph-f24` | runtime и транслятор графа переходным инструментом `tool-f19` | `driver.o` `96a690e9…`; `graph_trans-prod.exe` `79d51835…` |
| `check-f23` | graph-check, список `fable-graph-check-f23.tsv` | `CHECKS 113 lines, 0 failed`; 339 строк `PASS` (три режима) |
| `boot-f23` | `bootstrap quick` от `boot-f22` (16:43:59–16:58:53) | `BOOTSTRAP quick 0 failures`; G1 и G2 собраны и испытаны; `SUITE 9 rows, 0 failures` |
| `graph-f25` | транслятор графа инструментом и frontend `boot-f23` | `graph_trans-prod.exe` `ed264b77…` |
| `check-f24` | graph-check на итоговом кортеже, список `f24` (16:59:41–17:02:00) | `CHECKS 113 lines, 0 failed`; 339 `PASS` |
| `suite-f18` | полный набор рабочего frontend (17:02:18–17:20:12) | `SUITE 162 rows, 0 failures`; 1240 `PASS` |
| `manifest54`, `stage54` | манифест после правки комментария одной фикстуры | `MANIFEST 469 files, 0 failed`; `STAGED 469 files, 0 failed` |
| `check-f25` | graph-check на итоговом кортеже и манифесте 54, список `f25` (17:27:32–17:29:51) | `CHECKS 113 lines, 0 failed`; 339 `PASS` |
| `docs127-fable01` | `docs check` в основном checkout | отказ фазы грамматики (`status 1`): она читает рабочие файлы `provenance/grammar.json` и `docs/LMX_grammar.*.md`, которые в это время правит проход по документации; в срез эти файлы не входят |
| `docs128-fable01` | `docs check` на отдельном рабочем дереве `P/wt/docs128`: коммит `e78b1067` и индекс среза, patch-id индекса тот же, что в основном checkout (17:35:23–17:39:02) | `OK: 35 paired semantic chapters, 14 implements cases, both source snapshots; 27 paired grammar sections, 44 verbatim source excerpts, 615 imported files, links, exact semantic opening; line endings LF in the index for all 26512 tracked files` |
| `docs129-fable01` | то же дерево после последних правок записей среза (эта заметка, `steps/current.md`) | строка `OK` с теми же числами глав, разделов и выдержек |

Манифест 54 отличается от манифеста 53 одним файлом — `tests/graph/call_var_not_selected.lm2`: комментарий называл
прежний порядок (`call: Code Code\data`), исполняемых строк правка не касается. `bootstrap quick` и полный набор шли
на манифесте 53; фикстуры `tests/graph` ни тот, ни другой не читают. Список `f25` получен из списка `f24` заменой
каталогов результатов (`check-f24-` → `check-f25-`); строка его заголовка по-прежнему называет манифест 53 — стадия
при запуске `check-f25` была наполнена манифестом 54 (квитанция `stage54`). Манифест 53 отличается от манифеста 52 одним
комментарием фикстуры `former_var_block`, манифест 52 от 51 — четырьмя исходниками и пятью фикстурами (правки
комментариев по сверке помощника); на промежуточных манифестах собирались `rt-f16`, `graph-f23` и шёл `check-f22`
(`CHECKS 113 lines, 0 failed`) — эти записи в свидетельство не скопированы.

Образ runtime `boot-f23/g2/runtime/driver.o` (`96a690e9…`) побайтно равен `rt-f17/driver.o`. Образ frontend
изменился (`l2_frontend_graph.lm2` зовёт переименованные операции): hosted `boot-f23/g2/frontend/l2trans.exe` —
`5413c361…`, инструмент `boot-f23/lmxtool.exe` — `ca82f1e3…`.

## Мутанты

Оба мутанта собраны полностью (манифест, стадия, runtime, транслятор графа) и проверены своими списками; после
каждого исходники возвращены, а стадия наполнена манифестом 53 (`stage53r1`, `stage53r2`: `STAGED 469 files,
0 failed`); рабочее дерево сверено с манифестом по sha256.

| Мутант | Правка | Сборка | Список и итог |
|---|---|---|---|
| 1. Принято прежнее слово `var` | `lmx_graph.lm2`: слово `w_data` заводится из текста `var` | `manifest53m1`, `stage53m1`, `rt-f17m1`, `graph-f24m1` | `f23m1`: `former_var_part`, `former_var_block`, `code_data` — `CHECKS 3 lines, 3 failed` |
| 2. Прежний порядок аргументов | `lmx_graph_run.lm2` и `l2_graph_tool.lm2`: операнд 0 — код, операнд 1 — данные | `manifest53m2`, `stage53m2`, `rt-f17m2`, `graph-f24m2` | `f23m2`: `former_call_order`, `code_data`, `call_data_whole`, `sub_calls` — `CHECKS 4 lines, 4 failed` |

В обоих списках каждая строка отказывает во всех трёх режимах.

## Сверка помощником

Дифф имён прочитал помощник — чат «opus2» (Opus 5.5): в исполняемом коде прежних слов не осталось; по его замечаниям
поправлены комментарии исходников и фикстур (манифесты 52 и 53). Его же замечание о локальной переменной `code` в
`lmx_process_deadline.lm2` не подтвердилось: строка `deadline_machine` полного набора проходит.

## Пределы

- Порядок параметров остальных внутренних процедур ядра — `lmx_graph_invoke_data`, `lmx_graph_work_open_data`,
  `lmx_call_prim` (код, затем данные) — не менялся: это не запись языка
  ([ответ исполнителя Р5](../../../LMX_blog/q/fable-self-answers-20261110.md)); меняются, когда их касается правка.
- Шаблон заголовка обходчика рабочего frontend в `tools/build.lm2` описывает его операцию по-прежнему
  (`call: code data`) — это поведение рабочего frontend, шаг 8.
- Чистый граф по-прежнему объявляет Structure при обходе корня, связывает атом в момент исполнения объявления и
  заменяет содержимое при повторе — шаг 5.

## Записи

`records/pins` — манифесты `fable-source53`, `53m1`, `53m2`, `54` и списки graph-check `f23`, `f23m1`, `f23m2`,
`f24`, `f25`; `records/runs` — квитанции меток из таблиц выше, в том числе `docs127.out`, `docs128.out`,
`docs129.out`. Копии сняты с `tr -d '\r'`;
контрольные суммы — [records.sha256](records.sha256). Каталоги результатов graph-check лежат в стадии
(`P/fable-main01/check-fNN-<имя>`) и в свидетельство не входят.
