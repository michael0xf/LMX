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
| Lifetime | Вернуть record/native temporary через границу | Нет dangling pointer / обращения к type по адресу native local минус 4 |
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
| Source operands | Anonymous written left, right.length=1, written anonymous right[0] | Только внешний RHS-уровень; left целиком; никаких повторных открытий/P0-unwrapping |
| Message | Одновременные независимые экземпляры | Состояние не делится скрыто между Message/Thread |

Каждую существенную строку выполнить для interpreter→interpreter,
interpreter→native, native→interpreter, native→native. Native создаётся явно;
проверка не должна тайно подставлять старый native entry другого ABI.

## Граница раскрытия RHS

[operand_group_boundaries.json](operand_group_boundaries.json) содержит семь
неисполненных приёмочных случаев для общего обработчика. Проверяются все три
условия одновременно, отсутствие снятия левой группы, один уровень RHS,
отрицательные случаи с несколькими right, именованной ссылкой и результатом
функции. Режимы 0 и 1 сохраняют одинаковые границы; режим 1 не исполняет
дочерние вызовы ради их обнаружения. Обычные callable W/E сюда не перенесены.

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

Левый Name принимается как исходный объявляемый идентификатор общим режимом 1,
не как чтение уже объявленного значения. P0 ничего не открывает. `::` не получает
особую separator-грамматику; одноаргументный контракт именованной сигнатуры
читает поля принятого шаблона отдельно от формирования последовательности RHS.
Для двух правых аргументов эта матрица проверяет форму, но не изобретает новую
семантику сигнатуры. Проверить, что форма не меняется при соседстве с другими
обычными операндами и при построении через `sys\fromLmx`.

## Отрицательные примеры формы

- `T0 to (T1 T2) R` при неструктурном левом type token: один контейнер, а не два
  правых type-токена. Явный `fun\const\to(...; right := types)` принимает вектор.
- `(a b c) := f()` не раскрывает возвращённую Structure.
- `(a b) := (copy(Pair))` использует написанный group и явный field stream.
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
