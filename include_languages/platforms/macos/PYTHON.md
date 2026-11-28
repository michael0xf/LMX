# macOS: app-private Python

**Выбор: CPython GIL-enabled из python-build-standalone**, с dylib нужного `aarch64-apple-darwin` либо `x86_64-apple-darwin` target. Python, wheel и зависимые dylib должны иметь нужный Mach-O slice и совместимый deployment target. [Distribution metadata](https://docs.astral.sh/python-build-standalone/distributions/).

Runtime generation размещается в app-owned Application Support либо другом выбранном writable app root. Подписанный `.app` не модифицируется при `installPython`. Startup paths задаются изолированным PyConfig; глобальный `PYTHONHOME`, `PATH`, shell profile и системный Python не меняются.

Для Hardened Runtime dylib/plugin должен проходить library validation: по умолчанию принимается Apple signing либо тот же Team ID. Проект должен выбрать и проверить свой packaging/signing профиль. Entitlement для сторонних plug-ins — осознанная build-конфигурация конкретного приложения, не настройка ОС и не автоматически включаемый installer workaround. [Apple: library validation](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.cs.disable-library-validation).

**Альтернатива:** явный executable уже установленного Python в отдельном worker. Homebrew/framework/venv installations допускаются по фактическому handshake, а не по угадыванию стандартного каталога. Его packages доступны worker; приложение не переписывает их и не добавляет несовместимый libpython в свой process.

[Общий installation algorithm](../../src/install.lmx), [private](../../examples/private_runtime.lmx), [system](../../examples/system_python.lmx). Проверить перемещение app, оба native slices, code signing, native wheels и живые handles при смене поколения. Provider пока `REQUIRE_IMPLEMENTATION`.
