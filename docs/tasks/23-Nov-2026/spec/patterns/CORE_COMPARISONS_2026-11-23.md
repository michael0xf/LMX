# Текущая редакция сравнений и функций ядра

**23 ноября 2026 года.** Основа — только заново загруженный автором `spec.tar.gz`.

Точный SHA-256 исходного архива: `4b142bab169cf7cc3fd89766da35b90561f913b68dca3ab1f0725793e4ecb932`. Сопоставление файлов и патчи строятся с этой основой, а не с предыдущей сгенерированной версией.

## Что изменено

1. Сохранены сравнения самостоятельных реализаций LMX и контрольных языков. Иностранные клиенты переведены на настоящие библиотеки или собственные средства языка.
2. LMX-клиенты используют прямые функции ядра. Общий каталог, exports, исходники и нормативное описание согласованы; публичные имена имеют lowerCamelCase.
3. Обобщены контейнеры и callable-адаптеры, раскрыты отказы, пустые случаи и владение. Асинхронная политика реализована через Message/post, а не скрытую shared-state очередь.
4. Полные варианты оставлены для существенно разных подходов. Однострочные изменения и копии того же основного кода заменены пояснениями.
5. Добавлены отдельные наборы Julia и Perl в examples, общий реестр исходников и статистика всей директории. Счётчики клиентов не смешиваются с реализациями.
6. Для Fable приложены точные preimages, source/generated patches и проверяющий трёхстороннее слияние инструмент.

## Единый список дополнений

Сохранены 115 прежних вызовных имён. Сейчас каталог содержит **123** имён; ниже перечислены добавления. [Полный список](../CORE_FUNCTIONS.md) включает все функции, а не только новые.

| Новое имя | Договор | Исходник |
| --- | --- | --- |
| `findFirst(items; accepts)` | first accepted typed element as some(record), none for absence; ordered short-circuit over dense Arrays and Structures | [coreComparisonGroups.lmx](LMX_Fn_Receivers/src/coreComparisonGroups.lmx) |
| `allOf(predicates; contract=0)` | arbitrary finite predicate composition with a shared ordered signature, preserved input places and short-circuit; empty set requires an explicit contract | [coreComparisonGroups.lmx](LMX_Fn_Receivers/src/coreComparisonGroups.lmx) |
| `equalFields(first; second; same)` | ordered sequence/field equality with explicit typed comparator; unequal lengths are false, empty equal lengths are true; no implicit deep graph equality | [coreComparisonGroups.lmx](LMX_Fn_Receivers/src/coreComparisonGroups.lmx) |
| `retryPost(request; retryOn; attempts; delay; firstDelay; maxDelay; timeoutMs; complete)` | Message-owned bounded retry with saturated backoff, transport timeout and policy cancellation; persistent terminal result and late-reply draining | [coreComparisonGroups.lmx](LMX_Fn_Receivers/src/coreComparisonGroups.lmx) |
| `between(left; right)` | prepared operand for inclusive ordered bounds; exactly two right values, ordinary actual comparison types and the priority of <= | [coreComparisonExamples.lmx](LMX_Fn_Receivers/src/coreComparisonExamples.lmx) |
| `iterateUntilStop(iteration; body)` | execute accepted declaration DATA and associated body in their receiving activation; source Stop terminates, other declared exits retain name/payload in FxCallFailure; requires AE01 | [coreComparisonExamples.lmx](LMX_Fn_Receivers/src/coreComparisonExamples.lmx) |
| `sort(items; compare)` | stable nonmutating generic merge sort; three-way int comparator; fresh outer array preserving source profile and element identity; empty/singleton supported; callback failure does not modify input | [corePerlExamples.lmx](LMX_Fn_Receivers/src/corePerlExamples.lmx) |
| `unique(items; same)` | stable first-occurrence uniqueness with explicit typed equality predicate; fresh outer array preserving source profile and element identity; empty/singleton supported; callback failure does not modify input | [corePerlExamples.lmx](LMX_Fn_Receivers/src/corePerlExamples.lmx) |

## Существенные границы реализации

`bracket` регистрирует охраняемый finally до приобретения ресурса и освобождает его только после успешного acquire. Это закрывает промежуток между исходными операторами; атомарность передачи ресурса внутри нативного attempt не объявляется уже реализованной. Haskell mask/restore и приоритеты исключений Scala описаны отдельно.

`lazy` и `once` проверяют повторный вход, публикуют первый успешный результат, сбрасывают Busy после неудачи и устанавливают cleanup до перехода в Busy. Это состояние одного Message; разделяемый межпоточный cache не подразумевается.

`iterateUntilStop` выполняет принятую декларацию и тело в принимающем исполнении. Узкий provider AE01 — attemptAccepted — сохраняет происхождение принятой позиции и живые места. Поиск по внутреннему имени декларации и выбор по совпадению указателя запрещены. AR01 — acceptsRequirement — даёт внутреннее наблюдение существующей совместимости без исполнения пользовательского кода. Доказанные 1/0 отделены от неизвестного результата и не добавляют булев ABI публичному satisfies. Вместе с 17 ранее описанными входами это **19 интеграционных интерфейсов**, отдельно от пользовательских операторов. Четыре прежних булевых использования satisfies в Regex исправлены.

`retryPost` не теряет итог при недоставленной нотификации; он доступен через read. Таймаут и cancel останавливают политику новых попыток, но не обнуляют ожидания поздних ответов и не разрешают преждевременно уничтожать арену.

## Где смотреть результат

- [Клиенты и девять сравнений реализаций](LIBRARY_COMPONENTS.md).
- [Все примеры, включая Julia и Perl](examples/README.md), [их статистика](examples/STATISTICS.md).
- [Общая статистика паттернов](STATISTICS_2026-11-22.md). Дата в имени сохраняется для старых ссылок; внутри указана текущая редакция.
- [Проверки функциональной группы](09_functional_computation/VALIDATION_2026-11-23.md).
- [Интеграционные требования ядра](LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md).
- [Как Fable проверить и применить изменения](../../fable_merge/README.md).

Окончательные машинные отчёты отделяют фактически выполненные проверки от подготовленных случаев NOT_RUN. В этом архиве не поставляется компилятор/интерпретатор LMX; генерация документов и статические проверки не доказывают runtime-корректность.
