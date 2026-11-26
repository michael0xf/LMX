# Проверки и границы результатов

> **Граница ABI:** native-проверки прототипов ниже относятся к прежнему
> int-code представлению. Они не подтверждают прямую TypeRef и новый размер
> префикса. Требования миграции находятся в
> [TYPE_REFERENCES_CHANGE.md](../../TYPE_REFERENCES_CHANGE.md) и
> [README прототипов](../new_primitives/README.ru.md).

Первичные объекты проверок — [core/inventory.lmx](../core/inventory.lmx),
[schema.lmx](../catalog/schema.lmx), [package_plan.lmx](../package_plan.lmx),
[common_models.lmx](../types/common_models.lmx) и
[lowering_contract.lmx](../bridge/lowering_contract.lmx). Отчёты ниже имеют
явную область: актуальная опись, конкретный native профиль либо историческая
проверка прежнего снимка.

## Актуальная документационная опись

| Проверка | Что подтверждено | Свидетельство |
|---|---|---|
| Полнота источников | Все записи SOURCES, все объявленные public-header patterns, fingerprints исходников | [expanded_api_coverage.json](expanded_api_coverage.json) |
| Независимые API anchors | Известные семейства функций; отдельные SDL_DECLSPEC и ERFA scans; callbacks, inline, varargs и недоступные профили | [expanded_api_acceptance.json](expanded_api_acceptance.json) |
| Состав LMX-плана и моделей | Все текущие компоненты присутствуют ровно по одному разу, ссылки на модели/конвертеры разрешены, пути имеют 1–3 сегмента | [catalog_scope_check.json](catalog_scope_check.json) |
| Полный round-trip метаданных | Из первичных LMX-таблиц восстановлены все записи, все варианты C-деклараций, компонентные данные и header coverage | [catalog_summary.json](../catalog_summary.json), поле `metadata_roundtrip` |
| Статический LMX-текст | Отступы, cutters, границы форм и расположение `c.*`; без ошибок и неподдержанных форм | [lmx_static_sources.json](lmx_static_sources.json) |
| Сокращение закрытий | Избыточные `---`/`end:` удалены по обычному одноуровневому переходу, пустой строке или EOF; необходимые cutters и маркеры групп сохранены | [closer_normalization.json](closer_normalization.json), [редактор и правила](../../tools/NORMALIZE_LMX_CLOSERS.md) |
| Текст после сокращения | Повторная статическая проверка текущего каталога; это не запуск P0 и не исполнение LMX | [closers_lmx_static_sources.json](closers_lmx_static_sources.json) |
| Сравнение со снимком пользователя | Новые native компоненты отдельно от уже существовавших 23 пропусков каталога; прежние публичные callable IDs сохранены | [api_census_delta.json](api_census_delta.json) |
| Исправление callback parser | 47 неверных исторических identities сопоставлены 125 настоящим callback typedef names по полным исходным сигнатурам | [callback_identity_migration.json](callback_identity_migration.json) |
| Неоткрываемые native-ветки | Force-enable пяти unavailable/application/absent контрактов всё равно даёт `REVIEW_REQUIRED`; native providers не линкуются | [profile_gates.json](profile_gates.json), [код проверки](../bridge/run_profile_gate_tests.py) |
| Финальные входы и ссылки | SHA-256 конечного SOURCES и native evidence, совпадение входов nm, локальные ссылки и отсутствие Python caches | [final_catalog_checks.json](final_catalog_checks.json) |

Извлекатель не считает наличие объявления доказательством реализации.
Например, GL/EGL prototypes внутри SDL interoperability headers требуют
внешнего driver dispatch, `SDL_main` реализует host, APR skiplist исключён
из strict-C99 target, а optional SDL2 RWops/OGG ветви cute_sound не входят
в выбранный SDL3/WAV профиль. Такие контракты сохраняются в описи, но
генератор не добавляет для них включаемую native-ветку.

`tools/check_lmx_sources.py` не является P0-парсером и не выполняет
разрешение имён, полную типизацию либо запуск LMX. Round-trip доказывает
сохранность метаданных, а не корректность произвольного C ABI. Числа
`callable_candidates` и `direct_scalar_prototypes` обозначают классификацию
описи, а не число готовых защищённых функций ядра.

## Нативные сборки

Полная выбранная композиция из **180 компонентов** собрана в strict C99;
**138 из 138 CTest** прошли, включая пять native consumers `LMX::all`.
В **195 выбранных production-архивах** проверены **42 500 strong definitions**;
совпадений strong symbol names между архивами не обнаружено. Свидетельства:
[общая проверка сборки](../../c99_archive/VERIFICATION_2026-11-26.json) и
[аудит выбранных архивов](../../c99_archive/SYMBOL_AUDIT_2026-11-26.json).
Эти проверки относятся к нативной композиции и не запускают LMX runtime.

Точные версии, зависимости, C99-флаги, код проверок, измеренные архивы и
ограничения каждого нового профиля находятся рядом с интегратором:

| Расширение | Отчёт |
|---|---|
| gb, curated libc и cute | [bundles_extra/VERIFICATION.json](../../../third_party/lmx_c99_compact/extensions/bundles_extra/VERIFICATION.json) |
| APR, APR-Util и SDL3 | [platform_extra/VERIFICATION.json](../../../third_party/lmx_c99_compact/extensions/platform_extra/VERIFICATION.json) |
| NetSurf libraries | [netsurf_extra/VERIFICATION.json](../../../third_party/lmx_c99_compact/extensions/netsurf_extra/VERIFICATION.json) |
| HDF5 core + HL | [scientific_hdf5/VERIFICATION.json](../../../third_party/lmx_c99_compact/extensions/scientific_hdf5/VERIFICATION.json) |
| netCDF-C и libxml2 | [scientific_netcdf/VERIFICATION.json](../../../third_party/lmx_c99_compact/extensions/scientific_netcdf/VERIFICATION.json) |
| matio MAT7.3 | [knowledge_extra/MAT73_INTEGRATION.json](../../../third_party/lmx_c99_compact/extensions/knowledge_extra/MAT73_INTEGRATION.json) |
| PnetCDF | [scientific_pnetcdf/VERIFICATION.json](../../../third_party/lmx_c99_compact/extensions/scientific_pnetcdf/VERIFICATION.json) |

Детали профилей являются существенной частью результата. Наличие SDL video
API не доказывает испытание реального GPU/камеры; наличие MPI-IO не доказывает
многоранговый запуск. Область CDF-5 cross-read, число ranks и причина
неисполненных проверок указаны в научных отчётах. Исходный код тестов
сохраняется для повторения на другом оборудовании.

[expanded_archive_symbols.json](expanded_archive_symbols.json) — отдельное
наблюдение `nm` для указанного в нём набора native архивов. Совпадение имени
не устанавливает сигнатуру, владельца target или работоспособность backend.
Inline/static wrappers, platform guards и application hooks разбираются
отдельно. `whole_collection_link` в поисковой проекции содержит явную область
и ссылку на проверку configured consumers. `native_whole_archive_link: NOT_RUN`
обозначает, что единый образ через `--whole-archive` всех объектов не строился;
`lmx_runtime: NOT_RUN` сохраняет отдельный статус портирования в язык.

## Исторические результаты, сохранённые из загруженного снимка

Следующие файлы сохраняют свою исходную область. Они не выдаются за новую
сборку всей расширенной коллекции:

| Исходный результат | Область |
|---|---|
| [full_build.json](full_build.json) | 132 компонента и пять конкретных `LMX::all` consumers прежнего этапа |
| [bridge_tests.json](bridge_tests.json), [sanitized](bridge_tests_sanitized.json) | 101 проверка C reference-границы; обычная сборка и ASan/UBSan |
| [generated_shim_tests.json](generated_shim_tests.json), [sanitized](generated_shim_tests_sanitized.json), [final artifact](generated_shim_final_artifact.json) | Три default-отказа и 67 проверок включённого zlib compress2 adapter |
| [new_primitives/VERIFICATION.json](../new_primitives/VERIFICATION.json) | Числовой C reference: владение, rollback, precision, narrowing, квота памяти |
| [additions/summary.json](../additions/summary.json) | Измерения первых 20 добавленных библиотек |
| `baseline_*`, `expanded_api_validation.json`, `generated_lmx_static.json`, `all_lmx_static.json`, `delivery_checks.json`, `census_*_refresh.json` | Прежние проверки соответствующих исторических входов; актуальные результаты перечислены выше |

LeakSanitizer в исторических ASan/UBSan запусках был недоступен под ptrace
и указан как `NOT_RUN`. Это не означает отказ AddressSanitizer или
UndefinedBehaviorSanitizer, которые в тех запусках действительно работали.
Пути команд в новых компактных отчётах нормализованы; transient build trees
и длинные логи не включаются в overlay.

**Не заявлены выполненными:** интеграция всего каталога в актуальный LMX
runtime, Windows/QNX cross-builds, испытания на процессорах 100–200 МГц,
полный набор всех upstream suites и единый executable через
`--whole-archive` всех объектов. Фактически выполненные проверки описаны
своими отчётами и не распространяются автоматически на другие профили.
