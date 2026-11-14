# M11: physical reference records как код, срез 375

2026-11-14, Codex. База — принятый 374 в main,
`ff07457cd6a9ba8f77e71d5349a8be59a787115f`. Единственный writer/build — Sol;
работа идёт из `C:/Nyasha_Planet/LMX`, весь goal v3 ACTIVE.

Статус записи: код source01/651 заморожен; runtime01 и graph01 построены,
окончательные четыре pure-interpreter пробы прошли с ответами 0/0/4/4.
Положительные результаты — pure01, окончательные отрицательные — pure02.
Повтор baseline на окончательных исходниках подтверждён; private31 в трёх режимах,
AFTER36/mutation24 прошли. Полный bootstrap G1/G2/fixedpoint13 и повтор штатного G2 прошли.
Штатный render/docs check прошёл.
Эта запись не объявляет закрытие всего M11.5г, M13 или M14.

## Норма

- [Книга, роли `data` и `code`](../../../provenance/semantics-book.md#data-code-roles),
  и контракт `@` в строках 517/538: в данных ресивер объявляет место;
  при достижении той же записи как кода проверяет принимающее место и присваивает
  значение. Публикация physical reference не отменяет контракт записи.
- [Р15](../../../LMX_blog/q/fable-self-answers-20261110.md): проверка и присваивание
  выполняются при каждом достижении строки. Источник — текущее содержимое её
  source slot; при запуске над собой source и место могут совпадать, а публикация
  предыдущего запуска меняет значение следующего чтения.
- [M11, physical reference records](../../../next_core_tasks_v3.md): named kind5/6
  проверяют тип назначения, затем принимают текущую literal reference из source
  field через прежний store. Kind8/9 проверяют соответственно primitive family5/6
  без чтения непредъявленного payload и без записи в принимающее место.
- [Представление места без значения](../../../docs/kernel-implementation.ru.md#lmx):
  wrapper не является initialized-флагом. Слот, служебный указатель и заранее
  существующая typed cell сохраняются; type-only проверка не читает старый payload.
  Настоящее `@: p int` без кандидата всё ещё требует отдельного общего construction
  решения с wrapper8/cell5 и не считается реализованным этим срезом.

## Изменение и наблюдения

Изменены только два файла ядра: `lmx_graph_run.lm2` и `l2_graph_tool.lm2`,
45 добавленных / 4 удалённых строки. Вместо общего пропуска physical5/6/8/9
именованная запись использует существующие `known_place` и `store_reference`.
Тип назначения проверяется до чтения source; для wrapper8/9 store отсутствует.
Парсер, API и инфраструктура тестов этим изменением не расширены.

| Окончательная фикстура | Независимые ожидания и измеренный pure результат |
| --- | --- |
| [physical_reference_records.lm2](../../../selfbuild/tests/graph/physical_reference_records.lm2) | Ответ0. После подготовки Self и `call(data; Self)` first_i40/first_s1: source содержит int-reference на i40 и Structure-reference на A(v1). Затем `Self\ip := @j`, `Self\p := B` меняют source; следующий запуск даёт second_i41/second_s2. Обе семьи5/6 читают текущий source payload. |
| [physical_reference_type_only.lm2](../../../selfbuild/tests/graph/physical_reference_type_only.lm2) | Ответ0, before1/after1, p_after3/s_after7. Types не вызывается; его implicit wrappers8/9 как код проверяют уже заполненные места main.data и сохраняют их значения. |
| [physical_reference_int_refused.lm2](../../../selfbuild/tests/graph/physical_reference_int_refused.lm2) | Ответ4, before1/after0. Первый wrapper8 требует int-reference; Bad.p остаётся int99, raw `@: s Missing` остаётся написанной записью и не вычисляется. |
| [physical_reference_structure_refused.lm2](../../../selfbuild/tests/graph/physical_reference_structure_refused.lm2) | Ответ4, before1/after0/calls0. Raw `@: p int data[touch()]` проходит только проверку семейства5 без вычисления кандидата. Следующий wrapper9 отвергает int Bad.s99; оба поля Bad остаются неизменными. |

В отрицательных фикстурах Bad связан с написанной анонимной root-group. После
отказа полный AFTER показывает оба настоящих поля Bad: это независимая проверка
сохранённого raw initializer, а не вывод только из before/after. Старые прототипы,
державшие Bad внутри копируемой own data, не принимать как полную физическую
наблюдаемость окончательных отрицательных случаев.

Квитанции находятся в
`build2/codex_fix250generationchain01/runs/sol-m11-physical-reference-code-20261114-01`:
`manifest01.log` подтверждает651/0; `runtime01.log` и `graph01.log` — сборки;
`pure01-physical_reference_records.log`, `pure01-physical_reference_type_only.log`,
`pure02-physical_reference_int_refused.log` и
`pure02-physical_reference_structure_refused.log` — перечисленные результаты.

## Честная граница native-покрытия

Обычные Self и Types.data сейчас исполняются обходчиком, в том числе из native main;
общая компиляция ordinary Structure относится к открытому M14. Поэтому
private31 triple подтвердил согласованную семантику программы в трёх режимах,
но сам по себе не доказывает фактическое исполнение новой native physical-ветки.

По read-only review emitter после preflight генерирует runtime `graph_get` по
координате source body текущего вызова, затем читает reference value и вызывает
прежний store. Увиденный при трансляции target не встраивается. Это проверка
реализации по исходнику emitter; её не выдавать за проверенное выполнение ветки.
Штатный builder пока материализует int, а raw `@:` сохраняет Frame; fn/sub constructor
создаёт wrappers в отдельной data, сохраняя исходный body. Получение physical code
через Self/Types.data происходит после emit. Кроме того, изменение настоящего
исполняемого code сбрасывает несовместимый native entry: последующий fallback
не доказывает повторный native-вызов с обновлённым source literal.

Без специального runner или искусственного метода эта граница остаётся открытой
до соответствующего общего механизма. Ни прямое native-покрытие physical branch,
ни no-candidate storage, ни весь root/self этим срезом не объявлены завершёнными.

## Квитанции частной приёмки

Окончательный [Source02](source02.sha256) содержит659 canonical-входов; verify659 прошёл.
SHA-256 манифеста b0717914f56dbc0e4dab4d5f027ba62a68fe980d7519da254484a91e8e80830d.
От Source01 код ядра не менялся: добавлены только четыре пары зарегистрированных фикстур.
Driver01 ce8bbb7ff30de26f6a64b28e1e4f5bd5c28371cdc4e54589d8eda2d4893c2f94;
driver-observe01 9a0094f0a6e53026cf48c240acdd00bff8667f779bb1bd3442b9841a9bb80cc9.

Baseline374 на окончательном source: [5/6 records](baseline-final-physical_reference_records.log)
даёт41/2 вместо первых40/1; [type-only control](baseline-final-physical_reference_type_only.log)
сохраняет3/7. Оба неверных типа [int-reference](baseline-final-physical_reference_int_refused.log)
и [Structure-reference](baseline-final-physical_reference_structure_refused.log) ошибочно дают0/after1,
тогда как требуется4/after0. В новых pure случаях эти расхождения исправлены.

Все31 случая прошли в трёх режимах: [манифест](private01.tsv), [результат](private01.log).
Все36 полных AFTER-сравнений12 отрицательных случаев прошли:
[манифест](private-after01.tsv), [результат](private-after01.log).
Все24 [mutation checks](mutation01.log) прошли. [Whole bootstrap01 quick](bootstrap01.log) из принятого374
прошёл: настоящие G1/G2, по9 smoke; [fixedpoint13](fixedpoint01.log) и verify659 прошли.
Сравнения включают оба runtime objects и тождество частного driver01.
Настоящий G2 [построил graph-tool](g2-build01.log) и повторил31 в трёх режимах:
[манифест](g2-01.tsv), [результат](g2-01.log). Все36 [AFTER](g2-after01.log)
и24 [mutation checks](g2-mutation01.log) прошли.
Рабочая связка S/boot-m11-physical-reference-code-01/g2 и graph-m11-physical-reference-code-g2-01.
G2 graph SHA-256 0b03aa5043b7801f78883887e441a319f1cde5aa19010e839803e1723c006e07.
Штатный [render semantics](render01.log) прошёл:35 пар разделов,14 implements cases и обе исходные выдержки.
Штатный [docs check](docs-check01.log) прошёл:35/14/27/44/615, ссылки,
точное начало семантики и LF всего индекса27389. Квитанция добавлена после проверки с LF.
Оба git diff --check чисты. Два чужих untracked сохранили прежние SHA-256:
627ceecbc7bca3fb54ff8b6fa866f4ee48b5578d671cdc2cb9372db20993b125 и
b6db206a6f05cc58d086aa3c6575c6b27a0e252785c09f6be5c0e87e51e7d910.
