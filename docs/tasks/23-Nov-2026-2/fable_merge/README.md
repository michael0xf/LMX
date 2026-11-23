# Fable: одна текущая поставка для слияния

Этот пакет строит **прямой переход от исходной загруженной `spec.tar.gz` к нынешней полной `spec`**. Он включает сохранённую нормативную основу 23-Nov, восстановленные короткие приёмы 22-Nov, последующие сокращения, полезные общие функции и SBCL_comparison. Старый diff-пакет 23-Nov перед ним или после него применять не нужно: актуальные `source.patch`, `generated.patch` и `changes.json` описывают сразу конечную редакцию.

Исходный архив найден и проверен целиком:

```text
spec.tar.gz
SHA-256 4b142bab169cf7cc3fd89766da35b90561f913b68dca3ab1f0725793e4ecb932
```

Это настоящий первоначальный архив, не заново упакованная реконструкция и не архив 23-Nov. [BASELINE_PROVENANCE.json](BASELINE_PROVENANCE.json) фиксирует проверку исходных 863 файлов, всех 683 записей прежнего diff и всех 397 сохранённых preimages. Два поздних PDF/XLSX в старой поставке отсутствовали в её diff; новый пакет охватывает полную текущую `spec`. [BUILD_PROVENANCE.json](BUILD_PROVENANCE.json) содержит фактический digest конечного дерева, [VALIDATION.json](VALIDATION.json) — проверку его побайтового восстановления.

## Состав и пути

Рядом лежит полная новая директория [spec](../spec/README.md). Пути в patches и `changes.json` относительны корню вашей `docs/spec` или `spec`; путь компьютера автора не является частью договора.

| Файл | Назначение |
| --- | --- |
| `changes.json` | Каждый add/modify/delete, исходный и конечный SHA-256, размеры, source/generated |
| `source.patch` | Нормы, исходники, примеры, документация и генераторы |
| `generated.patch` | Производные PDF/XLSX/CSV, статистика и зеркала |
| `base-files.tar.gz` | Точные исходные содержимые всех изменённых или удалённых файлов |
| `merge.py` | Проверка, предварительное трёхстороннее слияние, применение с резервной копией |
| `build_fable_patch.py` | Общий воспроизводимый генератор diff между двумя spec-деревьями |
| `validate_packet.py`, `test_merge.py` | Применение только на временные копии и 8 проверок поведения инструмента |
| `rebuild_current_packet.py` | Проверка подлинного архива, подготовка базы, сборка и валидация в staging перед заменой пакета |
| `BASELINE_PROVENANCE.json`, `BUILD_PROVENANCE.json`, `VALIDATION.json` | Происхождение базы, точная конечная редакция и результаты доставки файлов |

## Проверка существующего проекта

Python 3.9+; Git нужен для трёхстороннего слияния. Из корня поставки:

```sh
python3 fable_merge/merge.py /path/to/docs/spec --check --merge --review /tmp/lmx-current-review --report /tmp/lmx-current-review.json
```

Без `--apply` целевая spec не меняется. `--review` пишет отдельные `.merge`-версии за пределами проекта. Выберите свободный путь review/report.

| Состояние | Что означает |
| --- | --- |
| `ready` | Локальное содержимое точно равно исходной базе |
| `alreadyApplied` | Файл уже совпадает с нынешней редакцией |
| `merged` | Локальные правки и нынешняя редакция объединены без текстового конфликта |
| `conflict` / `localChanges` | Нужно содержательное разрешение; весь автоматический apply заблокирован |
| `generatedSkipped` | Производный файл пропущен по умолчанию |

Если прежняя поставка 23-Nov уже применена, это обычное локальное состояние для трёхстороннего сравнения. Соседние правки могут объединиться, пересекающиеся потребуют решения. Чистый текстовый merge не является доказательством семантики. Не применяйте поверх результата старые patches: они относятся к прежней конечной редакции.

## Применение и производные файлы

```sh
python3 fable_merge/merge.py /path/to/docs/spec --apply --merge --report /tmp/lmx-current-applied.json
```

Инструмент повторно проверяет содержимое перед записью. Любой конфликт блокирует весь набор. Прежние файлы сохраняются в новой соседней `fable-backup-...` с `RESTORE.json`; существующий backup не перезаписывается. Для удаления и бинарной замены требуется точное совпадение базы. Изменение отдельного файла выполняется через временный файл и замену; резервная копия остаётся для восстановления. На время применения завершите параллельное редактирование затрагиваемых файлов.

Готовые артефакты включаются явно:

```sh
python3 fable_merge/merge.py /path/to/docs/spec --check --merge --include-generated --report /tmp/lmx-current-all-review.json
python3 fable_merge/merge.py /path/to/docs/spec --apply --merge --include-generated --report /tmp/lmx-current-all-applied.json
```

Если итог содержит ваши дополнительные правки к исходникам, статистику и документы нужно пересобрать по [общей проверке](../spec/patterns/VALIDATION.md), [пакету ядра](../spec/patterns/LMX_Fn_Receivers/README.md) и [SBCL-проверке](../spec/patterns/examples/SBCL_comparison/VALIDATION.md). Значения готовых таблиц относятся к исходникам этой поставки.

Для точной исходной базы доступны и обычные patches:

```sh
git apply --check /path/to/current-packet/fable_merge/source.patch /path/to/current-packet/fable_merge/generated.patch
git apply /path/to/current-packet/fable_merge/source.patch /path/to/current-packet/fable_merge/generated.patch
```

Эти команды выполняются из корня целевой spec. При самостоятельных изменениях предпочтителен `merge.py --merge`: базовые содержимые уже находятся в пакете; наличие исходного commit в вашем Git не требуется.

## Что требует исполнения ядра

[CORE_FUNCTIONS.md](../spec/CORE_FUNCTIONS.md) и профильные документы пакета ядра описывают общий public API и полные тела. [KERNEL_REQUIREMENTS.md](../spec/patterns/LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md) и [SBCL ТЗ](../spec/patterns/examples/SBCL_comparison/TZ_Standard_Lisp_and_Expression.md) отделяют готовые LMX-алгоритмы от реальных границ host/provider. `asOperand` настраивает существующий `OPERANDS_TEMPLATE`; отдельного Lisp parser или вида операнда нет.

Доставка файлов, source checks, формулы XLSX и реальные проверки SBCL не объявляются исполнением LMX. Семантические LMX-случаи без доступного runtime сохраняют статус `NOT_RUN`.

## Повторить проверку и сборку

После распаковки подлинного исходного архива в отдельную директорию:

```sh
python3 fable_merge/validate_packet.py --baseline /path/to/original/spec
```

Проверка применяет `merge.py` и оба git patches к двум временным копиям, сравнивает каждый байт с соседней новой `spec`, проверяет повторное применение без изменения файлов и запускает восемь изолированных тестов merge-инструмента. База и поставленная `spec` сравниваются до и после и не служат целями apply.

Для подготовки базы без сборки пакета:

```sh
python3 fable_merge/rebuild_current_packet.py --archive /path/to/original/spec.tar.gz --work /tmp/lmx-current-build
```

После завершения всех правок исходников и публикаций:

```sh
python3 fable_merge/rebuild_current_packet.py --archive /path/to/original/spec.tar.gz --work /tmp/lmx-current-build --updated spec --output fable_merge --build
```

Wrapper проверяет SHA-256 подлинного архива, использует существующий `build_fable_patch.py`, валидирует staged-копии обоими способами и повторно проверяет неизменность входов. Только затем он заменяет выходной пакет, сохраняя предыдущую директорию в work. При отсутствии `--build` действующие patches и `VALIDATION.json` не пересобираются.
