# Статус архивных задач LMX

Пометки сверены с редакцией от 27 ноября 2026 года. В каждой поставке
`STATUS.md` указывает прежние правила, места в исходных материалах и действующую
норму. Авторские тексты, манифесты и расписки поставок сохранены. Для отдельных
ТЗ действует таблица ниже. Состояние реализации — в [плане v3](../../next_core_tasks_v3.md#task-coverage-20261126).

## Поставки

| Поставка | Пометка рядом с исходниками | План v3 |
| --- | --- | --- |
| 24 ноября, группировка Expression и сигнатуры | [Статус](24-Nov-2026/STATUS.md) | [28](../../next_core_tasks_v3.md#docs-20261124), [29.8.4](../../next_core_tasks_v3.md#expression-reference-array) |
| 25 ноября, дополнение примеров и каталога | [Статус](25-Nov-2026/STATUS.md) | [28.7–28.8](../../next_core_tasks_v3.md#docs-20261124) |
| 25 ноября (2), опись и мост C99 | [Статус](25-Nov-2026-2/STATUS.md) | [29.7](../../next_core_tasks_v3.md#c99-catalog-20261125), [29.7.4](../../next_core_tasks_v3.md#c99-census-20261126) |
| 25 ноября (3), самостоятельная коллекция C99 | [Статус](25-Nov-2026-3/STATUS.md) | [29.7](../../next_core_tasks_v3.md#c99-catalog-20261125), [29.7.4](../../next_core_tasks_v3.md#c99-census-20261126) |
| 26 ноября, обновление коллекции C99 | [Статус](26-Nov-2026/STATUS.md) | [29.7.4](../../next_core_tasks_v3.md#c99-census-20261126) |
| 26 ноября (2), грамматика, Expression, массивы и SLJIT | [Статус](26-Nov-2026-2/STATUS.md) | [первый шаг](../../next_core_tasks_v3.md#grammar-first-20261126), [29.8](../../next_core_tasks_v3.md#types-arrays-20261126) |
| 26 ноября (3), размеры осей и TypeRef | [Статус](26-Nov-2026-3/STATUS.md) | [29.8](../../next_core_tasks_v3.md#types-arrays-20261126), [29.9](../../next_core_tasks_v3.md#prefix-types-20261126) |

## Поставки, сохранённые в истории Git

Исходные деревья 22–23 ноября находятся в родительском снимке коммита `b23b7b834` (`d901de2b9`).

| Поставка | Историческая норма или форма | Действующее место |
| --- | --- | --- |
| `22-Nov-2026` | Старые границы Expression, прежняя фиксация приоритетов и прежние декларации вызываемых в ТЗ об адаптерах. | [22](../../next_core_tasks_v3.md#docs-20261122), [общая группировка](../spec/EXPRESSION_ALGORITHM.md#single-parser-and-grouper), [сигнатуры](../spec/LMX_semantics.ru.md#fn-signature) |
| `22-Nov-2026-2` | `LMX_Array_Reference_Types_Core.ru.md` называет `@[]` типом Structure, описывает коды типов и TYPE-постфиксы. | [Типы и TypeRef](../spec/TYPE_DECLARATION_FORMS.md#type-descriptor), [редакция типов](../../next_core_tasks_v3.md#docs-20261122-2) |
| `22-Nov-2026-3` | Тот же заголовок и типовые примеры сохраняют суффиксы и коды. Примеры переданных деклараций используют ранние сигнатуры. | [Префиксы](../spec/TYPE_DECLARATION_FORMS.md), [переданные объявления](../../next_core_tasks_v3.md#docs-20261122-3) |
| `23-Nov-2026` | Grammar §29 описывает типовые постфиксы. Старые независимые проходы Expression, сопоставления и фикстуры принадлежат снимку. | [25](../../next_core_tasks_v3.md#docs-20261123), [P0 и Expression](../../next_core_tasks_v3.md#grammar-complete-20261127) |
| `23-Nov-2026-2` | Grammar §29 и тогдашние примеры SBCL используют TYPE-постфиксы и прежние формы операций. Их числовые наблюдения относятся к использованной версии. | [Каталог и SBCL](../../next_core_tasks_v3.md#docs-20261123-2), [типы](../spec/TYPE_DECLARATION_FORMS.md), [операции](../spec/TENSOR_EXPRESSIONS.md) |
| `23-Nov-2026-4` | Прежние формы операций, суффиксы типов и прежние фикстуры запуска `Main` относятся к своему корпусу. Прежняя возможность собирать внешние библиотеки вместе с ещё не принятым ядром снята. | [26, включая запуск корня](../../next_core_tasks_v3.md#docs-20261123-4), [грамматика](../../next_core_tasks_v3.md#grammar-complete-20261127), [внешние библиотеки после ядра](../../next_core_tasks_v3.md#after-kernel-20261127) |

<a id="standalone-status"></a>
## Отдельные ТЗ

| Исходный документ | Действующая задача | Историческая норма или написание |
| --- | --- | --- |
| [Assignment is not declaration](assignment_is_not_declaration.en.md) | [M7](../../next_core_tasks_v3.md#m7), [21.17–21.19](../../next_core_tasks_v3.md#uninit-graph-plan) | Числовой код `uninit:T` исторический. В записи хранится TypeRef, payload отсутствует. Группа мест использует обычное `:=`; `.:` пишет в срез с broadcasting. |
| Рабочее состояние [EN](dirty.md), [RU](dirty.ru.md) | [Один граф](../../next_core_tasks_v3.md#one-graph-plan), [явная компиляция](../../next_core_tasks_v3.md#explicit-compilation-plan), [инструменты графа](../../next_core_tasks_v3.md#graph-tools) | Load/cache/dirty, flush, публикация локалов и `implements` в §4 исторические. Действуют один граф, обычный допуск, запись в выбранное место и публикация Message по его договору. |
| [Полный граф, uninit и присваивание](LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md) | [21.17–21.19](../../next_core_tasks_v3.md#uninit-graph-plan), [29.8.2](../../next_core_tasks_v3.md#types-arrays-20261126) | Прежний числовой код типа исторический. Каноническое описание имеет адрес TypeRef, отсутствие полезной нагрузки сохраняется. |
| [Связывание и вызываемые](LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md) | [Связывание](../../next_core_tasks_v3.md#binding-callables-20261119), [K2](../../next_core_tasks_v3.md#k2-20261125) | `fn: name data`, исполняемые `fn/sub`, `fncall`, передача чужого DATA и `implements` исторические. Текущие формы — `Name :: DATA`, `satisfies` и фактический `parent(C)`. |
| [Пустая физическая строка](LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md) | [29.8.1](../../next_core_tasks_v3.md#grammar-p0-20261126), [первый шаг](../../next_core_tasks_v3.md#grammar-first-20261126) | Прежняя обработка пустой строки как пропуска и требование корневого `---` перед ней исторические. Рабочая парная проверка сравнивает графы с избыточным отсекателем и после его снятия. |
| [Аргументы-объявления и import](LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md) | [21.9–21.10](../../next_core_tasks_v3.md#declaration-import-plan) | Сигнатура `fn: name data`, суффиксные типы и старые примеры допуска исторические. Именованное фактическое подаётся через `name := value`. Объявление сохраняет написанное дерево и живой контекст. |
| [Потоки import, copy, merge](LMX_Fable_TZ_Import_Copy_Merge_Field_Streams_2026-11-21.md) | [21.10–21.12](../../next_core_tasks_v3.md#composition-stream-plan), [K2](../../next_core_tasks_v3.md#k2-20261125) | Пометка от 26 ноября о групповом `.:` историческая. Обычное `:=` работает и с `(a b) := copy(Pair)`, и с `(a b) := (copy(Pair))` по своим договорам потребления. Поток и одна явно собранная Structure сохраняют различие. Выбор W/E предшествует эффектам. |
| [Локальные объявления и инициализация](local_declarations_and_explicit_initialization.to_fable.en.md) | [M9](../../next_core_tasks_v3.md#m9), [21.9](../../next_core_tasks_v3.md#declaration-import-plan), [21.17](../../next_core_tasks_v3.md#uninit-graph-plan) | Числовой код `uninit` и суффиксные TYPE исторические. Готовая локальная инициализация, прозрачная запись в место вызывающего и явная запись в граф различаются по выбранному месту. |
| Композиция [основной текст](merge_documentation_corrections.en.md), [уточнения](merge_documentation_corrections_next.en.md) | [21.10–21.12](../../next_core_tasks_v3.md#composition-stream-plan), [композиция](../../next_core_tasks_v3.md#2a-общая-компоновка-кода-и-данных--активный-этап-n1n6) | `fn: name data` и подбор по пробно вычисленному значению исторические. У ТЗ сохраняются поток полей, фактический `parent(C)` и допустимое сохранение ссылки `independent: immutable:`. |
| Изменяющий отладочный API [EN](mutating_debug_API.en.md), [RU](mutating_debug_API.ru.md) | [8b](../../next_core_tasks_v3.md#stage8b-edit-api) | Упоминания `fn: name data`, старого ABI типов и прежней схемы операндов исторические. Четыре действия приложения и десять наблюдений остаются открытой приёмкой. |
| Контракт Message [EN](threadMessageAPI.en.md), [RU](threadMessageAPI.ru.md) | [8a](../../next_core_tasks_v3.md#stage8a) | Написания `implements`, `fn:` и `sub` исторические, в том числе в старых примерах матрицы. T01–T26 переносятся на общую модель вызова с теми же наблюдаемыми исходами. |
| Миграция почты [EN](threadMessageAPI_migration.en.md), [RU](threadMessageAPI_migration.ru.md) | [8a.1 и 8a.5](../../next_core_tasks_v3.md#stage8a) | `sendMessage`/`receiveMessage`, именованный `fn` и `implements` в §4 исторические. Действуют `send`/`receive`, общий слой Message для `post`, обычный допуск и `satisfies`. |
| [Операнды и приоритеты](to_fable_operands_arguments_priorities.md) | [21.13–21.16](../../next_core_tasks_v3.md#operand-preparation-plan), [29.8.4](../../next_core_tasks_v3.md#expression-reference-array) | Шаблон без `depth`, прежние регистрации, `fn:`, `implements`, раскрытие цели ссылки как группы и единая числовая таблица для `prefix`/`infix` исторические. Текущий шаблон передаёт `left, depth, right`. Ссылка при `satisfies = 0` даёт один Array. Строгий `prefix` читает роли без сравнения приоритетов. |
