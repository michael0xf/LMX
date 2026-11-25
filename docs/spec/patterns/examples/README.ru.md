# Исходники к русскому разбору LMX

[Все наборы: Haskell, Julia, Perl](README.md) · [Статистика всей директории](STATISTICS.md). Эта страница описывает исходные 24 сценария и их Haskell-аналоги.

Эти файлы сопровождают [русский разбор](../LMX_examples_and_analogies.ru.md).


[expected_results.json](expected_results.json) содержит ожидаемые значения, необходимые счётчики и подготовку. Это описание приёмки, а не результаты уже выполненного запуска.

| Файл | Обычная операция после запуска корня / проверка |
| --- | --- |
| [H01.lm3](haskell_comparision/source/lmx/H01.lm3) | `ApplyProbe\run()` |
| [H02.lm3](haskell_comparision/source/lmx/H02.lm3) | `SignatureProbe\run()` |
| [H03.lm3](haskell_comparision/source/lmx/H03.lm3) | `ClosureProbe\run()`; `add5(1; saved := 25)` |
| [H04.lm3](haskell_comparision/source/lmx/H04.lm3) | `DefaultProbe\run()` |
| [H05.lm3](haskell_comparision/source/lmx/H05.lm3) | `BindingProbe\run()` |
| [H06.lm3](haskell_comparision/source/lmx/H06.lm3) | `CompositionProbe\run()` |
| [H07.lm3](haskell_comparision/source/lmx/H07.lm3) | `Evaluation\prepared(), Evaluation\prepared()`; `Evaluation\raw(), Evaluation\raw()` |
| [H08.lm3](haskell_comparision/source/lmx/H08.lm3) | `StateProbe\run(Own\step)`; `StateProbe\run(Free\step)` |
| [H09.lm3](haskell_comparision/source/lmx/H09.lm3) | `Numbers\demo()` |
| [R01.lm3](haskell_comparision/source/lmx/R01.lm3) | `MergeProbe\run()` |
| [R02.lm3](haskell_comparision/source/lmx/R02.lm3) | `StreamProbe\run()` |
| [R03.lm3](haskell_comparision/source/lmx/R03.lm3) | `ImportProbe\run()` |
| [R04.lm3](haskell_comparision/source/lmx/R04.lm3) | `LocalProbe\run()`; `LocalProbe\explicitInitialization()` |
| [R06a.lm3](haskell_comparision/source/lmx/R06a.lm3) | `SharingProbe\run()` |
| [R06b.lm3](haskell_comparision/source/lmx/R06b.lm3) | `CycleProbe\run()` |
| [R07.lm3](haskell_comparision/source/lmx/R07.lm3) | `Operands\Example\demo()` |
| [R09.lm3](haskell_comparision/source/lmx/R09.lm3) | `UninitializedGraph\localWrite()`; `UninitializedGraph\graphWrite()` |
| [A01.lm3](haskell_comparision/source/lmx/A01.lm3) | `SlotProbe\run()` |
| [V02.lm3](haskell_comparision/source/lmx/V02.lm3) | `TicketCode\accepts("AB-09")`; `TicketCode\accepts("QZ-70")` |
| [V03.lm3](haskell_comparision/source/lmx/V03.lm3) | `SamplingCheck\check(candidate := Measurement\sample)`; `SamplingCheck\check(candidate := Measurement\biased)` |
| [V04.lm3](haskell_comparision/source/lmx/V04.lm3) | `FailureCheck\check(candidate := UnavailableSensor\read)`; `FailureCheck\check(candidate := UnavailableSensor\zero)` |
| [V05.lm3](haskell_comparision/source/lmx/V05.lm3) | `Commissioning\check(candidate := device)`; `Commissioning\check(candidate := device)` |
| [M01.lm3](haskell_comparision/source/lmx/M01.lm3) | `` |
| [M05.lm3](haskell_comparision/source/lmx/M05.lm3) | `Lamp\set(command := 1)` |

## Редакция с общими ресиверами и восстановленными короткими примерами

H04 использует прямой merge из 22-Nov. H09 содержит полный короткий Cycles с обычным catch; определение включено в основной размер. V02 сохраняет between. H07 переиспользует общий шаблон операнда, H08 — одно тело изменения y и один runner, M01 — существующий read, V05 — общий шаг журнала и общий цикл set/observe. Динамическое связывание и copy учитываются как обычные возможности языка. Обе стилевые записи одного договора сравниваются полностью; одна не исключается ради краткости.

[Реестр](variants.json) · [Ожидания](expected_results.json) · [Аудит](OPTIMIZATION_REVIEW.md) · [Размеры](validation/functional_receiver_counts.json). Все 24 сценария и их наблюдения сохранены.

## Haskell

[Analogies.hs](haskell_comparision/Analogies.hs) использует Haskell2010 с настоящими библиотеками `base`, `array` и `monad-loops` (0.4.3). Он содержит собственные assertions для функциональных аналогов, явного AST, неизменяемого массива, mock-зависимости, owner-loop и fan-out.

Из корня распакованного архива:

```sh
cd patterns/examples/haskell && cabal run lmx-analogy-clients
```
Успешная компиляция/исполнение здесь не заявляются: проверены текст, типовые отношения вручную и ожидаемые результаты. Отдельные транспортные и физические LMX-fixtures описаны в руководстве, поскольку они должны использовать действительные механизмы проверяемой реализации.

## Сравнительные программы

В JSON отдельно перечислены DP01–DP23 из корневых сравнительных документов. Их результаты отличаются от некоторых P01–P23 английского регрессионного корпуса, поскольку это разные конкретные тестовые данные. Числа каждой серии надо брать из её собственной записи.

## Единые операции и формы

[Короткие общие примеры и канонические имена](../UNIFIED_OPERATIONS.md) описывают unique, bind/some, общие Patterns, обе формы вызова и точные роли аргументов. Изменённые исходники имеют статус LMX runtime NOT_RUN.

## Процедурная и функциональная формы

Все24 сценария опубликованы в двух полных LMX-записях с одним договором. [Таблица и ссылки](OPTIMIZATION_REVIEW.md). Оба текста, включая все Throws, входят в сравнение. Минимальные формы copy/raw/place/Message могут совпадать; для каждого такого случая дано объяснение. Иностранные исходники и статус аналогий не изменяются.

Считается полный текст каждой формы: все определения, вспомогательные методы, комментарии внутри листинга, обработчики, имена ошибок и полные ссылки `throws: copy(target\throws)`. Списки берутся из фактически выбранных методов или явно заданного конечного объединения договоров. Статистического удаления аргументов Throws нет. В PDF/XLSX зелёным шрифтом и подчёркиванием числа выделяются **все** равные минимумы полного счёта сопоставимой строки; неполные аналогии победителя не получают.

## Запуск корня и дальнейшие операции

Всегда запускается корень R0 как L3 Thread. У корня нет DATA и пользовательских аргументов. Локальные объявления и вызовы обрабатываются общим механизмом языка.

Именованные операции из invoke, inputs и тестовых cases выполняются корнем или обычным обработчиком уже после старта. Main и Example\run не являются альтернативными точками запуска программы. Заглушка-родитель может иметь собственные аргументы и отправить корню сообщение; эти аргументы не становятся DATA корня.

load_before обозначает необходимые определения фикстуры. Отдельного режима запуска через загрузку в DATA он не вводит; import открывает доступные имена. Для короткого фрагмента явно задаётся принимающий контекст последующей обычной операции. Новая команда CLI или API запуска здесь не определяется. LMX runtime: NOT_RUN. [Норма запуска](../../LMX_semantics.en.md#source-entry-profiles).
