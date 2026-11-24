# Операнды и библиотечные компоненты в сравнениях

Редакция: 22 ноября 2026 года. Эта редакция использует текущие правила языка; новые встроенные операции не вводятся.

## Готовый заголовок сравнительного профиля

В [корневом примере Interpreter](23_interpreter_comparison.md) явно предоставлен следующий обычный DATA-фрагмент профиля сравнения:

```lmx
sys:
    OPERANDS_TEMPLATE:
        @: left
        @[]: right
        const: int: PASS_ARGS_AS_IS 0
        const: int: PRIORITY priority("+")
```
Операнды этого профиля используют `copy: sys\OPERANDS_TEMPLATE`. Эта строка входит в размер реализации операнда. Общее определение предоставлено один раз и явно требуется соответствующими fixtures; оно не повторяется в каждом клиенте. Шаблон не содержит `return`: конкретная операция задаёт собственный тип результата.

По уточнению автора в этой редакции предпочтительна позиционная передача: **`copy: sys\OPERANDS_TEMPLATE` стоит первым в DATA операнда**, до дополнительных входных полей. Поэтому `left` и `right` занимают первые две входные позиции; остальные поля следуют за готовым заголовком. Имена четырёх полей по-прежнему проверяются структурным требованием. Импорт готовых методов в клиенте сохраняет их исходный DATA и не заменяет это копирование заголовка при реализации самого операнда.

Структурное требование `OPERANDS_TEMPLATE` из [нормы](../LMX_semantics.en.md#operand-receiver) и явно предоставленный здесь `sys\OPERANDS_TEMPLATE` выполняют разные роли. Первое проверяет необходимые именованные поля; второе предоставляет конкретные поля с готовыми значениями режима и приоритета. Одна проверка соответствия не добавляет полей, системного объекта или нового API. Этот fixture не доказывает наличие такого объекта в любой среде LMX. Общие библиотечные реализации используют собственный обычный DATA-фрагмент `FxPreparedOperands` и явно задают приоритет каждой операции; [договор публикации](LMX_Fn_Receivers/PUBLICATION_CONTRACT.md#prepared-operand-data) описывает эту независимую реализацию.

## Значения и продолжения

Режим `PASS_ARGS_AS_IS 0` подготавливает значения аргументов. `\left` читает левое значение, `\right[i]` — соответствующее правое. Bare-имя метода даёт ссылку на него. Получение ссылки на продолжение не вызывает его тело; явный `next(...)` выполняется там, где написан в алгоритме.

Поэтому Maybe-bind, pipe, retry и композиция предикатов могут передавать готовые ссылки на методы без `sys\eval`. Если справа написан вызов фабрики продолжения, этот вызов в режиме 0 исполняется при подготовке аргумента. Управление исполнением самого исходного фрагмента требует сырого режима 1 с отдельным корректно построенным описанием.

`right` — массив ссылок на правые аргументы. Его наличие не создаёт автоматический fold: бинарная операция задаёт один правый аргумент, вариадическая явно обходит все элементы. Пустой массив и отсутствие аргумента различаются по обычному контракту. Число правых элементов определяется планом текущего уровня Expression; контейнерное значение не превращается автоматически в список своих полей.

После P0 группировщик Expression получает чистый граф и по его структуре, приоритетам и договорам операций строит план с отдельным левым участком и правым потоком текущего уровня. Это структурный план, а не строка для повторного разбора. Затем отдельный адаптер применения Expression упаковывает весь левый участок в один actual `left`, а правые элементы — в массив ссылок `right`. Для `op` с выбранным последовательностным договором `(a b) op (c d)` и `(a b) op (((c d)))` передают целую левую группу и два правых элемента c, d. В `(a b) op (((c d))) 7` справа два элемента: нормализованная подгруппа `(c d)` и 7. Группировщик рекурсивно обрабатывает каждую Expression-группу: одна единица прозрачна, несколько единиц представляются одной подгруппой. Для целой вычисляемой единицы сохраняются её границы и приоритеты; правила самого `op` не проверяются группировщиком. Прежняя формулировка об anonymous LEFT и единственной anonymous RIGHT описывает эти результаты группировки и ABI, а не отдельное снятие скобок после них. Три соседние правые группы остаются тремя элементами текущего уровня; адаптер не запускает повторную группировку. Готовое значение в принимающей роли VALUE/TYPE/DATA не становится CODE автоматически. В графе CODE/Expression безымянная Structure всегда является группой. Именованная Structure является группой, если её parent отличается от текущего lexical parent; при совпадении выполняется обычный вызов. Решение зависит от имени и parent узла, а не от записи через ссылку или встраивания. Для группового случая исходный parent сохраняется и вызов не вводится. Группировщик получает граф без скобок. P0 сохраняет исходный граф. Обычный выбор W/E у callable остаётся самостоятельным правилом. В `Name :: (A B)` справа одна целая Structure, а в `Name :: A B` — два аргумента; все аргументы `::` потребляются в DATA.

Для списка мест `(a b) := copy(Pair)` копирование непосредственно даёт правый поток. Форма `(a b) := (copy(Pair))` даёт здесь тот же результат и не нужна в кратчайшем клиенте. Это не разрешает убирать контейнер из `ptr := (copy(Model))` или разворачивать аргумент-контейнер `partial`: их принимающие договоры и границы значений сохраняются.

Готовый шаблон задаёт приоритет сложения. В демонстрациях порядок связываний при необходимости показан скобками. Повторное объявление одноимённого const-поля в DATA не считается способом заменить свойство скопированного заголовка. Операнд с другими свойствами должен явно и корректно построить своё описание по общим правилам композиции.

## Когда применяется операнд

Операнд использован там, где он выражает повторяемую композицию: передачу значения через стадии, связывание Maybe, построение составного предиката, настройку объекта цепочкой или политику повторных попыток. Его тело остаётся обычным методом; условие, цикл и вызовы продолжений полностью показаны в реализации.

Для одного прямого вызова, записи поля, commit/ACK или обработчика Message дополнительный операторный заголовок часто только увеличивает код. По каждому из 90 исходных примеров решение записано в [аудите](OPERAND_LIBRARY_REVIEW.md). Название функции не заменяется infix-записью ради одного внешнего сходства.

## Использование готовой библиотеки и её реализация

В связанных парах действует одна граница для всех трёх языков:

1. Прикладной пример получает готовый компонент, показывает import или явно описанную загрузку, свои данные, стадии, предикаты и наблюдение. В его размере нет определения импортируемого компонента.
2. Соседнее сравнение реализации содержит полный код того же компонента на LMX и обоих контрольных языках. Его размер посчитан отдельно.
3. Клиент связан с показанной реализацией, а не с необъявленным новым builtin. API, сигнатуры, отсутствие результата, ошибки и время жизни согласованы между двумя файлами.
4. Если один компонент обслуживает два примера, его реализация приведена один раз и связана с обоими. Общее уменьшение размера клиентских листингов не объявляется уменьшением размера клиентов вместе с библиотекой.

В LMX `import` открывает namespace уже доступного компонента. Он сам по себе не является новым файловым загрузчиком. Конкретные исходники и способ совместной подготовки указаны возле листингов. Нативная или интерпретируемая форма исполнения следует обычному контракту языка.

Стандартные арифметические операции, обычные языковые типы и базовые коллекции остаются возможностями соответствующего языка. Реализация прикладного компонента не требует повторно писать компилятор, allocator, HTTP-стек или СУБД. Эти исходные границы указаны в каждом сценарии.

## Message и существующий HTTP-транспорт

Операторная форма не превращает меж-Message протокол в синхронный вызов. `post`, ответ следующим входом, собственная арена и последовательный turn остаются явными. В Retry/HTTP допускается именно описанный синхронный вызов native-провайдера; ожидание собственного будущего answer внутри текущего turn не вводится.

Endpoint/route, `application/lmx`, admission, синхронный семантический ответ и асинхронные `replyTo`/`correlation` сохраняются по [MESSAGE_HTTP_PROFILE.md](MESSAGE_HTTP_PROFILE.md).

## Проверка

Механическая согласованность источников, Markdown, CSV, XLSX и PDF проверяется отдельно от семантики библиотек. Новые LMX-компоненты проверены по документам; исполнение отсутствующего LMX-ядра не заявляется. Подробности — в [VALIDATION.md](VALIDATION.md).

## English note

This comparison profile explicitly supplies the ordinary DATA fragment `sys\OPERANDS_TEMPLATE`, with prepared-value mode 0 and addition priority and without a forced result type. The structural requirement alone does not create this object or a new system API. The common library independently uses `FxPreparedOperands` and explicit operation priorities. A copied header is counted in each operator implementation. Callable values are references until explicitly invoked. A right-argument Array does not imply an automatic fold.

After P0, the Expression grouper receives a pure graph and uses its structure, operation priorities and contracts to produce a structured plan with a left segment and a right stream at the current level. It does not produce text for reparsing. A separate Expression application adapter packages the entire left segment as one `left` actual and the right items as the `right` Array of references. For an `op` with a selected sequence contract, `(a b) op (c d)` and `(a b) op (((c d)))` supply one whole left group and two right items c and d. `(a b) op (((c d))) 7` instead has two right items: normalized subgroup `(c d)` and 7. The grouper recursively processes each Expression group: one unit is transparent and several units form one subgroup. A complete computable unit retains its boundary and priorities; the grouper does not check the semantics of `op`. The former anonymous-LEFT/sole-anonymous-RIGHT condition describes these grouping and ABI results; it is not a later opening pass. Three adjacent right groups remain three current-level items; the adapter does not repeat grouping. A ready value consumed as VALUE/TYPE/DATA does not automatically become CODE. In a CODE/Expression graph an anonymous Structure is always a group. A named Structure is a group when its parent differs from the current lexical parent; when those parents coincide, ordinary call processing applies. This decision uses the node name and parent, not whether the node was written inline or reached through a reference. The group case preserves the original parent and introduces no call. The grouper receives the graph without parentheses. P0 retains the source graph, and ordinary callable W/E selection remains separate. `Name :: (A B)` has one whole right Structure, while `Name :: A B` has two right arguments; every `::` argument is consumed in DATA.

For a place-list target, `(a b) := copy(Pair)` consumes the copied field stream directly and is equivalent here to `(a b) := (copy(Pair))`. Scalar container assignments such as `ptr := (copy(Model))` and container arguments to `partial` retain their own value boundaries.

Following the author's clarification, positional supply is preferred and the copied standard header is first in an operand's DATA, before additional input fields. Thus `left` and `right` occupy the first two input positions. The named structural header requirement still applies. Importing a ready method preserves its original DATA.

Each paired case separates ready-component use from the complete component implementation, with the same boundary in all three languages. Imports refer to the implementation shown in the companion case, not an invented builtin. Shared components are linked to all clients. Message delivery and the existing HTTP profile retain their original semantics.
