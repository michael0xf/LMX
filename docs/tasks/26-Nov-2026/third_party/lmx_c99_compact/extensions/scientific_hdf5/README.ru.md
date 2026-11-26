# HDF5 2.3.0: ядро и полный C High-Level API

Коллекция включает `libhdf5` и весь C `libhdf5_hl`: H5LT, H5DO, H5DS, H5IM,
H5PT, H5TB, H5LD. Включены generated C lexer/parser H5LT, исходные `.l`/`.y`,
публичные/private заголовки, переносимые драйверы, C примеры и код тестов.
Официальный источник — tag `2.3.0` в
[HDFGroup/hdf5](https://github.com/HDFGroup/hdf5/releases/tag/2.3.0).
Адрес архива и его SHA-256 находятся в `SOURCES_ENTRIES.json`.

## Автономная сборка

Из `third_party/lmx_c99_compact`:

```sh
cmake -S extensions/scientific_hdf5 -B build/hdf5 -G Ninja -DCMAKE_BUILD_TYPE=MinSizeRel
cmake --build build/hdf5
ctest --test-dir build/hdf5 --output-on-failure
```

Нужны CMake >= 3.26, C99-компилятор, zlib и MPI C. Для компьютера без MPI:

```sh
cmake -S extensions/scientific_hdf5 -B build/hdf5-serial -G Ninja -DLMX_HDF5_PARALLEL=OFF
cmake --build build/hdf5-serial
ctest --test-dir build/hdf5-serial --output-on-failure
```

Настройка и сборка не загружают зависимости. `HDF5_ALLOW_EXTERNAL_SUPPORT=NO`,
`FETCHCONTENT_FULLY_DISCONNECTED=ON`; внешние plugin/VOL-пакеты не выбираются.
В общем дереве существующий `LMX::zlib` передаётся в дочерний CMake напрямую,
без второго source tree: его архив — `ZLIB_LIBRARY`, vendor headers —
`ZLIB_INCLUDE_DIR`, underlying target — dependency конфигурации HDF5.
Standalone использует установленный системный zlib.

Targets: `LMX::hdf5`, `LMX::hdf5_hl`, общий `LMX::scientific_hdf5`.
ExternalProject target `lmx_hdf5_build` конфигурирует, собирает и устанавливает
только в build tree. `LMX_HDF5_INSTALL_PREFIX` сообщает этот префикс зависимым
дочерним проектам. Они должны зависеть от `lmx_hdf5_build`, а затем передавать
префикс через `HDF5_ROOT`/`HDF5_DIR`. Upstream install включает
`lib/cmake/hdf5/hdf5-config.cmake`, headers и static core/HL archives.
Публичный `H5pubconf.h` генерируется для машины сборки; заранее приготовленная
конфигурация Linux не подставляется под другие платформы.

## Выбранный профиль и границы

Проверенный профиль: static core + весь HL, MPI I/O, zlib, pthread support,
C99 complex, deprecated C API, map API. `LMX_HDF5_PARALLEL=OFF` отключает
MPI driver и соответствующие условные declarations; их source/header файлы
сохраняются в коллекции. `_Float16` выключен как расширение за пределами C99.
C++, Fortran, Java bindings и приложения `h5dump` и подобные не относятся к
этому C библиотечному профилю.

Pthread support обеспечивает внутренние примитивы и mutex-based эмуляцию
атомиков. **Этот профиль не разрешает одновременно вызывать HDF5 из разных
акторов/потоков.** Upstream отвергает thread-safe + HL без
`HDF5_ALLOW_UNSUPPORTED`; такой override здесь не используется. На границе
LMX нужен общий gate для HDF5 calls, а каждый изменяемый `hid_t` должен иметь
владельца, срок жизни и соответствующий `H5*close`.

Общие CODE и описания форматов могут оставаться `independent: immutable:`;
между аренами разделяется ссылка. Открытые файлы, dataspaces, property lists,
event sets и MPI communicators — отдельные изменяемые ресурсы, их нельзя
выдать за immutable данные или автоматически разделить без контракта.

Map API включён, но его операции требуют VOL connector с поддержкой maps;
поддержка maps стандартным native VOL не заявляется. Сохранены source/header
опциональных HDFS, ROS3, direct, mirror и subfiling VFD, однако эти драйверы
не все активны в выбранном профиле. Точная доступность задаётся `H5pubconf.h`
и `EXPORTED_SYMBOLS.json`. `HDF5_ENABLE_PLUGIN_SUPPORT=OFF` относится к
подключению отдельной внешней коллекции `hdf5_plugins`; собственные H5PL
loader API ядра компилируются. SZIP не активирован без внешнего libaec;
DEFLATE, shuffle, Fletcher32 и другие автономные фильтры остаются доступны.

## Две адаптации C99

Upstream vendor files не изменены. `prepare_view.cmake` проверяет хеши и
создаёт build view:

1. `config/flags/HDFCompilerFlags.cmake`: C standard и стандартный compiler
   option переключены с 11 на 99.
2. `src/H5RTpkg.h`: повторный typedef `H5RT_node_t`, разрешённый в C11,
   заменён обычным определением уже объявленного `struct H5RT_node_t`.
   Раскладка и поля структуры сохраняются.

`HAVE_STDATOMIC_H=0` выбирает предусмотренную upstream mutex эмуляцию;
C11 `_Atomic` не маскируется подавлением диагностики. Проверка выполняется с
`-std=c99 -pedantic-errors`. В каталоге остаются upstream compiler-warning
настройки; локальные адаптации не добавляют `-Wno-pedantic`.

## Проверки и размеры

`VERIFICATION.json` записывает проверенные профили, `COMPACTNESS.json` —
размеры исходного и усечённого деревьев и static `.a`. Лимит 1 MB для этого
многофункционального пакета снят пользователем. Размер полного архива `.a`
не равен размеру программы, использующей несколько HDF5 функций.

Самостоятельный тест создаёт все данные на месте: chunked compressed dataset,
append, контрольные суммы, dimensions/scale, attributes, RGB image, compound
table, packet table, H5LT datatype-text parser, закрытие и повторное чтение.
Он использует каждый из семи C HL модулей и не требует внешних fixture files.

MPI тест выполняет настоящие collective MPI-IO write/read hyperslabs. В
текущей среде проверен **один rank**. Работа нескольких rank не заявляется;
ограничения среды отдельно зафиксированы в отчёте. На других машинах тот же
`test_mpi.c` поддерживает несколько rank. MPI support в библиотеке не означает,
что non-MPI core/HL операции требуют вызова `MPI_Init`.

Сохранены C upstream unit tests и примеры, но удалены бинарные `.h5` corpora,
снимки ожидаемого вывода, большие manuals/sites, CI metadata, C++/Fortran/Java
bindings, готовые binaries и архивы. Поэтому весь upstream test suite не
объявляется запускаемым без исходных fixtures; два добавленных теста полностью
самостоятельны. Нужные configure templates и compiler flag tables сохранены.

## Лицензии

`vendor/hdf5/LICENSE` — BSD-3-Clause. У generated Bison parser H5LT сохранён
исходный skeleton notice с явным исключением, позволяющим распространять
более крупную работу на иных условиях. Исключение не удалено и не заменено;
Bison executable не добавляется в runtime. Для стандартной сборки не нужны
ни Bison, ни Flex: generated C уже входит в официальный выпуск.
