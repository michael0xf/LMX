# Проверки API и совместной работы библиотек

Linux x86-64: 46 программ, 51 CTest-сценарий; все заново собраны с `-std=c99 -pedantic-errors`, утверждения включены, все 51 запуска прошли. Windows x64: 44 программы скомпилированы и слинкованы, 49 сценариев зарегистрированы; запуск на Windows не выполнялся. Только hiredis socketpair fixture и видео-проверка требуют UNIX.

Общий target — `lmx_usage_checks`, метка CTest — `lmx_usage_checks`. Каждый случай имеет отдельный рабочий каталог и тайм-аут. Внешние серверы, медиафайлы и датасеты не требуются. Временные файлы создаются внутри build.

```sh
cmake -S examples/checks -B build-checks -DCMAKE_BUILD_TYPE=Release
cmake --build build-checks --target lmx_usage_checks --parallel
ctest --test-dir build-checks -L lmx_usage_checks --output-on-failure
```

| Проверка | Назначение |
|---|---|
| `klib_core` | Арены и pool, выражения, собственные значения, строки/JSON/tree, 32/64-bit suffix arrays. |
| `stc.containers` | Векторы/deque/queue/list/map/set, порядок, clone/deep-copy, smart-pointer ownership. |
| `precision.tommath` | Точное умножение/деление, короткий выходной буфер, квадрат и корень 1000-значного числа. |
| `precision.mpdecimal` | 50-значный sqrt, half-even rounding, status flags, uint128 conversion, синтаксическая ошибка. |
| `scientific.basic` | Матрицы, FFT roundtrip, сплайн и JSON roundtrip, DWT-реконструкция, least-squares fit. |
| `scientific.cephes` | Независимые численные тождества специальных функций и сравнение с C99 libm. |
| `quadrature.finite_infinite` | Конечные/особые/бесконечные интегралы, userdata, неверный указатель/тип интервала. |
| `quadrature.stroud_moments` | Независимые точные моменты многочленов для двух правил, размерности 1..7. |
| `quadrature.sobol` | Известный префикс Sobol, float/double, 1111 измерений, неверные размеры и четыре конкурентных вызова. |
| `core_helpers.tlsf_pool` | Выравнивание, realloc с сохранением данных, исчерпание/слияние блоков, два pool и использование Ryu. |
| `core_helpers.ryu_roundtrip` | IEEE edge cases, 8192 детерминированных паттерна, exact roundtrip и fixed/scientific форматирование. |
| `genann.serialization` | Точный topology/weights roundtrip и восстановление activation callbacks, которые формат не сохраняет. |
| `kann.forward_gradient` | Независимый tanh/softmax oracle, 17 finite-difference gradients, сверка batch cost/gradient/output. |
| `kann.train_serialize` | Детерминированное обучение, неполный mini-batch и побитовое save/load параметров/выходов. |
| `nnom.conv_reference` | Квантованная Conv2D: независимая целочисленная свёртка, shape/rounding и повторный inference. |
| `nnom.model_lifetime` | Dense со значениями 5/9, shape, model_delete и optional allocation balance. |
| `channel_codes.rs_errors` | 16 неизвестных ошибок; 20 стираний+4 ошибки; shortened/in-place; один повреждённый beyond-capacity пример. |
| `acoustic.liquid_core` | FFT против прямого DFT на 16/17 точках, FIR impulse/DC/Nyquist, QAM16 с шумом, FEC-recovery. |
| `orbits.time_and_api` | TLE parse, int64 epochs 1957/2000/2039/2056 и эквивалентность временного/минутного шага SGP4. |
| `embeddings_static_ids` | Среднее и L2-норма, дубли token ID, empty/zero, invalid ID/shape, NaN и крайние конечные величины. |
| `network_systems_json` | JSMN-токены, JSON Patch cJSON, некорректный и неполный JSON. |
| `network_systems_monocypher` | BLAKE2b known answer, AEAD и Ed25519 roundtrip с обнаружением подмены. |
| `network_systems_lz4` | LZ4 HC block/frame roundtrip и отказ при недостаточном выходном буфере. |
| `network_systems_miniz` | Deflate/ZIP в памяти, CRC и совместимость miniz с zlib в одной translation unit. |
| `network_systems_tinycthread` | Два потока, mutex, итоговый счётчик и возвращаемые значения join. |
| `network_systems_libvterm` | ANSI color/cursor sequences и содержимое виртуального экрана. |
| `network_messagepack` | CMP ↔ MPack: взаимное чтение/запись, tree/streaming API и отказ на усечённом вводе. |
| `network_bson` | BSON-массивы, binary, Decimal128, Extended JSON roundtrip и усечённый документ. |
| `network_mongoc_uri` | URI, client lifecycle, выбранная компрессия и явный отказ неподдерживаемого TLS; без запроса к БД. |
| `network_hiredis_protocol` | Локальный RESP peer на socketpair: PING, binary ECHO, incremental RESP3 и ограничение глубины. |
| `network_llhttp_streaming` | HTTP-парсинг по одному байту: URL/headers/body/chunks/trailers; отказ TE+CL и неверному framing. |
| `network_sqlite_vec` | Явная регистрация SQLite extension, vec0/KNN, расстояния, bit iteration, ошибка размерности и close. |
| `network_sqlite3_memory` | In-memory SQLite: prepared/bound text, quoted identifiers, rollback и cleanup после ошибки. |
| `network_sodium_crypto` | SHA-256 known answer, secretbox и signature roundtrip; обнаружение подмены. |
| `network_mbedtls_config_crypto` | Mbed TLS 3.6.7: SHA-256 и DES known answers, PSA init и thread-safe конфигурация. |
| `formats_gui_commands` | Nuklear/microui command buffers, default font atlas, Olive pixel raster and C99 layout checks. |
| `formats_webp_roundtrip` | WebP lossless RGBA roundtrip plus mux/demux EXIF byte equality. |
| `formats_video_roundtrip` | Synthetic jo_mpeg→pl_mpeg and minih264→h264bsd roundtrips with decoded pixel checks. |
| `formats_geodesic_reference` | Geodesic reference inverse/direct/equator distances and spherical polygon area. |
| `formats_h3_grid` | Reference H3 index, center roundtrip, neighborhood uniqueness, parent and boundary. |
| `formats_nmea_parse` | RMC/GGA parsing, checksum rejection, coordinates, UTC conversion and C99 named-field layout. |
| `formats_shapefile_roundtrip` | SHP/SHX polygon plus DBF UTF-8/integer/double persistence roundtrip. |
| `formats_qr_roundtrip` | Nayuki QR encoding→quirc decoding for UTF-8/binary payload, then blank-image detector reuse. |
| `formats_text_formats` | Markdown callbacks/HTML, Gumbo recovery, yxml/ezxml XML, TOML typed data and YAML parse/emit/parse. |
| `formats_zip_roundtrip` | Memory ZIP create/extract, missing-entry rejection and miniz/zlib CRC coexistence. |
| `formats_zstd_roundtrip` | Threaded Zstd compression/decompression byte equality and truncated-frame rejection. |

`text_formats` проверяет шесть API отдельными запусками. NNoM allocator tracking применяется только в исходном Linux GNU/Clang heap-режиме; остальные конфигурации проверяют вычисления и жизненный цикл. KANN pthread и sqlite-vec AVX определения берутся из реальной конфигурации соответствующих библиотек. Копия MessagePack-теста оставлена одна.

В Release у проверок снимается `NDEBUG`; параметры производственных библиотек не меняются. Эти выбранные проверки не являются полными upstream suites и не доказывают корректность на непроверенных ОС/CPU.
