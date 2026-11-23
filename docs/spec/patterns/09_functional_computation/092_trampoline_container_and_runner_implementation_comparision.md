# 092. Trampoline container and runner implementation

Обобщённый Bounce хранит запись произвольного результата либо nullary thunk; runner не знает тип результата или исходную арность шага.

**Примеры использования:** [083. Trampoline](083_trampoline_comparision.md)

## Общий сценарий

Реализовать done(record), more(thunk) и trampoline(bounce). more сохраняет функцию без вызова; runner вызывает её ровно один раз на итерацию и возвращает результат done. Частичное связывание аргументов вынесено в общий partial.

**Ожидаемое наблюдение:** trampoline(done(record)) возвращает ту же запись результата без вызова continuation. Каждый more запускает сохранённый thunk один раз. Пример чётности даёт 1,0,0 в LMX и true,false,false в контролях, не накапливая рекурсивный стек шагов.

Основные варианты: LMX — **текущее ядро**, Haskell — **обобщённая реализация**, Scala — **обобщённая реализация**. Основным считается самый короткий из рассмотренных допустимых алгоритмов текущего контракта; это выбор по символам, а не заявление о большей общности.

При одинаковом размере сохраняется прежний корректный основной вариант. Импорты, объявления и throws входят в подсчёт. Встроенные операции принадлежат одному текущему ядру; полный локальный helper допустим, когда сохраняет прикладной сценарий и включён в подсчёт. Исторические публикации остаются пояснением. Смена архитектурного механизма допустима при сохранении всей задачи, полей, эффектов и границы учитываемого кода.

## LMX — основной: текущее ядро

```lmx
FxBounce:
    int: done 0
    @: value 0
    @: next 0

FxDone:
    private: @: value
    return: @
    done:
        private: @: result (copy(FxBounce))
        result\done := 1
        result\value := value
        return: result

FxMore:
    private: @: thunk
    return: @
    more:
        throws: FxArity FxKernelFailure FxTypeToken
        private: @: shape FxKernel\signature(subject := thunk)
        if: length(shape\inputTypes) != 0
            throw: FxArity()
        private: @: result (copy(FxBounce))
        result\next := thunk
        return: result

FxTrampoline:
    private: FxBounce@: current
    return: @
    trampoline:
        throws: copy(FxThrows\call)
        private: @: empty (copy(()))
        while: current\done = 0
            private: @: record FxApply\apply(current\next; empty)
            current := \record
        return: current\value
```

Основной листинг — точные определения FxBounce, FxDone, FxMore, FxTrampoline из действующих исходников пакета. Публичные операции являются частью ядра; общие зависимости посчитаны отдельно в [реестре](IMPLEMENTATION_DEPENDENCIES.md). Другая версия библиотеки для этого примера не выбирается. Сам этот фрагмент не объявлен самостоятельной реализацией ядра.

[Основной листинг](examples/lmx/092_trampoline_container_and_runner_implementation.lm3)

## Haskell — основной: обобщённая реализация

```haskell
module Bounce (Bounce, done, more, run) where

data Bounce a = Done a | More (() -> Bounce a)

done :: a -> Bounce a
done = Done

more :: (() -> Bounce a) -> Bounce a
more = More

run :: Bounce a -> a
run (Done answer) = answer
run (More next) = run (next ())
```

Haskell2010; клиент компилируется вместе с соседним авторским модулем реализации. Прежний вариант также сохранён ниже; его размер не суммируется с новым.

[Основной листинг](examples/haskell/092_trampoline_container_and_runner_implementation.hs)

## Scala — основной: обобщённая реализация

```scala
object Bounce {
  enum Value[+A] {
    case Done(answer: A)
    case More(next: () => Value[A])
  }
  def done[A](answer: A): Value[A] = Value.Done(answer)
  def more[A](next: () => Value[A]): Value[A] = Value.More(next)
  @annotation.tailrec
  def run[A](current: Value[A]): A = current match {
    case Value.Done(answer) => answer
    case Value.More(next) => run(next())
  }
}
```

Scala 3; клиент использует соседний авторский generic-компонент. Прежний вариант сохранён ниже и исключён из нового подсчёта.

[Основной листинг](examples/scala/092_trampoline_container_and_runner_implementation.scala)

## Выбор основного кода и подсчёт

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 591 | 33 |
| Haskell | 198 | 9 |
| Scala | 303 | 13 |

Первичная таблица считает ровно `listings[].code`. Вторые варианты ниже не прибавляются к основным. [Допустимость и выбор алгоритма](variant_selection.json) воспроизводится скриптом. [Реестр зависимостей](IMPLEMENTATION_DEPENDENCIES.md) отдельно показывает, какие компоненты текущего ядра использует клиент и сколько стоит общее ядро новых ресиверов.

## LMX — исторический процедурный пример; вне текущего подсчёта

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
```

Сохранён исходный поясняющий листинг. Он использует прежний специализированный интерфейс/контейнер; отдельная старая библиотека не входит в текущее единое ядро.

Исторический код сохранён для разбора, но не является другой подключаемой библиотекой и не участвует в выборе алгоритма текущего общего контракта.

Историческая форма сохранена как объяснение исходного алгоритма. Она не объявляется действующей самостоятельной библиотекой или равной по общности заменой текущего ядра.

Новые реализации доступны также в [LMX_Fn_Receivers](../LMX_Fn_Receivers/README.md). Исторический специализированный пример не ограничивает текущий общий API ядра.

## Haskell — исторический специализированный пример; вне текущего подсчёта

```haskell
module BounceBool (Bounce, done, more, run) where

data Bounce = Done Bool | More (Int -> Bounce) Int

done :: Bool -> Bounce
done = Done

more :: (Int -> Bounce) -> Int -> Bounce
more = More

run :: Bounce -> Bool
run (Done answer) = answer
run (More next argument) = run (next argument)
```

Сохранён исходный поясняющий листинг. Он использует прежний специализированный интерфейс/контейнер; отдельная старая библиотека не входит в текущее единое ядро.

Исторический код сохранён для разбора, но не является другой подключаемой библиотекой и не участвует в выборе алгоритма текущего общего контракта.

## Scala — исторический специализированный пример; вне текущего подсчёта

```scala
object BounceBool {
  enum Bounce {
    case Done(answer: Boolean)
    case More(next: Int => Bounce, argument: Int)
  }
  def done(answer: Boolean): Bounce = Bounce.Done(answer)
  def more(next: Int => Bounce, argument: Int): Bounce =
    Bounce.More(next, argument)
  @annotation.tailrec
  def run(current: Bounce): Boolean = current match {
    case Bounce.Done(answer) => answer
    case Bounce.More(next, argument) => run(next(argument))
  }
}
```

Сохранён исходный поясняющий листинг. Он использует прежний специализированный интерфейс/контейнер; отдельная старая библиотека не входит в текущее единое ядро.

Исторический код сохранён для разбора, но не является другой подключаемой библиотекой и не участвует в выборе алгоритма текущего общего контракта.

## Семантические границы

**Честная граница сравнения.** Это сравнение общего Bounce-компонента и настоящего цикла исполнения: все три языка хранят done-результат либо отложенный nullary шаг. LMX показывает контейнеры и runner, а общий мост вызова учитывается отдельно. Старый BounceBool с фиксированным целым аргументом — сохранённая иллюстрация специализации, а не конкурирующий текущий контейнер.

**Основной LMX.** Основной листинг содержит контейнер, конструкторы и цикл из src/containers.lmx. Nullary-call выполняет обычный apply, а полученная запись @-результата шага явно разыменовывается для чтения ссылки на следующий Bounce; это не раскрытие группы аргументов. partial не дублируется внутри контейнера.

**Наблюдаемый общий сценарий.** Контейнер обобщён по результату, но протокол шага намеренно nullary→Bounce. Это математическая форма батута, а не случайная специализация на одном int-аргументе. У произвольной исходной функции аргументы связывает partial с произвольной сигнатурой.

**Возможности общего ядра.** Контейнер обобщён по результату, но протокол шага намеренно nullary→Bounce. Это математическая форма батута, а не случайная специализация на одном int-аргументе. У произвольной исходной функции аргументы связывает partial с произвольной сигнатурой.

Универсальный набор новых ресиверов может делать больше специализированного компактного примера. В частности, Maybe/Bounce общего пакета хранят произвольные записи, bracket не фиксирует R, partial принимает произвольный смешанный префикс. Сравнение символов не приравнивает дополнительные возможности к нулевой стоимости. Прямой record-API сообщает FxCallFailure с исходным именем внутри; действующий общий вариант bracket проверяет этот договор явно. Локальный прикладной Around передаёт ResourceFailure напрямую и целиком входит в свой клиентский листинг.

## English explanation

Generic Bounce holds an arbitrary result record or a nullary thunk; the runner does not know the result type or the original step arity.

**Usage examples:** [083. Trampoline](083_trampoline_comparision.md)

**Scenario.** Implement done(record), more(thunk) and trampoline(bounce). more stores the function without calling it; the runner calls it exactly once per iteration and returns the done result. Argument binding belongs to generic partial.

**Expected observation.** trampoline(done(record)) returns that result record without invoking a continuation. Each more invokes the retained thunk once. Parity yields 1,0,0 in LMX and true,false,false in the controls without accumulating a recursive step stack.

Primary is the shortest eligible complete current-contract algorithm for each language. Its imports, declarations and throws are included. The complete historical listing stays adjacent and is excluded from the primary count. Implementation comparisons retain their full generalized contracts. A usage scenario may instead use a complete counted local helper when it preserves that scenario. This does not select another core library edition; the generic component remains current.

**Primary LMX.** The primary listing contains the container, constructors and loop from src/containers.lmx. Ordinary apply performs the nullary invocation; the resulting @ record is read as the reference to the next Bounce. partial is not duplicated inside the container.

**LMX variant `core`.** The primary listing contains the container, constructors and loop from src/containers.lmx. Ordinary apply performs the nullary invocation; the resulting @ record is read as the reference to the next Bounce. partial is not duplicated inside the container.

No execution of LMX or the control programs is claimed.

## Источники / Sources

- [Scala TailCalls API](https://www.scala-lang.org/api/current/scala/util/control/TailCalls%24.html) — Первичный пример протокола возвращаемого следующего шага; готовый TailCalls в данной паре не используется.
- [Haskell 2010 Report, declarations and bindings](https://www.haskell.org/onlinereport/haskell2010/haskellch4.html) — Собственные варианты Done/More и поля функционального типа.
- [Scala 3 Book, Algebraic Data Types](https://docs.scala-lang.org/scala3/book/types-adts-gadts.html) — Представление Bounce собственным enum.
- [Scala tailrec annotation](https://www.scala-lang.org/api/current/scala/annotation/tailrec.html) — Компилятор отвергает @tailrec, если метод не может быть превращён в цикл; это проверка драйвера, не готовая библиотека Bounce.

**Норма LMX:** [семантика](../../LMX_semantics.en.md), [грамматика](../../LMX_grammar.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

[Проверка вариантов и публикации](VALIDATION_2026-11-22.md) отделяет статические сверки от фактического исполнения. [Интеграция в ядро](../../kernel-implementation.en.md#receiver-kernel-integration) описывает требуемую поддержку новых общих ресиверов.
