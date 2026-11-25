# Семь небольших ненумерических библиотек

В коллекцию подготовлены семь дополнительных библиотек: суффиксный поиск, триангуляция, столкновения выпуклых тел, INI, терминальный редактор, Unicode-сегментация и современный xxHash. Они собраны из сохранённых исходников как C99, без загрузок во время конфигурации или сборки. Работа этих алгоритмов не требует внешнего сервиса. Локальные файлы и терминал доступны только тем вызовам, чья собственная семантика их использует.

Общий принцип каталогизации описан в [архитектуре](../ARCHITECTURE.ru.md), а общие DATA — в [моделях границы L3/L2](../types/README.ru.md). Альтернативные библиотеки и их исходные API сохраняются. Общие данные не превращаются в отдельные, несовместимые LMX-типы только потому, что потребитель данных сменился.

## Состав и измерения

Измерения относятся к Linux x86-64, GCC 14.2.0, CMake `MinSizeRel`, `-Os -DNDEBUG -std=c99 -pedantic-errors`, PIC. Размер — весь статический архив без удаления таблицы символов. Это более строгая проверка размера, чем подсчёт только машинного кода. Размер другой платформы следует измерять отдельно; Windows/macOS здесь не запускались. Полный результат находится в [non_numeric_build.json](non_numeric_build.json).

| Библиотека и версия | Назначение; пакет | Лицензии сохранённых частей | Архив, байт | Проверка поведения |
| --- | --- | --- | ---: | --- |
| libdivsufsort 2.0.2-1, закреплённый commit | Суффиксный массив, поиск, BWT; `text\search` | MIT | 27 624 для 32-bit индекса; 27 724 для 64-bit | `banana` → `[5,3,1,0,4,2]`, поиск `ana`, BWT→inverse BWT, оба размера индекса |
| libtess2 1.0.3, закреплённый commit | Триангуляция контуров; `geo\tessellation` | SGI-B-2.0 | 47 570 | Квадрат с отверстием; сумма площадей треугольников равна 12 |
| libccd, закреплённый commit; upstream CMake 2.0 | GJK/EPA/MPR для выпуклых тел; `geo\collision` | BSD-3-Clause | 45 120 | Раздельные/пересекающиеся коробки, глубина проникновения 0.5 через GJK/EPA и MPR |
| inih, закреплённый commit; upstream Meson 63 | INI; `text\ini` | BSD-3-Clause | 4 452 | Секция и значения, повреждённая секция, отказ callback |
| isocline 1.1.0 | Строковый редактор REPL; `ui\terminal` | MIT + permissive notice Markus Kuhn для встроенного `wcwidth` | 126 218 | UTF-8-переходы, токены, история в памяти, чтение строки с Unicode из pipe |
| libunibreak 8.0 | Границы строк, слов и графем; `text\unicode` | Zlib + Unicode-3.0 | 149 060 | Комбинируемый знак, emoji с ZWJ, UTF-16 surrogate pair, перенос строки и границы слов |
| xxHash 0.8.4 | XXH32/64, XXH3-64/128; `code\hash` | BSD-2-Clause | 19 218 | Golden values старых алгоритмов, streaming/one-shot XXH3, canonical 128-bit round-trip, сравнение XXH64 с копией 0.6.5 |

Все восемь архивов меньше **1 000 000 байт**. Девять функциональных тестов прошли. Проверка `nm` также подтвердила, что все внешние символы новой копии xxHash имеют префикс `LMXC99_XXH_`. Это проверки C-библиотек и адаптеров сборки. Компиляция и выполнение LMX-обёрток не выполнялись; полная интерактивная сессия терминального редактора также не проверялась.

## Закреплённые исходники и лицензии

Точные commit, URL архивов, SHA-256 архивов и каждого сохранённого файла записаны в [PROVENANCE.json](../../../third_party/lmx_c99_compact/extensions/text_hash_extra/PROVENANCE.json). Архивы загрузки, сторонние build tools, бинарные результаты и исходные деревья тестовых framework в патч не входят. Production-файлы upstream не изменялись.

Компактность исходников измерена отдельно от размера бинарной библиотеки:

| Набор | Полный распакованный upstream, байт | Сохранённый vendor, байт |
| --- | ---: | ---: |
| libdivsufsort | 133 689 | 83 705 |
| libtess2 | 247 809 | 189 892 |
| libccd | 337 202 | 120 640 |
| inih | 92 732 | 28 267 |
| isocline | 1 228 035 | 400 853 |
| libunibreak | 4 527 072 | 815 890, включая дополнительно сохранённую Unicode-лицензию |
| xxHash | 5 511 342 | 300 853 |

Unicode-таблицы libunibreak и включаемые `.c`-части isocline являются входами компиляции, поэтому сохраняются. Точные размеры и число файлов приведены в `source_selection` provenance; коэффициент сокращения не подменяется одинаковым обещанием для каждой библиотеки.

| Источник | Закреплённый commit | Текст лицензии в патче |
| --- | --- | --- |
| [y-256/libdivsufsort](https://github.com/y-256/libdivsufsort) | `5f60d6f026c30fb4ac296f696b3c8b0eb71bd428` | [LICENSE](../../../third_party/lmx_c99_compact/vendor/libdivsufsort/LICENSE) |
| [memononen/libtess2](https://github.com/memononen/libtess2) | `8dbd6483e920311a58c9af10a10beb278efebc36` | [LICENSE.txt](../../../third_party/lmx_c99_compact/vendor/libtess2/LICENSE.txt) |
| [danfis/libccd](https://github.com/danfis/libccd) | `7931e764a19ef6b21b443376c699bbc9c6d4fba8` | [BSD-LICENSE](../../../third_party/lmx_c99_compact/vendor/libccd/BSD-LICENSE) |
| [benhoyt/inih](https://github.com/benhoyt/inih) | `18d8e283993c752731d31176241f9da136454789` | [LICENSE.txt](../../../third_party/lmx_c99_compact/vendor/inih/LICENSE.txt) |
| [daanx/isocline](https://github.com/daanx/isocline/tree/v1.1.0) | `d55a58139badbe83d61c5d89954fa5bddcabe6d7` | [LICENSE](../../../third_party/lmx_c99_compact/vendor/isocline/LICENSE), [wcwidth.c](../../../third_party/lmx_c99_compact/vendor/isocline/src/wcwidth.c) |
| [adah1972/libunibreak](https://github.com/adah1972/libunibreak/tree/libunibreak_8_0) | `28a2756b864c343f438cd22537d49d394d4666a5` | [LICENCE](../../../third_party/lmx_c99_compact/vendor/libunibreak/LICENCE), [UNICODE_LICENSE.txt](../../../third_party/lmx_c99_compact/vendor/libunibreak/UNICODE_LICENSE.txt) |
| [Cyan4973/xxHash](https://github.com/Cyan4973/xxHash/tree/v0.8.4) | `c87183a77d67f7d37e3d2d1b7eaac5e7c695e4f0` | [LICENSE](../../../third_party/lmx_c99_compact/vendor/xxhash/LICENSE) |

libunibreak содержит готовые таблицы Unicode 17.0.0. Они компилируются локально; скачивание Unicode Data или запуск генераторов при сборке не требуется. Дополнительный текст Unicode License V3 получен с [официального сайта Unicode](https://www.unicode.org/license.txt); его происхождение отдельно помечено в provenance. В libccd не включён upstream test framework CU с LGPL. В xxHash не включены GPL-исходники команды `xxhsum`. Эти исключения не затрагивают выбранные библиотечные API.

## Конкретные ограничения интеграции

**libdivsufsort.** Собраны два исходных API с индексами `int32_t` и `int64_t`. На L3 это один смысловой тип последовательности индексов с явной шириной хранения, если она существенна для вызывающего кода. Отрицательные значения длины и переполнение при преобразовании `size_t` проверяются до C. Для текста требуется явное представление байтов: суффиксный массив этой библиотеки индексирует байты, а не Unicode-графемы. Два публичных заголовка — воспроизводимые раскрытия upstream-шаблона; остальные production-файлы сохранены буквально.

**libtess2.** Вход — контуры в общем `BridgeData\Tensor`, координаты и индексы результата остаются общими массивами. В интерфейсе необходимо сохранять winding rule, число координат вершины и выбранный формат выходных элементов. Ссылки `tessGetVertices` и `tessGetElements` заимствованы у tessellator: обёртка должна скопировать результат или удерживать его владельца. Такие адреса не становятся долговечными ссылками L3 автоматически.

**libccd.** Выбран единственный C ABI с `CCD_DOUBLE`; параллельный float ABI под теми же символами не создаётся. Геометрия использует общие `BridgeData\Vector3`/`Tensor`; C-структуры и callback являются деталями адаптера. Support/center callbacks должны иметь явного владельца, срок жизни и лимит работы. Нужно проверять статус алгоритма, конечность координат и допустимые tolerances. Результат «нет пересечения» сохраняется отдельно от ошибки выделения памяти.

**inih.** Callback выдаёт пару `section/name/value`; тот же смысловой результат можно представить через существующие `BridgeData\KeyValue` или `ParseNode`. INI не задаёт единой семантики повторов ключей, multiline и комментариев для всех систем: выбранные upstream compile-time настройки фиксируются в профиле и не подменяются догадкой об универсальном формате. Файловый API `ini_parse` требует полномочия на чтение файла; `ini_parse_string` работает с уже имеющимися данными. На Windows путь к файлу следует учитывать отдельно от кодировки содержимого; upstream допускает передачу `FILE*`, открытого подходящим API.

**isocline.** В upstream существует один `static ic_env_t *rpenv`, а редактор управляет общим терминалом и обработчиками сигналов. Состояние нельзя механически копировать из R0 в каждого актора. Его следует обслуживать одним terminal actor/service, сериализуя команды, с единственным владельцем истории, completer/highlighter и выделенной памяти. Данные строки возвращаются в арену запрашивающего актора, а память isocline освобождается через согласованный allocator. `ic_init_custom_malloc` — настройка процесса до других вызовов, а не обычная локальная операция каждого L3-актора. Readline-подобные возможности дают permissive альтернативу для REPL, но ABI и набор деталей отличаются от GNU Readline. Собран обычный upstream debug-function profile: необязательный `IC_NO_DEBUG_MSG` не включён, потому что его macro допускает пустой variadic аргумент, отвергаемый строгим C99. Вывод диагностики остаётся выключенным без переменной `ISOCLINE_DEBUG`.

**libunibreak.** Для UTF-8/16/32 длины и выходные метки имеют единицы кодирования соответствующего API. Метка `INSIDEACHAR` не является границей графемы. Общий фасад должен нормализовать единицы индекса явно и сохранять различие «граница слова», «разрешённый перенос строки» и «граница графемы». Unicode normalization остаётся отдельной операцией, например существующего utf8proc. Тип LMX-строки при выборе другого backend не меняется.

**Современный xxHash.** Новая библиотека собирается с PRIVATE `XXH_NAMESPACE=LMXC99_XXH_`. Потребитель включает [lmx_xxhash_modern.h](../../../third_party/lmx_c99_compact/extensions/text_hash_extra/include/lmx_xxhash_modern.h). Старый заголовок из LZ4 и новый заголовок используются в **разных C translation units**: у версий совпадает include guard и имеются несовместимые внутренние типы состояния. Снятие `XXH_NAMESPACE` после include тоже неправильно, потому что aliases раскрываются позднее. В [COMPONENTS.json](../../../third_party/lmx_c99_compact/extensions/text_hash_extra/COMPONENTS.json) указан `canonical_header_map` и преобразование фактических ABI-символов. Shared compile definitions для `LMX::all` не применяются.

Обе реализации XXH64 получают один `BridgeData\Buffer`, одну длину и seed; проведён тест равенства результата в одном процессе. XXH3-64 и XXH3-128 — другие алгоритмы. Их результаты должны содержать algorithm/width/seed в обычном DATA-описании; для переноса между платформами используется canonical byte representation, а не дамп C-структуры. Это некриптографические хеши; API crypto-библиотек остаётся отдельным выбором для соответствующих задач.

## Рассмотренные альтернативы и решения

| Кандидат/ситуация | Решение и конкретная причина |
| --- | --- |
| GNU Readline | Для нового встраивания выбран isocline. [Официальная страница Readline](https://tiswww.cwru.edu/php/chet/readline/rltop.html) указывает GPL; выбранный библиотечный профиль isocline имеет permissive условия. Это функциональная альтернатива для REPL, не обещание совместимости всех Readline API. |
| libcsv | Не добавлен: [официальный COPYING](https://github.com/rgamble/libcsv/blob/master/COPYING) содержит LGPL-2.1. Permissive CSV-backend остаётся незакрытым пунктом, а не считается заменённым INI/TOML-парсером. |
| libccd upstream tests/CU | В тестовый патч не включены LGPL-файлы CU. Проверки геометрического API написаны отдельно и используют выбранную BSD-библиотеку. |
| xxHash `xxhsum` | GPL CLI не нужен для опубликованных функций BSD-библиотеки; он не входит в сохранённый набор. |
| Старый и новый xxHash | Обе реализации сохранены. Коллизии символов устранены namespace, несовместимость заголовков — разными C units. Новые XXH3 API также доступны. |
| Имеющийся utf8proc и новый libunibreak | Оба backend полезны. Существующий utf8proc используется из Mongo без второй копии того же snapshot; libunibreak добавляет самостоятельные API сегментации. Общие LMX данные переиспользуются. |

## Воспроизведение

Адаптер находится в [extensions/text_hash_extra/CMakeLists.txt](../../../third_party/lmx_c99_compact/extensions/text_hash_extra/CMakeLists.txt); фрагмент реестра — в [COMPONENTS.json](../../../third_party/lmx_c99_compact/extensions/text_hash_extra/COMPONENTS.json). При интеграции корневой CMake добавляет `extensions/text_hash_extra` и связывает `LMX::all` с `LMX::text_hash_extra`. Другие группы здесь не изменяются. Множество тестов запускается через отдельный проверочный driver, даже если production-компактный профиль отключает `BUILD_TESTING`.

Из корня проекта после наложения патча:

```sh
python3 docs/core_catalog/tools/rebuild_extra_headers.py --project . --check
python3 docs/core_catalog/tools/check_additional_libraries.py \
  --project . --work-dir /tmp/lmx-extra-checks \
  --report /tmp/lmx-extra-checks/report.json
```

Если исходники legacy xxHash находятся вне проверяемого дерева, проверочному driver можно передать `--legacy-xxhash-dir /path/to/lz4/lib`. Без имеющейся legacy-копии специальный dual-backend тест не запускается, а остальные библиотеки проверяются независимо. Команды не устанавливают инструменты и не обращаются в сеть. CMake 3.20+, C99-компилятор и обычный системный build tool должны быть доступны заранее. Проверка повторно сверяет SHA-256 всех сохранённых upstream-файлов, собирает архивы, запускает функциональные тесты и измеряет размер. Публичные функции далее инвентаризируются общим генератором каталога; никакой компонент не получает статус готового L3 API только вследствие успешной C-сборки.
