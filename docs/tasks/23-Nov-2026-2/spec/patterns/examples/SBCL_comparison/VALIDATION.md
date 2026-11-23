# Проверка SBCL_comparison

## Что выполнено

| Объект | Результат | Свидетельство |
| --- | --- | --- |
| 24 клиентских сценария Common Lisp | 88 из 88 проверок, ошибок 0 | [common_lisp.json](validation/common_lisp.json), [журнал](validation/common_lisp.log) |
| 6 самостоятельных reference-реализаций | 107 проверок | [implementation_execution.json](validation/implementation_execution.json), [журнал](validation/implementation_test.log) |
| Внешние symbols пакета COMMON-LISP | 978 фактически перечисленных имён; все классифицированы | [экспорт](validation/common_lisp_symbols.json), [классификация](COMMON_LISP_COVERAGE.json) |
| Источники, публикации, числа и ссылки | Воспроизводимая проверка согласованности | [source_checks.json](validation/source_checks.json) |
| XLSX | Формулы итогов, изменение входа и возврат исходного значения; динамическая подсветка минимумов | [workbook_checks.json](validation/workbook_checks.json) |
| PDF/XLSX | Экспорт и визуальная проверка всех страниц и заполненных областей | [artifact_validation.json](validation/artifact_validation.json) |
| LMX | **NOT_RUN** | [сценарии приёмки клиентов](validation/lmx_acceptance_cases.json), [42 сценария новых функций](../../LMX_Fn_Receivers/tests/core_standard_lisp_cases.json) |

Фактический runtime Lisp — **SBCL 2.2.9.debian**. Клиентский стенд использует стандартные функции Common Lisp и реальные `sb-thread`/`sb-concurrency` для S24. Самостоятельные reference-реализации тестируются отдельным стендом и не подменяют стандартную библиотеку в клиентах. Экспорт 978 symbols — проверка полноты инвентаря, а не 978 поведенческих тестов совместимости.

На стороне LMX подготовлены полные листинги, договоры, общие реализации, зависимости и ожидаемые результаты. Интегрированный LMX executor в этой работе недоступен; семантические ожидания не называются пройденным runtime. S24 дополнительно требует конкретный Message host/parser fixture, поэтому не включён в итог 23 полных пар и не подсвечивается победителем.

## Воспроизведение источников и Lisp

Команды выполняются из `spec/patterns/examples/SBCL_comparison`. Python 3 нужен для сборки каталогов и проверки хешей; SBCL — для исполнения Lisp.

```sh
python3 tools/rebuild_implementations.py
python3 tools/rebuild.py
python3 tools/build_expression_review.py
python3 tools/build_cl_coverage.py
python3 tools/run_common_lisp.py --sbcl /path/to/sbcl
python3 tools/run_implementation_tests.py --sbcl /path/to/sbcl
```

Если `sbcl.core` лежит отдельно, оба runner принимают `--sbcl-home /path/to/sbcl/runtime`. Они запускают настоящий SBCL, сохраняют вывод и SHA-256 входных файлов. При отсутствии программы статус будет `NOT_RUN`; Python-имитация вычислений не используется.

Инвентарь можно снова получить командой `sbcl --script tools/export_common_lisp_symbols.lisp > validation/common_lisp_symbols.json`, после чего повторить `build_cl_coverage.py`. Экспорт читает имена и свойства symbols и не вызывает перечисленные функции.

Генераторы читают единую реализацию дополнительной метрики [patterns/tools/throws_metrics.py](../../tools/throws_metrics.py). Объявление сохраняет заголовок и первый записанный синтаксический аргумент. `copy(Throws)` и ссылки остаются целиком; определения банков считаются в своей границе исходника или уникального замыкания. Отдельный архив этой директории ожидает соответствующую внешнюю `spec`; вторая копия алгоритма счёта в него не добавлена.

## PDF и XLSX

```sh
python3 tools/build_pdf.py
node tools/build_workbook.mjs
python3 tools/validate.py
python3 tools/refresh_manifest.py
python3 tools/verify_manifest.py --spec-root ../../..
```

PDF использует ReportLab и DejaVu Sans/Mono. XLSX использует `@oai/artifact-tool`; пакет должен разрешаться стандартным Node import. Генератор принимает необязательные аргументы `node tools/build_workbook.mjs /path/to/SBCL_comparison /path/to/output` и сохраняет XLSX в каталог сравнения, а изображения проверки — в выбранный output.

Подсветка сравнивает три числовые колонки полных сопоставимых строк: LMX, LMX без сложного Throws и Common Lisp. При равенстве двух LMX значений участвует только полное; если уменьшенное LMX значение меньше, выбирается оно. Межъязыковые равенства сохраняются. В XLSX это настоящие правила `MIN`/`AND`; вычисленные итоги используют `SUMIFS` и `SUM`, а отношение — полные размеры. В PDF применены те же условия выбора ячеек. Полное замыкание зависимостей и несопоставимые справочные величины не объявляются отдельными победителями.

Визуальная проверка проводится после финального рендера: все PDF-страницы и четыре заполненные области XLSX. Контрольный JSON указывает SHA-256 проверенных файлов. Его нельзя автоматически считать свежим после нового экспорта; обновление документа требует новой проверки затронутого оформления.

## Границы проверки и обновления

`validate.py` проверяет, что исходники совпадают с каталогом и полными листингами Markdown, метрики пересчитываются точно, все 24 ID и 6 реализаций сохранены, альтернативы не являются копиями, а успешные Lisp receipts относятся к нынешним файлам. Его `PASS` не является запуском LMX.

`refresh_manifest.py` фиксирует локальные файлы и прочитанные внешние определения. `verify_manifest.py` ничего не изменяет. При новой редакции общей `spec` нужно сопоставить исходники, затем обновить извлечённые реализации, аудит Expression, метрики и публикации. При изменении Common Lisp-кода требуется повторное фактическое исполнение соответствующего стенда. Изменение документации или LMX само по себе не требует повторять неизменённый Lisp-код.

Остающиеся требования к интеграции перечислены в [ТЗ стандартных возможностей](TZ_Standard_Lisp_and_Expression.md) и [ТЗ Message fixture](TZ_Message_Fixture_Fable.md), с путями относительно `spec`.
