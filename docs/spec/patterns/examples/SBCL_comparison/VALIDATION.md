# Проверка SBCL_comparison

## Что выполнено

| Объект | Результат | Свидетельство |
| --- | --- | --- |
| 24 клиентских сценария Common Lisp | 88 из 88 проверок, ошибок 0 | [common_lisp.json](validation/common_lisp.json), [журнал](validation/common_lisp.log) |
| 6 самостоятельных reference-реализаций | 107 проверок | [implementation_execution.json](validation/implementation_execution.json), [журнал](validation/implementation_test.log) |
| Внешние symbols пакета COMMON-LISP | 978 фактически перечисленных имён; все классифицированы | [экспорт](validation/common_lisp_symbols.json), [классификация](COMMON_LISP_COVERAGE.json) |
| Источники, публикации, числа и ссылки | Воспроизводимая проверка согласованности | [source_checks.json](validation/source_checks.json) |
| XLSX | Генерация из общей модели; полные размеры и формульные итоги | [workbook_publication_20261123.json](../../validation/workbook_publication_20261123.json) |
| PDF | Генерация из той же модели; таблицы и ожидаемые минимумы | [pdf_generation_20261123.json](../../validation/pdf_generation_20261123.json) |
| PDF/XLSX | Независимая проверка реальных файлов: значения, сохранённые результаты формул, все равные минимумы, цвет и подчёркивания | [publication_checks.json](../../validation/publication_checks.json) |
| Оформление публикаций | Контроль границ и визуальная проверка итогового рендера | [artifact_review_20261123.json](../../validation/artifact_review_20261123.json) |
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

Оба LMX-стиля проверяются общим `lmx_style_variants.py`: полный исходник, один общий файл для same_minimal_form или два для distinct, совпадающий contract_id, все метрики и честный NOT_RUN. Полные Throws и copy-ссылки остаются в счёте; дополнительная метрика с удалением аргументов больше не вычисляется.

## PDF и XLSX

```sh
python3 tools/build_pdf.py
node tools/build_workbook.mjs
python3 ../../tools/verify_publication.py
python3 tools/validate.py
python3 tools/refresh_manifest.py
python3 tools/verify_manifest.py --spec-root ../../..
```
Оба локальных генератора вызывают общую публикацию из [PUBLICATION_DATA.json](../../PUBLICATION_DATA.json). PDF использует ReportLab и DejaVu Sans/Mono. XLSX использует `@oai/artifact-tool`; Node запускается из установленного runtime с доступным пакетом. Генератор принимает необязательные аргументы `node tools/build_workbook.mjs /path/to/SBCL_comparison /path/to/output` и сохраняет XLSX в каталог сравнения; при выбранном output туда также попадает копия файла. Общий verifier проверяет весь набор публикаций, поэтому для полного PASS остальные файлы и общие generation receipts также должны соответствовать текущей модели.

Подсветка сравнивает три полных размера сопоставимой строки: LMX процедурный, LMX функциональный и Common Lisp. Все равные минимумы сохраняются. Оба отношения вычисляются по соответствующим полным LMX-размерам; S24 и справочные замыкания зависимостей не объявляются победителями.

Оформление проверяется после финального рендера; текущая запись визуального контроля находится в [artifact_review_20261123.json](../../validation/artifact_review_20261123.json). Независимый [publication_checks.json](../../validation/publication_checks.json) связывает проверку с SHA-256 общей модели, generation receipts и фактических PDF/XLSX. После нового экспорта эти свидетельства должны быть обновлены. Проверка XML и сохранённых результатов формул не является исполнением нативного Excel; его статус остаётся **NOT_RUN**.

В XLSX минимумы задаются обычными правилами условного форматирования: зелёный шрифт и нижняя линия. В PDF те же значения напечатаны зелёным и подчёркнуты. Проверяются все равные минимумы; неполный S24 не получает победителя.

## Границы проверки и обновления

`validate.py` проверяет, что исходники совпадают с каталогом и полными листингами Markdown, метрики пересчитываются точно, все 24 ID, 48 LMX-вариантов в 41 исходнике и 6 общих реализаций сохранены, same_minimal_form обоснован, дополнительные альтернативы не являются копиями, а успешные Lisp receipts относятся к нынешним файлам. Без `--skip-artifacts` он также требует актуальный общий publication PASS и независимо проверяет собственные PDF/XLSX. Опция `--skip-artifacts` выполняет только проверку исходников и метаданных. Его `PASS` не является запуском LMX или нативного Excel.

`refresh_manifest.py` фиксирует локальные файлы и прочитанные внешние определения. `verify_manifest.py` ничего не изменяет. При новой редакции общей `spec` нужно сопоставить исходники, затем обновить извлечённые реализации, аудит Expression, метрики и публикации. При изменении Common Lisp-кода требуется повторное фактическое исполнение соответствующего стенда. Изменение документации или LMX само по себе не требует повторять неизменённый Lisp-код.

Остающиеся требования к интеграции перечислены в [Спецификация стандартных возможностей](STANDARD_LISP_AND_EXPRESSION.md) и [Контракт Message fixture](MESSAGE_FIXTURE.md), с путями относительно `spec`.
