# Upstream-примеры: навигация и условия использования

Здесь учтены **182 файла, 915,747 байт**, относящиеся к **62 компонентам**. Это исходные программы, фрагменты, необходимые helpers и краткие справки. Число файлов в таблицах включает поддержку и документацию, а не только исполняемые программы.

**Статус: source-reviewed.** Upstream-выборка не собиралась и не запускалась как единый набор. Проверка библиотек коллекции не означает проверку каждого их примера. Побайтовое совпадение исходных копий проверено; три локальных forwarding header и научная справка обозначены как материалы интеграции.

[UPSTREAM_SOURCES.json](UPSTREAM_SOURCES.json) содержит запись для каждого файла: назначение, SHA-256, тип материала, режим сборки, цели, заголовки, определения, support files, входы и ограничения. Раздел `libraries` задаёт точные версии/commit, URL источников и лицензии; файловые исключения из общей лицензии указаны отдельно. Все локальные пути JSON отсчитываются от корня коллекции. Исходные архивы не требуются для чтения этих материалов.

Проверенные собственные демонстрации находятся отдельно в `collection/`, проверки — в `checks/`; они не входят в этот каталог.

## Сеть, криптография, БД и системные API

| Компонент | Файлов | Сценарии | Цели / режим |
|---|---:|---|---|
| [cjson](upstream/cjson/) | 1 | Создание JSON и печать в буфер | `LMX::cjson` |
| [curl](upstream/curl/) | 11 | HTTP(S), заголовки, POST, multi-loop, SFTP | `LMX::curl` |
| [dyad](upstream/dyad/) | 2 | TCP echo и callbacks простого HTTP demo | `LMX::dyad` |
| [enet](upstream/enet/) | 1 | UDP host/peer, пакеты и события | `LMX::enet` |
| [hiredis](upstream/hiredis/) | 3 | Redis sync/async, RESP3 PUSH | `LMX::hiredis` |
| [jsmn](upstream/jsmn/) | 1 | Токены JSON и подключение header API | `LMX::jsmn` |
| [libssh2](upstream/libssh2/) | 5 | SSH exec, SFTP, неблокирующее чтение | `LMX::libssh2` |
| [libvterm](upstream/libvterm/) | 1 | Разбор терминальных escape sequences | `LMX::vterm` |
| [mbedtls](upstream/mbedtls/) | 7 | AEAD, HMAC, ECDH, ECDSA, CTR-DRBG | `LMX::mbedcrypto` |
| [microtar](upstream/microtar/) | 1 | Чтение/запись TAR и stream callbacks | `LMX::microtar` |
| [mongo_c_driver](upstream/mongo_c_driver/) | 5 | BSON, URI, ping, insert и cursor | `LMX::bson`, `LMX::mongoc` |
| [monocypher](upstream/monocypher/) | 5 | AEAD, Argon2, BLAKE2b, Ed25519, X25519 | `LMX::monocypher` |
| [postgresql](upstream/postgresql/) | 5 | Транзакция, cursor, NOTIFY, binary I/O | `LMX::pq` |
| [sqlite_vec](upstream/sqlite_vec/) | 1 | SQLite в памяти и vector KNN | `LMX::sqlite3`, `LMX::sqlite_vec` |
| [tinycthread](upstream/tinycthread/) | 1 | Создание и ожидание потока | `LMX::tinycthread` |
| [tinydir](upstream/tinydir/) | 3 | Обход каталога и сведения о файлах | `LMX::tinydir` |

## Числа, контейнеры, DSP и нейросети

| Компонент | Файлов | Сценарии | Цели / режим |
|---|---:|---|---|
| [afan_neural_network](upstream/afan_neural_network/) | 1 | Учебный XOR, сохранение/загрузка сети | `LMX::afan_neural_network` |
| [cmpfit](upstream/cmpfit/) | 1 | Подбор параметров модели | `LMX::cmpfit` |
| [cquadpack](upstream/cquadpack/) | 3 | Конечные и бесконечные интегралы | `LMX::quadpack` |
| [decnumber](upstream/decnumber/) | 4 | decimal64/128, контексты и округление | `LMX::decnumber` |
| [genann](upstream/genann/) | 1 | Небольшая обучаемая нейросеть | `LMX::genann` |
| [kann](upstream/kann/) | 3 | MLP/RNN CLI и чтение модели | `LMX::kann`, `LMX::mlp_kann` |
| [kissfft](upstream/kissfft/) | 1 | FFT над двоичными входными отсчётами | `LMX::kissfft` |
| [klib](upstream/klib/) | 4 | Контейнеры, FASTA/FASTQ, CLI options | `LMX::klib`, `LMX::klib_headers`, `LMX::zlib` |
| [liquid_dsp](upstream/liquid_dsp/) | 11 | FFT, фильтры, modem, resampling, FEC | `LMX::liquid_dsp` |
| [mint](upstream/mint/) | 2 | CPU-тензоры и broadcasting | `LMX::mint`; один implementation TU |
| [mpdecimal](upstream/mpdecimal/) | 4 | Точная десятичная арифметика | `LMX::mpdec` |
| [stc](upstream/stc/) | 8 | Векторы, map/set, очереди и строки | `LMX::stc` |
| [tinyspline](upstream/tinyspline/) | 1 | B-spline: контрольные точки и оценка | `LMX::tinyspline` |
| [wavelib](upstream/wavelib/) | 2 | Прямое и обратное wavelet-преобразование | `LMX::wavelib` |

## Форматы, графика, аудио и геоданные

| Компонент | Файлов | Сценарии | Цели / режим |
|---|---:|---|---|
| [cglm](upstream/cglm/) | 1 | Подключение и применение math API | `LMX::cglm` |
| [cgltf](upstream/cgltf/) | 1 | Загрузка и разбор glTF | `LMX::cgltf` |
| [expat](upstream/expat/) | 3 | Потоковый XML parser | `LMX::expat` |
| [geodesic](upstream/geodesic/) | 3 | Расстояния и геодезические задачи | `LMX::geodesic` |
| [gumbo](upstream/gumbo/) | 1 | Разбор HTML | `LMX::gumbo` |
| [h3](upstream/h3/) | 5 | Координаты, ячейки и обход H3 | `LMX::h3` |
| [kuba_zip](upstream/kuba_zip/) | 2 | ZIP CLI и callbacks | `LMX::kuba_zip` |
| [libspng](upstream/libspng/) | 1 | PNG decoding, размеры и метаданные | `LMX::libspng` |
| [libwebp](upstream/libwebp/) | 7 | WebP-инструменты и нужные helpers | `LMX::webp`, `LMX::webpmux` |
| [libyaml](upstream/libyaml/) | 1 | Parser/emitter YAML | `LMX::libyaml` |
| [lodepng](upstream/lodepng/) | 2 | PNG encode/decode | `LMX::lodepng` |
| [md4c](upstream/md4c/) | 3 | Markdown → HTML | `LMX::md4c_html` |
| [microui](upstream/microui/) | 1 | Построение UI и команды рисования | `LMX::microui` |
| [miniaudio](upstream/miniaudio/) | 9 | Playback, capture, engine и callbacks | реализация внутри примера |
| [minmea](upstream/minmea/) | 2 | Чтение NMEA-строк | `LMX::minmea` |
| [msf_gif](upstream/msf_gif/) | 1 | GIF writer API | `LMX::msf_gif` |
| [nuklear](upstream/nuklear/) | 4 | Четыре фрагмента UI без main | `LMX::nuklear`; фрагменты |
| [olive](upstream/olive/) | 4 | Программная графика в ANSI-терминале | реализация внутри примера |
| [pdfgen](upstream/pdfgen/) | 1 | Создание PDF | `LMX::pdfgen` |
| [pl_mpeg](upstream/pl_mpeg/) | 1 | MPEG-кадры в BMP | реализация внутри примера |
| [qoi](upstream/qoi/) | 1 | Конвертация PNG ↔ QOI | реализация внутри примера |
| [qrcodegen](upstream/qrcodegen/) | 1 | Генерация QR-кода | `LMX::qrcodegen` |
| [rtree](upstream/rtree/) | 1 | Пространственный индекс | `LMX::rtree` |
| [shapelib](upstream/shapelib/) | 7 | Чтение/запись SHP и DBF | `LMX::shapelib` |
| [tiny_regex_c](upstream/tiny_regex_c/) | 1 | Регулярные выражения | `LMX::tiny_regex_c` |
| [tinyfiledialogs](upstream/tinyfiledialogs/) | 2 | Нативные/внешние диалоговые helpers | `LMX::tinyfiledialogs` |
| [tinysoundfont](upstream/tinysoundfont/) | 1 | SoundFont synthesis API | `LMX::tinysoundfont` |
| [tomlc99](upstream/tomlc99/) | 2 | Разбор и обход TOML | `LMX::tomlc99` |
| [tpng](upstream/tpng/) | 1 | PNG writer API | `LMX::tpng` |
| [whereami](upstream/whereami/) | 2 | Путь executable и shared module | `LMX::whereami` |
| [xlsxio](upstream/xlsxio/) | 3 | Чтение/запись XLSX | `LMX::xlsxio_read`, `LMX::xlsxio_write` |
| [zstd](upstream/zstd/) | 7 | Потоковая и обычная компрессия | `LMX::zstd` |

## Как выбирать и собирать

- **Обычные программы:** отдельный executable на каждый `main`; применяйте include paths и PUBLIC definitions указанной цели. Требования в JSON описательные: условные пометки POSIX/Linux не являются буквальными флагами компилятора.
- **Фрагменты и helpers:** четыре файла Nuklear включаются в приложение после `nuklear.h`; им нужны контекст, ввод и отрисовка. Файлы поддержки WebP/md2html связываются со своим CLI, а `vc.c` Olive и glue miniaudio уже включаются текстом — отдельной translation unit не нужны.
- **Реализация в примере:** QOI, Olive, pl_mpeg и выбранные miniaudio demos сами определяют implementation-макросы. Не подключайте вторую реализацию из одноимённой статической библиотеки. Mint использует INTERFACE-цель и ровно одну implementation translation unit.
- **Локальная раскладка заголовков:** сохраняйте соседние helpers. У H3 upstream include — `<h3/h3api.h>`, тогда как build-tree цель экспортирует `h3api.h`: нужен layout adapter в каталоге сборки. Kuba ZIP CLI требует `vendor/kuba_zip/src` для `<zip.h>`; не смешивайте этот include с MiniZip. Для libssh2 нужны `libssh2_setup.h`, generated `libssh2_config.h` и `HAVE_CONFIG_H`; пути описаны в JSON.
- **Научные примеры:** краткие рецепты и особенности forward headers описаны в [SCIENTIFIC_USAGE_RU.md](upstream/SCIENTIFIC_USAGE_RU.md). В частности, directory forwarding headers Wavelib/Mint не добавляют в include search path; Liquid-DSP CLI helper рассчитан на отдельный executable на пример.

## Входы и ограничения

- HTTP/SSH/Redis/PostgreSQL/MongoDB-программы требуют адреса и работающего сервера. Некоторые создают файлы, ключи Redis или схемы/документы БД; используйте выделенные данные для демонстрации. Они не запускаются при чтении каталога.
- Текущий MongoDB-клиент собран без TLS, SCRAM/SASL/AWS и client-side encryption; hiredis и libpq здесь также без TLS, хотя libpq поддерживает SCRAM. Upstream SSH-демонстрации печатают fingerprint/known-host result, но не гарантируют отказ при несовпадении; это отмечено у конкретных файлов. У curl HTTPS сохранены проверки по умолчанию; макросы `SKIP_*_VERIFICATION` их отключают.
- KANN, klib kseq, графические/звуковые конвертеры и некоторые CLI ожидают пользовательские данные. Датасеты, модели, звук, изображения и test corpora сюда не добавлены. Miniaudio требует доступного аудиобэкенда/устройства; tinyfiledialogs может запускать внешние desktop helpers. Olive выбран только с терминальным `VC_PLATFORM=2`.
- Криптографические демо показывают API и могут содержать фиксированные демонстрационные ключи/nonce. Очистку глобального PSA runtime из standalone Mbed TLS demo не переносят в код, пока его используют curl или другие компоненты.
- Лицензия `NOASSERTION` у Mint и afan Neural-Network означает отсутствие подтверждённого upstream-разрешения; она не переименована в MIT. Лицензии и сохранённые notices находятся по путям из JSON и [SOURCES.json](../SOURCES.json).
