# Исходники к русскому разбору LMX

Эти файлы сопровождают [русский разбор](../LMX_examples_and_analogies.ru.md).

Каждый клиент `.lm3` загружается в свежий контекст вместе с перечисленными для него зависимостями `load_before` из expected_results.json. Затем существующий стенд вызывает его точку входа. Библиотечный import открывает уже доступные имена; чтение файла по пути он не вводит. Разные клиенты не объединяются в один namespace, искусственный main или DATA для R0 не добавляются.

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

## Редакция с общими ресиверами и выбором короткого варианта

Во всех шести парах H01,H02,H03,H04,H06,H07 основной — более короткий корректный полный LMX-код, второй вариант сохранён рядом и исключён из его размера. Сравниваются только корректные варианты с сопоставимой границей учёта. Естественные динамические вызовы, копирование и связывание LMX не заменяются искусственной архитектурной имитацией. [Аудит и таблица](OPTIMIZATION_REVIEW.md) · [Оба исходника и зависимости](variants.json).

`expected_results.json` указывает `selected_variant`, `alternative_cases`, `variant_cases` и `variant_load_before`. Каждый вариант запускается отдельно. Все общие ресиверы входят в одно текущее ядро и доступны прямо. [LMX_Receivers.lmx](../LMX_Fn_Receivers/LMX_Receivers.lmx) — его видимые исходники, а не отдельная выбираемая версия библиотеки. Старые механизмы, если они нужны процедурному аналогу, явно записаны внутри самого примера. Каталог libraries сохраняет исходники механизмов для чтения, а не набор альтернативных ядер.

В H02 именованное требование записывается `PairOperation :: DATA`. Альтернатива строит такое же семантическое требование через `signatureTypes`, без публичного fn. H05/H08/H09 сохранены прямыми по причинам связывания, места записи и живой декларации/Stop; R07/V02 сохраняют OPERANDS_TEMPLATE первым в DATA.

[Размеры](validation/functional_receiver_counts.json) относятся к основной части перед маркером альтернативы. [Скрипт выбора](tools/select_variants.py) и [проверка](tools/check_receiver_revision.py) воспроизводят это правило. Реализации библиотек показаны рядом и посчитаны отдельно.

## Haskell

[Analogies.hs](haskell/Analogies.hs) использует Haskell2010 с библиотеками `base` и `array`. Он содержит собственные assertions для функциональных аналогов, явного AST, неизменяемого массива, mock-зависимости, owner-loop и fan-out.

Из корня распакованного архива:

```sh
runghc -iexamples/libraries/haskell examples/haskell/Analogies.hs
```

Успешная компиляция/исполнение здесь не заявляются: проверены текст, типовые отношения вручную и ожидаемые результаты. Отдельные транспортные и физические LMX-fixtures описаны в руководстве, поскольку они должны использовать действительные механизмы проверяемой реализации.

## Сравнительные программы

В JSON отдельно перечислены DP01–DP23 из корневых сравнительных документов. Их результаты отличаются от некоторых P01–P23 английского регрессионного корпуса, поскольку это разные конкретные тестовые данные. Числа каждой серии надо брать из её собственной записи.
