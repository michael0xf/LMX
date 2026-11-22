# Общие ресиверы и контейнеры LMX

Редакция: **22 ноября 2026 года**. Все перечисленные операции и контейнеры входят в единое текущее ядро и доступны по прямым именам. Клиентский import не требуется. `fun\const` — внутренний источник постоянных экспортов; исходный владелец метода и его DATA сохраняются. Разных подключаемых версий библиотек нет.

В каталоге нет ограничения пользовательских значений типом int или произвольной фиксированной арностью. Используются полные типовые требования и ссылки на записи `{type value}`. Любая структура уже является массивом @ и служит последовательностью без обязательной обёртки items. Служебные int для type-кодов, индексов, длин и логических флагов сохраняются по смыслу языка.

## Документы и реализация

- [Интеграция общих ресиверов в ядро](../kernel-implementation.ru.md#receiver-kernel-integration).
- [Нормативное описание всех ресиверов](../LMX_semantics.en.md#functional-receivers).
- [Взаимозаменяемость форм сигнатуры с сохранённой связью именованной сигнатуры и call](../LMX_semantics.en.md#fn-forms-equivalent).
- [API с аргументами](LMX_Fn_Receivers/API.md) и [единая сборка исходников](LMX_Fn_Receivers/LMX_Receivers.lmx).
- [Минимальные входы ядра](LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md) и [проверки](LMX_Fn_Receivers/tests/ACCEPTANCE.md).

## Полный каталог

| Ресивер | Действие | Исходник |
| --- | --- | --- |
| `types` | Физические коды типов полей; результат int соответствует обычному контракту type. | [reflection.lmx](LMX_Fn_Receivers/src/reflection.lmx) |
| `names` | Канонические имена физических полей; отсутствие имени отличается от пустого exact identifier. | [reflection_bridges.lmx](LMX_Fn_Receivers/src/reflection_bridges.lmx) |
| `signature` | Описание сигнатуры, полученное из семантических входов и результата callable. | [reflection_bridges.lmx](LMX_Fn_Receivers/src/reflection_bridges.lmx) |
| `signatureTypes` | То же описание сигнатуры из полного набора типовых требований; тип результата слева, типы входов справа. | [fn_operand.lmx](LMX_Fn_Receivers/src/fn_operand.lmx) |
| `curry` | Цепочка одноаргументных функций для произвольного конечного числа входов; последняя возвращает исходный R. | [generic_functions.lmx](LMX_Fn_Receivers/src/generic_functions.lmx) |
| `apply` | Обычный вызов по вектору записей аргументов; результат переносится ссылкой на его типизированную запись. | [generic_runtime.lmx](LMX_Fn_Receivers/src/generic_runtime.lmx) |
| `partial` | Захват начального префикса 0..N аргументов; остаточная функция сохраняет точные типы. | [generic_functions.lmx](LMX_Fn_Receivers/src/generic_functions.lmx) |
| `uncurry` | Обратный адаптер цепочки с явной полной сигнатурой и объявленными исходами всех ступеней. | [generic_functions.lmx](LMX_Fn_Receivers/src/generic_functions.lmx) |
| `flip` | Перестановка первых двух позиций вместе с их типами; остальные позиции сохраняются. | [generic_functions.lmx](LMX_Fn_Receivers/src/generic_functions.lmx) |
| `compose` | Композиция outer(inner(...)) с согласованием результата inner и входа outer. | [generic_combinators.lmx](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `pipe` | Та же последовательная композиция в порядке first, then second. | [generic_combinators.lmx](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `identity` | Тождественная функция для переданного полного типового требования. | [generic_combinators.lmx](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `map` | Последовательное применение функции к каждой записи; новая структура результатов. | [collections.lmx](LMX_Fn_Receivers/src/collections.lmx) |
| `filter` | Отбор записей по предикату с сохранением порядка и идентичности выбранных значений. | [collections.lmx](LMX_Fn_Receivers/src/collections.lmx) |
| `foldl` | Левая свёртка с явным начальным состоянием; тип аккумулятора не обязан совпадать с типом элемента. | [collections.lmx](LMX_Fn_Receivers/src/collections.lmx) |
| `zip` | Пары записей до длины более короткой последовательности. | [collections.lmx](LMX_Fn_Receivers/src/collections.lmx) |
| `zipWith` | Попарный вызов операции с двумя аргументами произвольных типов. | [collections.lmx](LMX_Fn_Receivers/src/collections.lmx) |
| `scanl` | Префиксы левой свёртки, включая seed; n элементов дают n+1 состояний. | [collections.lmx](LMX_Fn_Receivers/src/collections.lmx) |
| `bind` | Связывание Maybe: отсутствие пропускает продолжение; наличие передаёт записанное значение. | [containers.lmx](LMX_Fn_Receivers/src/containers.lmx) |
| `traverse` | Обход в Maybe с остановкой на первом отсутствии и сохранением порядка. | [collections.lmx](LMX_Fn_Receivers/src/collections.lmx) |
| `memoize` | Кеш результатов с явным сравнением ключей и заданным договором стабильности ключа. | [generic_combinators.lmx](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `fix` | Рекурсивное связывание через явно предоставленную функцию self. | [generic_combinators.lmx](LMX_Fn_Receivers/src/generic_combinators.lmx) |
| `select` | Выбор физических полей по индексам, включая порядок заданного списка. | [structures.lmx](LMX_Fn_Receivers/src/structures.lmx) |
| `omit` | Исключение физических полей по индексам. | [structures.lmx](LMX_Fn_Receivers/src/structures.lmx) |
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
| `list` | Обычная структура как последовательность @; отдельная оболочка items не создаётся. | [containers.lmx](LMX_Fn_Receivers/src/containers.lmx) |
| `flatMap` | Отображение в последовательности и их последовательное объединение. | [containers.lmx](LMX_Fn_Receivers/src/containers.lmx) |
| `done` | Завершённый шаг Bounce с произвольным типизированным результатом. | [containers.lmx](LMX_Fn_Receivers/src/containers.lmx) |
| `more` | Незавершённый Bounce с нульарным продолжением; конструктор его не вызывает. | [containers.lmx](LMX_Fn_Receivers/src/containers.lmx) |
| `trampoline` | Итеративное исполнение Bounce до done без накопления цепочки вызовов. | [containers.lmx](LMX_Fn_Receivers/src/containers.lmx) |

## Значение, запись и созданная функция

`(value record)` даёт ссылку на типизированную запись. Это удобно для неоднородной структуры аргументов, Maybe/Result и коллекций. Обычное разыменование читает значение по его реальному типу. Контейнер не требует предварительно превращать любое значение в int или дополнительную одноэлементную структуру.

`apply` переносит результат как такую запись. Фабрики `curry`, `partial`, `flip` и композиции создают обычные callable с точными типами входов и результата. Возвращаемый фабрикой @ означает ссылку на созданный callable, а не изменение его результата на @. Void сохраняет отдельное значение отсутствия результата.

Maybe имеет present и ссылку value; Result — ok и ссылку value/reason; List — сама структура; Bounce — done/result либо нульарное продолжение. `more` не вызывает продолжение, а `trampoline` запускает их по одному. Эти формы используют существующую память LMX и не добавляют класс, scheduler или новую разновидность арены.

## Названия

Каррирование называется `curry`, левая свёртка — `foldl`, её префиксы с seed — `scanl`, мемоизация — `memoize`, acquire/release/action — `bracket`. Именованные сигнатуры полностью записываются `Name :: DATA`; построение из type-токенов доступно как `signatureTypes`. Старого публичного fn или его алиаса нет. Источники выбора имён и отличия от полных контрактов контрольных языков приведены в разделе [Источники имён](../LMX_semantics.ru.md#receiver-name-sources).

## Примеры и метрика

[Функциональная группа](09_functional_computation/README.md) и [корневые примеры](examples/README.ru.md) используют этот API. В каждом переписанном файле сохранён прежний процедурный код, исключённый из основных метрик. Реализации и общие зависимости библиотек показаны отдельно и не считаются бесплатными при оценке полного приложения.

Это исходная реализация и контракт интеграции. Часть входов ядра требует реализации по [интеграции в ядро](../kernel-implementation.ru.md#receiver-kernel-integration). Статический отчёт не заменяет запуск parser/transpiler или native/interpreter.

## Как выбирается сравниваемый пример

Основным становится самый короткий по непробельным символам корректный вариант
с сопоставимой границей подсчёта. Второй вариант сохраняется рядом. Включение
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
