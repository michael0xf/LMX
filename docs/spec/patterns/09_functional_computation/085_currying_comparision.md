# 085. Currying

Прямой partial строит add5 и add100 из обычной функции; процедура копирования окружения вынесена в общую реализацию.

**Соседнее сравнение реализации:** [099. General partial-application implementation](099_integer_partial_application_implementation_comparision.md)

## Общий сценарий

Объявить сложение и вызвать partial(add;(5)) и partial(add;(100)). Получить 6,101,6 после завершения фабрики. Локальное saved=1000 не меняет сохранённые значения. Префикс — Structure записей, а не скрытый список только int.

**Ожидаемое наблюдение:** 6, 101, 6; demo возвращает 6101006. Возвращённая функция имеет ровно один явный int-вход. Библиотечный LMX-прототип не меняется; две созданные функции независимы.

Основные варианты: LMX — **ядро: поэтапное curry**, Haskell — **обобщённая реализация**, Scala — **обобщённая реализация**. Основным считается самый короткий из рассмотренных допустимых алгоритмов текущего контракта; это выбор по символам, а не заявление о большей общности.

При одинаковом размере сохраняется прежний корректный основной вариант. Импорты, объявления и throws входят в подсчёт. Встроенные операции принадлежат одному текущему ядру; полный локальный helper допустим, когда сохраняет прикладной сценарий и включён в подсчёт. Исторические публикации остаются пояснением. Смена архитектурного механизма допустима при сохранении всей задачи, полей, эффектов и границы учитываемого кода.

## LMX — основной: ядро: поэтапное curry

```lmx
Addition:
    int: first
    int: second
    return: int
    apply:
        return: first + second

Demo:
    return: int
    run:
        throws:
            FxIndex
            FxArity
            FxRecordArity
            FxTypeToken
            FxKernelFailure
            FxCallFailure
            ReceiverIndex
            SequenceSize
        @: add curry(Addition\apply)
        @: add5 add(5)
        @: add100 add(100)
        int: saved 1000
        return: add5(1) * 1000000 + add100(1) * 1000 + add5(1)
```

Один общий curry создаёт две независимые ветви add5/add100. Сохранены saved=1000, повторный add5(1) и полный результат 6101006. Действующий вариант с двумя partial остаётся рядом. Полные тела и дополнительная стоимость curry раскрыты в [приложении](CURRY_ADAPTER_VARIANT.md), а не объявлены бесплатной заменой 099.

Тела используемых компонентов показаны рядом: [099. General partial-application implementation](099_integer_partial_application_implementation_comparision.md). Это описание текущего компонента, а не выбор версии библиотеки. Общая инфраструктура ядра раскрыта в реестре зависимостей.

[Основной листинг](examples/lmx/085_currying.lm3)

## Haskell — основной: обобщённая реализация

```haskell
module CurryingExample where
import Partial (partial)

add :: Int -> Int -> Int
add first second = first + second

demo :: Int
demo = let add5 = partial add 5
           add100 = partial add 100
       in add5 1 * 1000000 + add100 1 * 1000 + add5 1
```

Haskell2010; клиент компилируется вместе с соседним авторским модулем реализации. Прежний вариант также сохранён ниже; его размер не суммируется с новым.

Тела используемых компонентов показаны рядом: [099. General partial-application implementation](099_integer_partial_application_implementation_comparision.md). Это описание текущего компонента, а не выбор версии библиотеки. Общая инфраструктура ядра раскрыта в реестре зависимостей.

[Основной листинг](examples/haskell/085_currying.hs)

## Scala — основной: обобщённая реализация

```scala
import Partial.partial

object CurryingExample {
  def add(first: Int, second: Int): Int = first + second
  def demo: Int = {
    val add5 = partial(add, 5)
    val add100 = partial(add, 100)
    add5(1) * 1000000 + add100(1) * 1000 + add5(1)
  }
}
```

Scala 3; клиент использует соседний авторский generic-компонент. Прежний вариант сохранён ниже и исключён из нового подсчёта.

Тела используемых компонентов показаны рядом: [099. General partial-application implementation](099_integer_partial_application_implementation_comparision.md). Это описание текущего компонента, а не выбор версии библиотеки. Общая инфраструктура ядра раскрыта в реестре зависимостей.

[Основной листинг](examples/scala/085_currying.scala)

Другие сохранённые LMX варианты: [core](examples/lmx/variants/085_currying_core.lm3) — 308 символов (допустимый).

## Выбор основного кода и подсчёт

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 292 | 23 |
| Haskell | 180 | 8 |
| Scala | 189 | 9 |

Первичная таблица считает ровно `listings[].code`. Вторые варианты ниже не прибавляются к основным. [Допустимость и выбор алгоритма](variant_selection.json) воспроизводится скриптом. [Реестр зависимостей](IMPLEMENTATION_DEPENDENCIES.md) отдельно показывает, какие компоненты текущего ядра использует клиент и сколько стоит общее ядро новых ресиверов.

## LMX — исторический процедурный пример; вне текущего подсчёта

```lmx
Addition:
    int: first
    int: second
    return: int
    apply:
        return: first + second

Demo:
    return: int
    run:
        @: add5 Curry\capture(Addition\apply; 5)
        @: add100 Curry\capture(Addition\apply; 100)
        int: saved 1000
        return: add5(1) * 1000000 + add100(1) * 1000 + add5(1)
```

Сохранён исходный поясняющий листинг. Он использует прежний специализированный интерфейс/контейнер; отдельная старая библиотека не входит в текущее единое ядро.

Исторический код сохранён для разбора, но не является другой подключаемой библиотекой и не участвует в выборе алгоритма текущего общего контракта.

Историческая форма сохранена как объяснение исходного алгоритма. Она не объявляется действующей самостоятельной библиотекой или равной по общности заменой текущего ядра.

Новые реализации доступны также в [LMX_Fn_Receivers](../LMX_Fn_Receivers/README.md). Исторический специализированный пример не ограничивает текущий общий API ядра.

## Haskell — исторический специализированный пример; вне текущего подсчёта

```haskell
module CurryingExample where
import CurryInt (capture)

add :: Int -> Int -> Int
add first second = first + second

demo :: Int
demo = let add5 = capture add 5
           add100 = capture add 100
       in add5 1 * 1000000 + add100 1 * 1000 + add5 1
```

Сохранён исходный поясняющий листинг. Он использует прежний специализированный интерфейс/контейнер; отдельная старая библиотека не входит в текущее единое ядро.

Исторический код сохранён для разбора, но не является другой подключаемой библиотекой и не участвует в выборе алгоритма текущего общего контракта.

## Scala — исторический специализированный пример; вне текущего подсчёта

```scala
import CurryInt.capture

object CurryingExample {
  def add(first: Int, second: Int): Int = first + second
  def demo: Int = {
    val add5 = capture(add, 5)
    val add100 = capture(add, 100)
    add5(1) * 1000000 + add100(1) * 1000 + add5(1)
  }
}
```

Сохранён исходный поясняющий листинг. Он использует прежний специализированный интерфейс/контейнер; отдельная старая библиотека не входит в текущее единое ядро.

Исторический код сохранён для разбора, но не является другой подключаемой библиотекой и не участвует в выборе алгоритма текущего общего контракта.

## Семантические границы

**Честная граница сравнения.** Сравнивается частичное применение сложения с двумя независимыми захватами, повторным вызовом и сохранённым локальным saved. Контроли используют соседний partial-компонент, реализованный через обычное замыкание; LMX использует своё общее построение callable. Тела и стоимость построителя показаны в 099 и реестре зависимостей, а дополнительные возможности LMX по арности отдельно оговорены. Короткий curry-вариант сохраняет весь клиентский сценарий; его дополнительные LMX-тела приведены отдельно в CURRY_ADAPTER_VARIANT.md. Две независимые версии ядра не вводятся.

**Основной LMX.** Один общий curry создаёт две независимые ветви add5/add100. Сохранены saved=1000, повторный add5(1) и полный результат 6101006. Действующий вариант с двумя partial остаётся рядом. Полные тела и дополнительная стоимость curry раскрыты в [приложении](CURRY_ADAPTER_VARIANT.md), а не объявлены бесплатной заменой 099.

**Наблюдаемый общий сценарий.** int относится только к прикладному сложению и числовой кодировке 6101006. Общее partial не ограничено int×int→int. Для k=N оно возвращает отложенный nullary callable и не вызывает исходную функцию при создании.

**Возможности общего ядра.** int относится только к прикладному сложению и числовой кодировке 6101006. Общее partial не ограничено int×int→int. Для k=N оно возвращает отложенный nullary callable и не вызывает исходную функцию при создании.

Универсальный набор новых ресиверов может делать больше специализированного компактного примера. В частности, Maybe/Bounce общего пакета хранят произвольные записи, bracket не фиксирует R, partial принимает произвольный смешанный префикс. Сравнение символов не приравнивает дополнительные возможности к нулевой стоимости. Прямой record-API сообщает FxCallFailure с исходным именем внутри; действующий общий вариант bracket проверяет этот договор явно. Локальный прикладной Around передаёт ResourceFailure напрямую и целиком входит в свой клиентский листинг.

## English explanation

Direct partial builds add5 and add100 from an ordinary function; environment copying belongs to the generic implementation.

**Companion implementation:** [099. General partial-application implementation](099_integer_partial_application_implementation_comparision.md)

**Scenario.** Declare addition and call partial(add;(5)) and partial(add;(100)). Obtain 6,101,6 after the factory completes. Local saved=1000 does not change retained values. The prefix is a Structure of records, not a hidden int-only list.

**Expected observation.** 6, 101, 6; demo returns 6101006. The returned function has exactly one explicit int input. The LMX library prototype is unchanged and the two created functions are independent.

Primary is the shortest eligible complete current-contract algorithm for each language. Its imports, declarations and throws are included. The complete historical listing stays adjacent and is excluded from the primary count. Implementation comparisons retain their full generalized contracts. A usage scenario may instead use a complete counted local helper when it preserves that scenario. This does not select another core library edition; the generic component remains current.

**Primary LMX.** One general curry creates independent add5/add100 branches. saved=1000, the repeated add5(1), and the complete result 6101006 remain. The valid two-partial alternative is retained. Complete curry bodies and their additional dependency cost are disclosed in CURRY_ADAPTER_VARIANT.md, not treated as a free replacement for component 099.

**LMX variant `core`.** partial reflects the input signature, admits a prefix by ordinary rules and builds a residual callable with remaining input types and the original return. For two ints this is add5(int)→int; the helper is not specialized to it. Core operations are direct; Addition retains its original first/second fields and apply method. The catalog title Currying is retained; this particular test exercises partial application. The separate curry receiver builds unary stages and is documented in generic_functions.lmx and the receiver catalog. The two APIs are not presented as identical operations.

No execution of LMX or the control programs is claimed.

## Источники / Sources

- [Haskell 2010 Report, expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html) — Функциональное применение, лямбда и лексически сохранённое значение.
- [Scala Tour, Higher-order Functions](https://docs.scala-lang.org/tour/higher-order-functions.html) — Функция как вход и создаваемая лямбда; готовый Function2.curried в этой паре не используется.

**Норма LMX:** [семантика](../../LMX_semantics.en.md), [грамматика](../../LMX_grammar.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

[Проверка вариантов и публикации](VALIDATION_2026-11-22.md) отделяет статические сверки от фактического исполнения. [Интеграция в ядро](../../kernel-implementation.en.md#receiver-kernel-integration) описывает требуемую поддержку новых общих ресиверов.
