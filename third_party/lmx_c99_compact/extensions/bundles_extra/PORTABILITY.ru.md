# Проверяемые изменения представления для сборки

Все перечисленные изменения выполняет `prepare_bundles.cmake` после проверки
SHA-256 входного файла. В `vendor/` остаётся оригинал. CMake и `src/` — обычный
читаемый код адаптации, а не инструкция скачать или пропатчить неизвестную
последующую версию. После обновления vendor hash должен быть пересмотрен.

| Исходник | Изменение | Основание проверки |
| --- | --- | --- |
| gb.h | C99 variadic assert/panic macros без GNU comma elision; forward declaration `struct gbThread`; убраны лишние `;` после macro-generated определений; `dlsym` representation copy с проверкой размеров вместо object/function pointer cast | Strict C99; вызов thread callback, arenas/strings/files/sort |
| gb implementation TU | `gb_inline` задаётся как обычное внешнее определение | GCC forced-inline + PIC interposition иначе не компилируется |
| gb_ini.h | `gb_ini_error_string` имеет декларацию в public header и единственное определение под implementation guard | Связывание библиотеки с отдельным consumer TU |
| cute_tiled.h | Forward typedef для `cute_tiled_chunk_t` | Чтение finite и infinite/chunk карты |
| cute_png.h | Повторный typedef заменён определением уже объявленного struct | PNG encode/decode roundtrip с varying alpha |
| cute_sync.h | Повторный typedef устранён; POSIX CAS сравнивает возвращённое старое значение с expected | Успешный/неуспешный integer и pointer CAS, thread pool 300 задач |
| cute_net.h | Scope каждого повторно именованного compile-time typedef в upstream tests отделён | Все 49 встроенных tests собираются C99 и проходят |
| cute_spritebatch.h | `term` освобождает собственные lonely и atlas handles через callback; borrowed premade handles не трогает | Проверка обеих ветвей владения ресурсами |
| spritebatch implementation TU | Явные `stdint.h` и `limits.h` | Upstream использует `uintptr_t` и `INT_MAX`, не включая эти headers |
| cute_sound.h | Скобки в CPU feature checks делают scalar override действующим; устранены duplicate typedef и два лишних `;` | Строгая C99 сборка; WAV metadata и SDL dummy lifecycle |
| EA calloc.c | Порог проверки multiplication overflow вычисляется в `size_t`, не `unsigned long` | Для LLP64 `long` может быть 32-битным при 64-битном `size_t`; overflow test |
| EA strtoull.c | Цифры A–Z/a–z переводятся прибавлением 10, не вычитанием | Base-16/base-36, ULLONG_MAX и end pointer |
| EA towccase.c | Range differences сравниваются без знака; supplementary-plane case offset использует правильное направление | Кириллица и Deseret upper/lower |
| EA wcwidth.c | Отдельный индекс для wide table; unsigned differences для supplementary ranges | CJK width=2, combining width=0 и сумма ширин |
| EA iswspace.c | Явный просмотр 32-битной таблицы вместо вызова системного `wcschr` | Проверка U+3000; не смешиваются Win32 16-битные и выбранные 32-битные wide values |

EA исходники компилируются через маленькие generated wrapper TUs: host headers
включаются до приватных namespace macros, все внешние функции переименованы в
`lmx_ea_*`. `-fno-builtin`, `-fno-strict-aliasing` и для GCC
`-fno-tree-loop-distribute-patterns` не дают компилятору свернуть переименованные
реализации libc в рекурсивный вызов host builtin. Публичный façade содержит
80 функций; ещё один внутренний case helper также имеет префикс.

Другие OS/CPU ветви не объявлены протестированными. Размеры, typedef ширины,
thread intrinsics и native handles требуют проверки при переносе на конкретную
платформу. C99 language mode не устраняет зависимость ОС у сетевых, файловых,
звуковых и потоковых функций.
