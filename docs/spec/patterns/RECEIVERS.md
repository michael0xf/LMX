# Общие ресиверы и контейнеры LMX

Редакция: **23 ноября 2026 года**. Все перечисленные операции и контейнеры входят в единое текущее ядро и доступны по прямым именам. Клиентский import не требуется. `fun\const` — внутренний источник постоянных экспортов; исходный владелец метода и его DATA сохраняются. Разных подключаемых версий библиотек нет.

В каталоге нет ограничения пользовательских значений типом int или произвольной фиксированной арностью. Используются полные типовые требования и ссылки на записи `{type value}`. Любая структура уже является массивом @ и служит последовательностью без обязательной обёртки items. Служебные int для type-кодов, индексов, длин и логических флагов сохраняются по смыслу языка.

## Документы и реализация

- [Интеграция общих ресиверов в ядро](../kernel-implementation.en.md#receiver-kernel-integration).
- [Нормативное описание всех ресиверов](../LMX_semantics.en.md#functional-receivers).
- [Взаимозаменяемость форм сигнатуры с сохранённой связью именованной сигнатуры и call](../LMX_semantics.en.md#fn-forms-equivalent).
- [API с аргументами](LMX_Fn_Receivers/API.md) и [единая сборка исходников](LMX_Fn_Receivers/LMX_Receivers.lmx).
- [Минимальные входы ядра](LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md) и [проверки](LMX_Fn_Receivers/tests/ACCEPTANCE.md).
- [Реализация callable-адаптеров](LMX_Fn_Receivers/ADAPTER_IMPLEMENTATION.md), [общие последовательности](LMX_Fn_Receivers/SEQUENCES_IMPLEMENTATION.md) и [текстовые Patterns](LMX_Fn_Receivers/REGEX_IMPLEMENTATION.md).

## Полный каталог

Базовые таблицы ниже сохраняют 115 вызовных имён более раннего пакета: 61 общую операцию, 14 операций последовательностей и 40 текстовых ресиверов/операндов. В загруженной редакции 23-Nov уже были восемь последующих дополнений, всего 123 имени. Текущий набор сохраняет их и добавляет 89 функций — всего **212**. Все имена являются прямыми функциями ядра и полностью перечислены в [едином актуальном реестре](../CORE_FUNCTIONS.md) и [машинном каталоге](LMX_Fn_Receivers/catalog.json). Отдельные **24 прочих символа** — готовые Patterns, настройки, структурные требования и именованные исходы — приведены в [реестре значений и требований](LMX_Fn_Receivers/value_symbols.json); они не прибавляются к числу вызовных имён.

### Общие ресиверы и контейнеры: 61 операция

| Ресивер | Действие | Исходник |
| --- | --- | --- |
| `types` | Физические коды типов полей; результат int соответствует обычному контракту type. | [reflection.lmx](LMX_Fn_Receivers/src/reflection.lmx) |
| `names` | Канонические имена физических полей; отсутствие имени отличается от пустого exact identifier. | [reflection_bridges.lmx](LMX_Fn_Receivers/src/reflection_bridges.lmx) |
| `signature` | Описание сигнатуры, полученное из семантических входов и результата callable. | [reflection_bridges.lmx](LMX_Fn_Receivers/src/reflection_bridges.lmx) |
| `signatureTypes` | То же описание сигнатуры из полного набора типовых требований; тип результата слева, типы входов справа. | [fn_operand.lmx](LMX_Fn_Receivers/src/fn_operand.lmx) |
| `curry` | Цепочка одноаргументных функций для произвольного конечного числа входов; последняя возвращает исходный R. | [generic_functions.lmx](LMX_Fn_Receivers/src/generic_functions.lmx) |
| `apply` | Обычный вызов по плотному массиву или вектору записей аргументов; результат переносится ссылкой на его типизированную запись. | [generic_runtime.lmx](LMX_Fn_Receivers/src/generic_runtime.lmx) |
| `partial` | Захват начального префикса 0..N аргументов; остаточная функция сохраняет точные типы. | [generic_functions.lmx](LMX_Fn_Receivers/src/generic_functions.lmx) |
| `uncurry` | Обратный адаптер цепочки с явной полной сигнатурой и объявленными исходами всех ступеней. | [generic_functions.lmx](LMX_Fn_Receivers/src/generic_functions.lmx) |
| `flip` | Перестановка первых двух позиций вместе с их типами; остальные позиции сохраняются. | [generic_functions.lmx](LMX_Fn_Receivers/src/generic_functions.lmx) |
| `compose` | Композиция outer(inner(...)) с согласованием результата inner и входа outer. | [generic_combinators.lmx](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `pipe` | Та же последовательная композиция в порядке first, then second. | [generic_combinators.lmx](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `identity` | Тождественная функция для переданного полного типового требования. | [generic_combinators.lmx](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `map` | Последовательное применение функции к элементам плотного или ссылочного массива; новая структура записей результатов. | [collections.lmx](LMX_Fn_Receivers/src/collections.lmx) |
| `filter` | Отбор по предикату с сохранением порядка, профиля массива и целей выбранных ссылок. | [collections.lmx](LMX_Fn_Receivers/src/collections.lmx) |
| `foldl` | Левая свёртка с явным начальным состоянием; тип аккумулятора не обязан совпадать с типом элемента. | [collections.lmx](LMX_Fn_Receivers/src/collections.lmx) |
| `zip` | Пары записей до длины более короткой последовательности. | [collections.lmx](LMX_Fn_Receivers/src/collections.lmx) |
| `zipWith` | Попарный вызов операции с двумя аргументами произвольных типов. | [collections.lmx](LMX_Fn_Receivers/src/collections.lmx) |
| `scanl` | Префиксы левой свёртки, включая seed; n элементов дают n+1 состояний. | [collections.lmx](LMX_Fn_Receivers/src/collections.lmx) |
| `bind` | Связывание Maybe: отсутствие пропускает продолжение; наличие передаёт записанное значение. | [containers.lmx](LMX_Fn_Receivers/src/containers.lmx) |
| `traverse` | Обход в Maybe с остановкой на первом отсутствии и сохранением порядка. | [collections.lmx](LMX_Fn_Receivers/src/collections.lmx) |
| `memoize` | Кеш результатов с явным сравнением ключей и заданным договором стабильности ключа. | [generic_combinators.lmx](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `fix` | Рекурсивное связывание через явно предоставленную функцию self. | [generic_combinators.lmx](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `select` | Выбор полей или элементов по индексам в заданном порядке; плотный или ссылочный профиль сохраняется. | [structures.lmx](LMX_Fn_Receivers/src/structures.lmx) |
| `omit` | Исключение полей или элементов по индексам с сохранением профиля исходного массива. | [structures.lmx](LMX_Fn_Receivers/src/structures.lmx) |
| `rename` | Переименование выбранных полей в одной общей копии через существующую таблицу имён. | [reflection_bridges.lmx](LMX_Fn_Receivers/src/reflection_bridges.lmx) |
| `reorder` | Полная перестановка физических полей без пропусков и повторов. | [structures.lmx](LMX_Fn_Receivers/src/structures.lmx) |
| `project` | Проекция выбранных полей с одной общей операцией copy и общей картой копирования. | [structures.lmx](LMX_Fn_Receivers/src/structures.lmx) |
| `defaults` | Обычный merge(fallback; source); наличие исходного поля сохраняется и для нуля/uninit. | [structures.lmx](LMX_Fn_Receivers/src/structures.lmx) |
| `diff` | Разность вектора идентичностей записей; содержимое объектов не сравнивается глубоко. | [structures.lmx](LMX_Fn_Receivers/src/structures.lmx) |
| `patch` | Проверка базы и применение такой разности в новый контейнер. | [structures.lmx](LMX_Fn_Receivers/src/structures.lmx) |
| `bindFields` | Изменение DATA-defaults обычной композицией; входные позиции сохраняются. | [structures.lmx](LMX_Fn_Receivers/src/structures.lmx) |
| `derive` | Производная структура через общий merge. | [structures.lmx](LMX_Fn_Receivers/src/structures.lmx) |
| `transpose` | Транспонирование прямоугольной структуры строк; длины проверяются. | [collections.lmx](LMX_Fn_Receivers/src/collections.lmx) |
| `groupBy` | Группировка по keyOf и явному сравнению ключей с устойчивым порядком. | [collections.lmx](LMX_Fn_Receivers/src/collections.lmx) |
| `lazy` | Отложенный нульарный callable, кеширующий первый успешный результат. | [generic_wrappers.lmx](LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `force` | Явное получение результата отложенного вычисления. | [generic_wrappers.lmx](LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `once` | Обёртка с одним успешным вычислением; политика повторения после ошибки указана отдельно. | [generic_wrappers.lmx](LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `repeat` | Заданное число последовательных запусков с вектором результатов. | [generic_wrappers.lmx](LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `runUntil` | Повторение шага до выполнения предиката; не заменяет встроенный until. | [generic_wrappers.lmx](LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `retryCall` | Ограниченные повторные попытки по явной политике; не заменяет управляющий retry. | [generic_wrappers.lmx](LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `bracket` | Acquire, затем action, затем release через finally; освобождение после успешного acquire. | [generic_wrappers.lmx](LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `recover` | Обработка явно представленного отказа, без подавления ошибок подготовки ядра. | [generic_wrappers.lmx](LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `adapter` | Композиция преобразования входа, целевой операции и преобразования выхода. | [generic_combinators.lmx](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `permute` | Адаптация произвольного количества входов по полной перестановке позиций. | [generic_combinators.lmx](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `overload` | Выбор ровно одного кандидата по явным предикатам; неоднозначность является ошибкой. | [generic_combinators.lmx](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `predicate` | Нормализация результата предиката к логическому представлению профиля. | [generic_combinators.lmx](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `guard` | Проверка предусловия перед целевым вызовом. | [generic_combinators.lmx](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `trace` | Явные события входа, результата или завершения процедуры. | [generic_wrappers.lmx](LMX_Fn_Receivers/src/generic_wrappers.lmx) |
| `contract` | Предусловие и постусловие вокруг вызова; сама проверка совместимости остаётся satisfies. | [generic_combinators.lmx](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `composeData` | Композиция фактического DATA callable с overlay при сохранении правильного CODE и parent. | [structures.lmx](LMX_Fn_Receivers/src/structures.lmx) |
| `record` | Ссылка на типизированную запись подготовленного значения через обычный OPERANDS_TEMPLATE. | [generic_functions.lmx](LMX_Fn_Receivers/src/generic_functions.lmx) |
| `some` | Наличие значения любого типа в Maybe; переносится ссылка на запись. | [containers.lmx](LMX_Fn_Receivers/src/containers.lmx) |
| `none` | Отсутствие Maybe, отличное от имеющегося нуля и от void. | [containers.lmx](LMX_Fn_Receivers/src/containers.lmx) |
| `ok` | Успех Result с типизированным значением. | [containers.lmx](LMX_Fn_Receivers/src/containers.lmx) |
| `err` | Отказ Result с типизированной причиной. | [containers.lmx](LMX_Fn_Receivers/src/containers.lmx) |
| `bindResult` | Связывание Result с пропуском продолжения при отказе. | [containers.lmx](LMX_Fn_Receivers/src/containers.lmx) |
| `list` | Новый внешний контейнер записей из любого допустимого Array; отдельная оболочка items не создаётся. | [containers.lmx](LMX_Fn_Receivers/src/containers.lmx) |
| `flatMap` | Отображение в последовательности и их последовательное объединение. | [containers.lmx](LMX_Fn_Receivers/src/containers.lmx) |
| `done` | Завершённый шаг Bounce с произвольным типизированным результатом. | [containers.lmx](LMX_Fn_Receivers/src/containers.lmx) |
| `more` | Незавершённый Bounce с нульарным продолжением; конструктор его не вызывает. | [containers.lmx](LMX_Fn_Receivers/src/containers.lmx) |
| `trampoline` | Итеративное исполнение Bounce до done без накопления цепочки вызовов. | [containers.lmx](LMX_Fn_Receivers/src/containers.lmx) |

### Последовательности: 14 операций

| Ресивер / операнд | Действие | Исходник |
| --- | --- | --- |
| `range` | Плотный int[] от start с заданным step; stop не включается, размер проверяется. | [sequences.lmx](LMX_Fn_Receivers/src/sequences.lmx) |
| `slice` | Проверенный полуоткрытый диапазон [begin, end); профиль плотного или ссылочного массива сохраняется. | [sequences.lmx](LMX_Fn_Receivers/src/sequences.lmx) |
| `reverse` | Новый контейнер с обратным порядком элементов; цели ссылок сохраняются. | [sequences.lmx](LMX_Fn_Receivers/src/sequences.lmx) |
| `concat` | Объединение частей на один уровень; одинаковые плотные T[] сохраняют T[], остальные сочетания дают @[]. | [sequences.lmx](LMX_Fn_Receivers/src/sequences.lmx) |
| `compress` | Устойчивый выбор по int-маске той же длины; профиль исходного массива сохраняется. | [sequences.lmx](LMX_Fn_Receivers/src/sequences.lmx) |
| `any` | Проверка предиката слева направо с остановкой на первом истинном результате. | [sequences.lmx](LMX_Fn_Receivers/src/sequences.lmx) |
| `all` | Проверка предиката слева направо с остановкой на первом ложном результате. | [sequences.lmx](LMX_Fn_Receivers/src/sequences.lmx) |
| `index` | Maybe с индексом первого подходящего элемента; none при отсутствии. | [sequences.lmx](LMX_Fn_Receivers/src/sequences.lmx) |
| `count` | Число элементов, принятых предикатом; обход выполняется в порядке источника. | [sequences.lmx](LMX_Fn_Receivers/src/sequences.lmx) |
| `replaceRange` | Замена [begin, end) после проверки и захвата источника; перекрытие допустимо, descriptor target сохраняется. | [sequences_mutation.lmx](LMX_Fn_Receivers/src/sequences_mutation.lmx) |
| `splice` | Меняет [begin, end) через replaceRange; возвращает удалённые элементы в новом контейнере того же профиля. | [sequences_mutation.lmx](LMX_Fn_Receivers/src/sequences_mutation.lmx) |
| `append` | Добавление значений в конец того же target; значения источника фиксируются до записи. | [sequences_mutation.lmx](LMX_Fn_Receivers/src/sequences_mutation.lmx) |
| `insert` | Вставка последовательности в указанную позицию того же target. | [sequences_mutation.lmx](LMX_Fn_Receivers/src/sequences_mutation.lmx) |
| `deleteAt` | Удаление [begin, end) из того же target через общий алгоритм replaceRange. | [sequences_mutation.lmx](LMX_Fn_Receivers/src/sequences_mutation.lmx) |

### Текстовые Patterns: 33 ресивера и 5 операндов

| Ресивер / операнд | Действие | Исходник |
| --- | --- | --- |
| `literal` | Pattern буквального текста; строка не разбирается как отдельный regex-синтаксис. | [primitives.lmx](LMX_Fn_Receivers/src/regex/primitives.lmx) |
| `oneOf` | Pattern одной текстовой единицы из заданного набора. | [primitives.lmx](LMX_Fn_Receivers/src/regex/primitives.lmx) |
| `noneOf` | Pattern одной текстовой единицы вне заданного набора. | [primitives.lmx](LMX_Fn_Receivers/src/regex/primitives.lmx) |
| `charRange` | Pattern одной текстовой единицы из включительного диапазона first..last. | [primitives.lmx](LMX_Fn_Receivers/src/regex/primitives.lmx) |
| `satisfy` | Pattern одной текстовой единицы, принятой обычным предикатом. | [primitives.lmx](LMX_Fn_Receivers/src/regex/primitives.lmx) |
| `boundaryOf` | Нулевой Pattern границы по предикату соседних текстовых единиц. | [primitives.lmx](LMX_Fn_Receivers/src/regex/primitives.lmx) |
| `sameAs` | Буквальное повторение последнего завершённого захвата с указанным именем. | [primitives.lmx](LMX_Fn_Receivers/src/regex/primitives.lmx) |
| `sequence` | Последовательное соединение Patterns с возвратом к предыдущим кандидатам при неудаче продолжения. | [combinators.lmx](LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `choice` | Упорядоченный выбор: кандидаты ранней ветви исчерпываются прежде перехода к следующей. | [combinators.lmx](LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `repeated` | Повторение между minimum и maximum с порядком extendFirst или stopFirst; unbounded — явное значение настройки. | [combinators.lmx](LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `atomic` | Сохранение только первого кандидата дочернего Pattern; последующая неудача не открывает его заново. | [combinators.lmx](LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `capture` | Именованный захват с историей завершённых вхождений; неудачная ветвь не меняет чужую историю. | [combinators.lmx](LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `ahead` | Положительная проверка вперёд без сдвига внешней позиции и переноса новых локальных захватов. | [combinators.lmx](LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `notAhead` | Отрицательная проверка вперёд; отсутствие кандидата отличается от ошибки выполнения. | [combinators.lmx](LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `behind` | Положительная проверка назад, включая переменную ширину, без сдвига внешней позиции. | [combinators.lmx](LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `notBehind` | Отрицательная проверка назад без сдвига позиции и без подавления ошибок выполнения. | [combinators.lmx](LMX_Fn_Receivers/src/regex/combinators.lmx) |
| `utf8Text` | Проверенный TextView для UTF-8; единицы поиска — Unicode scalar values, исходный descriptor сохраняется. | [text.lmx](LMX_Fn_Receivers/src/regex/text.lmx) |
| `byteText` | TextView с единицами 0–255 для физического 8-битного char[]; кодировка не декодируется. | [text.lmx](LMX_Fn_Receivers/src/regex/text.lmx) |
| `matchAt` | Первое совпадение с началом в заданной позиции текстового профиля. | [operations.lmx](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `wholeMatch` | Поиск кандидата, покрывающего весь текст; неполный ранний кандидат не отменяет последующий backtracking. | [operations.lmx](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `find` | Первое совпадение при поиске слева направо; результат использует общий Maybe. | [operations.lmx](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `eachMatch` | Итератор совпадений через обычные yield/Stop; пустые совпадения не зацикливают поиск. | [operations.lmx](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `contains` | Логический результат наличия найденного совпадения. | [operations.lmx](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `hasPrefix` | int 1/0: совпадение начинается в позиции 0; хвост разрешён. | [operations.lmx](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `hasSuffix` | int 1/0: существует совпадение, доходящее до конца; учитываются перекрытия и альтернативы. | [operations.lmx](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `matches` | Логический результат совпадения всего текста. | [operations.lmx](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `matchedSpan` | Интервал выбранного совпадения со ссылкой на исходный TextView. | [operations.lmx](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `matchedText` | Материализация текста выбранного совпадения в новом char[]. | [operations.lmx](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `captureSpans` | Интервалы всех завершённых захватов имени в хронологическом порядке. | [operations.lmx](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `lastCapture` | Последний завершённый интервал захвата имени; отсутствие отличается от пустого захвата. | [operations.lmx](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `captureText` | Материализация текста последнего завершённого захвата имени. | [operations.lmx](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `captureTexts` | Материализация текстов всей истории завершённых захватов имени. | [operations.lmx](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `replaceFirst` | Замена первого выбранного совпадения текстом или результатом обычного callable. | [operations.lmx](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `replace` | Замена всех выбранных совпадений; вставленный текст повторно не просматривается. | [operations.lmx](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `split` | Разбиение по совпадениям с сохранением определённых контрактом пустых полей. | [operations.lmx](LMX_Fn_Receivers/src/regex/operations.lmx) |
| `then` | Обычный Expression-операнд последовательного соединения Patterns; делегирует общему конструктору. | [operands.lmx](LMX_Fn_Receivers/src/regex/operands.lmx) |
| `times` | Обычный Expression-операнд точного числа повторений Pattern. | [operands.lmx](LMX_Fn_Receivers/src/regex/operands.lmx) |
| `atLeast` | Обычный Expression-операнд нижней границы числа повторений Pattern. | [operands.lmx](LMX_Fn_Receivers/src/regex/operands.lmx) |
| `atMost` | Обычный Expression-операнд верхней границы числа повторений Pattern. | [operands.lmx](LMX_Fn_Receivers/src/regex/operands.lmx) |
| `optional` | Обычный Expression-операнд нуля или одного повторения Pattern; не создаёт Maybe. | [operands.lmx](LMX_Fn_Receivers/src/regex/operands.lmx) |

## Дополнения из сравнений реализации

Полный текущий список, включая сигнатуры и ссылки на исходники, находится в [CORE_FUNCTIONS.md](../CORE_FUNCTIONS.md). Дополнения не образуют подключаемую библиотеку: после интеграции они доступны напрямую, в одном ядре.

- `findFirst`, `allOf`, `equalFields` и `retryPost`: [исходник](LMX_Fn_Receivers/src/coreComparisonGroups.lmx).
- `between` и `iterateUntilStop`: [исходник](LMX_Fn_Receivers/src/coreComparisonExamples.lmx), [контракт принятой декларации](LMX_Fn_Receivers/CORE_EXAMPLE_HELPERS.md).
- `sort` и `unique`: [исходник](LMX_Fn_Receivers/src/corePerlExamples.lmx), [полный договор](LMX_Fn_Receivers/CORE_PERL_EXAMPLES.md); используются общим образом в Julia и Perl наборах.

`retryPost` использует настоящие Message и `post`, сохраняет конечный результат и отдельно учитывает поздние ответы. Таймаут и отмена дальнейших повторов не означают принудительного завершения удалённого вызова. `iterateUntilStop` требует узкого входа `attemptAccepted`, сохраняющего принятую позицию декларации и живые места принимающего исполнения. Его реализация в нативном ядре — явно указанная интеграционная задача, не имитация через копию namespace.

## Значение, запись и созданная функция

`(value record)` даёт ссылку на типизированную запись. Это удобно для неоднородной структуры аргументов, Maybe/Result и коллекций. Обычное разыменование читает значение по его реальному типу. Контейнер не требует предварительно превращать любое значение в int или дополнительную одноэлементную структуру.

`apply` переносит результат как такую запись. Фабрики `curry`, `partial`, `flip` и композиции создают обычные callable с точными типами входов и результата. Возвращаемый фабрикой @ означает ссылку на созданный callable, а не изменение его результата на @. Void сохраняет отдельное значение отсутствия результата.

Maybe имеет present и ссылку value; Result — ok и ссылку value/reason; List — сама структура; Bounce — done/result либо нульарное продолжение. `more` не вызывает продолжение, а `trampoline` запускает их по одному. Эти формы используют существующую память LMX и не добавляют класс, scheduler или новую разновидность арены.

## Названия

Каррирование называется `curry`, левая свёртка — `foldl`, её префиксы с seed — `scanl`, мемоизация — `memoize`, acquire/release/action — `bracket`. Именованные сигнатуры полностью записываются `Name :: DATA`; построение из type-токенов доступно как `signatureTypes`. Старого публичного fn или его алиаса нет. Текущие имена `flatMap`, `groupBy`, `index`, `reverse`, `compress`, `replaceRange` и остальные согласованы с [текущей картой 15 переименований](api_revision_20261122.json). Переименование не меняет контракт: например, `index` возвращает Maybe индекса, а `deleteAt` удаляет полуоткрытый диапазон. Источники выбора имён и отличия от полных контрактов контрольных языков приведены в разделе [Источники имён](../LMX_semantics.en.md#receiver-name-sources).

## Примеры и метрика

[Функциональная группа](09_functional_computation/README.md) и [корневые примеры](examples/README.ru.md) используют этот API. Полные дополнительные листинги оставлены для действительно разных подходов; различия одной строки объясняются текстом. Самостоятельные реализации на контрольных языках сравниваются с LMX отдельно, а клиенты используют настоящие библиотеки или средства языка. LMX-клиенты используют прямые имена ядра. Общие зависимости показаны и посчитаны отдельно.

Это исходная реализация и контракт интеграции. Часть входов ядра требует реализации по [интеграции в ядро](../kernel-implementation.en.md#receiver-kernel-integration). Статический отчёт не заменяет запуск parser/transpiler или native/interpreter.

## Как выбирается сравниваемый пример

Основным становится самый короткий по непробельным символам корректный вариант
с сопоставимой границей подсчёта. Существенно иной вариант сохраняется рядом; малозначимая вариация описывается комментарием. Включение
helper в ядро само по себе не позволяет скрыть его работу: библиотечный вызов
LMX сопоставляется с библиотекой или оператором контрольного языка, выполняющим
сопоставимую работу. Если контроль раскрывает предметный алгоритм, его реализация
показывается и учитывается также на стороне LMX либо сравнение помечается отдельным
уровнем использования. Общие определения считаются один раз.

Архитектурные преимущества языка сохраняются: обычные copy/merge, динамическая
структура и связывание не заменяются искусственной имитацией классов или
статических generic-конструкций. Сравниваются задача и поведение, а не форма
алгоритмов. Поля, идентичность, порядок эффектов, состояния, ошибки и проверяемый
результат нельзя удалять ради сокращения; в Flyweight поле width остаётся во всех
реализациях. Исторический некорректный листинг может быть пояснением, но не кандидатом
на выбор основного по краткости.

## Операнды и скобки

`::` использует expression LMX и общие правила операндов. `Name :: A B` передаёт
два правых аргумента, `Name :: (A B)` — один аргумент-структуру.
Единственное общее раскрытие возможно, когда left — безымянная структура,
right содержит ровно один аргумент и этот аргумент тоже безымянная структура.
Тогда снимается один внешний уровень только в right; left остаётся целым.
Операция не повторяется рекурсивно и никогда не выполняется P0. Для левого
идентификатора Name это исключение не действует. [Полная матрица случаев](../LMX_semantics.en.md#operand-right-only-opening).
