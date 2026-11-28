# Android NDK: ограничения относительно LMX

**Целевая C99-совместимая платформа. Android build/emulator run: NOT_RUN.** Выбранный Python и оба способа доступа описаны отдельно в [PYTHON.md](PYTHON.md).

## ABI, C library и сборка

Android использует Linux kernel и ELF, но **bionic**, а не glibc; Linux бинарник той же ISA не является Android-библиотекой. NDK предоставляет C headers, Clang/lld и публичные native API. Начальная Python-связка выбирает `arm64-v8a` и `x86_64`; обычное ядро LMX не получает искусственный запрет на другие C99 ABI, но для них нужен отдельный receipt. [PEP 738](https://peps.python.org/pep-0738/), [NDK ABI](https://developer.android.com/ndk/guides/abis).

`minSdkVersion` определяет native API availability и минимальную ОС всего dependency graph. Проверка версии только перед вызовом не спасает от отсутствующего symbol при загрузке. Для реально опционального нового API нужен допустимый dynamic lookup. `compileSdkVersion` не заменяет NDK API target. [NDK SDK versions](https://developer.android.com/ndk/guides/sdk-versions).

Сервисы threads входят в bionic libc; не требовать отдельные `libpthread`/`librt`. Dynamic loader API требует `libdl`; логирование — `liblog`. Использовать публичные NDK API, а не private Android/system library symbols. [Native APIs](https://developer.android.com/ndk/guides/stable_apis).

## Память и выполнение

Не фиксировать page size 4096. NDK r28+ по умолчанию строит 16-KB-aligned ELF; проверить также все сторонние `.so`, package alignment и фактический page size. Размер arena record и размер системной страницы — разные величины. [16-KB pages](https://developer.android.com/guide/practices/page-sizes).

Для приложений, ориентированных на Android 10+, `execve` файлов из writable app home запрещён. Следовательно, план «скачать компилятор/python в data directory и запустить как desktop executable» не является базовым профилем. LMX interpreter и загруженная допустимая shared library используют другой путь. JIT/MIR generation требует отдельного executable-memory adapter и проверки конкретного target; C99-ядро не должно зависеть от него. [Android 10 changes](https://developer.android.com/about/versions/10/behavior-changes-10).

## Жизненный цикл приложения

App имеет собственный sandbox, storage и жизненный цикл. UI thread не является бесконечно блокируемым owner loop; длительное исполнение идёт в предусмотренную native lane. Message сохраняет штатный механизм LMX; создание native threads относится к Android host adapter. При остановке process не обещается финальное callback-сохранение. Документ/состояние нужно публиковать в предусмотренных приложением точках сохранения.

LMX input/output получает реальные host channels: assets/files/document access, logging и UI; ожидание консольного stdin не является обязательной частью ядра. Handle внешнего Android resource не становится обычным числовым указателем. Android разрешения и доступность сервиса проверяются тем adapter, который его использует.

## Приёмка

Собрать ядро без Python и с Python provider отдельно; проверить arm64 device и x86-64 emulator, минимум выбранного API, 4-KB/16-KB среды, app suspend/restart, Message cancellation, storage lifecycle, ELF dependencies и невозможность загрузки ошибочного ABI. Нативный library test на Ubuntu эту приёмку не заменяет.
