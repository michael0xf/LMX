# Сравнение: Функциональные вычисления

Контрольные языки: **Haskell, Scala**. Дата редакции: 2026-11-21.

Числа — непробельные символы / непустые строки показанных листингов. Комментарии включены. Использование библиотеки и её реализация имеют отдельные строки; граница одинакова для трёх языков.

| ID | Паттерн | LMX | Haskell | Scala | Граница |
| ---: | --- | ---: | ---: | ---: | --- |
| 082 | [Monad](082_monad_comparision.md) | 131 / 11 | 169 / 6 | 135 / 6 | Использование библиотеки |
| 091 | [Maybe container and bind implementation](091_maybe_container_and_bind_implementation_comparision.md) | 297 / 22 | 255 / 10 | 223 / 12 | Реализация библиотеки |
| 083 | [Trampoline](083_trampoline_comparision.md) | 273 / 16 | 222 / 9 | 215 / 8 | Использование библиотеки |
| 092 | [Trampoline container and runner implementation](092_trampoline_container_and_runner_implementation_comparision.md) | 397 / 28 | 229 / 9 | 361 / 14 | Реализация библиотеки |
| 084 | [Execute Around](084_execute_around_comparision.md) | 563 / 38 | 580 / 20 | 441 / 26 | Использование библиотеки |
| 098 | [Execute Around implementation](098_execute_around_implementation_comparision.md) | 156 / 12 | 293 / 10 | 145 / 9 | Реализация библиотеки |
| 085 | [Currying](085_currying_comparision.md) | 218 / 13 | 181 / 8 | 190 / 9 | Использование библиотеки |
| 099 | [Integer partial-application implementation](099_integer_partial_application_implementation_comparision.md) | 275 / 18 | 114 / 3 | 97 / 4 | Реализация библиотеки |

Haskell даёт естественный контроль для Maybe/Monad и каррирования. Scala сочетает функциональные приёмы с JVM, явным батутом и обычным управлением ресурсами. Эти языки выбраны за подходящие механизмы, а не для универсального рейтинга краткости.

[Методика](../COMPARISON_METHODOLOGY.ru.md). [Проверка](../VALIDATION.md).

Суммарный рейтинг языков по разным группам не строится: состав языков, внешние библиотеки и класс задачи различаются.
