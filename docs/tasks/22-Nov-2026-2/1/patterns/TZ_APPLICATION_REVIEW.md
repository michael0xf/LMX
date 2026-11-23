# Применение текущих ТЗ к документации и примерам

Проверены три корневых ТЗ и текущее приоритетное задание об адаптерах. Таблица связывает их требования с нормой и конкретным исходником или отчётом. Изменения применены к тексту и подготовленным LMX-реализациям; исполнение ядра здесь не проверяется.

## Трассировка требований

| Требование | Норма | Исходник / свидетельство | Что закреплено |
| --- | --- | --- | --- |
| Типовые головы и переменная/значение | [Документ](../CORE_SEQUENCES_REGEX.en.md#types) | [sequence_examples.lmx](LMX_Fn_Receivers/examples/sequence_examples.lmx) | Struct@: ptr; type[]: array; int@[] и int[]@; universal @: ptr value сохраняет initializer. |
| Общий разбор и сохранение групп | [Документ](../../LMX_Array_Reference_Types_Core.ru.md#common-parsing) | [LMX_grammar.en.md](../LMX_grammar.en.md) | P0 сохраняет контейнеры; TYPE/NAME/VALUE определяются до исполнения. Старые адресные скобки заменены на @D\field. |
| Коды типов и полное требование | [Документ](../../LMX_Array_Reference_Types_Core.ru.md#type-codes) | [kernel_contracts.lmx](LMX_Fn_Receivers/src/kernel_contracts.lmx) | T[] и T@ дают обычный int-код; normalizer сохраняет структурное/callable требование. Интернирование остаётся работой ядра. |
| Пустой массив и uninit | [Документ](../LMX_semantics.en.md#uninit-zero-payload) | [fn_and_assignment.lmx](LMX_Fn_Receivers/examples/fn_and_assignment.lmx) | Uninit имеет нулевой payload; явное [] создаёт готовый пустой массив. Отсутствие actual не заменяется нулём. |
| Произвольная глубина указателей | [Документ](../../LMX_Array_Reference_Types_Core.ru.md#references) | [CORE_SEQUENCES_REGEX.en.md#types](../CORE_SEQUENCES_REGEX.en.md#types) | Один общий механизм для T@, T@@, T@@@ и дальнейшей конечной глубины; нет фиксированного лимита 3. |
| satisfies и физический storage | [Документ](../../LMX_Array_Reference_Types_Core.ru.md#admission) | [sequences_core.lmx](LMX_Fn_Receivers/src/sequences_core.lmx) | Направленное A[] satisfies B[]; кеш проверенных типов; допуск не меняет реальный stride и не является результатом matching. |
| Единый Expression и раскрытие RIGHT | [Документ](../CORE_SEQUENCES_REGEX.en.md#expressions) | [operand_group_boundaries.json](LMX_Fn_Receivers/tests/operand_group_boundaries.json) | Единственное открытие RIGHT при anonymous LEFT и единственном anonymous RIGHT; LEFT сохраняется; P0 этого не делает. |
| Универсальные последовательности | [Документ](../CORE_SEQUENCES_REGEX.en.md#sequences) | [SEQUENCES_IMPLEMENTATION.md](LMX_Fn_Receivers/SEQUENCES_IMPLEMENTATION.md) | Плотные T[] и Structure/@[] используют фактическое представление; callbacks допускаются обычным вызовом. |
| Замена диапазона и removed-result | [Документ](../LMX_semantics.en.md#range-replacement-results) | [sequences_mutation.lmx](LMX_Fn_Receivers/src/sequences_mutation.lmx) | replaceRange возвращает target; splice возвращает fresh removed; общий алгоритм, самоналожение, предварительный snapshot. |
| Текущие имена | [Документ](../NAMING_2026-11-22.md) | [catalog.json](LMX_Fn_Receivers/catalog.json) | 15 утверждённых переименований, 3 добавления, 115 уникальных вызовных имён; текстовый replace не конфликтует с replaceRange. |
| Patterns и обычный operand ABI | [Документ](../CORE_SEQUENCES_REGEX.en.md#patterns) | [operands.lmx](LMX_Fn_Receivers/src/regex/operands.lmx) | then/times/atLeast/atMost/optional используют общий left/right; существующий \| расширен без отдельного parser. |
| Захваты, backtracking, текст | [Документ](../../LMX_Regex_Operands.ru.md) | [REGEX_IMPLEMENTATION.md](LMX_Fn_Receivers/REGEX_IMPLEMENTATION.md) | sameAs, ahead/notAhead, behind/notBehind, extendFirst/stopFirst; TextView, scalar/octet, пустой успех и ошибки сохраняются. |
| Проверки начала и конца | [Документ](../LMX_semantics.en.md#pattern-boundary-predicates) | [regex_boundaries.lmx](LMX_Fn_Receivers/examples/regex_boundaries.lmx) | hasPrefix стартует в 0; hasSuffix проверяет доходящие до конца альтернативы и перекрытия с полным контекстом. |
| Адаптеры и реальная активация | [Документ](../LMX_semantics.en.md#adapter-behavior) | [adapter_frames.lmx](LMX_Fn_Receivers/src/adapter_frames.lmx) | Defaults/autofill, required/private, фактические места и отложенное потребление; omitted actual не превращается в explicit value. |
| Общие callable и uncurry | [Документ](../LMX_semantics.en.md#uncurry-observations) | [generic_functions.lmx](LMX_Fn_Receivers/src/generic_functions.lmx) | Произвольная конечная арность и типы; фактические промежуточные сигнатуры; последний callable-результат не вызывается лишний раз. |
| DATA, parent, lifetime и declared failures | [Документ](../tasks/TZ_PRIORITY_Callable_Adapters_Fable_2026-11-22.md) | [KERNEL_REQUIREMENTS.md](LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md) | Нет нового постоянного графа окружения; сохраняются хозяин, lifetime и исходные отказы. Нужна интеграция 17 указанных границ. |
| Message и HTTP | [Документ](../LMX_semantics.en.md) | [patterns.json](06_async_and_messages/patterns.json) | Сохраняются Message и существующий HTTP-транспорт; новые функции не подменяют очередь и протокол обычным локальным вызовом. |
| Все варианты и честная метрика | [Документ](RECEIVERS.md) | [recount_report.json](validation/recount_report.json) | 99 сравнений/297 primary; 23 GoF/184; 24 root examples. Выбирается самый короткий сопоставимый вариант, остальные сохраняются. |

## Объём проверки

- **181 корневое наблюдение:** 58 для типов, 82 для последовательностей, 41 для Patterns. Матрица [uploaded_spec_acceptance.json](LMX_Fn_Receivers/tests/uploaded_spec_acceptance.json) пересобирается из текущих ТЗ; старые IDs сохранены.
- **31 A/B-наблюдение адаптеров:** 10 source probes, 8 частичных probes, 13 сценариев для kernel harness. [Матрица](LMX_Fn_Receivers/tests/adapter_acceptance.json) и [пояснение покрытия](LMX_Fn_Receivers/tests/ADAPTER_ACCEPTANCE.md).
- **227 актуальных .lmx/.lm3, 137 основных/сохранённых LMX-строк в patterns.json и 15 исторических исходников** рассмотрены при [аудите имён и типовой записи](validation/api_syntax_revision_20261122.json). Строки генераторов проверены отдельно.
- Алгоритмы сохранённых вариантов не удалены; их объявления обновлены до `Struct@: ptr`, `type[]: array` и соответствующих составных форм. Универсальные инициализации `@: ptr value` сохранены по смыслу.

## Что ещё требует реального ядра

Все четыре направления interpreter/native остаются **NOT_RUN**. Нормативная матрица не считается количеством успешно выполненных тестов. 58 core-наблюдений требуют настоящих parser/type-interner/access проверок. Подключение 17 документированных входов ядра остаётся обязательным.

У части адаптеров ещё нужен реальный harness. Для новых Pattern-наблюдений 39–41 [manifest fixtures](LMX_Fn_Receivers/tests/regex/fixtures.json) прямо перечисляет недостающие отдельные комбинации и общий declared-callback-failure gate. Наличие 57 исходных fixtures не выдаётся за полное runtime-покрытие 41 нормативного случая.

Оставшихся противоречий документации рассмотренным ТЗ не обнаружено. Это результат сверки текста и исходников, а не доказательство корректности компилятора или интерпретатора.

[Машинный отчёт](validation/current_tz_application_20261122.json) · [Итоговая проверка комплекта](VALIDATION.md) · [Статистика](STATISTICS_2026-11-22.md).
