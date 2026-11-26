# Сборка и проверка C99 коллекции

## Полный принятый состав

Команды выполняются **из корня LMX**. Исходники находятся
в `third_party/lmx_c99_compact`; отдельного корневого CMake проекта всего LMX
для этой задачи не требуется.

```sh
cmake -S third_party/lmx_c99_compact -B build-c99 \
  -DCMAKE_BUILD_TYPE=MinSizeRel -DLMX_ARCHIVE_VERIFY=ON
cmake --build build-c99 --parallel 2
ctest --test-dir build-c99 --output-on-failure
```

Нужны подготовленные локальные C99 compiler/CMake/Make или Ninja и системные
SDK/development inputs выбранных OS backends. Часть autotools adapters
использует make и m4, а некоторые прежние генераторы требуют flex/bison.
Научный parallel profile требует MPI C installation с MPI-IO. Для неё можно
передать `-DMPI_C_COMPILER=/path/to/mpicc` и
`-DMPIEXEC_EXECUTABLE=/path/to/mpiexec`. POSIX/threads/OpenGL/X11 dependencies
и ограничения конкретных platform profiles описаны возле adapters.

Сборка не скачивает источники. Наличие локального source archive не заменяет
compiler, MPI runtime или development headers устройства. Runtime, которым
создан MPI handle, должен соответствовать MPI headers использованного build.

Корневой CMake сохраняет полный принятый состав этого этапа. `LMX::all`
предоставляет совокупность targets; для конкретного приложения можно связывать
нужные targets. Отдельная `.a` на диске не означает включение каждого её
object/section в executable. Последующее сокращение состава для конкретного
устройства — отдельный анализ после полной описи.

## Отдельные семейства

Из `third_party/lmx_c99_compact`:

```sh
cmake -S extensions/bundles_extra -B build-bundles \
  -DLMX_BUNDLES_EXTRA_BUILD_TESTS=ON -DLMX_BUNDLES_WITH_SOUND=OFF
cmake --build build-bundles
ctest --test-dir build-bundles --output-on-failure

cmake -S extensions/netsurf_extra -B build-netsurf
cmake --build build-netsurf
ctest --test-dir build-netsurf --output-on-failure

cmake -S extensions/scientific_pnetcdf -B build-pnetcdf \
  -DLMX_PNETCDF_BUILD_TESTS=ON -DMPI_C_COMPILER=/path/to/mpicc
cmake --build build-pnetcdf
ctest --test-dir build-pnetcdf --output-on-failure
```

`cute_sound` включается при наличии уже подготовленного SDL3 target/package;
общая композиция переиспользует `LMX::sdl3`. Отдельный NetSurf profile требует
Expat, а общая сборка использует существующий `LMX::expat`. HDF5 и PnetCDF
документируют свои standalone зависимости и installed prefixes:
[HDF5](../../third_party/lmx_c99_compact/extensions/scientific_hdf5/README.ru.md),
[PnetCDF](../../third_party/lmx_c99_compact/extensions/scientific_pnetcdf/README.ru.md).
Общая netCDF-C сборка использует уже подготовленные научные зависимости.

Малые прежние группы `storage_extra`, `science_extra`, `control_extra`,
`knowledge_extra` и `pdf_extra` также имеют локальные CMake/README profiles.
Их возможности зависят от выбранных dependencies: MAT7.3 требует HDF5,
а MAT5 compression использует zlib.

## Что означает успешная проверка

В production C-командах используется C99, `C_EXTENSIONS=OFF` и
`-pedantic-errors` на проверенном GCC. Build views устраняют конкретные
несовместимости и известные ошибки; vendor inputs сохраняются отдельно.
Точные edits и семантические tests перечислены в групповых отчётах.

Тесты работают в отдельных build directories и не пишут результат поверх
исходников. Codec roundtrips проверяют конкретные представления; parser tests
проверяют выбранные fixtures, а не полный набор возможных входов. Native
threading проверяется задачами/CAS; audio использует dummy device; MPI-IO
запускается отдельно от обычных однопроцессных функций.

**Полная композиция: 180 компонентов, build PASS, 138/138 CTest PASS.**
[Итоговый общий отчёт](VERIFICATION_2026-11-26.json) и
[индекс групповых проверок](VERIFICATION.json) сохраняют scope каждого запуска. Число CMake-exported compile
commands не включает автоматически команды внешних make projects; такие
сборки отмечаются отдельно. Число tests не равно числу функций в каталоге.

На данной ограниченной платформе работал реальный MPI-IO с одним rank.
Multi-rank MPI initialization блокируется средой; этого нельзя записать как
ошибку файлового формата или как успешный двухпроцессный тест. На подходящем
host `LMX_PNETCDF_MULTI_RANK_TESTS=ON` добавляет двухпроцессную проверку.
Параметры launcher и среды задаются явно и не становятся переносимыми
настройками всех систем. Linux execution не объявляется тестом Win32/macOS/MCU.

## Измерения и последующие пополнения

[Индекс размеров](SIZES.json) ведёт к первичным COMPACTNESS reports. Раздельно
учитываются исходники до/после очистки, `.a` container, text/data/bss и внешние
runtime dependencies. Размер финального LMX и пиковая RAM измеряются только
на конечной композиции; они не выводятся из суммы статических архивов.

Проверить сильные глобальные имена в готовой полной сборке можно так:

```sh
python3 docs/c99_archive/tools/audit_symbols.py build-c99 \
  --output build-c99/symbols.json
```

Команда выполняется из корня LMX; нужен Python 3 и GNU-compatible `nm`.
Скрипт читает правила Ninja или CMake Makefiles, выбирает production archives
и исключает промежуточные/installed duplicates. Список внешних providers
соответствует полной композиции этого снимка; неполная сборка требует
отдельного списка. Подтверждённый результат — 195 архивов, 42 500 сильных
имён, 0 коллизий. Это проверка имён, а не whole-archive link или произвольная
комбинация всех optional backends.

Для пополнения: выбрать библиотечную возможность и C99 profile, проверить
лицензии всех частей, собрать, выполнить предметную проверку, оставить
необходимые inputs/notices/короткую справку/код tests и повторить сборку.
Добавить source URL, revision, profile gates и API в core_catalog. Сохранять
вторую реализацию допустимо; она может иметь другие требования к памяти,
алгоритм, лицензируемые части и способ интеграции.
