# Приёмка общего набора ресиверов ядра

**Статус:** подготовлены исходники и статическая проверка. Ни один пункт ниже
не отмечен выполненным настоящим LMX-ядром. Файл [STATIC_REPORT.json](STATIC_REPORT.json)
проверяет комплектность/сборку/скобки/явные cutters и не заменяет эту матрицу.

## Запускаемые подготовленные fixtures

Выполнение программы всегда начинается с обычного L3 Thread R0 без DATA и пользовательских аргументов. После подготовки графа уже работающий R0 либо достигнутый обработчик сообщения обычным вызовом `FxAllExamples\run()` выполняет подготовленные проверки. Выбор имени проверяемого метода не заменяет этот старт.

[run_all.lmx](../examples/run_all.lmx) явно вызывает:

1. [fn_and_assignment.lmx](../examples/fn_and_assignment.lmx): готовые type-code
   токены, uninit без payload, void, групповые перестановки и явный copy-stream.
2. [generic_callable_examples.lmx](../examples/generic_callable_examples.lmx):
   разнородные int/double/string входы, double/Structure/callable/void результаты,
   нулевая арность, префиксы 0/N, независимые ветви curry, uncurry/flip.
3. [structure_examples.lmx](../examples/structure_examples.lmx): выбор, перестановка,
   сохранение общих ссылок, diff/patch, defaults, bindFields с переопределением.
4. [fn_equivalence.lmx](../examples/fn_equivalence.lmx): оба направления именованного
   и построенного из типов требования, разные имена formal, void и нулевая арность.
5. [value_generic_examples.lmx](../examples/value_generic_examples.lmx): строки и
   double в map, строковые Maybe/Bounce, точный double-result lazy, смешанные поля.

Каждый probe возвращает int 1 как индикатор теста. Это не тип результата
проверяемых функций. Собранный файл сам ни одного probe не запускает.

## Обязательная семантическая матрица

| Область | Действие | Требуемое наблюдение |
|---|---|---|
| Взаимозаменяемость сигнатур | named requirement → generated callable и token requirement → named callable | Одинаковый admission по ordered full types/R; имена/defaults не identity |
| Именованная сигнатура/call | Старый corpus `Name :: DATA` вместе с `call` | Все прежние ожидания сохранены; новая auto-execution сигнатуры не вводится |
| Различия сигнатур | Изменить count/order/model/result/hasResult | Несовместимость ловится в обоих направлениях |
| uninit token | Нормализовать uninit:T | Читается tag, не payload; исходная запись не меняется |
| void | Nullary/ненулевая процедура | Не возникает фиктивного входа/return, @0 и пустая Structure отличимы |
| Арность | 0, 1, 2, несколько разных входов; затем арность больше всех демонстрационных | Нет фиксированных таблиц/лимитов; тип каждого входа сохраняется |
| prefix | k=0, k=N, k>N, смешанные типы | Последний случай FxArity до вызова F; первые два отложены |
| callable R | Последний R сам является функцией | Он возвращён как значение, а не исполнен дополнительным шагом |
| Точные имена | Контракт pN, исходные входы с другими именами | Actuals mapping по позиции, own names candidate не повреждены |
| Capture | Изменить исходный primitive после partial | Captured primitive сохраняет значение; ссылочный target сохраняет identity |
| Lifetime | Вернуть record/native temporary через границу | Нет dangling pointer / чтения TypeRef перед адресом native local: у native local нет префикса графовой записи |
| Общая Structure | Передать Structure вместо Array<@> в каждую sequence operation | Прямой length/index обход, без items-оболочки и лишнего copy |
| Dense Array<T> | Передать целиком как значение/попытаться reinterpret как @ vector | Значение сохраняется; неявная reinterpretation запрещена |
| Maybe | some(0), some(@0), some(empty), none | Первые три present, none absent; next не вызывается на none |
| List | Пустые/смешанные списки | Порядок стабилен; callback допускает собственные реальные типы |
| Result | Ошибка с non-int reason | reason сохраняет тип и identity; next не вызывается |
| Bounce | Большая цепь, финальная строка/Structure/callable | Итеративный runner, нет дополнительного вызова готового результата |
| compose | N-арный inner, unary outer, void R | Точная внешняя сигнатура; unary outer — определение composition |
| permute/flip | Смешанные типы и некорректные перестановки | Типы и actuals переставляются вместе; ошибка до F |
| memoize | Два равных ключа, неуспех F, nullary/void F | Первый успех кешируется; неуспех нет; ключ не перепринимается после F |
| fix | Self + произвольное число входов | Self указывает на обычный residual callable; нет раннего запуска |
| lazy/once | Успех, неуспех→повтор, рекурсивное force | Кеш первого успеха; состояние сброшено после failure; FxLazyCycle |
| bracket | acquire failure, action failure, release failure, void action | Release после успешного acquire ровно по finally; прежний finally contract |
| retry/recover | Несколько declared имён и payload разных типов | Сохранены имя/payload; системные implicit failures не превращены в Result |
| FxWrap effects | Target, engine и техническая ошибка record | Generated throws содержит все escaping names; пойманный envelope не теряет target failure |
| trace/contract | События/предикаты с mixed inputs и void R | Не подставляется int-value sentinel; обычный порядок эффектов |
| names/rename | Анонимное поле, повторы, пустое exact имя если допустимо | Различия сохранены; переименование не редактирует литералы исходника |
| Graph | Общие ссылки, циклы, actual parent после factory/import | Один чистый граф и правильные owners, без второго environment |
| Source operands | План групп/потоков и отдельный адаптер применения | left упакован в один actual, right — ссылки текущего уровня; никакого второго раскрытия/P0-unwrapping |
| Message | Одновременные независимые экземпляры | Состояние не делится скрыто между Message/Thread |

Каждую существенную строку выполнить для interpreter→interpreter,
interpreter→native, native→interpreter, native→native. Native создаётся явно;
проверка не должна тайно подставлять старый native entry другого ABI.

## Группировщик и адаптер применения

[operand_group_boundaries.json](operand_group_boundaries.json) задаёт
неисполненные приёмочные случаи двух участков [общего механизма](../../../LMX_semantics.en.md#expression-structural-grouping). Группировщик
обрабатывает переданный чистый граф, приоритеты, группы и явные потоки. Адаптер применения
упаковывает левую часть в один actual, а правый поток текущего уровня — в Array
ссылок. Прежние векторы проверяются как следствия этого плана и ABI, без
дополнительного opening pass. В частности, три правые Structures не превращаются
в девять полей; bare `copy(d)` даёт явный поток без лишней группы.
Режимы 0 и 1 используют один план текущего уровня; режим 1 сохраняет исходное
вхождение целого вложенного Expression и не исполняет дочерние вызовы ради
планирования. Его внутренние физические токены не становятся отдельными actuals.
DATA/TYPE-модели и готовые результаты сохраняют свои договоры.
Проверить также `1 + ((2)) = 3` с группой слева и справа. Обычные callable W/E
сюда не перенесены; `RxLogicalArguments` не раскрывает элементы готового вектора.
В CODE/Expression проверить три ветви: именованная Structure с текущим
лексическим `parent` следует обычному вызову; именованная с другим `parent` и
любая анонимная — группировке с сохранением настоящего `parent`.
Сравнить `1 + S + 2` при `S: a b c d` с другим `parent` с прямой группой:
одинаковая группировка не утверждает числовой допустимости `+`.
VALUE/TYPE/DATA не переводятся в CODE автоматически; отсутствие исходных
скобок или другое происхождение графа не создаёт отдельного семантического режима.

## Формы обычного операнда `::`

[signature_operand_shapes.json](signature_operand_shapes.json) задаёт входы и
ожидаемую форму правых аргументов для реального общего парсера и обработчика
операндов. Это **не выполненные parser tests** и не новое правило декларации.

| Исходник | right.length | Содержимое правой последовательности |
|---|---:|---|
| `Name :: A B` | 2 | Два идентификатора A, B |
| `Name :: (A B)` | 1 | Одна написанная Structure, в ней A и B |
| `Name :: ((A B))` | 1 | Одна написанная внешняя Structure с ещё одной Structure |
| `Built :: data` | 1 | Одна ссылка на DATA-описание |

Левый Name принимается как исходный объявляемый идентификатор в роли DATA,
не как чтение уже объявленного значения. Режим builtin `::` здесь не задан:
его реализация и метаданные отсутствуют. P0 ничего не открывает. `::` не получает
особую separator-грамматику. По [общему договору списка](../../../LMX_semantics.en.md#receiver-structure-sequences)
namespace читает упорядоченные непосредственные поля принятой Structure или
DATA по ссылке, когда получателю нужен список деклараций или полей. `::`
использует этот механизм для DATA-деклараций сигнатуры отдельно от формирования
внешней последовательности RHS. Это не специальное раскрытие `::` и не перенос
CODE W/E на DATA; вложенные контейнеры рекурсивно не раскрываются.
Для двух правых аргументов эта матрица проверяет форму, но не изобретает новую
семантику сигнатуры. Проверить, что форма не меняется при соседстве с другими
обычными операндами и при построении через `sys\fromLmx`.

Все аргументы `::` принимаются исключительно как DATA по
[контракту `::`](../../../LMX_semantics.en.md#signature-description-consumption).
При чтении DATA-шаблона его инициализаторы и тело не запускаются, служебные поля готового описания не
становятся формалами. По [общему правилу](../../../LMX_semantics.en.md#receiver-context-invariance)
ресиверы сохраняют свой смысл, а Expression находится в CODE. Проверить, что
`::` остаётся объявлением сигнатуры, `const`/`private` — модификаторами с DATA-аргументами, а вызов
производителя внутри Expression не превращается в объявление Structure из-за
внешнего DATA. Приоритеты, группировка и подготовка результата принадлежат общему
Expression; `::` не выбирает CODE-ветвь и не выполняет `sys\eval` над RHS.
Подготовленный результат принимается как DATA. Одна Structure остаётся одним
внешним actual; общий namespace предоставляет её непосредственные поля (или
поля DATA по ссылке) как список по договору получателя. Роль DATA или CODE
определяет обработку этих элементов, не вводит безусловное раскрытие контейнеров.
Проверить сохранение целого объекта у whole-value/TYPE-профилей, вложенной модели
и структуры `return`, а также внешнего вектора `RxLogicalArguments`.
Готовый signature profile не разбирается по служебным полям. Безымянная Structure
не вызывается; её возможное исполнение на месте в CODE/Expression надо отличать
от вызова и от чтения DATA-шаблона.
Прямые producer-примеры в [общей матрице](../../../validation/signature_expression_cases_20261124.json)
являются нормативными целями, как и явное получение значения в обычном объявлении
с последующим `f :: description`. Исполнение всех случаев реальным ядром —
**NOT_RUN**; реализации builtin `::` в пакете нет.

## Отрицательные примеры формы

- `T0 -> (T1 T2) R` при неструктурном левом type token: один контейнер, а не два
  правых type-токена. Для готового вектора входов используют внутренний именованный
  вызов `` FxToTypes\`->`(inputs := types; result := R) ``; обычная публичная
  форма `` `->`(T0; T1; ...; R) `` получает TYPE-токены с результатом последним.
- `(a b c) .: f()` не раскрывает возвращённую Structure.
- `(a b) .: copy(Pair)` получает явный field stream; для группового получателя эффект совпадает с `(a b) .: (copy(Pair))`.
- `scalar := (copy(Pair))` сохраняет одну Structure, если этого требует scalar.
- `curry`/`partial` сохраняют обычное selection: required без actual и собственного applicable default отклоняется; defaults не исполняются ради анализа.
- `uncurry` не запускает ступени для анализа их следующей сигнатуры.
- `names(S)` не реализуется через sys\name(pointerIdentifier).
- `rename` не реализуется заменой строк результата toLmx.
- `satisfies` не превращается в запуск candidate для проверки совместимости.

## Текущая попытка исправления callable adapters

Новые тела описаны в [ADAPTER_IMPLEMENTATION.md](../ADAPTER_IMPLEMENTATION.md). [adapter_semantics.lmx](adapter_semantics.lmx) содержит конкретные исходные пробы, запускаемые через `FxAdapterExamples\run()` после подключения настоящих call-phase bridges. [ADAPTER_ACCEPTANCE.md](ADAPTER_ACCEPTANCE.md) отделяет написанные пробы от ещё требующих инстанцирования сценариев; [adapter_acceptance.json](adapter_acceptance.json) содержит все A01–A20/B01–B11 из текущего §37. Все четыре execution режима каждого случая имеют статус NOT_RUN.

Механическая проверка отсутствия старой eager capture/Ti→@ таблицы не доказывает runtime-сохранение default, parent, lifetime и native ABI. Эти проверки остаются обязательными; старые исходники под reference не участвуют в текущей сборке.

## Canonical generic operations and both forms

[generic_operations_acceptance.json](generic_operations_acceptance.json) records
constructor capture, generic equality, Pattern source profiles and exact-role
checks for every canonical export and variant. All execution modes are NOT_RUN.
[generic_operations.lmx](generic_operations.lmx) contains prepared representative
source fixtures. Family/role publication follows [PUBLICATION_CONTRACT.md](../PUBLICATION_CONTRACT.md).
