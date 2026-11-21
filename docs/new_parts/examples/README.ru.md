# Исходники к русскому разбору LMX

Эти файлы сопровождают [русский разбор](../LMX_examples_and_analogies.ru.md).

Каждый `.lm3` — отдельный исходник со своими корневыми именами. Загружайте его в свежем контексте и вызывайте указанную точку входа существующим стендом. Не объединяйте все файлы в один namespace и не добавляйте искусственный `main` или DATA для R0.

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
| [H08.lm3](lmx/H08.lm3) | `StateProbe\ownCopy()`; `StateProbe\callerPlace()` |
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

## Haskell

[Analogies.hs](haskell/Analogies.hs) использует Haskell2010 с библиотеками `base` и `array`. Он содержит собственные assertions для функциональных аналогов, явного AST, неизменяемого массива, mock-зависимости, owner-loop и fan-out.

Из корня распакованного архива:

```sh
runghc examples/haskell/Analogies.hs
```

Успешная компиляция/исполнение здесь не заявляются: проверены текст, типовые отношения вручную и ожидаемые результаты. Отдельные транспортные и физические LMX-fixtures описаны в руководстве, поскольку они должны использовать действительные механизмы проверяемой реализации.

## Сравнительные программы

В JSON отдельно перечислены DP01–DP23 из корневых сравнительных документов. Их результаты отличаются от некоторых P01–P23 английского регрессионного корпуса, поскольку это разные конкретные тестовые данные. Числа каждой серии надо брать из её собственной записи.
