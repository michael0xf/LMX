# UDUNITS-2 2.2.28: включение отложено

**Решение 2026-11-25: не включать в SOURCES/корневой CMake этой сборки.** UDUNITS полезен как библиотека арифметики физических единиц, преобразования значений и временных origins; его XML — реальная база единиц, а не конфигурация LMX. Лицензия UCAR permissive с patent-termination clause; основание отсрочки — проверенное различие error recovery генераторов.

В tag v2.2.28 нет готовых `parser.c/scanner.c`. Попытка сохранить C99 inputs без Bison skeleton использовала public-domain **byacc 2.0 20260126** и **Flex 2.6.4**. Из рабочей копии grammar удалён устаревший блок из 35 ручных `yy*`-переименований: byacc `-p ut` сам переименовывает свои таблицы. Generated parser/scanner вместе занимают около 150 KB. Linux `dladdr` адаптирован в отдельном build view: адрес статического объекта того же модуля вместо function pointer, чтобы пройти `-pedantic-errors`. Никакого абсолютного scratch-пути к базе в config не задано.

Сборка C99 `-Os -DNDEBUG -pedantic-errors` прошла, `.a` — **182 612 байт**. Явно переданная исходная база из шести XML загрузилась. Прошли 14 корректных conversion vectors: скорость, температура, составные единицы, Unicode exponent, даты, часовой пояс и leap day.

**Ошибка:** `ut_parse(system, "m // s", UT_ASCII)` с byacc parser вызывает повторное освобождение unit в правиле `product_exp DIVIDE error` (`parser.y`, action с `ut_free($1); YYERROR;`). Release-проверка завершается SIGSEGV. ASan обнаруживает heap-use-after-free в `ut_free`, повторно вызванном из этого error action. Проверку ошибочного ввода не удаляли.

Контрольное сравнение использовало неизменённую upstream grammar и **Bison только в scratch**, с теми же остальными объектами UDUNITS и Expat. Этот вариант проходит те же корректные векторы и malformed-input check под AddressSanitizer/UBSan. LeakSanitizer в среде выдаёт собственную ошибку ptrace; контрольный запуск выполнен с `ASAN_OPTIONS=detect_leaks=0`, поэтому проверки утечек не заявляются. Оба генератора сообщают 3 shift/reduce и 9 reduce/reduce conflicts. Это не доказательство общего дефекта UDUNITS: наблюдаемая авария относится к данному переносу на byacc.

## Условие будущего включения

Экспериментальная адаптация и исходники UDUNITS не входят в эту поставку:
это краткая запись проверенного решения об отсрочке, а не инструкция запуска
отсутствующего target. Ссылки ниже позволяют получить исходную версию.
Перед включением нужен проверенный перенос error recovery с набором
некорректных выражений или другая приемлемая стратегия генерации.
Минимальный регрессионный пример — разбор `"m // s"` после загрузки базы
единиц. Корректный результат — штатная ошибка разбора без повторного
освобождения памяти. Единичное исправление аварии не заменяет проверки
совместимости грамматики и генератора.

Источники:

- <https://github.com/Unidata/UDUNITS-2/tree/v2.2.28>
- <https://www.unidata.ucar.edu/software/udunits>
- <https://invisible-island.net/byacc/> — public-domain статус генератора и generated programs.
- <https://invisible-island.net/archives/byacc/byacc-20260126.tgz>
- <https://github.com/westes/flex/blob/v2.6.4/COPYING> — условия scanner skeleton.
- <https://github.com/Unidata/UDUNITS-2/issues/159> — upstream grammar conflicts.
- <https://github.com/Unidata/UDUNITS-2/issues/157> — другие наблюдения о некорректном вводе и статусе parser.
