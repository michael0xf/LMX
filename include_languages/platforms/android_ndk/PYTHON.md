# Android: private Python и уже установленный Python

## Выбранная реализация

**CPython Android embeddable package с python.org**, GIL-enabled, через C embedding API. Это сохраняет один native provider contract с desktop CPython и не делает Java/другой язык дополнительной частью LMX. `libpython*.so` и его native зависимости входят в выбранный app-native delivery; stdlib и app site-packages извлекаются в app-private files при первом использовании. [Официальное embedding](https://docs.python.org/3.14/using/android.html), [Android releases](https://www.python.org/downloads/android/).

Приоритет — доступность CPython libraries на конкретном Android ABI, а не замена CPython более узким interpreter. Из популярных сборочных SDK Chaquopy полезен своим Android wheel ecosystem, но его Gradle pip workflow не является произвольным runtime pip installer и не доказывает ABI-совместимость его wheels с любым другим build. В выбранном manual NDK profile packages берутся как pure wheels либо проверенные Android wheels matching Python ABI/API. Недостающие native packages заранее cross-build через поддерживаемый upstream/cibuildwheel pipeline. [Python Android packages](https://docs.python.org/3.14/using/android.html#building-a-python-package-for-android), [Chaquopy packages](https://chaquo.com/chaquopy/doc/current/faq.html).

## Что означает установка runtime

Первый `py.install` может устанавливать bundled runtime assets в app-private generation без каких-либо настроек ОС. NDK допускает сценарий copy+`dlopen`, но binary должен иметь подходящий ABI, API, dependencies и alignment. Downloaded native bundle не считается доступным на любом канале доставки автоматически.

**Для Google Play** native `.so` доставляется допустимым Play/app-механизмом; публичная policy ограничивает загрузку executable native code вне Play. Исключение для кода интерпретаторов не превращает произвольный CPython extension `.so` в pure Python. Поэтому runtime download pure-Python packages и доставка native runtime/wheels разделены в install plan. Для иного канала распространения native-download profile проверяется отдельно. [Google Play policy](https://support.google.com/googleplay/android-developer/answer/16559646).

`python`/`pip` executable в app data не используется. Wheel installer работает внутри выбранного provider либо получает заранее подготовленный bundle; сборка `sdist` на устройстве не является скрытым fallback. `.pth`/startup hooks не исполняются автоматически в изолированном default.

## Ограничения библиотек

`subprocess` и `multiprocessing` официально не поддерживаются Android Python. Native stdout/stderr и stdin не эквивалентны terminal desktop; streams интегрируются с приложением/logging. Обычные file/socket/thread возможности действуют в app sandbox и host lifecycle. [Python availability](https://docs.python.org/3.14/library/intro.html), [subprocess](https://docs.python.org/3/library/subprocess.html), [multiprocessing](https://docs.python.org/3.14/library/multiprocessing.html).

Manylinux/glibc wheels не подходят bionic. Наличие wheel не доказывает 16-KB alignment всех его `.so`; проверить их вместе с libpython. GIL-enabled Python и owner Message не дают parallel bytecode execution; native extensions могут иметь собственные worker threads, которые нужно завершить до освобождения runtime.

## Альтернативный путь

На Android нет общего системного Python, гарантированно доступного всем приложениям. Если Python уже установлен, например внутри другого приложения/Termux, он должен **явно предоставить bridge service/endpoint**. LMX подключается к нему через external protocol; sandbox другого приложения не обходится, доступность его executable/path не предполагается. Если такого endpoint нет, mode external сообщает unavailable; private runtime остаётся основным способом.

[LMX private example](../../examples/private_runtime.lmx), [system endpoint example](../../examples/system_python.lmx), [install algorithm](../../src/install.lmx). Android-specific native provider, packaging, emulator и physical-device checks остаются `REQUIRE_IMPLEMENTATION`/`NOT_RUN`.
