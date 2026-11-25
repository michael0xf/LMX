# stb: все текущие компоненты в C99-сборке

## Источники

Основная коллекция: <https://github.com/nothings/stb>, commit
`6b5799bae8a1fe3792691ef4b72ae26434c3e799` от 2026-11-19.
Общих тегов или GitHub releases нет. Это зафиксированный снимок основной
ветки с версиями в самих исходных файлах, не общий stable-релиз проекта.

Сохранены все **19 текущих public library files**. Кроме того, включены две
библиотеки, недавно перенесённые авторами из stb в отдельные репозитории:

- `stb_image_resize2.h`: <https://github.com/nothings/stb_image_resize>,
  commit `a4f303e34a92d1410d510cbe85a1781ce4b8c9fd`.
- `stb_sprintf.h`: <https://github.com/nothings/stb_sprintf>,
  commit `d9d1bb37d2ea313eb8a734452b178b2c27bbb951`.

Все vendor-файлы неизменны. URL и хеши архивов/файлов находятся в
`provenance/stb.json` и `provenance/stb_split_projects.json`. Лицензии основной
коллекции и обоих перенесённых проектов сохранены отдельно, как и notices
внутри заголовков.

## Как подключены 21 компонент

| Компоненты | Сборка/использование |
|---|---|
| `stb_image`, `stb_image_write`, `stb_image_resize2` | Готовые implementations в `LMX::stb` |
| `stb_truetype`, `stb_rect_pack`, `stb_dxt`, `stb_perlin` | Готовые implementations в `LMX::stb` |
| `stb_vorbis`, `stb_hexwave` | Готовые implementations в `LMX::stb` |
| `stb_ds`, `stb_c_lexer`, `stb_divide`, `stb_include`, `stb_sprintf`, `stb_herringbone_wang_tile` | Готовые implementations в `LMX::stb` |
| `stb_leakcheck` | Отдельная цель `LMX::stb_leakcheck`, включаемая приложением явно |
| `stb_easy_font` | Header-only; проверяется компиляцией и генерацией вершин |
| `stb_textedit` | Заголовок с вашими string type/callbacks; рабочий пример в тесте |
| `stb_tilemap_editor` | Заголовок с вашими draw callbacks; рабочий пример в тесте |
| `stb_connected_components` | Заголовок с вашей grid/cluster configuration |
| `stb_voxel_render` | Заголовок с вашим `STBVOX_CONFIG_MODE` и другими mesh-параметрами |

Все заголовки доступны через `LMX::stb_headers`, а `LMX::stb` подключает эту
цель транзитивно. Компоненты с пользовательской конфигурацией проверяются
в отдельных C99 translation units; в общую библиотеку не зашита случайная
конфигурация чужих типов, render callbacks или размеров решётки.

При линковке с готовой `LMX::stb` не нужно повторно определять
`STB_*_IMPLEMENTATION` для уже собранного компонента. Для самостоятельной
конфигурации выбирайте headers target и определяйте implementation ровно
в одном своём C-файле.

## C99-настройки

`STBI_NO_THREAD_LOCALS` выключает необязательные thread-local варианты
image-настроек, использующие C11 или расширения компилятора. Обычные global
settings сохранены. Thread-local setters этой конфигурацией не предоставляются.

`STBI_NO_SIMD` и `STBIR_NO_SIMD` выбирают переносимые C-реализации image/resize.
В закреплённой resize-версии SIMD-константа не проходит GCC
`-pedantic-errors`; вместо подавления ошибки используется предусмотренный
авторами C-вариант. Это может снизить скорость ресайза относительно SIMD.
Заголовки с исходными ускоренными реализациями сохранены без изменений.

Windows-only UTF-8 filename helpers и необязательные OS cache-size queries
не включены. `fopen` и остальная стандартная C99 stdio сохранены. CPU cache
probe resize на поддерживаемом x86 toolchain может использовать `cpuid.h`/
intrinsics; это не системная библиотека. На других архитектурах есть fallback.

Режим C99 не означает отсутствие любых compiler primitives: `stb_vorbis`
использует `alloca`, а `stb_ds` на GCC/Clang применяет `__typeof__` для удобной
передачи rvalue-ключей. У `stb_ds` есть альтернативный путь с адресом lvalue.
Эти требования указаны явно; гарантия для произвольного минимального
ISO-C99-компилятора не заявляется.

`stb_c_lexer` собран с исходными настройками автора. В частности,
`STB_C_LEX_0_IS_EOF=N`: NUL возвращается как токен 0; это учитывает тест.
Это библиотека для лексеров, а не готовый полный frontend ANSI C99.

## Что исключено

Весь актуальный набор public C library files сохранён. Не включены
`deprecated/` (старые замещённые реализации), repository data/benchmarks,
upstream test harness и разработческие инструменты. Они не являются
текущими компонентами коллекции. Вместо mixed-language test harness
предоставлены перечисленные ниже C99-проверки.

## Дополнительные библиотеки

Достаточно стандартной библиотеки C и системной математики (`libm`, где
она отдельная). Внешние libpng, libjpeg, zlib, FreeType, Vorbis, OpenGL или
графический toolkit для этой сборки **не нужны**. Декодеры и алгоритмы
реализованы внутри stb. Для вывода подготовленной геометрии/GUI ваше
приложение само выбирает backend; это отдельное прикладное решение.

## Проверки

Семь CTest programs покрывают все выбранные компоненты:

1. `stb.functional_smoke`: lossless PNG round trip через память; image resize;
   dynamic array/hash map; непересекающаяся упаковка прямоугольников; lexer;
   formatted output; отрицательное деление; Perlin noise; include injection;
   синтез HexWave; DXT-компрессия; Wang template/tileset/map. Для Vorbis и
   TrueType здесь проверяется отказ на неподходящем заголовке, не полноценный
   набор валидных audio/font файлов.
2. `stb.leakcheck_allocator`: calloc/realloc с сохранением содержимого и free.
3. `stb_custom_textedit`: собственная ASCII-строка, paste, cursor, вставка,
   backspace, selection/cut, undo/redo.
4. `stb_custom_tilemap`: создание, определения тайлов, set/get, свойства,
   dimensions, tick/draw callbacks, background tile и очистка всех ячеек
   16×16, включая свойства и связи последней строки.
5. `stb_custom_connected_components`: 8×8 grid с кластерами 4×4; разделяющая
   стена, открытие/закрытие прохода, batch update и connected IDs.
6. `stb_custom_voxel`: mode 1, один padded cube в обычном, explicit geometry
   и vheight-пути даёт 6 quads; после reset и установки буферов пустые данные
   дают 0; shader strings доступны без OpenGL.
7. `stb_custom_easy_font`: генерация vertex/color data, размеры строк,
   multiline height, spacing.

Тесты используют действующие в Release проверки, а не отключаемые assert.

## Исправления индексирования в C99-представлении

`cmake/STBArrayFixes.cmake` создаёт две исправленные копии заголовков в
`build/generated/stb_c99`. Target `LMX::stb_headers` ставит этот каталог перед
`vendor/stb`; оригинальные vendor-файлы и все авторские уведомления сохранены.

У исходного tilemap editor плоский индекс проходил за границу внутренней
строки многомерного массива. UBSan подтвердил ошибку при создании карты:
индекс 16 внутри массива длины 16. В операциях background/clear используются
явные индексы `[i / STBTE_MAX_TILEMAP_X][i % STBTE_MAX_TILEMAP_X]` для данных,
свойств, связей и счётчиков связей.

В voxel renderer аналогично исправлены selector/vmesh-таблицы `[6][4]` и
массивы mesh/slot при reset. В обычном geometry-пути передаётся указатель на
строку из четырёх элементов, а не указатель на первый элемент первой строки
с последующим выходом за её границы. Дополнительно исправлено подтверждённое
UBSan знаковое переполнение при упаковке вершины: преобразование в
`stbvox_uint32` выполняется **до** сдвигов, включая `7 << 29`.

Сфокусированные tilemap/voxel тесты прошли с GCC 14.2.0,
`-std=c99 -pedantic-errors -O1 -fsanitize=undefined
-fno-sanitize-recover=undefined`. До исправлений оба завершались с ошибками
UBSan. Отдельный исходный voxel-прогон с проверкой границ подтвердил выход
за внутренний массив и без проверки сдвигов. Диагностика до исправлений,
логи после и описание изменений сохранены в `docs/validation/stb_c99_fixes`.
Это проверка перечисленных путей, а не гарантия отсутствия любых других
ошибок во всех режимах stb.

В connected-components тесте выбран штатный override кластеров 4×4:
автоматическая конфигурация слишком маленьких кластеров может породить
zero-length arrays, которые строгий C99-компилятор отклоняет.
