# SQLite catalogue fixtures

Эти файлы проверяют SQL projection, не исполняют LMX compiler/runtime. Целевой контракт описан в [CATALOGUE_SQLITE.ru.md](../../docs/CATALOGUE_SQLITE.ru.md).

## Запуск

Требуется Python с SQLite >=3.37.0. Из этого каталога:

```sh
python verify.py
```

Harness создаёт заново только `sample.sqlite3` в этом fixture каталоге, загружает [DDL](../../schema/catalogue.sql) и [sample publication](sample_publication.sql), исполняет cases и записывает [receipt](validation_receipt.json) и [query results](query_results.json). Это host verification script, не реализация сервера на Python.

Те же `.sql` файлы исполняются SQLite CLI/любым SQLite host, если доступны; значения `:name`, `:changed_key` и другие параметры передаются binding API. В данном окружении использован Python sqlite3 binding с реальным SQLite engine, не отдельный sqlite3 CLI.

## Stable query names

| Name | SQL file | Bind parameters |
|---|---|---|
| validate | [00_validate.sql](queries/00_validate.sql) | — |
| publication | [01_publication.sql](queries/01_publication.sql) | — |
| name | [02_name.sql](queries/02_name.sql) | name |
| type | [03_type.sql](queries/03_type.sql) | type_name |
| callers | [04_callers.sql](queries/04_callers.sql) | callee_key |
| callees | [05_callees.sql](queries/05_callees.sql) | caller_key |
| impact | [06_impact.sql](queries/06_impact.sql) | changed_key |
| native_exports | [07_native_exports.sql](queries/07_native_exports.sql) | — |
| related_tests | [08_related_tests.sql](queries/08_related_tests.sql) | changed_key |
| documentation | [09_documentation.sql](queries/09_documentation.sql) | term |
| ordered_fields | [10_ordered_fields.sql](queries/10_ordered_fields.sql) | owner_key |
| signatures | [11_signatures.sql](queries/11_signatures.sql) | callable_key |
| unresolved | [12_unresolved.sql](queries/12_unresolved.sql) | — |
| graph_cycle | [13_graph_cycle.sql](queries/13_graph_cycle.sql) | start_key |
| admit_key | [14_admit_key.sql](queries/14_admit_key.sql) | expected_snapshot, node_key |

`validate` — publication gate; ненулевой результат означает rollback. `admit_key` проверяется в той же read transaction, что и последующий lookup. SQL не вызывает LMX receivers, не компилирует и не изменяет native bindings.

## Содержимое sample

76 synthetic facts представляют конечный graph fixture с повторяющимися именами полей, несколькими вхождениями одной цели, физическим null slot, отдельным realparent, self-cycle и циклом статических вызовов. Основой назван compile-input. Один call target динамически неизвестен. Test association существует, но test status — not-run. Native binding — not-linked. Полный kernel toLmx capture недоступен; coverage runtime-lmx=unavailable.

Фрагменты `int: accumulator 0`, `int: value 3`, `int: value 5`, `int: initial 0` — reference LMX payload strings. Они не заменяют полный вывод универсального codec и не являются receipt его исполнения.

Прикладные ключи `n:total`, `n:reduce` и другие существуют только внутри sample publication. Их нельзя передавать обычным runtime commands как адреса объектов.

## Checks

[query_cases.json](query_cases.json) задаёт 21 проверку с ожидаемыми результатами. Дополнительно harness проверяет 10 ошибок: повтор field ordinal, второй realparent, неверный SQL-тип ordinal, несуществующий evidence label, известную цель под dynamic-unresolved, неверный basis, NULL coverage, null slot без discriminator, dangling target и ложный complete toLmx без payload.

Отдельный reader видит old-before-commit/new-after-commit; неудачный candidate откатывается. Эти результаты касаются SQLite, не atomicity всего runtime/native. Optional [FTS5 script](optional_fts5.sql) проверяется в отдельной in-memory DB и не добавляет таблицы в baseline sample.

## Артефакты

- [sample.sqlite3](sample.sqlite3) — готовая demonstration DB с одной таблицей.
- [validation_receipt.json](validation_receipt.json) — actual host receipt.
- [query_results.json](query_results.json) — complete returned rows.

Runtime compilation, kernel toLmx и endturn integration: **NOT_RUN**.
