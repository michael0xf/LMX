# 082. Monad

Контекстное связывание вычислений на конкретном примере Maybe: отсутствие результата пропускает следующие шаги.

## Общий сценарий

Дважды поделить целое число пополам. Каждый шаг допускает только чётное число. Прогнать 8 и 6; во втором случае второй шаг должен вернуть отсутствие, а продолжение после отсутствия не вызывается.

**Ожидаемое наблюдение:** Для 8: present=1, value=2 (Just 2 / Some(2)). Для 6: present=0 (Nothing / None). Bind не читает value отсутствующего результата. Законы unit/bind рассматриваются по наблюдаемому значению, без сравнения адресов контейнеров.

**Граница сравнения:** Ядро сценария. Сравнивается только контекст возможного отсутствия. IO, State, асинхронные эффекты и трансформеры монад сюда не включены. Контейнеры LMX считаются неизменяемыми по договору после передачи клиенту; произвольная внешняя мутация нарушила бы этот договор. Нельзя называть любой объект с методом bind монадой без проверки трёх законов.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Box:
    int: present 0
    int: value 0

Values:
    int: x
    return: @
    unit:
        @: result (copy(Box))
        result\present := 1
        result\value := x
        return: result
    half:
        @: result (copy(Box))
        if: x % 2 = 0
            result\present := 1
            result\value := x / 2
        return: result

Bind:
    @: input Box
    @: next
    return: @
    apply:
        if: input\present = 0
            return: input
        return: next(input\value)

Example:
    int: x
    return: @
    run:
        @: initial Values\unit(x)
        @: first Bind\apply(initial; Values\half)
        return: Bind\apply(first; Values\half)
```

Входы: Exampleun(8), Exampleun(6). Box — только данные без методов, поэтому запись в собравшую copy группу записывает именно возвращаемое значение. Повторный вызов next получает обычный int.

[Отдельный листинг](examples/lmx/082_monad.lm3)

## Haskell

```haskell
module MonadExample where

half :: Int -> Maybe Int
half x = if even x then Just (x `div` 2) else Nothing

run :: Int -> Maybe Int
run x = Just x >>= half >>= half

demo :: (Maybe Int, Maybe Int)
demo = (run 8, run 6)
```

Haskell 2010, Prelude. >>= и Just относятся к уже реализованному Maybe, его исходник не включён в измерение.

[Отдельный листинг](examples/haskell/082_monad.hs)

## Scala

```scala
object MonadExample {
  def half(x: Int): Option[Int] =
    if (x % 2 == 0) Some(x / 2) else None

  def run(x: Int): Option[Int] =
    Some(x).flatMap(half).flatMap(half)

  def demo = (run(8), run(6))
}
```

Scala 3, стандартный Option. flatMap здесь имеет тот же договор пропуска шага при None.

[Отдельный листинг](examples/scala/082_monad.scala)

## Разбор LMX

LMX реализует конкретный Maybe<int> обычными структурами и методом Bind.apply. Поле present — часть демонстрационного типа; это не физический uninit и не новое ключевое слово. Создание результата явно копирует Box и заполняет его собственные слоты. Метод не сохраняет ссылку на завершённый кадр.

## Сопоставление

Haskell использует стандартный Maybe и >>=, Scala — Option.flatMap. Их краткость здесь отражает уже существующую библиотечную абстракцию. В LMX показана её реализация для int; универсальный полиморфный интерфейс Monad и доказательство законов для произвольных эффектов этим листингом не создаются.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 405 | 32 |
| Haskell | 166 | 7 |
| Scala | 158 | 7 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Context-preserving composition, illustrated by Maybe: absence skips subsequent steps.

**Scenario.** Halve an integer twice, accepting only even inputs at each step. Run 8 and 6; the latter fails at the second step. A continuation following absence must not run.

**Expected observation.** 8 produces present=1, value=2 (Just 2 / Some(2)); 6 produces absence (Nothing / None). Bind does not read an absent payload. Unit/bind laws are observational, not container-address equality.

**LMX.** LMX implements a concrete Maybe<int> with ordinary structures and Bind.apply. The present field belongs to this example type; it is neither physical uninit nor a keyword. Results explicitly copy Box and fill their own slots. No expired activation is captured.

**Comparison.** Haskell uses standard Maybe and >>=; Scala uses Option.flatMap. Their brevity includes an existing library abstraction. LMX spells out the int instance. This does not introduce a universal polymorphic Monad interface or prove laws for arbitrary effects.

**Scope and limitations.** Only optional results are compared, excluding IO, State, asynchronous effects and transformers. LMX clients must not mutate published result containers. An arbitrary object with bind is not automatically a lawful monad.

### Dependencies and execution boundaries

- **LMX:** Call Exampleun(8) and Exampleun(6). Box has data only; writes into its copied grouping container fill the returned value. The continuation receives an ordinary int.
- **Haskell:** Haskell 2010, Prelude. The existing implementation of Maybe is outside the measured listing.
- **Scala:** Scala 3 standard Option; flatMap skips the next step on None.

## Источники / Sources

- [Haskell 2010 Report, predefined types and Monad](https://www.haskell.org/onlinereport/haskell2010/haskellch6.html) — Определения Maybe и Monad; источник для контекста и законов.
- [Scala Option API](https://www.scala-lang.org/api/current/scala/Option.html) — Контракт flatMap для Option; контрольный язык.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
