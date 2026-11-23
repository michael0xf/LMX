# Библиотечные операции: использование и сравнение реализации

Редакция **23 ноября 2026 года**. Примеры использования и самостоятельные реализации имеют разные границы подсчёта. Все девять сравнений реализаций сохранены; они не становятся самописными зависимостями иностранных клиентов.

| Сравнение реализации | Клиент | Прямые функции LMX | Реальное средство контрольного языка |
| --- | --- | --- | --- |
| [091. Maybe container and bind implementation](09_functional_computation/091_maybe_container_and_bind_implementation_comparision.md) | [082](09_functional_computation/082_monad_comparision.md) | `some, none, bind` | Haskell Maybe / (>>=); Scala Option.flatMap |
| [092. Trampoline container and runner implementation](09_functional_computation/092_trampoline_container_and_runner_implementation_comparision.md) | [083](09_functional_computation/083_trampoline_comparision.md) | `done, more, trampoline` | Haskell free / Free Identity; Scala TailCalls |
| [093. Pipe — generic implementation](02_architecture_and_boundaries/093_pipe_implementation_comparision.md) | [013](02_architecture_and_boundaries/013_pipe_and_filter_comparision.md) | `pipe, compose` | Java IntUnaryOperator.andThen; Go ordinary function composition |
| [094. FindFirst — generic implementation](03_domain_and_persistence/094_find_by_id_implementation_comparision.md) | [016](03_domain_and_persistence/016_repository_comparision.md) | `findFirst` | Python next with a generator; C# LINQ FirstOrDefault |
| [095. AllOf — predicate conjunction implementation](03_domain_and_persistence/095_specification_combinator_implementation_comparision.md) | [031](03_domain_and_persistence/031_specification_comparision.md) | `allOf` | Python all; C# LINQ All |
| [096. EqualFields — value equality implementation](03_domain_and_persistence/096_money_value_equality_implementation_comparision.md) | [032](03_domain_and_persistence/032_value_object_comparision.md) | `equalFields` | Python dataclass equality; C# record equality |
| [097. RetryPost — asynchronous retry implementation](05_cloud_and_resilience/097_retry_library_implementation_comparision.md) | [039](05_cloud_and_resilience/039_retry_comparision.md), [045](05_cloud_and_resilience/045_ambassador_comparision.md) | `retryPost` | Go cenkalti/backoff/v5; C# Polly |
| [098. Execute Around implementation](09_functional_computation/098_execute_around_implementation_comparision.md) | [084](09_functional_computation/084_execute_around_comparision.md) | `bracket` | Haskell Control.Exception.bracket; Scala Using.resource |
| [099. General partial-application implementation](09_functional_computation/099_integer_partial_application_implementation_comparision.md) | [085](09_functional_computation/085_currying_comparision.md) | `partial, curry` | Haskell partial application; Scala Function2.curried |

## Как использовать исходники

В LMX все перечисленные функции относятся к одному проекту ядра и вызываются напрямую. Самостоятельный клиент не загружает отдельную пользовательскую библиотеку. [Общий реестр](../CORE_FUNCTIONS.md) связывает публичные имена, сигнатуры и полные алгоритмы.

Клиенты Haskell, Scala, Python, Go, Java и C# используют указанные настоящие средства языка или пакеты. Наши MaybeValue, Bounce, Around, Partial и другие сравнительные реализации остаются в отдельных листингах реализации. Они не импортируются в клиент вместо настоящей библиотеки. Необходимые версии, зависимости и ограничения указаны у соответствующего исходника.

## Полнота

Реализации обобщены в пределах указанного договора операции: типы пользовательских значений не привязаны к int, размер или арность не ограничены произвольной константой, разобраны пустые входы и отказы. Значения int для индекса, type-кода и логического результата остаются там, где они требуются семантикой. Предметный Money или счётчик в клиенте не специализируют общий helper.

Реализация отдельной операции не называется заменой целого framework. Например, 098 сравнивает single-resource bracket, а не весь Using.Manager; 097 сравнивает явно ограниченную политику повторов, а не полный набор возможностей Polly.

## Дополнительные примеры

[Сравнения Haskell](examples/library_comparisons/README.md) содержат полные самостоятельные модули и ссылки на канонические определения LMX. Их клиент Analogies.hs использует base, array и monad-loops, а не эти модули. [Julia](examples/julia_comparison/README.md) и [Perl](examples/perl_comparison/README.md) следуют тому же правилу и отдельно учитывают реализации библиотечных операций.

## Асинхронность и владение

`retryPost` реализует состояние задания в Message, выполняет отправку и ожидание через post, сохраняет итог и учитывает поздние ответы. Отмена повторов или уведомление о таймауте не доказывает завершение удалённой операции. Для синхронных combinators достаточно post всего метода владельцу: транспорт, включая HTTP, уже предоставляет доставку, ответы и ошибки доставки. Внутренняя вторая очередь или scheduler таким функциям не приписываются.

## Подсчёт

Клиент, реализация и общие зависимости считаются раздельно. Общий исходник ядра хранится один раз; таблица зависимостей даёт полные тела по ссылкам и размер замыкания зависимостей без повторов. Для конкретного приложения нельзя механически сложить все альтернативные сценарии или прибавлять стандартную библиотеку только одному языку. [Методика](COMPARISON_RULES.md) и [общая статистика примеров](examples/STATISTICS.md) явно указывают, какие пары имеют одинаковый наблюдаемый договор.

LMX runtime не входит в пакет. Проверка публикации, исходников и размеров не является отметкой выполнения LMX; точные оставшиеся входы перечислены в [KERNEL_REQUIREMENTS.md](LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md).
