# Применение патча LMX runtime server

Архив содержит изменения документации и новые LMX-заготовки собственного сервера runtime, API агента, каталог SQLite и примеры MCP. Исходники ядра в этот патч не входят.

## Основа

Порядок документов:

1. `27-Nov-2026-doc.tar.gz`;
2. уже выпущенный `27-Nov-2026-doc-tensor-patch.tar.gz`;
3. этот `27-Nov-2026-doc-runtime-server-patch.tar.gz`.

Два replacement-файла LMX_semantics собраны именно поверх шага 2. Прямое наложение на исходный архив без tensor patch не заменяет все изменения предыдущей работы.

## Состав и проверка

[PATCH_MANIFEST.json](PATCH_MANIFEST.json) содержит входные SHA-256, before/after SHA двух изменённых существующих документов и SHA каждого добавленного файла. Внутри delta нет неизменённых файлов исходной документации или ядра.

[Unified diff](docs/runtime_server/changes/LMX_semantics.diff) показывает изменения только двух существующих нормативных документов. Его применение к указанной основе проверено; полученные файлы побайтно совпали с replacement-файлами. Новый каталог `docs/runtime_server/` устанавливается вместе с ними.

Распакуйте архив в отдельный каталог для просмотра. Перед наложением сравните свои `docs/spec/LMX_semantics.en.md` и `.ru.md` с `before_sha256` manifest. Если файлы уже отличаются, применяйте diff как обычное слияние локальных изменений, не заменяйте их вслепую. Если основа совпадает, перенесите содержимое `docs/` поверх соответствующего корня документации.

## С чего начать

- [README пакета](docs/runtime_server/README.md).
- [Архитектура](docs/runtime_server/docs/ARCHITECTURE.ru.md).
- [Точный API](docs/runtime_server/docs/API.ru.md).
- [Каталогизация и SQLite](docs/runtime_server/docs/CATALOGUE_SQLITE.ru.md).
- [План реализации](docs/runtime_server/docs/IMPLEMENTATION_PLAN.ru.md).
- [Выполненные проверки](docs/runtime_server/docs/VALIDATION.ru.md).

Нормативный контракт: `fromLmx` создаёт чистый граф, пригодный для компиляции; `toLmx` выдаёт LMX-код любой Structure и любого L3Thread. Сервер использует эти ресиверы ядра и обычный Message/native-walker runtime. Неприсоединённые provider slots остаются явно указанной работой реализации.
