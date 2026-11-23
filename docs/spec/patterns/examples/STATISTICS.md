# Статистика всей директории examples

Редакция **2026-11-23**. Подсчёт строится из текущих исходников, а не прежних PDF или таблиц.

## Сопоставимые наборы

| Набор | Сценариев LMX | Полных пар | Поясняющих аналогий | Только LMX | LMX в полных парах | Контроль в полных парах | Контроль / LMX |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Haskell | 24 | 6 | 6 | 12 | 1331 | 1206 | 0.906 |
| Julia | 24 | 24 | 0 | 0 | 3648 | 1244 | 0.341 |
| Perl | 24 | 24 | 0 | 0 | 6490 | 3073 | 0.473 |

Директория содержит 72 сценария LMX. Существующие 24 исходника сохранены. Два новых набора подобраны под характерные задачи Julia и Perl. Их разные составы не дают основания строить общий рейтинг языков. Неполная аналогия не считается нулевым размером другого языка и не участвует в отношениях.

## Основные листинги

| Набор / ID | Сценарий | Статус | LMX: символы / строки | Контроль: символы / строки | Контроль / LMX |
| --- | --- | --- | ---: | ---: | ---: |
| [haskell / H01](lmx/H01.lm3) | Replace and invoke a first-class callable | Полная пара | 207 / 15 | 303 / 11 | 1.464 |
| [haskell / H02](lmx/H02.lm3) | Named signature positions versus candidate names | Только LMX | 271 / 14 | — | — |
| [haskell / H03](lmx/H03.lm3) | Independent bound prefixes and residual callable admission | Полная пара | 341 / 24 | 143 / 7 | 0.419 |
| [haskell / H04](lmx/H04.lm3) | Overrideable copied default | Полная пара | 265 / 18 | 128 / 3 | 0.483 |
| [haskell / H05](lmx/H05.lm3) | Dynamic and lexical binding after a graph copy | Поясняющая аналогия | 218 / 18 | — | — |
| [haskell / H06](lmx/H06.lm3) | Order of two composed computations | Полная пара | 179 / 13 | 89 / 2 | 0.497 |
| [haskell / H07](lmx/H07.lm3) | Prepared value versus raw source occurrence | Поясняющая аналогия | 461 / 30 | — | — |
| [haskell / H08](lmx/H08.lm3) | Owned formal copy versus caller place | Только LMX | 122 / 17 | — | — |
| [haskell / H09](lmx/H09.lm3) | Finite iterator with a live declaration and body | Поясняющая аналогия | 260 / 17 | — | — |
| [haskell / R01](lmx/R01.lm3) | Merge an existing record and add a field | Поясняющая аналогия | 183 / 11 | — | — |
| [haskell / R02](lmx/R02.lm3) | Copy a field stream into group assignment | Только LMX | 95 / 10 | — | — |
| [haskell / R03](lmx/R03.lm3) | Imported parent identity versus copied parent identity | Только LMX | 244 / 16 | — | — |
| [haskell / R04](lmx/R04.lm3) | Computed initializer, local write and repeated activation | Только LMX | 383 / 26 | — | — |
| [haskell / R06a](lmx/R06a.lm3) | Graph copy preserving shared targets | Только LMX | 189 / 11 | — | — |
| [haskell / R06b](lmx/R06b.lm3) | Graph copy preserving a cycle | Только LMX | 139 / 10 | — | — |
| [haskell / R07](lmx/R07.lm3) | User operand and preserved computation | Поясняющая аналогия | 159 / 12 | — | — |
| [haskell / R09](lmx/R09.lm3) | Uninitialized payload and local versus graph write | Только LMX | 189 / 13 | — | — |
| [haskell / A01](lmx/A01.lm3) | Shared structural slots and replacement field identity | Только LMX | 126 / 11 | — | — |
| [haskell / V02](lmx/V02.lm3) | Whole ASCII ticket-code predicate | Полная пара | 242 / 10 | 132 / 6 | 0.545 |
| [haskell / V03](lmx/V03.lm3) | Inject a read dependency and check interaction counts | Поясняющая аналогия | 298 / 23 | — | — |
| [haskell / V04](lmx/V04.lm3) | Distinguish a named failure from a numeric result | Только LMX | 160 / 15 | — | — |
| [haskell / V05](lmx/V05.lm3) | Command/read integration check and fault modes | Только LMX | 552 / 33 | — | — |
| [haskell / M01](lmx/M01.lm3) | Serial state updates at one Message owner | Полная пара | 97 / 9 | 411 / 15 | 4.237 |
| [haskell / M05](lmx/M05.lm3) | Void Message procedure without a fabricated reply | Только LMX | 49 / 5 | — | — |
| [julia / J01](julia_comparison/source/lmx/J01.lm3) | Полуоткрытый диапазон с направлением | Полная пара | 131 / 8 | 109 / 3 | 0.832 |
| [julia / J02](julia_comparison/source/lmx/J02.lm3) | Копия среза | Полная пара | 88 / 8 | 90 / 4 | 1.023 |
| [julia / J03](julia_comparison/source/lmx/J03.lm3) | Разворот без изменения входа | Полная пара | 72 / 6 | 23 / 1 | 0.319 |
| [julia / J04](julia_comparison/source/lmx/J04.lm3) | Отбор по числовой маске | Полная пара | 138 / 7 | 97 / 4 | 0.703 |
| [julia / J05](julia_comparison/source/lmx/J05.lm3) | Квадраты через comprehension | Полная пара | 138 / 11 | 25 / 1 | 0.181 |
| [julia / J06](julia_comparison/source/lmx/J06.lm3) | Стабильный отбор нечётных | Полная пара | 136 / 11 | 28 / 1 | 0.206 |
| [julia / J07](julia_comparison/source/lmx/J07.lm3) | Левая свёртка с неассоциативным шагом | Полная пара | 220 / 13 | 38 / 1 | 0.173 |
| [julia / J08](julia_comparison/source/lmx/J08.lm3) | Все промежуточные суммы с начальным значением | Полная пара | 209 / 13 | 50 / 1 | 0.239 |
| [julia / J09](julia_comparison/source/lmx/J09.lm3) | Парное прохождение до короткого входа | Полная пара | 85 / 7 | 44 / 1 | 0.518 |
| [julia / J10](julia_comparison/source/lmx/J10.lm3) | Слитное поэлементное выражение | Полная пара | 164 / 13 | 41 / 1 | 0.250 |
| [julia / J11](julia_comparison/source/lmx/J11.lm3) | Плоское разворачивание результатов | Полная пара | 132 / 11 | 53 / 1 | 0.402 |
| [julia / J12](julia_comparison/source/lmx/J12.lm3) | Группировка по чётности | Полная пара | 256 / 17 | 55 / 2 | 0.215 |
| [julia / J13](julia_comparison/source/lmx/J13.lm3) | Хотя бы одно превышение | Полная пара | 149 / 12 | 36 / 1 | 0.242 |
| [julia / J14](julia_comparison/source/lmx/J14.lm3) | Все значения положительны | Полная пара | 142 / 11 | 26 / 1 | 0.183 |
| [julia / J15](julia_comparison/source/lmx/J15.lm3) | Первый найденный индекс без sentinel | Полная пара | 201 / 12 | 90 / 4 | 0.448 |
| [julia / J16](julia_comparison/source/lmx/J16.lm3) | Количество выполнений предиката | Полная пара | 138 / 11 | 28 / 1 | 0.203 |
| [julia / J17](julia_comparison/source/lmx/J17.lm3) | Дополнение существующего массива | Полная пара | 94 / 7 | 45 / 1 | 0.479 |
| [julia / J18](julia_comparison/source/lmx/J18.lm3) | Splice с возвратом удалённых элементов | Полная пара | 112 / 9 | 128 / 4 | 1.143 |
| [julia / J19](julia_comparison/source/lmx/J19.lm3) | Транспонирование прямоугольной матрицы | Полная пара | 113 / 6 | 35 / 1 | 0.310 |
| [julia / J20](julia_comparison/source/lmx/J20.lm3) | Устойчивая сортировка записей | Полная пара | 255 / 16 | 44 / 1 | 0.173 |
| [julia / J21](julia_comparison/source/lmx/J21.lm3) | Первые уникальные значения | Полная пара | 208 / 12 | 22 / 1 | 0.106 |
| [julia / J22](julia_comparison/source/lmx/J22.lm3) | Цифры в ASCII-строке | Полная пара | 164 / 11 | 41 / 1 | 0.250 |
| [julia / J23](julia_comparison/source/lmx/J23.lm3) | Объединение частей на один уровень | Полная пара | 77 / 6 | 48 / 1 | 0.623 |
| [julia / J24](julia_comparison/source/lmx/J24.lm3) | Декартово произведение через вложенные comprehensions | Полная пара | 226 / 20 | 48 / 1 | 0.212 |
| [perl / P01](perl_comparison/source/lmx/P01.lm3) | Преобразование списка через map | Полная пара | 172 / 11 | 73 / 6 | 0.424 |
| [perl / P02](perl_comparison/source/lmx/P02.lm3) | Отбор элементов через grep | Полная пара | 175 / 11 | 77 / 6 | 0.440 |
| [perl / P03](perl_comparison/source/lmx/P03.lm3) | Сумма с нейтральным значением | Полная пара | 197 / 12 | 90 / 7 | 0.457 |
| [perl / P04](perl_comparison/source/lmx/P04.lm3) | Все промежуточные остатки счёта | Полная пара | 225 / 13 | 129 / 7 | 0.573 |
| [perl / P05](perl_comparison/source/lmx/P05.lm3) | Короткое замыкание any и all | Полная пара | 250 / 16 | 123 / 7 | 0.492 |
| [perl / P06](perl_comparison/source/lmx/P06.lm3) | Срез с перестановкой и повторением | Полная пара | 130 / 7 | 88 / 6 | 0.677 |
| [perl / P07](perl_comparison/source/lmx/P07.lm3) | Изменение массива с возвратом удалённых | Полная пара | 185 / 10 | 146 / 7 | 0.789 |
| [perl / P08](perl_comparison/source/lmx/P08.lm3) | Стабильная сортировка записей | Полная пара | 256 / 12 | 117 / 7 | 0.457 |
| [perl / P09](perl_comparison/source/lmx/P09.lm3) | Уникальные значения в порядке появления | Полная пара | 216 / 12 | 90 / 7 | 0.417 |
| [perl / P10](perl_comparison/source/lmx/P10.lm3) | Частотная таблица с порядком первых вхождений | Полная пара | 413 / 25 | 166 / 11 | 0.402 |
| [perl / P11](perl_comparison/source/lmx/P11.lm3) | Автовивификация групп записей | Полная пара | 394 / 25 | 218 / 12 | 0.553 |
| [perl / P12](perl_comparison/source/lmx/P12.lm3) | Наложение настроек с сохранением полей | Полная пара | 58 / 6 | 77 / 6 | 1.328 |
| [perl / P13](perl_comparison/source/lmx/P13.lm3) | Map с выдачей нескольких элементов | Полная пара | 162 / 11 | 70 / 6 | 0.432 |
| [perl / P14](perl_comparison/source/lmx/P14.lm3) | Разделение строки без потери пустых полей | Полная пара | 166 / 6 | 92 / 6 | 0.554 |
| [perl / P15](perl_comparison/source/lmx/P15.lm3) | Проверка полного ASCII-идентификатора | Полная пара | 203 / 6 | 92 / 6 | 0.453 |
| [perl / P16](perl_comparison/source/lmx/P16.lm3) | Именованные группы с явным отсутствием | Полная пара | 396 / 11 | 144 / 7 | 0.364 |
| [perl / P17](perl_comparison/source/lmx/P17.lm3) | Глобальное извлечение слов | Полная пара | 343 / 15 | 75 / 6 | 0.219 |
| [perl / P18](perl_comparison/source/lmx/P18.lm3) | Буквальная замена всех совпадений | Полная пара | 228 / 8 | 115 / 6 | 0.504 |
| [perl / P19](perl_comparison/source/lmx/P19.lm3) | Вычисляемая замена с сохранением ширины | Полная пара | 474 / 19 | 88 / 6 | 0.186 |
| [perl / P20](perl_comparison/source/lmx/P20.lm3) | Обратная ссылка на одинаковое слово | Полная пара | 226 / 6 | 97 / 6 | 0.429 |
| [perl / P21](perl_comparison/source/lmx/P21.lm3) | Транслитерация алфавита ДНК | Полная пара | 219 / 17 | 75 / 6 | 0.342 |
| [perl / P22](perl_comparison/source/lmx/P22.lm3) | Независимые замыкания со своим счётчиком | Полная пара | 365 / 24 | 224 / 12 | 0.614 |
| [perl / P23](perl_comparison/source/lmx/P23.lm3) | Ленивый итератор, в котором ноль не означает конец | Полная пара | 364 / 29 | 242 / 16 | 0.665 |
| [perl / P24](perl_comparison/source/lmx/P24.lm3) | Освобождение ресурса при успехе и исключении | Полная пара | 673 / 40 | 365 / 18 | 0.542 |

## Сравнения реализаций

Эти размеры не прибавляются к каждому клиенту. Общие зависимости LMX могут встречаться в нескольких замыканиях; складывать строки этой таблицы как размер одного приложения нельзя. Клиенты контрольных языков не импортируют сравнительные модули.

| Набор / ID | Операции | LMX: символы / строки | Контроль: символы / строки |
| --- | --- | ---: | ---: |
| julia / JI01 | Упорядоченные обходы, предикаты и свёртки | 5123 / 263 | 2758 / 125 |
| julia / JI02 | Границы, маски и устройство массивов | 4233 / 191 | 2529 / 114 |
| julia / JI03 | Изменение диапазона с сохранением target | 2522 / 88 | 1230 / 50 |
| julia / JI04 | Сортировка, уникальность и группировка | 2676 / 134 | 1614 / 86 |
| perl / PI01 | Общие последовательные коллекции | 2966 / 146 | 1387 / 85 |
| perl / PI02 | Срез и изменение диапазона | 3713 / 144 | 1168 / 50 |
| perl / PI03 | Стабильная сортировка и unique | 1894 / 97 | 1174 / 55 |
| perl / PI04 | Группировка с произвольным ключом | 782 / 37 | 568 / 26 |
| perl / PI05 | Композиция записей и копирование data-графа | 71 / 6 | 1002 / 44 |
| perl / PI06 | Полный синхронный bracket | 526 / 24 | 454 / 23 |
| perl / PI07 | Построение шаблонов и операции над regex-движком | 9969 / 414 | 3999 / 168 |
| haskell / H01 | apply | 1906 / 152 | 79 / 3 |
| haskell / H03 | partial | 11963 / 627 | 699 / 17 |
| haskell / H06 | pipe, compose | 11189 / 606 | 389 / 15 |
| haskell / H07 | lazy, once | 10875 / 587 | 1309 / 35 |
| haskell / H09 | iterateUntilStop | 2008 / 160 | 644 / 19 |
| haskell / V02 | between | 185 / 9 | 315 / 6 |
| haskell / R01 | derive / record composition | 71 / 6 | 108 / 3 |

## Метод и воспроизведение

Основная метрика — непробельные Unicode-символы, включая комментарии внутри явно выбранного листинга; вторая — непустые строки. Переводы строк нормализуются в LF, внешние пустые строки удаляются, добавляется один завершающий LF. JSON дополнительно хранит символы с пробелами, UTF-8-байты и SHA-256. Тестовый harness не маскируется под часть предметной реализации.

Отношение равно размеру контрольного листинга, делённому на размер LMX; отношение сумм считается по одним и тем же полным парам. Это метрика кода, не скорости, памяти или качества языка.

Библиотечные операции LMX входят непосредственно в ядро; отдельные реализации сравниваются по явно указанному общему договору. Полные альтернативы сохраняются только при другом подходе. Код, убирающий обязательные эффекты, поля или проверки, не выбирается ради краткости.

Исходные наборы: [Haskell coverage](haskell/comparison_index.json), [Julia](julia_comparison/examples.json), [Perl](perl_comparison/examples.json). Артефакты: [JSON](STATISTICS.json), [CSV](STATISTICS.csv), [XLSX](STATISTICS.xlsx), [PDF](STATISTICS.pdf), [реестр всех исходников](SOURCE_INVENTORY.json).

Команды из корня spec: `python3 patterns/examples/tools/refresh_examples_statistics.py`, затем генераторы `refresh_examples_pdfs.py` и `refresh_examples_workbooks.mjs` из той же директории. Для XLSX требуется `@oai/artifact-tool`; путь к примерам задаётся LMX_EXAMPLES_ROOT.

Source and publication metrics only. LMX runtime is absent. Foreign execution receipts, where available, are stored in suite validation.
