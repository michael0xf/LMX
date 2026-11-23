# Аудит examples: восстановление коротких реализаций

Редакция: 23 ноября 2026 года. Все 24 сценария сохранены. H04 восстановлен на основе прямого merge из 22-Nov; H09 снова содержит целиком исходный короткий Cycles. Вариант с ядром не имеет приоритета перед более простым полным решением.

| Пример | Сохранённые подходы | Основной |
| --- | --- | --- |
| H01 | original, receivers | original |
| H02 | original, receivers | original |
| H03 | original, receivers | receivers |
| H04 | original | original |
| H06 | original, receivers | original |
| H07 | original, receivers | original |
| R01 | receivers | receivers |
| V02 | original, regex | original |
| V03 | reuse | reuse |

H07 переиспользует sys\OPERANDS_TEMPLATE через copy/merge. H08 использует один runner и одно тело изменения y, демонстрируя собственную ячейку Own и свободное динамическое место Free. M01.add вызывает уже существующий read. V05 записывает шаг журнала и пару set/observe по одному разу; два вызова пары безусловны. H01/H02/H03/H04/H06 не хранят ненужные промежуточные результаты.

H09 включает полное локальное определение Cycles в основной размер. Его catch обрабатывает только Stop источника; отказ тела распространяется под исходным именем. Отдельный core-адаптер с FxCallFailure показан как иной контракт и не используется для подмены основного примера. V02 сохраняет between; prepared/raw occurrences H07 и lazy сохраняются как разные подходы.

Haskell использует аппликацию, композицию, foldM/replicateM, Data.Ix.inRange и Control.Monad.Loops.whileJust_. Каталог libraries содержит сравниваемые реализации; клиентский Cabal-компонент не добавляет его в hs-source-dirs.

[Ожидания](expected_results.json), [реестр вариантов](variants.json), [размеры](validation/functional_receiver_counts.json). Проверены исходники и согласованность; исполнение LMX/GHC не заявляется.
