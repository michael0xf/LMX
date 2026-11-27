# Что проверено в этом пакете

Дата: 27 ноября 2026 года. Проверки относятся к конкретному архиву с документацией и LMX-заготовками. Они не объявляют готовыми отсутствующие runtime/provider интеграции.

## Выполнено

| Проверка | Фактический результат | Свидетельство |
| --- | --- | --- |
| Новые LMX sources/examples | 13 файлов; 0 ошибок ограниченного checker; 0 unsupported forms; 0 C tokens | [lmx_static.json](../validation/lmx_static.json) |
| Независимая сверка LMX | Проверены callable/DATA/parent, node/private paths, finite exits, owner writes, callback lifetime и поздние outcomes; найденные проблемы исправлены | [Аудит](audit/RUNTIME_SOURCE_AUDIT.ru.md), [syntax basis](audit/LMX_SOURCE_REVIEW.ru.md) |
| JSON/SSE fixtures MCP | 18 JSON-файлов разбираются, manifest перечисляет 18 reference файлов; 2 SSE data messages — корректный JSON | [mcp_static.json](../validation/mcp_static.json) |
| SQLite schema/sample | Одна main table, 76 synthetic facts, integrity_check=ok | [SQL receipt](../fixtures/catalogue/validation_receipt.json) |
| SQL queries | 21 query case PASS | [Результаты](../fixtures/catalogue/query_results.json) |
| SQL negative cases | 10 неверных случаев отклонены constraints либо publication gate | [SQL receipt](../fixtures/catalogue/validation_receipt.json) |
| SQL publication | Rollback сохраняет прежний snapshot; отдельный reader видит старый до COMMIT и новый после | [SQL receipt](../fixtures/catalogue/validation_receipt.json) |
| Каталожный key | Old publication token отклоняется после замены; null slot не исчезает | [Queries/gates](../fixtures/catalogue/README.md) |
| Optional FTS5 | Русскоязычный поиск PASS на отдельной host-БД | [SQL receipt](../fixtures/catalogue/validation_receipt.json) |
| Пакет и документация | Относительные новые ссылки, якоря, fenced blocks, hash manifest, unified diff и состав delta проверяются при упаковке | [package_checks.json](../validation/package_checks.json) |

SQL действительно исполнялся на **SQLite 3.53.1**, через Python host sqlite3 binding. Это проверка схемы, запросов и транзакционных свойств данной БД. Она не является выполнением LMX SQLite binding или compiler publication hook. Факты sample synthetic; kernel_toLmx_capture=NOT_RUN.

## Значение статического LMX-результата

Использован существующий `docs/core_catalog/tools/check_lmx_sources.py` из исходных документов. Он проверяет ограниченный source subset: shielding строк/комментариев, парные разделители, layout/cutters, blank root boundaries и размещение c.*.

Это **не P0, не type checker, не compiler и не interpreter**. Результат 0 ошибок не доказывает namespace binding, admission, overload selection, foreign ABI, effects или выполнение. Поэтому статус обозначен `STATIC_SOURCE_CHECKS_NOT_P0_NOT_RUNTIME`.

Ручная/независимая сверка дополняет bounded check: исходные примеры и нормативные contracts были сопоставлены с созданным кодом. Она тоже не превращается в runtime PASS.

## Что не запускалось

- Production P0/namespace/type/admission и исполнение новых LMX bodies на предоставленном ядре.
- Полный kernel fromLmx/toLmx roundtrip любой Structure/L3Thread.
- Compile→facts→endturn→SQLite integration.
- Модельный HTTP provider, native listener/TLS и реальные transport faults.
- MCP end-to-end/conformance current либо legacy с работающим LMX-сервером.
- Hot swap на живых native frames, реальные timeout/late mail и graph lifetime stress.

Эти пункты — конкретные задачи [плана](IMPLEMENTATION_PLAN.ru.md). В пакет не вставлены mocks, которые сделали бы такой запуск внешне успешным.

## Повторение host-проверки SQL

Из `docs/runtime_server`:

```sh
python3 fixtures/catalogue/verify.py
```

Скрипт создаёт/обновляет только демонстрационные fixture-артефакты этого каталога. Он не подключается к пользовательскому runtime или рабочей БД. Условия, включая версию SQLite и optional FTS5, перечислены в [fixture README](../fixtures/catalogue/README.md).

Ограниченную проверку LMX можно повторить из корня уже дополненной документации:

```sh
python3 docs/core_catalog/tools/check_lmx_sources.py docs/runtime_server/src docs/runtime_server/examples --report /tmp/lmx-server-static.json
```

Общий checker не включён в delta повторно: он принадлежит неизменённой исходной документации.
