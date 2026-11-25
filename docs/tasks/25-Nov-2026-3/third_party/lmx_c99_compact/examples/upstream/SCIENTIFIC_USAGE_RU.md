# Контейнеры, математика, DSP и небольшие сети: примеры использования

Здесь собраны выбранные upstream-программы на C. Каждый `.c` — отдельный пример, если в таблице не указано иначе. Исходные программы не изменены; рядом добавлены только три маленьких заголовка для связи с публичными именами и C99-представлениями коллекции. Программы просмотрены по исходному коду, но в рамках этой подборки заново не компилировались и не запускались. Их не следует считать дополнительным пройденным набором тестов.

Уже проверенные примеры интеграции находятся в соседнем каталоге `../collection`. С них удобнее начинать, если нужен готовый пример для выбранных настроек всей коллекции. Все пути ниже относительны к `examples/upstream/`.

## Подключение одного примера

Минимальный `CMakeLists.txt` приложения, рядом с которым лежит каталог коллекции:

```cmake
cmake_minimum_required(VERSION 3.20)
project(usage_sample C)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

set(LMX_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/lmx_c99_compact")
add_subdirectory("${LMX_ROOT}" lmx)

add_executable(decimal_sqrt
    "${LMX_ROOT}/examples/upstream/mpdecimal/libmpdec/examples/sqrt.c")
target_link_libraries(decimal_sqrt PRIVATE LMX::mpdec)
if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(decimal_sqrt PRIVATE -pedantic-errors)
endif()
```

Собрать `decimal_sqrt` и передать ему аргумент `2`: программа печатает корень и флаги десятичного контекста. Для другого примера замените исходный путь и CMake-цель из таблицы. Не объединяйте несколько файлов с `main()` в один executable. Не добавляйте повторно исходники самих библиотек: они уже входят в соответствующие цели.

## Контейнеры и строки

| Исходный файл | Цель | Что показывает |
|---|---|---|
| `stc/examples/vectors/new_vec.c` | `LMX::stc` | Типизированный вектор структур и пользовательская сортировка. |
| `stc/examples/hashmaps/hashmap.c` | `LMX::stc` | Строковая hash map: вставка, поиск, обновление, удаление. |
| `stc/examples/priorityqueues/new_pqueue.c` | `LMX::stc` | Очередь приоритетов с пользовательским сравнением. |
| `stc/examples/bitsets/bits.c` | `LMX::stc` | Биты, расширение набора, клонирование и XOR. |
| `stc/examples/spans/multidim.c` | `LMX::stc` | Многомерные views, срезы и изменение исходного массива. |
| `stc/examples/strings/splitstr.c` | `LMX::stc` | Разбиение строк через views и regex. |
| `stc/examples/regularexpressions/regex_match.c` | `LMX::stc` | Поиск чисел в тексте и замена совпадений. |
| `stc/examples/coroutines/fibonacci.c` | `LMX::stc` | Кооперативный генератор и его завершение. |
| `klib/test/klist_test.c` | `LMX::klib_headers` | Короткий жизненный цикл списка. |
| `klib/test/kbarena_test.c` | `LMX::klib` | Выделение в арене, сохранение и восстановление позиции. |
| `klib/test/kseq_test.c` | `LMX::klib_headers`, `LMX::zlib` | Чтение пользовательского FASTA/FASTQ, в том числе gzip. |
| `klib/test/ketopt_test.c` | `LMX::klib_headers` | CLI-параметры; сравнение с системным `getopt_long`. |

Для STC используйте определения, передаваемые целью, в том числе `STC_HAS_TYPEOF=0`. Слово `test` в сохранённом upstream-пути не означает, что скопирован весь тестовый набор: здесь только четыре коротких программы klib. Последняя из них дополнительно требует системный `getopt.h` с `getopt_long`; самой `ketopt.h` этот внешний интерфейс не нужен.

`kseq_test.c` принимает путь к доступному входному файлу; данные в поставку не включены. При переносе этого минимального примера в приложение добавьте обработку ошибки `gzopen`.

## Десятичные числа и численные методы

| Исходный файл | Цель | Пример аргументов / назначение |
|---|---|---|
| `mpdecimal/libmpdec/examples/sqrt.c` | `LMX::mpdec` | `2` — корень с 38 значащими цифрами. |
| `mpdecimal/libmpdec/examples/powmod.c` | `LMX::mpdec` | `2 100 17` — модульное возведение в степень. |
| `mpdecimal/libmpdec/examples/divmod.c` | `LMX::mpdec` | `100 7` — целая часть частного и остаток. |
| `mpdecimal/libmpdec/examples/compare.c` | `LMX::mpdec` | `1.00 1` — сравнение десятичных значений. |
| `decnumber/example1.c` | `LMX::decnumber` | `1.25 2.50` — сложение `decNumber`. |
| `decnumber/example3.c` | `LMX::decnumber` | `1000 5 10` — проценты, округление, проверка ошибок. |
| `decnumber/example5.c` | `LMX::decnumber` | `123.45` — строка ↔ `decimal64`, просмотр байтов. |
| `decnumber/example7.c` | `LMX::decnumber` | `0.1 0.2` — сложение `decQuad`. |
| `tinyspline/examples/c/quickstart.c` | `LMX::tinyspline` | B-spline, оценка, производная, Bezier и освобождение. |
| `cmpfit/testmpfit.c` | `LMX::cmpfit` | Линейная/квадратичная/Gaussian модель, фиксированные параметры. |
| `cquadpack/test/dqagtst.c` | `LMX::quadpack` | Интегрирование на конечном интервале разными правилами. |
| `cquadpack/test/dqagit.c` | `LMX::quadpack` | Интегрирование по бесконечному интервалу и оценка ошибки. |
| `wavelib/test/dwt2test.c` | `LMX::wavelib` | Двумерный DWT и обратное восстановление матрицы. |
| `kissfft/tools/fftutil.c` | `LMX::kissfft` | Потоковое 1D/ND FFT, реальные и комплексные данные. |

В примерах decNumber размер локального `decNumber` задаётся выбранным `DECNUMDIGITS` или форматом. Не добавляйте противоречащее определение точности сразу ко всему приложению. MPDecimal — десятичная арифметика: эти демонстрации не обещают бинарную семантику MPFR.

`testmpfit.c` самим автором описан как учебные примеры. Небольшие массивы точек находятся в программе; внешний журнал эталонных результатов не нужен для её работы. Текст условий CMPFIT/MINPACK сохранён в `vendor/cmpfit/DISCLAIMER`.

Два заголовка связывают неизменные демонстрации с коллекцией:

- `cquadpack/test/cquadpack.h` включает `lmx_quadpack.h` и отображает только используемые `dqag`/`dqagi` на их публичные имена `lmx_quadpack_*`.
- `wavelib/header/wavelib.h` направляет относительное включение примера к `<wavelib.h>` из `LMX::wavelib`. Это важно: цель предоставляет проверенное C99-представление, а исходный upstream-заголовок содержит массивы нулевой длины. Каталог этого маленького forwarder не добавляйте как отдельный `-I`.

`fftutil` — POSIX CLI с `getopt`. Он принимает двоичные массивы соответствующего `kiss_fft_scalar`, а не WAV-файлы. Размерности должны быть положительными и допустимыми, кадры полными. Исходный CLI не проверяет все ошибки чтения и аргументов. Для первого FFT без входных файлов удобнее [scientific_pipeline.c](../collection/scientific_pipeline.c).

## DSP без звукового устройства

Выбранные Liquid-DSP программы используют `LMX::liquid_dsp`. Для их общего CLI-заголовка добавьте только:

```cmake
target_include_directories(dsp_demo PRIVATE
    "${LMX_ROOT}/examples/upstream/liquid_dsp/include")
```

Каждый `.c` собирается отдельно: `liquid.argparse.h` содержит определения CLI-функций. Цель предоставляет публичный C99-заголовок Liquid-DSP, pthread-зависимость и `_XOPEN_SOURCE=700`. Примеры рассчитаны на POSIX-совместимый `getopt.h`. Звуковая карта, PortAudio, PCM-файлы и внешние FFT-библиотеки им не нужны.

| Файл в `liquid_dsp/examples/` | Действие |
|---|---|
| `fft_example.c` | Прямое/обратное FFT и ошибка восстановления. |
| `firfilt_crcf_example.c` | FIR-фильтр для комплексного сигнала. |
| `firdespm_example.c` | Проектирование Parks–McClellan. |
| `nco_example.c` | Осциллятор и оценка спектра. |
| `resamp_crcf_example.c` | Произвольное изменение частоты дискретизации. |
| `modem_example.c` | Модуляция и демодуляция символов. |
| `fskmodem_example.c` | FSK-связь в синтетическом шуме. |
| `crc_example.c` | Обнаружение повреждения сообщения. |
| `fec_example.c` | Исправление ошибок в блоке. |
| `framesync64_example.c` | Генерация кадра, приём и callback. |

Запускайте с `-h` для описания параметров. Некоторые программы **записывают** `.m`-скрипт для последующего построения графика; MATLAB/Octave не участвует в C-вычислениях. Эти выходные файлы не входят в поставку. Пользовательские размеры и частоты должны оставаться в допустимом диапазоне из подсказки программы.

Для передачи байтов через PCM в памяти используйте [acoustic_loopback.c](../collection/acoustic_loopback.c), для Reed–Solomon — [rs_recovery.c](../collection/rs_recovery.c). Upstream-интеграционные тесты Quiet и длительные рандомизированные тесты libcorrect сюда не переносились.

## Нейросети и тензоры

| Исходный файл | Цель | Назначение |
|---|---|---|
| `genann/example1.c` | `LMX::genann` | Создание, обучение, вычисление и освобождение небольшой MLP. |
| `kann/examples/mlp.c` | `LMX::mlp_kann` | MLP с пользовательскими текстовыми/gzip матрицами; save/load. |
| `kann/examples/rnn-bit.c` | `LMX::kann` | GRU, разворачивание графа, обучение на целочисленных строках. |
| `kann/examples/inspect.c` | `LMX::kann` | Вывод графа пользовательской модели, в том числе DOT. |
| `afan_neural_network/main.c` | `LMX::afan_neural_network` | Учебное обучение XOR и сохранение/загрузка. |
| `mint/examples/simple/simple.c` | `LMX::mint` | CPU-тензоры, арифметика и broadcasting. |

Genann и Afan создают веса во время выполнения. Успешное обучение XOR при любом случайном начальном состоянии не гарантируется. KANN CLI требует POSIX `getopt` и пользовательские входные данные; датасеты и модели не приложены. Примеры предполагают корректные читаемые файлы. Для POSIX-сборки их можно дополнить `target_compile_definitions(demo PRIVATE _POSIX_C_SOURCE=200809L)`.

Afan записывает `my_network.txt`. Upstream-пример не освобождает отдельно загруженную сеть перед выходом; при переносе в длительно работающий процесс добавьте `free_network(loaded_network)`. Для Afan и Mint у выбранного upstream-снимка нет заявленной лицензии (`NOASSERTION`); это отражено в общих notices коллекции.

`mint/mint.h` — третий маленький forwarder. Он сохраняет исходный `../../mint.h` и направляет его к C99-представлению `LMX::mint`. Не включайте каталог forwarder в поиск заголовков. Сам `simple.c` определяет `MT_IMPLEMENTATION`, поэтому отдельная вторая реализация Mint в этом executable не нужна. Сохраняйте передаваемое целью `LMX_MINT_TENSORS_ONLY=1`.

Без датасетов и с проверенной интеграцией также доступны [genann_regression.c](../collection/genann_regression.c), [kann_regression.c](../collection/kann_regression.c), [nnom_dense.c](../collection/nnom_dense.c), [tinn_curve.c](../collection/tinn_curve.c), [mint_tensor.c](../collection/mint_tensor.c), [utensil_tensor.c](../collection/utensil_tensor.c) и [static_embeddings.c](../collection/static_embeddings.c). NNoM-примеры с большими сгенерированными `weights.h` и изображения не включены.

## Остальные полезные отправные точки

- [precision.c](../collection/precision.c) — LibTomMath и MPDecimal с проверкой результатов.
- [quadrature.c](../collection/quadrature.c) — интерфейс конечных/бесконечных интегралов, многомерных правил и Sobol.
- [tle_orbit.c](../collection/tle_orbit.c) — TLE и положения/скорости в TEME; вычисление азимута наблюдателя и Doppler — отдельная геометрия.
- [arena_numbers.c](../collection/arena_numbers.c) — TLSF и форматирование Ryu.
- [text_paths.c](../collection/text_paths.c) — пути cwalk и UTF-8.

Версии, закреплённые commits, исходные URL и условия распространения указаны в корневом `SOURCES.json`. Оригинальные copyright/license-комментарии в примерах сохранены. Три новых header-forwarder и этот справочный текст относятся к интеграционной части коллекции (`LICENSE.integration`, 0BSD).
