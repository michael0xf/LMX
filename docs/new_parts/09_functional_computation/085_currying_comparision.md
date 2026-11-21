# 085. Currying

Клиент готового capture частично применяет собственное сложение и использует полученные функции после возврата фабрики.

**Реализация используемого компонента:** [099. Integer partial-application implementation](099_integer_partial_application_implementation_comparision.md)

## Общий сценарий

Объявить прикладную binary-функцию сложения. С помощью одинакового готового capture построить add5 и add100, затем получить add5(1), add100(1), add5(1). Одноимённая LMX-локальная saved=1000 не меняет сохранённые значения.

**Ожидаемое наблюдение:** 6, 101, 6; demo возвращает 6101006. Возвращённая функция имеет ровно один явный int-вход. Библиотечный LMX-прототип не меняется; две созданные функции независимы.

**Граница сравнения:** Использование библиотеки. Сравнивается частичное применение конкретной binary int×int→int, не универсальный curry, varargs или захват всех динамических локалов. OPERANDS_TEMPLATE не заменяет сохранение окружения и добавил бы здесь промежуточную форму без пользы. Отдельные implicit defaults не используются.

Готовые компоненты одинаково доступны всем трём языкам. Здесь считается клиентский код; полные реализации вынесенных компонентов показаны в связанных сравнениях выше.

## LMX

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

Вызов Demo\run(). Предварительно загрузить LMX-реализацию Curry из companion Integer partial-application implementation. Оба возвращённых callable уже пережили завершение своих фабричных вызовов.

[Отдельный листинг](examples/lmx/085_currying.lm3)

## Haskell

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

Haskell2010. Компилировать вместе с CurryInt из companion Integer partial-application implementation. Лексическое замыкание и его стоимость показаны отдельно.

[Отдельный листинг](examples/haskell/085_currying.hs)

## Scala

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

Scala 3. Компилировать с CurryInt из companion Integer partial-application implementation. Готовый .curried не используется ни клиентом, ни его helper.

[Отдельный листинг](examples/scala/085_currying.scala)

## Разбор LMX

Curry\capture — авторский helper из соседнего Integer partial-application implementation. Клиент содержит само сложение и все наблюдения. Полная работа copy/parent и сохранение binary/first показаны в companion; это не новый builtin и не удержание фабричного кадра.

## Сопоставление

Все три клиента используют готовый capture с полной собственной реализацией рядом. Прикладное сложение остаётся в каждом листинге. Haskell/Scala не заставляются вручную реализовывать граф LMX: их helper использует естественные лямбды, и эта разница видна в implementation-сравнении.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 218 | 13 |
| Haskell | 181 | 8 |
| Scala | 190 | 9 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

A client of ready capture partially applies its own addition and uses the resulting functions after factory return.

**Implementation of the supplied component:** [099. Integer partial-application implementation](099_integer_partial_application_implementation_comparision.md)

**Scenario.** Declare the application binary addition. Use the same ready capture abstraction to create add5 and add100, then obtain add5(1), add100(1), add5(1). A same-named LMX caller local saved=1000 does not change retained values.

**Expected observation.** 6, 101, 6; demo returns 6101006. The returned function has exactly one explicit int input. The LMX library prototype is unchanged and the two created functions are independent.

**LMX.** Curry\capture is the author-supplied helper from adjacent Integer partial-application implementation. The client contains addition and all observations. The complete copy/parent work and binary/first retention are shown in the companion; this is not a new built-in or retained factory frame.

**Comparison.** All three clients use ready capture with complete custom implementations alongside. Application addition remains in every listing. Haskell/Scala are not forced to recreate the LMX graph; their helpers use natural lambdas and that difference stays visible in the implementation comparison.

**Scope and limitations.** The comparison covers partial application of binary int×int→int, not universal curry, varargs or capture of all dynamic locals. OPERANDS_TEMPLATE would not replace environment retention and would add an unnecessary intermediate form. Implicit defaults are not used.

### Dependencies and execution boundaries

- **LMX:** Call Demo\run(). First load Curry from the LMX companion Integer partial-application implementation. Both returned callables outlive their completed factory invocations.
- **Haskell:** Haskell2010. Compile with CurryInt from companion Integer partial-application implementation. Its lexical closure and code cost are shown separately.
- **Scala:** Scala 3. Compile with CurryInt from companion Integer partial-application implementation. Neither client nor helper calls ready .curried.

## Источники / Sources

- [Haskell 2010 Report, expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html) — Функциональное применение, лямбда и лексически сохранённое значение.
- [Scala Tour, Higher-order Functions](https://docs.scala-lang.org/tour/higher-order-functions.html) — Функция как вход и создаваемая лямбда; готовый Function2.curried в этой паре не используется.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
