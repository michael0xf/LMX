# Изменения: операнды и готовые библиотеки

Дата: 21 ноября 2026 года. Это следующая редакция расширенного архива.

- Сохранены все 90 дополнительных паттернов и 23 исходных корневых GoF-примера.
- Проверены все 90 LMX-примеров на применение OPERANDS_TEMPLATE и библиотечных функций.
- Изменены 11 основных сравнений; добавлено 9 сравнений реализации.
- Всего в новых группах 99 сравнений и 297 листингов.

## Граница сравнения

Monad использует готовый Maybe во всех трёх языках. Trampoline использует готовый контейнер шага и исполнитель. Их реализации показаны отдельными соседними сравнениями. Тот же подход применён к остальным выбранным компонентам. Никакой helper не исключён только из LMX.

## Список изменений

| Основной пример | Реализации |
| --- | --- |
| [013. Pipe and Filter](02_architecture_and_boundaries/013_pipe_and_filter_comparision.md) | [093. Pipe — implementation](02_architecture_and_boundaries/093_pipe_implementation_comparision.md) |
| [016. Repository](03_domain_and_persistence/016_repository_comparision.md) | [094. FindById — implementation](03_domain_and_persistence/094_find_by_id_implementation_comparision.md) |
| [031. Specification](03_domain_and_persistence/031_specification_comparision.md) | [095. Specification combinator — implementation](03_domain_and_persistence/095_specification_combinator_implementation_comparision.md) |
| [032. Value Object](03_domain_and_persistence/032_value_object_comparision.md) | [096. Money value equality — implementation](03_domain_and_persistence/096_money_value_equality_implementation_comparision.md) |
| [039. Retry](05_cloud_and_resilience/039_retry_comparision.md) | [097. Retry Library — Implementation](05_cloud_and_resilience/097_retry_library_implementation_comparision.md) |
| [045. Ambassador](05_cloud_and_resilience/045_ambassador_comparision.md) | [097. Retry Library — Implementation](05_cloud_and_resilience/097_retry_library_implementation_comparision.md) |
| [079. Fluent Interface](08_objects_and_composition/079_fluent_interface_comparision.md) | Изменение операндной формы в самом листинге |
| [082. Monad](09_functional_computation/082_monad_comparision.md) | [091. Maybe container and bind implementation](09_functional_computation/091_maybe_container_and_bind_implementation_comparision.md) |
| [083. Trampoline](09_functional_computation/083_trampoline_comparision.md) | [092. Trampoline container and runner implementation](09_functional_computation/092_trampoline_container_and_runner_implementation_comparision.md) |
| [084. Execute Around](09_functional_computation/084_execute_around_comparision.md) | [098. Execute Around implementation](09_functional_computation/098_execute_around_implementation_comparision.md) |
| [085. Currying](09_functional_computation/085_currying_comparision.md) | [099. Integer partial-application implementation](09_functional_computation/099_integer_partial_application_implementation_comparision.md) |

Markdown, отдельные исходники, CSV, XLSX и PDF заново получены из согласованных JSON. В таблицах использование и реализация различаются явно, а их суммы в Excel разделены. Контрольные результаты, существующий Message/HTTP-профиль и ограничения асинхронного исполнения сохранены.

[Полный аудит](OPERAND_LIBRARY_REVIEW.md) · [Статус проверок](VALIDATION.md)

## Дополнительная проверка корневой examples/

По следующему запросу проверены все 24 исходных LMX-файла и Analogies.hs. Переписаны H01, H03, H06, H07, H09, R07 и V02. Добавлены шесть сравнений полных библиотечных реализаций и реальные импортируемые Haskell-модули. H03/H06 используют уже показанные реализации 099/093; библиотеки не объявлены новыми паттернами.

Все прежние ожидаемые значения, счётчики, отрицательные проверки, 18 дополнительных fixtures и 23 записи корневых сравнительных программ сохранены. В V02 добавлены два отрицательных Unicode-входа. В V05 уточнён фактический владелец наблюдаемого состояния; для Message сохранено различие HTTP admission и прикладного результата. Зависимости, аудит и полные пары доступны из [examples/README.ru.md](examples/README.ru.md).

В новой редакции дополнительно исправлены пути через сохранённые independent/immutable в библиотеках Specification и Money. В операндах, использующих готовый sys\OPERANDS_TEMPLATE, шаблон стоит первым в DATA согласно уточнению автора о предпочтительной позиционной передаче. Специальные typed/prepared и raw заголовки H07 сохранены явно.
