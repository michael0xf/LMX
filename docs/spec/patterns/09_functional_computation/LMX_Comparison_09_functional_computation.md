# Сравнение: Функциональные вычисления

Контрольные языки: **Haskell, Scala**. Редакция: 2026-11-22. Основной — короткий допустимый алгоритм текущего контракта.

Числа — непробельные символы / непустые строки. Альтернативы сохранены и исключены из этой таблицы. Все клиенты используют текущие совместимые компоненты; исторические примеры не задают ещё одну библиотеку. Подробности и отдельные суммы: [реестр зависимостей](IMPLEMENTATION_DEPENDENCIES.md).

| ID | Паттерн | LMX | Haskell | Scala | Граница |
| ---: | --- | ---: | ---: | ---: | --- |
| 082 | [Monad](082_monad_comparision.md) | 226 / 17 | 183 / 6 | 147 / 6 | Использование библиотеки |
| 091 | [Maybe container and bind implementation](091_maybe_container_and_bind_implementation_comparision.md) | 411 / 30 | 271 / 10 | 265 / 12 | Реализация библиотеки |
| 083 | [Trampoline](083_trampoline_comparision.md) | 479 / 37 | 236 / 9 | 237 / 8 | Использование библиотеки |
| 092 | [Trampoline container and runner implementation](092_trampoline_container_and_runner_implementation_comparision.md) | 611 / 39 | 198 / 9 | 303 / 13 | Реализация библиотеки |
| 084 | [Execute Around](084_execute_around_comparision.md) | 817 / 52 | 579 / 20 | 440 / 26 | Использование библиотеки |
| 098 | [Execute Around implementation](098_execute_around_implementation_comparision.md) | 374 / 20 | 287 / 10 | 141 / 9 | Реализация библиотеки |
| 085 | [Currying](085_currying_comparision.md) | 283 / 20 | 180 / 8 | 189 / 9 | Использование библиотеки |
| 099 | [General partial-application implementation](099_integer_partial_application_implementation_comparision.md) | 605 / 24 | 101 / 3 | 91 / 4 | Реализация библиотеки |

Haskell даёт естественный контроль для Maybe/Monad и каррирования. Scala сочетает функциональные приёмы с JVM, явным батутом и обычным управлением ресурсами. Эти языки выбраны за подходящие механизмы, а не для универсального рейтинга краткости.

[Варианты и размеры](variant_selection.json) · [Методика](../COMPARISON_METHODOLOGY.ru.md) · [Проверка](VALIDATION_2026-11-22.md)

По разным контрактам и разной общности не строится общий рейтинг языка. Более короткий листинг не отменяет существование полной общей реализации рядом.
