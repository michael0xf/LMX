# Что архив умеет читать и создавать

Это каталог **внешних представлений данных**: файлов, контейнеров, кодеков,
форматов носителей и оптических кодов. Семантику данных и работу с объектами
задаёт LMX. TOML/YAML/INI здесь нужны только при обмене с уже существующим
внешним потребителем; они не предлагаются как дополнительная система
настроек LMX.

Проверены состав исходных 132 компонентов, семь добавлений `storage_extra`
и четыре относящихся к форматам добавления `knowledge_extra` и PDFio. В
[FORMAT_MATRIX.json](FORMAT_MATRIX.json) — **64 позиции**, API, CMake targets,
ограничения, ссылки на локальные исходники и номера строк с API declarations.
62 позиции имеют собранный API; отдельно отмечены MIDI source-only и
FASTA/FASTQ с требуемой macro instantiation. Это проверка по source/header/CMake,
а не утверждение о проведении полного conformance testing всех форматов.

В таблицах **Ч** означает чтение, **З** — запись. Наличие обеих стрелок не
обещает сохранение всех metadata, стилей и расширений при roundtrip.

## Документы и структурированный текст

| Формат | Направление и библиотека | Что можно получить или создать |
|---|---|---|
| JSON | Ч: jsmn; Ч/З: cJSON, Jansson | Tokens либо tree values, JSON output. jsmn оставляет интерпретацию чисел LMX; cJSON хранит numbers как `double`. |
| XML | Ч: yxml, Expat; Ч/З: ezxml | Потоковые события или дерево и XML serialization. |
| HTML | Ч: Gumbo; З из Markdown: md4c-html | Структура/текст HTML; генерация HTML из Markdown. CSS layout и JavaScript не входят. |
| Markdown | Ч: md4c | События блоков, spans и текста; generic Markdown writer отсутствует. |
| PDF | З: PDFGen; Ч/З: PDFio | Создание страниц, чтение/запись объектов, metadata и streams, копирование страниц. Рендеринг и общий layout/text extractor отсутствуют. |
| XLSX | Ч/З: XLSXIO | Чтение sheets/cells и создание простого spreadsheet; без Excel formula engine и полного сохранения оформления. |
| XLS | Ч: libxls | BIFF/OLE worksheets и значения; без записи, пересчёта формул и XLSX. |
| TOML | Ч: tomlc99 | Импорт внешнего TOML; writer не собран. |
| YAML | Ч/З: libyaml | Parser/events/documents и emitter; tags/schema не задают автоматически типы LMX. |
| INI | Ч: inih | Разбор выбранного INI dialect; writer отсутствует. |

Практически значимые ограничения:

- PDFio даёт чтение структуры PDF и декодированных streams; это не готовый просмотрщик. Для encrypted CreationDate сохранён отдельный KNOWN_FAIL; обычные metadata/страницы/Flate и ограниченный AES-128 roundtrip проверены. **PDFGen сам по себе не является средством чтения PDF.** Заголовок также
  прямо ограничивает набор не-ASCII символов при UTF-8 input и стандартных PDF
  fonts. Полную кириллическую/многоязычную типографику нельзя обещать на этом API.
- XLSXIO даёт table I/O. ZIP и XML под ним не превращают библиотеку в средство
  отображения или редактирования произвольных DOCX/PPTX/ODT/ODS.
- libxls собран без iconv: для BIFF8 есть upstream UTF-16 → UTF-8 conversion,
  но старые code pages не нормализуются автоматически. Это существенное
  ограничение для legacy файлов с национальными текстами.
- Для точных integers/decimals нельзя незаметно проводить все JSON numbers
  через cJSON `double`. Выбор LMX типа должен следовать нужной точности.

Основание: строки `json`–`ini`, `xls` матрицы; `pdfgen.h`, `xlsxio_read.h`,
`xlsxio_write.h`, `xls.h` и соответствующие CMake profiles.

## Изображения, шрифты и оптические коды

| Формат | Чтение | Запись | Граница возможностей |
|---|---|---|---|
| PNG | stb_image, LodePNG, libspng, tpng | stb_image_write, LodePNG, libspng | **libspng здесь собран в обоих направлениях**; tpng — только RGBA reader. APNG не обещан. |
| JPEG | stb_image; tjpgdec и NanoJPEG | stb_image_write | stb читает progressive; маленькие alternatives — baseline; writer — baseline. NanoJPEG не читает CMYK, Exif/JFIF metadata и lossless JPEG. |
| GIF | gifdec, stb | msf_gif, jo_gif | Есть animation APIs. jo_gif игнорирует входную alpha; palette quantization ограничивает цвета. |
| QOI | qoi | qoi | Lossless RGB/RGBA; простой raster codec. |
| WebP | libwebp + demux | libwebp + mux | Lossy/lossless images и animation container APIs; не произвольный WebM video decoder. |
| TIFF/BigTIFF | libtiff | libtiff | Обе endian формы. Поддержка зависит от compiled codecs; ограничения ниже. |
| BMP/TGA/Radiance HDR | stb | stb | Простой raster I/O; Radiance RGBE не OpenEXR. |
| PSD/PIC/binary PPM-PGM | stb | — | PSD только composite, без Photoshop layers; PNM не означает все ASCII variants. |
| TTF/OTF-CFF/TTC | stb_truetype | — | Метрики/контуры/rasterization; не font writer и не полный shaping/layout engine. |
| BC1/BC3/BC4/BC5 | — | stb_dxt | Texture blocks; готовый DDS/KTX container writer не следует из этого API. |
| QR Code | quirc | qrcodegen | Reader принимает grayscale pixels; writer возвращает module matrix. PNG/JPEG слой подключается отдельно. |
| Data Matrix ECC200 | libdmtx | libdmtx | Memory image/symbol API; не общий reader всех barcode families. |

В выбранном libtiff доступны внутренние uncompressed/LZW/PackBits/CCITT/
LogLuv/NeXT/Thunder/MDI codecs. **JPEG/old-JPEG, JBIG, LERC, LZMA,
ZSTD, WebP и PixarLog отключены**. Deflate/AdobeDeflate включены через существующий zlib. Выполнены 20 roundtrips для TIFF/BigTIFF ×
обе endian формы × uncompressed/LZW/PackBits/AdobeDeflate/Deflate; для LZW/Deflate проверен horizontal predictor. Наличие `LMX::tiff` не означает,
что откроется любой TIFF с любым способом сжатия.

Основание: строки `png`–`gpu_blocks`, `tiff`, `qr`, `datamatrix`; libspng
`spng.h` и graphics CMake, stb headers, `knowledge_extra/VERIFICATION.json`.

## Аудио и видео

| Представление | Реальные направления | Что ещё потребуется |
|---|---|---|
| WAV/RIFF, W64, RF64 | Ч/З: dr_wav; WAV Ч/З также miniaudio | dr_wav не кодирует compressed WAV; miniaudio encoder пишет WAV, не MP3/FLAC. |
| AIFF, RIFX | Ч: текущий dr_wav | Запись и чтение metadata для них отсутствуют; AIFF ADPCM не поддерживается. |
| MP3 | Ч: dr_mp3, minimp3, miniaudio | MP3 encoder отсутствует; dr_mp3 и minimp3 не полностью независимы по происхождению. |
| FLAC, Ogg FLAC | Ч: dr_flac; native FLAC также miniaudio | FLAC encoder отсутствует; Ogg FLAC не означает Opus. |
| Ogg Vorbis | Ч: stb_vorbis | Encoder отсутствует. |
| MPEG audio Layer I | Ч: jo_mp1 | Отдельный старый codec, не MP3. |
| MPEG-1 audio Layer II | Ч: pl_mpeg | MP2 decoder, без encoder. |
| SF2 SoundFont | Ч + PCM synthesis: TinySoundFont | Сохранённый банк инструментов; SF2 writer отсутствует. |
| MIDI file | Сохранён `tml.h` | **TML_IMPLEMENTATION не собран** в target TinySoundFont; нужен отдельный C translation unit и проверка. |
| MPEG-1 video | Ч: pl_mpeg; З: jo_mpeg | jo_mpeg создаёт простой elementary stream; поддерживает 24/25/30/50/60 fps, не mux с audio. |
| MPEG Program Stream | Ч/demux: pl_mpeg | Bundled video/audio decoders — MPEG-1 + MP2; не произвольный MPEG2/4. |
| H.264/AVC elementary | Ч: h264bsd; З: minih264 | Baseline-oriented decoder; нельзя обещать general High/CABAC. MP4/MOV container I/O не добавляется автоматически. |
| WebM/Matroska subset | Ч/demux: nestegg | Возвращает compressed packets. Нужен отдельный codec; VP8/VP9/AV1/Opus decode и WebM mux отсюда не следуют. |

Полезная цепочка: **файл → container demux → codec → PCM/pixels → LMX**.
Каждый этап должен действительно присутствовать. Например, nestegg завершает
лишь первый этап; нельзя по факту его наличия объявлять поддержку воспроизведения
WebM. Обратная цепочка отдельно требует encoder и container mux.

Основание: строки `wav`–`webm`; headers dr_libs, miniaudio, pl_mpeg,
minih264/h264bsd и фактический media CMake source list.

## Архивы, сжатие и бинарные значения

| Формат/codec | Направления | Существенное ограничение |
|---|---|---|
| ZIP | Ч/З: miniz, kuba_zip, classic MiniZip | Store/DEFLATE; ZIP64/encryption/extra methods зависят от backend. Не обещается любой ZIP extension. |
| TAR | Ч/З: microtar | Basic subset: 100-byte names/linknames и unsigned size fields; PAX/GNU long-name extensions не заявлены. |
| DEFLATE/zlib/gzip | Ч/З: zlib; raw/zlib также miniz | gzip APIs относятся к zlib. Сжатый stream сам по себе не multi-file archive. |
| LZ4 block/frame | Ч/З: LZ4 | Raw block требует внешних границ/размера; framed API отдельный. |
| Zstandard | Ч/З: Zstd | Modern frames/dictionaries; legacy ≤0.7 frames отключены. |
| 7z/LZMA/LZMA2 | **Ч: LZMA SDK** | Выбран `Z7_EXTRACT_ONLY`; encoder не собран. Поддержка XZ container и encrypted 7z не установлена. |
| heatshrink | Ч/З | Малый streaming codec; window/lookahead и framing нужно сохранять отдельно. |
| MessagePack | Ч/З: CMP, MPack | Типовые values; смысл extension types задаёт приложение. |
| Protocol Buffers | Ч/З: nanopb | Нужны schema и generated C descriptors; произвольные bytes не self-describing. |
| CBOR | Ч/З: QCBOR, TinyCBOR | Независимые API, взаимный разбор проверен. Decimal/bigfloat tags — представление, а не вычислитель. |
| BSON | Ч/З: libbson | Может работать с bytes локально, без MongoDB server; не читает WiredTiger storage. |

Для восстановления полезно сохранять **схему и параметры вместе с данными**:
`.proto`/C descriptors для nanopb; dictionary для dictionary-coded Zstd;
framing и параметры heatshrink. Это не описание происхождения версии, а то,
без чего сами сохранённые bytes могут оказаться недекодируемыми.

Основание: строки `zip`–`cbor`, `bson`; особенно
`extensions/archives/CMakeLists.txt` и определение `Z7_EXTRACT_ONLY`.

## Геометрия, наблюдения и научные данные

| Формат | Возможность | Ограничение |
|---|---|---|
| glTF 2.0 / GLB | Ч/З: cgltf | GLB writer умеет включить переданный binary buffer; внешние buffers/images автоматически не сохраняет. Draco/BasisU metadata не равны соответствующим decoders. |
| OBJ / MTL | Ч: fast_obj | Geometry, indices, material references; writer и image decoder не входят. |
| SHP/SHX + DBF | Ч/З: Shapelib | Vector records и attributes; не CRS/.prj parser, GIS renderer или универсальный text converter. |
| NMEA 0183 | Ч: minmea | Поддерживаемые sentence types, checksum/time/coordinates; generic NMEA writer отсутствует. |
| TLE | Ч + SGP4 propagation | Нет TLE writer или обратного orbit fitting. |
| FASTA/FASTQ | kseq macro parser | Нужны `KSEQ_INIT` и read callback для выбранного stream; готовый самостоятельный runtime reader не инстанцирован библиотекой. |
| BGZF | Ч/З: klib + zlib | Включён в POSIX profile; это не полный BAM/CRAM parser. |
| Newick/NHX subset | Ч/З: klib knhx | Node/name/distance representation; полное сохранение всех NHX annotations не обещается. |
| MAT4/MAT5 | Ч/З: matio, включая zlib MAT5 | **MAT7.3/HDF5 отключён**; MCOS paths не были exercised в focused tests. |
| TinySpline JSON | Ч/З: TinySpline | Собственная spline schema; embedded Parson не выставлен как ещё один generic JSON API. |
| Genann/KANN/Tinn models | Ч/З: собственные APIs | Три разных native formats, не взаимозаменяемые; не ONNX/GGUF/SafeTensors. |
| Mint converted model | Ч: Mint | Только заранее converted representation; C API не читает ONNX напрямую. |

Основание: строки `gltf`–`newick`, `mat`, `tinyspline_json`, `native_nn`,
`mint_native`; public headers и generated-profile CMake adapters.

## Носители, хранилища и локальная инфраструктура

**FatFs** читает/пишет/создаёт FAT12/16/32 и exFAT через block-device callbacks.
Выбраны UTF-8 long filenames, Unicode case conversion и OEM CP437 для коротких
имён. FAT и exFAT проверены с кириллицей и `é` после remount. Separate FAT32
image и реальная flash не тестировались. Для настоящих timestamps нужны часы;
дефолтный профиль использует фиксированную дату.

**littlefs** и **SPIFFS** читают/создают свои flash filesystem formats. Это
независимые реализации: littlefs имеет иерархию, SPIFFS — flat names. Нужно
сохранить геометрию и параметры носителя, подключить read/write/erase/sync.
RAM-модель подтверждает API и persistence при remount, но не физическую
надёжность контроллера при пропадании питания.

**SQLite** открывает и создаёт SQLite database files; **FlashDB** работает с
собственной sector KV/time-series representation. Они сохраняют полезные
внешние представления; смысл объектов, значений и records определяет LMX.
FlashDB проверен в standard C FILE sector backend, с GC и повторным чтением
записей. Реальная FAL/flash-плата не запускалась; `fflush` не доказывает hardware
power-loss durability.

**Mbed TLS** разбирает и создаёт поддерживаемые X.509 certificate/CSR и
key objects в DER/PEM. Это позволяет обслуживать совместимые сохранённые
артефакты локальной сети. Trust policy, ключи, часы и источник случайности —
отдельные входы приложения; parse/write capability не означает доверие данным.

Нельзя перепутать сетевой клиент с reader дискового архива:

- hiredis реализует RESP client, а не reader Redis RDB/AOF;
- libpq — PostgreSQL client, а не reader data directory/WAL;
- mongoc — wire client, а libbson — local document representation;
- llhttp — HTTP parser, не HTML renderer.

Основание: строки `sqlite`, `flashdb`, `fat`, `littlefs`, `spiffs`,
`certificates` и `wire_only_boundaries` в матрице.

## Честные пробелы, полезные для следующего отбора

PDFio предоставляет доступ к объектам и декодированным потокам существующих
PDF. Для показа страниц и общего извлечения текста с восстановлением
порядка чтения нужны дополнительные слои. Другие заметные пробелы —
семантические office-document readers, полный modern media container/codec
набор и дополнительные научные контейнеры.

В этой проверенной подборке не найден готовый target/API для PDF rendering,
DOCX/PPTX/ODT/ODS semantic rendering, MAT7.3/HDF5/NetCDF/NPY/NPZ/DICOM,
AVIF/HEIF/JPEG XL/OpenEXR/SVG rendering, общего MP4/MOV mux/demux,
HEVC/AV1/VP9/AAC/Opus, MP3/FLAC/Vorbis encoding, RAR/BZip2/XZ container,
CSV/TSV quoting-aware I/O, прямого ONNX/GGUF/SafeTensors import. Наличие ZIP,
XML, tensors или compression primitives позволяет написать дополнительные
слои, но не считается уже готовой поддержкой этих форматов.

Это список границ фактической сборки, а не утверждение, что подходящих
компактных permissive C99 реализаций в мире нет. При следующем пополнении
имеет смысл выбирать конкретный внешний материал, который требуется
спасти/прочитать/создать, и проверять целую цепочку от bytes до полезных данных.
