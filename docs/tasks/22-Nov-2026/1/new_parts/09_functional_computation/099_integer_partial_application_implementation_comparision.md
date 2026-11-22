# 099. General partial-application implementation

Общая реализация partial(F;prefix): произвольная смешанная сигнатура, 0≤k≤N, точный остаточный контракт и исходный return.

**Примеры использования:** [085. Currying](085_currying_comparision.md), [083. Trampoline](083_trampoline_comparision.md)

## Общий сценарий

Исследовать сигнатуру F, принять и сохранить k входных записей, построить callable оставшихся N−k позиций. Захваченные примитивы — снимки значения; ссылочные значения сохраняют идентичность цели. k=0 и k=N допустимы, раннего вызова F нет.

**Ожидаемое наблюдение:** Общий случай сохраняет порядок и типы входов, точный R и объявленные failures. Для клиента сложения результат — 6,101,6. Для N=0 фабрика возвращает nullary callable; для k>N отказ происходит до публикации результата.

Основные варианты: LMX — **текущее ядро**, Haskell — **обобщённая реализация**, Scala — **обобщённая реализация**. Основным считается самый короткий из рассмотренных допустимых алгоритмов текущего контракта; это выбор по символам, а не заявление о большей общности.

При одинаковом размере сохраняется прежний корректный основной вариант. Импорты, объявления и throws входят в подсчёт. Клиенты используют один текущий компонент; исторические специализированные формы остаются пояснением. Смена архитектурного механизма допустима при сохранении всей задачи, полей, эффектов и границы учитываемого кода.

## LMX — основной: текущее ядро

```lmx
FxPartial:
    private:
        @: operation
        @: prefix
    return: @
    partial:
        throws:
            FxArity
            FxIndex
            FxKernelFailure
            FxRecordArity
            FxTypeToken
        private: @: info FxKernel\signature(subject := operation)
        private: @: inputs info\inputTypes
        private: int: n length(inputs)
        private: int: k length(prefix)
        if: k > n
            throw: FxArity()
        private: @: captured FxCapturePrefix\capture(inputs; prefix)
        private: @: remaining FxSlice\slice(inputs; k; n - k)
        private: @: contract FxSignatures\make(remaining; info\resultType)
        private: @: state FxNewState\make(operation; info; captured)
        private: []: char body FxTargetCallText\build(n; k; 0; info\hasResult)
        return: FxBuild\make(contract; body; state; info\throws)
```

Основной листинг — точные определения FxPartial из действующих исходников пакета. Публичные операции являются частью ядра; общие зависимости посчитаны отдельно в [реестре](IMPLEMENTATION_DEPENDENCIES.md). Другая версия библиотеки для этого примера не выбирается. Сам этот фрагмент не объявлен самостоятельной реализацией ядра.

[Основной листинг](examples/lmx/099_integer_partial_application_implementation.lm3)

## Haskell — основной: обобщённая реализация

```haskell
module Partial (partial) where

partial :: (a -> b -> r) -> a -> (b -> r)
partial binary first = \second -> binary first second
```

Haskell2010; клиент компилируется вместе с соседним авторским модулем реализации. Прежний вариант также сохранён ниже; его размер не суммируется с новым.

[Основной листинг](examples/haskell/099_integer_partial_application_implementation.hs)

## Scala — основной: обобщённая реализация

```scala
object Partial {
  def partial[A, B, R](binary: (A, B) => R, first: A): B => R =
    second => binary(first, second)
}
```

Scala 3; клиент использует соседний авторский generic-компонент. Прежний вариант сохранён ниже и исключён из нового подсчёта.

[Основной листинг](examples/scala/099_integer_partial_application_implementation.scala)

## Выбор основного кода и подсчёт

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 605 | 24 |
| Haskell | 101 | 3 |
| Scala | 91 | 4 |

Первичная таблица считает ровно `listings[].code`. Вторые варианты ниже не прибавляются к основным. [Допустимость и выбор алгоритма](variant_selection.json) воспроизводится скриптом. [Реестр зависимостей](IMPLEMENTATION_DEPENDENCIES.md) отдельно показывает, какие компоненты текущего ядра использует клиент и сколько стоит общее ядро новых ресиверов.

## LMX — исторический процедурный пример; вне текущего подсчёта

```lmx
CapturePrototype:
    int: saved 0
    @: binary 0
    inputs:
        int: second
        return: int
        apply:
            return: node\binary(node\saved; second)

Curry:
    @: binary
    int: first
    return: @
    capture:
        @: instance (copy(CapturePrototype))
        @: owner parent(instance\inputs)
        owner\saved := first
        owner\binary := binary
        return: instance\inputs\apply
```

Сохранён исходный поясняющий листинг. Он использует прежний специализированный интерфейс/контейнер; отдельная старая библиотека не входит в текущее единое ядро.

Исторический код сохранён для разбора, но не является другой подключаемой библиотекой и не участвует в выборе алгоритма текущего общего контракта.

Историческая форма сохранена как объяснение исходного алгоритма. Она не объявляется действующей самостоятельной библиотекой или равной по общности заменой текущего ядра.

Новые реализации доступны также в [LMX_Fn_Receivers](../LMX_Fn_Receivers/README.md). Исторический специализированный пример не ограничивает текущий общий API ядра.

## Haskell — исторический специализированный пример; вне текущего подсчёта

```haskell
module CurryInt (capture) where

capture :: (Int -> Int -> Int) -> Int -> (Int -> Int)
capture binary first = \second -> binary first second
```

Сохранён исходный поясняющий листинг. Он использует прежний специализированный интерфейс/контейнер; отдельная старая библиотека не входит в текущее единое ядро.

Исторический код сохранён для разбора, но не является другой подключаемой библиотекой и не участвует в выборе алгоритма текущего общего контракта.

## Scala — исторический специализированный пример; вне текущего подсчёта

```scala
object CurryInt {
  def capture(binary: (Int, Int) => Int, first: Int): Int => Int =
    second => binary(first, second)
}
```

Сохранён исходный поясняющий листинг. Он использует прежний специализированный интерфейс/контейнер; отдельная старая библиотека не входит в текущее единое ядро.

Исторический код сохранён для разбора, но не является другой подключаемой библиотекой и не участвует в выборе алгоритма текущего общего контракта.

## Семантические границы

**Честная граница сравнения.** Показана реализация partial, а не только вызов готовой фабрики: текущий LMX-код проверяет длину префикса, сохраняет аргументы и строит остаточный callable. Общая граница с Haskell/Scala — произвольные типы двух аргументов и результата при захвате первого; LMX дополнительно поддерживает N аргументов, и эта более широкая возможность не объявляется бесплатной или эквивалентной бинарному контракту. Общие тела построителя и эффекты раскрыты в реестре; исторический int-only capture сохранён как пояснение.

**Основной LMX.** Показан реальный алгоритм partial из src/generic_functions.lmx. Он использует общие анализ сигнатуры, capturePrefix, построение DATA/graph и обычный generated call; ни число аргументов, ни тип результата не зашиты. Все вызываемые общие helpers перечислены и посчитаны в IMPLEMENTATION_DEPENDENCIES.md. Интерфейсы ядра являются требованиями интеграции, а не готовым проверенным бинарником.

**Наблюдаемый общий сценарий.** Остаточные позиции принимаются явно и не запускаются досрочно из-за default-значений. capture не удерживает произвольное динамическое окружение фабрики. Глубокое клонирование ссылочных графов, авто-компиляция и новый persistent cache не добавлены. Для полностью связанных аргументов сохраняется отложенный nullary вызов.

**Возможности общего ядра.** Остаточные позиции принимаются явно и не запускаются досрочно из-за default-значений. capture не удерживает произвольное динамическое окружение фабрики. Глубокое клонирование ссылочных графов, авто-компиляция и новый persistent cache не добавлены. Для полностью связанных аргументов сохраняется отложенный nullary вызов.

Универсальный набор новых ресиверов может делать больше специализированного компактного примера. В частности, Maybe/Bounce общего пакета хранят произвольные записи, bracket не фиксирует R, partial принимает произвольный смешанный префикс. Сравнение символов не приравнивает дополнительные возможности к нулевой стоимости. Прямой record-API сообщает FxCallFailure с исходным именем внутри; основной пример bracket проверяет этот договор явно.

## English explanation

General partial(F;prefix): an arbitrary heterogeneous signature, 0≤k≤N, exact residual contract and original return.

**Usage examples:** [085. Currying](085_currying_comparision.md), [083. Trampoline](083_trampoline_comparision.md)

**Scenario.** Reflect F, admit and retain k input records, then build a callable for the remaining N−k positions. Captured primitives are snapshots; references retain target identity. k=0 and k=N are valid and F is not invoked early.

**Expected observation.** The general case retains input order/types, exact R and declared failures. The addition client yields 6,101,6. N=0 produces a nullary callable; k>N fails before publishing a result.

Primary is the shortest eligible complete current-contract algorithm for each language. Its imports, declarations and throws are included. The complete historical listing stays adjacent and is excluded from the primary count. Specialized historical implementations do not satisfy the full generalized current contract. There is one current component implementation; historical specialized code is not offered as another library dependency.

**Primary LMX.** The actual partial algorithm is taken from src/generic_functions.lmx. It uses shared signature analysis, capturePrefix, DATA/graph construction and an ordinary generated call; arity and result type are not hardwired. Shared helpers are listed and measured in IMPLEMENTATION_DEPENDENCIES.md. Kernel interfaces are integration requirements, not a tested binary.

**Current core implementation.** The actual partial algorithm is taken from src/generic_functions.lmx. It uses shared signature analysis, capturePrefix, DATA/graph construction and an ordinary generated call; arity and result type are not hardwired. Shared helpers are listed and measured in IMPLEMENTATION_DEPENDENCIES.md. Kernel interfaces are integration requirements, not a tested binary.

No execution of LMX or the control programs is claimed.

## Источники / Sources

- [Haskell 2010 Report, expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html) — Функциональное применение, лямбда и лексически сохранённое значение.
- [Scala Tour, Higher-order Functions](https://docs.scala-lang.org/tour/higher-order-functions.html) — Функция как вход и создаваемая лямбда; готовый Function2.curried в этой паре не используется.

**Норма LMX:** [семантика](../../LMX_semantics.en.md), [грамматика](../../LMX_grammar.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

[Проверка вариантов и публикации](VALIDATION_2026-11-22.md) отделяет статические сверки от фактического исполнения. [ТЗ интеграции](../../tasks/TZ_Receivers_Satisfies_2026-11-22.md) описывает требуемую поддержку новых общих ресиверов.
