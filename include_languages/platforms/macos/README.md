# macOS: платформа LMX

**Целевая платформа. Полная сборка этого выпуска: NOT_RUN.** Python вынесен в [PYTHON.md](PYTHON.md).

Базовый C99 compiler — Clang с выбранным macOS SDK/deployment target. Срезы arm64 и x86-64 проверяются независимо; universal binary объединяет совместимые срезы, но не делает зависимость другой архитектуры загружаемой. OS/SDK/platform-specific calls изолированы в host adapter.

Для native памяти сохраняются общие C99 правила, реальные alignment и LP64 sizes. Нельзя делать предположение, что unaligned typed access допустим на любом host. Пути, bundle resources и writable application data разделены; ядро не пишет в подписанный `.app` для обновления своих данных.

Hardened Runtime ограничивает JIT/executable memory и загрузку сторонних библиотек. Для интерпретатора LMX не следует включать JIT-разрешения только потому, что существует MIR target. Реальная JIT-конфигурация требует отдельной платформенной приёмки; загружаемые dylib/extension согласуются с code-signing выбранного приложения. [Apple: Hardened Runtime](https://developer.apple.com/documentation/security/hardened-runtime).

Приёмка: C99 build на обоих выбранных срезах, SDK/deployment compatibility, Unicode paths, запуск из подписанного bundle, read-only bundle с app-owned data, Message owner lifecycle, dylib dependencies. Поведение через Rosetta не заменяет нативный arm64 receipt.
