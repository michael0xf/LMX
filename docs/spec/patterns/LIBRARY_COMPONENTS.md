# Библиотечные операции: использование и сравнение реализации

Редакция **23 ноября 2026 года**. Короткие сопоставимые реализации 22-Nov восстановлены на основе спецификации 23-Nov. Девять сравнений реализаций сохранены. Их договоры различаются: некоторые показывают обобщённый стандартный API, другие — конкретный общий компонент приложения.

| Реализация | Клиенты | LMX | Граница сравнения |
| --- | --- | --- | --- |
| [091. Maybe container and bind implementation](09_functional_computation/091_maybe_container_and_bind_implementation_comparision.md) | [082](09_functional_computation/082_monad_comparision.md) | `some, none, bind` | Стандартные Maybe / Option; отдельное обобщённое сравнение контейнера и bind. |
| [092. Trampoline container and runner implementation](09_functional_computation/092_trampoline_container_and_runner_implementation_comparision.md) | [083](09_functional_computation/083_trampoline_comparision.md) | `done, more, trampoline` | Haskell Free Identity / Scala TailCalls; отдельные контейнер и trampoline. |
| [093. Pipe — implementation](02_architecture_and_boundaries/093_pipe_implementation_comparision.md) | [013](02_architecture_and_boundaries/013_pipe_and_filter_comparision.md) | `pipe` | Общий pipe применяет стадии к значению; контрольный профиль — целочисленный конвейер. compose строит callable и сравнивается отдельно. |
| [094. FindById — implementation](03_domain_and_persistence/094_find_by_id_implementation_comparision.md) | [016](03_domain_and_persistence/016_repository_comparision.md) | `findFirst` | Общий findFirst принимает предикат; клиент сохраняет профиль поиска по id и прежнее представление отсутствия. |
| [095. Specification combinator — implementation](03_domain_and_persistence/095_specification_combinator_implementation_comparision.md) | [031](03_domain_and_persistence/031_specification_comparision.md) | `allOf` | Общий allOf сохраняет действительную совместимую сигнатуру; клиент проверяет два предиката с коротким замыканием. |
| [096. Money value equality — implementation](03_domain_and_persistence/096_money_value_equality_implementation_comparision.md) | [032](03_domain_and_persistence/032_value_object_comparision.md) | `equals` | equals использует явную проекцию полей Money; общий алгоритм равенства и проекция имеют отдельные обязанности. |
| [097. Retry Library — Implementation](05_cloud_and_resilience/097_retry_library_implementation_comparision.md) | [039](05_cloud_and_resilience/039_retry_comparision.md), [045](05_cloud_and_resilience/045_ambassador_comparision.md) | `retry` | Общий синхронный retry с явным профилем Http503; полные реализации и общие зависимости учитываются отдельно. |
| [098. Execute Around implementation](09_functional_computation/098_execute_around_implementation_comparision.md) | [084](09_functional_computation/084_execute_around_comparision.md) | `bracket` | Haskell bracket / Scala Using.resource; один ресурс, полный acquire/action/release. |
| [099. General partial-application implementation](09_functional_computation/099_integer_partial_application_implementation_comparision.md) | [085](09_functional_computation/085_currying_comparision.md) | `partial, curry` | Haskell partial application / Scala curried; произвольная смешанная сигнатура LMX. |

## Общие компоненты и полный размер

Клиенты 039 и 045 используют общий синхронный компонент 097: канонический retry с явным Http503 в LMX и опубликованный RetryHelper в Go/C#. Они явно помечены `shared_implementation_client`. Таблица включает оба клиента и один полный helper; импорт не превращает реализацию в бесплатную стандартную библиотеку. Для одного выбранного клиента JSON содержит отдельную сумму client + helper. Асинхронные варианты с другим договором сохранены в extended_comparisons.

| Компонент / клиенты | Язык | Клиенты | Helper один раз | Всего |
| --- | --- | ---: | ---: | ---: |
| 97 / 039, 045 | LMX | 430 | 608 | 1038 |
| 97 / 039, 045 | Go | 289 | 276 | 565 |
| 97 / 039, 045 | C# | 292 | 420 | 712 |

## Краткость и полнота

Для каждого функционального клиентского договора сравниваются обе полные формы LMX: процедурная и функциональная. Одна из них не исключается из сравнения из-за размера. Динамическое связывание, `{type value}` и копирование полей используются по действующей спецификации; лексическая видимость свободных имён не навязывается. Повторяющийся алгоритм выносится в обычную функцию либо заменяется копированием общего набора полей.

В 084 сохранён целиком авторский Around + общий Trace (709 непробельных символов). Функциональный клиент core bracket занимает 586 символов; оба варианта входят в сравнение. Сравнение имени ошибки исключено по доказанному замкнутому набору callback-исходов этого примера; другие ошибки инфраструктуры выходят под собственными именами. Это не общее разрешение перехватывать любой FxCallFailure как ResourceFailure. [Точная проверка границы](09_functional_computation/review/084_failure_boundary.md).

Клиенты функциональной группы используют настоящие средства Haskell/Scala. Самостоятельные сравнительные реализации этих языков остаются отдельными листингами. Публичные функции LMX принадлежат одному ядру; прикладные профили и полные общие исходники явно указаны рядом. [Общий реестр](../CORE_FUNCTIONS.md) связывает публичные имена и определения.

## Дополнительные наборы

[Исходные 24 примера](examples/README.md), [Julia](examples/julia_comparison/README.md), [Perl](examples/perl_comparison/README.md) и [SBCL/Common Lisp](examples/SBCL_comparison/README.md) публикуют клиентов, полные сравнения реализаций и зависимости отдельно. Если у новой операции нет иностранной сравнительной реализации, она обозначена как unpaired, а действующее определение LMX и замыкание зависимостей всё равно доступны и посчитаны.

## Подсчёт и проверяемые ограничения

Основной размер включает весь текст каждого опубликованного клиента: заголовки, обязательные поля, импорты и Throws. Считается полный текст каждой формы: все определения, вспомогательные методы, комментарии внутри листинга, обработчики, имена ошибок и полные ссылки `throws: copy(target\throws)`. Списки берутся из фактически выбранных методов или явно заданного конечного объединения договоров. Статистического удаления аргументов Throws нет. В PDF/XLSX зелёным шрифтом и подчёркиванием числа выделяются **все** равные минимумы полного счёта сопоставимой строки; неполные аналогии победителя не получают. Общая реализация учитывается один раз в своей границе.

Замыкания зависимостей разных альтернатив пересекаются, поэтому их нельзя механически складывать как один исполняемый пакет. [Статистика](STATISTICS_2026-11-22.md), [полный JSON](validation/statistics_20261122.json) и [методика](COMPARISON_RULES.md) фиксируют границы. LMX runtime отсутствует; source checks и пересчёт размеров не являются исполнением LMX. [Требования интеграции](LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md).
