# Функциональные вычисления

Четыре прикладных сценария используют ядро LMX и реальные средства Haskell/Scala. Четыре соседних сравнения показывают самостоятельные реализации соответствующих компонентов; usage-клиенты их не импортируют. Сохранены только альтернативы с другим подходом.

[Каталог](LMX_Design_Patterns.ru.md) · [English](LMX_Design_Patterns.en.md) · [Сравнение](LMX_Comparison_09_functional_computation.md) · [Зависимости](IMPLEMENTATION_DEPENDENCIES.md) · [Проверка](VALIDATION_2026-11-23.md) · [Message и ошибки](FAILURE_BOUNDARIES.md)

Клиенты Haskell используют Maybe, пакет free, Control.Exception.bracket и обычное применение функций. Scala использует Option, TailCalls, Using.resource и Function2.curried. Самописные MaybeValue/Bounce/Around/Partial используются только в сравнениях реализации. Они не нужны для запуска usage-клиентов.

Профили компиляции: Haskell usage — GHC с base, для 083 установленный free (проверенный контракт 5.2). Реализация 098 включает ScopedTypeVariables; 099 — DataKinds, GADTs, KindSignatures, TypeFamilies и TypeOperators, перечисленные в pragma. Scala-исходники написаны для Scala 3: enum/given/звёздочные импорты и гетерогенные Tuple в 099. Документация scala-library 2.13 подтверждает Using/TailCalls/Function2, но не означает совместимость этих исходников со Scala 2.13.

`patterns.json` — источник листингов и допустимых вариантов. `alternative` пуст: полные исторические повторы убраны. Различающиеся подходы находятся в `variants`; отдельный файл в `variants/` создаётся только для неосновного подхода. Основной исходник не содержит второй полной закомментированной копии.

Воспроизведение: sync_receiver_bodies.py → select_shortest.py → regenerate_publication.py → curry_appendix.py → check_publication.py. PDF/XLSX используют те же данные. Сверка исходников не является исполнением языков.
