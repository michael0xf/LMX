# Обзор семейств C99

Полный актуальный перечень хранится один раз в
[SOURCES.json](../../third_party/lmx_c99_compact/SOURCES.json), а API и
LMX-пакеты — в [core_catalog](../core_catalog/README.ru.md). Этот документ
помогает выбрать направление; версии, лицензии, headers, c.* вызовы,
ABI aliases и условные профили нужно брать из соответствующей записи.

## Основные возможности

| Область | Примеры и назначение | Где искать точную опись |
| --- | --- | --- |
| Числа и математика | mpdecimal, LibTomMath, SoftFloat, fixed-point, линейная алгебра, FFT, оптимизация | [План пакетов](../core_catalog/package_plan.lmx), [новые примитивы](../core_catalog/new_primitives/) |
| Строки, Unicode и структуры | STC, sds, utf8proc, gb, выбранный EA libc, parserutils, libwapcaplet | Каталог компонентов по ID, затем contracts конкретной функции |
| Системные механизмы | APR/APR-Util, SDL3, gb, cute_sync; память, потоки, файловые операции, устройства | [platform_extra](../../third_party/lmx_c99_compact/extensions/platform_extra/README.ru.md), [bundles_extra](../../third_party/lmx_c99_compact/extensions/bundles_extra/README.ru.md) |
| Сеть и протоколы | curl, llhttp, libssh2, TLS, lwIP, MQTT, Modbus, Cyphal/CAN, cute_net | Сетевые и control пакеты в core_catalog |
| Форматы текста и документов | JSON, XML, HTML/DOM/CSS, Markdown, PDF, XLS/XLSX, INI | [Матрица форматов](FORMAT_MATRIX.json) |
| Графика и мультимедиа | PNG/JPEG/WebP/GIF/BMP, Aseprite, sprite atlas, WAV/audio, SDL3 | [Форматы](FORMAT_GUIDE.ru.md), [NetSurf](../../third_party/lmx_c99_compact/extensions/netsurf_extra/README.md) |
| Архивы и компактные представления | ZIP/TAR/7z reader, zlib/Zstd/LZ4, CBOR, MessagePack, protobuf/BSON | Матрица форматов и профиль конкретного codec |
| Научные контейнеры | HDF5+HL, netCDF-C, PnetCDF, matio; CDF-5, netCDF-4, MAT7.3 | Научный раздел [форматов](FORMAT_GUIDE.ru.md) и научные adapters |
| Геометрия, наблюдения и измерения | glTF/OBJ/Shapefile, NMEA/TLE, ERFA, ODE, фильтры, PID, cute_c2 | План пакетов и source/component записи |
| Носители и хранилища | FatFs/exFAT, littlefs/SPIFFS, FlashDB, SQLite | [storage_extra](../../third_party/lmx_c99_compact/extensions/storage_extra/README.md) |
| Модели и специализированные engines | Tensor/NN libraries, PCRE2, SLJIT, SQL | Публичный контракт и scope каждой библиотеки |

## Ответ на предложенные наборы

| Предложение | Принятый результат |
| --- | --- |
| gingerBill gb | `bundles_extra:gb`: core `gb.h` и внешний INI reader; JSON в этом upstream snapshot нет |
| cute_headers | Восемь отдельных targets: collision, Tiled, Aseprite, PNG, spritebatch, sync, net и sound; каждый имеет свой маленький C API |
| C99Containers | Историческое имя/fork STC; покрывается уже включённым `base:stc` |
| embeddedartistry/libc | `bundles_extra:ea_libc`: 80 публичных `lmx_ea_*` функций, без подмены host libc и без APSL исходников |
| APR / APR-Util | `platform_extra:apr` и `platform_extra:apr_util`: pools, portability, I/O, threading, XML и выбранные вспомогательные механизмы |
| SDL3 | `platform_extra:sdl3`: platform/device APIs; реальная доступность зависит от выбранных backends |
| NetSurf libs | Восемь компонентов: wapcaplet, parserutils, hubbub, dom, css, svgtiny, nsbmp, nsgif |
| HDF5 / HL | `scientific_formats:hdf5`: C core и полный C HL; MPI profile имеет отдельный execution status |
| netCDF-C | `scientific_formats:netcdf`: CDF-1/2/5, netCDF-4 и выбранные DAP/NCZarr/diskless механизмы |
| PnetCDF | `scientific_formats:pnetcdf`: 915 `ncmpi_*` + 9 `cdl_hdr_*` публичных функций, MPI-IO для CDF-1/2/5 |
| libxml2 | `scientific_formats:libxml2`: самостоятельный XML/HTML C API и реальная зависимость DAP4 |
| matio 1.6.0 | Существующий `knowledge_extra:matio` обновлён с поддержкой MAT7.3 через HDF5 |

Это компонентная опись: один компонент может иметь несколько CMake targets,
а число экспортов `.a` включает внутренние helpers. Полный function census,
source-only declarations, header instantiations и profile gates находятся в
core_catalog. Обзорная таблица не заменяет эту информацию.
