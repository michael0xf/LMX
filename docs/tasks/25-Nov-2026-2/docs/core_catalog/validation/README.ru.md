# Проверки и границы результатов

Объекты проверок заданы первичными
[core/inventory.lmx](../core/inventory.lmx), [schema.lmx](../catalog/schema.lmx),
[lowering_contract.lmx](../bridge/lowering_contract.lmx) и
[profiles.lmx](../new_primitives/profiles.lmx).

| Проверка | Результат | Свидетельство |
|---|---|---|
| Все 132 компонента C-коллекции | Configure + build PASS, повторная конфигурация PASS | [full_build.json](full_build.json) |
| Пять потребителей общего `LMX::all` | 5/5 PASS | [full_build.json](full_build.json) |
| Числовые добавления | 3/3 CTest PASS, все 10 архивов меньше 1 000 000 B в измеренном профиле | [numeric_extra/VERIFICATION.json](../../../third_party/lmx_c99_compact/extensions/numeric_extra/VERIFICATION.json) |
| Текст, геометрия, терминал, xxHash | 9 проверок PASS | [non_numeric_build.json](../additions/non_numeric_build.json) |
| DNS, события, mDNS | C99 offline test PASS, header-only пример компилируется | [network_build.json](network_build.json) |
| Reference C-граница | 101 проверка, обычная сборка и ASan/UBSan PASS | [bridge_tests.json](bridge_tests.json), [sanitized](bridge_tests_sanitized.json) |
| Сгенерированные C-shim | Три default-отказа; включённый compress2, 67 проверок, ASan/UBSan PASS | [generated_shim_tests.json](generated_shim_tests.json), [sanitized](generated_shim_tests_sanitized.json), [финальные исходники](generated_shim_final_artifact.json) |
| Reference новых примитивов | ASan/UBSan PASS; владение, rollback, precision, exact narrowing, квота памяти | [new_primitives/VERIFICATION.json](../new_primitives/VERIFICATION.json) |
| Исходная/расширенная опись | Независимые acceptance checks, дедупликация, сохранение всех прежних идентичностей | [expanded_api_coverage.json](expanded_api_coverage.json), [api_census_delta.json](api_census_delta.json) |
| Символы в построенных `.a` | Измеренные совпадения имён и отдельные inline/profile категории | [expanded_archive_symbols.json](expanded_archive_symbols.json) |

Файл `tools/check_lmx_sources.py` проверяет только описанный набор свойств
исходного текста: отступы, cutters, закрытие на пустой строке и расположение
`c.*`. Он не заменяет P0, разрешение ссылок, полную типизацию и исполнение.
Round-trip каталога проверяет восстановление всей метаинформации, а не
корректность произвольной C-сигнатуры на любом ABI.

Восстановленные поля `build_input_status`/`source_validation` внутри
компонентных записей отражают область исходного census: сам извлекатель
не выполняет линковку. Итоговую отдельную проверку сборки описывает
`full_build.json`. `whole_collection_link: NOT_RUN` в поисковой проекции
не означает, что пять проверочных consumers не запускались: не проверялся
единый образ со всеми API/объектами коллекции.

LeakSanitizer в этой среде недоступен под ptrace и отмечен `NOT_RUN`;
AddressSanitizer и UndefinedBehaviorSanitizer реально запускались.
Нормализованные пути команд в отчётах обозначают корень проекта, коллекцию
и временный build directory. Полные build logs в патч не входят.

**Не выполнялись:** интеграция в актуальный LMX runtime, Windows/QNX
cross-builds, испытания на малых процессорах, полный набор upstream
regression suites и сборка единого executable со всеми объектами через
`--whole-archive`. Выбранные consumers действительно связаны и выполнены;
это проверка конкретного совместного использования, не доказательство
любой возможной комбинации API.
