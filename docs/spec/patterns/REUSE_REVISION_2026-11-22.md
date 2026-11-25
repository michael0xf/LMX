# Переиспользование кода и передача деклараций

Редакция от 22 ноября 2026 года. Основа — текущий комплект документации и примеров из загруженного архива; предыдущая доставленная сборка — `LMX_Complete_084_2026-11-22.zip`.

## Что изменено

Проверены все **146 записей**: 99 расширенных сравнений, 23 исходных GoF-сравнения и 24 самостоятельных примера. В 25 основных LMX-листингах выбраны более короткие варианты при сохранении сценария. Ещё два листинга дополнены отсутствовавшими прикладными определениями. Ничего не удалено из набора задач; код контрольных языков и ожидаемые результаты сохранены.

Общие действия переиспользуют уже определённые методы `read`, `query`, `start`, `sample`; повторяющиеся тела вынесены в общие `reply`, `Steps\code`, `Trace\code` и `Trace\eval`. В подходящих местах повторно используется общий локальный контекст и явная ссылка на шаблон. Позиционная запись сокращена только при известном порядке DATA. Эти решения и случаи, где сокращение разрушало бы контракт, записаны отдельно для каждого примера.

## Декларация как аргумент

**Передаваемая декларация — DATA-структура, которая не исполняется при передаче. Её внутреннее имя не ищется среди принимающих входов.** Аргумент поступает по обычной позиции либо по внешней метке `name := value`; выбранная переменная принимает всю структуру по общим правилам допустимости. Инициализатор не вычисляется ради подгонки к примитивному типу.

[Текст для объединения с Fable](../LMX_semantics.en.md#declaration-arguments) содержит полное правило, пример `numbers/cycles`, ожидаемый результат 12 и необходимые изменения ядра. Правило внесено в основные нормативные документы, руководство, заметки и регрессионный пример D-03. В адаптерах разделены внутренний транспорт места и публичный фактический аргумент; новая интеграционная проверка PA01 остаётся NOT_RUN.

## Примеры 083 и 084

- **083:** общий шаг находится в `Steps\code`; `even_step` и `odd_step` задают свои `x` и `next`. Список `Throws` объявлен один раз, все четыре обращения включены в размер. Исправлена опечатка `Tthrows`. Вход — `Steps\Example\run(n)`.

- **084:** полное определение `Around` остаётся в основном листинге. Общие `Trace\code` и `Trace\eval` объединяют журнал и проверку отказа. В `Release\close` сначала объявляется `int: x 3`, затем вызывается `eval()`. Вход — `Trace\Example\run(mode)`. Ресурс 42, три переданных callback, освобождение и обработчик сохранены.

Исторический 083 теперь включает точные Bounce и BounceRunner из сохранённого 092; сам старый клиент не изменён. Полный сохранённый 084 продолжает включать Around из сохранённого 098. Дополнительный пример обработки отказа батута тоже содержит весь нужный прикладной код.

## Изменение размеров

Считаются непробельные Unicode-символы полного основного листинга. Это сравнение с предыдущей доставленной сборкой, а не с первоначальными историческими строками из сводки.

| Набор | Было | Стало | Изменение |
| --- | ---: | ---: | ---: |
| 99 расширенных сравнений, LMX | 21975 | 21577 | −398 |
| 23 GoF-сравнения, LMX | 5734 | 5734 | 0 |
| 24 корневых примера, LMX | 5408 | 5674 | +266 |

Увеличение корневого набора связано с включением полного Cycles в H09 (+73) и CharacterRange в V02 (+199); V03 стал короче на 6 символов. Старые клиенты H09/V02 буквально сохранены в составе полных листингов и метаданных. Прикладные определения не объявлялись операциями ядра ради исключения из подсчёта.

| ID | Пример | Было | Стало |
| --- | --- | ---: | ---: |
| 004 | [Flux / Redux](01_ui_and_navigation/004_flux_redux_comparision.md) | 287 | 273 |
| 035 | [Front Controller](01_ui_and_navigation/035_front_controller_comparision.md) | 137 | 120 |
| 036 | [Page Controller](01_ui_and_navigation/036_page_controller_comparision.md) | 109 | 99 |
| 005 | [Layered Architecture](02_architecture_and_boundaries/005_layered_architecture_comparision.md) | 215 | 195 |
| 006 | [Hexagonal Architecture (Ports and Adapters)](02_architecture_and_boundaries/006_hexagonal_architecture_comparision.md) | 215 | 181 |
| 007 | [Clean Architecture](02_architecture_and_boundaries/007_clean_architecture_comparision.md) | 342 | 300 |
| 008 | [Onion Architecture](02_architecture_and_boundaries/008_onion_architecture_comparision.md) | 247 | 234 |
| 013 | [Pipe and Filter](02_architecture_and_boundaries/013_pipe_and_filter_comparision.md) | 209 | 202 |
| 015 | [Microkernel / Plug-in](02_architecture_and_boundaries/015_microkernel_comparision.md) | 361 | 355 |
| 046 | [Anti-Corruption Layer (ACL)](02_architecture_and_boundaries/046_anti_corruption_layer_comparision.md) | 175 | 165 |
| 047 | [Strangler Fig](02_architecture_and_boundaries/047_strangler_fig_comparision.md) | 330 | 310 |
| 032 | [Value Object](03_domain_and_persistence/032_value_object_comparision.md) | 273 | 239 |
| 011 | [CQRS](04_events_and_consistency/011_cqrs_comparision.md) | 262 | 257 |
| 041 | [Saga](04_events_and_consistency/041_saga_comparision.md) | 361 | 301 |
| 050 | [Materialized View](04_events_and_consistency/050_materialized_view_comparision.md) | 214 | 208 |
| 054 | [Competing Consumers](05_cloud_and_resilience/054_competing_consumers_comparision.md) | 288 | 242 |
| 060 | [Actor Model](06_async_and_messages/060_actor_model_comparision.md) | 104 | 100 |
| 064 | [Future / Promise](06_async_and_messages/064_future_promise_comparision.md) | 273 | 268 |
| 090 | [MapReduce](06_async_and_messages/090_map_reduce_comparision.md) | 220 | 216 |
| 065 | [Read-Write Lock](07_state_coordination/065_read_write_lock_comparision.md) | 111 | 107 |
| 067 | [Guarded Suspension](07_state_coordination/067_guarded_suspension_comparision.md) | 258 | 253 |
| 070 | [Monitor Object](07_state_coordination/070_monitor_object_comparision.md) | 149 | 143 |
| 083 | [Trampoline](09_functional_computation/083_trampoline_comparision.md) | 433 | 417 |
| 084 | [Execute Around](09_functional_computation/084_execute_around_comparision.md) | 719 | 709 |
| H09 | [Корневой пример](examples/haskell_comparision/source/lmx/H09.lm3) | 212 | 285 |
| V02 | [Корневой пример](examples/haskell_comparision/source/lmx/V02.lm3) | 263 | 462 |
| V03 | [Корневой пример](examples/haskell_comparision/source/lmx/V03.lm3) | 304 | 298 |

## Публикация и проверки

Заново сформированы все **13 PDF / 18 страниц** и **13 XLSX / 16 листов**, а также Markdown, CSV и JSON статистики. Пересчёт формул сравнительных книг проверен изменением входного числа и его восстановлением; в конечных файлах нет ячеек ошибок. Просмотрены все итоговые страницы и листы, включая длинные пояснения вариантов. В сводном PDF исправлен перенос заключительного абзаца на отдельную почти пустую страницу.

Сверены все 883 прежних пути, 198 групповых и 161 GoF-листинг контрольных языков, 99 прежних основных LMX-листингов и сохранённые варианты. Все 24 корневых ID и 45 ожидаемых случаев, а также 23 GoF-ожидания сохранены. Индивидуальные обзоры покрывают 146 записей без пропусков и повторов.

**LMX не запускался.** Эти проверки подтверждают сохранность материалов и согласованность публикации. Они не подтверждают исполнение нового правила, допустимость типов на ядре или поведение нативных переходов. Встроенные общие алгоритмы по-прежнему требуют реализации и приёмки указанных FxKernel-интерфейсов.

## Где смотреть результаты

- [Общая статистика](STATISTICS_2026-11-22.md), [Excel](STATISTICS_2026-11-22.xlsx), [PDF](STATISTICS_2026-11-22.pdf).
- [Обзор 01–05](validation/reuse_review_01_05_20261122.json), [06–09](validation/reuse_review_06_09_20261122.json), [083/084](validation/reuse_review_083_084_20261122.json), [GoF и examples](validation/reuse_review_gof_examples_20261122.json).
- [Сохранность](validation/reuse_preservation_sources_20261122.json), [актуальные проверки](VALIDATION.md), [актуальные проверки](VALIDATION.md).
- [Визуальная проверка PDF](validation/pdf_visual_review_20261122.json) и [Excel](validation/xlsx_visual_review_20261122.json).

Актуальное применение общих операций, форм и переименований описано в [отчёте интеграции](../INTEGRATION_REPORT.md). Числа обзора 22-Nov остаются историческими и не являются результатами проверки изменённых исходников.
