# 085. Currying

Преобразование бинарного сложения в последовательность получения функции и её вызова с оставшимся аргументом.

## Общий сценарий

Построить add5 и add100, завершить обе фабричные активации, затем вызвать add5(1), add100(1), add5(1). Одноимённая локальная saved у вызывающего не должна менять захваченное значение.

**Ожидаемое наблюдение:** Последовательность 6, 101, 6; общий demo возвращает 6101006. Исходный прототип остаётся с saved=0. У каждой возвращённой функции один явный вход x.

**Граница сравнения:** Ядро сценария. Показано каррирование конкретного бинарного сложения, а не универсальный curry для произвольной сигнатуры. Возвращённый LMX-граф подчиняется обычному времени жизни и правилам копирования; задержка исполнения raw-аргумента с погибшим кадром здесь не используется.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
AdderPrototype:
    int: saved 0
    inputs:
        int: x
        return: int
        add:
            return: x + node\saved

AdderFactory:
    int: increment
    return: @
    create:
        @: instance (copy(AdderPrototype))
        @: lexicalOwner parent(instance\inputs)
        lexicalOwner\saved := increment
        return: instance\inputs\add

Demo:
    return: int
    run:
        @: add5 AdderFactory\create(5)
        @: add100 AdderFactory\create(100)
        int: saved 1000
        return: add5(1) * 1000000 + add100(1) * 1000 + add5(1)
```

Адаптация предоставленного примера H03. node\saved сохраняет его нормативное лексическое значение. Вход только x, а saved не становится вторым параметром.

[Отдельный листинг](examples/lmx/085_currying.lm3)

## Haskell

```haskell
module CurryingExample where

add :: Int -> Int -> Int
add saved x = saved + x

demo :: Int
demo = let add5 = add 5
           add100 = add 100
       in add5 1 * 1000000 + add100 1 * 1000 + add5 1
```

Haskell 2010. Применение add 5 создаёт функцию оставшегося аргумента без дополнительной фабрики в пользовательском коде.

[Отдельный листинг](examples/haskell/085_currying.hs)

## Scala

```scala
object CurryingExample {
  val add: (Int, Int) => Int = (saved, x) => saved + x
  val curried: Int => Int => Int = add.curried

  def demo: Int = {
    val add5 = curried(5)
    val add100 = curried(100)
    add5(1) * 1000000 + add100(1) * 1000 + add5(1)
  }
}
```

Scala 3. Здесь именно curried у Function2; несколько списков параметров метода и каррирование не объявляются одним и тем же механизмом.

[Отдельный листинг](examples/scala/085_currying.scala)

## Разбор LMX

Использован уже имеющийся в архиве приём H03: внешняя копия собирает поля, а saved записывается в фактического скопированного владельца inputs. Это явное сохранение значения в графе. Контейнер группы не принимается за владельца метода; frame фабрики не удерживается.

## Сопоставление

В Haskell функции естественно каррированы; Scala показывает Function2.curried. LMX реализует ту же наблюдаемую двухступенчатую операцию через возвращаемый метод и явное сохраняемое окружение. Это существенно длиннее встроенной функции двух функциональных языков; заменять это изменением default неверно, потому что default оставил бы дополнительный вход и возможность переопределения.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 372 | 22 |
| Haskell | 134 | 7 |
| Scala | 191 | 9 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Transform binary addition into obtaining a function and then supplying its remaining argument.

**Scenario.** Build add5 and add100, finish both factory activations, then call add5(1), add100(1), add5(1). A same-named caller local must not replace the retained value.

**Expected observation.** The values are 6, 101 and 6; demo returns the encoding 6101006. The prototype retains saved=0. Each returned function has one explicit input x.

**LMX.** This applies the existing H03 technique: the grouped copy receives fields, while saved is written into the copied actual owner of inputs. Retention is explicit in the graph, not in the finished factory frame.

**Comparison.** Haskell functions are curried; Scala uses Function2.curried. LMX implements the same two-stage observation through a returned method and explicit retained environment. This is longer than built-in currying. Merely changing a default would leave another input and possible override, changing the contract.

**Scope and limitations.** This is currying of a specific binary addition, not a generic curry for arbitrary signatures. The returned LMX graph follows ordinary lifetime and copying rules; no raw argument retains a dead frame.

### Dependencies and execution boundaries

- **LMX:** Adapted from the supplied H03 example, preserving its normative lexical node\saved behavior. x is the sole input; saved is not another parameter.
- **Haskell:** Haskell 2010. Applying add to 5 produces a function of the remaining argument.
- **Scala:** Scala 3. This explicitly uses Function2.curried, rather than conflating currying with multiple method parameter lists.

## Источники / Sources

- [Haskell 2010 Report, expressions](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html) — Функциональное применение и лямбда-выражения.
- [Scala Tour, Multiple Parameter Lists](https://docs.scala-lang.org/tour/multiple-parameter-lists.html) — Различие multiple parameter lists и Function.curried.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
