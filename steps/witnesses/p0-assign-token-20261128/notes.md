# Токен `:=` в начале поля общего P0: срез грамматики (28 ноября 2026 года)

Ведущий `coder`. Приказ Sol: `SOL-CODER-P0-DEPTH-V3-20261128`, второй срез (граница `:=`). Проект согласован Sol до
кода: `build2/coder-grammar-20261127/DESIGN-ASSIGN-1.md`; ответы Sol на пять вопросов: голая форма и контексты корня,
индекса и вызова читаются той же механикой и остаются пробами без обещания исполнения; защита построителя входит в
срез; текст сообщения — «bare := requires its Expression projection»; многострочная форма проверяется по раскладке.
База: набор `coder-depth02` (`deeb02c06`). План: этап 1, переходный критерий (5)
([очередь](../../../next_core_tasks_v3.md#grammar-complete-20261127)).

## Норма

- `docs/spec/LMX_grammar.ru.md:61`: левой частью `:=` может быть безымянная Structure мест — `(a b c) := (c, a, b)`,
  `(a b) := (copy(Pair))`; для позиционной записи результата вызова в группу мест используется `(a b c) := f()`;
  непустая ограниченная Structure, за которой стоит `:=`, — левая часть записи, правая часть разбирается по общим
  правилам выражений; этот случай отделён от группы в голове Frame.
- `docs/spec/LMX_grammar.ru.md:424`: P0 сохраняет группу, а общий механизм Expression подготавливает её.
- `docs/spec/LMX_grammar.ru.md:1313`: `:=` остаётся цельным токеном и не становится разделителем.
- `selfbuild/src/l2src/p0_scan.lm2:32–34`: `:=` — один токен, никогда `:` затем `=`.

## Что сделано

- **Одно условие рядом с атомом `::`.** Поле с пустой головой, начинающееся двумя байтами `:=`, берёт их как голову;
  путь компактного атома даёт атом `:=` длины 2 со своим диапазоном. `(a b c) := f()` читается как Structure(a, b, c),
  атом `:=`, Frame `f`; роль выбирает потребитель, не P0. Новой функции, флага и кода состояния нет. До среза форма
  отвергалась кодом 6 «unexpected character in field list» на токене.
- **Не менялось.** Frame ASSIGN с непустой головой (`a := b`, `a:=b`, в группе, вызове, индексе и условии); ветвь
  группы; разделители среза; атом `::`; условное двоеточие; `(Model): p`; `(a b c) : = f()` по-прежнему отвергается
  кодом 6. Дерево каждого источника, который база принимала, сохраняется: условие лежит на пути, ведшем к коду 6.
- **Построитель.** `lm_graph_build_node` (`l2_graph_build.lm2`) отвергает атом из двух байт `:=` рядом с отказом
  условному вопросу: «bare := requires its Expression projection». Поля до него могут быть уже построены; программа не
  передаётся исполнителю или генератору, ничего не исполняется. Текст сравнивается как написанный: точное имя
  `` `:=` `` держит кавычки и не встречается.

## Случаи набора

Ожидания записаны до запуска кандидата (`assign-01/suite_assign_cases.py`, `assign_check.py`).

- 9 новых случаев `assign_group_*`, `assign_token_*`: дерево двойника с `::` из базы с заменой текста атома —
  `(a b c) := f()`, слитная запись, `(a b) := (copy(Pair))`, `(a b c) := f(); g()`, `(:= a b)`, `:= a`,
  `x: (a b c) := f()`, форма на отступе, `(a b c) :=`.
- 12 контролей `assign_kept_*` с деревьями базы `coder-depth02`; один отвергающий контроль
  `assign_colon_space_equal_refused` (6@1:9).
- Одно ожидание обновлено на месте по указанию Sol (06:24): `t233_g05_empty_group_assign.lmx` (`():= 5`) — было
  «отвергнуто, как `(a) := 5` сегодня», стало Structure(()), атом `:=`, атом `5` — дерево двойника `() :: 5` базы.
  У P0 нет условия на пустоту группы; пустая группа — не допустимая левая часть записи, это отказывает потребитель.

Четыре ожидания моего проверочного сценария были записаны неверно и поправлены до записи результатов: печать двух
форм в индексе (поля индекса лежат на одном уровне, как у `x[a b]`), форма с двумя атомами (`::` в правой части
заменяется вместе с токеном), номер строки токена в программе построителя (17, три строки комментария). Кандидат во
всех четырёх дал печать по механике.

## Расписки

Кандидат: стадия `build2/coder-grammar-20261127/stage-assign-01`, тег `coder-assign01`, собран от набора
`coder-depth02` (инструмент `c44987ab`, frontend `b02b5119`, runtime `ca11ca11` / `3fdafeaf`). Исходники:
`p0_parser.lm2` — `0f4d6c9d8b228956…`, `l2_graph_build.lm2` — `ffa300d47fff7156…`.

| Производитель | SHA-256 |
| --- | --- |
| Инструмент `coder-assign01-tool01/lmxtool-tool.exe` | `900292fcea9cbe11b888a869f36041703da97d9932da15886dae4b551ea5f93f` |
| Frontend `coder-assign01-feh01/l2trans.exe` | `8e2e6b808b6fa82ec2efface282a87644f7cdfe2a6a33dac95ff188875a92502` |
| Runtime `coder-assign01-rt02/driver.o` (новым frontend; равен объекту от `b02b5119`) | `ca11ca11eb62c3c1a8782ed1a7ac275703d75f031d78e997f9f210d10c6e0a8a` |
| Graph `coder-assign01-graph02/graph_trans-prod.exe` | `b067417a53b956d208aa3a4673c128db33a4bc1b315fc523914881f7d01682fe` |

Манифест: `verify selfbuild/inputs.sha256` по дереву и по стадии — VERIFIED 1936 files, sha `d4639b3e`.
База сравнений — набор `coder-depth02` (Graph `52dbe627`). Расписки — `build2/coder-grammar-20261127/assign-01/`.

| Проверка | Результат | Расписка |
| --- | --- | --- |
| `parser-suite` | PARSER-SUITE 593 cases, 0 failed | `light/ps-final/` |
| `parser-bounds` | PARSER-BOUNDS cases 501, rows 535, nested 99, empty 83, multiline 45, mix 75, failed 0 | `light/pb-final/` |
| Корпус, база против кандидата: `p0 FILE` / `flags` / `nodes` | SAME 1734, DIFFERENT 30 = 10 случаев перехода в трёх режимах | `light/p0-same.out` |
| Деревья собственных исходников (`selfbuild/src`, `tools`, `tests`, `tests/parser`) | 2013 файлов: SAME 2003 (обоими приняты 1870, отвергнуты 133); 10 иных — все приняты теперь (9 новых случаев и `t233_g05_empty_group_assign`); ни одно дерево базы не изменилось | `own-diff.tsv` |
| Деревья исходников `docs` | 2603 файлов: SAME 2557; 46 иных — все приняты теперь, база отвергала каждый кодом 6 на `:=` (перечень ниже) | `docs-diff.tsv` |
| 28 форм (`assign_check.py`) | 24 — дерево двойника с `::`; 4 — записанная печать (`x[:= a]`, `x[(a b) := f()]`, `(a b c) := ::`, `a := := b`); не как ожидалось — 0 | `check/assign-check.out` |
| Построитель, положительный контроль `builder_positive.lmx` (`touch()` оператором корня) | run rc 0; после запуска `Observed: int: hits 1` | `check/builder_positive.run.out` |
| Построитель, `builder_group_assign.lmx` (`(a b c) := touch()`) и `builder_bare_assign.lmx` (`:= touch()`) | check, run и emit native: `build answered 2`, «bare := requires its Expression projection» на 17:9 и 16:1; запуска нет, файла выдачи нет | `check/*.check.out`, `extra/` |
| 26 проб среза 1a с диагностикой | SAME 26, DIFFERENT 0 | `light/probes.out` |
| Реестр ограниченных форм (588 случаев) | строки 578 случаев равны базе; 10 иных — случаи перехода | `light/bounds-diff.out` |
| lmx-dev, связка `depth-removal-depth02`, `check:syntax` двух изменённых модулей | passed, achievedPhase `P0 syntax`; runId `20261128-062730-bbfe90a26b72` (`p0_parser.lm2`), `20261128-062733-7c1e28614db9` (`l2_graph_build.lm2`) | `build2/lmx_dev/runs/` |

Источники `docs`, принятые теперь (46): 18 живых — `docs/spec/examples/array_expressions/place_rotation.lm3` и его
копия в `doc_examples`, `assignment_forms/004_place_rotation`, `009_returned_array`, `010_sibling_groups` и три
копии, `expression_slices/006_group_rotation` и копия, `operator_depth/002_assignment_levels` и копия,
`patterns/10_algorithms/examples/lmx/common/103_union_find.lm3`,
`patterns/11_state_and_simulation_patterns/examples/lmx/shared/106_double_buffer.lm3`,
`patterns/LMX_Fn_Receivers/LMX_Receivers.lmx`, `patterns/LMX_Fn_Receivers/examples/fn_and_assignment.lmx`,
`generic_callable_examples.lmx`, `patterns/examples/haskell_comparision/source/lmx/R02.lm3`; и 28 копий в снимках
`docs/tasks/24-Nov-2026` (4), `25-Nov-2026` (6), `27-Nov-2026` (18). Это примеры нормы с формой `(a b c) := f()`,
которые общий P0 отвергал до этого среза.

## Что этим не заявлено

- Широкие проверки набора (полный список, самопроверки ядра, набор графа, `bootstrap quick`) в этом окне не
  запускались: они должны следующему сеансу, прежде чем набор станет базой широких заявлений.
- Контексты корня, индекса и вызова вне случаев набора — пробы (`assign-01/check/assign-check.out`); смысл этих
  записей определит механизм Expression.
- Путь размещённого frontend (P0 → `lm_p0_lower_types` → L1) на этой форме не измерялся.
- `check:translate` через связку lmx-dev для машинного модуля не заявляется: фаза переводит файл как программу.
  Перевод подтверждён ручной трансляцией frontend `coder-depth02` (exit 0) и сборкой цепочки из него.
