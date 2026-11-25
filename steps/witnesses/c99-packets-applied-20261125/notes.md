# Пакеты автора 2026-11-25 (2) и (3) применены: каталог ядра и компактных библиотек C99, архив C99

Поручение автора (2026-11-25, около 18:40): «примените пожалуйста с Helper-ом патчи документации:
docs\tasks\25-Nov-2026-2\ docs\tasks\25-Nov-2026-3\». Исполнено тремя коммитами: архивный `52e461425` (оба пакета байт
в байт как выданы), рабочий `3ac8a4a07` (рабочие документы, коллекция, атрибуты, ссылки) и коммит записей (этот файл,
шаг 29.7 плана, журнал правок документации). Решения Sol и Astra: `CODER-DOCS26-20261125-01-EOL-FINDING`,
`CODER-DOCS26-20261125-01-ASTRA-ANSWER`. Ядро, транслятор и runtime не менялись и не перестраивались.

## Что выдано

| Пакет | Часть | Файлов | Байт |
| --- | --- | --- | --- |
| (2) | `docs/core_catalog/**` | 484 | 22 648 567 |
| (2) | `third_party/lmx_c99_compact/**` | 1032 | 9 892 876 |
| (3) | `docs/c99_archive/**` | 9 | 293 984 |
| (3) | корневые `README.ru.md` и `CMakeLists.txt` пакета | 2 | 11 218 |
| (3) | `third_party/lmx_c99_compact/**` | 7399 | 129 293 516 |
| Всего | | 8926 | 162 140 161 (154,6 МиБ) |

`PATCH_INFO.json` пакета 2 (`docs/core_catalog/PATCH_INFO.json`): патч-оверлей, пути от корня проекта LMX; основа —
`LMX.TAR.GZ`, SHA-256 `fd67abf5…`, 51 743 935 байт; `kernel_source_changes: false`; пять существующих файлов
заменены, удалений нет; входной документ `docs/core_catalog/README.ru.md`. Пакет 3 заменяет пять файлов `third_party`
пакета 2 и добавляет 23 компонента к 132 — 155 (`docs/c99_archive/README.ru.md:18`).

Каталог о себе. Первичные данные — LMX-файлы; таблицы Markdown и поисковые JSON — их справочные проекции;
нормативная основа — текущая `docs/spec` (`docs/core_catalog/README.ru.md:4–6`). Файлы каталога не регистрируют новых
функций в работающем интерпретаторе (`:8–9`). `publication.lmx:8`: `status "proposal_only; runtime NOT_RUN"`.
Числа каталога: 215 канонических имён ядра и 227 вариантов договоров (`README.ru.md:19`); 32 122 записи C API и
19 331 кандидат в 1 058 исходных поверхностях (`:39–40`); `lmx_runtime: NOT_RUN`, `whole_collection_link: NOT_RUN`
(`catalog_summary.json:2415–2416`). Отчёт автора о сборке 132 компонентов на Linux x86-64 (`README.ru.md:10–13`) —
результат этой выдачи; на машине проекта коллекция не собиралась. Якоря для плана — `plan-anchors.tsv` (чтение
helper, сверено coder: каждая цитата байт в байт в названной строке).

## Решение Sol и Astra

- Q3.1. Оба пакета — одним отдельным архивным коммитом, байт в байт, с точными правилами
  `docs/tasks/25-Nov-2026-2/** -text` и `docs/tasks/25-Nov-2026-3/** -text`. До индексирования снять путь и SHA-256
  каждого файла, затем сравнить пути и blob индекса. Файлы, скрытые правилом `build/`, добавить по списку.
- Q3.2. Рабочая компактная коллекция — из пакета 3. CRLF → LF для всех текстов, кроме семи, чьи SHA-256 закреплены
  манифестами автора и ломаются на LF: `vendor/libtess2/Source/geom.c`, `geom.h`;
  `vendor/libfixmath/libfixmath/fix16.h`, `fract32.h`, `uint32.h`;
  `vendor/softfloat/source/include/softfloat.h`, `softfloat_types.h` — для них точные атрибуты `-text`. Для остальных
  сверить LF-форму с оригиналом и записать оба SHA-256. Новых исключений для control-байтов не нужно.
  `validate_inventory` сохраняет свою область (132 против `SOURCES.json`; в пакете 3 уже 155).
- Q3.3. Корневые README LMX сохранить; добавить ссылки на `docs/core_catalog/README.ru.md` и
  `docs/c99_archive/INTEGRATION.ru.md`. Титульную страницу архива, перенесённую в `docs/c99_archive/README.ru.md`,
  исправить по относительным ссылкам. Корневой CMake пакета 3 остаётся только в архивном снимке; рабочая команда
  `cmake -S third_party/lmx_c99_compact -B <build-dir> -DCMAKE_BUILD_TYPE=MinSizeRel -DLMX_ARCHIVE_VERIFY=ON` —
  в рабочем `BUILD_AND_VERIFY`; добавленные ссылки проверить отдельно.
- Q3.4. Рабочие документы — `docs/core_catalog` и `docs/c99_archive`. В плане отдельные задачи: выбор ABI и профиля;
  настоящее понижение и публикация пакетов; модели, конвертеры и числовые примитивы — после проверки договоров на
  ядре ([29.7](../../../next_core_tasks_v3.md#c99-catalog-20261125)). 133 `.lm3` и 148 `.lmx` каталога разобраны
  принятым P0 через lmx-dev (только синтаксис). Отчёт автора о Linux-сборке цитировать как результат этой выдачи.

## Архивный коммит `52e461425`

Основа `93528badd` (HEAD был равен origin/main; сверено выборкой перед коммитом). 8927 путей: 8926 файлов пакетов и
`.gitattributes` с двумя правилами `-text`.

1. До индексирования снята таблица `path, bytes, sha256` всех 8926 файлов (`CF/docs26-01/archive-sha256.tsv`,
   1 455 005 байт, SHA-256 таблицы `08415f63…`). После индексирования путь и blob каждого файла сравнены с таблицей:
   8926 из 8926 равны.
2. Скрытые корневым правилом `build/` пути добавлены по списку (`git add -f --pathspec-from-file`): 23 в пакете 2
   (77 575 байт) и 24 в пакете 3 (78 813 байт) — `vendor/mongo_c_driver/build/cmake/*` и
   `vendor/libtiff/build/CMakeLists.txt` обоих пакетов (`forced-paths.tsv`).
3. `python tools/check_docs.py` — выход 0. docs check индекса 303 принятым tool: `OK`, все числа равны предыдущему
   прогону, кроме числа отслеживаемых файлов — 46 936.

`CF` = `build2/codex_fix250generationchain01`. Отдельные таблицы работы остаются там; в свидетельство включены
те, которые называет решение.

## Рабочий коммит `3ac8a4a07`

| Часть | Путей | Что |
| --- | --- | --- |
| `third_party/lmx_c99_compact/**` | 2861 | 2854 новых и 7 заменённых; 2526 — байты автора, 335 — LF-форма |
| `docs/core_catalog/**` | 484 | байты автора, без изменений |
| `docs/c99_archive/**` | 10 | девять документов пакета 3 и `README.ru.md` |
| `.gitattributes` | 1 | семь точных `-text` |
| `README.ru.md` | 1 | одна строка ссылок |
| Всего | 3357 | 3348 новых, 9 изменённых |

Индексировано точными путями (`git add --` пяти путей, затем 24 скрытых по списку — те же 24, что в архиве:
`vendor/mongo_c_driver/build/cmake/*`, `vendor/libtiff/build/CMakeLists.txt`, 78 813 байт). Каждый blob индекса
равен файлу дерева: 3357 из 3357.

### Коллекция против пакета 3

Все 2861 изменённых пути сверены с архивным пакетом 3 (`HEAD:docs/tasks/25-Nov-2026-3/<путь>` на момент
индексирования): 2526 — байты автора (33 543 767 байт), 335 — LF-форма байтов автора. Семь заменённых отслеживаемых
файлов (`CMakeLists.txt`, `README.md`, `README_RU.md`, `SOURCES.json`, `examples/CMakeLists.txt`,
`extensions/archives/CMakeLists.txt`, `extensions/micro_mlp/cmake/AfanCompat.cmake`) — байты пакета 3.

Нормализация: 335 файлов, байты автора 2 779 499 → 2 733 078; переводов CRLF 46 421, строк только с LF в байтах
автора 0; для каждого файла разница байт равна числу его CRLF. Оба SHA-256 каждого файла — `normalized.tsv`.

| Область | Файлов | CRLF |
| --- | --- | --- |
| `vendor/softfloat` | 307 | 31 271 |
| `vendor/fatfs` | 17 | 13 604 |
| `vendor/libfixmath` | 8 | 1 316 |
| `vendor/nanomodbus` | 3 | 230 |
| Всего | 335 | 46 421 |

### Семь исходников с байтами автора

| Файл (`third_party/lmx_c99_compact/`) | Байт | CRLF | SHA-256 |
| --- | --- | --- | --- |
| `vendor/libtess2/Source/geom.c` | 9741 | 267 | `1b2ed092634483d7b9fd51c01609a68f1373bb0945b7e660f6abf65c8964ebb6` |
| `vendor/libtess2/Source/geom.h` | 3824 | 83 | `dfc62f50e25c3ada66c9f1250f22f41b1e0fcafec825ae3310d8bf345accb170` |
| `vendor/libfixmath/libfixmath/fix16.h` | 11750 | 349 | `748f34b1a2c690d39dbb607d44a67ef1be5280af0363504c9cac59b067d35ec1` |
| `vendor/libfixmath/libfixmath/fract32.h` | 1170 | 42 | `7003d2c4247d2f25faf6a7f1c51ca4fe10a6b6d79ef5c522719f344168b3587c` |
| `vendor/libfixmath/libfixmath/uint32.h` | 383 | 23 | `473d7ebf2217402e2f911aa41eeba67137b5c15ab8275165065cc8cfb3f53dbb` |
| `vendor/softfloat/source/include/softfloat.h` | 17806 | 372 | `0359d1f1c5bef11bcb728b5f065655bf0f144c918692f1350d5f44e25d68acd4` |
| `vendor/softfloat/source/include/softfloat_types.h` | 4127 | 81 | `d0876f30a0d3dde97dd16007dbf635d98ef8262476ab8913930548a70f140afa` |

Голых CR в них нет. Четыре бинарных файла (`libpq.dll`, `libpq.dll.a`, `libwinpthread-1.dll`, `win32.ico`) не
менялись: атрибут `-text` по точному пути стоит с `73ba211e3`.

### Закрепления хешей на дереве

| Манифест | Строк | Дерево — совпадает | После CRLF → LF совпадает | Ломаются на LF |
| --- | --- | --- | --- | --- |
| `extensions/text_hash_extra/PROVENANCE.json` | 119 | 119 | 117 | 2 (`geom.c`, `geom.h`) |
| `C99SourceCoverage.Headers` (`docs/core_catalog/catalog/schema.lmx`) | 1058 | 1058 | 1053 | 5 (`fix16.h`, `fract32.h`, `uint32.h`, `softfloat.h`, `softfloat_types.h`) |

Поиск хеш-литералов в конфигурациях и отчётах коллекции (1844 literals в 1194 файлах) попадает на файлы с CR только в
этих семи текстах и двух известных бинарных файлах. Новые файлы коллекции: голых CR, NUL и C0 — 0.

Концы строк в индексе всей коллекции (7399 файла): `i/lf` 7386, `i/crlf` 6, `i/mixed` 1 (`geom.c`), `i/none` 2
(файлы без переводов строк — `vendor/cglm/src/swift/empty.c`, `vendor/lwip/test/fuzz/config.h`), `i/-text` 4
(бинарные).

### Документы

- `docs/core_catalog/**` (484) и девять документов `docs/c99_archive/` скопировал helper (`CODER-HELPER-DOCS26-20261125-01-RESULT`).
  coder сверил копию с пакетами: 493 файла равны побайтно, лишних нет.
- `docs/c99_archive/README.ru.md` — титульная страница пакета 3 (`docs/tasks/25-Nov-2026-3/README.ru.md`, 10 778
  байт). Текст автора не менялся, кроме десяти ссылок и одной заметки: семь `](docs/c99_archive/X` стали `](X`, три
  `](third_party/` стали `](../../third_party/`; перед командой самостоятельной поставки
  `cmake -S . -B build …` вставлена заметка проекта о рабочей команде (11 156 байт).
- `docs/c99_archive/BUILD_AND_VERIFY.ru.md`: перед тем же блоком команды — заметка о том, что корневой файл CMake
  пакета в репозитории LMX не установлен, и рабочая команда запускается от каталога коллекции. Остальной текст —
  как выдан.
- Корневой `README.ru.md` сохранён; после строки о тестах парсера добавлена одна строка со ссылками на
  `docs/core_catalog/README.ru.md` и `docs/c99_archive/INTEGRATION.ru.md` (4245 → 4684 байт). `README.md` и
  `README.en.md` не менялись: документы выдачи — русские.
- Ссылки проверены отдельно (`docs_links_check.py`, fences исключены): 154 файла Markdown (`docs/core_catalog/**`,
  `docs/c99_archive/*`, три корневых README) — 1328 относительных ссылок, нарушенных 0; все 16 ссылок корневого
  `README.ru.md` и все 10 перенесённых разрешаются.

### Проверки

- `python tools/check_docs.py` — выход 0.
- docs check индекса 304 принятым tool (`CF/coder-k2s1c-build-01/coder-k2s1c-tool01/lmxtool-tool.exe`): `OK`, все
  числа равны индексу 303, кроме числа отслеживаемых файлов — 50 284 (= 46 936 + 3348 новых).

## Каталог через принятый P0

281 текст каталога (133 `.lm3`, 148 `.lmx`) разобран принятым P0 через lmx-dev, CLI `entry.py check <файл> --phase
syntax`, по одному вызову на файл: 281 `completed passed`, диагностик 0 (`p0-catalog.tsv`). Связка `accepted`, роль
`accepted`, effectiveHash `03cb584f7bc0735c7f223507c5d088020a2e447d0936e66d02e92799df0ce61a`, acceptedRevision
`cb7a8798a1c9a271ec7cb544db335f1f908563e9`, pinsVerified 6; расписки — `build2/lmx_dev/runs/20261125-19*`. Это
только разбор: статическая проверка автора (`tools/check_lmx_sources.py`) — не P0 (`README.ru.md:200`), а исполнение
текстов каталога актуальным runtime не выполнялось и автором (`CHANGES.ru.md:57–58`), и нами.

## Что не делалось

Коллекция на машине проекта не собиралась (ни `cmake`, ни `ctest`). Инструменты каталога (12 файлов `.py` в
`docs/core_catalog/tools/`) не запускались. `validate_inventory` не расширялась. PDF, XLSX и статистика взяты как
выданы и не сверялись. Код ядра, транслятора и runtime не менялся. Файлы под `build/` внутри коллекции после этого
коммита отслеживаются, но соответствуют корневому правилу игнорирования: обычный `git add` каталога их не обновляет,
изменения в них добавлять точным путём.

## Файлы свидетеля

- `normalized.tsv` — 335 строк: путь, байты автора, байты LF, CRLF, строк только с LF у автора, SHA-256 автора,
  SHA-256 LF-формы.
- `forced-paths.tsv` — 71 путь, добавленный по списку: 23 (архив, пакет 2), 24 (архив, пакет 3), 24 (рабочая
  коллекция).
- `p0-catalog.tsv` — 281 строка разбора P0.
- `plan-anchors.tsv` — якоря шага 29.7: задача, файл, строки, цитата, метка.
- В `CF/docs26-01/` остаются полные таблицы: `archive-sha256.tsv` (снимок 8926 файлов), `bundle-vs-packet.tsv`
  (2861 путь против пакета 3, оба SHA-256), `index-apply.tsv` (blob HEAD, индекс и дерево 3357 путей), `pins2.tsv`
  (1177 строк закреплений), `pin-scan.tsv` (поиск хеш-литералов), `helper/` и `helper-b/` (работа helper).

## Как повторить

```
git ls-files --eol -- third_party/lmx_c99_compact
python tools/check_docs.py
DOCS_TOOL=<принятый tool> bash build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01/fable/tz-20261121/accept-tools/docs_check.sh <N>
```

Сверки сделаны скриптами coder вне репозитория (`docs_pins.py`, `docs_bundle_normalize.py` без `--write`,
`docs_bundle_vs_packet.py`, `docs_index_receipt.py`, `docs_links_check.py`, `docs_p0_batch.py`); каждая читает
манифест автора и дерево и ничего не пишет.
