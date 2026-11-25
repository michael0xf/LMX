# LMX: статический набор библиотек C99 / POSIX

Состав согласован 25 ноября 2026 года. Сетевая часть использует **CivetWeb 1.16,
curl 8.23.0, общую mbedTLS 3.6.7 и zlib 1.4**. Математическая часть собрана
из небольших библиотек с отдельными API. GSL, GMP, MPFR, OpenSSL, Mongoose
и Cubature исключены из активного набора.

Все исходники выбранного профиля находятся в `vendor/`. Конфигурирование
и сборка не скачивают зависимости. Исходные конфигурационные файлы, примеры,
лицензии и документация новых математических библиотек сохранены; рабочая
интеграция и дополнительные примеры находятся рядом с ними.

Актуальные результаты проверок и границы проверенной платформы приведены
в [docs/validation/README_RU.md](docs/validation/README_RU.md).

## Состав

| Компонент | Зафиксированная версия | Назначение |
|---|---|---|
| CivetWeb | 1.16 | HTTP/HTTPS и WebSocket-сервер |
| curl | 8.23.0 | Исходящие сетевые запросы, включая HTTPS |
| mbedTLS | 3.6.7 | Одна общая TLS/криптографическая сборка для клиента и сервера |
| zlib | 1.4 | Сжатие, HTTP gzip/deflate, BGZF |
| SQLite | 3.54.1 | Встроенная SQL-база: только официальные `sqlite3.c` и `sqlite3.h` |
| stb | Основной commit `6b5799bae8a1fe3792691ef4b72ae26434c3e799` | Выборка C99; resize и sprintf закреплены отдельно |
| klib | Commit `97a0fcb790b43b9e5da8994f4671021fec036f19` | Контейнеры, алгоритмы, POSIX, pthreads, BGZF и kurl |
| STC | 5.0 | Контейнеры, строки и прочая выбранная C99-часть |
| decNumber | 3.68 | Десятичная арифметика и фиксированные десятичные форматы |
| libsodium | 1.0.22-stable | Криптографические операции и генерация случайных данных |
| SLJIT | Commit `23d64b71b8f5fa51d774a01459770f7e1b68d371` | JIT; версия API в заголовке 0.95 |
| linmath.h | Commit `3eef82841046507e16a0f6194a61cee2eadd34b3` | Небольшие векторы, матрицы и кватернионы |
| KissFFT | 131.1.0 | FFT; по умолчанию скаляр `double` |
| TinySpline | 0.6.0 | NURBS, B-сплайны, кривые Безье |
| Wavelib | Commit `7f61bf592f3c470b2a7d8199431fde821d7253ac` | Вейвлетные преобразования |
| Cephes | Закреплённые исходники Netlib | Спецфункции и распределения; экспорт `lmx_cephes_*` |
| CMPFIT | 1.5 | Нелинейный метод наименьших квадратов |
| xoshiro256** / SplitMix64 | Закреплённые авторские исходники | Численный PRNG с явным состоянием |
| LibTomMath | 1.3.0 | Целые числа произвольной точности |
| MPDecimal / libmpdec | 4.0.1 | Десятичные числа произвольной точности |
| CQUADPACK | 1.1.1 | C-порт QUADPACK: адаптивное одномерное интегрирование |
| Stroud | Текущий снимок `stroud_rule` с сайта автора | Многомерные квадратурные правила |
| Sparse Grid HW | Текущий снимок с сайта автора | Разреженные сетки для многомерных интегралов |
| Sobol | Текущий авторский снимок + адаптация C99 | Квазислучайные последовательности и QMC-интегрирование |

Замена Cubature включена отдельным модулем `c99_quad_lite`: QUADPACK,
Stroud, Sparse Grid HW и Sobol. Точные источники, адаптации API и состояние
проверки этой группы описаны в `docs/QUADRATURE.md`. У автора Sobol исходная
версия написана на C++; она сохранена, а в target компилируется проверенная
адаптация C99. C++ runtime не требуется.

Версии, явно указанные пользователем, сохранены. В остальных случаях взят
релиз либо закреплённый снимок авторских исходников. Снимок без официального
релиза не обозначается как stable-релиз. Все URL, commit ID и контрольные
суммы доступны в `provenance/`.

SQLite подключена по умолчанию (`LMX_WITH_SQLITE3=ON`). Сохранены обычные
возможности upstream и режим `SQLITE_THREADSAFE=1`. Отдельного SQL-сервера
или сторонних пакетов для неё не нужно. Подробности и проверенные контрольные
суммы: [docs/SQLITE3.md](docs/SQLITE3.md).

Полные исходники можно восстановить офлайн из сохранённых оригинальных
архивов и отдельных файлов: [SOURCE_RESTORATION_RU.md](docs/SOURCE_RESTORATION_RU.md).
Общий архив коллекции уже содержит готовое дерево `vendor/` и все файлы
интеграции; после распаковки можно сразу выполнять команды сборки ниже.
Оригинальные архивы сохранены дополнительно для воспроизводимости. Если
`vendor/` отсутствует в отдельной копии проекта, восстановите его командой
`python3 scripts/restore_vendor.py` до конфигурирования.

## Сборка

Для полного профиля нужны C99-компилятор GCC/Clang, CMake **3.20+**, POSIX sh,
make, linker/archiver и Ninja либо Unix Makefiles. Готовый configure-скрипт
libsodium входит в исходники; Autoconf/Automake и GNU m4 для этого состава
не требуются. Отдельной установки OpenSSL/mbedTLS/zlib не требуется.
C++ и Fortran не нужны для библиотечных targets.

```sh
cmake -S . -B build/lmx -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DLMX_STRICT_C99=ON \
    -DBUILD_TESTING=ON \
    -DLMX_BUILD_EXAMPLES=ON
cmake --build build/lmx --parallel 4
ctest --test-dir build/lmx --output-on-failure
./build/lmx/lmx_math_example
./build/lmx/lmx_sqlite3_example
```

Либо с сохранёнными настройками:

```sh
cmake --preset posix-release
cmake --build --preset posix-release --parallel 4
ctest --preset posix-release
```

`math-only` — отдельный preset математической части без сети, контейнеров,
SQLite и runtime-библиотек. Сборка `Release` и сборка `Debug` должны иметь разные
каталоги. Для переключения с прежней редакции с OpenSSL используйте новый
build-каталог.

Минимум CMake повышен относительно предложенного примера 3.16: используемая
версия curl уже требует 3.18, а сохранённые build/test presets используют
возможности 3.20. Это требование инструмента сборки, не стандарта C.

## Подключение к приложению

```cmake
cmake_minimum_required(VERSION 3.20)
project(MyApplication LANGUAGES C)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

set(BUILD_TESTING OFF CACHE BOOL "Dependency tests")
set(LMX_BUILD_EXAMPLES OFF CACHE BOOL "Dependency examples")
add_subdirectory(third_party/lmx_c99_bundle)
add_executable(my_lmx main.c)
target_link_libraries(my_lmx PRIVATE LMX::all)
```

Для математики сохранено предложенное имя:

```cmake
target_link_libraries(my_app PRIVATE c99_gsl_lite) # также LMX::math
```

```c
#include "c99_gsl.h"
```

Для сети:

```cmake
target_link_libraries(my_app PRIVATE LMX::curl LMX::civetweb)
```

В Qt-проекте можно включить `LANGUAGES C CXX`, собирать C-файлы как C99 и
подключать те же targets к приложению. Сам Qt не является зависимостью
коллекции. Полный пример подключения находится в `examples/consumer/`.

### Основные targets

| Target | Состав |
|---|---|
| `LMX::all` | Все включённые группы |
| `c99_gsl_lite`, `LMX::math` | Математическая группа: scientific + precision, с подключаемой квадратурой |
| `LMX::scientific` | linmath, KissFFT, TinySpline, Wavelib, Cephes, CMPFIT, RNG |
| `LMX::precision` | LibTomMath и MPDecimal |
| `c99_quad_lite`, `LMX::quadrature` | QUADPACK, Stroud, Sparse Grid HW и Sobol |
| `LMX::quadpack`, `LMX::stroud`, `LMX::sparse_grid_hw`, `LMX::sobol` | Отдельные компоненты квадратуры |
| `LMX::linmath`, `LMX::kissfft`, `LMX::tinyspline`, `LMX::wavelib` | Отдельные компоненты |
| `LMX::cephes`, `LMX::cmpfit`, `LMX::rng` | Отдельные компоненты |
| `LMX::tommath`, `LMX::mpdec`, `LMX::decnumber` | Три разных API арифметики |
| `LMX::curl`, `LMX::civetweb`, `LMX::zlib` | Сетевые библиотеки и сжатие |
| `LMX::mbedtls`, `LMX::mbedx509`, `LMX::mbedcrypto` | Три части одного исходного дистрибутива mbedTLS |
| `LMX::sodium`, `LMX::sljit` | Криптография и JIT |
| `LMX::sqlite3` | SQLite amalgamation; `#include "sqlite3.h"` |
| `LMX::stb`, `LMX::stb_headers` | Реализации и заголовки stb |
| `LMX::stb_leakcheck` | Отдельное подключаемое инструментирование malloc/free |
| `LMX::klib`, `LMX::klib_headers` | klib, включая BGZF/kurl в POSIX-профиле |
| `LMX::klib_posix`, `LMX::klib_threads` | POSIX и pthreads-части |
| `LMX::stc`, `LMX::stc_headers` | STC |

Targets передают необходимые include paths, определения ABI и транзитивные
библиотеки. Не копируйте вручную только `.a` и один заголовок: например,
LibTomMath требует согласованного `MP_32BIT`, MPDecimal — сгенерированного
`mpdecimal.h`, mbedTLS — одинаковой конфигурации у библиотеки и потребителя.
`LMX::all` — интерфейсный CMake-target, а не вручную склеенный `.a`.
Статические зависимости попадут в один executable обычной линковкой.

Для квадратуры используется `#include "c99_quad.h"`. Общий `c99_gsl.h`
включает его при `LMX_WITH_QUADRATURE=ON` (значение по умолчанию).
`examples/quadrature/main.c` показывает адаптивный интеграл `sin(x)/x`
и QMC по трёхмерному единичному кубу. В CQUADPACK фактический callback
принимает `userdata`; простые обёртки `c99_quad_dqags`, `c99_quad_dqagi`
и `c99_quad_dqk21` сохраняют удобную форму из предложенного примера.
`c99_quad_qmc_sobol` работает с массивом координат, проверяет входные данные
и использует компенсированное суммирование.

## Смысл математической замены

`c99_gsl_lite` сохранён как удобное имя агрегатора. Эта коллекция не реализует
API/ABI GSL и не покрывает весь её набор алгоритмов. `linmath.h` рассчитана
на небольшую графическую линейную алгебру; она не заменяет произвольные
плотные/разреженные решатели, BLAS и LAPACK.

LibTomMath реализует длинные целые числа с собственным API. MPDecimal считает
в **десятичной** арифметике; точность задаётся количеством десятичных цифр.
Она не превращает результаты в бинарную арифметику MPFR и не предоставляет
всю её библиотеку функций. decNumber и MPDecimal остаются отдельными API:
их объекты нельзя приводить друг к другу указателем.

В примере `examples/main.c` исправлены размер выходного буфера, проверка
возвращаемых ошибок и освобождение памяти через `mpd_free`. RNG имеет явное
состояние `lmx_rng` и инициализацию `lmx_rng_seed`; функции `next()` двух
исходных генераторов не конфликтуют. Для ключей и токенов используйте
libsodium, для воспроизводимых численных расчётов — xoshiro/SplitMix.

Cephes публикуется с префиксом `lmx_cephes_`, поэтому не подменяет `gamma`,
`erf`, `j0` или функции стандартного `<complex.h>`. Её прежние глобальные
состояния ошибки/знака сохранены и требуют координации при конкурентном
использовании. Подробности: `docs/SCIENTIFIC_RU.md`, `docs/PRECISION.md`.

## Сеть и общая TLS-библиотека

curl и CivetWeb статически связываются с одной конфигурацией mbedTLS 3.6.7.
Клиентские HTTPS-запросы выполняет curl. В mbedTLS-адаптере CivetWeb 1.16
нет реализации его собственного HTTPS/WSS-клиента и проверки клиентских
сертификатов на сервере (mTLS); наличие TLS 1.3 не добавляет эти API.

Сервер использует POSIX-потоки. Общий генератор случайных чисел mbedTLS
собран с pthreads-защитой. Если LMX обрабатывает своё состояние в одном
потоке, обработчики CivetWeb должны передавать события этому потоку
средствами приложения.

Жизненный цикл общей TLS:

1. Один раз инициализировать curl и запустить серверы.
2. Выполнять клиентские запросы и обслуживать соединения.
3. Остановить все CivetWeb-серверы и завершить работу TLS-потребителей.
4. После этого вызвать `curl_global_cleanup()`.

Последний шаг важен: очистка curl затрагивает общее PSA-состояние mbedTLS.
Приложение задаёт доверенные CA для клиента и сертификат/ключ для сервера.
Тестовые PEM-файлы в `tests/` служат только локальной проверке.

Полный список библиотечных и системных зависимостей, отключённых опций curl
и адаптации CivetWeb: `docs/NETWORK_DEPENDENCIES_RU.md`, `docs/CIVETWEB.md`,
`docs/CURL_ZLIB.md` и `docs/MBEDTLS.md`.

## C99, переносимость и сохранность

CMake задаёт `C_STANDARD 99`, `C_STANDARD_REQUIRED ON`, `C_EXTENSIONS OFF`;
при `LMX_STRICT_C99=ON` GCC/Clang получают `-pedantic-errors`.
POSIX разрешён. Это профиль для обычной платформы с системной C-библиотекой,
потоками и сокетами, а не обещание работы на любом freestanding-компиляторе.
Архитектурные JIT-backends SLJIT и разрешённые compiler intrinsics описаны
в документах компонентов.

Текущий полный адаптер рассчитан на native POSIX и single-config генератор
Ninja/Unix Makefiles. Это не проверенная универсальная сборка для MSVC,
32-битных платформ, cross compilation либо Apple universal binaries.
Исходные платформенные конфигурации библиотек сохранены, но их наличие не
является результатом тестирования на этих платформах.

Исходники upstream остаются неизменёнными. Необходимые поправки C99 создаются
в build-каталоге: например, указание ABI MPDecimal, допустимые C99 flexible
arrays Wavelib, параметры матриц linmath и адаптация CivetWeb к mbedTLS 3.6.
Их точный перечень находится в документах и CMake-файлах компонентов.

Лицензии и требования к уведомлениям для распространения закрытого бинарника
описаны в [LICENSES_AND_DISTRIBUTION_RU.md](docs/LICENSES_AND_DISTRIBUTION_RU.md).
`LICENSE.integration` относится только к новым интеграционным файлам и не
заменяет лицензии библиотек и производных от них адаптаций.
