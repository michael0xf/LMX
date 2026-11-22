# 083. Trampoline

Взаимные even/odd шаги используют общий Bounce с nullary continuation, созданной partial.

**Соседнее сравнение реализации:** [092. Trampoline container and runner implementation](092_trampoline_container_and_runner_implementation_comparision.md), [099. General partial-application implementation](099_integer_partial_application_implementation_comparision.md)

## Общий сценарий

Для неотрицательного n определить чётность. Незавершённый шаг возвращает more(partial(другой_шаг; (n−1))) без вызова другого шага. trampoline вызывает по одному сохранённому thunk до done.

**Ожидаемое наблюдение:** 0 → true, 1 → false, 100001 → false; LMX возвращает 1, 0, 0. Каждый шаг возвращает управление драйверу; вложенная цепочка вызовов even/odd не накапливается.

Основные варианты: LMX — **текущее ядро**, Haskell — **обобщённая реализация**, Scala — **обобщённая реализация**. Основным считается самый короткий из рассмотренных допустимых алгоритмов текущего контракта; это выбор по символам, а не заявление о большей общности.

При одинаковом размере сохраняется прежний корректный основной вариант. Импорты, объявления и throws входят в подсчёт. Клиенты используют один текущий компонент; исторические специализированные формы остаются пояснением. Смена архитектурного механизма допустима при сохранении всей задачи, полей, эффектов и границы учитываемого кода.

## LMX — основной: текущее ядро

```lmx
Steps:
    int: n
    return: @
    even_step:
        throws:
            FxIndex
            FxArity
            FxRecordArity
            FxTypeToken
            FxKernelFailure
            FxCallFailure
        if: n = 0
            return: done(value := (1 record))
        return: more(thunk := partial(odd_step; (n - 1)))
    odd_step:
        throws:
            FxIndex
            FxArity
            FxRecordArity
            FxTypeToken
            FxKernelFailure
            FxCallFailure
        if: n = 0
            return: done(value := (0 record))
        return: more(thunk := partial(even_step; (n - 1)))

Example:
    int: n
    return: int
    run:
        throws:
            FxIndex
            FxArity
            FxRecordArity
            FxTypeToken
            FxKernelFailure
            FxCallFailure
        return: \trampoline(Steps\even_step(n))
```

Операции являются частью текущего ядра и доступны напрямую. Библиотеку другой редакции загружать не нужно; общий код реализации показан в соседних сравннениях и реестре зависимостей.

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

## Выбор основного кода и подсчёт

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 479 | 37 |
| Haskell | 236 | 9 |
| Scala | 237 | 8 |

Первичная таблица считает ровно `listings[].code`. Вторые варианты ниже не прибавляются к основным. [Допустимость и выбор алгоритма](variant_selection.json) воспроизводится скриптом. [Реестр зависимостей](IMPLEMENTATION_DEPENDENCIES.md) отдельно показывает, какие компоненты текущего ядра использует клиент и сколько стоит общее ядро новых ресиверов.

## LMX — исторический процедурный пример; вне текущего подсчёта

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

Сохранён исходный поясняющий листинг. Он использует прежний специализированный интерфейс/контейнер; отдельная старая библиотека не входит в текущее единое ядро.

Исторический код сохранён для разбора, но не является другой подключаемой библиотекой и не участвует в выборе алгоритма текущего общего контракта.

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

**Честная граница сравнения.** Сравниваются шаги even/odd и запуск готового батута: Haskell/Scala тоже используют соседний Bounce-компонент, а отложенный переход строят средствами функции/замыкания. В LMX ту же отсрочку задаёт partial; его общий построитель раскрыт отдельно. Ни частота вызовов, ни результат, ни отсутствие роста рекурсивного стека не исключены из контракта.

**Основной LMX.** partial получает префикс, содержащий единственный int только в этом прикладном примере, и возвращает nullary callable. В самом Bounce нет поля int argument и ограничения на число параметров исходного шага. trampoline возвращает ссылку на запись результата; явное явное разыменование результата читает её int-полезное значение.

**Наблюдаемый общий сценарий.** Ограничение n≥0 принадлежит задаче чётности. Общий trampoline не ограничивает результат int или bool. Это последовательный батут; Message, планирование и параллельное выполнение не добавлены. Создание thunk не вызывает исходный шаг.

**Возможности общего ядра.** Ограничение n≥0 принадлежит задаче чётности. Общий trampoline не ограничивает результат int или bool. Это последовательный батут; Message, планирование и параллельное выполнение не добавлены. Создание thunk не вызывает исходный шаг.

Универсальный набор новых ресиверов может делать больше специализированного компактного примера. В частности, Maybe/Bounce общего пакета хранят произвольные записи, bracket не фиксирует R, partial принимает произвольный смешанный префикс. Сравнение символов не приравнивает дополнительные возможности к нулевой стоимости. Прямой record-API сообщает FxCallFailure с исходным именем внутри; основной пример bracket проверяет этот договор явно.

## English explanation

Mutual even/odd steps use generic Bounce with a nullary continuation created by partial.

**Companion implementation:** [092. Trampoline container and runner implementation](092_trampoline_container_and_runner_implementation_comparision.md), [099. General partial-application implementation](099_integer_partial_application_implementation_comparision.md)

**Scenario.** For nonnegative n, compute parity. An unfinished step returns more(partial(otherStep; (n−1))) without invoking the other step. trampoline invokes one retained thunk at a time until done.

**Expected observation.** 0 yields true, 1 false and 100001 false; LMX returns 1, 0, 0. Every step returns control to the driver; no nested even/odd call chain accumulates.

Primary is the shortest eligible complete current-contract algorithm for each language. Its imports, declarations and throws are included. The complete historical listing stays adjacent and is excluded from the primary count. Specialized historical implementations do not satisfy the full generalized current contract. There is one current component implementation; historical specialized code is not offered as another library dependency.

**Primary LMX.** partial receives a one-int prefix only in this application and returns a nullary callable. Bounce has no int argument field or bound on the original step arity. trampoline returns a result-record reference; explicit dereference of the result reads its int payload.

**Current core implementation.** partial receives a one-int prefix only in this application and returns a nullary callable. Bounce has no int argument field or bound on the original step arity. trampoline returns a result-record reference; explicit dereference of the result reads its int payload.

No execution of LMX or the control programs is claimed.

## Источники / Sources

- [Scala TailCalls API](https://www.scala-lang.org/api/current/scala/util/control/TailCalls%24.html) — Первичный пример протокола возвращаемого следующего шага; готовый TailCalls в данной паре не используется.
- [Haskell 2010 Report, declarations and bindings](https://www.haskell.org/onlinereport/haskell2010/haskellch4.html) — Собственные варианты Done/More и поля функционального типа.
- [Scala 3 Book, Algebraic Data Types](https://docs.scala-lang.org/scala3/book/types-adts-gadts.html) — Представление Bounce собственным enum.
- [Scala tailrec annotation](https://www.scala-lang.org/api/current/scala/annotation/tailrec.html) — Компилятор отвергает @tailrec, если метод не может быть превращён в цикл; это проверка драйвера, не готовая библиотека Bounce.

**Норма LMX:** [семантика](../../LMX_semantics.en.md), [грамматика](../../LMX_grammar.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

[Проверка вариантов и публикации](VALIDATION_2026-11-22.md) отделяет статические сверки от фактического исполнения. [Интеграция в ядро](../../kernel-implementation.ru.md#receiver-kernel-integration) описывает требуемую поддержку новых общих ресиверов.
