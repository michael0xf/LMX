# 092. Trampoline container and runner implementation

Собственный Bounce для логического результата и отложенного вызова с одним целочисленным аргументом; полный runner во всех трёх языках.

**Примеры использования:** [083. Trampoline](083_trampoline_comparision.md)

## Общий сценарий

Реализовать Done(answer) и More(next, argument). done создаёт завершённое значение; more сохраняет ссылку на шаг и его int-аргумент, ничего не вызывая. run повторно вызывает один сохранённый шаг и получает новый Bounce до Done. Весь контейнер и драйвер показаны; клиент определяет even/odd.

**Ожидаемое наблюдение:** run(done(true)) сразу возвращает true. Каждый More исполняет сохранённый next ровно один раз с сохранённым argument. Клиент для 0, 1, 100001 получает true, false, false (LMX: 1, 0, 0); глубина вложенных вызовов шагов не растёт с n.

**Граница сравнения:** Реализация библиотеки. Результат — Bool (LMX int 0/1), аргумент следующего шага — один int. Это минимальный tail-call trampoline, не полный continuation runtime и не бенчмарк. Выделение контейнеров и сборка памяти сохраняют свою стоимость; постоянный размер heap не обещается. Клиентские шаги должны возвращать Bounce, не рекурсивно запускать следующий шаг сами. В показанной LMX-реализации даже Done создаётся через copy: для входа n выделяется n+1 типизированных Bounce-контейнеров в арене Message. Замена локального current сама по себе не освобождает прежний контейнер; O(1) общего потребления памяти и автоматическая сборка здесь не заявляются. Это новая симметричная граница с явным Bounce; прежний специализированный LMX-драйвер без контейнеров имел другую стоимость. Haskell/Scala используют собственные GC-профили.

Показана реализация компонента на всех трёх языках. Её код полностью включён в эту строку сравнения; связанный прикладной пример считает только использование готового компонента.

## LMX

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
    @: current BounceValue
    return: int
    run:
        while: current\done = 0
            @: step current\next
            current := step(current\argument)
        return: current\answer
```

Оба поля состояния и сохранённый аргумент находятся в возвращаемом графе. Runner не требует удерживать активацию, создавшую More. Файл загружается перед клиентом Trampoline.

[Отдельный листинг](examples/lmx/092_trampoline_container_and_runner_implementation.lm3)

## Haskell

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

Haskell2010. Собственные Bounce и run; готовый trampoline не импортируется. Передавать этот файл компилятору с клиентом или размещать как BounceBool.hs на пути поиска.

[Отдельный листинг](examples/haskell/092_trampoline_container_and_runner_implementation.hs)

## Scala

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

Scala 3. Собственный enum и runner; @tailrec проверяет хвостовой вызов драйвера, но не вызывает готовый TailCalls. Компилировать вместе с клиентом.

[Отдельный листинг](examples/scala/092_trampoline_container_and_runner_implementation.scala)

## Разбор LMX

BounceValue — собственный контейнер, не builtin. done/more копируют его данные и заполняют новый результат; More хранит обычную ссылку и int в графе, не raw-вхождение и не адрес завершённого кадра. BounceRunner меняет только своё current и вызывает шаг из цикла. У done/more общий DATA, поэтому клиент явно именует value либо next/argument.

## Сопоставление

Во всех языках одинаковая модель отложенного вызова: функция Int→Bounce плюс уже сохранённый int. Никакой готовый Trampoline/TailCalls, monadic bind, CPS-преобразователь или scheduler не скрыт за интерфейсом. Haskell использует хвостовой драйвер, Scala — проверяемую @tailrec-функцию, LMX — while.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 397 | 28 |
| Haskell | 229 | 9 |
| Scala | 361 | 14 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

A custom Bounce for a Boolean result or a deferred call with one integer argument, with complete runners in all three languages.

**Usage examples:** [083. Trampoline](083_trampoline_comparision.md)

**Scenario.** Implement Done(answer) and More(next, argument). done creates completion; more stores a step reference and its integer argument without invoking it. run repeatedly invokes one stored step and receives the next Bounce until Done. The complete container and driver are shown; even/odd belong to the client.

**Expected observation.** run(done(true)) returns true immediately. Each More invokes the stored next exactly once with its stored argument. The client for 0, 1, 100001 yields true, false, false (LMX: 1, 0, 0); nested step-call depth does not grow with n.

**LMX.** BounceValue is a custom container, not a built-in. done/more copy its data and fill a new result; More stores an ordinary reference and int in the graph, not a raw occurrence or an expired-frame address. BounceRunner changes only its current place and calls a step from the loop. done/more share DATA, so the client explicitly names value or next/argument.

**Comparison.** All languages use the same deferred-call model: an Int→Bounce function plus an already stored int. No ready Trampoline/TailCalls, monadic bind, CPS transformer or scheduler is hidden behind the interface. Haskell uses a tail driver, Scala a checked @tailrec function and LMX a while loop.

**Scope and limitations.** The result is Bool (LMX int 0/1), and a next step has one integer argument. This is a minimal tail-call trampoline, not a full continuation runtime or benchmark. Container allocation and collection retain their costs; constant heap size is not promised. Client steps must return Bounce instead of recursively running the next step themselves. In this LMX implementation even Done is created by copy: input n allocates n+1 typed Bounce containers in the Message arena. Replacing local current does not itself free the previous container; O(1) total memory and automatic collection are not claimed. This is the new symmetric boundary with explicit Bounce; the former specialized container-free LMX driver had a different cost. Haskell/Scala have their own GC profiles.

### Dependencies and execution boundaries

- **LMX:** State and the stored argument reside in the returned graph. The runner does not retain the activation that created More. Load this source before the Trampoline client.
- **Haskell:** Haskell2010. Custom Bounce and run; no ready trampoline is imported. Supply this source with the client or place it as BounceBool.hs on the module search path.
- **Scala:** Scala 3. Custom enum and runner; @tailrec checks the driver tail call but does not invoke ready TailCalls. Compile together with the client.

## Источники / Sources

- [Scala TailCalls API](https://www.scala-lang.org/api/current/scala/util/control/TailCalls%24.html) — Первичный пример протокола возвращаемого следующего шага; готовый TailCalls в данной паре не используется.
- [Haskell 2010 Report, declarations and bindings](https://www.haskell.org/onlinereport/haskell2010/haskellch4.html) — Собственные варианты Done/More и поля функционального типа.
- [Scala 3 Book, Algebraic Data Types](https://docs.scala-lang.org/scala3/book/types-adts-gadts.html) — Представление Bounce собственным enum.
- [Scala tailrec annotation](https://www.scala-lang.org/api/current/scala/annotation/tailrec.html) — Компилятор отвергает @tailrec, если метод не может быть превращён в цикл; это проверка драйвера, не готовая библиотека Bounce.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
