# Исходники к русскому разбору LMX

[Все наборы: Haskell, Julia, Perl](README.md) · [Статистика всей директории](STATISTICS.md). Эта страница описывает исходные 24 сценария и их Haskell-аналоги.

Эти файлы сопровождают [русский разбор](../LMX_examples_and_analogies.ru.md).

Каждый клиент `.lm3` загружается в свежий контекст вместе с перечисленными для него зависимостями `load_before` из expected_results.json. Затем существующий стенд вызывает его точку входа. Общие функции доступны напрямую как часть единого ядра. Обычный import в предметном примере открывает уже доступные имена; чтение файла по пути он не вводит. Разные клиенты не объединяются в один namespace, искусственный main или DATA для R0 не добавляются.

[expected_results.json](expected_results.json) содержит ожидаемые значения, необходимые счётчики и подготовку. Это описание приёмки, а не результаты уже выполненного запуска.

| Файл | Точка входа / проверка |
| --- | --- |
| [H01.lm3](lmx/H01.lm3) | `ApplyProbe\run()` |
| [H02.lm3](lmx/H02.lm3) | `SignatureProbe\run()` |
| [H03.lm3](lmx/H03.lm3) | `ClosureProbe\run()`; `add5(1; saved := 25)` |
| [H04.lm3](lmx/H04.lm3) | `DefaultProbe\run()` |
| [H05.lm3](lmx/H05.lm3) | `BindingProbe\run()` |
| [H06.lm3](lmx/H06.lm3) | `CompositionProbe\run()` |
| [H07.lm3](lmx/H07.lm3) | `Evaluation\prepared(), Evaluation\prepared()`; `Evaluation\raw(), Evaluation\raw()` |
| [H08.lm3](lmx/H08.lm3) | `StateProbe\run(Own\step)`; `StateProbe\run(Free\step)` |
| [H09.lm3](lmx/H09.lm3) | `Numbers\demo()` |
| [R01.lm3](lmx/R01.lm3) | `MergeProbe\run()` |
| [R02.lm3](lmx/R02.lm3) | `StreamProbe\run()` |
| [R03.lm3](lmx/R03.lm3) | `ImportProbe\run()` |
| [R04.lm3](lmx/R04.lm3) | `LocalProbe\run()`; `LocalProbe\explicitInitialization()` |
| [R06a.lm3](lmx/R06a.lm3) | `SharingProbe\run()` |
| [R06b.lm3](lmx/R06b.lm3) | `CycleProbe\run()` |
| [R07.lm3](lmx/R07.lm3) | `Operands\Example\demo()` |
| [R09.lm3](lmx/R09.lm3) | `UninitializedGraph\localWrite()`; `UninitializedGraph\graphWrite()` |
| [A01.lm3](lmx/A01.lm3) | `SlotProbe\run()` |
| [V02.lm3](lmx/V02.lm3) | `TicketCode\accepts("AB-09")`; `TicketCode\accepts("QZ-70")` |
| [V03.lm3](lmx/V03.lm3) | `SamplingCheck\check(candidate := Measurement\sample)`; `SamplingCheck\check(candidate := Measurement\biased)` |
| [V04.lm3](lmx/V04.lm3) | `FailureCheck\check(candidate := UnavailableSensor\read)`; `FailureCheck\check(candidate := UnavailableSensor\zero)` |
| [V05.lm3](lmx/V05.lm3) | `Commissioning\check(candidate := device)`; `Commissioning\check(candidate := device)` |
| [M01.lm3](lmx/M01.lm3) | `` |
| [M05.lm3](lmx/M05.lm3) | `Lamp\set(command := 1)` |

## Редакция с общими ресиверами и восстановленными короткими примерами

H04 использует прямой merge из 22-Nov. H09 содержит полный короткий Cycles с обычным catch; определение включено в основной размер. V02 сохраняет between. H07 переиспользует общий шаблон операнда, H08 — одно тело изменения y и один runner, M01 — существующий read, V05 — общий шаг журнала и общий цикл set/observe. Динамическое связывание и copy учитываются как обычные возможности языка. При равном договоре выбирается кратчайшая полноценная запись; размещение функции в ядре не даёт её клиенту приоритета.

[Реестр](variants.json) · [Ожидания](expected_results.json) · [Аудит](OPTIMIZATION_REVIEW.md) · [Размеры](validation/functional_receiver_counts.json). Все 24 сценария и их наблюдения сохранены.

## Haskell

[Analogies.hs](haskell/Analogies.hs) использует Haskell2010 с настоящими библиотеками `base`, `array` и `monad-loops` (0.4.3). Он содержит собственные assertions для функциональных аналогов, явного AST, неизменяемого массива, mock-зависимости, owner-loop и fan-out.

Из корня распакованного архива:

```sh
cd patterns/examples/haskell && cabal run lmx-analogy-clients
```

Успешная компиляция/исполнение здесь не заявляются: проверены текст, типовые отношения вручную и ожидаемые результаты. Отдельные транспортные и физические LMX-fixtures описаны в руководстве, поскольку они должны использовать действительные механизмы проверяемой реализации.

## Сравнительные программы

В JSON отдельно перечислены DP01–DP23 из корневых сравнительных документов. Их результаты отличаются от некоторых P01–P23 английского регрессионного корпуса, поскольку это разные конкретные тестовые данные. Числа каждой серии надо брать из её собственной записи.
