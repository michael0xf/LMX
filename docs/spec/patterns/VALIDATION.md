# Проверка документации и публикаций — 26 ноября 2026

Текущая модель: [PUBLICATION_DATA.json](PUBLICATION_DATA.json), SHA-256 `f8455be2a482e95311435e231a815bd84bcc2133c837a644fa4075ae971b6627`. Статус исходников и публикаций: **PASS**; статус текущих изменённых/новых материалов переданной ревизии: **PASS**. PASS относится к указанной текущей области и перечисленным проверкам, а не ко всем историческим записям дерева. Production LMX parser, translator, runtime и интеграция PD01 имеют **NOT_RUN**.

## Текущие проверки

| Область | Статус | Что проверено | Отчёт |
| --- | --- | --- | --- |
| Общий текущий пакет | PASS | Текущие изменённые/новые материалы; 54 исходника и 108 мест, связанные evidence receipts | [JSON](validation/current_revision_checks_20261126.json) |
| Группы сравнений | PASS | 11 групп, 108 сравнений, 337 полных листингов | [JSON](validation/recount_report.json) |
| Ядро | PASS | 215 имён, 52 частей, 20 интеграционных границ; ограниченная статическая проверка | [JSON](LMX_Fn_Receivers/tests/STATIC_REPORT.json) |
| Depth ABI | PASS | 261 проверок исходников и метаданных; PD01 production NOT_RUN | [JSON](LMX_Fn_Receivers/tests/operand_depth_source_20261126.json) |
| Haskell | PASS | 24 модулей, 32 LMX-файла; исходники, исполнение NOT_RUN | [JSON](examples/haskell_comparision/validation/check_receipt.json) |
| Julia | PASS | 175 проверок, 113 случаев Python oracle; Julia и LMX NOT_RUN | [JSON](examples/julia_comparison/validation/check_report.json) |
| Perl | PASS | 31 сравнений: исходники, JSON, Markdown и размеры; текущий runtime NOT_RUN | [JSON](examples/perl_comparison/validation/final_consistency.json) |
| SBCL | PASS | 468 проверок исходников и размеров; SBCL и LMX NOT_RUN | [JSON](examples/SBCL_comparison/validation/workflow_source_checks.json) |
| PDF/XLSX | PASS | 21/21 PDF и 21/21 XLSX; 1909 числовых размеров, формулы, минимумы и равенства | [JSON](validation/publication_checks.json) |
| Визуальная проверка | PASS | Выборочно просмотрены 6 PDF-страниц и 8 полных листов; прочая проверка отдельно обозначена в отчёте | [JSON](validation/visual_review_20261126.json) |

## Граница текущей ревизии и исторические записи

Общий обход дерева документации сохраняет статус **FAIL**: в нём остаются **11** прежних наблюдений в исторических файлах, побайтно совпадающих с базовым архивом. Новых замечаний в текущем отчёте: **0**. Их точные пути, SHA-256 и область проверки сохранены в [отчёте ревизии](validation/current_revision_checks_20261126.json). Исторические записи не переписаны для получения общего PASS; PASS текущей ревизии не отменяет результат обхода всего дерева.

Формы `[](N)T`, `@(N)T` имеют область **DOC_SPEC_ADDITION_ONLY** и production acceptance **NOT_RUN**. Описание синтаксиса не выдаётся за выполненную проверку его production-парсером.

## Комплектность и измерения

Модель содержит **112** клиентских договоров и **224** измерений двух LMX-форм. В 4 языковых наборах examples находятся **99** сценариев и **198** стилевых листингов; **83** сценария образуют полные пары. Отдельно учтены **24** сравнений общих реализаций. Это разные области подсчёта; они не складываются в число различных программ.

Публикация состоит из **20** основных документов и **1** зеркала: всего **21 PDF** и **21 XLSX**. В этой ревизии пересозданы 9 PDF и 9 XLSX. Неизменённые файлы сохраняют исходную дату генерации в текущих receipts; их история не переписана.

Полный размер включает все объявления, код в указанной границе, комментарии, Throws и ссылки copy. Обе формы LMX участвуют самостоятельно. Минимум сопоставимой строки подчёркнут зелёным; при равенстве отмечены все победители. Аналогии не становятся нулевым контрольным листингом и не входят в сумму полных пар. Размер исходника не измеряет скорость или память.

## Публикации и визуальная область

[PDF receipt](validation/pdf_generation_20261126.json) и [XLSX receipt](validation/workbook_publication_20261126.json) содержат хеши готовых файлов и их действительную edition. [Проверка](validation/publication_checks.json) читает сериализованные XLSX и PDF: значения, формулы и кэш сумм, правила условного форматирования, реальные зелёные числа и подчёркивания. Artifact-tool пересчитывал формулы; запуск Microsoft Excel не заявляется.

[Визуальный отчёт](validation/visual_review_20261126.json) перечисляет конкретные просмотренные страницы и листы с хешами файлов и рендеров. Выборочная визуальная проверка не названа просмотром всех страниц. Проверки остальных страниц и их границ указаны отдельно.

## Исполнение и предыдущие receipts

Этот генератор только читает доказательства и обновляет сводку. Он не запускает LMX, Julia, Haskell, SBCL, Perl или сторонние компиляторы. Текущий Julia-отчёт проверяет исходники и Python oracle; это не исполнение Julia. Проверка формы или размера кода не подтверждает связывание, типизацию, parent-связи, время жизни или нативный ABI.

Следующие прежние receipts сохранены отдельно. Записанный в них PASS не переносится на изменённый LMX-код или новые случаи исполнения:

- [examples/perl_comparison/validation/client_tests.json](examples/perl_comparison/validation/client_tests.json) — записанный статус `PASS`; прежняя область отчёта.
- [examples/SBCL_comparison/validation/common_lisp.json](examples/SBCL_comparison/validation/common_lisp.json) — записанный статус `NOT_RUN`; прежняя область отчёта.
- [examples/SBCL_comparison/validation/implementation_execution.json](examples/SBCL_comparison/validation/implementation_execution.json) — записанный статус `PASS`; прежняя область отчёта.
- [10_algorithms/tests/validation.json](10_algorithms/tests/validation.json) — записанный статус `PASS`; прежняя область отчёта.
- [11_state_and_simulation_patterns/tests/validation_results.json](11_state_and_simulation_patterns/tests/validation_results.json) — записанный статус `PARTIAL`; прежняя область отчёта.

## Воспроизведение текущей сводки

После синхронизации исходников и метаданных обновляют статистику и PUBLICATION_DATA. Экспорт выполняют только для реально затронутых сравнительных документов; затем отдельно проверяют готовые файлы и их рендеры. Эта команда не повторяет экспорт или широкие тесты:

```sh
python -B tools/refresh_validation_report.py --revision-checks validation/current_revision_checks_20261126.json
```

Команда запускается из spec/patterns. Путь --revision-checks может указывать на другой текущий отчёт. Без существующего текущего отчёта поле source_packet остаётся NOT_RUN и общий статус PARTIAL. Записываются только [VALIDATION.md](VALIDATION.md) и [validation_overview_20261126.json](validation/validation_overview_20261126.json); исторические receipts не изменяются. `--check` сравнивает эти два результата без записи.
