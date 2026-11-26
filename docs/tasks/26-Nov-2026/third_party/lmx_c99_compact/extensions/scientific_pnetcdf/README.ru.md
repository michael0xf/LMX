# PnetCDF 1.15.1: C99, MPI-IO и CDF-5

`LMX::pnetcdf` предоставляет полный набор из 915 функций `ncmpi_*`, объявленных
выбранным публичным C-заголовком, а также 9 публичных `cdl_hdr_*` функций
чтения заголовка CDF: всего 924 функции. Общий target этой директории —
`LMX::scientific_pnetcdf`. Состав и LMX группировка описаны в основном
`docs/core_catalog`; машиночитаемые входы интеграции находятся в
`SOURCE_ENTRIES.json`.

| Формат | Флаг создания | Первые четыре байта |
| --- | --- | --- |
| CDF-1 / classic | `NC_CLOBBER` | `43 44 46 01` |
| CDF-2 / 64-bit offset | `NC_CLOBBER \| NC_64BIT_OFFSET` | `43 44 46 02` |
| CDF-5 / 64-bit data | `NC_CLOBBER \| NC_64BIT_DATA` | `43 44 46 05` |

CDF-5 — формат, который также называется `64-bit data` и `netCDF-5` в
обсуждении архива. Он поддерживает, в частности, `NC_INT64` и `NC_UINT64`.
Версия самой библиотеки здесь **PnetCDF 1.15.1**. Базовый backend использует
MPI-IO и не требует HDF5. Дополнительные drivers GIO, ADIOS, netCDF4,
burst-buffer и subfiling в данном профиле отключены, как и C++/Fortran bindings.
`--enable-relax-coord-bound` задан явно для совместимости с netCDF-C.

## Сборка без сети

Нужны CMake, make, m4, POSIX shell и установленная реализация MPI с C compiler
wrapper и MPI-IO. MPI предоставляет и заголовки, и runtime одной совместимой
установки. MPI runtime в эту библиотеку не вложен. Из корня C99 коллекции:

```sh
cmake -S extensions/scientific_pnetcdf -B build-pnetcdf \
  -DMPI_C_COMPILER=/path/to/mpi/bin/mpicc \
  -DMPIEXEC_EXECUTABLE=/path/to/mpi/bin/mpiexec \
  -DLMX_PNETCDF_BUILD_TESTS=ON
cmake --build build-pnetcdf --parallel 4
ctest --test-dir build-pnetcdf --output-on-failure
```

При включении поддиректории target `lmx_pnetcdf_build` выполняет локальные
configure/make шаги. Переменная `LMX_PNETCDF_INSTALL_PREFIX` указывает готовый
prefix с `include/pnetcdf.h` и `lib/libpnetcdf.a`. Внешний dependent build,
например netCDF-C, должен зависеть от `lmx_pnetcdf_build` до своей configure
фазы. Заголовок создаётся из retained `vendor/pnetcdf/src/include/pnetcdf.h.in`;
снимок ABI конкретного MPI в vendor не сохраняется.

`configure_local.cmake` копирует исходники в build view, выполняет configure
с `--no-create --disable-maintainer-mode`, затем запрашивает у `config.status` только входы production
C-сборки. Поэтому не нужно хранить большие шаблоны неиспользуемых Fortran
bindings или Makefiles приложений. Сначала генерируется `ncx.h`, затем отдельно
собираются dispatchers/common/ncmpio и общий static archive. Сборка не запускает
утилиты чтения данных и не загружает исходники.

## Малые исправления интеграции

Оригиналы vendor не изменены. В build view после проверки SHA-256 изменяется
только `src/dispatchers/lib_version.c`:

1. Пустое сравнение адреса функции с адресом объекта заменено безвредным
   `(void)pnetcdf_libvers`; это устраняет нарушение C99 и сохраняет version ABI.
2. Подключается читаемый `src/ubyte_aliases.c`: upstream заголовок объявляет
   `ncmpi_put_att_ubyte` и `ncmpi_get_att_ubyte`, но исходная библиотека экспортирует
   только идентичные `uchar` варианты. Две aliases сохраняют объявленные
   сигнатуры и передают проверку/преобразование существующим реализациям.

Интеграционный код имеет лицензию `../../LICENSE.integration` (0BSD).
PnetCDF copyright сохранён целиком; встроенный utf8proc и его Unicode data
имеют собственные permissive notices в `src/drivers/common`. Build helpers
autoconf/libtool сохраняют свои исходные notices и исключения для generated
build machinery; они не становятся библиотекой в LMX runtime.

Неиспользуемые `m4/ax_compiler_vendor.m4` и `m4/ax_check_compile_flag.m4`
удалены: их exception распространяется на generated configure, а исходные
macros остаются GPL. Release configure сохранён; maintainer mode явно отключён,
поэтому make не пытается регенерировать Autoconf inputs. Это не затрагивает
M4 генераторы числовых преобразований, которые нужны production C сборке.
Перечень удаления и повторная проверка — `LICENSE_RETENTION_AUDIT.json`.

## Проверенные свойства

Полное исходное дерево и усечённое дерево собраны одним адаптером с
`-Os -std=c99 -pedantic-errors -fPIC` на Linux x86_64/GCC 14.2/MPICH 4.2.1.
Проверка public header против `nm` подтверждает наличие всех 915 объявленных
`ncmpi_*` и 9 `cdl_hdr_*` функций в итоговом archive.

В обоих вариантах прошёл реальный **однопроцессный MPI-IO** roundtrip:
создание и повторное открытие CDF-1/2/5, проверка magic и format ID,
collective и independent чтение, nonblocking write + wait, размеры и атрибуты,
точные `UINT64` значения выше `2^53` и `NC_UBYTE` атрибут с 255. Это проверяет
CDF-5 как реальный формат файла, а не только наличие константы в заголовке.

В доступной среде запуск нескольких ranks блокируется на MPI initialization
из-за ограничений системных socket/sysfs ресурсов. Multi-rank выполнение
**не отмечено как пройденное**. Тот же `tests/roundtrip.c` распределяет данные
между произвольным числом ranks; на обычном MPI host дополнительный тест
включается `-DLMX_PNETCDF_MULTI_RANK_TESTS=ON`. Параметры launcher задаются
`MPIEXEC_PREFLAGS`, параметры среды — `LMX_PNETCDF_TEST_ENVIRONMENT`.

Здесь для MPICH single-rank использованы `-launcher fork`, `UCX_TLS=self`,
`UCX_VFS_ENABLE=n`, `HWLOC_COMPONENTS=-linux`. Они описывают данный запуск,
а не обязательные настройки PnetCDF для всех систем.

`tests/serial_crossread.c` — независимый потребитель на netCDF-C, без MPI.
Для получения малого CDF-5 файла из проверяемого кода:

```sh
mpiexec -n 1 ./lmx_pnetcdf_roundtrip . --keep
cc -std=c99 -pedantic-errors tests/serial_crossread.c \
  -I/path/to/netcdf/include -L/path/to/netcdf/lib -lnetcdf -o crossread
./crossread pnetcdf-cdf5.nc
```

Cross-reader специально требует one-rank fixture с четырьмя элементами.
Его исходник сохранён; выполнение с конкретной сборкой netCDF-C фиксируется
общей проверкой архива, отдельно от PnetCDF-only CTest.

## Компактность и LMX

Сохранены production C implementation, M4 generators, реально используемая
Unicode table, конфигурационные inputs, лицензии, короткие документы и C tests/
examples. Удалены bindings, невыбранные drivers, приложения, двоичные fixtures,
большие исторические release notes и неиспользуемые build inputs. Размеры до и
после, размер `.a` и секций находятся в `COMPACTNESS.json`; `.a`, `.o` и
сгенерированные файлы данных в исходный патч не входят.

LMX wrappers должны хранить communicator/file/request как ресурсы с явным
владельцем и завершать незаконченные запросы до освобождения буферов.
Collective операции требуют согласованного участия communicator; это отдельное
ограничение от actor messaging. `MPI_Offset` и counts преобразуются с проверкой
диапазонов. Общий код и таблицы `independent: immutable:` доступны через ссылки
без копий в аренах акторов; изменяемые MPI/file contexts создаются отдельно.
