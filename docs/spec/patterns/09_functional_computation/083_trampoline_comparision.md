# 083. Trampoline

Паритет: процедурный цикл и функциональный trampoline для конечного неотрицательного n.

## Общий сценарий

Для неотрицательного n определить чётность. Незавершённый шаг возвращает more(partial(другой_шаг; (n−1))) без вызова другого шага. trampoline вызывает по одному сохранённому thunk до done.

**Ожидается:** 0 → true, 1 → false, 100001 → false; LMX возвращает 1, 0, 0. Каждый шаг возвращает управление драйверу; вложенная цепочка вызовов even/odd не накапливается.

Общие реализации: [092. Trampoline container and runner implementation](092_trampoline_container_and_runner_implementation_comparision.md), [099. General partial-application implementation](099_integer_partial_application_implementation_comparision.md). Они учитываются отдельно; иностранные клиенты не импортируют эти сравнительные модули.

## Граница двух стилей

Договор клиента — parity конечного неотрицательного n: 0→1, 1→0, 100001→0. Процедурный цикл хранит состояние; функциональный вариант показывает настоящий trampoline и два шага с общим телом. Полная общая реализация trampoline остаётся отдельно в092.

## LMX — процедурный

```lmx
Steps:
    Example:
        int: n
        return: int
        run:
            int: value 1
            while: n > 0
                value := 1 - value
                n -= 1
            return: value
```

[Полный исходник](examples/lmx/procedural/083_trampoline.lm3). 82 непробельных символов; 10 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

```lmx
Steps:
    int: n
    return: @
    Throws: copy(partial\throws) FxCallFailure
    code:
        throws: copy(Throws)
        if: n = 0
            return: done(x)
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

[Полный исходник](examples/lmx/083_trampoline.lm3). 344 непробельных символов; 25 непустых строк. Все объявления и Throws включены.


## Haskell

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

## Scala

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

## Подсчёт полного текста

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | **82** | 10 |
| LMX — функциональный | 344 | 25 |
| Haskell | 307 | 10 |
| Scala | 265 | 8 |

Обе LMX-записи сравниваются самостоятельно. Полный текст включает все объявления, локальные helpers и Throws; заголовки и списки ошибок не вычитаются. Общие тела ядра учитываются один раз в отдельных сравнениях. Минимум сопоставимой строки подчёркивается в PDF и XLSX зелёным; при равенстве отмечаются все победители.

Явные Throws и copy списка вызываемого метода сохраняют точный видимый договор отказов. У процедурной записи нет скрытых обходов через map/filter/fold/unique/pipe/bind или поэлементную Array-арифметику.

## Семантические границы

Ограничение n≥0 принадлежит задаче чётности. Общий trampoline не ограничивает результат int или bool. Это последовательный батут; Message, планирование и параллельное выполнение не добавлены. Создание thunk не вызывает исходный шаг.

[Ошибки и Message/post](FAILURE_BOUNDARIES.md). [Общие зависимости](IMPLEMENTATION_DEPENDENCIES.md).

## English explanation

Parity: an explicit loop and a functional trampoline for finite nonnegative n.

**Scenario.** For nonnegative n, compute parity. An unfinished step returns more(partial(otherStep; (n−1))) without invoking the other step. trampoline invokes one retained thunk at a time until done.

**Expected.** 0 yields true, 1 false and 100001 false; LMX returns 1, 0, 0. Every step returns control to the driver; no nested even/odd call chain accumulates.

**Limits.** n≥0 is a parity-domain precondition. Generic trampoline does not restrict results to int or bool. It is sequential, with no Message scheduler or parallelism. Constructing a thunk does not invoke the original step.

Both complete LMX client styles are counted in full. Foreign controls retain the same scenario; 085 removes unused and single-use locals consistently across languages. Implementation comparisons retain one canonical body. Revised LMX source has not been executed.

## Источники

- [Haskell free: Free and iter](https://hackage-content.haskell.org/package/free-5.2/docs/Control-Monad-Free.html)
- [Scala TailCalls](https://www.scala-lang.org/api/2.13.16/scala/util/control/TailCalls$.html)

## Проверка

[Проверка публикации](VALIDATION_2026-11-23.md) проверяет обе записи и зеркала. [Acceptance cases](acceptance_cases.json) — спецификация ожидаемых наблюдений, а не LMX execution receipt.
