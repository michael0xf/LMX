# Решения о составе — 26 ноября 2026

Точное состояние поставки фиксируется в
[SOURCES.json](../../third_party/lmx_c99_compact/SOURCES.json). Основные
LMX-структуры и функции находятся в [core_catalog](../core_catalog/README.ru.md).
Здесь записаны действующие принципы отбора и причины ограничений профилей.

## Сохранить полноту перед последующим сокращением

Текущая задача — сохранить все принятые функции и полезные реализации,
сгруппировать их по смыслу и подготовить воспроизводимые C99 profiles.
Анализ того, какие библиотеки отключать в конкретной маленькой системе,
выполняется после этого. Дублирование возможностей само по себе не является
основанием удалить библиотеку: альтернативный API или набор зависимостей
может оказаться рабочим на другой машине или в аварийной ситуации.

Для многофункциональных наборов и отдельно согласованных научных библиотек
порог **1 000 000 байт больше не является отсечением**. Для небольшой узкой
библиотеки размер по-прежнему важен как практическая характеристика, а не
единственная цель. Общий бюджет определяется реальными профилями и связями.
Размер source tree, `.a`, финального executable, runtime dependencies и RAM
учитываются отдельно. Никакие старые числа не переименовываются в измерение
нового набора.

## Научные форматы приняты

Прежнее решение исключить HDF5/netCDF из-за размера изменено текущим
поручением. В состав входят HDF5 2.3.0 с C HL, netCDF-C 4.10.1, PnetCDF 1.15.1,
а matio 1.6.0 использует HDF5 для MAT7.3. libxml2 2.15.4 нужен DAP4 и также
каталогизируется как самостоятельная C библиотека.

CDF-5 означает `64-bit data`/`NC_64BIT_DATA`, включая 64-битные целые.
HDF5-backed netCDF-4, CDF-5 и версия библиотеки netCDF-C различаются в описи.
Serial I/O, collective MPI I/O, DAP, directory NCZarr, S3 и filter plugins
имеют отдельные gates: наличие исходника или объявления не означает,
что каждый backend включён и проверен на данной платформе.

Проверенный однопроцессный MPI-IO не объявляется проверкой нескольких ranks.
В данной среде multi-rank initialization ограничен системными ресурсами;
исходный тест сохраняется для подходящего MPI host.

## Очистка исходников

Сохраняются необходимые production inputs, полезные платформенные ветви,
лицензии всех встроенных частей, короткая справка, исходный код тестов и
примеров. Не переносятся download archives, git history, сайты документации,
дублирующие SDK payloads, тяжёлые demo assets и результаты сборки. Исходное
дерево и усечённое дерево проверяются одинаковым адаптером; небольшие
compatibility fixes отделены от vendor и проверяют закреплённый input hash.

C99 требования относятся к производственному C-профилю. C++/Fortran bindings
не выдаются за C99 из-за общего происхождения проекта. Платформенные OS/MPI
inputs остаются явными зависимостями. Выбор части большого upstream набора
объясняется в его README/SOURCE_ENTRIES, а не скрывается под названием всей
библиотеки.

## Практические уточнения предложений

- В gb snapshot нет JSON. Включены gb core и INI; C11 anonymous structures
  в gb_math и зависимый GL layer не объявлены C99 реализацией.
- cute_headers включён восемью независимыми components. TLS header требует
  другого OS backend и не включён в выбранный working profile.
- C99Containers найден как исторический STC; уже имеющийся STC покрывает это
  предложение без добавления старого fork.
- Embedded Artistry libc имеет MIT корень и разные per-file licenses.
  Выбранные 80 функций изолированы префиксом `lmx_ea_`; APSL реализации,
  опасный upstream realloc и полная подмена системной libc исключены из
  этого профиля. Отдельные сохранённые альтернативные libc algorithms остаются.
- NetSurf modules дают HTML/DOM/CSS/SVG parsing и image decoders. Они не
  означают включение browser application, JavaScript runtime или полного layout.

## Лицензии и известные границы

Новые runtime компоненты имеют разрешающие licenses без copyleft;
встроенные код/таблицы сохраняют собственные notices. Скрипты стандартной
системы сборки сохраняют исходные условия и применимые исключения.
Интеграционная 0BSD лицензия не заменяет licenses upstream.
Две унаследованные записи Mint и afan Neural-Network остаются `NOASSERTION`.

Известный PDFio encrypted CreationDate regression сохраняется как
[KNOWN_LIMITATION](../../third_party/lmx_c99_compact/extensions/pdf_extra/KNOWN_LIMITATIONS.md),
с отдельным воспроизводящим исходником. Он не записывается как успешный test.
Отложенный эксперимент UDUNITS-2 описан в [UDUNITS_DEFERRED.md](UDUNITS_DEFERRED.md).

LMX сохраняет собственную семантику данных, язык и actor model. JSON/XML/INI
служат внешнему обмену; специализированные PCRE2/SLJIT/SQL механизмы допустимы.
Общие Lua/Perl/JavaScript environments и готовые микросервисы не добавляются
вместо LMX. `independent: immutable:` CODE/DATA разделяются ссылками, без
копий в actor arenas; mutable native contexts требуют отдельного владельца.

Исправления конкретных библиотек и точные тесты находятся возле adapters:
[gb/cute/EA](../../third_party/lmx_c99_compact/extensions/bundles_extra/PORTABILITY.ru.md),
[platform](../../third_party/lmx_c99_compact/extensions/platform_extra/README.ru.md),
[NetSurf](../../third_party/lmx_c99_compact/extensions/netsurf_extra/README.md),
[HDF5](../../third_party/lmx_c99_compact/extensions/scientific_hdf5/README.ru.md),
[PnetCDF](../../third_party/lmx_c99_compact/extensions/scientific_pnetcdf/README.ru.md).
