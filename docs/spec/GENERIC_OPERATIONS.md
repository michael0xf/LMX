# Общие операции, единые имена и профили данных

Нормативный контракт: каждая применимая операция стандартной библиотеки имеет ресиверную и операндную формы под одним каноническим именем. Они используют общий алгоритм, действительные аргументные роли, полный результат и конечный договор ошибок.

Подробный код описывает общие построители, сравнение, Pattern и профили данных. Исполняемые определения находятся в общей библиотеке; наличие описания и исходника не заменяет runtime-приёмку (**NOT_RUN**).

Связанные разделы: [монадические операции](MONADIC_OPERATIONS.md), [общее равенство](GENERIC_EQUALITY.md), [формы всех операций](OPERATION_FORMS.md). Последний раздел распространяет аудит также на типообъявляющие, управляющие и системные ресиверы; существующий P0 уже допускает их в Expression.

## 1. Обязательные правила

1. **Одно значение операции — одно основное имя.** Обычная запись `name(a; b)` и запись операндом `a name b` используют один алгоритм. Если прежний операнд и прежний ресивер уже делают одно и то же, их свести к этому имени.
2. **Прежние имена не оставлять вызываемыми.** Не нужны алиасы, устаревшие экспорты, совместимые обёртки или скрытые вторые входы. Старое имя допустимо в таблице миграции и объяснении истории; код, импорты, тесты и основные примеры переводятся целиком.
3. Новые словесные имена имеют форму `lowerCamelCase`; приоритет у привычного осмысленного имени исходной операции. Существующие символьные имена сохраняются и доступны как точные идентификаторы в обратных кавычках. Для монад установлено имя **`bind`**.
4. «Для всех типов» означает все значения, для которых определён данный контракт. Обобщённый обход не навязывает `int` пользовательскому элементу. Декодирование текста, целочисленное деление и объявление типа сохраняют свою осмысленную область; общий механизм над ними принимает соответствующий профиль.
5. Все ресиверы, включая объявляющие типы, входят в аудит двух форм. Их TYPE/NAME/DATA-роли сохраняются, а типовые объявления не превращаются в обычные VALUE-callback. Запрос типа и построение сигнатуры имеют собственные контракты.
6. Использовать существующие `OPERANDS_TEMPLATE`, подготовленные записи значений, гомоиконность, адаптивные преобразования актора и динамическое связывание. Не копировать тела библиотечных операций в примеры.
7. Сохранять истинные входные и выходные требования, идентичность ссылок, порядок эффектов и полные `throws`. `@: value` само по себе не означает «произвольное значение любого типа»: различать значение и ссылку на его запись.

Для снятия повторений важны оба уровня: общий алгоритм в библиотеке и общий адаптер способов вызова. Две короткие декларации разных форм допустимы; два одинаковых алгоритма обхода — нет.

## 2. Общие механизмы и исходная инвентаризация

Историческое состояние в этом подразделе объясняет происхождение унификации. Окончательные публичные имена и их договоры установлены далее и в [текущем каталоге](patterns/LMX_Fn_Receivers/CATALOG.md); прежние экспорты не являются действующим API.

| Область | Проверенное состояние | Изменение |
| --- | --- | --- |
| Монады | Обычные `bind`, `bindResult`, `flatMap` есть в обеих версиях. В старом примере 091 есть инфиксный `MaybeOps\bind`. | Единое семейство `bind`; код и миграция в разделе монадических операций. |
| Общий переход к операнду | `FxAsOperand\asOperand` уже существует в [coreStandardLisp.lmx](patterns/LMX_Fn_Receivers/src/coreStandardLisp.lmx). | Переиспользовать построитель; не создавать по адаптеру с собственным алгоритмом на каждую операцию. |
| Pattern | `then` уже вызывает последовательную композицию; примитивы и источники ограничены текстом. | Одна общая композиция для любых допустимых Pattern; обе формы назвать `then`. |
| Подготовка значения | `FxCaptureOne`, `FxRecordOperands\record`, `FxBuild`, `FxSignatures` уже есть. | Общий адаптивный вход из раздела монадических операций. |
| Рефлексия | Есть `sys\typeof`, `types`, `names`, `signature`, `signatureTypes`. | Добавить `type` как удобный запрос фактического типа; не дублировать рефлексию. |
| Публичный `type` | В проверенных `src/public.lmx` и каталоге обеих версий не найден. | Это добавляемый вход, а не утверждение о ранее готовой функции. |
| Сигнатуры | `Name :: DATA` уже обозначает именованную сигнатуру; `signatureTypes` строит описание по TYPE-токенам. | Не менять смысл `::`. Добавить короткую ориентацию «вход `to` результат», переиспользовав построитель сигнатур. |
| Сравнение | Есть `FxValueSame`, `equalFields`, `FxSequenceDifference`, `wholeMatch`. | Один выбор сравнения и один проход по диапазонам; отдельный `sameText` не вводить. |
| Последовательности | Большинство `FxSeq*` уже работает с фактическими профилями Array. | Сохранить типизированное чтение/запись; обобщать найденные ограничения, а не стирать всё до `@[]`. |

Основания: [public.lmx](patterns/LMX_Fn_Receivers/src/public.lmx), [CATALOG.md](patterns/LMX_Fn_Receivers/CATALOG.md), [containers.lmx](patterns/LMX_Fn_Receivers/src/containers.lmx), [fn_operand.lmx](patterns/LMX_Fn_Receivers/src/fn_operand.lmx), [regex/operands.lmx](patterns/LMX_Fn_Receivers/src/regex/operands.lmx).

### 2.1. Проверять равенство контрактов, а не только похожий результат

Два имени объединяются, если совпадают область входов, порядок вычисления, семантика результата, ошибки и действительные эффекты. Различие обычной упаковки аргументов и `left/right` устраняется общим входным адаптером.

`bind` для Maybe, Result и последовательностей — перегрузки одного связывания по семейству контейнера. `then` для Pattern — последовательная композиция распознавателей и не становится монадическим `bind` только из-за похожей английской формулировки.

Специализированная политика с наблюдаемым отличием не объявляется синонимом. Например, «повторять только ошибку HTTP 503» и «повторять по переданному предикату» отличаются контрактом политики; первую следует выразить аргументом общей операции и убрать локальный повтор алгоритма.

### 2.2. Полный исходный перечень публичных операций

Ниже историческая инвентаризация исходной редакции **23-Nov-2026 до унификации**: `src/public.lmx` содержал **212 экспортов**. Таблица сохраняет происхождение операций, а не действующие прежние callable-имена. Полный актуальный перечень находится в [каталоге](patterns/LMX_Fn_Receivers/CATALOG.md); каждый дополнительный экспорт подчиняется тому же договору двух форм, ролей, результатов и ошибок.

| Источник | Исходные публичные имена |
| --- | --- |
| [reflection.lmx](patterns/LMX_Fn_Receivers/src/reflection.lmx) | `types` |
| [reflection_bridges.lmx](patterns/LMX_Fn_Receivers/src/reflection_bridges.lmx) | `names`, `signature`, `rename` |
| [fn_operand.lmx](patterns/LMX_Fn_Receivers/src/fn_operand.lmx) | `signatureTypes` |
| [generic_functions.lmx](patterns/LMX_Fn_Receivers/src/generic_functions.lmx) | `curry`, `partial`, `uncurry`, `flip`, `record` |
| [generic_runtime.lmx](patterns/LMX_Fn_Receivers/src/generic_runtime.lmx) | `apply` |
| [generic_combinators.lmx](patterns/LMX_Fn_Receivers/src/generic_combinators.lmx) | `compose`, `pipe`, `identity`, `memoize`, `fix`, `adapter`, `permute`, `overload`, `predicate`, `guard`, `contract` |
| [collections.lmx](patterns/LMX_Fn_Receivers/src/collections.lmx) | `map`, `filter`, `foldl`, `zip`, `zipWith`, `scanl`, `traverse`, `transpose`, `groupBy` |
| [containers.lmx](patterns/LMX_Fn_Receivers/src/containers.lmx) | `bind`, `some`, `none`, `ok`, `err`, `bindResult`, `list`, `flatMap`, `done`, `more`, `trampoline` |
| [structures.lmx](patterns/LMX_Fn_Receivers/src/structures.lmx) | `select`, `omit`, `reorder`, `project`, `defaults`, `diff`, `patch`, `bindFields`, `derive`, `composeData` |
| [generic_wrappers.lmx](patterns/LMX_Fn_Receivers/src/generic_wrappers.lmx) | `lazy`, `force`, `once`, `repeat`, `runUntil`, `retryCall`, `bracket`, `recover`, `trace` |
| [sequences.lmx](patterns/LMX_Fn_Receivers/src/sequences.lmx) | `range`, `slice`, `reverse`, `concat`, `compress`, `any`, `all`, `index`, `count` |
| [sequences_mutation.lmx](patterns/LMX_Fn_Receivers/src/sequences_mutation.lmx) | `replaceRange`, `splice`, `append`, `insert`, `deleteAt` |
| [regex/primitives.lmx](patterns/LMX_Fn_Receivers/src/regex/primitives.lmx) | `literal`, `oneOf`, `noneOf`, `charRange`, `satisfy`, `boundaryOf`, `sameAs` |
| [regex/combinators.lmx](patterns/LMX_Fn_Receivers/src/regex/combinators.lmx) | `sequence`, `choice`, `repeated`, `atomic`, `capture`, `ahead`, `notAhead`, `behind`, `notBehind` |
| [regex/text.lmx](patterns/LMX_Fn_Receivers/src/regex/text.lmx) | `utf8Text`, `byteText` |
| [regex/operations.lmx](patterns/LMX_Fn_Receivers/src/regex/operations.lmx) | `matchAt`, `wholeMatch`, `find`, `eachMatch`, `contains`, `hasPrefix`, `hasSuffix`, `matches`, `matchedSpan`, `matchedText`, `captureSpans`, `lastCapture`, `captureText`, `captureTexts`, `replaceFirst`, `replace`, `split` |
| [regex/operands.lmx](patterns/LMX_Fn_Receivers/src/regex/operands.lmx) | `then`, `times`, `atLeast`, `atMost`, `optional` |
| [coreComparisonGroups.lmx](patterns/LMX_Fn_Receivers/src/coreComparisonGroups.lmx) | `findFirst`, `allOf`, `equalFields`, `retryPost` |
| [coreComparisonExamples.lmx](patterns/LMX_Fn_Receivers/src/coreComparisonExamples.lmx) | `between`, `iterateUntilStop` |
| [corePerlExamples.lmx](patterns/LMX_Fn_Receivers/src/corePerlExamples.lmx) | `sort`, `unique` |
| [coreStandardFunctional.lmx](patterns/LMX_Fn_Receivers/src/coreStandardFunctional.lmx) | `take`, `drop`, `splitAt`, `takeWhile`, `dropWhile`, `span`, `partition`, `enumerate`, `windows`, `chunks`, `intersperse`, `intercalate`, `unzip`, `foldr`, `scanr`, `filterMap`, `mapWhile`, `findMap`, `mapAccumL`, `mapAccumR`, `groupAdjacent`, `replicate`, `cycle`, `starmap`, `zipLongest`, `collect`, `includes`, `adjoin`, `union`, `intersection`, `difference`, `symmetricDifference`, `isSubset` |
| [coreStandardObjects.lmx](patterns/LMX_Fn_Receivers/src/coreStandardObjects.lmx) | `mapOption`, `filterOption`, `orElse`, `orElseGet`, `orElseOption`, `foldOption`, `flattenOption`, `mapResult`, `mapErr`, `orElseResult`, `foldResult`, `attempt`, `tap`, `findField`, `hasField`, `getField` |
| [coreStandardLisp.lmx](patterns/LMX_Fn_Receivers/src/coreStandardLisp.lmx) | `assoc`, `pairlis`, `getProperty`, `setProperty`, `removeProperty`, `getProperties`, `asOperand`, `mismatch`, `searchSequence`, `substitute` |
| [coreStandardText.lmx](patterns/LMX_Fn_Receivers/src/coreStandardText.lmx) | `indexOf`, `lastIndexOf`, `compareText`, `trim`, `trimStart`, `trimEnd`, `repeatText`, `padLeft`, `padRight`, `translate`, `join`, `formatInt`, `parseInt`, `removePrefix`, `removeSuffix` |
| [coreStandardNumeric.lmx](patterns/LMX_Fn_Receivers/src/coreStandardNumeric.lmx) | `sum`, `product`, `minimum`, `maximum`, `argMin`, `argMax`, `extrema`, `min`, `max`, `minMax`, `clamp`, `sign`, `gcd`, `lcm`, `divMod` |

Для каждого экспорта зафиксировать: основной алгоритм, роли аргументов, полный результат, `throws`, обычную форму, операндную форму и решение об имени. Отсутствие изменения тела у уже общего ресивера — нормальный результат проверки; отсутствие второй формы — незавершённая публикация.

Дополнительно пройти внутренние операнды `PipeLibrary`, `FindLibrary`, `SpecificationLibrary`, `MoneyLibrary`, `RetryLibrary`, `FxBetween`, `FxRecordOperands`, `FxSignatureOperand`, `RxThenOperand`, `RxRepeatOperands`. Их не видно целиком по одной таблице публичных имён.

## 3. Один механизм двух форм

### 3.1. Значения: использовать готовый asOperand

Существующий `FxAsOperand` получает callable и приоритет. Он извлекает действительную сигнатуру, строит обычный узел с `left/right`, собирает логические аргументы через `RxLogicalArguments` и вызывает ту же операцию. Результат и конечный набор ошибок сохраняются. Входы не должны превращать целый Array в набор случайных аргументов.

Ниже общий **библиотечный контейнер двух представлений**, а не новое ключевое слово. Он хранит настоящий обычный callable и построенный операнд; указатели присваиваются после `copy`.

```lmx
FxOperationForms:
    @: call 0
    @: operand 0

FxForms:
    private:
        @: operation
        int: priority
    required: operation priority
    return: @
    make:
        throws: copy(FxThrows\selection)
        private: @: forms (copy(FxOperationForms))
        forms\call := operation
        forms\operand := FxAsOperand\asOperand(operation; priority)
        return: forms
```

Построитель применяется один раз при подготовке библиотечного контекста, до группировки выражений, использующих полученный операнд. Дублировать его для `map`, `foldl`, `sort`, `unique`, `slice` и других обычных операций не требуется.

```lmx
StandardForms:
    const: @: unique FxForms\make(FxUnique\unique; sys\priority("+"))
```

Этот фрагмент показывает создание записей `FxOperationForms`. `StandardForms\unique` — **описание двух входов**, не автоматически исполнимая замена публичного `unique`. Реальные публичные формы подключаются по следующему пункту. Для специальных принимающих ролей, например `type`, далее дан собственный точный вход, который переиспользует общий захват значения.

<a id="32-публикация-под-одним-именем-и-пересечение-перегрузок"></a>
### 3.2. Публикация под одним именем и пересечение перегрузок

Общая цель — `unique(xs)` и `xs unique`, `bind(m; f)` и `m bind f`, `type(x)` и `x type`. Две одинаковые `const: @: bind ...` в одном пространстве эту задачу не решают.

В проверенной семантике [выбор объявления](LMX_semantics.en.md#declaration-selection) учитывает все допустимые кандидаты. Не задано предпочтение «уже обычная функция», «более узкая Structure», «первое объявление» или «больше подходящих полей». Поэтому нельзя объявить готовой глобальную публикацию, которая держится на выдуманном предпочтении.

Конкретное пересечение: Maybe представлен Structure, а Structure является Array. Обычный `bind(m; f)` может подходить и общей Array-перегрузке. При смешивании обычных и операндных DATA возникает дополнительное пересечение `input/next` с `left/right`. Одного различия меток недостаточно для всех позиционных вызовов.

**Обязательный контракт подключения двух представлений:**

1. В явно доступном библиотечном/акторном контексте операция публикуется как одно семейство с обычным и операндным представлениями. Синтаксическая роль обращения выбирает соответствующее представление именно этого объявленного семейства; затем действует обычный выбор допустимого объявления.
2. Для `bind` и других операций с несколькими семантическими семействами контекст сохраняет выбранное полное требование/представление входа. Известный Maybe направляется в Maybe-семейство, известный Result — в Result, явно выбранный последовательностный контракт — в Array. Общее физическое хранение не заменяет этот контракт.
3. Если данных о представлении недостаточно или два семантических семейства действительно допустимы, сохранить обычную неоднозначность и возможность явного квалифицированного выбора. Не исполнять пробный callback, конвертер, инициализатор или тело для угадывания семейства.
4. Само построение `FxOperationForms` не реализует эти правила. В реализации сначала найти соответствующий существующий путь разрешения ролей/контекста. Если такого подключения нет, реализовать его как **общую явно описанную возможность публикации семейства** и отразить в семантике. Не заявлять, что это поведение уже доказано редакцией 23-Nov.
5. Правило не даёт скрытого приоритета двум несвязанным одноимённым пользовательским объявлениям. Старые имена операций не используются как обход неоднозначности.

Конкретные алгоритмы и отдельные формы в этом разделе можно перенести независимо; завершённость публичного API проверяется только после подключения обеих форм и разрешения этих пересечений. Дополнительный List-контейнер ради отличия от Array не нужен.

### 3.3. Роли, которые нельзя смешивать

| Роль | Что передаётся | Общий путь |
| --- | --- | --- |
| Значение целиком | Одно принятое значение с действительным типом | Захват типизированной записи и обычное принятие. |
| Callable | Настоящая операция с её владельцем, сигнатурой и динамическим контекстом | Существующие `FxApply`/`FxTry` либо прямой типизированный вызов. |
| TYPE | Полное требование типа, включая модель, квалификации, Array и ссылки | `normalizeType` и построитель сигнатуры; не выдавать число кода за адрес. |
| DATA/NAME | Объявление, поле или имя с существующей семантикой | Соответствующий штатный принимающий путь. |
| Отложенный CODE/выражение | Исходное выражение с исходным живым контекстом | Существующий raw/accepted-form путь; не превращать его заранее в значение. |
| Цель мутации | Прежняя цель записи/ссылка, а не её оторванная копия | Сохранить правила записи, преобразования и ошибок. |

Генератор `asOperand` в режиме 0 — общий путь для принимаемых значений. Он не подменяет управление потоком, отложенное тело `iterateUntilStop`, действие `bracket` или TYPE-параметр только тем, что записан через `@`.

Для raw-форм сохранить `PASS_ARGS_AS_IS 1` и существующий `sys\eval`. Один явный запуск `eval` исполняет выражение один раз; несколько запусков могут повторять эффекты. Динамические имена разрешаются по исходному действующему контексту. Перенос в библиотеку не должен захватывать их случайными служебными полями.

Основания: [prepared operands](LMX_semantics.en.md#prepared-operands), [raw operands](LMX_semantics.en.md#raw-operands), [expression eval](LMX_semantics.en.md#expression-eval), [conversion context](LMX_semantics.en.md#conversion-context), [AE01 и AR01](patterns/LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md).

### 3.4. Произвольное расположение операнда

В языке общий шаблон `left/right`; отдельного типа «префиксный операнд» вводить не надо. Если контракт допускает отсутствие `left`, один и тот же готовый операнд может принимать `(myOp 1 2 3 4 5)` и `(1 myOp 2 3 4 5)`.

Расположение не меняет число логических аргументов и не вводит автоматическое повторное раскрытие вложенных Arrays. Отсутствующий `left` не заменяется `0`, `null` или случайным одноимённым полем динамического окружения. Для операций с обязательным левым входом обычная форма `name(...)` остаётся второй формой API; левопустое написание не обещается без подходящего контракта.

## 4. Сопоставление с Scala и Haskell; код недостающих входов

| Исходная запись | Смысл | Основное имя LMX и обычная форма | Операндная форма | Решение |
| --- | --- | --- | --- | --- |
| Scala `.flatMap(f)`, Haskell `>>=` | Применить продолжение, возвращающее контейнер того же семейства, и связать результат на один уровень | `bind(m; f)` | `m bind f` | Уже есть алгоритмы; объединить имена и формы. |
| Haskell `x :: T` | Аннотация типа | Существующее объявление `T: x` | Не вводить второй смысл LMX `::` | `type(x)` — отдельный запрос фактического типа, а не эквивалент статической аннотации. |
| Запрос фактического типа | Узнать действительный код типа значения | `type(x)` | `x type` | Добавить общий вход поверх `sys\typeof`. |
| Haskell `A -> B` | Тип функции со входом A и результатом B | `to(A; B)` | `A to B` | Добавить короткий вход к существующему построителю сигнатуры. |
| LMX `return:` | Описание результата в DATA либо возврат из CODE | Сохранить | Сохранить | Это не новый синоним операции `to`. |

`flatMap` имеет смысл отображения со снятием одного уровня; не требуется реально создавать промежуточный `Some(Some(...))`. См. [Scala Option](https://www.scala-lang.org/api/current/scala/Option.html). Аннотация типа и стрелка типа функции различаются в [Haskell 2010, declarations and bindings](https://www.haskell.org/onlinereport/haskell2010/haskellch4.html).

### 4.1. Общий type

`FxValueType` принимает внутреннюю готовую запись значения. Публичный вход `type(x)` захватывает **одно значение целиком** через тот же контекст принятия значений, что описан для `some(x)`. Тело запроса не копирует механизм определения типа.

```lmx
FxValueType:
    private: @: value
    required: value
    return: int
    type:
        return: sys\typeof(value)

FxTypeOperand:
    copy: FxPreparedOperands
    const: int: PRIORITY sys\priority("+")
    required: left right
    return: int
    type:
        throws: FxRecordArity
        return: FxValueType\type(
            value := FxRecordOperands\record(left := left; right := right)
        )
```

`FxRecordOperands\record` уже проверяет единственность значения: операнд `x type` получает один `left` и пустой `right`. Публичный вызов `type(x)` не передаёт произвольное число в `@` как адрес. Для `T = @` также нужен захват самой ссылочной записи, включая `type(null)`.

Полный фактический код берётся из `sys\typeof` по действующим правилам: сохраняются вид элемента Array и глубина ссылки. Имя произвольной пользовательской модели Structure не создаёт отдельный физический код. Поэтому обещать, что `type(x)` восстанавливает любую семантическую модель, нельзя.

Адаптер конструкторов из раздела монадических операций использует сигнатуру конструктора со ссылочным результатом. Его нельзя механически вызвать с `FxValueType\type`, который возвращает `int`. Общий вход `VALUE → готовая запись` переиспользуется, а `int` возвращается настоящим `FxValueType` без стирания результата до `@`. Финальный список ошибок публичного входа включает ошибки фактически достигнутого захвата/построения.

### 4.2. Общий to

Операция принимает упорядоченные TYPE-токены; последний — результат, предыдущие — входы. Поэтому `to(A; B)` и `A to B` означают один вход A и результат B. `to(A0; A1; B)` и `A0 to A1 B` означают два входа; `to(B)` — сигнатуру без входов. Каждый написанный TYPE-токен остаётся целым, включая структурное требование.

Существующий алгоритм нормализации и построения сигнатуры остаётся в `FxSignatureOperand\make`. Убрать публичный alias `signatureTypes` и перевести его вызовы на `to`, с результатом в последней позиции. Слово `yields` как второй синоним не вводить.

```lmx
FxToTypes:
    private:
        @[]: inputs
        @: result
    required: inputs result
    return: @
    to:
        throws: copy(FxThrows\selection)
        return: FxSignatureOperand\make(
            left := result;
            right := inputs
        )

FxToTokens:
    private: @[]: tokens
    required: tokens
    return: @
    to:
        throws: FxArity copy(FxThrows\selection)
        if: length(tokens) = 0
            throw: FxArity()
        private: int: last length(tokens) - 1
        private: @[]: inputs FxSeqSlice\slice(tokens; 0; last)
        return: FxToTypes\to(inputs := inputs; result := tokens[last])

FxToOperand:
    copy: FxPreparedOperands
    const: int: PRIORITY sys\priority("+")
    required: left right
    return: @
    to:
        throws: FxArity copy(FxThrows\selection)
        return: FxToTokens\to(
            tokens := RxLogicalArguments\collect(left := left; right := right)
        )
```

У `to(A; B)` обе позиции имеют роль TYPE. Обычный публичный адаптер передаёт в `FxToTokens` вектор полных записей написанных токенов; операнд получает их через уже существующий сборщик. Это одна нормализация и один построитель сигнатуры.

Операнд `to` в приведённом объявлении требует левый TYPE-токен. Сигнатура без входов доступна обычным `to(B)`. Дополнительная левопустая запись `(to B)` потребует отдельного защищённого входа по общему правилу раздела 3: отсутствующий `left` не должен заполняться одноимённым полем вызывающего контекста.

Внутренний именованный вход `FxToTypes\to(inputs := typeRecords; result := resultToken)` остаётся для библиотечного кода. Он не является вторым прежним именем. Не складывать его и `FxToOperand` в пространство как неразличённые позиционные overload: подключить представления по разделу 3.

`A to B` создаёт описание сигнатуры; не вызывает функцию и не выполняет `return`. `Name :: DATA` остаётся именованной сигнатурой. Прежнее `B signatureTypes A0 A1` мигрирует в `A0 to A1 B`, а не в ту же последовательность токенов с заменённым словом. Для результата, который сам является сигнатурой, использовать явные скобки: `A to (B to C)`. Общие правила однократного открытия RHS не меняются.

### 4.3. bind

Полный код — в [монадических операциях](MONADIC_OPERATIONS.md). Здесь обязательна миграция прежних `bindResult` и `flatMap` в `bind` соответствующего семейства. Старые публичные имена удаляются; внутренние методы также получают единое имя `bind`. Сами тела связывания не копируются.

Для Array результат существующего алгоритма — новый `@[]` с фактическими записями элементов. Он соединяет результаты продолжения ровно на один уровень. Это не обещание сохранить плотный профиль входного массива.

## 5. Один общий проход сравнения

В [общем равенстве](GENERIC_EQUALITY.md) определён общий `FxValueSame`: явный comparator либо обычное сравнение фактических значений; вложенные конечные ациклические Arrays идут через `equalFields`. Этот выбор использовать во всех перечисленных ниже операциях.

Вместо ещё одного обхода текста расширить уже существующий `FxSequenceDifference` двумя независимыми начальными позициями. Его первые пять позиций сохраняют существующий порядок; шестая — `secondStart` с нулём по умолчанию.

<a id="51-диапазоны"></a>
### 5.1. Диапазоны

```lmx
FxSequenceDifference:
    private:
        @: first
        @: second
        @: same 0
        int: firstStart 0
        int: count
        int: secondStart 0
    required: first second count
    return: int
    find:
        throws: copy(FxThrows\predicate)
        FxSeqInfo\get(first)
        FxSeqInfo\get(second)
        if: firstStart < 0 || secondStart < 0 || count < 0
            throw: ReceiverIndex()
        if: firstStart > length(first) || secondStart > length(second)
            throw: ReceiverIndex()
        if: count > length(first) - firstStart || count > length(second) - secondStart
            throw: ReceiverIndex()
        private: int: i 0
        while: i < count
            if: FxValueSame\test(
                FxSeqRead\read(first; firstStart + i);
                FxSeqRead\read(second; secondStart + i);
                same
            ) = 0
                return: i
            i += 1
        return: -1

FxEqualFields:
    private:
        @: first
        @: second
        @: same 0
    required: first second
    return: int
    equalFields:
        throws: copy(FxThrows\predicate)
        FxSeqInfo\get(first)
        FxSeqInfo\get(second)
        if: length(first) != length(second)
            return: 0
        return: FxSequenceDifference\find(
            first := first;
            second := second;
            same := same;
            count := length(first)
        ) < 0
```

`-1` здесь — внутренний результат «несовпадение не найдено». Он не подменяет публичный Maybe. Пустой диапазон равен пустому; недопустимые границы порождают ошибку. Проверки через `length - start` избегают переполнения суммы до проверки.

`FxEqualFields` использует этот диапазонный алгоритм, как установлено также в [общем равенстве](GENERIC_EQUALITY.md). В итоговом коде остаётся один полный обход пары диапазонов — `FxSequenceDifference`. `unique`, вложенное равенство, поиск последовательности, литеральный Pattern и обратные ссылки используют его. Текст с точным сравнением тоже не получает второй цикл.

### 5.2. Общий поиск элемента

Для `oneOf`, `noneOf` и прежнего поиска символа использовать уже существующий `FxKeyIndex`. Элемент может быть числом, строкой, вложенным Array, Structure или ссылкой; `int` относится только к позиции и результату предиката. Полное обобщение существующего тела — необязательный `same = 0` при сохранении поиска ключей с `stride/field`:

```lmx
FxKeyIndex:
    private:
        @: source
        @: key
        @: same 0
        int: stride 1
        int: field -1
    required: source key
    return: int
    find:
        throws: copy(FxThrows\predicate) FxShape
        private: int: size FxKeyShape\count(source; stride)
        private: int: i 0
        while: i < size
            private: @: candidate FxSeqRead\read(source; i)
            private: int: usable 1
            if: field >= 0
                FxSeqInfo\get(candidate)
                if: length(candidate) = 0
                    usable := 0
                else:
                    candidate := FxSeqRead\read(candidate; field)
            ---
            if: usable != 0
                if: FxValueSame\test(key; candidate; same) != 0
                    return: i
            ---
            i += stride
        return: -1
```

Это замена прежнего определения `FxKeyIndex`. `includes`, распознавание класса и бывший `FxCharIndex` используют его. Для обычного списка значений остаются `stride = 1` и `field = -1`. Порядок аргументов пользовательского comparator — ключ, затем текущий элемент; он сохранён. Нового параллельного `FxElementIndex` нет.

`wholeMatch` распознаёт Pattern по всей длине источника; это иной контракт, чем обычное равенство данных. Точное текстовое равенство можно выразить существующим буквальным Pattern, но не следует добавлять `sameText` с ещё одним алгоритмом. Сравнение без регистра, нормализация Unicode или доменная эквивалентность требуют явно выбранного comparator/профиля.

## 6. Pattern над произвольными данными

### 6.1. Где находится текстовое ограничение

В исходном текстовом профиле [regex/support.lmx](patterns/LMX_Fn_Receivers/src/regex/support.lmx) `Pattern` прежде принимал `RxPreparedText@`. В [regex/primitives.lmx](patterns/LMX_Fn_Receivers/src/regex/primitives.lmx) литералы и классы принимают `char[]`, предикат — `int`. Это были ограничения входа и источника; сами последовательная композиция, выбор, повторение, захват и возврат к альтернативам работают через курсор и кандидатов.

В обобщении общий Pattern получает источник с последовательностью **типизированных единиц** и отдельным профилем. Для Array единица — целый элемент исходного Array. Для текста единица — результат существующего декодирования, а профиль сохраняет текст и отображение позиций в байтовые границы.

Не переписывать движок как отдельные «text regex» и «array regex». Поменять входные требования и общие примитивы; оставить один курсор, один журнал захватов и один порядок кандидатов.

### 6.2. Полный код общего источника и двух адаптеров

`TextView`, `RxPreparedText` и текстовый декодер остаются внутри текстового профиля. Единственная общая сигнатура `Pattern` использует `RxPreparedSource`, как в коде ниже.

```lmx
RxSourceDomain:
    @: literalUnits 0

RxPreparedSource:
    @: view 0
    @: units 0
    RxSourceDomain@: domain 0
    @: profile 0

Pattern :: (RxPreparedSource@: source; int: position; @: captures; return: @)

ArrayView:
    @: items 0

RxArrayProfile:

RxArrayView:
    private: @: items
    required: items
    return: @
    arrayView:
        throws: copy(FxThrows\kernel)
        FxSeqInfo\get(items)
        private: @: view (copy(ArrayView))
        view\items := items
        return: view

RxSourceMake:
    private:
        @: view
        @: units
        RxSourceDomain@: domain
        @: profile
    required: view units domain profile
    return: @
    make:
        private: @: source (copy(RxPreparedSource))
        source\view := view
        source\units := units
        source\domain := domain
        source\profile := profile
        return: source

RxArrayLiteralUnits:
    private:
        @: value
        @: profile
    required: value profile
    return: @
    make:
        throws: copy(FxThrows\kernel)
        FxSeqInfo\get(value)
        return: value

RxTextLiteralUnits:
    private:
        @: value
        RxPreparedText@: profile
    required: value profile
    return: @
    make:
        throws: copy(FxThrows\sequence) PatternArgument PatternEncoding
        private: char[]: text \value
        private: @: prepared RxTextBuild\make(text; profile\profile)
        return: prepared\units

RxArrayDomain:
    @: literalUnits RxArrayLiteralUnits\make

RxTextDomain:
    @: literalUnits RxTextLiteralUnits\make

RxArrayPrepare:
    private: ArrayView@: source
    required: source
    return: @
    make:
        throws: copy(FxThrows\kernel)
        FxSeqInfo\get(source\items)
        return: RxSourceMake\make(
            source;
            source\items;
            RxArrayDomain;
            RxArrayProfile
        )

RxTextPrepareSource:
    private: TextView@: source
    required: source
    return: @
    make:
        throws: copy(FxThrows\sequence) PatternArgument PatternEncoding
        private: @: text RxPrepare\make(source)
        return: RxSourceMake\make(source; text\units; RxTextDomain; text)
```

`units` у Array указывает на исходную типизированную последовательность; преобразование всех элементов в `int` или все плотные Arrays в `@[]` не выполняется. `int position` — координата, а не тип содержимого. Пустой `RxArrayProfile` — явное состояние профиля, а не отсутствие источника.

`arrayView(xs)` — обычный вход значения целиком по разделу 3. Внутренний `RxArrayView` получает готовую запись Array. `utf8Text` и `byteText` продолжают выбирать текстовые профили. Автоматическое удобное преобразование голого Array допустимо только в однозначном контексте источника; не распознавать произвольную Structure по нескольким случайно совпавшим полям.

Для других доменов — токенов, записей, узлов дерева — используются те же конечные последовательности либо свой явный адаптер источника с тем же контрактом. Приведённый код реализует индексируемый конечный источник; поддержку бесконечных потоков, графовых циклов и иных координат нельзя приписать ему без отдельного контракта.

### 6.3. Литерал произвольной последовательности

Конструктор хранит одну исходную запись, а источник определяет её единицы. В текстовом профиле выполняется прежнее декодирование; в Array-профиле сравниваются целые элементы.

```lmx
RxLiteral:
    private: @: value
    required: value
    return: @
    literal:
        return: RxPrimitiveMake\make(RxLiteralProbe\probe; value)

RxLiteralProbe:
    private:
        @: payload
        RxPreparedSource@: source
        int: position
        @: captures
    return: int
    probe:
        throws: copy(FxThrows\predicate) SequenceSize PatternArgument PatternEncoding
        private: @: prepare source\domain\literalUnits
        private: @: part prepare(value := payload; profile := source\profile)
        private: int: count length(part)
        if: count > length(source\units) - position
            return: -1
        if: FxSequenceDifference\find(source\units; part; 0; position; count) >= 0
            return: -1
        return: position + count
```

Предусловие `probe`: позиция проверена общим `RxOpen` и находится в `[0, length(units)]`. Публичный вход не должен обходить эту проверку. Пустой литерал успешно сопоставляется с нулевой длиной; это не None.

`literal(xs)` означает блок элементов. Один вложенный Array остаётся целым элементом, если он находится в одноэлементном внешнем блоке. Произвольное одиночное значение без ручной упаковки принимает общий конструктор `element`.

```lmx
RxElement:
    private: @: value
    required: value
    return: @
    element:
        return: RxPrimitiveMake\make(RxElementProbe\probe; value)

RxElementProbe:
    private:
        @: payload
        RxPreparedSource@: source
        int: position
        @: captures
    return: int
    probe:
        throws: copy(FxThrows\predicate)
        if: position = length(source\units)
            return: -1
        if: FxValueSame\test(FxSeqRead\read(source\units; position); payload) = 0
            return: -1
        return: position + 1
```

У `element(x)` также нужен единичный захват фактического значения: значение-ссылка не превращается в её цель, а Array не раскрывается.

Обобщённый `literal` переносит проверку совместимости литерала с выбранным доменом к моменту сопоставления, потому что при создании Pattern источник ещё не выбран. Это наблюдаемое изменение времени ошибки и должно быть указано в документации. Если существующий типизированный текстовый вход должен сохранять раннюю проверку, его адаптивное представление проверяет `char[]` до общей фабрики, без отдельного распознавателя и без старого имени-алиаса.

### 6.4. Предикат над настоящим элементом

Сначала проверить настоящую сигнатуру предиката без исполнения тела. Требуется один вход произвольного допустимого типа и результат `int`. Проверка общая для `satisfy` и `boundaryOf`; поэтому неверный callable отвергается и при пустом источнике.

```lmx
FxUnaryPredicate:
    private: @: operation
    required: operation
    return: @
    check:
        throws: copy(FxThrows\selection) FxArity
        private: @: shape FxKernel\signature(operation)
        if: length(shape\inputTypes) != 1
            throw: FxArity()
        if: shape\hasResult = 0
            throw: FxTypeToken()
        private: @: integerType FxKernel\normalizeType(
            FxAllOfTypeToken\integer[0]
        )
        if: \shape\resultType != \integerType
            throw: FxTypeToken()
        return: operation

RxSatisfy:
    private: @: predicate
    required: predicate
    return: @
    satisfy:
        throws: copy(FxThrows\selection) FxArity
        return: RxPrimitiveMake\make(
            RxPredicateProbe\probe;
            FxUnaryPredicate\check(predicate)
        )

RxPredicateProbe:
    private:
        @: payload
        RxPreparedSource@: source
        int: position
        @: captures
    return: int
    probe:
        throws: copy(FxThrows\predicate)
        if: position = length(source\units)
            return: -1
        private: @: item FxSeqRead\read(source\units; position)
        private: @: accepted FxApply\apply(payload; FxOne\make(item))
        if: FxSeqPredicate\truth(accepted) = 0
            return: -1
        return: position + 1
```

Предикат принимает настоящий тип целого элемента. Результат проверяет единственный `FxSeqPredicate`; ошибка типа предиката не выдаётся за несовпадение. Ошибка callback также не становится `-1`.

### 6.5. Общие oneOf и noneOf

Список допустимых единиц готовит выбранный домен; тест членства общий. Проверка списка выполняется до проверки конца источника, сохраняя прежний порядок ошибок неверного текстового литерала.

```lmx
RxClassConfig:
    @: values 0
    int: inverted 0

RxClassMake:
    private:
        @: values
        int: inverted
    required: values inverted
    return: @
    make:
        private: @: config (copy(RxClassConfig))
        config\values := values
        config\inverted := inverted
        return: RxPrimitiveMake\make(RxClassProbe\probe; config)

RxMembers:
    private: @: values
    required: values
    return: @
    oneOf:
        return: RxClassMake\make(values; 0)
    noneOf:
        return: RxClassMake\make(values; 1)

RxClassProbe:
    private:
        RxClassConfig@: payload
        RxPreparedSource@: source
        int: position
        @: captures
    return: int
    probe:
        throws: copy(FxThrows\predicate) FxShape SequenceSize PatternArgument PatternEncoding
        private: @: prepare source\domain\literalUnits
        private: @: values prepare(value := payload\values; profile := source\profile)
        if: position = length(source\units)
            return: -1
        private: @: item FxSeqRead\read(source\units; position)
        private: int: found FxKeyIndex\find(values; item) >= 0
        if: found = payload\inverted
            return: -1
        return: position + 1
```

Используется единственный помощник поиска из раздела 5.2; отдельного цикла поиска символов нет.

### 6.6. Общая композиция then: оба входа, один алгоритм

Последовательная композиция экспортируется как `then` и реализуется единственным `RxSequence\then`. Обе формы обращаются к тому же телу:

```lmx
RxSequence:
    private: @: patterns
    required: patterns
    return: @
    then:
        throws: copy(FxThrows\kernel)
        private: @: config RxPartsPrepare\prepare(patterns := patterns)
        if: length(config\parts) = 0
            return: emptyPattern
        if: length(config\parts) = 1
            return: config\parts[0]
        return: RxPatternFactory\make(RxSequenceOpen\open; config)

RxThenOperand:
    private:
        @: left
        @[]: right
    required: right
    const: int: PASS_ARGS_AS_IS 0
    const: int: PRIORITY sys\priority("+")
    return: @
    then:
        throws: FxKernelFailure FxTypeToken PatternArgument
        private: @: args RxLogicalArguments\collect(left := left; right := right)
        if: length(args) < 2
            throw: PatternArgument()
        return: RxSequence\then(patterns := args)
```

В обычной форме сохранить договор `0/1/N` Patterns: ноль даёт `emptyPattern`, один возвращает этот Pattern. Операнд сохраняет проверку минимум двух логических аргументов. Общий публичный адаптер собирает обычные аргументы в единственный `patterns`-вектор и сохраняет функцию по её настоящему владельцу.

`RxPartsPrepare` и `RxNormalize` должны принимать уже готовый `Pattern` и явно выбранный литеральный вход любого поддержанного домена. Проверка принадлежности Pattern выполняется существующим структурным принятием/AR01, без пробного вызова Pattern. При нескольких допустимых ролях сохраняется явный выбор, а не догадка по структуре данных.

### 6.7. Остальные изменения движка

Это обязательная карта переноса уже существующего кода; тела обхода не нужно копировать в документацию или переписывать отдельно по типу данных.

| Файл / узлы | Требуемая замена |
| --- | --- |
| `regex/support.lmx`: `RxPatternOwner\Call\open`, `RxOpen`, фабрики `Span`/`Match` | Обязательно заменить входы на `RxPreparedSource`. Иначе новая сигнатура `Pattern` будет противоречить настоящему callable, который возвращает фабрика. |
| `regex/combinators.lmx` | Заменить узкие аргументы `RxPreparedText@: source` на `RxPreparedSource@: source`. Сохранить порядок ветвей, кадров и кандидатов. |
| `regex/primitives.lmx` | Перенести общий `RxPrimitiveOpen` на новый источник; подключить приведённые probe. |
| `regex/values.lmx` | Общие `emptyPattern`, `neverPattern`, «любой элемент», начало и конец используют единый заголовок Pattern. Убрать повторные специализированные заголовки. |
| `Span` и `Match` | Общая ссылка на исходный view и подготовленный источник; координаты соответствуют его единицам. Текстовый профиль сохраняет таблицу байтовых смещений. |
| `sameAs` | Сравнивать текущий диапазон и захваченный диапазон через `FxSequenceDifference`, передав оба смещения. |
| `boundaryOf` | Проверять общий предикат единицы по обе стороны; край источника и отсутствие единицы не смешивать с нулевым значением. |
| `within` | Общий упорядоченный тест через профиль сравнения и преобразования границ; текстовый диапазон является доменной настройкой. Имя отличается от конструктора последовательности `range`. |
| `matchAt`, `wholeMatch`, `find`, `eachMatch`, `contains`, `hasPrefix`, `hasSuffix` | Один публичный вход источника через общий подготовитель; прежний результат/порядок совпадений сохраняется. |
| `matchedValue`, `captureValue`, `captureValues` | Общее извлечение фрагмента: текстовый профиль возвращает текст, Array-профиль — соответствующий Array. |
| `replaceFirst`, `replace`, `split` | Общая сборка источника через его профиль; текст не теряет кодировку, Array — требования элементов и разрешённый профиль результата. |

Для AST один узел поступает в `satisfy` целиком. Рекурсивный Pattern может сопоставить `arrayView(children)` тем же движком. При объединении захватов из разных источников нужен явный источник/путь координаты; нельзя просто смешать два числовых интервала в одном журнале.

Сохранить защёлку завершения курсора, существование успеха нулевой длины, защиту повторения от отсутствия продвижения и неизменяемость уже опубликованного журнала захватов. В `REGEX_IMPLEMENTATION.md` предусмотрен прозрачный проброс исходных callback-ошибок через конечные сигнатуры и общий шлюз. Внутренний `FxCallFailure` из приведённого `probe` должен проходить этот установленный публичный путь, а не менять контракт regex на «только оболочка ошибки».

## 7. Обобщение остальных узких библиотечных операций

Ниже обязательные изменения после инвентаризации. Это не исключения из требования двух форм: у каждого результирующего имени должны быть обычный вход и операнд. Уже общие операции используют механизм раздела 3 без копирования своих тел.

### 7.1. Текст и последовательности

| Текущая область | Общий контракт и место единственного алгоритма |
| --- | --- |
| `indexOf`, `lastIndexOf` | Поиск блока элементов в Array с `same = 0`; один общий `FxSequenceDifference`. Сохранить начальную позицию, направление, пустой образец и `-1` при отсутствии. |
| `searchSequence` | Тот же поиск, но установленный публичный результат — Maybe позиции. Это наблюдаемое отличие от `indexOf`; общим должен быть проход, а не насильственная замена результата. |
| `compare` | Лексикографическое сравнение по профилю элементов. Текстовый профиль сохраняет существующее сравнение беззнаковых байтов; пользовательский порядок явно передаётся. |
| `trim`, `trimStart`, `trimEnd` | Общий поиск границ по множеству элементов либо predicate. Удалить `FxCharIndex`; использовать `FxKeyIndex`/общий предикат и существующий `slice`. Текстовый набор пробелов — профиль по умолчанию только текста. |
| `padLeft`, `padRight` | Общие `cycle`, `slice` и `concat` с фактическим профилем результата. Пустой заполнитель при требуемом расширении — прежняя ошибка. Для произвольного T пробел не является универсальным default. |
| `translate` | Одна одновременная замена целого элемента по первой подходящей позиции таблицы. Поиск общий; результат проходит принятие целевого профиля. Не заменять её последовательными переписываниями уже заменённого результата. |
| `join` | Одно имя для обеих форм и всех Arrays; единственный алгоритм вставки разделителя и соединения. Пустой разделитель определяется явным профилем/требованием результата. |
| `cycle` | Политика отрицательного числа задаётся параметром `rejectNegative` общего алгоритма. Код ниже. |
| `removePrefix`, `removeSuffix` | Общий диапазонный comparator и `slice`; неизменность источника и отсутствие совпадения сохранить. |
| `format` / `parse` | Типизированные профили кодирования/разбора. Точный целочисленный алгоритм — одна реализация профиля; генераторы имён используют тот же `format`. |

Текстовое преобразование вида «без учёта регистра» не включается молча. Кодировка, нормализация, разбиение на байты/кодовые точки и порядок сравнения задаются профилем. Наличие общего прохода не делает эти разные контракты взаимозаменяемыми.

### 7.2. cycle без второго текстового тела

`cycle` возвращает пустую последовательность при неположительном числе повторений. Политика `rejectNegative` сохраняет возможность явного отказа для отрицательного числа в том же алгоритме:

```lmx
FxStdCycle:
    private:
        @: items
        int: count
        int: rejectNegative 0
    required: items count
    return: @
    cycle:
        throws: copy(FxThrows\sequence)
        if: rejectNegative != 0 && count < 0
            throw: SequenceSize()
        private: @: info FxSeqInfo\get(items)
        if: count <= 0 || length(items) = 0
            return: FxSeqEmpty\make(items)
        if: count > info\maxLength / length(items)
            throw: SequenceSize()
        return: FxSeqConcat\concat(FxStdReplicate\replicate(items; count))
```

Прежний вызов `repeatText(text; n)` мигрирует в `cycle(text; n; rejectNegative := 1)`, если требуется сохранить его отрицательную границу. Это один дополнительный аргумент политики, не копия реализации. При доказанном неотрицательном n используется `cycle(text; n)`. Публичное текстовое представление сохраняет результат `char[]` через точное требование, а не выдаёт пользователю служебную ссылку на запись.

### 7.3. Числа и упорядоченные значения

`sum`, `product`, `minimum`, `maximum`, `argMin`, `argMax`, `extrema`, `min`, `max`, `minMax`, `clamp` и `sign` проверить на фактические требования элементов. Не сужать готовые общие реализации обратно к `int` ради одинакового примера.

`gcd`, `lcm` и `divMod` используют точную целочисленную арифметику. Общий контракт принимает тип/профиль с нужными операциями деления и остатка; дробным или произвольным объектам не приписывается такой профиль автоматически. Пределы, знак остатка и округление остаются частью договора.

`range` принимает явный профиль шага и порядка с полузакрытыми границами. Точный целочисленный вход — профиль по умолчанию. В профиле задаются проверка нулевого/непродвигающего шага, допустимое направление, построение следующего значения, предел длины и представление элемента. Для точного целочисленного профиля сохранить текущий предварительный подсчёт длины в `bigint` и проверку `maxLength`. Для округляемой арифметики отдельно проверить фактическое продвижение; не обещать завершение цикла только по положительности написанного шага.

`between` уже сравнивает подготовленные значения с границами через общие операции. Его не нужно размножать на отдельные версии для каждого числа. Общие типы сравнения должны поддерживаться как в обычном вызове, так и в операнде.

### 7.4. Составление и применение функций

В исходной редакции 23-Nov-2026 `FxPipe\pipe` создавал композицию двух функций, вызывая `compose` с обратным порядком аргументов, а демонстрационный `PipeLibrary\pipe` немедленно проводил `int` через стадии. Эти разные действия получили самостоятельные канонические имена.

Действующий контракт:

- **`compose`** строит функцию; обе формы используют текущий `FxCompose`. Старый вызов `pipe(first; second)`, создававший функцию, становится `compose(outer := second; inner := first)`. Прежнего перенаправляющего тела и callable-псевдонима нет.
- **`pipe`** применяет последовательность стадий к исходному значению. Полезное значение и результаты стадий имеют их фактические типы; каждая стадия получает целую запись предыдущего результата. Операнд и обычный вызов используют одну реализацию в [coreGenericOperations.lmx](patterns/LMX_Fn_Receivers/src/coreGenericOperations.lmx).
- Если стадии меняют тип, построитель готового `pipe` извлекает итоговое требование последней стадии и использует существующий `FxWrap`. Универсальная внутренняя ссылка на запись не должна стать ложным публичным типом результата `@`.

Динамическая связь свободных имён сохраняется через промежуточные библиотечные вызовы. Нельзя переписать этот механизм в локальную лексическую копию только из-за привычек другого языка.

### 7.5. Предикаты, поиск, доменные значения и повторные попытки

| Найденный узкий пример | Перенос |
| --- | --- |
| `SpecificationLibrary\Operators\both` над двумя `int`-предикатами | Перевести в общий `allOf`; обе формы используют существующий построитель общей сигнатуры и короткое замыкание. `both` удалить. Для пустого набора требуется явный контракт. |
| `FindLibrary` с `int id` | Использовать общий `findFirst` с фактическим типом ключа и явной проекцией/предикатом. Тело прохода не оставлять в локальном примере. |
| `MoneyLibrary\Equality\equals` | Общее `equals` принимает значения и выбранную проекцию/эквивалентность. Денежный профиль сравнивает `cents` и `currency`, а не все физические поля Structure. |
| `equalFields` | Сохраняет точный договор длины и упорядоченных полей; использует раздел 5. Прямой вызов на всей Money-структуре не эквивалентен сравнению двух избранных полей. |
| `RetryLibrary\retry` | Обобщить тип результата и условия повторения через явные predicate/delay/limit; профиль HTTP 503 становится настройкой этой политики. Не ограничивать общий результат `int`. |
| `retryCall` | Сохраняет установленный повтор объявленных исключений и фактический успешный результат; общий механизм эффектов/ошибок не заменяется проверкой кода 503. |
| `retryPost` | Сохраняет асинхронный Message job, timeout, завершение и владение состоянием. Это не синоним синхронного `retryCall`. |

Для `equals` использовать существующий `FxValueSame` и явную проекцию, без ещё одного рекурсивного сравнения. Для применения нескольких предикатов и компараторов — общий вызов фактических записей. Проекция и callback не вычисляются повторно только для проверки подходящей перегрузки.

## 8. Таблица обязательной миграции имён

Эта таблица задаёт переход от исходных имён, перечисленных в аудите, к окончательному API. Прежние имена нужны в документации истории и миграции; в итоговом коде они не остаются callable.

| Прежнее имя / действие | Итоговое имя | Изменение вызова и контракта |
| --- | --- | --- |
| `bindResult` | `bind` | Выбрать Result-семейство; алгоритм тот же. |
| `flatMap` | `bind` | Выбрать Array/последовательностное семейство; снять ровно один уровень. |
| `sequence` для Pattern | `then` | Сохранить обычную арность 0/1/N и установленную арность операнда. |
| `signatureTypes` | `to` | Перенести TYPE результата в последнюю позицию; входы сохраняют порядок. |
| `both` из примера предикатов | `allOf` | Снять ограничения двух `int`-предикатов; использовать общий построитель. |
| `pipe`, создававший композицию | `compose` | Явно переставить аргументы `outer := second; inner := first`. `pipe` остаётся только применением стадий. |
| `intercalate` | `join` | Общие последовательности и точный профиль результата; один алгоритм вставки разделителя. |
| `repeatText` | `cycle` | При сохранении старого отрицательного случая передать `rejectNegative := 1`. |
| `compareText` | `compare` | Общий профиль сравнения; прежний текстовый порядок сохранён его профилем. |
| `formatInt`, `parseInt` | `format`, `parse` | Целочисленный профиль остаётся точным; новые типы подключаются своими профилями. |
| `charRange` | `within` | Pattern допустимого диапазона значений по выбранному порядку. |
| `anyChar` | `anyElement` | Одна произвольная единица источника. |
| `textStart`, `textEnd` | `start`, `end` | Границы общего источника. |
| `matchedText` | `matchedValue` | Фрагмент в профиле исходных данных. |
| `captureText`, `captureTexts` | `captureValue`, `captureValues` | Один или несколько захваченных фрагментов своего источника. |

`times`, `atLeast`, `atMost`, `optional` и `repeated` — разные установленные параметры/контракты повторения, а не старые алиасы одного и того же вызова. Каждая операция получает обе формы и делегирует одному движку. `repeat`, исполняющий callback, также не является Pattern-`repeated`.

При миграции обновить:

1. Декларации и публичные экспорты.
2. Все внутренние вызовы и именованные actuals.
3. Импорты и таблицы обычных/операндных представлений.
4. Строки генерируемого LMX внутри `FxBuild` и других построителей.
5. Документацию, каталог, примеры сравнений, фикстуры и ожидаемые результаты.

В исходниках после миграции не остаются прежние определения, ссылки, разрешающие fallback или тесты старых alias. Историю переименования хранить в документации миграции, не поддерживать её отдельным кодом.

## 9. Исключения и компактные примеры

Полные `throws` остаются в узле. Общие списки ошибок не превращаются в скрытое `throws any`. Возможность увидеть, какие ошибки порождает метод, считаю преимуществом LMX; сокращать эту часть ради победы в количестве символов не требуется.

Повторяемый список задаётся один раз:

```lmx
Throws:
    FxIndex
    FxArity
    FxRecordArity
    FxTypeToken
    FxKernelFailure
    FxCallFailure
    ReceiverIndex
    SequenceSize
```

Использование остаётся обычным `throws: copy(Throws)`. Для конкретного узла состав списка обязан соответствовать достигнутым вызовам; приведённый список не универсальная замена всех ошибок Pattern, predicates или mutation.

В функциональных сравнениях публикуются две полные LMX-формы одного наблюдаемого договора: процедурная с явными циклами, ветвлениями и изменением данных и функциональная с общими операциями, Expression и короткими адаптивными входами. Каждая форма использует уместную краткую запись своего стиля; исходники, Markdown и статистика содержат обе формы. Единое библиотечное тело не копируется ради двух клиентов. Если неизменяемый низкоуровневый договор допускает только одну минимальную форму, один исходник и один блок публикуются с явным обоснованием и двумя равными показателями.

Для `SBCL_comparison` использовать возможности общего Expression. Где уместно, LMX-пример может иметь Lisp-подобное расположение `(myOp 1 2 3 4 5)`; допустимое `(1 myOp 2 3 4 5)` остаётся применением того же шаблона. Это не новый отдельный вид операторов.

Статистика считает полный исходник каждого стиля: все аргументы Throws, обработчики и полные ссылки `throws: copy(target\throws)` остаются в счёте. Списки копируются из фактически вызываемых методов; для перегрузки указывается выбранный source-handler либо явное конечное объединение применимых договоров, а не первая случайная ветвь семейства. Общая норма [доступа к договору операции](OPERATION_FORMS.md#operation-contract-throws) распространяется и на системные ресиверы. В XLS/PDF зелёным выделяются минимальные полные значения в сопоставимой строке, включая равные минимумы; сокращённой статистической колонки Throws нет.

## 10. Приёмка

### 10.1. Имена, покрытие и отсутствие дублей

- Для каждого из 212 исходных экспортов и каждого нового экспорта есть решение о каноническом имени, общем алгоритме, принимающих ролях и двух формах.
- Типообъявляющие, системные и управляющие ресиверы входят в аудит с сохранением их действительных ролей; сложность обработки не служит основанием пропустить определение.
- Старых callable-имён из таблицы миграции нет. Переименование обновило также сгенерированный исходный текст и внутренние вызовы.
- В общей библиотеке один алгоритм каждого обхода. `equalFields`, `unique`, поиск, литерал и backreference используют согласованное сравнение; отдельного `sameText` нет.
- Для каждого результирующего обычного ресивера есть операнд; для каждого исходного операнда есть обычный вход. У обоих одно основное имя.

### 10.2. Формы и типы

| Проверка | Требуемое наблюдение |
| --- | --- |
| Две формы | При одинаковых принятых аргументах совпадают результат, тип, ошибки и эффекты; различие разрешённой арности явно описано. |
| Общий шаблон | Проверены допустимые левопустые и непустые `left`; условное раскрытие RHS происходит ровно по действующей норме. |
| Скаляры/Arrays/Structure/ссылки | Подготовка не теряет фактический тип, вложенность и идентичность; элемент остаётся одним аргументом. |
| Адаптивный вход | Пользователю не нужны ручной `record`, объявление типа для каждой разновидности или локальная копия адаптера. |
| Перегрузки | Проверены Maybe/Result/Array-пересечения, callable как Structure, TYPE-токен как Structure; нет выбора по порядку объявления. |
| Контекст | Свободные имена работают через чужую функцию по динамической цепочке; служебные поля не подменяют исходное окружение. |
| Мутация | Цель записи остаётся исходной целью; копия значения не выдаётся за ссылку на цель. |
| TYPE | `type` не совпадает по смыслу с `types`, `Name :: DATA` или `return`. `to` принимает полные токены и не открывает внутреннюю модель как список входов. |
| Генерация | `PASS_ARGS_AS_IS`, `PRIORITY` и настоящая сигнатура готовы до группировки/эффектов; `parent` у callable сохранён. |

### 10.3. Pattern и общие профили

Проверить одинаковыми сценариями текст, плотный числовой Array, Array строк, смешанную Structure, ссылки и Array узлов. Нужны пустой источник, нулевой литерал, None и успешный нулевой Match, альтернативы с возвратом, повторение без продвижения, captures и `sameAs`.

Для текста отдельно проверить Unicode/байтовые профили и исходные смещения; для Arrays — целостность вложенного элемента и требования результата `replace/split`. Неверный predicate должен отвергаться при построении `satisfy`, в том числе перед сопоставлением с пустым источником. Неверный литерал проверяется в документированной фазе.

Для `times`, `atLeast`, `atMost`, `optional` и `repeated` сохранить границы и порядок кандидатов. Нельзя считать семантически одинаковыми `times(p; n)` и `repeated(p; minimum := n)`.

### 10.4. Режимы исполнения и статусы

После переноса выполнить проверки интерпретатор/интерпретатор, интерпретатор/native, native/интерпретатор, native/native, где эти пути поддержаны проектом. Проверка Markdown, поиск имён или построение графа не заменяют исполнение.

До этого момента статус примеров и описанных определений — **NOT_RUN**. В доступной редакции отдельные точки AR01/AE01 и публичный шлюз ошибок regex описаны как требования к реализации; приведённая спецификация не превращает их автоматически в работающий runtime.

## 11. Порядок интеграции общих механизмов

1. Фактические владельцы и все действующие экспорты перечисляются в текущем каталоге; новые операции проходят тот же полный аудит.
2. Канонические имена соответствуют таблице миграции; совместимые aliases отсутствуют.
3. Публикация связывает обычную и операндную формы с общими принимающими ролями и явным контекстом семантического семейства.
4. Конструкторы и `bind` используют общий адаптер значений; `type` сохраняет собственный результат `int`, `to` — полные TYPE-токены.
5. Сравнение, источники Pattern и движки общие; текстовые и числовые правила находятся в их явных профилях.
6. Изменение реализации сопровождается обновлением каталога, коротких примеров и проверкой наблюдений приёмки.

Единое ядро использует общий библиотечный код на LMX, две формы каждого установленного имени, полные контракты узлов и клиентские примеры без повторяющейся обвязки.
