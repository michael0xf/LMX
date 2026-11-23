# 083. Trampoline

Взаимные even/odd шаги используют общий Bounce с nullary continuation, созданной partial.

**Сравнения реализаций:** [092. Trampoline container and runner implementation](092_trampoline_container_and_runner_implementation_comparision.md), [099. General partial-application implementation](099_integer_partial_application_implementation_comparision.md). Это ссылки для чтения, не импорты самописных модулей в контрольные usage-клиенты.

## Общий сценарий

Для неотрицательного n определить чётность. Незавершённый шаг возвращает more(partial(другой_шаг; (n−1))) без вызова другого шага. trampoline вызывает по одному сохранённому thunk до done.

**Ожидаемое наблюдение:** 0 → true, 1 → false, 100001 → false; LMX возвращает 1, 0, 0. Каждый шаг возвращает управление драйверу; вложенная цепочка вызовов even/odd не накапливается.

**Граница сравнения.** LMX вызывает непосредственные операции текущего ядра; контрольные языки используют настоящую библиотеку или собственные средства языка. Самописные аналоги из соседних сравнений сюда не импортируются.

| Язык | Используемое средство |
| --- | --- |
| Haskell | `free 5.2: Control.Monad.Free; base: Identity` |
| Scala | `scala-library: scala.util.control.TailCalls` |

## LMX — общий алгоритм шага

```lmx
Steps:
    int: n
    return: @
    Throws: copy(FxThrows\capture) FxCallFailure
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

[Исходник](examples/lmx/083_trampoline.lm3)

## Haskell — готовое средство языка/библиотеки

```haskell
module TrampolineExample where
import Control.Monad.Free (Free(..), iter)
import Data.Functor.Identity (Identity(..))

evenStep, oddStep :: Int -> Free Identity Bool
evenStep 0 = Pure True
evenStep n = Free (Identity (oddStep (n - 1)))
oddStep 0 = Pure False
oddStep n = Free (Identity (evenStep (n - 1)))

parity :: Int -> Bool
parity = iter runIdentity . evenStep
```

Клиент использует существующее средство языка/библиотеки. Соседняя самостоятельная реализация служит отдельным сравнением и не подключается.

[Исходник](examples/haskell/083_trampoline.hs)

## Scala — готовое средство языка/библиотеки

```scala
import scala.util.control.TailCalls.*

object TrampolineExample {
  def evenStep(n: Int): TailRec[Boolean] =
    if (n == 0) done(true) else tailcall(oddStep(n - 1))
  def oddStep(n: Int): TailRec[Boolean] =
    if (n == 0) done(false) else tailcall(evenStep(n - 1))
  def parity(n: Int): Boolean = evenStep(n).result
}
```

Клиент использует существующее средство языка/библиотеки. Соседняя самостоятельная реализация служит отдельным сравнением и не подключается.

[Исходник](examples/scala/083_trampoline.scala)

## Подсчёт

| Язык | Непробельные символы | Непустые строки | Без сложного Throws |
| --- | ---: | ---: | ---: |
| LMX | 361 | 25 | 348 |
| Haskell | 307 | 10 | — |
| Scala | 265 | 8 | — |

Считается только `listings[].code`, включая импорты, объявления и throws. Альтернативный подход не прибавляется к основному. [Выбор](variant_selection.json) сравнивает допустимые варианты одной границы. [Зависимости реализации](IMPLEMENTATION_DEPENDENCIES.md) показывают общие LMX-тела отдельно.

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основная цена включает их полностью. Дополнительная колонка оставляет заголовок и первый написанный аргумент списка; copy/ссылка сохраняется целиком, общий банк учитывается один раз с первым аргументом. Это только другой подсчёт, не сокращение исходника или контракта.

## Удалённые малозначимые повторы

Удалены полные повторы, отличавшиеся импортом, написанием вызова, повторением общего тела либо специализацией на int. Эти отличия не образуют отдельного текущего алгоритма; исходная редакция сохраняется в базе diff.

## Семантические границы

Ограничение n≥0 принадлежит задаче чётности. Общий trampoline не ограничивает результат int или bool. Это последовательный батут; Message, планирование и параллельное выполнение не добавлены. Создание thunk не вызывает исходный шаг.

[Политика очистки, ошибок и Message/post](FAILURE_BOUNDARIES.md).

## English explanation

Mutual even/odd steps use generic Bounce with a nullary continuation created by partial.

**Scenario.** For nonnegative n, compute parity. An unfinished step returns more(partial(otherStep; (n−1))) without invoking the other step. trampoline invokes one retained thunk at a time until done.

**Expected.** 0 yields true, 1 false and 100001 false; LMX returns 1, 0, 0. Every step returns control to the driver; no nested even/odd call chain accumulates.

**Limits.** n≥0 is a parity-domain precondition. Generic trampoline does not restrict results to int or bool. It is sequential, with no Message scheduler or parallelism. Constructing a thunk does not invoke the original step.

Usage clients call the real language/library facility. Adjacent foreign implementations are independent comparison subjects and are not imported by usage clients. Only genuinely different approaches remain. The source listings have not been executed by an LMX/Haskell/Scala runtime in this workspace.

## Источники / Sources

- [Haskell free: Free and iter](https://hackage-content.haskell.org/package/free-5.2/docs/Control-Monad-Free.html)
- [Scala TailCalls](https://www.scala-lang.org/api/2.13.16/scala/util/control/TailCalls$.html)

**Норма LMX:** [семантика](../../LMX_semantics.en.md), [грамматика](../../LMX_grammar.en.md), [источники ядра](../LMX_Fn_Receivers/README.md).

## Проверка

[Проверка публикации](VALIDATION_2026-11-23.md) сверяет данные, исходники, отсутствие подмены библиотечных клиентов и границы подсчёта. [Acceptance matrix](acceptance_cases.json) отделяет подготовленные наблюдения от реального запуска.
