# Библиотечные компоненты и связанные примеры

Показаны 9 реализации компонентов. Каждый имеет по три полных листинга. Основные примеры получают эти компоненты готовыми на одинаковых условиях.

| Реализация | Использование | Контрольные языки |
| --- | --- | --- |
| [091. Maybe container and bind implementation](09_functional_computation/091_maybe_container_and_bind_implementation_comparision.md) | [082. Monad](09_functional_computation/082_monad_comparision.md) | Haskell, Scala |
| [092. Trampoline container and runner implementation](09_functional_computation/092_trampoline_container_and_runner_implementation_comparision.md) | [083. Trampoline](09_functional_computation/083_trampoline_comparision.md) | Haskell, Scala |
| [093. Pipe — implementation](02_architecture_and_boundaries/093_pipe_implementation_comparision.md) | [013. Pipe and Filter](02_architecture_and_boundaries/013_pipe_and_filter_comparision.md) | Java, Go |
| [094. FindById — implementation](03_domain_and_persistence/094_find_by_id_implementation_comparision.md) | [016. Repository](03_domain_and_persistence/016_repository_comparision.md) | Python, C# |
| [095. Specification combinator — implementation](03_domain_and_persistence/095_specification_combinator_implementation_comparision.md) | [031. Specification](03_domain_and_persistence/031_specification_comparision.md) | Python, C# |
| [096. Money value equality — implementation](03_domain_and_persistence/096_money_value_equality_implementation_comparision.md) | [032. Value Object](03_domain_and_persistence/032_value_object_comparision.md) | Python, C# |
| [097. Retry Library — Implementation](05_cloud_and_resilience/097_retry_library_implementation_comparision.md) | [039. Retry](05_cloud_and_resilience/039_retry_comparision.md), [045. Ambassador](05_cloud_and_resilience/045_ambassador_comparision.md) | Go, C# |
| [098. Execute Around implementation](09_functional_computation/098_execute_around_implementation_comparision.md) | [084. Execute Around](09_functional_computation/084_execute_around_comparision.md) | Haskell, Scala |
| [099. Integer partial-application implementation](09_functional_computation/099_integer_partial_application_implementation_comparision.md) | [085. Currying](09_functional_computation/085_currying_comparision.md) | Haskell, Scala |

## Подготовка исходников

Все отдельные листинги находятся в examples соответствующей группы. В LMX библиотека сначала доступна общему namespace, после чего client выполняет обычный import. Запись import не обещает новый механизм поиска файлов. Haskell-модули и Scala/Java/C# классы подготавливаются вместе с клиентом; для прямой загрузки Haskell исходнику модуля дают его объявленное имя либо явно передают оба файла компилятору. Точные зависимости и имена модулей указаны возле кода.

Реализация общего компонента не дублируется в размере каждого клиента. Для оценки выбранного приложения нужно сложить нужные клиентские листинги с используемыми реализациями один раз; нельзя складывать все варианты альтернативных сценариев как одну production-систему.

## English note

Each implementation case includes the complete component in LMX and both control languages. Clients retain their application-specific work. Namespace imports require the supplied implementation to be loaded; they do not introduce a file loader. Per-listing notes identify module/class names and compilation dependencies. Count a shared component once when assessing a selected set of clients.
