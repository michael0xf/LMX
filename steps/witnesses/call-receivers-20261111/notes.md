# Ресиверы `call` и `fncall` в чистом графе — срез 353, 2026-11-11

Исполнитель: fable. Норма — решение автора 2026-11-11:
[ресиверы `call` и `fncall`](../../../LMX_blog/2026-11-11.md#call-receivers); книга —
[ресиверы `call` и `fncall`](../../../docs/LMX_semantics.ru.md#call-receivers). План — раздел
[M10](../../../next_core_tasks_v3.md#m10), шаги 1–5 для чистого графа (интерпретатор и выпускаемый им `native`).
Рабочий frontend (понижение L3 и обходчик) в срез не входит — шаг 6. Чтения исполнителя — часть Н
[ответов](../../../LMX_blog/q/fable-self-answers-20261110.md); открытый вопрос автору — П6, порядок аргументов
двухаргументной записи: срез читает её по-прежнему, `call: code data`.

## Что изменено

1. **Части запуска в рабочем кадре** (`tools/build.lm2`, шаблон `LmxGraphFrame`; `src/l2src/lmx_graph_run.lm2`).
   Кадр активации получил поля `args` (Structure формалов), `body` (тело), `result` (есть ли результат) и `own`
   (данные — собственная `var` вызываемого). Кадр открывает `lmx_graph_work_open_parts`; прежняя
   `lmx_graph_work_open_data` берёт части у самого кода и зовёт её. Исполняющийся код читает формалы
   (`lmx_graph_activation_args` — в `lmx_graph_named_int`, `lmx_graph_local_int`, `lmx_graph_known_int`,
   `lmx_graph_store_name`, `lmx_graph_resolve`, `lmx_graph_work_capture`), тело (`lmx_graph_method_run`) и наличие
   результата (`lmx_graph_launch_result` — в `lmx_graph_block`) из кадра, а не из Structure метода. Активация без
   кадра отвечает по Structure, как прежде.
2. **Запуск по поданным частям** (`lmx_graph_launch`). Формалы — поля Structure аргументов: место `int` со
   значением даёт запуску независимую ячейку, место-ссылка передаётся как есть, прочее — ответ 5. Данные не
   дозаполняются. Описание результата — слово `int` (каноническое слово, не ячейка), иначе 5. Без данных обычная
   Structure исполняется над самой собой, вызываемое — над своей `var`. Вызываемое без поданных аргументов
   сохраняет свой контракт и вход (`lmx_graph_invoke_data`); с поданными — формалами служат поля поданной Structure,
   тело интерпретируется.
3. **Ресиверы** (`lmx_graph_eval_explicit_call`, `lmx_graph_eval_fncall`). `call` принимает один, два или три
   аргумента: три — `args var code`; один — обычная Structure над самой собой (`lmx_graph_call_data` больше не
   выбирает её `var`), вызываемое — над своей `var`; два — по-прежнему `code data`. `fncall` принимает два, три или
   четыре: `return code`, `var return code`, `args var return code`; он стоит операндом (`lmx_graph_eval_number`)
   и оператором (тело, корень). `fncall` — слово языка: `w_fncall` в состоянии графа, слово в списке ресиверов
   (`lmx_graph_receivers_in`), в `lmx_graph_language_word`.
4. **Данные читаются целиком** (`lmx_graph_data_realize`). Перед привязкой мест вычисляемые объявления корневого
   уровня данных (`int: имя выражение`) исполняются по порядку полей и публикуются в свои слоты, один раз — при
   всяком запуске, кроме запуска вызываемого над собственной `var`.
5. **Выпускаемый `native`** (`src/l2src/l2_graph_tool.lm2`): `lm_graph_emit_fncall`, трёхаргументная ветвь
   `lm_graph_emit_explicit_call` — код зовёт `lmx_graph_launch`; неверное число аргументов выпускается отказом на
   месте исполнения. Имя `lmx_graph_launch` добавлено в список экспорта `graph_run_names` (41).

## Перепись строк `call:` (шаг 1)

Поиск: `git grep -n -E '^\s*call: '` по `selfbuild`, на начало среза. Одноаргументных строк 32, двухаргументных 91
(из них десять — `call: X X`), всего 123. В `tests/graph` — 9 одноаргументных (пять в исходниках, четыре в
ожиданиях) и 24 двухаргументных; в `tests/dyn` и `tests/os_twins` — 23 и 67.

Одноаргументные строки `tests/dyn` и `tests/os_twins` по виду цели:

| Вид цели | Строк | Где | По новой норме |
|---|---|---|---|
| метод (`fn`, `sub`) | 9 | `assign_known` 59; `callable_place_signature` 195, 205; `formal_defaults` 106; `struct_call_throws` 18, 24, 32, 45; `sub_parts` 124 | не меняется: метод исполняется над своей `var` |
| Structure без `var` | 11 | `absent_head_definition` 19, 23, 27; `place_write_form` 249; `struct_call_selected` 17, 22; `structure_path_write` 134; `unary_data_selection` 22, 45, 49; `written_path_form` 86 | итог тот же: десять целей своих мест не объявляют; `unary_data_selection` 22 (`S` с `int: x 2` и `x := 4`) отказывает и над самой собой — две головы `x` |
| Structure с `var` | 3 | `written_form` 225 (`Two`, две формы `var:`); `os_twins/named_call_below_os` 27 и `named_call_below_unit` 17 (`Counter`) | меняет смысл: `var` больше не выбирается — шаг 6 |

Одноаргументные строки `tests/graph`: `code_data` — `call: Code` (с `var`: переведена) и `call: Free` (без `var`,
свободное внешнее имя: итог тот же); `code_data_no_var` — `call: Code` (без `var`: был отказ, стала положительной);
`post_loop` — `call: RepeatOwn` (с `var`: переведена); `sub_calls` — `call: add` (метод: не меняется).

## Фикстуры

Новые строки graph-check:

| Фикстура | Строка | Что проверяет |
|---|---|---|
| `graph/call_receivers` | положительная | шесть форм; `fncall` оператором; ресиверы в теле метода; части метода по отдельности; `sub` по частям; композиция из частей трёх структур |
| `graph/call_data_whole` | положительная | значение поля раньше строки его объявления — над самой собой и над поданными данными; вычисляемое начальное значение; оно исполняется один раз |
| `graph/call_var_not_selected` | ответ 3 | одноаргументный `call` над Structure, чьи места объявлены в её `var` |
| `graph/call_data_lacks` | ответ 3 | данные без используемой переменной, через `fncall` |
| `graph/call_self_repeat` | ответ 3 | `call(code)` при двух корневых объявлениях переменной |
| `graph/fncall_arity`, `graph/call_arity` | ответ 5 | неверное число аргументов |
| `graph/call_returns_value` | ответ 5 | `call` над телом, возвращающим значение |
| `graph/fncall_no_result` | ответ 5 | `fncall` над телом без результата |
| `graph/fncall_result_word` | ответ 5 | описание результата — не слово `int` |

Изменённые: `graph/code_data` (`call: Code` → `call: Code Code\var`, имена `passed_x`, `passed_y`; значения те же),
`graph/post_loop` (`call: RepeatOwn` → `call: RepeatOwn RepeatOwn\var`), `graph/code_data_no_var` (была отказом 3,
теперь положительная: `Code\x` = 7, корневое `x` = 5).

## Пределы

- Формалы поданной Structure аргументов — места `int` со значением и места-ссылки; результат — только `int`.
- `catch` в чистом графе не исполняется вовсе; его запуск частями не проверен.
- Двухаргументная запись читается `call: code data` (вопрос П6).
- У Structure над самой собой вычисляемое объявление исполняется до первого оператора и на своей строке повторно не
  исполняется: объявление `int: b a` после `a := a + 1` получает прежнее `a`. Это чтение исполнителя (ответы, Н11).
- Шаг 5 раздела M9 в чистом графе не сделан: повтор со значением в корне место не записывает, голый путь при двух
  головах выбирает первое вхождение, путь с индексом вхождения не строится.

## Измерение `Model: KnownStruct` (вопрос автора в ходе среза)

Автор: «Проверь: Model: KnownStruct сейчас какое дерево порождает в интерпретаторе и трансляторе?» Кортеж среза 352
(`graph-f18`, `fe-f17`); пробы `x01`–`x06`, `y01`–`y04`, выводы — `records/probes/x-interp.txt` и
`records/probes/probes-y-fe-f17.txt`:

| Проба | Запись | Итог |
|---|---|---|
| `x01` | `Model: KnownStruct`, `Model` неизвестна | P0: Frame `Model` с атомом; после исполнения `Model` содержит Structure `KnownStruct` под её именем |
| `x02` | то же, `Model` уже Structure с `int: z 9` | содержимое заменено: `z` нет, второго поля `Model` нет |
| `x03` | `length(Model)`, `length(Model\KnownStruct)`, запись `Model\KnownStruct\a := 7` | 1 и 2; `KnownStruct\a` тоже 7 — тот же экземпляр |
| `x04` | `KnownStruct` объявлена ниже | в `Model` остаётся слово `KnownStruct` |
| `x05` | форма в теле метода | ответ 3: в теле метода не исполняется |
| `x06` | `Model(KnownStruct)`, `Other: (KnownStruct)` | то же дерево: P0 раскрывает единственную Structure |
| `x01`–`x03` в трёх режимах | `records/runs/x-check.out` | `CHECKS 3 lines, 0 failed`: `native` и `forced` дают то же дерево |
| `y01`, `y03`, `y04` | рабочий frontend, `Model` неизвестна | отказ трансляции: «a form with a colon whose head names nothing declares a Structure with its tail inside, not a place…» (`y01` — «unknown field path segment» на чтении пути) |
| `y02` | рабочий frontend, `Model` — известная Structure | отказ трансляции: «a form with a colon declares and writes no known place…» |

## Проверки

- **Пробы интерпретатора** (`records/probes/`; выводы сняты скриптом `interp.sh`): `k01`–`k03`
  (`k-interp-f18.txt`) — запись `call(Code Data)` даёт тот же Frame, что `call: Code Data`; метод — Structure из
  четырёх частей. `h08`–`h14` (`h08-14-interp-f18.txt`) — что чистый граф исполнял до среза (`graph-f18`): значение
  поля раньше строки объявления читается (6), вычисляемое поле данных не реализуется (ответ 3), вычисляемая `var`
  метода исполняется при входе. `z01`–`z04` (`z-interp-f21.txt`) — новый интерпретатор (писались на `graph-f19` и
  `graph-f20`, вывод снят на `graph-f21`): шесть форм, части метода, реализация данных, метод над чужими данными с
  вычисляемым полем; `z01`–`z03` в трёх режимах — `CHECKS 3 lines, 0 failed` (`records/runs/z-check.out`, список
  `records/probes/z-check.tsv`).
- **Переходный инструмент** `tool-f18` (`build-self` новых текстов): изменились шаблон заголовка (`LmxGraphFrame`,
  `LmxGraphState`) и список экспорта.
- **Первый кортеж** (`rt-f14`, `graph-f19`, manifest 47) и список graph-check `f18`: `CHECKS 108 lines, 1 failed` —
  `fncall_arity` в режиме `native`: эмиттер отказывал при трансляции, а отрицательная строка требует отказа при
  исполнении. Неверное число аргументов `fncall` и `call` эмиттер теперь выпускает отказом на месте исполнения;
  добавлена фикстура `call_arity`. Второй список `f19` (`graph-f20`, manifest 48): `CHECKS 109 lines, 0 failed`.
- **Мутант «ресивер берёт данные из Structure кода»** (manifest `49m1`: в `lmx_graph_launch` поданные данные
  заменены кодом; `rt-f14m1`, `graph-f20m1`; список `f19m1`): `call_receivers` падает в трёх режимах —
  `CHECKS 1 lines, 1 failed`. После сборки исходник и стадия возвращены и сверены с manifest 49 по sha256
  (`records/runs/stage49b.out`).
- **Кортеж** (`boot-f22`, manifest 49, 465 входов): `bootstrap quick` — 0 отказов, малый набор — 9 строк, 0 отказов;
  G1 = G2 (`EXE-SAME 1` для frontend); `l1trans` тот же, что в `boot-f21`; hosted frontend, инструмент и `driver.o`
  другие — в них ядро чистого графа и шаблон заголовка (`driver.o` `9296be5d…`, побайтно равен `rt-f14`);
  `graph-f21` = `graph-f20` (`records/runs/exe-same-f22.out`). Инструмент `boot-f22/lmxtool.exe` — `35736274…`,
  frontend `boot-f22/g2/frontend/l2trans.exe` — `0cc9a2e1…`.
- **Graph-check на кортеже** (список `f20`: frontend и runtime `boot-f22/g2`, `graph-f21`):
  `CHECKS 109 lines, 0 failed`, 327 PASS — 99 прежних фикстур и 10 новых в режимах интерпретатора, `native` и
  `forced`.
- **Полный набор** (`suite-f17`: hosted frontend и runtime `boot-f22/g2`): `SUITE 162 rows, 0 failures`, 1240 PASS,
  17m03s. Рабочий frontend срезом не менялся; набор проверяет его на новом `driver.o`.
- **Документы:** `docs check` на индексе этого коммита — `records/runs/docs123.out`.

## Записи

`records.sha256` — sha256 каждого файла `records/`. `records/pins` — manifest 46–49, `49m1` и списки graph-check
`f18`, `f19`, `f19m1`, `f20`; `records/runs` — выводы сборок, проверок, мутанта, наборов и проверки документов;
`records/probes` — исходники проб (`k`, `x`, `y`, `h08`–`h14`, `z`), их итоги, ожидания и списки проверки проб
`x` и `z` в трёх режимах, скрипты проб (`interp.sh` — интерпретатор чистого графа; `probesum.sh` и `runprobe2.sh` —
рабочий frontend).
