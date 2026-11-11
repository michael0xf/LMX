# Составная форма в рабочем frontend — срез 351, 2026-11-11

Исполнитель: fable. Норма — решение автора 2026-11-10:
[место объявляет только `ресивер: аргументы`](../../../LMX_blog/2026-11-10.md#receiver-args-only),
[суть ошибки составной формы](../../../LMX_blog/2026-11-10.md#composed-form-breaks-structure); книга —
[объявление места](../../../docs/LMX_semantics.ru.md#receiver-args-only). План — раздел
[M9](../../../next_core_tasks_v3.md#m9), шаги 1–3 для рабочего frontend (понижение L3 и обходчик) и первое
измерение шага 4. В чистом графе шаг 3 сделан срезом 346.

## Что изменено

1. **Читатель объявления** (`src/l2src/l2_frontend_resolve.lm2`, `lm_compiler_declaration`). Составная ветвь —
   внешняя голова как место, ресивер хвоста как утверждаемое требование, операнд ресивера как кандидат — действует
   только для Frame оператора `:=` и Frame формы ресивера, приведённой к записи по пути (бит узла 8192,
   `lm_compiler_receiver_form_node`). Форма с двоеточием этой ветвью не читается.
2. **Роль содержимого** (там же, `lm_compiler_decl_content_core`). Роль 4 — «хвост потреблён ресивером»: одиночное
   применение ресивера к значению или к имени, известному снаружи, — по ней Frame не считался определением
   Structure в корне (`lm_compiler_unit_role`), в теле метода (`lm_compiler_local_absent_def`) и в теле Structure
   (`lm_compiler_ns_nested_def`). Теперь роль есть только у тех же двух видов Frame. У формы с двоеточием
   содержимое — тело: голова, которая ничего не называет, объявляет именованную Structure с хвостом внутри.
3. **Элемент тела — применение ресивера к значению** (`src/l2src/l2_frontend_core.lm2`,
   `lm_compiler_take_ns_body`). Элемент, голова которого — ресивер значения или типа, объявляющий поле именованной
   Structure (`int`, `char`, `size_t`, `unsigned`, `ulong` — слова `lm_compiler_lit_field_kind` — и `@`), а операнд
   — не имя места (`int: 5`, `@: 0`, `@: Model: 0`), полем не является. Понижение Structure со значением внутри не
   строит и отказывает на месте применения: «a receiver applied to a value declares no place, and a Structure
   declared with it inside is not lowered yet: a place is declared by its receiver with the name first --
   `int: name value`, `@: name value`». Прежде такой элемент доходил до сообщений «a named Structure field needs a
   name» и «a reference field needs a type and a name» на голове внешней формы.
4. **Поле операнда `merge` именем вперёд снято.** Удалена функция `lm_compiler_named_typed_field_kind`
   (`l2_frontend_helpers.lm2`) и четыре её вызова: `lm_compiler_merge_typed_decl` (resolve),
   `lm_compiler_mrs_build` (emit), `lm_compiler_whole_merge_shape` (lower), `lm_compiler_merge_typed_own` (values).
   Имя убрано из списка экспорта `frontend_names` в `tools/build.lm2` (259 имён). Операнд `(a: int: 5)` отказывает
   прежним сообщением «this merge operand form is not lowered yet» на месте операнда.
5. **Проверка принимаемого значения** (`src/l2src/l2_frontend_emit.lm2`, `lm_compiler_check_receiving_value_at`).
   Одиночное применение ресивера примитива к значению (`int: 6`) читается выражением: операнд принимается типом
   ресивера, место принимает этот тип — как начальное значение ссылки под утверждённым требованием
   (`lm_compiler_check_reference_init`). Прежде эта проверка отказывала словами «int has no value», и такое значение
   в записи по имени проходило только составным чтением объявления. Следствия: `i: int: 6` при известном `i`
   отказывает по правилу формы (шаг 4 раздела M7), а запись по индексу и через ссылку принимает такое значение.
6. Комментарии транслятора, называвшие составную форму действующей записью, переписаны (`l2_frontend_core`,
   `l2_frontend_emit`, `l2_frontend_lower`, `l2_frontend_useplan`).

## Перепись и перевод (шаги 1 и 2)

Перепись сделана по тексту, отдельной ветви отчёта в трансляторе нет
([ответы исполнителя](../../../LMX_blog/q/fable-self-answers-20261110.md), Л1). После среза 349 в поддерживаемых
исходниках оставалось 12 составных форм в 11 строках пяти фикстур `tests/dyn`:

| Фикстура | Было | Стало |
|---|---|---|
| `explicit_data_var_field.lm2` | `cell: int: 1` | `int: cell 1` |
| `merge_args_model_formal_refused.lm2` | `(a: int: 5)` | `(int: a 5)` |
| `merge_args_operand.lm2` | `(a: int: 5)` в трёх строках, голое `a: int: 5` | `(int: a 5)`, `int: a 5` |
| `merge_named_field_operand.lm2` | `(a: int: 5)`, голое `a: int: 7`, `(a: int: 4); (c: int: 2)` | `(int: a 5)`, `int: a 7`, `(int: a 4); (int: c 2)` |
| `whole_arguments.lm2` | `(a: int: 5)` в двух строках | `(int: a 5)` |

Остальные четыре строки измерения из плана (`var\cell: int: 7`, `I\cell: int: 19`, `var\caught: int: var\p`,
`First: @: First: 0`) срез 349 перевёл на `:=`. Комментарии этих фикстур, пяти соседних
(`assign_typed_unknown*_refused`, `merge_assign_operand_refused`, `merge_args_computed_default_refused`) и списка
`full-suite.tsv` переписаны; ссылки на пример автора от 2026-11-07 новую запись ему не приписывают.

Поиск по тексту после перевода (`records/probes/text-search.txt`): в начале оператора составная форма с ресивером
значения или типа стоит только в фикстурах чистого графа (`tests/graph/declare_nested.lm2`,
`declare_place_receiver.lm2`) и в новых фикстурах этого среза; внутри строки — только в них же и в комментариях,
которые называют её снятой. Записи вида `b: immutable: merge(Holder)` (14 строк в семи файлах) — объявление через
`merge`, вопрос П4; составное чтение их не касалось.

## Чтение (шаг 3)

| Запись | Голова | Что делает понижение L3 |
|---|---|---|
| `holder: int: time` | неизвестна | Structure `holder` с полем `time`; `holder\time` читается и пишется |
| `timeout: ms: int: time 500` | неизвестна | `timeout` с `ms` внутри и местом `time`: `timeout\ms\time` = 500 |
| то же при `int: time` снаружи | неизвестна | то же: имя снаружи чтения не меняет |
| `i: int: 5`, `cell: int: 1`, `ptr: @: 0` | неизвестна | отказ на месте применения ресивера (предел) |
| `x: 4` | неизвестна | Structure с числом внутри — как до среза |
| `i: int: 6`, `code: int: 8` | известное место | отказ шага 4 раздела M7 |
| `I\cell: int: 19`, `First: @: First: 0` | известное место | отказ шага 4 раздела M7 — как до среза |
| `i := int: 6`, `I\cell := int: 19` | — | запись значения, которое проверяет ресивер |
| `pack: merge(Args; (a: int: 5))` | — | отказ: непониженная форма операнда |

Обходчик своего чтения составной формы не имел: он идёт по тому же объявлению; все строки таблицы проверены в
режимах `n` и `f`.

## Пределы

- Structure с вызовом ресивера внутри (`i: int: 5`, `ptr: @: 0` при неизвестной голове) понижение L3 не строит и
  отказывает. По норме это объявление Structure; чистый граф его исполняет. Тот же предел, что у `Struct1: Struct2`
  (срез 350).
- Отказ операнда `(a: int: 5)` — сообщение о непониженной форме операнда, а не объявление Structure `a` с вызовом
  ресивера внутри: по той же причине.
- Литерал вне диапазона в применении ресивера отказывает при трансляции, а не отказом, который принимает `catch`
  (шаг 4).

## Фикстуры

Новые строки полного набора, режимы `nf`:

| Фикстура | Строка | Что проверяет |
|---|---|---|
| `dyn/composed_declares_structure.lm2` | `runs`, 7 | `holder: int: time`, `timeout: ms: int: time 500`, тело Structure, тело метода; имя `time` известно снаружи |
| `dyn/composed_value_refused.lm2` | `refuses`, `5:4` | `i: int: 5` в корне |
| `dyn/composed_value_method_refused.lm2` | `refuses`, `5:11` | `cell: int: 1` в теле метода |
| `dyn/composed_field_refused.lm2` | `refuses`, `5:8` | `i: int: 5` в теле Structure |
| `dyn/composed_reference_refused.lm2` | `refuses`, `4:6` | `ptr: @: 0` в корне |
| `dyn/composed_known_refused.lm2` | `refuses`, `7:5` | `i: int: 6` при известном `int: i` |
| `dyn/composed_known_root_refused.lm2` | `refuses`, `4:1` | `code: int: 8` в корне |
| `dyn/merge_named_field_refused.lm2` | `refuses`, `10:23` | операнд `(a: int: 5)` |
| `dyn/typed_value_write.lm2` | `runs`, 7 | `int: 6` — значение записи по имени, пути, индексу и через ссылку |

Игла первых четырёх отказов — «a receiver applied to a value declares no place, and a Structure declared with it
inside is not lowered yet», пятого и шестого — «a form with a colon declares and writes no known place: assign
with :=», седьмого — «this merge operand form is not lowered yet».

## Проверки

- **Пробы холодным frontend** (`fe-f08`–`fe-f12`; исходники проб и итог финального `fe-f12` —
  `records/probes/`). Программа вне набора доводится до запуска цепочкой набора — скрипт
  `records/probes/runprobe2.sh`: frontend (нативно и с `--walk-methods`), `l1trans` с рабочим каталогом `src`
  стадии, `gcc -c`, компоновка с `driver.o` и `l2_libc.o`, `p-prod.exe 0 entry 7` и то же с `walkroot 1`. Строка
  `run(expect 7): root0 rc=0 root1 rc=0` означает, что оба исполнителя корня дали 7.
- **Первый кортеж** (`boot-f19`, manifest 39) и **первый полный прогон** (`suite-f14`): `SUITE 158 rows, 6
  failures` — `named_call_below_os`, `named_call_below_unit`, `callable_place_fields`, нативно и под обходчиком.
  Отказ пункта 3 был шире нормы: условие «ресивер потребляет одно значение, а объявления нет» выполняется и для
  зарезервированного `var` с данными, записанными полями (`var: (int: n 3)`, блочная запись — то же дерево).
  Условие сужено до ресиверов, которые объявляют поле значением или типом; кортеж пересобран.
- **Кортеж** (`boot-f20`, manifest 40, 448 входов): `bootstrap quick` — 0 отказов, малый набор — 9 строк, 0
  отказов; G1 = G2 (`EXE-SAME 1` для frontend); `l1trans` тот же, что в `boot-f18`; `driver.o` `0fec21ad…` и
  `driver-observe.o` `f7f580ec…` те же; инструмент `boot-f20` = `boot-f19`, от `boot-f18` отличается (список
  экспорта frontend короче на одно имя); `graph-f17` = `graph-f16`. Сборке предшествовал переходный инструмент
  `tool-f16` (`build-self` новых текстов): список экспорта изменился.
- **Полный набор** (`suite-f15`): `SUITE 158 rows, 0 failures`, 1216 PASS.
- **L1 программ набора** против `suite-f13` (`records/runs/rowl1-f13-f15.out`): 210 из 220 — побайтно те же; две
  новые программы в двух режимах есть только в новом прогоне. Десять различий:
  - `whole_arguments` (2) — имя вынесенного `merge` со смещением в исходном тексте (`l2_lift_11_3958` →
    `l2_lift_11_4061`); после подстановки имени файлы равны.
  - `explicit_data_var_field` (2) — одна строка таблицы имён: слово головы `cell` стало словом `int`.
  - `free_c_abi`, `free_c_pointer`, `free_value_consumers` (6) — таблица указательных типов короче на одну-две
    записи, коды следующих типов сдвинулись; вне этой таблицы различий нет. Причина: вопрос «слово типа?»
    (`lm_compiler_prim_type_word` → `lm_compiler_ptr_type_word`) для слова двери `c.` заводит указательный тип
    побочным действием. Его задавало чтение роли 4 голове единственного Frame в хвосте любой формы; теперь это
    чтение есть только у `:=` и формы ресивера. Наименьшее воспроизведение — проба `q01` (`return: c.f(x)`): у
    прежнего frontend два типа, у нового один; проба `q08` (тот же вызов начальным значением) — без различий
    (`records/probes/q-summary.txt`).
- **Мутант «прежнее чтение возвращено»** (`fe-f13m`, manifest `40m1`: оба условия пунктов 1 и 2 сняты;
  `records/probes/mutant-fe-f13m.txt`, рядом итог `fe-f12` по тем же фикстурам):
  - `composed_declares_structure` не транслируется — «unknown field path segment» на `box\time` (16:5): `box`
    снова место со значением `time`;
  - `composed_value_refused`, `composed_value_method_refused`, `composed_field_refused` транслируются и дают 7:
    форма снова объявляет место;
  - `composed_known_refused` и `composed_known_root_refused` транслируются и записывают место — выход 6 и 8;
  - `composed_reference_refused` отказывает прежним сообщением среза 350 (вид 7, 4:1), а не новым;
  - `merge_named_field_refused` отказывает так же, как рабочий frontend: чтение поля именем вперёд удалено, и
    мутант его не возвращает;
  - `typed_value_write` проходит: проверка значения от чтения формы не зависит.
  После сборки исходник и стадия возвращены и сверены с manifest 40 по sha256 (`records/runs/stage40b.out`).
- **Graph-check** не повторялся: фикстуры `tests/graph`, транслятор графа и runtime те же.
- **Поиск по тексту** — `records/probes/text-search.txt`.
- **Документы:** `docs check` на индексе этого коммита — `records/runs/docs119.out` (метка `docs118` — прогон до последней правки текста плана, тот же итог).

## Измерение шага 4 (одноаргументные формы)

Понижение L3, `fe-f12`, оба пути; номера проб — в `records/probes/probes-fe-f12.txt`.

| Запись | Проба | Итог |
|---|---|---|
| `int: i` без значения, затем `i := 7` | `m9r`, `m9w` | 7 |
| повторное `int: i` при `int: i 5` | `m9s` | значение прежнее |
| `char: i` после `int: i 5` | `m9t`, `p03` | транслируется; при исполнении R0 остановлен неперехваченным отказом |
| `return: int: 7` | `m9n` | 7 |
| `g(int: 7)`, `g(a := int: 4)` | `m9o`, `n03` | значение передано |
| `int: i (int: 7)`, `int: j int: 6`, `int: code int: 7` | `m9p`, `m9z`, `n07` | значение принято |
| `i := int: 7`, `i := (int: 6)`, `(int: 2) + int: 5`, `int: 6 + 1` | `m9q`, `m9m`, `m9x`, `n08` | значение принято |
| `a[1] := int: 6` | `n01` | 7 — со среза 351; прежде «int has no value» |
| `\p := int: 6`, чтение `\p` | `n16` | 7 — со среза 351; прежде «int has no value» |
| `i := int: big`, `size_t: big 4294967296U`, внутри `catch: convert ()` | `p02` | выход 3: отказ `convert` принят `catch` |
| `i := int: 342348523485629384569384` | `p01` | отказ трансляции «literal not representable as int» |
| `int: 5`, `int: 342348523485629384569384` отдельным оператором | `m9v`, `m9u` | отказ трансляции «unsupported body» |
| `i: int: "text"` при известном `i` | `n18` | «assignment value has incompatible type» |

Не относится к срезу, записано, чтобы не искать заново: поле Structure с вычисляемым начальным значением
(`int: a int: 5`, `int: a (int: 5)`; пробы `n04`, `n11`) до исполнения тела Structure читается как 0 — вычисляемое
объявление исполняется, когда до него доходит управление; запись через ссылку на место-число метода
(`@: p int @ i`; пробы `n12`–`n15`) само место не меняет — так закреплено фикстурой `free_index_places`
(`outer_pointer`: `cell` остаётся 5).

## Записи

`records.sha256` — sha256 каждого файла `records/`. `records/pins` — manifest 35–40 и `40m1`; `records/runs` —
выводы сборок, наборов, сравнений и проверки документов; `records/probes` — исходники проб, скрипт запуска и итоги.
