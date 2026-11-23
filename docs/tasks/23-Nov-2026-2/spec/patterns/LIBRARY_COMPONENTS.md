# Библиотечные операции: использование и сравнение реализации

Редакция **23 ноября 2026 года**. Короткие сопоставимые реализации 22-Nov восстановлены на основе спецификации 23-Nov. Девять сравнений реализаций сохранены. Их договоры различаются: некоторые показывают обобщённый стандартный API, другие — конкретный общий компонент приложения.

| Реализация | Клиенты | LMX | Граница сравнения |
| --- | --- | --- | --- |
| [091. Maybe container and bind implementation](09_functional_computation/091_maybe_container_and_bind_implementation_comparision.md) | [082](09_functional_computation/082_monad_comparision.md) | `some, none, bind` | Стандартные Maybe / Option; отдельное обобщённое сравнение контейнера и bind. |
| [092. Trampoline container and runner implementation](09_functional_computation/092_trampoline_container_and_runner_implementation_comparision.md) | [083](09_functional_computation/083_trampoline_comparision.md) | `done, more, trampoline` | Haskell Free Identity / Scala TailCalls; отдельные контейнер и trampoline. |
| [093. Pipe — implementation](02_architecture_and_boundaries/093_pipe_implementation_comparision.md) | [013](02_architecture_and_boundaries/013_pipe_and_filter_comparision.md) | `PipeLibrary` | Короткий импортируемый pipe из 22-Nov; расширенная обобщённая версия сохранена отдельно. |
| [094. FindById — implementation](03_domain_and_persistence/094_find_by_id_implementation_comparision.md) | [016](03_domain_and_persistence/016_repository_comparision.md) | `FindLibrary` | Первый объект с заданным целочисленным id; обобщённый findFirst остаётся отдельной операцией. |
| [095. Specification combinator — implementation](03_domain_and_persistence/095_specification_combinator_implementation_comparision.md) | [031](03_domain_and_persistence/031_specification_comparision.md) | `SpecificationLibrary` | Композиция двух предикатов с коротким замыканием; один общий контракт полей. |
| [096. Money value equality — implementation](03_domain_and_persistence/096_money_value_equality_implementation_comparision.md) | [032](03_domain_and_persistence/032_value_object_comparision.md) | `MoneyLibrary` | Двухкомпонентный Money; общий equalFields не подменяет предметное сравнение. |
| [097. Retry Library — Implementation](05_cloud_and_resilience/097_retry_library_implementation_comparision.md) | [039](05_cloud_and_resilience/039_retry_comparision.md), [045](05_cloud_and_resilience/045_ambassador_comparision.md) | `RetryLibrary` | Собственный синхронный RetryHelper во всех трёх языках; весь helper учитывается отдельно и вместе с клиентами. |
| [098. Execute Around implementation](09_functional_computation/098_execute_around_implementation_comparision.md) | [084](09_functional_computation/084_execute_around_comparision.md) | `bracket` | Haskell bracket / Scala Using.resource; один ресурс, полный acquire/action/release. |
| [099. General partial-application implementation](09_functional_computation/099_integer_partial_application_implementation_comparision.md) | [085](09_functional_computation/085_currying_comparision.md) | `partial, curry` | Haskell partial application / Scala curried; произвольная смешанная сигнатура LMX. |

## Общие компоненты и полный размер

Клиенты 039 и 045 используют собственный общий синхронный компонент 097 в LMX, Go и C#. Они явно помечены `shared_implementation_client`. Таблица включает оба клиента и один полный helper; импорт не превращает реализацию в бесплатную стандартную библиотеку. Для одного выбранного клиента JSON содержит отдельную сумму client + helper. Асинхронные варианты с другим договором сохранены в extended_comparisons.

| Компонент / клиенты | Язык | Клиенты | Helper один раз | Всего | LMX без сложного Throws |
| --- | --- | ---: | ---: | ---: | ---: |
| 97 / 039, 045 | LMX | 264 | 366 | 630 | 630 |
| 97 / 039, 045 | Go | 289 | 276 | 565 | — |
| 97 / 039, 045 | C# | 292 | 420 | 712 | — |

## Краткость и полнота

Выбирается самый короткий полный вариант с тем же наблюдаемым договором. Динамическое связывание, `{type value}` и копирование полей используются по действующей спецификации; лексическая видимость свободных имён не навязывается. Повторяющийся алгоритм выносится в обычную функцию либо заменяется копированием общего набора полей.

В 084 сохранён целиком авторский Around + общий Trace (709 непробельных символов). Основной клиент core bracket занимает 586 символов. Сравнение имени ошибки исключено по доказанному замкнутому набору callback-исходов этого примера; другие ошибки инфраструктуры выходят под собственными именами. Это не общее разрешение перехватывать любой FxCallFailure как ResourceFailure. [Точная проверка границы](09_functional_computation/review/084_failure_boundary.md).

Клиенты функциональной группы используют настоящие средства Haskell/Scala. Самостоятельные сравнительные реализации этих языков остаются отдельными листингами. Публичные функции LMX принадлежат одному ядру; узкие PatternLibrary-компоненты и их полные исходники явно указаны рядом. [Общий реестр](../CORE_FUNCTIONS.md) связывает публичные имена и определения.

## Дополнительные наборы

[Исходные 24 примера](examples/README.md), [Julia](examples/julia_comparison/README.md), [Perl](examples/perl_comparison/README.md) и [SBCL/Common Lisp](examples/SBCL_comparison/README.md) публикуют клиентов, полные сравнения реализаций и зависимости отдельно. Если у новой операции нет иностранной сравнительной реализации, она обозначена как unpaired, а действующее определение LMX и замыкание зависимостей всё равно доступны и посчитаны.

## Подсчёт и проверяемые ограничения

Основной размер включает весь текст выбранного листинга: заголовки, обязательные поля, импорты и Throws. Явные конечные отказы и общий `Throws/copy(Throws)` — преимущество LMX по авторской оценке: видно, какой метод что порождает. Дополнительная колонка «без сложного Throws» сохраняет заголовок и первый аргумент каждого списка, все ссылки/copy и первый аргумент общего банка. Общая реализация считается один раз в своей границе; сама программа и её эффекты не изменяются.

Замыкания зависимостей разных альтернатив пересекаются, поэтому их нельзя механически складывать как один исполняемый пакет. [Статистика](STATISTICS_2026-11-22.md), [полный JSON](validation/statistics_20261122.json) и [методика](COMPARISON_RULES.md) фиксируют границы. LMX runtime отсутствует; source checks и пересчёт размеров не являются исполнением LMX. [Требования интеграции](LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md).
