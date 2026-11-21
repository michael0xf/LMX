# 083. Trampoline

Исполнитель последовательно получает следующий шаг вычисления вместо роста цепочки вложенных вызовов.

## Общий сценарий

Взаимные even/odd шаги определяют чётность неотрицательного n. Проверить 0, 1 и 100001. Каждый шаг возвращает управление драйверу; в LMX нет рекурсивного вызова второго шага.

**Ожидаемое наблюдение:** 0 → true/1, 1 → false/0, 100001 → false/0. Выполняется n+1 шагов с проверкой базы. LMX-драйвер хранит один текущий next, а не историю из n кадров.

**Граница сравнения:** Ядро сценария. Допустим n≥0 в пределах машинного Int. Замеры стека и скорости не выполнялись; для Haskell конкретные свойства стека зависят от реализации и строгости. Нельзя вернуть LMX-шаг наружу и затем рассчитывать на закончившийся Runner.run: для этого потребовалось бы явное сохраняемое состояние.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Steps:
    return: @
    even_step:
        if: remaining = 0
            finished := 1
            answer := 1
            return: 0
        remaining -= 1
        return: odd_step
    odd_step:
        if: remaining = 0
            finished := 1
            answer := 0
            return: 0
        remaining -= 1
        return: even_step

Runner:
    int: remaining
    return: int
    run:
        int: finished 0
        int: answer 0
        @: next Steps\even_step
        while: finished = 0
            next := next()
        return: answer
```

Runnerun(100001). Все шаги исполняются синхронно внутри одной живой активации; потоки и Message-планировщик для этого паттерна не требуются.

[Отдельный листинг](examples/lmx/083_trampoline.lm3)

## Haskell

```haskell
module TrampolineExample where

data Bounce a = Done a | More (() -> Bounce a)

run :: Bounce a -> a
run (Done value) = value
run (More next) = run (next ())

evenStep, oddStep :: Int -> Bounce Bool
evenStep 0 = Done True
evenStep n = More (\() -> oddStep (n - 1))
oddStep 0 = Done False
oddStep n = More (\() -> evenStep (n - 1))

demo :: Bool
demo = run (evenStep 100001)
```

Haskell 2010. Для исполнения с предсказуемой оптимизацией драйвера целевой профиль — GHC с оптимизацией; отсутствие запуска отмечено отдельно.

[Отдельный листинг](examples/haskell/083_trampoline.hs)

## Scala

```scala
import scala.util.control.TailCalls.*

object TrampolineExample {
  def evenStep(n: Int): TailRec[Boolean] =
    if (n == 0) done(true) else tailcall(oddStep(n - 1))

  def oddStep(n: Int): TailRec[Boolean] =
    if (n == 0) done(false) else tailcall(evenStep(n - 1))

  def demo: Boolean = evenStep(100001).result
}
```

Scala 3. Код библиотеки TailCalls не включён в листинг; он обеспечивает цикл исполнения отложенных шагов.

[Отдельный листинг](examples/scala/083_trampoline.scala)

## Разбор LMX

Это явный батут: Steps возвращает ссылку на следующий метод. Свободные remaining, finished и answer связываются с местами живого вызова Runner.run; Steps не объявляет их собственными входами. Запись меняет места драйвера немедленно. Нулевая ссылка возвращается только при finished=1 и больше не вызывается.

## Сопоставление

В Scala использован готовый TailCalls; в Haskell явно показан тип Bounce и хвостовой драйвер. В LMX шаг представлен обычной ссылкой на метод, состояние остаётся в живом драйвере. Это один специализированный алгоритм; универсальная CPS-библиотека и асинхронное планирование не предполагаются.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 292 | 26 |
| Haskell | 292 | 12 |
| Scala | 261 | 8 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

An executor repeatedly obtains the next computation step instead of nesting calls.

**Scenario.** Mutual even/odd steps test a nonnegative n. Check 0, 1 and 100001. Each step returns to the driver; the LMX version never calls the other step recursively.

**Expected observation.** 0 yields true/1; 1 and 100001 yield false/0. The base-case check makes n+1 steps. The LMX driver retains one next step instead of n activation records.

**LMX.** Steps returns the next method reference. Its free remaining, finished and answer names bind transparently to the live Runner.run places. Steps does not declare copies of those inputs. The null result is returned only after finished=1 and is never called.

**Comparison.** Scala uses the existing TailCalls library; Haskell explicitly defines Bounce and its tail driver. LMX uses ordinary method references and state in the live driver. This is a specialized synchronous algorithm, not a universal CPS library or async scheduler.

**Scope and limitations.** Inputs are nonnegative and fit machine Int. Stack size and speed were not measured; Haskell implementation and strictness matter. An LMX step cannot outlive Runner.run without explicit retained state.

### Dependencies and execution boundaries

- **LMX:** Call Runnerun(100001). Steps execute synchronously within one live activation; this pattern does not require thread or Message scheduling.
- **Haskell:** Haskell 2010; an optimized GHC build is the intended execution profile. No runtime result is claimed.
- **Scala:** Scala 3. The TailCalls implementation is an external standard-library dependency.

## Источники / Sources

- [Scala TailCalls API](https://www.scala-lang.org/api/current/scala/util/control/TailCalls%24.html) — Договор done, tailcall и result; первичное описание готового батута.
- [Haskell 2010 Report, expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html) — Функции и отложенные выражения для явного Bounce.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
