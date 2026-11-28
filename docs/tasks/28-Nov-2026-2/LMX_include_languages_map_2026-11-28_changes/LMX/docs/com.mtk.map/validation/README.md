# Проверки com.mtk.map и P0–MIX

Эти результаты относятся к редакции 28 ноября 2026. Разные виды проверки
учитываются отдельно: успешный Java/C/host запуск не является запуском LMX.

| Материал | Что проверено | Статус |
| --- | --- | --- |
| [original_java_probe.json](original_java_probe.json) | Компиляция исходного core Java и 15 проверок структуры, Cursor, bunch и двух writers. | Реальный `PASS`. |
| [java_original_manifest.json](java_original_manifest.json) | 67 исходных файлов сохранены рядом с черновиком без изменения байтов. | Проверено SHA-256. |
| [java_method_inventory.json](java_method_inventory.json) | 1323 Java AST объявления, включая constructor/interface/nested/anonymous. | Получены через JDK parser. |
| [coverage_summary.json](coverage_summary.json) | 591 storage + 732 upper declarations, без пропусков и пересечений. | `EXACT_AST_COVERAGE_PASS`. |
| [coverage_storage.json](coverage_storage.json), [coverage_tags.json](coverage_tags.json) | Сопоставление исходных методов с общими LMX телами, исходными TODO и внешними зависимостями. | Полнота отображения; execution не утверждается. |
| [static_report.json](static_report.json) | Состав LMX, определённые имена/первые шаги путей, ограниченные delimiter/indentation checks, ссылки и Java hashes. | `STATIC_CHECKS_PASS`. |
| [p0_host_report.json](p0_host_report.json) | 10 220 комбинаций двух edits, 4096 наборов checkpoint, 6 исходных coordinate fixtures. | `HOST_ORACLE_PASS`. |
| [storage_cases.json](storage_cases.json), [tag_cases.json](tag_cases.json), [p0_cases.json](p0_cases.json) | Ожидания обычных LMX вызовов и интеграционных сценариев. | `NOT_RUN_PRODUCTION_LMX`. |

Из 1323 сопоставлений 1307 используют конкретные общие LMX операции,
8 отмечены `IMPLEMENTED_DRAFT`, 4 — `SOURCE_TODO`, 4 —
`EXTERNAL_DEPENDENCY`. Это не процент прошедших runtime-тестов.

## Повторить локальные проверки

Из корня `LMX/`:

```sh
python docs/com.mtk.map/validation/static_check.py
python docs/com.mtk.map/validation/check_coverage.py
python docs/com.mtk.map/validation/p0_host_oracle.py
```

Скрипты перезаписывают только собственные JSON-отчёты. Первый не реализует
грамматику P0 и не проверяет TYPE/effect admission. Второй сравнивает точные
source/class/method/line ключи. Третий исполняет Python host oracle;
его Unicode-проверки читают уже существующие parser fixtures.

[MapJavaInventory.java](MapJavaInventory.java) — исходник извлечения AST.
Он вызывает `JavacTask.parse()` без подстановки отсутствующих внешних
библиотек и сохраняет объявления с исходными диапазонами. В нормализованном
inventory пути указывают `java_original/`, а тела представлены хешами;
полные тела находятся в сохранённом Java.

[OriginalMapProbe.java](OriginalMapProbe.java) компилируется вместе с
исходным `java_original/com/mtk/map` и его `i/`; `mtk/map` adapters с
отсутствующими зависимостями не входят в запуск. Фактические compiler/run
arguments и результаты сохранены в receipt; абсолютные пути в нём относятся
к проведённому запуску.

## Что нужно исполнять на полном ядре

Новые `.lmx` должны пройти production P0, общий translator/TYPE и затем
интерпретатор/native runtime. Сценарии вызываются обычным способом из уже
запущенного R0/Thread; имя case не заменяет entry. Новые P0 hooks требуют
подключения к существующему parser/builder.

В LMX-коде используются Message и явные состояния протокола. `synchronized`
принадлежит низкому уровню L2. Проверки сообщений должны подтверждать
правильные ответы, correlation/generation, сохранение событий, отсутствие
повторного эффекта и корректное завершение; они не являются поиском
«deadlock Message».
