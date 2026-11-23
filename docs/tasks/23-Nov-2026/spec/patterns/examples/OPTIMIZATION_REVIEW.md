# Аудит examples: ядро, настоящие библиотеки и разные подходы

Редакция: 23 ноября 2026 года. Все 24 сценария сохранены. H04, R01 и V03 больше не повторяют целые программы ради нескольких изменённых строк.

| Пример | Сохранённые подходы | Основной |
| --- | --- | --- |
| H01 | original, receivers | original |
| H02 | original, receivers | original |
| H03 | original, receivers | receivers |
| H04 | receivers | receivers |
| H06 | original, receivers | original |
| H07 | original, receivers | original |
| R01 | receivers | receivers |
| V02 | original, regex | original |
| V03 | reuse | reuse |

H09 использует прямой iterateUntilStop, V02 — between. Их полные алгоритмы вынесены в ядро и сравнение реализаций; ни одного значения и проверки источника это не удаляет. Подготовленные/сырые occurrences H07 и lazy — разные подходы, поэтому оба сохранены. Небольшие варианты перечислены в [решениях](validation/dedup_decisions_20261123.json).

Haskell использует аппликацию, композицию, foldM/replicateM, Data.Ix.inRange и Control.Monad.Loops.whileJust_. Каталог libraries содержит только сравниваемые реализации. Клиентский Cabal-компонент не добавляет этот каталог в hs-source-dirs.

[Ожидания](expected_results.json), [реестр вариантов](variants.json), [размеры](validation/functional_receiver_counts.json). Исполнение LMX/GHC не заявляется.
