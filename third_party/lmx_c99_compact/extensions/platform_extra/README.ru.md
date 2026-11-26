# APR, APR-Util и SDL3: автономная группа платформенных библиотек

Исходники: APR 1.7.6, APR-Util 1.6.6, SDL 3.4.20. Официальные адреса,
хеши полученных архивов, публичные заголовки, зависимости и CMake targets
записаны в `SOURCES_ENTRIES.json`. Публичный API сохранён для каталогизации
целиком, в том числе API отключённых в проверенном профиле возможностей.

## Сборка

Из `third_party/lmx_c99_compact`:

```sh
cmake -S extensions/platform_extra -B build/platform -G Ninja -DCMAKE_BUILD_TYPE=MinSizeRel
cmake --build build/platform
ctest --test-dir build/platform --output-on-failure
```

Нужны C99-компилятор, CMake >= 3.20, POSIX shell, make, системные заголовки
и библиотека Expat. Проверенный компилятор — GCC 14.2; применяется
`-std=c99 -pedantic-errors`, а не режим GNU99. Настройка и сборка ничего не
загружают. Autoconf и libtool не нужны: сохранены release `configure` и
минимальные сопровождающие сценарии. Сгенерированные платформенные
`apr.h`, `apu.h` и private config headers создаются в каталоге сборки.

При включении в общее дерево существующий `LMX::expat` используется повторно.
В build tree создаётся небольшой префикс с уже собранным архивом Expat и двумя
публичными заголовками; второй комплект исходников не создаётся.

Targets: `LMX::apr`, `LMX::apr_util`, `LMX::sdl3`, общий
`LMX::platform_extra`. `LMX_PLATFORM_BUILD_APR=OFF` позволяет собирать SDL
отдельно. `LMX_PLATFORM_EXTRA_BUILD_TESTS` включает три автономных теста.
`LMX_PLATFORM_VENDOR_DIR` позволяет проверить тот же адаптер на исходных
неусечённых upstream trees. `LMX_PLATFORM_SDL_X11=OFF` выбирает профиль без
X11/OpenGL; исходники платформенных backend остаются в архиве.

APR имеет upstream CMake для Windows; он сохранён вместе с Windows sources.
Общий адаптер APR здесь проверен на POSIX и использует configure/make.
Windows, macOS, Android, iOS и физические устройства в этой среде не
проверялись. В SDL сохраняется необходимый платформенный код на Objective-C,
C++ и Java там, где он входит в upstream source tree; проверенный Linux
производственный профиль компилирует C, и это не означает, что каждый файл
многоплатформенного upstream написан на C99.

## Что включено в проверенный профиль

APR: пулы/аллокаторы, строки, кодировки/escape, hash/table/array, файлы,
сеть IPv4/IPv6, потоки, блокировки, mmap, shared memory, процессы, время,
случайные байты, poll, DSO loading. `apr_skiplist_*` пока не входит в выбранный C99 архив:
upstream упорядочивает адреса функций, преобразованные в `void *`, через
`<`/`>`. `vendor/apr/tables/apr_skiplist.c` и публичный заголовок сохранены;
это явно `outside_selected_profile`, не скрытая потеря исходников.

APR-Util: XML через Expat, URI, base64, SDBM, buckets, queue/thread pool,
memcache/Redis clients, ресурсные пулы, UUID, встроенные digest/password
примитивы и другие автономные функции. Внешние LDAP, SQL и crypto providers
не активированы. Их исходники и интерфейсы оставлены для последующего
подключения. Наличие API определяется сгенерированным `apu.h`.

SDL: software rendering, поверхности/BMP, IO, преобразование аудио,
events, threads/timers/processes, properties, dummy/disk audio,
dummy/offscreen video, OpenGL renderer, Linux/HIDAPI/virtual controllers,
V4L2 camera, Unix tray. X11 включается при наличии X11/Xext dev inputs;
дополнительные Xcursor/Xinput/Xfixes/Xrandr/Xscreensaver/Xtest расширения
не требуются профилем. Vulkan/GPU, Wayland/KMS и внешние звуковые серверы
сейчас отключены настройками. Исходники этих возможностей сохранены.

## Изменения для C99

`vendor/` содержит неизменённые выбранные файлы официальных выпусков.
`prepare_views.cmake` создаёт локальный build view и проверяет SHA-256 каждого
изменяемого файла до применения адаптации. `C99_ADAPTATIONS.json` содержит
хеши входов и результатов. Подавления `-Wpedantic` нет.

APR-Util optional-function registry хранит адрес **ячейки с типизированным
указателем на функцию** в hash table; NULL сохраняет семантику удаления.
SDL qsort/bsearch передают адрес типизированной callback-ячейки. В Sinput,
SteamDeck и Switch анонимные C11 union/struct заменены именованными полями;
порядок и типы элементов wire packet не меняются.

В SDL сохраняется исходный ABI-контракт динамической загрузки и pointer
properties. Там, где upstream преобразует адрес функции в `void *` и обратно,
адаптер копирует представление через unsigned char/memcpy и проверяет равенство
размеров на этапе компиляции. Это C99-синтаксис с **условием ABI платформы**,
а не доказательство существования такого преобразования на любой C99-машине.
Поддержанный здесь ABI — Linux/POSIX с одинаковым размером object/function
pointers. Null-путь оставляет типизированный NULL. Early dynapi bridge не
вызывает SDL_memcpy до инициализации dispatch table.

## Проверки и компактность

`VERIFICATION.json` и `COMPACTNESS.json` фиксируют результаты и точные размеры.
Сохраняются исходные тесты/примеры в виде кода; крупные fixture assets,
сайты, CI/IDE-проекты, готовые binaries и дистрибутивные архивы удалены.
Не заявляется, что все upstream tests могут выполняться без удалённых assets.
Три добавленных теста генерируют собственные данные и работают без сети:

- APR: pool/hash/table/array, файловая запись и повторное чтение, два потока
  с mutex и проверкой результата.
- APR-Util: бинарный base64, URI, XML entity и потоковая подача, ошибочный XML,
  SDBM close/reopen и callback register/retrieve/invoke/remove.
- SDL: qsort/bsearch, thread result, event queue, software renderer и blit,
  BMP roundtrip в памяти, custom free callback, audio format/rate/channel
  conversion и загрузка символа из тестовой C shared library. Dummy backends позволяют выполнять тест без оборудования.

Проверка dummy backend не подтверждает работоспособность физического
звукового устройства, GPU, камеры, gamepad или оконного сервера.
Лимит 1 MB для этих многопрофильных пакетов снят пользователем; размеры
static `.a` не равны размеру финальной программы с выбранными функциями.

## Лицензии

APR и APR-Util: Apache-2.0 плюс сохранённые `LICENSE`/`NOTICE` и встроенные
permissive notices. `configure` имеет разрешение неограниченного копирования.
Сохранённые GNU `config.guess`, `config.sub`, `ltmain.sh` относятся к сборке
и содержат явные upstream exceptions, разрешающие распространение вместе
с библиотекой на условиях библиотеки. Эти исключения не удалялись.

SDL: zlib; встроенный HIDAPI распространяется по permissive варианту
из своего набора лицензий (BSD/original alternative), его notices сохранены.
GPL-вариант выбора не используется. SDL `LICENSE.txt`, HIDAPI notices,
`SDL_copying.h` и лицензии вспомогательного кода сохранены. Включение этих
upstream файлов не означает отправку изменений в upstream.

Неиспользуемый `SDL3 src/hidapi/m4` удалён после проверки сборочных правил.
В частности, exception в `ax_pthread.m4` разрешает свободное использование
сгенерированного configure, но не меняет GPL самого исходного macro.
Этот вход не нужен SDL CMake; production C и переносимые backend остаются
в коллекции. Точный перечень и размеры — `LICENSE_RETENTION_AUDIT.json`.
