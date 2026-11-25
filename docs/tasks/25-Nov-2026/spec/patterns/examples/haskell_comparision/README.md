# LMX и Haskell: 24 исходника и сравнения

Директория `haskell_comparision` содержит соответствующий Haskell-код **для всех 24 исходных сценариев**, их полные сравнения и две сохранённые LMX-формы. Пустых иностранных листингов нет. Само совпадение результата не выдаётся за реализацию гомоиконного графа, динамического связывания, parent или Message-протокола: такие строки имеют явную границу аналогии.

| Сценарий | Haskell-исходник | Сопоставимость |
| --- | --- | --- |
| [H01. Replace and invoke a first-class callable](H01_comparision.md) | [H01.hs](source/haskell/H01.hs) | Полная пара |
| [H02. Named signature positions versus candidate names](H02_comparision.md) | [H02.hs](source/haskell/H02.hs) | Аналогия |
| [H03. Independent bound prefixes and residual callable admission](H03_comparision.md) | [H03.hs](source/haskell/H03.hs) | Полная пара |
| [H04. Overrideable copied default](H04_comparision.md) | [H04.hs](source/haskell/H04.hs) | Полная пара |
| [H05. Dynamic and lexical binding after a graph copy](H05_comparision.md) | [H05.hs](source/haskell/H05.hs) | Аналогия |
| [H06. Order of two composed computations](H06_comparision.md) | [H06.hs](source/haskell/H06.hs) | Полная пара |
| [H07. Prepared value versus raw source occurrence](H07_comparision.md) | [H07.hs](source/haskell/H07.hs) | Аналогия |
| [H08. Owned formal copy versus caller place](H08_comparision.md) | [H08.hs](source/haskell/H08.hs) | Аналогия |
| [H09. Finite iterator with a live declaration and body](H09_comparision.md) | [H09.hs](source/haskell/H09.hs) | Аналогия |
| [R01. Merge an existing record and add a field](R01_comparision.md) | [R01.hs](source/haskell/R01.hs) | Аналогия |
| [R02. Copy a field stream into group assignment](R02_comparision.md) | [R02.hs](source/haskell/R02.hs) | Аналогия |
| [R03. Imported parent identity versus copied parent identity](R03_comparision.md) | [R03.hs](source/haskell/R03.hs) | Аналогия |
| [R04. Computed initializer, local write and repeated activation](R04_comparision.md) | [R04.hs](source/haskell/R04.hs) | Аналогия |
| [R06a. Graph copy preserving shared targets](R06a_comparision.md) | [R06a.hs](source/haskell/R06a.hs) | Аналогия |
| [R06b. Graph copy preserving a cycle](R06b_comparision.md) | [R06b.hs](source/haskell/R06b.hs) | Аналогия |
| [R07. User operand and preserved computation](R07_comparision.md) | [R07.hs](source/haskell/R07.hs) | Аналогия |
| [R09. Uninitialized payload and local versus graph write](R09_comparision.md) | [R09.hs](source/haskell/R09.hs) | Аналогия |
| [A01. Shared structural slots and replacement field identity](A01_comparision.md) | [A01.hs](source/haskell/A01.hs) | Аналогия |
| [V02. Whole ASCII ticket-code predicate](V02_comparision.md) | [V02.hs](source/haskell/V02.hs) | Полная пара |
| [V03. Inject a read dependency and check interaction counts](V03_comparision.md) | [V03.hs](source/haskell/V03.hs) | Полная пара |
| [V04. Distinguish a named failure from a numeric result](V04_comparision.md) | [V04.hs](source/haskell/V04.hs) | Полная пара |
| [V05. Command/read integration check and fault modes](V05_comparision.md) | [V05.hs](source/haskell/V05.hs) | Полная пара |
| [M01. Serial state updates at one Message owner](M01_comparision.md) | [M01.hs](source/haskell/M01.hs) | Полная пара |
| [M05. Void Message procedure without a fabricated reply](M05_comparision.md) | [M05.hs](source/haskell/M05.hs) | Аналогия |

Полных пар: 9. Реальных программ-аналогий с указанными ограничениями: 15. Обе категории снабжены исходниками и фикстурами; статус **не означает**, что новый код уже запускался.

## Устройство каталога

- `source/lmx`: исходные полные функциональные LMX-записи; `procedural` содержит отличающиеся процедурные формы. Совпадающая минимальная форма хранится одним файлом и имеет два стилевых указателя.
- `source/haskell`: 24 отдельных модуля и одна общая пользовательская реализация `GraphCopy.hs` для двух графовых примеров.
- `<ID>_comparision.md`: договор, обе LMX-формы, Haskell-код, точная граница соответствия и ссылки на проверку.
- `comparison_index.json`: зеркала исходников, зависимости и отдельные статусы сопоставимости, измерения и исполнения.
- `validation/fixtures.json` и `validation/Main.hs`: ожидаемые наблюдения и исполнимый проверяющий harness.
- `Analogies.hs`: сохранённый прежний сборник, включая дополнительные примеры руководства. Новые 24 пары от него не зависят; старый сборник не считается доказательством выполнения новых модулей.

## Метрики



В текущем пересчёте сравниваются обе полные LMX-формы и полный Haskell-модуль, включая объявления, imports, локальные helpers, обработчики и Throws. Общий пользовательский GraphCopy раскрывается в границе зависимости и учитывается один раз в полном листинге использующего его примера. Harness с запуском потоков, утверждениями и дополнительной инструментировкой находится за этой границей в обоих языках. Неполные графовые аналогии не получают победителя; в полных парах зелёным выделяются все равные минимумы.

## Проверка

Из этой директории:

```sh
python3 tools/check.py
```

Проверка сверяет 24 исходника с Markdown и JSON, наличие обеих LMX-форм и зависимостей, полный набор фикстур, имена модулей и SHA-256 текущего текста. Если `ghc` найден, она компилирует `validation/Main.hs` с `source/haskell` и запускает тесты с ограничением времени. Если компилятора нет, результат исполнения честно остаётся **NOT_RUN**, а статическая проверка фиксируется отдельно. Протокол пишется в `validation/check_receipt.json`.

При установленном Cabal можно выполнить:

```sh
cabal test haskell-comparisons
```

Текущая подготовка: Haskell compilation/runtime **NOT_RUN**, LMX runtime **NOT_RUN**. Ожидания из `fixtures.json` не являются прошедшими тестами. Уже полученные ранее parser receipts LMX не заменяются новым runtime-утверждением.

LMX стартует с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции фикстур происходят после старта; они не образуют альтернативный Main. В Haskell `validation/Main.hs` — обычная точка запуска тестового harness целевого языка.

## Официальные источники интерфейсов

- [Haskell 2010 Report: expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html)
- [base: Data.IORef](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Data-IORef.html)
- [base: Control.Exception](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Control-Exception.html)
- [base: Control.Concurrent.Chan](https://downloads.haskell.org/ghc/9.6.1/docs/libraries/base-4.18.0.0/Control-Concurrent-Chan.html)
- [containers: Data.Map.Strict](https://hackage-content.haskell.org/package/containers-0.7/docs/Data-Map-Strict.html)
- [base: Data.Ix](https://hackage-content.haskell.org/package/base-4.20.1.0/docs/Data-Ix.html)

Копирование графа, модели owner/slot/payload и адаптер именованных аргументов написаны непосредственно в показанных исходниках. Они не приписываются стандартной библиотеке Haskell.

Размеры пересчитаны по текущим полным исходникам. Таблицы: [Markdown](LMX_Comparison_Haskell.md), [PDF](LMX_Comparison_Haskell.pdf), [XLSX](LMX_Comparison_Haskell.xlsx), [CSV](statistics.csv), [JSON](statistics.json).
