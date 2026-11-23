# Статистика всей директории examples

Редакция **2026-11-23**. Подсчёт строится из текущих исходников, а не прежних PDF или таблиц.

## Сопоставимые наборы

| Набор | Сценариев LMX | Полных пар | Поясняющих аналогий | Только LMX | LMX в полных парах | без сложного Throws | Контроль в полных парах | Контроль / LMX |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Haskell | 24 | 6 | 6 | 12 | 1195 | 1124 | 1206 | 1.009 |
| Julia | 24 | 24 | 0 | 0 | 3259 | 2721 | 1244 | 0.382 |
| Perl | 24 | 24 | 0 | 0 | 5097 | 4258 | 3073 | 0.603 |
| Common Lisp (SBCL) | 24 | 23 | 1 | 0 | 4146 | 4095 | 3147 | 0.759 |

Директория содержит 96 сценария LMX. Существующие 24 исходника сохранены. Отдельные наборы подобраны под характерные задачи Julia, Perl и Common Lisp/SBCL. Их разные составы не дают основания строить общий рейтинг языков. Неполная аналогия не считается нулевым размером другого языка и не участвует в отношениях.

## Основные листинги

| Набор / ID | Сценарий | Статус | LMX: символы / строки | без сложного Throws | Контроль: символы / строки | Контроль / LMX |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| [haskell / H01](lmx/H01.lm3) | Replace and invoke a first-class callable | Полная пара | 191 / 14 | 191 | 303 / 11 | 1.586 |
| [haskell / H02](lmx/H02.lm3) | Named signature positions versus candidate names | Только LMX | 215 / 12 | 215 | — | — |
| [haskell / H03](lmx/H03.lm3) | Independent bound prefixes and residual callable admission | Полная пара | 297 / 21 | 226 | 143 / 7 | 0.481 |
| [haskell / H04](lmx/H04.lm3) | Overrideable copied default | Полная пара | 205 / 13 | 205 | 128 / 3 | 0.624 |
| [haskell / H05](lmx/H05.lm3) | Dynamic and lexical binding after a graph copy | Поясняющая аналогия | 218 / 18 | 218 | — | — |
| [haskell / H06](lmx/H06.lm3) | Order of two composed computations | Полная пара | 167 / 11 | 167 | 89 / 2 | 0.533 |
| [haskell / H07](lmx/H07.lm3) | Prepared value versus raw source occurrence | Поясняющая аналогия | 354 / 22 | 354 | — | — |
| [haskell / H08](lmx/H08.lm3) | Owned formal copy versus caller place | Только LMX | 94 / 14 | 94 | — | — |
| [haskell / H09](lmx/H09.lm3) | Finite iterator with a live declaration and body | Поясняющая аналогия | 285 / 25 | 285 | — | — |
| [haskell / R01](lmx/R01.lm3) | Merge an existing record and add a field | Поясняющая аналогия | 183 / 11 | 183 | — | — |
| [haskell / R02](lmx/R02.lm3) | Copy a field stream into group assignment | Только LMX | 95 / 10 | 95 | — | — |
| [haskell / R03](lmx/R03.lm3) | Imported parent identity versus copied parent identity | Только LMX | 226 / 15 | 226 | — | — |
| [haskell / R04](lmx/R04.lm3) | Computed initializer, local write and repeated activation | Только LMX | 383 / 26 | 383 | — | — |
| [haskell / R06a](lmx/R06a.lm3) | Graph copy preserving shared targets | Только LMX | 189 / 11 | 189 | — | — |
| [haskell / R06b](lmx/R06b.lm3) | Graph copy preserving a cycle | Только LMX | 139 / 10 | 139 | — | — |
| [haskell / R07](lmx/R07.lm3) | User operand and preserved computation | Поясняющая аналогия | 159 / 12 | 159 | — | — |
| [haskell / R09](lmx/R09.lm3) | Uninitialized payload and local versus graph write | Только LMX | 189 / 13 | 189 | — | — |
| [haskell / A01](lmx/A01.lm3) | Shared structural slots and replacement field identity | Только LMX | 126 / 11 | 126 | — | — |
| [haskell / V02](lmx/V02.lm3) | Whole ASCII ticket-code predicate | Полная пара | 242 / 10 | 242 | 132 / 6 | 0.545 |
| [haskell / V03](lmx/V03.lm3) | Inject a read dependency and check interaction counts | Поясняющая аналогия | 298 / 23 | 298 | — | — |
| [haskell / V04](lmx/V04.lm3) | Distinguish a named failure from a numeric result | Только LMX | 160 / 15 | 160 | — | — |
| [haskell / V05](lmx/V05.lm3) | Command/read integration check and fault modes | Только LMX | 547 / 39 | 547 | — | — |
| [haskell / M01](lmx/M01.lm3) | Serial state updates at one Message owner | Полная пара | 93 / 9 | 93 | 411 / 15 | 4.419 |
| [haskell / M05](lmx/M05.lm3) | Void Message procedure without a fabricated reply | Только LMX | 49 / 5 | 49 | — | — |
| [julia / J01](julia_comparison/source/lmx/J01.lm3) | Полуоткрытый диапазон с направлением | Полная пара | 131 / 8 | 96 | 109 / 3 | 0.832 |
| [julia / J02](julia_comparison/source/lmx/J02.lm3) | Копия среза | Полная пара | 88 / 8 | 88 | 90 / 4 | 1.023 |
| [julia / J03](julia_comparison/source/lmx/J03.lm3) | Разворот без изменения входа | Полная пара | 72 / 6 | 72 | 23 / 1 | 0.319 |
| [julia / J04](julia_comparison/source/lmx/J04.lm3) | Отбор по числовой маске | Полная пара | 138 / 7 | 80 | 97 / 4 | 0.703 |
| [julia / J05](julia_comparison/source/lmx/J05.lm3) | Квадраты через comprehension | Полная пара | 40 / 5 | 40 | 25 / 1 | 0.625 |
| [julia / J06](julia_comparison/source/lmx/J06.lm3) | Стабильный отбор нечётных | Полная пара | 92 / 6 | 85 | 28 / 1 | 0.304 |
| [julia / J07](julia_comparison/source/lmx/J07.lm3) | Левая свёртка с неассоциативным шагом | Полная пара | 220 / 13 | 168 | 38 / 1 | 0.173 |
| [julia / J08](julia_comparison/source/lmx/J08.lm3) | Все промежуточные суммы с начальным значением | Полная пара | 209 / 13 | 145 | 50 / 1 | 0.239 |
| [julia / J09](julia_comparison/source/lmx/J09.lm3) | Парное прохождение до короткого входа | Полная пара | 85 / 7 | 85 | 44 / 1 | 0.518 |
| [julia / J10](julia_comparison/source/lmx/J10.lm3) | Слитное поэлементное выражение | Полная пара | 66 / 6 | 66 | 41 / 1 | 0.621 |
| [julia / J11](julia_comparison/source/lmx/J11.lm3) | Плоское разворачивание результатов | Полная пара | 132 / 11 | 132 | 53 / 1 | 0.402 |
| [julia / J12](julia_comparison/source/lmx/J12.lm3) | Группировка по чётности | Полная пара | 256 / 17 | 190 | 55 / 2 | 0.215 |
| [julia / J13](julia_comparison/source/lmx/J13.lm3) | Хотя бы одно превышение | Полная пара | 149 / 12 | 149 | 36 / 1 | 0.242 |
| [julia / J14](julia_comparison/source/lmx/J14.lm3) | Все значения положительны | Полная пара | 142 / 11 | 142 | 26 / 1 | 0.183 |
| [julia / J15](julia_comparison/source/lmx/J15.lm3) | Первый найденный индекс без sentinel | Полная пара | 201 / 12 | 138 | 90 / 4 | 0.448 |
| [julia / J16](julia_comparison/source/lmx/J16.lm3) | Количество чётных элементов | Полная пара | 53 / 5 | 53 | 28 / 1 | 0.528 |
| [julia / J17](julia_comparison/source/lmx/J17.lm3) | Дополнение существующего массива | Полная пара | 94 / 7 | 94 | 45 / 1 | 0.479 |
| [julia / J18](julia_comparison/source/lmx/J18.lm3) | Splice с возвратом удалённых элементов | Полная пара | 112 / 9 | 112 | 128 / 4 | 1.143 |
| [julia / J19](julia_comparison/source/lmx/J19.lm3) | Транспонирование прямоугольной матрицы | Полная пара | 113 / 6 | 70 | 35 / 1 | 0.310 |
| [julia / J20](julia_comparison/source/lmx/J20.lm3) | Устойчивая сортировка записей | Полная пара | 236 / 12 | 170 | 44 / 1 | 0.186 |
| [julia / J21](julia_comparison/source/lmx/J21.lm3) | Первые уникальные значения | Полная пара | 208 / 12 | 131 | 22 / 1 | 0.106 |
| [julia / J22](julia_comparison/source/lmx/J22.lm3) | Цифры в ASCII-строке | Полная пара | 119 / 6 | 112 | 41 / 1 | 0.345 |
| [julia / J23](julia_comparison/source/lmx/J23.lm3) | Объединение частей на один уровень | Полная пара | 77 / 6 | 77 | 48 / 1 | 0.623 |
| [julia / J24](julia_comparison/source/lmx/J24.lm3) | Декартово произведение через вложенные comprehensions | Полная пара | 226 / 20 | 226 | 48 / 1 | 0.212 |
| [perl / P01](perl_comparison/source/lmx/P01.lm3) | Преобразование целого списка | Полная пара | 45 / 5 | 45 | 73 / 6 | 1.622 |
| [perl / P02](perl_comparison/source/lmx/P02.lm3) | Отбор элементов через grep | Полная пара | 100 / 6 | 93 | 77 / 6 | 0.770 |
| [perl / P03](perl_comparison/source/lmx/P03.lm3) | Сумма с нейтральным значением | Полная пара | 55 / 5 | 55 | 90 / 7 | 1.636 |
| [perl / P04](perl_comparison/source/lmx/P04.lm3) | Все промежуточные остатки счёта | Полная пара | 225 / 13 | 161 | 129 / 7 | 0.573 |
| [perl / P05](perl_comparison/source/lmx/P05.lm3) | Короткое замыкание any и all | Полная пара | 213 / 14 | 213 | 123 / 7 | 0.577 |
| [perl / P06](perl_comparison/source/lmx/P06.lm3) | Срез с перестановкой и повторением | Полная пара | 130 / 7 | 94 | 88 / 6 | 0.677 |
| [perl / P07](perl_comparison/source/lmx/P07.lm3) | Изменение массива с возвратом удалённых | Полная пара | 185 / 10 | 134 | 146 / 7 | 0.789 |
| [perl / P08](perl_comparison/source/lmx/P08.lm3) | Стабильная сортировка записей | Полная пара | 256 / 12 | 190 | 117 / 7 | 0.457 |
| [perl / P09](perl_comparison/source/lmx/P09.lm3) | Уникальные значения в порядке появления | Полная пара | 216 / 12 | 139 | 90 / 7 | 0.417 |
| [perl / P10](perl_comparison/source/lmx/P10.lm3) | Частотная таблица с порядком первых вхождений | Полная пара | 269 / 17 | 254 | 166 / 11 | 0.617 |
| [perl / P11](perl_comparison/source/lmx/P11.lm3) | Автовивификация групп записей | Полная пара | 296 / 22 | 281 | 218 / 12 | 0.736 |
| [perl / P12](perl_comparison/source/lmx/P12.lm3) | Наложение настроек с сохранением полей | Полная пара | 58 / 6 | 58 | 77 / 6 | 1.328 |
| [perl / P13](perl_comparison/source/lmx/P13.lm3) | Map с выдачей нескольких элементов | Полная пара | 75 / 6 | 75 | 70 / 6 | 0.933 |
| [perl / P14](perl_comparison/source/lmx/P14.lm3) | Разделение строки без потери пустых полей | Полная пара | 166 / 6 | 85 | 92 / 6 | 0.554 |
| [perl / P15](perl_comparison/source/lmx/P15.lm3) | Проверка полного ASCII-идентификатора | Полная пара | 203 / 6 | 122 | 92 / 6 | 0.453 |
| [perl / P16](perl_comparison/source/lmx/P16.lm3) | Именованные группы с явным отсутствием | Полная пара | 396 / 11 | 315 | 144 / 7 | 0.364 |
| [perl / P17](perl_comparison/source/lmx/P17.lm3) | Глобальное извлечение слов | Полная пара | 193 / 6 | 148 | 75 / 6 | 0.389 |
| [perl / P18](perl_comparison/source/lmx/P18.lm3) | Буквальная замена всех совпадений | Полная пара | 219 / 8 | 138 | 115 / 6 | 0.525 |
| [perl / P19](perl_comparison/source/lmx/P19.lm3) | Вычисляемая замена с сохранением ширины | Полная пара | 287 / 12 | 242 | 88 / 6 | 0.307 |
| [perl / P20](perl_comparison/source/lmx/P20.lm3) | Обратная ссылка на одинаковое слово | Полная пара | 226 / 6 | 145 | 97 / 6 | 0.429 |
| [perl / P21](perl_comparison/source/lmx/P21.lm3) | Транслитерация алфавита ДНК | Полная пара | 102 / 6 | 102 | 75 / 6 | 0.735 |
| [perl / P22](perl_comparison/source/lmx/P22.lm3) | Независимые замыкания со своим счётчиком | Полная пара | 290 / 16 | 290 | 224 / 12 | 0.772 |
| [perl / P23](perl_comparison/source/lmx/P23.lm3) | Ленивый итератор, в котором ноль не означает конец | Полная пара | 263 / 19 | 250 | 242 / 16 | 0.920 |
| [perl / P24](perl_comparison/source/lmx/P24.lm3) | Освобождение ресурса при успехе и исключении | Полная пара | 629 / 46 | 629 | 365 / 18 | 0.580 |
| [sbcl / S01](SBCL_comparison/source/lmx/S01.lm3) | MAPCAR: преобразование списка | Полная пара | 49 / 5 | 49 | 50 / 2 | 1.020 |
| [sbcl / S02](SBCL_comparison/source/lmx/S02.lm3) | REMOVE-IF-NOT: устойчивый отбор | Полная пара | 98 / 6 | 91 | 48 / 2 | 0.490 |
| [sbcl / S03](SBCL_comparison/source/lmx/S03.lm3) | REDUCE: левая свёртка | Полная пара | 102 / 10 | 102 | 53 / 2 | 0.520 |
| [sbcl / S04](SBCL_comparison/source/lmx/S04.lm3) | MAPCAR по двум спискам | Полная пара | 174 / 12 | 174 | 45 / 2 | 0.259 |
| [sbcl / S05](SBCL_comparison/source/lmx/S05.lm3) | SOME и EVERY: короткое замыкание | Полная пара | 218 / 16 | 218 | 211 / 5 | 0.968 |
| [sbcl / S06](SBCL_comparison/source/lmx/S06.lm3) | POSITION-IF: первый подходящий индекс | Полная пара | 94 / 10 | 94 | 53 / 2 | 0.564 |
| [sbcl / S07](SBCL_comparison/source/lmx/S07.lm3) | STABLE-SORT: ключ и устойчивость | Полная пара | 188 / 14 | 175 | 64 / 2 | 0.340 |
| [sbcl / S08](SBCL_comparison/source/lmx/S08.lm3) | REMOVE-DUPLICATES: сохранить первые | Полная пара | 175 / 12 | 151 | 63 / 2 | 0.360 |
| [sbcl / S09](SBCL_comparison/source/lmx/S09.lm3) | REPLACE: ограниченный диапазон | Полная пара | 168 / 10 | 168 | 96 / 2 | 0.571 |
| [sbcl / S10](SBCL_comparison/source/lmx/S10.lm3) | Замыкание add5 | Полная пара | 170 / 13 | 170 | 119 / 5 | 0.700 |
| [sbcl / S11](SBCL_comparison/source/lmx/S11.lm3) | APPLY: сумма аргументов из списка | Полная пара | 55 / 5 | 55 | 36 / 2 | 0.655 |
| [sbcl / S12](SBCL_comparison/source/lmx/S12.lm3) | Ключевые аргументы и значение по умолчанию | Полная пара | 170 / 12 | 170 | 128 / 5 | 0.753 |
| [sbcl / S13](SBCL_comparison/source/lmx/S13.lm3) | Динамическая переменная SPECIAL | Полная пара | 198 / 17 | 198 | 153 / 6 | 0.773 |
| [sbcl / S14](SBCL_comparison/source/lmx/S14.lm3) | LABELS: локальная рекурсия | Полная пара | 125 / 13 | 125 | 71 / 4 | 0.568 |
| [sbcl / S15](SBCL_comparison/source/lmx/S15.lm3) | Несколько возвращаемых значений | Полная пара | 98 / 7 | 98 | 60 / 2 | 0.612 |
| [sbcl / S16](SBCL_comparison/source/lmx/S16.lm3) | DESTRUCTURING-BIND: вложенная форма | Полная пара | 75 / 6 | 75 | 60 / 3 | 0.800 |
| [sbcl / S17](SBCL_comparison/source/lmx/S17.lm3) | LOOP: условное накопление | Полная пара | 129 / 7 | 122 | 57 / 2 | 0.442 |
| [sbcl / S18](SBCL_comparison/source/lmx/S18.lm3) | CLOS: общий вызов для разных объектов | Полная пара | 371 / 25 | 371 | 389 / 13 | 1.049 |
| [sbcl / S19](SBCL_comparison/source/lmx/S19.lm3) | CLOS: изменяемый слот и сохранение полей | Полная пара | 306 / 18 | 306 | 281 / 7 | 0.918 |
| [sbcl / S20](SBCL_comparison/source/lmx/S20.lm3) | Макрос: вычислить форму ровно один раз | Полная пара | 139 / 12 | 139 | 169 / 6 | 1.216 |
| [sbcl / S21](SBCL_comparison/source/lmx/S21.lm3) | Условие и HANDLER-CASE | Полная пара | 187 / 15 | 187 | 178 / 7 | 0.952 |
| [sbcl / S22](SBCL_comparison/source/lmx/S22.lm3) | UNWIND-PROTECT: полный жизненный цикл | Полная пара | 489 / 31 | 489 | 532 / 19 | 1.088 |
| [sbcl / S23](SBCL_comparison/source/lmx/S23.lm3) | Мемоизация через HASH-TABLE | Полная пара | 368 / 28 | 368 | 231 / 8 | 0.628 |
| [sbcl / S24](SBCL_comparison/source/lmx/S24.lm3) | SBCL: очередь сообщений и отдельный поток | Поясняющая аналогия | 432 / 38 | 432 | 251 / 8 | — |

## Сравнения реализаций

Эти размеры не прибавляются к каждому клиенту. Общие зависимости LMX могут встречаться в нескольких замыканиях; складывать строки этой таблицы как размер одного приложения нельзя. Клиенты контрольных языков не импортируют сравнительные модули.

| Набор / ID | Операции | LMX: символы / строки | без сложного Throws | Контроль: символы / строки |
| --- | --- | ---: | ---: | ---: |
| julia / JI01 | Упорядоченные обходы, предикаты и свёртки | 5123 / 263 | 5021 | 2758 / 125 |
| julia / JI02 | Границы, маски и устройство массивов | 4233 / 191 | 4097 | 2529 / 114 |
| julia / JI03 | Изменение диапазона с сохранением target | 2522 / 88 | 2522 | 1230 / 50 |
| julia / JI04 | Сортировка, уникальность и группировка | 2676 / 134 | 2467 | 1614 / 86 |
| perl / PI01 | Общие последовательные коллекции | 2966 / 146 | 2927 | 1387 / 85 |
| perl / PI02 | Срез и изменение диапазона | 3713 / 144 | 3713 | 1168 / 50 |
| perl / PI03 | Стабильная сортировка и unique | 1894 / 97 | 1751 | 1174 / 55 |
| perl / PI04 | Группировка с произвольным ключом | 782 / 37 | 716 | 568 / 26 |
| perl / PI05 | Композиция записей и копирование data-графа | 71 / 6 | 71 | 1002 / 44 |
| perl / PI06 | Полный синхронный bracket | 316 / 16 | 316 | 454 / 23 |
| perl / PI07 | Построение шаблонов и операции над regex-движком | 9969 / 414 | 9813 | 3999 / 168 |
| sbcl / SI01 | Обходы, фильтрация и свёртка | 2483 / 115 | 2386 | 1503 / 47 |
| sbcl / SI02 | Короткие предикаты, первый индекс и запись значения | 1402 / 78 | 1339 | 674 / 24 |
| sbcl / SI03 | Устойчивая сортировка и первые уникальные элементы | 1894 / 97 | 1751 | 1218 / 43 |
| sbcl / SI04 | Замена диапазона и сохранение target | 1729 / 58 | 1729 | 1262 / 38 |
| sbcl / SI05 | Частичное применение произвольной конечной функции | 533 / 17 | 533 | 454 / 13 |
| sbcl / SI06 | Мемоизация с явным равенством полного ключа | 1211 / 48 | 1211 | 508 / 15 |
| haskell / H01 | apply | 1906 / 152 | 1027 | 79 / 3 |
| haskell / H03 | partial | 14935 / 742 | 13843 | 699 / 17 |
| haskell / H06 | pipe, compose | 14161 / 721 | 13133 | 389 / 15 |
| haskell / H07 | lazy, once | 13847 / 702 | 12782 | 1309 / 35 |
| haskell / H09 | Cycles\iterate | 73 / 9 | 73 | 644 / 19 |
| haskell / V02 | between | 185 / 9 | 185 | 315 / 6 |
| haskell / R01 | derive / record composition | 71 / 6 | 71 | 108 / 3 |

## Метод и воспроизведение

На мой взгляд, явные Throws — преимущество LMX: предельно ясно, какие ошибки может породить метод. Общий список и `throws: copy(Throws)` сохраняют точный контракт без повторения деклараций. Сокращать эти записи ради размера не хочется.

Колонка **«без сложного Throws»** сохраняет заголовок и первый написанный аргумент каждого списка, а также все ссылки `copy(...)`. Только аргументы после первого исключаются из дополнительного подсчёта. Сам список тоже учитывается, один раз в его исходной границе кода. Исходники не меняются; основные отношения размеров считаются по полному коду.

Основная метрика — непробельные Unicode-символы, включая комментарии внутри явно выбранного листинга; вторая — непустые строки. Переводы строк нормализуются в LF, внешние пустые строки удаляются, добавляется один завершающий LF. JSON дополнительно хранит символы с пробелами, UTF-8-байты и SHA-256. Тестовый harness не маскируется под часть предметной реализации.

Отношение равно размеру контрольного листинга, делённому на размер LMX; отношение сумм считается по одним и тем же полным парам. Это метрика кода, не скорости, памяти или качества языка.

Библиотечные операции LMX входят непосредственно в ядро; отдельные реализации сравниваются по явно указанному общему договору. Полные альтернативы сохраняются только при другом подходе. Код, убирающий обязательные эффекты, поля или проверки, не выбирается ради краткости.

Исходные наборы: [Haskell coverage](haskell/comparison_index.json), [Julia](julia_comparison/examples.json), [Perl](perl_comparison/examples.json), [SBCL](SBCL_comparison/examples.json). Артефакты: [JSON](STATISTICS.json), [CSV](STATISTICS.csv), [XLSX](STATISTICS.xlsx), [PDF](STATISTICS.pdf), [реестр всех исходников](SOURCE_INVENTORY.json).

Команды из корня spec: `python3 patterns/examples/tools/refresh_examples_statistics.py`, затем генераторы `refresh_examples_pdfs.py` и `refresh_examples_workbooks.mjs` из той же директории. Для XLSX требуется `@oai/artifact-tool`; путь к примерам задаётся LMX_EXAMPLES_ROOT.

Source and publication metrics only. LMX runtime is absent. Foreign execution receipts, where available, are stored in suite validation.
