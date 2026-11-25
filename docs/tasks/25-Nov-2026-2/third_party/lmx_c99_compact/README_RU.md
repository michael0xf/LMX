# LMX: компактная коллекция библиотек C99

[English](README.md) · Редакция от **25 ноября 2026 года**

Этот README рассчитан на размещение в корне `lmx_c99_compact`, рядом с [CMakeLists.txt](CMakeLists.txt). Коллекция содержит **132 принятые компонентные позиции**; все группы библиотек включены по умолчанию. Она предоставляет исходники, CMake-targets, адаптеры, примеры и тесты для подключения к LMX или другому приложению. Компилятор LMX, его FFI и графический Manager сюда не входят.

## Начать здесь

- [Первичная LMX-опись и план подключения к ядру](../../docs/core_catalog/README.ru.md) — пакеты, функции, модели, конвертеры и новые примитивы; приоритет у текущей `docs/spec`.
- [20 компактных дополнений](../../docs/core_catalog/additions/OVERVIEW.ru.md) — исходники до/после очистки, лицензии, фактические размеры и проверки.
- [SOURCES.json](SOURCES.json) — полный перечень компонентов, закреплённые версии/commits, исходные URL и пути к лицензиям.
- [Примеры и команды запуска](examples/README_RU.md) — 26 готовых демонстрационных программ.
- [Указатель примеров upstream](examples/UPSTREAM_INDEX_RU.md) и [подробный индекс происхождения](examples/UPSTREAM_SOURCES.json).
- [Перечень проверок](examples/checks/INDEX_RU.md) — выбранные unit/integration tests.
- [Краткая памятка по вызовам C из акторов](examples/reference/C_FFI_QUICK_RU.md).

Все ссылки ниже относительны к корню этой компактной поставки. Старые каталоги отчётов и полные upstream-дистрибутивы не нужны для работы с этим руководством.

## 1. Состав и расположение файлов

| Путь | Назначение |
|---|---|
| [vendor/](vendor/) | Отобранные исходники библиотек и необходимые входы сборки, включая применимые платформенные реализации, шаблоны и лицензии |
| [cmake/](cmake/) | Правила сборки базовых компонентов и копирования Windows runtime |
| [extensions/](extensions/) | Адаптеры дополнительных групп, интеграционные исходники и отдельные подготовленные входы сборки; каталог необходим |
| [include/](include/) и [src/](src/) | Общие заголовки и интеграционный код коллекции |
| [examples/collection/](examples/collection/) | Законченные программы, использующие библиотеки |
| [examples/upstream/](examples/upstream/) | Отобранные дополнительные примеры и короткие справки upstream |
| [examples/checks/](examples/checks/) | Самостоятельные проверки библиотечных API и совместной работы компонентов |
| [prebuilt/](prebuilt/) | Согласованный Windows runtime и сведения о его происхождении |
| [extensions/postgresql/prebuilt/](extensions/postgresql/prebuilt/) | Windows x64 `libpq.dll`, соответствующие заголовки, import library и manifest |
| [SOURCES.json](SOURCES.json) | Связь каждого компонента с его исходником, версией и уведомлениями |

В компактном каталоге нет `source_archives/` и копий полных репозиториев. `llhttp` находится в [vendor/llhttp/](vendor/llhttp/); CivetWeb исключён. `extensions/` нельзя удалить: это действующая часть интеграции, а не дубликат `vendor/`.

Исходники отбирались пофайлово из полной коллекции, затем проверялись конфигурацией, компиляцией и линковкой. Сохранены нужные файлы платформенных ветвей библиотек, а не только файлы проверенного Linux-host. Небольшие C99-адаптации обычно создают отдельные сборочные копии; оригинальные vendored входы остаются отдельно от таких копий. Комплект является подготовленной коллекцией для данного CMake-проекта: не каждый оставшийся upstream build-script рассчитан на самостоятельную сборку урезанного дерева.

### Группы библиотек

| Группа | Основной состав | Публичные targets / правила |
|---|---|---|
| HTTP, TLS, сжатие | curl 8.23.0, llhttp 9.4.4, mbedTLS 3.6.7, zlib 1.4 | `LMX::curl`, `LMX::llhttp`, `LMX::http_parser`, `LMX::mbedtls`, `LMX::zlib`; [сеть](cmake/CURL_ZLIB.cmake), [парсер](extensions/http_parser/CMakeLists.txt) |
| Контейнеры и базовое ядро | Выборки stb, klib, STC; decNumber, libsodium, SLJIT; SQLite | `LMX::stb`, `LMX::klib`, `LMX::stc`, `LMX::decnumber`, `LMX::sodium`, `LMX::sljit`, `LMX::sqlite3` |
| Научная математика | linmath, KissFFT, TinySpline, Wavelib, Cephes, CMPFIT, xoshiro | `LMX::math`, `c99_gsl_lite`; [правила](cmake/Scientific.cmake) |
| Точная арифметика и интегрирование | LibTomMath, MPDecimal; CQUADPACK, Stroud, Sparse Grid HW, Sobol | [Точная арифметика](cmake/Precision.cmake), [квадратуры](cmake/Quadrature.cmake); общий `LMX::math` |
| Сеть и системные утилиты | dyad, ENet, libssh2, Monocypher, miniz, LZ4, microtar, jsmn, cJSON, tinydir, TinyCThread, libvterm | `LMX::systems`; [правила](extensions/systems/CMakeLists.txt) |
| Графика и изображения | Sokol renderer, Nuklear, microui, Olive.c; QOI, LodePNG, libspng, tPNG, TJpgDec, NanoJPEG, gifdec, msf_gif | `LMX::graphics`, `LMX::sokol`; [правила](extensions/graphics/CMakeLists.txt) |
| Аудио и видео | miniaudio, dr_wav/dr_mp3/dr_flac, minimp3, jo_mp1, TinySoundFont, pl_mpeg, jo_mpeg, jo_gif, minih264, nestegg, h264bsd, libwebp с mux/demux | `LMX::media`; [правила](extensions/media/CMakeLists.txt) |
| Документы и модели | PDFGen, md4c, Gumbo, yxml, ezXML, tomlc99, libyaml, cgltf, fast_obj | `LMX::documents`; [правила](extensions/documents/CMakeLists.txt) |
| Архивы и двоичные форматы | kuba zip, Zstandard, C-декодеры LZMA SDK, CMP, MPack, nanopb runtime | `LMX::archives`; [правила](extensions/archives/CMakeLists.txt) |
| XLSX | xlsxio, Expat, классический MiniZip из zlib | `LMX::xlsxio`; [правила](extensions/xlsxio/CMakeLists.txt) |
| Внешние БД | hiredis, libbson/libmongoc, libpq 18.7 | `LMX::databases`, `LMX::pq`; [драйверы](extensions/databases/CMakeLists.txt), [PostgreSQL](extensions/postgresql/CMakeLists.txt) |
| Векторный поиск | sqlite-vec для включённой SQLite | `LMX::sqlite_vec`; [правила](extensions/sqlite_vec/CMakeLists.txt) |
| Дополнительные утилиты | tinyfiledialogs, whereami, cglm, quirc, QR-Code-generator, tiny-regex-c | `LMX::extras`; [правила](extensions/extras/CMakeLists.txt) |
| Геодезия и пространственные индексы | GeographicLib-C geodesic, H3, tidwall rtree, Shapelib, minmea | `LMX::geospatial`; [правила](extensions/geospatial/CMakeLists.txt) |
| Тензоры | CPU-тензорная часть mint и CPU-реализация utensil | `LMX::tensors`, `LMX::mint`, `LMX::utensil`; [правила](extensions/tensors/CMakeLists.txt) |
| Пути и UTF-8 | cwalk, utf8.h | `LMX::text_paths`; [правила](extensions/text_paths/CMakeLists.txt) |
| Преобразование чисел и память | Полная float/double C-часть Ryu; TLSF | `LMX::core_helpers`; [правила](extensions/core_helpers/CMakeLists.txt) |
| Статические эмбеддинги | Усреднение float-векторов по token IDs, необязательная L2-нормализация | `LMX::embeddings`, `LMX::static_embeddings`; [API](extensions/embeddings/include/lmx_static_embeddings.h) |
| Коррекция ошибок | libcorrect: Reed–Solomon, свёрточные коды/Viterbi; fec shim | `LMX::channel_codes`, `LMX::correct`; [правила](extensions/channel_codes/CMakeLists.txt) |
| DSP и звуковой модем | Liquid-DSP с внутренним FFT, libquiet, Jansson | `LMX::acoustic`, `LMX::liquid_dsp`, `LMX::quiet`; [правила](extensions/acoustic/CMakeLists.txt) |
| Орбиты спутников | C-реализация SGP4/TLE из aholinch/sgp4 | `LMX::orbits`, `LMX::sgp4`; [правила](extensions/orbits/CMakeLists.txt) |
| Нейронные сети CPU | Genann, KANN с autodiff и reader, Tinn, afan Neural-Network | `LMX::genann`, `LMX::kann`, `LMX::kann_data`, `LMX::tinn`, `LMX::afan_neural_network` |
| Квантованный inference | Scalar-ядро NNoM, q7/q15 | `LMX::mlp_nnom`, `LMX::nnom`; [правила](extensions/nnom/CMakeLists.txt) |

Компонентные позиции, CMake-targets и статические архивы — разные единицы подсчёта. Повторяющиеся зависимости, в частности zlib, cglm и KissFFT, не добавляются как независимые копии одной реализации. Точный состав закреплён в [SOURCES.json](SOURCES.json).

### Дополнение к исходным 112 компонентам

| Группа | Компоненты | Цель |
|---|---:|---|
| [Числовые альтернативы](extensions/numeric_extra/README.ru.md) | 10 | `LMX::numeric_extra` |
| [Текст, геометрия, терминал, хеши](../../docs/core_catalog/additions/NONNUMERIC.ru.md) | 7 | `LMX::text_hash_extra` |
| [Локальная сеть](extensions/network_extra/README.ru.md) | 3 | `LMX::network_extra` |

Все три группы включены в `LMX::all`. Для пяти дополнительных проверок общей линковки задайте `-DLMX_BUILD_CATALOG_CHECKS=ON`, затем `ctest --test-dir build -R "^catalog\." --output-on-failure`. Эти проверки не включают отсутствующие исторические test fixtures. Результаты новой общей сборки и её границы — в [full_build.json](../../docs/core_catalog/validation/full_build.json).

## 2. Требования к сборке

- **CMake 3.20+**, C99-компилятор, linker/archiver и системные C-заголовки. Проверены GCC и Clang. Корневой проект использует только `LANGUAGES C`, `C_STANDARD=99`, `C_STANDARD_REQUIRED=ON`, `C_EXTENSIONS=OFF`; строгий режим GCC/Clang добавляет `-pedantic-errors`.
- **Python 3.8+** для адаптеров; **POSIX/MSYS2 `sh` и GNU Make** для libsodium и исходной сборки libpq. Используйте single-config generator: **Ninja** или **Unix Makefiles**. Multi-config generators не поддерживаются этими двумя адаптерами.
- Для **libpq из исходников** нужны Bison, Flex, Perl, GNU m4 и `nm`; исходной Windows-ветви также нужен `windres`. Совместимая готовая Windows x64/MSVCRT DLL выбирается до поиска PostgreSQL-specific host tools. Готовый `configure` сохранён; Autoconf/Automake повторно запускать не требуется.
- Для графики нужен SDK выбранного backend: OpenGL, OpenGL ES 3 либо Vulkan. В проверенном Linux-варианте используется системный `OpenGL::OpenGL`; Android GLES3 использует NDK `GLESv3` и `log`.

Зависимости не скачиваются при конфигурации или сборке. Компиляторы, SDK и перечисленные инструменты должны быть установлены заранее. Выбранным библиотечным реализациям не нужны C++/Fortran-компиляторы, OpenSSL или отдельно установленная mbedTLS. X11/GLX, GTK и AppIndicator не входят в обязательную цепочку сборки.

На Windows предусмотрен **MinGW-w64/MSYS2 с pthreads**; native MSVC не проверен и не заявлен. Наличие сохранённой OS-ветви исходников не означает, что вся коллекция уже собрана и выполнена на этой ОС.

## 3. Сборка библиотек

Все команды ниже выполняются из корня коллекции:

```sh
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel 4
```

Если Ninja не установлен, вместо `-G Ninja` можно указать `-G "Unix Makefiles"` в подходящей POSIX/MSYS2-среде. Для смены toolchain или generator используйте новый build-каталог.

Все `LMX_WITH_*` в [корневом CMakeLists.txt](CMakeLists.txt) заданы обычными `set(... ON)`. Это фиксированный принятый состав: `-DLMX_WITH_...=OFF` не является способом отключить группу. Изменение состава выполняется вручную с учётом зависимостей.

Корневой проект собирает библиотеки. Старые `BUILD_TESTING` и `LMX_BUILD_EXAMPLES` внутри него установлены в `OFF`, поскольку прежние полные fixtures в компактную поставку не входят. Новые отобранные программы и тесты имеют отдельные входы CMake, описанные ниже. `CMakePresets.json` в этом архиве нет: используйте явные команды, а не прежний `posix-release` preset.

### Примеры и тесты

```sh
cmake -S examples -B build-examples -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build-examples --parallel 4
ctest --test-dir build-examples --output-on-failure
```

Этот проект собирает библиотеки, 26 демонстрационных программ и отобранные проверки. Программы появляются в `build-examples/bin/`:

```sh
./build-examples/bin/lmx_example_sqlite_memory
./build-examples/bin/lmx_example_qr_image qr.pgm "Lingvamyxa"
./build-examples/bin/lmx_example_xlsx_roundtrip table.xlsx
./build-examples/bin/lmx_example_http_parser
```

На Windows у исполняемых файлов добавляется `.exe`. Выходные файлы создаются в текущем рабочем каталоге; имена и аргументы остальных демонстраций приведены в [руководстве примеров](examples/README_RU.md).

Только проверки:

```sh
cmake -S examples/checks -B build-checks -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build-checks --target lmx_usage_checks --parallel 4
ctest --test-dir build-checks -L lmx_usage_checks --output-on-failure
```

В Release у тестов остаётся включён `assert`. Сценарии имеют отдельные рабочие каталоги и тайм-ауты; внешние серверы БД, сертификаты, медиаархивы и датасеты им не нужны. Это выбранные проверки API, численных результатов и взаимодействия библиотек, а не полные upstream suites.

## 4. Подключение к приложению

Если коллекция лежит в `third_party/lmx_c99_compact`:

```cmake
cmake_minimum_required(VERSION 3.20)
project(MyApplication LANGUAGES C)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

add_subdirectory(third_party/lmx_c99_compact)
add_executable(my_lmx main.c)
target_link_libraries(my_lmx PRIVATE LMX::all)
lmx_copy_runtime(my_lmx)
```

`LMX::all` — INTERFACE-агрегатор зависимостей. Он передаёт библиотеки, include paths, определения и системные зависимости. Обычная статическая линковка извлекает нужные объектные файлы; она не обязана включить весь код всех архивов в executable.

Для существующего Qt/C++-приложения задайте в собственном `project` языки `C CXX`; сами C-зависимости сохранят свой стандарт. Qt не является зависимостью коллекции.

Можно линковать отдельные публичные targets, сохраняя полный состав собираемой коллекции:

```cmake
target_link_libraries(my_app PRIVATE
    LMX::curl LMX::llhttp LMX::sqlite3 LMX::sqlite_vec
    LMX::qrcodegen LMX::quirc LMX::static_embeddings)
lmx_copy_runtime(my_app)
```

Используйте настройки targets. Ручное копирование одной `.a` не переносит определения ABI, include paths и зависимости. Большинство включённых заголовочных реализаций разнесено по отдельным адаптерам: объединение всех `*_IMPLEMENTATION` в один C-файл может вызвать конфликты приватных имён и макросов.

`LMX::mint` и `LMX::utensil` — INTERFACE-цели; реализацию предоставляет приложение. Для Mint определите `MT_IMPLEMENTATION` перед включением `<mint.h>` ровно в одной единице трансляции, как в [mint_tensor.c](examples/collection/mint_tensor.c). Заголовок Utensil сам содержит внешние определения: включайте его ровно в одну единицу трансляции либо используйте собственный фасад деклараций; пример — [utensil_tensor.c](examples/collection/utensil_tensor.c). Само подключение `LMX::all` не создаёт эти две реализации.

### Windows DLL

[lmx_copy_runtime](cmake/WindowsRuntime.cmake) копирует рядом с executable применимые `libpq.dll` и `libwinpthread-1.dll`; на POSIX функция ничего не делает. Для winpthreads предпочитается runtime активного компилятора; поставляемый fallback разрешён только для проверенного ABI и сверяется по SHA-256.

- [Manifest libpq](extensions/postgresql/prebuilt/windows-x86_64/manifest.json): готовая Windows x64/MSVCRT DLL размером **401 267 байт**, соответствующие headers/import library. Совместимость проверяет [адаптер PostgreSQL](extensions/postgresql/CMakeLists.txt); другая поддерживаемая MinGW-конфигурация использует исходную сборку. Предустановленная libpq не предполагается.
- [Manifest winpthreads](prebuilt/windows-x86_64/runtime/manifest.json): поставляемый runtime размером **325 114 байт**. Он нужен другим компонентам общей сборки; готовая libpq DLL сама импортирует только системные Windows DLL.

Две DLL вместе занимают **726 381 байт**. Собственный код приложения и дополнительные зависимости могут добавить другие runtime-файлы. Разрядность и CRT должны соответствовать приложению; x64 DLL не предназначена для 32-битного процесса.

## 5. Существенные особенности компонентов

### Сеть и БД

curl и libssh2 используют общую конфигурацию mbedTLS/mbedcrypto. SCP/SFTP в curl подключены через libssh2. Согласованные параметры находятся в [настройках curl](cmake/CURL_ZLIB.cmake), [настройках TLS](cmake/MbedTLS.cmake) и [группе systems](extensions/systems/CMakeLists.txt).

`LMX::llhttp` / `LMX::http_parser` предоставляют потоковый HTTP-парсер. Сокеты, TLS transport, соединения, маршрутизацию и время жизни HTTP-сервера организует приложение. llhttp не содержит готового сервера; исходящие HTTPS-запросы выполняет curl.

Наличие общей mbedTLS не включает TLS автоматически во всех драйверах БД. В этой поставке hiredis собрана без OpenSSL-адаптера; libpq — без TLS, но с SCRAM-SHA-256; libmongoc — без TLS и crypto-backend для SCRAM, без SASL/Kerberos/AWS/CSE. Состав задают [правила БД](extensions/databases/CMakeLists.txt) и [правила libpq](extensions/postgresql/CMakeLists.txt). Проверки URI/протоколов без сервера не являются проверкой подключения к реальной БД.

### Графика, аудио и видео

В [графической группе](extensions/graphics/CMakeLists.txt) `LMX_GRAPHICS_SOKOL_BACKEND` выбирает `GLCORE`, `GLES3` или `VULKAN`. Desktop default — GLCORE; для Android/Emscripten/iOS — GLES3. Приложение предоставляет окно, current GL/GLES context либо Vulkan device/queue и presentation. Оконные `sokol_app`/glue и аудиоустройство Sokol в target не входят. Vulkan backend экспериментален в закреплённой версии upstream; требования к API и features остаются требованиями этого backend. Android-проверка выполнена для GLES3.

RGFW и tray исключены. Nuklear и microui требуют вывода через renderer приложения; отдельная miniaudio предоставляет аудиоустройства. tinyfiledialogs на UNIX собирается без GTK/X11-заголовков, но при работе может вызывать установленные `zenity`/`kdialog` или консольный fallback; это не гарантия GUI в headless-среде. Детали есть в [заголовке tinyfiledialogs](vendor/tinyfiledialogs/tinyfiledialogs.h).

`jo_mp1` декодирует MP1. `minih264` — энкодер; включённый H.264 Baseline-декодер — h264bsd. Nestegg разбирает WebM-контейнер. libwebp mux/demux не обещает отсутствие буферизации кадров. Звуковое устройство и реальные графические окна при проверке компактной поставки не использовались.

### Математика, тензоры и машинное обучение

[c99_gsl.h](include/c99_gsl.h) и [c99_quad.h](include/c99_quad.h) дают общую точку входа. Имя `c99_gsl_lite` не означает совместимость с полным API/ABI GSL. MPDecimal выполняет десятичную арифметику, а не бинарную арифметику MPFR; linmath/cglm ориентированы на небольшие графические матрицы.

Mint включена как проверенная CPU-тензорная часть; полный model runtime не заявлен. EmbeddedLapack исключена после воспроизведённых ошибок памяти. Связка с ней не представлена как готовый модуль NumPy/MATLAB.

[Модуль static embeddings](extensions/embeddings/include/lmx_static_embeddings.h) принимает готовые token IDs и float-векторы. Tokenizer, загрузчик GGUF/safetensors и веса модели в него не входят.

NNoM выполняет квантованный inference, а не обучение. Сохранено scalar-ядро q7/q15; CMake применяет небольшие проверенные поправки в сборочной копии. Вызывающая сторона сохраняет buffers/descriptors; optimized dense для групп из четырёх выходов требует upstream x4-packed weights. Проверки Dense/Conv2D и времени жизни памяти не подтверждают все режимы каждого слоя. См. [адаптер](extensions/nnom/CMakeLists.txt) и [сценарии проверок](examples/checks/INDEX_RU.md).

TinyCThread предоставляет часть потокового API C11; это не эмулятор языка C11, `_Atomic`, `_Generic` или требований других компиляторов. ggml, dav1d/libavif, edge264 и Box2D v3 в принятую коллекцию не входят.

### DSP, коррекция ошибок и орбиты

Liquid-DSP использует внутренний FFT: интеграция не ищет и не подключает FFTW. libquiet обменивается PCM-буферами; его можно связать с miniaudio без PortAudio/libsndfile. Готовый протокол передачи файлов с повторами и аутентификацией это само по себе не создаёт. Пример [acoustic_loopback.c](examples/collection/acoustic_loopback.c) работает без аудиоустройства.

У libcorrect свёрточный API использует битовые длины, RS — байтовые; код коррекции не гарантирует обнаружение любого повреждения сверх своих возможностей. SGP4 вычисляет положение и скорость в TEME; азимут и Доплер требуют дополнительной геометрии наблюдателя. В адаптированной C-реализации Unix timestamps в миллисекундах используют `int64_t`; относительное время в минутах и Julian dates сохраняют тип `double`.

## 6. Примеры, справки и границы проверки

В `examples/` сохранено **268 файлов, 1 429 932 байта**: это общий объём программ, кратких справок, тестов, индексов происхождения и CMake-файлов. Лимит дополнения составлял 30 МБ; объём не увеличивался искусственно.

- **26 программ коллекции:** заново собраны в строгом C99 и запущены на Linux. Для Windows все 26 скомпилированы и слинкованы.
- **182 upstream-файла для 62 компонентов:** 140 программ, 4 фрагмента, 21 краткая справка, 2 SQL-файла подготовки и 15 вспомогательных файлов. Они просмотрены, но все программы не собирались и не запускались. Дополнительные требования отмечены в [индексе](examples/UPSTREAM_INDEX_RU.md); эти примеры не входят в автоматическую сборку 26 программ. Примеры со своим `*_IMPLEMENTATION` нельзя одновременно линковать со второй реализацией той же библиотеки.
- **46 проверочных программ / 51 CTest-сценарий на Linux:** все прошли. Для Windows собраны 44 программы, зарегистрированы 49 сценариев; две UNIX-проверки там не включаются. Windows-сценарии не запускались.

### Выполненные проверки компактной поставки

| Платформа | Проверено |
|---|---|
| Linux x86-64, GCC 14.2.0 | 1 512 строгих C99-команд, включая 4 проверочных translation units; 122 статических архива; общая принудительная линковка и запуск; 26 демонстраций и 51 сценарий |
| Windows x64, MinGW-w64 GCC 14.2.0 | 1 503 строгих C99-команды основной проверки; 119 статических архивов; общая линковка; дополнительно 26 примеров и 44 тестовые программы. PE-файлы не запускались |
| Android arm64-v8a, API 26, NDK 30.0.16248370 | Только графическая часть, GLES3: 28 C99-команд; 12 графических архивов вместе с zlib слинкованы в AArch64 ELF. Запуска на устройстве не было |
| macOS | Платформенные входы сохранены; нативная сборка и запуск не выполнялись |

Linux-конфигурация и сборка выполнены с запретом сетевых соединений. Наборы сильных определений всех проверенных производственных статических архивов совпали с полной коллекцией на Linux и Windows. Это проверка сохранения состава, а не доказательство корректности каждого API на всех ОС и CPU. Общая Android-сборка всех библиотек не заявляется.

Исходный compact-архив содержит **4563 файла**, сумма их размеров — **93 186 264 байта (88,87 МиБ)**. Архив `.tar.gz` занимает **18 832 800 байт (17,96 МиБ)**. Эти измерения относятся к выпущенному архиву до добавления этой пары README. Собранные проверочные executable в архив не включены.

## 7. Лицензии и дальнейшая интеграция

Точные сведения и пути к текстам находятся в [SOURCES.json](SOURCES.json). Сохранены применимые LICENSE/COPYING/NOTICE и дополнительные уведомления. Mint и afan Neural-Network оставлены с явным **NOASSERTION**: это отсутствие установленной лицензии, а не обозначение MIT или Public Domain.

Собственная интеграция покрывается [LICENSE.integration](LICENSE.integration), если в файле не указано иначе; модуль статических эмбеддингов имеет [отдельную MIT-лицензию](extensions/embeddings/LICENSE). Производные адаптации сохраняют условия соответствующего upstream. Лицензии готового runtime и его исключения сохранены рядом с [Windows-файлами](prebuilt/windows-x86_64/licenses/).

Для подключения `c.*` к существующей модели акторов используйте [памятку по FFI](examples/reference/C_FFI_QUICK_RU.md): allocator hooks, владение объектами, штатное освобождение и граница завершения нативного исполнения. Это задел для интеграции, а не уже реализованный механизм исполнения LMX. Память нативного вызова нельзя освобождать, пока код или его callbacks ещё могут её использовать.

Индексы, правила сборки и примеры в этой редакции открываются непосредственно из компактного каталога. Старые отчёты, дополнительные файлы-идеи и исходный полный архив для разрешения ссылок не требуются.
