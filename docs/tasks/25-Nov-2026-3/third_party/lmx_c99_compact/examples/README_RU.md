# Примеры и проверки коллекции

## Готовые программы

Сборка из корня распакованной коллекции:

```sh
cmake -S examples -B build-examples -DCMAKE_BUILD_TYPE=Release
cmake --build build-examples --parallel
```

Нужны те же C99/POSIX-инструменты и системный графический SDK, что для основной коллекции. Исходники зависимостей уже находятся в `../vendor`; CMake ничего не скачивает. Основная сборка `cmake -S .` включает библиотеки; этот отдельный проект добавляет демонстрационные программы и проверки.

В `collection/` лежат 26 небольших программ: все заново собраны и запущены на Linux x86-64 в этой compact-поставке. Их бинарники появляются в `build-examples/bin/` (на Windows — с суффиксом `.exe`).

| Имя программы после `lmx_example_` | Что показывает |
|---|---|
| `math` | Длинные целые, десятичная арифметика, FFT, сплайны и интегрирование |
| `precision` | Большие целые числа и десятичные вычисления заданной точности |
| `quadrature` | Адаптивное и многомерное численное интегрирование |
| `scientific_pipeline` | Небольшой вычислительный конвейер научных функций |
| `sqlite_memory` | SQLite: база в памяти, запросы и освобождение ресурсов |
| `arena_numbers` | TLSF-пул и преобразование чисел Ryu |
| `genann_regression` | Обучение небольшой нейросети Genann |
| `qr_image` | QR-код в PGM-файл |
| `path_regex` | Путь к программе и простой поиск по регулярному выражению |
| `kann_regression` | Граф вычислений и обучение KANN |
| `raster_png` | Рисование на CPU и запись PNG без окна |
| `xlsx_roundtrip` | Запись и чтение XLSX с UTF-8, числами и экранированием |
| `pdf_document` | Создание небольшого PDF-документа |
| `markdown_html` | Преобразование Markdown в HTML |
| `acoustic_loopback` | Передача пакетов через PCM с контролируемым шумом, без аудиоустройства |
| `tle_orbit` | TLE и расчёт состояния орбиты SGP4 |
| `geodesic_nmea` | Геодезическое расстояние и разбор NMEA |
| `mint_tensor` | Тензорные операции Mint через подготовленный C99-заголовок |
| `utensil_tensor` | CPU-тензоры Utensil |
| `text_paths` | Нормализация путей и работа с UTF-8 |
| `tinn_curve` | Обучение Tinn, сохранение и загрузка модели |
| `nnom_dense` | Небольшая квантованная сеть NNoM, описанная вручную |
| `postgres_info` | libpq: версия и разбор строки подключения без сервера |
| `static_embeddings` | Усреднение небольших векторов токенов |
| `rs_recovery` | Восстановление блока с ошибками кодом Рида — Соломона |
| `http_parser` | Разбор HTTP через callback-интерфейс llhttp |

Примеры запуска:

```sh
./build-examples/bin/lmx_example_sqlite_memory
./build-examples/bin/lmx_example_qr_image qr.pgm "Lingvamyxa"
./build-examples/bin/lmx_example_xlsx_roundtrip table.xlsx
./build-examples/bin/lmx_example_pdf_document report.pdf
./build-examples/bin/lmx_example_acoustic_loopback
```

PDF, PNG/PGM, XLSX и модель Tinn создаются при запуске. Используйте отдельный рабочий каталог и новые имена файлов: некоторые writer API перезаписывают существующий путь. Acoustic loopback работает с PCM в памяти; микрофон, колонки и внешние файлы ему не нужны, кроме уже включённого `vendor/quiet/quiet-profiles.json`.

## Дополнительные примеры upstream

[UPSTREAM_INDEX_RU.md](UPSTREAM_INDEX_RU.md) содержит краткую навигацию, а [UPSTREAM_SOURCES.json](UPSTREAM_SOURCES.json) — назначения, точные источники, лицензии и условия сборки каждого файла.

Эти исходники просмотрены и сохранены, но общей проверки сборки или запуска для них не заявляется. Они не входят в автоматическую CMake-сборку выше. Среди них есть программы с внешним сервером или пользовательским входным файлом, GUI-фрагменты без `main` и примеры со своей `*_IMPLEMENTATION`. Для последних нельзя дополнительно линковать вторую реализацию той же библиотеки. Конкретные требования указаны в каталоге; маленькие локальные header adapters явно обозначены.

## Проверки

В `checks/` собраны выбранные самостоятельные unit/integration checks: библиотечные API, форматы, численные результаты, память, сериализация и локальное взаимодействие компонентов. Нет внешнего PostgreSQL/Redis/MongoDB-сервера, сертификатов, медиаархивов или датасетов. Два POSIX-теста включаются только на UNIX.

```sh
ctest --test-dir build-examples --output-on-failure
```

Проверки также можно собирать отдельно:

```sh
cmake -S examples/checks -B build-checks -DCMAKE_BUILD_TYPE=Release
cmake --build build-checks --parallel
ctest --test-dir build-checks --output-on-failure
```

`assert` в тестовых программах остаётся включён даже в Release. Они пишут временные результаты в свои каталоги внутри build, а не в исходники. Подробности отдельных случаев — в [checks/INDEX_RU.md](checks/INDEX_RU.md).
