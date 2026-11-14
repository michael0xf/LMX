# M8: receiving-context написанной Structure, срез 374

2026-11-14, Codex. База — принятый 373,
`feadb715baf15124afca53d371e899cd0e79095f`. Работа и новые коммиты идут только
из `C:/Nyasha_Planet/LMX`, main. Единственный writer/build — Sol; весь goal v3 ACTIVE.

Статус этой записи: source03/651 подготовлен, runtime02 и graph01 построены,
четыре окончательные pure-interpreter пробы прошли с ответами 0/0/5/4.
Private27 в трёх режимах, AFTER30 и mutation24 прошли. Полный bootstrap quick G1/G2,
fixedpoint13 и повтор тех же проверок штатным G2 прошли. Штатные генерация/docs check прошли.
Эти результаты не объявляют завершения M11.5г или переноса рабочего frontend M11.8.

## Норма и исходное расхождение

- [M8, книга :97](../../../provenance/semantics-book.md) и
  [грамматика §18](../../../docs/LMX_grammar.ru.md#empty-colon): P0 сохраняет
  единственную анонимную Structure. Значение группы выбирает контракт получателя,
  а не известность головы её первого поля. Пустая группа — присутствующее значение.
- [Р17](../../../LMX_blog/q/fable-self-answers-20261110.md), пункты 1–3, и
  [книга :955](../../../provenance/semantics-book.md): написанная Structure на месте
  значения остаётся данными; standalone-группа ничего не вызывает. Кодом её поля
  становятся при явном выборе тела соответствующим consumer.
- [Контракт `@`, книга :538 и :593](../../../provenance/semantics-book.md):
  `@: held value` связывает ссылку на полученное Structure-value. Правило о чтении
  внешнего списка аргументов как кода не запускает поля вложенной группы.
- [Р12](../../../LMX_blog/q/fable-self-answers-20261110.md) и
  [книга :1093](../../../provenance/semantics-book.md): вычисляемое объявление обычных
  данных сохраняет initializer до исполнения соответствующего кода. Ссылка на
  `(int: p touch())`, `length` или `typeof` всей этой Structure не вызывает touch.
  Выбор самого невычисленного поля p — другое действие: retained Frame не является
  опубликованным значением поля и его чтение отказывает.
- [Присваивание](../../../docs/LMX_semantics.ru.md#assign-known) сохраняет контракт
  существующего места: kind6 принимает Structure-value; числовой и primitive-reference
  контексты сохраняют свои читатели. Индексная запись не отменяет допуск и границы слота.
- [Тип адреса](../../../docs/LMX_semantics.ru.md#get-type): `typeof((missing))`
  видит заголовок написанной Structure, не разрешая missing. Код 13 относится к
  текущему профилю; числовой код типа нормой языка не закреплён.

На принятом 373 `@: Code (int: p touch())` сохранял группу в BEFORE, но consumer
отвечал 2 вместо Structure длины 1 при calls0. Это измеренный остаток потребителя
M8, а не ошибка P0. Старое пояснение О6 о literal-операнде merge не вводит отдельного
запуска ordinary-data initializer при связывании ссылки через `@2`.

## Изменение и границы

Общий `lmx_graph_read_received_value` читает actual по выбранному контракту:
обычное/reference выражение, число либо Structure-value. Он используется у `@2`,
ссылочного присваивания, Structure-аргументов length/typeof, базы пути/индекса,
RHS индексной записи и уже существующих actual/launch readers. Сохранённая группа
не раскрывается в код только из-за одного поля или языковой головы внутри неё.
Прямой `merge(...)` остаётся producer с обычным вычислением операндов; дополнительная
внешняя группа `(merge(...))` сохраняла бы написанное поле.

Для назначения, чей тип до own-data ещё неизвестен, scanner сохраняет возможные
entry-снимки RHS как optional в прежней карте. Фактический kind1 читает entry-снимок;
kind6 сохраняет группу и не продвигает её имена во входы текущей активации.
Optional-строки не видны детям до реального потребления владельцем. Новый поиск
внешнего источника после initializer не заменяет entry-снимок.

Выбранное через путь невычисленное поле сохраняет отказ 5. Destination preflight
предшествует RHS и не позволяет присваивать имени созданного метода. Новых таблиц,
runner или второго парсера нет. Native обычной Structure M14, настоящий `@: p int`
без кандидата, оставшийся root/self и M11.8 этим срезом не объявляются завершёнными.

## Четыре окончательные фикстуры

| Источник | Независимое ожидание |
| --- | --- |
| [received_structure_values.lm2](../../../selfbuild/tests/graph/received_structure_values.lm2) | Ответ 0. root_n/direct_n/missing_n/own_n/replaced_n/path_n/given_n/indexed_n = 1; group_type = 13; method_counts = 1301 из длин 1/3/0/1; method_fields = 4; literal_calls = 0. Direct merge: merged_n = 2, merged_p = 7, merge_calls = 1. `@3 int` с вычисляемым индексом и копией typed reference: address_value/reference_value = 41, final_calls = 2. |
| [received_assignment_snapshots.lm2](../../../selfbuild/tests/graph/received_assignment_snapshots.lm2) | Ответ 0. prepared = 0, numeric = 5, structural = 8, held_n = 1, outside = 8, changes = 2. |
| [received_field_read_refused.lm2](../../../selfbuild/tests/graph/received_field_read_refused.lm2) | Ответ 5 при чтении Holder.p, calls = 0, before = 1; последующая запись before = 2 не исполняется. |
| [received_assignment_preflight_refused.lm2](../../../selfbuild/tests/graph/received_assignment_preflight_refused.lm2) | Ответ 4 на присваивании созданному p; before = 1, внешний p = 7, RHS missing не потребляется. |

У snapshot-фикстуры State — обычный `fn` с own data и `return: 0`. Первый вызов
подготавливает вложенные методы существующим конструктором. Number и Literal затем
ссылаются на `State\data\number/literal`; State уже не активен. Вход number получает k5
до change→8 и записывает 5. Literal сохраняет `(k)` как Structure: optional k5 не
становится входом; leaf читает актуальное лексическое k8. Каждая из двух активаций
вызывает change один раз, итог calls2. Это не обещание повторной инициализации State.

Вариант с nested fn внутри [ordinary State](ordinary-nested-methods-gap.lm2) даёт
[3 и на штатном G2](ordinary-nested-methods-gap.log): текущий ordinary-маршрут
не подготавливал необходимые construction bindings. Written fn в дампе сами по себе
не доказывают отсутствия F — исходные объявления по контракту сохраняются. Окончательный
fn State использует уже действующий own-data проход и устраняет зависимость этой пробы
от незавершённой подготовки ordinary nested methods. Ранние отказы не приняты как
результат snapshot-контракта; working variant — pure03.

Все четыре `.lm2` и их `.expected` включены в обычный `selfbuild/inputs.list`.
Ожидания относятся к полному AFTER; положительный graph-check сравнивает его штатно,
отрицательные состояния требуют прежнего graph-same отдельно от проверки ответа.

## Кодовая приёмка

P = `C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01`;
S = `P/sol-p0-stage01`;
R = `P/runs/sol-m8-received-values-20261114-01`.

- `R/source03.sha256`: 651 canonical-вход; SHA-256 файла манифеста
  `97ebb18926f9bc1e66c5a250d3ce963b3c0cbf90676b731b178a8cb2ce656df5`.
  `manifest03.log`: MANIFEST 651, 0 failed; `verify03.log`: VERIFIED 651, 0 failed;
  стадия — `stage03.log`.
- Runtime `S/runtime-m8-received-values-02`, `R/runtime02.log`: штатная сборка успешна.
  Graph `S/graph-m8-received-values-01/graph_trans-prod.exe`, `R/graph01.log`: сборка успешна.
  Runtime01 остановился на L2 parse13/tail-cutter у final return value_contract;
  явное завершение вложенного if исправлено до Source02. Неуспешная попытка не принята как gate.
- Pure: `pure01-received_structure_values.log`,
  `pure03-received_assignment_snapshots.log`, `pure01-received_field_read_refused.log`,
  `pure02-received_assignment_preflight_refused.log`: окончательные ответы 0/0/5/4;
  состояния соответствуют указанным выше значениям.
- Private27: все 27 случаев прошли interp/native/forced, [манифест](private01.tsv),
  [результат](private01.log). Все 30 полных AFTER-сравнений 10 отрицательных случаев
  прошли, [манифест](private-after01.tsv), [результат](private-after01.log).
  Все 24 [mutation checks](mutation01.log) прошли.
- [Полный bootstrap01 quick](bootstrap01.log) из принятого373 прошёл: настоящие G1/G2,
  по9 smoke-строк; [fixedpoint13](fixedpoint01.log) и verify651 прошли.
  Сравнения включают оба runtime objects и тождество частного driver02.
- Настоящий G2 штатно [построил graph-tool](g2-build01.log) и повторил все27 случаев
  interp/native/forced: [манифест](g2-01.tsv), [результат](g2-01.log).
  [Все30 AFTER](g2-after01.log) и [24 mutation](g2-mutation01.log) прошли.
- Рабочая связка: S/boot-m8-received-values-01/g2 и graph-m8-received-values-g2-01.
  Driver.o d0c3701ea05672f5076503e5508b565d9e6298a73489960cfa71264c87bee714;
  driver-observe.o 1e69adfaa5d0e168e558d602d2e505b4b7035b6819b94a93029e59e085fcdb5d;
  G2 graph bd65ffac63b081a1b00d81f92a14ad6696b13f607a32d75417e4191b470d75ee.
- Штатный [render semantics](render01.log) прошёл:35 пар семантики/14 implements cases,
  обе исходные выдержки. Штатный [docs check](docs-check01.log) прошёл:
  35/14/27/44/615, ссылки, точное начало семантики и LF всего индекса27358.
  Квитанция проверки добавлена после проверки с нормализованным LF.
  Оба git diff --check чисты. Чужие два untracked сохранили SHA-256:
  627ceecbc7bca3fb54ff8b6fa866f4ee48b5578d671cdc2cb9372db20993b125 и
  b6db206a6f05cc58d086aa3c6575c6b27a0e252785c09f6be5c0e87e51e7d910.

## Следующий M11: physical reference records, ещё не исправлено

[Минимальная проба](physical-reference-code-gap.lm2) нынешним graph01 даёт
[seen2](physical-reference-code-gap.log), ожидается1: после первого call(Self)
его p стал physical kind6, второй call(data;Self) пропускает написанное ссылочное
объявление вместо публикации A в data.p. Это следующий уже предусмотренный пункт M11.

Невызванный Types создаёт implicit wrappers8/9 существующим конструктором метода.
Его data как код должен проверять типы принимающих p/s без чтения payload и store:

| Проба | Измерено graph01 | Требуется |
| --- | --- | --- |
| [Заполненные p/s](wrapper-code-type-only.lm2) | [0; before1/after1, p3/s7](wrapper-code-type-only.log) | Сохранить этот результат |
| [Число вместо int-reference](wrapper-code-type-refused.lm2) | [0; before1/after1](wrapper-code-type-refused.log) | 4; before1/after0 |
| [Число вместо Structure-reference](wrapper-code-structure-refused.lm2) | [0; before1/after1](wrapper-code-structure-refused.log) | 4; before1/after0, raw Bad.p не вычислять |

Эти пробы не включены в положительную приёмку374; исправление не объявлено выполненным.
No-candidate construction @:p int здесь не используется и остаётся отдельной OPEN задачей.
