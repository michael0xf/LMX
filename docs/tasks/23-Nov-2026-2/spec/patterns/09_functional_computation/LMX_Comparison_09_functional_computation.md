# Сравнение: Функциональные вычисления

Редакция 2026-11-23. Контрольные языки: Haskell, Scala. Числа — непробельные символы / непустые строки.

Четыре клиента готовых средств и четыре отдельные реализации. Суммы разных уровней не образуют рейтинг языка. Соседние реализации не импортируются в контрольные клиенты.

| ID | Паттерн | LMX | Haskell | Scala | Граница | Без сложного Throws |
| ---: | --- | ---: | ---: | ---: | --- | ---: |
| 082 | [Monad](082_monad_comparision.md) | 195 / 11 | 125 / 5 | 135 / 5 | Использование библиотеки | 182 |
| 091 | [Maybe container and bind implementation](091_maybe_container_and_bind_implementation_comparision.md) | 390 / 27 | 271 / 10 | 265 / 12 | Реализация библиотеки | 390 |
| 083 | [Trampoline](083_trampoline_comparision.md) | 361 / 25 | 307 / 10 | 265 / 8 | Использование библиотеки | 348 |
| 092 | [Trampoline container and runner implementation](092_trampoline_container_and_runner_implementation_comparision.md) | 591 / 33 | 198 / 9 | 303 / 13 | Реализация библиотеки | 565 |
| 084 | [Execute Around](084_execute_around_comparision.md) | 586 / 45 | 642 / 21 | 521 / 27 | Использование библиотеки | 586 |
| 098 | [Execute Around implementation](098_execute_around_implementation_comparision.md) | 316 / 16 | 390 / 11 | 836 / 36 | Реализация библиотеки | 316 |
| 085 | [Currying](085_currying_comparision.md) | 236 / 15 | 154 / 8 | 198 / 10 | Использование библиотеки | 223 |
| 099 | [General partial-application implementation](099_integer_partial_application_implementation_comparision.md) | 533 / 17 | 699 / 17 | 263 / 7 | Реализация библиотеки | 533 |

[Зависимости](IMPLEMENTATION_DEPENDENCIES.md) · [Выбор](variant_selection.json) · [Ошибки и Message](FAILURE_BOUNDARIES.md) · [Проверка](VALIDATION_2026-11-23.md)
