# 083. Trampoline

Прикладные взаимные even/odd шаги поверх готового Bounce и runner.

**Реализация используемого компонента:** [092. Trampoline container and runner implementation](092_trampoline_container_and_runner_implementation_comparision.md)

## Общий сценарий

Для неотрицательного n определить чётность взаимными шагами even/odd. Каждый незавершённый шаг возвращает More со ссылкой на другой шаг и числом n−1; он не вызывает другой шаг. Прогнать 0, 1 и 100001 через библиотечный runner, полностью показанный рядом.

**Ожидаемое наблюдение:** 0 → true, 1 → false, 100001 → false; LMX возвращает 1, 0, 0. Каждый шаг возвращает управление драйверу; вложенная цепочка вызовов even/odd не накапливается.

**Граница сравнения:** Использование библиотеки. Вход n неотрицателен; результат логический. Эта программа показывает tail-call trampoline, а не универсальное преобразование любого рекурсивного алгоритма. Пример не измеряет быстродействие, heap или стек реального LMX-ядра; отсутствие вложенного вызова следующего шага проверяется по коду и должно подтверждаться runtime-приёмкой. В показанной LMX-реализации даже Done создаётся через copy: для входа n выделяется n+1 типизированных Bounce-контейнеров в арене Message. Замена локального current сама по себе не освобождает прежний контейнер; O(1) общего потребления памяти и автоматическая сборка здесь не заявляются. Это новая симметричная граница с явным Bounce; прежний специализированный LMX-драйвер без контейнеров имел другую стоимость. Haskell/Scala используют собственные GC-профили.

Готовые компоненты одинаково доступны всем трём языкам. Здесь считается клиентский код; полные реализации вынесенных компонентов показаны в связанных сравнениях выше.

## LMX

```lmx
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

Входы Example\run(0), Example\run(1), Example\run(100001). Сначала загрузить examples/lmx/092_trampoline_container_and_runner_implementation.lm3. more получает уже готовое число и ссылку; библиотека не вызывает шаг при конструировании.

[Отдельный листинг](examples/lmx/083_trampoline.lm3)

## Haskell

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

Скомпилировать вместе с examples/haskell/092_trampoline_container_and_runner_implementation.hs, объявляющим модуль BounceBool. В клиенте нет собственного драйвера и нет стандартного trampoline. Внешние пробы parity 0, parity 1 и parity 100001.

[Отдельный листинг](examples/haskell/083_trampoline.hs)

## Scala

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

Scala 3. Компилировать вместе с examples/scala/092_trampoline_container_and_runner_implementation.scala. Используется ровно его BounceBool, без scala.util.control.TailCalls. Внешние пробы TrampolineExample.parity(0), parity(1), parity(100001).

[Отдельный листинг](examples/scala/083_trampoline.scala)

## Разбор LMX

Bounce и BounceRunner предоставлены собственным соседним implementation-листингом. В клиенте остаются условия завершения и выбор следующего шага. n−1 — сохранённое число, even_step/odd_step — обычные ссылки. Режим raw, удержание кадра, динамическая переменная remaining и отдельный scheduler не нужны.

## Сопоставление

Во всех трёх языках из размера клиента исключены контейнер и runner одной явно заданной библиотеки. В соседнем блоке они реализованы и посчитаны для каждого языка. Haskell и Scala здесь также импортируют custom BounceBool, не готовый TailCalls.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 273 | 16 |
| Haskell | 222 | 9 |
| Scala | 215 | 8 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Application even/odd steps using a ready Bounce and runner.

**Implementation of the supplied component:** [092. Trampoline container and runner implementation](092_trampoline_container_and_runner_implementation_comparision.md)

**Scenario.** Determine parity for nonnegative n using mutual even/odd steps. Every unfinished step returns More with the other step and n−1; it does not invoke that step. Run 0, 1 and 100001 through the library runner fully shown alongside.

**Expected observation.** 0 yields true, 1 false and 100001 false; LMX returns 1, 0, 0. Every step returns control to the driver; no nested even/odd call chain accumulates.

**LMX.** Bounce and BounceRunner are supplied by the adjacent custom implementation listing. Termination conditions and next-step selection remain client code. n−1 is a stored number and even_step/odd_step are ordinary references. Raw mode, retained frames, a dynamic remaining place and a separate scheduler are unnecessary.

**Comparison.** The same explicitly defined container and runner are excluded from every client count. The adjacent block implements and counts them in each language. Haskell and Scala also import custom BounceBool rather than ready TailCalls.

**Scope and limitations.** n is nonnegative and the result is Boolean. This demonstrates a tail-call trampoline, not a transformation of arbitrary recursion. It does not measure runtime speed, heap or a real LMX core stack; the code avoids nested next-step calls and runtime acceptance must confirm the behavior. In this LMX implementation even Done is created by copy: input n allocates n+1 typed Bounce containers in the Message arena. Replacing local current does not itself free the previous container; O(1) total memory and automatic collection are not claimed. This is the new symmetric boundary with explicit Bounce; the former specialized container-free LMX driver had a different cost. Haskell/Scala have their own GC profiles.

### Dependencies and execution boundaries

- **LMX:** Call Example\run(0), Example\run(1), Example\run(100001). First load examples/lmx/092_trampoline_container_and_runner_implementation.lm3. more receives a prepared number and reference; construction does not invoke the step.
- **Haskell:** Compile with examples/haskell/092_trampoline_container_and_runner_implementation.hs, which declares BounceBool. The client has neither its own driver nor a standard trampoline implementation. External probes: parity 0, parity 1 and parity 100001.
- **Scala:** Scala 3. Compile with examples/scala/092_trampoline_container_and_runner_implementation.scala. Uses exactly that BounceBool, without scala.util.control.TailCalls. External probes: TrampolineExample.parity(0), parity(1), parity(100001).

## Источники / Sources

- [Scala TailCalls API](https://www.scala-lang.org/api/current/scala/util/control/TailCalls%24.html) — Первичный пример протокола возвращаемого следующего шага; готовый TailCalls в данной паре не используется.
- [Haskell 2010 Report, declarations and bindings](https://www.haskell.org/onlinereport/haskell2010/haskellch4.html) — Собственные варианты Done/More и поля функционального типа.
- [Scala 3 Book, Algebraic Data Types](https://docs.scala-lang.org/scala3/book/types-adts-gadts.html) — Представление Bounce собственным enum.
- [Scala tailrec annotation](https://www.scala-lang.org/api/current/scala/annotation/tailrec.html) — Компилятор отвергает @tailrec, если метод не может быть превращён в цикл; это проверка драйвера, не готовая библиотека Bounce.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
