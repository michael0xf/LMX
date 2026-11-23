# 083. Trampoline

Взаимные even/odd шаги используют общий Bounce с nullary continuation, созданной partial.

**Соседнее сравнение реализации:** [092. Trampoline container and runner implementation](092_trampoline_container_and_runner_implementation_comparision.md), [099. General partial-application implementation](099_integer_partial_application_implementation_comparision.md)

## Общий сценарий

Для неотрицательного n определить чётность. Незавершённый шаг возвращает more(partial(другой_шаг; (n−1))) без вызова другого шага. trampoline вызывает по одному сохранённому thunk до done.

**Ожидаемое наблюдение:** 0 → true, 1 → false, 100001 → false; LMX возвращает 1, 0, 0. Каждый шаг возвращает управление драйверу; вложенная цепочка вызовов even/odd не накапливается.

Основные варианты: LMX — **общий алгоритм шага**, Haskell — **обобщённая реализация**, Scala — **обобщённая реализация**. Основным считается самый короткий из рассмотренных допустимых алгоритмов текущего контракта; это выбор по символам, а не заявление о большей общности.

При одинаковом размере сохраняется прежний корректный основной вариант. Импорты, объявления и throws входят в подсчёт. Встроенные операции принадлежат одному текущему ядру; полный локальный helper допустим, когда сохраняет прикладной сценарий и включён в подсчёт. Исторические публикации остаются пояснением. Смена архитектурного механизма допустима при сохранении всей задачи, полей, эффектов и границы учитываемого кода.

[Объявления выходов, обработчики и граница примера](FAILURE_BOUNDARIES.md#trampoline).

## LMX — основной: общий алгоритм шага

```lmx
Steps:
    int: n
    return: @
    Throws:
        FxIndex
        FxArity
        FxRecordArity
        FxTypeToken
        FxKernelFailure
        FxCallFailure
        ReceiverIndex
        SequenceSize
    code:
        throws: copy(Throws)
        if: n = 0
            return: done(value := (x record))
        return: more(thunk := partial(next; (n - 1)))
    even_step:
        throws: copy(Throws)
        int: x 1
        @: next odd_step
        return: code()
    odd_step:
        throws: copy(Throws)
        int: x 0
        @: next even_step
        return: code()
    Example:
        int: n
        return: int
        run:
            throws: copy(Throws)
            return: \trampoline(even_step(n))
```

Общий алгоритм шага находится в Steps\code; even_step и odd_step задают локальные x и next, доступные по динамическому связыванию. Throws содержит список выходов один раз, четыре copy(Throws) входят в подсчёт. Входы: Steps\Example\run(0), Steps\Example\run(1), Steps\Example\run(100001). Выходы передаются вызывающему; это не корневой обработчик Message. [Разыменование и catch](FAILURE_BOUNDARIES.md#trampoline).

Тела используемых компонентов показаны рядом: [092. Trampoline container and runner implementation](092_trampoline_container_and_runner_implementation_comparision.md), [099. General partial-application implementation](099_integer_partial_application_implementation_comparision.md). Это описание текущего компонента, а не выбор версии библиотеки. Общая инфраструктура ядра раскрыта в реестре зависимостей.

[Основной листинг](examples/lmx/083_trampoline.lm3)

## Haskell — основной: обобщённая реализация

```haskell
module TrampolineExample where
import Bounce (Bounce, done, more, run)

evenStep, oddStep :: Int -> Bounce Bool
evenStep 0 = done True
evenStep n = more (\() -> oddStep (n - 1))
oddStep 0 = done False
oddStep n = more (\() -> evenStep (n - 1))

parity :: Int -> Bool
parity n = run (evenStep n)
```

Haskell2010; клиент компилируется вместе с соседним авторским модулем реализации. Прежний вариант также сохранён ниже; его размер не суммируется с новым.

Тела используемых компонентов показаны рядом: [092. Trampoline container and runner implementation](092_trampoline_container_and_runner_implementation_comparision.md). Это описание текущего компонента, а не выбор версии библиотеки. Общая инфраструктура ядра раскрыта в реестре зависимостей.

[Основной листинг](examples/haskell/083_trampoline.hs)

## Scala — основной: обобщённая реализация

```scala
import Bounce.*

object TrampolineExample {
  def evenStep(n: Int): Value[Boolean] =
    if (n == 0) done(true) else more(() => oddStep(n - 1))
  def oddStep(n: Int): Value[Boolean] =
    if (n == 0) done(false) else more(() => evenStep(n - 1))
  def parity(n: Int): Boolean = run(evenStep(n))
}
```

Scala 3; клиент использует соседний авторский generic-компонент. Прежний вариант сохранён ниже и исключён из нового подсчёта.

Тела используемых компонентов показаны рядом: [092. Trampoline container and runner implementation](092_trampoline_container_and_runner_implementation_comparision.md). Это описание текущего компонента, а не выбор версии библиотеки. Общая инфраструктура ядра раскрыта в реестре зависимостей.

[Основной листинг](examples/scala/083_trampoline.scala)

Другие сохранённые LMX варианты: [core](examples/lmx/variants/083_trampoline_core.lm3) — 433 символов (допустимый).

## LMX — действующая альтернатива: текущее ядро

```lmx
Steps:
    int: n
    return: @
    throws:
        FxIndex
        FxArity
        FxRecordArity
        FxTypeToken
        FxKernelFailure
        FxCallFailure
        ReceiverIndex
        SequenceSize
    even_step:
        throws: copy(Steps\throws)
        if: n = 0
            return: done(value := (1 record))
        return: more(thunk := partial(odd_step; (n - 1)))
    odd_step:
        throws: copy(Steps\throws)
        if: n = 0
            return: done(value := (0 record))
        return: more(thunk := partial(even_step; (n - 1)))

Example:
    int: n
    return: int
    run:
        throws: copy(Steps\throws)
        return: \trampoline(Steps\even_step(n))
```

Общий список выходов хранится в Steps\throws; ссылки на него входят в размер клиента. Метод Example\run передаёт эти выходы своему вызывающему. Он не объявлен корневым обработчиком Message. [Разыменование и catch](FAILURE_BOUNDARIES.md#trampoline).

Полный размер этого варианта: **433 непробельных символов / 28 непустых строк**. Он не прибавляется к выбранному основному листингу; это отдельный допустимый способ выполнить тот же сценарий.

[Исходник текущей альтернативы](examples/lmx/variants/083_trampoline_core.lm3)

## Выбор основного кода и подсчёт

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 417 | 33 |
| Haskell | 236 | 9 |
| Scala | 237 | 8 |

Первичная таблица считает ровно `listings[].code`. Вторые варианты ниже не прибавляются к основным. [Допустимость и выбор алгоритма](variant_selection.json) воспроизводится скриптом. [Реестр зависимостей](IMPLEMENTATION_DEPENDENCIES.md) отдельно показывает, какие компоненты текущего ядра использует клиент и сколько стоит общее ядро новых ресиверов.

## LMX — сохранённый процедурный вариант целиком; вне текущего подсчёта

```lmx
BounceValue:
    int: done 0
    int: answer 0
    int: argument 0
    @: next 0

Bounce:
    int: value
    @: next
    int: argument
    return: @
    done:
        @: result (copy(BounceValue))
        result\done := 1
        result\answer := value
        return: result
    more:
        @: result (copy(BounceValue))
        result\next := next
        result\argument := argument
        return: result

BounceRunner:
    BounceValue@: current return: int
    run:
        while: current\done = 0
            @: step current\next
            current := step(current\argument)
        return: current\answer

Steps:
    int: n
    return: @
    even_step:
        if: n = 0
            return: Bounce\done(value := 1)
        return: Bounce\more(next := odd_step; argument := n - 1)
    odd_step:
        if: n = 0
            return: Bounce\done(value := 0)
        return: Bounce\more(next := even_step; argument := n - 1)

Example:
    int: n
    return: int
    run:
        return: BounceRunner\run(Steps\even_step(n))
```

Полный размер сохранённого варианта: **670 непробельных символов / 43 непустых строк**.

Сохранённый клиент показан целиком с исходными Bounce и BounceRunner из сохранённого 092. Его исходные байты не изменены; определения добавлены как context_prefix. Исторический специализированный вариант служит пояснением, а не другой подключаемой редакцией ядра.

Историческая форма сохранена как объяснение исходного алгоритма. Она не объявляется действующей самостоятельной библиотекой или равной по общности заменой текущего ядра.

Новые реализации доступны также в [LMX_Fn_Receivers](../LMX_Fn_Receivers/README.md). Исторический специализированный пример не ограничивает текущий общий API ядра.

## Haskell — исторический специализированный пример; вне текущего подсчёта

```haskell
module TrampolineExample where
import BounceBool (Bounce, done, more, run)

evenStep, oddStep :: Int -> Bounce
evenStep 0 = done True
evenStep n = more oddStep (n - 1)
oddStep 0 = done False
oddStep n = more evenStep (n - 1)

parity :: Int -> Bool
parity n = run (evenStep n)
```

Сохранён исходный поясняющий листинг. Он использует прежний специализированный интерфейс/контейнер; отдельная старая библиотека не входит в текущее единое ядро.

Исторический код сохранён для разбора, но не является другой подключаемой библиотекой и не участвует в выборе алгоритма текущего общего контракта.

## Scala — исторический специализированный пример; вне текущего подсчёта

```scala
import BounceBool.*

object TrampolineExample {
  def evenStep(n: Int): Bounce =
    if (n == 0) done(true) else more(oddStep, n - 1)
  def oddStep(n: Int): Bounce =
    if (n == 0) done(false) else more(evenStep, n - 1)
  def parity(n: Int): Boolean = run(evenStep(n))
}
```

Сохранён исходный поясняющий листинг. Он использует прежний специализированный интерфейс/контейнер; отдельная старая библиотека не входит в текущее единое ядро.

Исторический код сохранён для разбора, но не является другой подключаемой библиотекой и не участвует в выборе алгоритма текущего общего контракта.

## Семантические границы

**Честная граница сравнения.** Сравниваются шаги even/odd и запуск готового батута: Haskell/Scala тоже используют соседний Bounce-компонент, а отложенный переход строят средствами функции/замыкания. В LMX ту же отсрочку задаёт partial; его общий построитель раскрыт отдельно. Ни частота вызовов, ни результат, ни отсутствие роста рекурсивного стека не исключены из контракта. Общий шаг и все его настройки включены целиком; размер не скрывает прикладные зависимости.

**Основной LMX.** Общий алгоритм шага находится в Steps\code; even_step и odd_step задают локальные x и next, доступные по динамическому связыванию. Throws содержит список выходов один раз, четыре copy(Throws) входят в подсчёт. Входы: Steps\Example\run(0), Steps\Example\run(1), Steps\Example\run(100001). Выходы передаются вызывающему; это не корневой обработчик Message. [Разыменование и catch](FAILURE_BOUNDARIES.md#trampoline).

**Наблюдаемый общий сценарий.** Ограничение n≥0 принадлежит задаче чётности. Общий trampoline не ограничивает результат int или bool. Это последовательный батут; Message, планирование и параллельное выполнение не добавлены. Создание thunk не вызывает исходный шаг.

**Возможности общего ядра.** Ограничение n≥0 принадлежит задаче чётности. Общий trampoline не ограничивает результат int или bool. Это последовательный батут; Message, планирование и параллельное выполнение не добавлены. Создание thunk не вызывает исходный шаг.

Универсальный набор новых ресиверов может делать больше специализированного компактного примера. В частности, Maybe/Bounce общего пакета хранят произвольные записи, bracket не фиксирует R, partial принимает произвольный смешанный префикс. Сравнение символов не приравнивает дополнительные возможности к нулевой стоимости. Прямой record-API сообщает FxCallFailure с исходным именем внутри; действующий общий вариант bracket проверяет этот договор явно. Локальный прикладной Around передаёт ResourceFailure напрямую и целиком входит в свой клиентский листинг.

## English explanation

Mutual even/odd steps use generic Bounce with a nullary continuation created by partial.

**Companion implementation:** [092. Trampoline container and runner implementation](092_trampoline_container_and_runner_implementation_comparision.md), [099. General partial-application implementation](099_integer_partial_application_implementation_comparision.md)

**Scenario.** For nonnegative n, compute parity. An unfinished step returns more(partial(otherStep; (n−1))) without invoking the other step. trampoline invokes one retained thunk at a time until done.

**Expected observation.** 0 yields true, 1 false and 100001 false; LMX returns 1, 0, 0. Every step returns control to the driver; no nested even/odd call chain accumulates.

Primary is the shortest eligible complete current-contract algorithm for each language. Its imports, declarations and throws are included. The complete historical listing stays adjacent and is excluded from the primary count. Implementation comparisons retain their full generalized contracts. A usage scenario may instead use a complete counted local helper when it preserves that scenario. This does not select another core library edition; the generic component remains current.

**Primary LMX.** Steps\code owns the shared step algorithm. even_step and odd_step supply local x and next through dynamic binding. Throws declares the exits once; all four copy(Throws) uses are counted. Entry points are Steps\Example\run(0), Steps\Example\run(1), and Steps\Example\run(100001). Exits propagate to the caller; this is not a root Message handler. [Dereference and catch](FAILURE_BOUNDARIES.md#trampoline).

**LMX variant `core`.** partial retains the prefix and creates a nullary callable. Steps\throws declares the exits once; each method explicitly receives that stream through copy(Steps\throws), with no new P0 unwrapping rule. The declaration and all three uses are counted. trampoline returns a typed result-record reference; prefix \ dereferences the completed call result to read its int payload. The expanded spelling and a caller-side catch are explained in [the companion note](FAILURE_BOUNDARIES.md#trampoline).

No execution of LMX or the control programs is claimed.

## Источники / Sources

- [Scala TailCalls API](https://www.scala-lang.org/api/current/scala/util/control/TailCalls%24.html) — Первичный пример протокола возвращаемого следующего шага; готовый TailCalls в данной паре не используется.
- [Haskell 2010 Report, declarations and bindings](https://www.haskell.org/onlinereport/haskell2010/haskellch4.html) — Собственные варианты Done/More и поля функционального типа.
- [Scala 3 Book, Algebraic Data Types](https://docs.scala-lang.org/scala3/book/types-adts-gadts.html) — Представление Bounce собственным enum.
- [Scala tailrec annotation](https://www.scala-lang.org/api/current/scala/annotation/tailrec.html) — Компилятор отвергает @tailrec, если метод не может быть превращён в цикл; это проверка драйвера, не готовая библиотека Bounce.

**Норма LMX:** [семантика](../../LMX_semantics.en.md), [грамматика](../../LMX_grammar.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

[Проверка вариантов и публикации](VALIDATION_2026-11-22.md) отделяет статические сверки от фактического исполнения. [Интеграция в ядро](../../kernel-implementation.en.md#receiver-kernel-integration) описывает требуемую поддержку новых общих ресиверов.

[Declared exits, handlers, and example boundary](FAILURE_BOUNDARIES.md#trampoline).
