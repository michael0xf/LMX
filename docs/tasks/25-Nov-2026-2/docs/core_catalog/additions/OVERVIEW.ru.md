# Обзор 20 добавлений

В таблице собраны **10 числовых, 7 текстовых/геометрических/терминальных и 3 сетевых компонента**.
Канонические предлагаемые пакеты взяты из [package_plan.lmx](../package_plan.lmx),
а не из предварительных `proposed_package` отдельных C-модулей. Это размещение
в плане LMX; успешная C99 сборка ещё не означает готовность L3 обёрток.
Машиночитаемая проекция с точными путями доказательств — [summary.json](summary.json).

В колонке исходников указаны байты **полного распакованного upstream дерева →
сохранённого vendor дерева**. Учтены находящиеся в vendor build inputs, notices,
краткие документы и сохранённые test/example sources; общие `extensions/`,
каталог LMX, generated build views и бинарные результаты сюда не включены.
Текущие файлы пересчитаны: все 20 значений совпали с отчётами отбора.

| Компонент — назначение | LMX пакет | Лицензия | Исходники: до → после, байт | Выбранные native артефакты, байт | Проверка |
|---|---|---|---:|---:|---|
| LibBF — Произвольная двоичная точность и математические функции | `number\real` | MIT | 745 314 → 272 725 | 90 992 `.a` | C99 + smoke PASS |
| SoftFloat — Программная IEEE арифметика 16/32/64/80/128 бит | `number\float` | BSD-3-Clause | 1 872 955 → 1 267 905 | 484 220 `.a` | C99 + smoke PASS |
| libfixmath — Fixed-point Q16.16 арифметика | `number\fixed` | MIT | 951 539 → 58 703 | 17 928 `.a` | C99 + smoke PASS |
| libfixmatrix — Fixed-point матрицы, векторы и кватернионы | `math\linear` | MIT | 85 283 → 41 039 | 25 144 `.a` | C99 + smoke PASS |
| FP16 — Конверсия IEEE и ARM alternate half | `number\float` | MIT | 398 275 → 30 158 | 2 498 `.a` | C99 + smoke PASS |
| CMINPACK — Нелинейные уравнения и least squares | `math\fit` | MINPACK permissive¹ | 2 645 003 → 238 165 | 75 222 `.a` | C99 + smoke PASS |
| IMath — Большие целые и точные рациональные числа | `number\bigint` | MIT | 2 271 299 → 127 451 | 52 900 `.a` | C99 + smoke PASS |
| PFFFT — Float/double FFT и fast convolution | `math\transform` | NCAR/UCAR BSD-like¹ | 3 040 759 → 265 510 | 79 692 `.a` | C99 + smoke PASS |
| pcg-c — Псевдослучайные потоки и jump-ahead | `random` | Apache-2.0 / MIT | 565 412 → 134 437 | 50 806 `.a` | C99 + smoke PASS |
| LibTomFloat — Экспериментальная произвольная двоичная точность | `number\real` | Public Domain / WTFPL-2.0 | 264 328 → 61 650 | 86 284 `.a` | C99 + smoke PASS; experimental² |
| libdivsufsort — Суффиксные массивы и BWT | `text\search` | MIT | 133 689 → 83 705 | 55 348 (2 `.a`) | C99 + smoke PASS |
| libtess2 — Тесселяция многоугольников | `geo\tessellation` | SGI-B-2.0 | 247 809 → 189 892 | 47 570 `.a` | C99 + smoke PASS |
| libccd — Пересечения выпуклых тел | `geo\collision` | BSD-3-Clause | 337 202 → 120 640 | 45 120 `.a` | C99 + smoke PASS |
| inih — Разбор конфигурации INI | `document\config` | BSD-3-Clause | 92 732 → 28 267 | 4 452 `.a` | C99 + smoke PASS |
| isocline — Редактор строки для терминала/REPL | `ui\terminal` | MIT + wcwidth¹ | 1 228 035 → 400 853 | 126 218 `.a` | C99 + smoke PASS; TTY NOT_RUN |
| libunibreak — Границы строк, слов и графем Unicode | `text\unicode` | Zlib + Unicode-3.0 | 4 527 072 → 815 890 | 149 060 `.a` | C99 + smoke PASS |
| xxHash 0.8.4 — Быстрые некриптографические хеши | `hash` | BSD-2-Clause | 5 511 342 → 300 853 | 19 218 `.a` | C99 + smoke PASS |
| c-ares — Асинхронный DNS | `net\dns` | MIT | 5 373 957 → 2 465 461 | 466 620 `.a` | C99 + smoke PASS |
| libevent — Цикл событий, buffers, HTTP/DNS/RPC | `net\event` | BSD-3-Clause + ISC/BSD¹ | 4 720 957 → 2 398 384 | 428 410 (3 `.a`) | C99 + smoke PASS |
| mDNS — Обнаружение служб в локальной сети | `net\discovery` | Unlicense | 119 956 → 109 979 | нет `.a`; example EXE 35 640 | name roundtrip PASS; EXE NOT_RUN |

¹ Полные условия и отдельные notices сохранены; лицензия CMINPACK содержит
acknowledgment University of Chicago, isocline — отдельное permissive
уведомление Markus Kuhn для wcwidth. Их точные пути и исходные названия
лицензий перечислены в `summary.json`.

² LibTomFloat сохранён как экспериментальная независимая реализация. Выбранная
сборка исправляет `sqrt(0)` и signed-long constructor, включая `LONG_MIN`;
краткие regression checks прошли. Upstream WARNING остаётся в поставке,
`mpf_from_string`/`mpf_to_string` объявлены, но не реализованы. Основной `real`
использует LibBF; `double` остаётся отдельным машинным профилем.

## Суммы и границы измерений

| Группа | Компоненты | Исходники до, байт | Исходники после, байт | Выбранные `.a`, байт |
|---|---:|---:|---:|---:|
| Числовые | 10 | 12 840 167 | 2 497 743 | 965 686 |
| Текст, геометрия, терминал, хеши | 7 | 12 077 881 | 1 940 100 | 446 986 |
| Сетевые | 3 | 10 214 870 | 4 973 824 | 895 030 |
| **Всего** | **20** | **35 132 918** | **9 411 667** | **2 307 702** |

Отбор уменьшил vendor source trees на **25 721 251 байт
(73,21%)**. Это сравнение
распакованных файлов, а не степень ZIP-сжатия всего патча.

Сумма native библиотек состоит из **22 статических архивов для
19 компонентов**. У libdivsufsort учтены обе ширины индекса; у libevent —
`core + extra + pthreads`, без повторного добавления монолитного `libevent.a`.
Имеющиеся LibTomMath и legacy xxHash повторно не посчитаны. У каждого из
19 компонентов сумма выбранных архивов меньше 1 000 000 байт в измеренной
конфигурации. Размер `.a` включает служебные таблицы и не равен RAM задачи или
размеру окончательного ядра после линковки.

**mDNS — header-only.** Число **35 640 байт** относится к целой upstream
example-программе, с динамической системной C runtime. Программа собрана для
замера, но не запускалась. Это число не включено в сумму `.a` и не выдаётся за
размер отсутствующей библиотеки. Отдельный mDNS name roundtrip выполнен внутри
C99 network smoke. DNS queries и multicast packets этот smoke не отправлял.

Числа получены в локальных Linux x86_64 C99/MinSizeRel профилях. Переносимость
исходников не подменяется утверждением, что Windows/macOS/другие CPU уже
испытаны: их исполнение в этих отчётах — `NOT_RUN`.

## Лицензии, примеры и фактические проверки

Проверено существование **всех заявленных license/notice paths для всех 20
компонентов**, а также исходников выбранных usage checks и примеров. Числовые
проверки находятся в [numeric_extra/tests](../../../third_party/lmx_c99_compact/extensions/numeric_extra/tests),
текстовые и геометрические — в [text_hash_extra/tests](../../../third_party/lmx_c99_compact/extensions/text_hash_extra/tests),
сетевой smoke — в [network_smoke.c](../../../third_party/lmx_c99_compact/extensions/network_extra/tests/network_smoke.c).

В vendor c-ares и libevent сохранены исходники upstream tests; у libevent также
есть выбранные sample-программы. У mDNS сохранён исходный [mdns.c](../../../third_party/lmx_c99_compact/vendor/mdns/mdns.c).
Наличие этих файлов **не означает**, что upstream suites полны, что сохранено
всё их внешнее тестовое окружение или что они запускались. Full upstream suites
остаются `NOT_RUN`; c-ares GTest/C++ исходники не являются зависимостью выбранной
production C99 сборки. В числовом и текстовом compact profiles выполнены
собственные краткие checks; исходные большие/несовместимые harnesses не
выдаются за пройденные.

Фактические результаты: numeric **3/3** выбранных CTest-проверки PASS;
text/hash **9/9** PASS; network report — PASS для DNS packet fields, event timer,
buffer roundtrip, HTTP URI и mDNS name roundtrip. Interactive TTY editing
isocline, полный запуск mDNS example, LMX wrapper runtime и cross-platform
execution не заявлены проверенными. Все ссылки на исходники и результаты
для каждой строки сохранены в `summary.json`.

## Исходные отчёты

- Числовые: [COMPONENTS](../../../third_party/lmx_c99_compact/extensions/numeric_extra/COMPONENTS.json), [COMPACTNESS](../../../third_party/lmx_c99_compact/extensions/numeric_extra/COMPACTNESS.json), [VERIFICATION](../../../third_party/lmx_c99_compact/extensions/numeric_extra/VERIFICATION.json).
- Текст/геометрия/терминал/хеши: [COMPONENTS](../../../third_party/lmx_c99_compact/extensions/text_hash_extra/COMPONENTS.json), [PROVENANCE с source_selection](../../../third_party/lmx_c99_compact/extensions/text_hash_extra/PROVENANCE.json), [non_numeric_build](non_numeric_build.json).
- Сетевые: [COMPONENTS](../../../third_party/lmx_c99_compact/extensions/network_extra/COMPONENTS.json), [COMPACTNESS](../../../third_party/lmx_c99_compact/extensions/network_extra/COMPACTNESS.json), [network_build](../validation/network_build.json).
