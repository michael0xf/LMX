# 085. Currying

Прямой partial строит add5 и add100 из обычной функции; процедура копирования окружения вынесена в общую реализацию.

**Сравнения реализаций:** [099. General partial-application implementation](099_integer_partial_application_implementation_comparision.md). Это ссылки для чтения, не импорты самописных модулей в контрольные usage-клиенты.

## Общий сценарий

Объявить сложение и создать независимые add5/add100 через поэтапный curry либо partial. Контрольные клиенты используют применение Haskell и Function2.curried Scala. Сохранены saved=1000 и повторный add5(1); результат 6101006.

**Ожидаемое наблюдение:** 6, 101, 6; demo возвращает 6101006. Возвращённая функция имеет ровно один явный int-вход. Библиотечный LMX-прототип не меняется; две созданные функции независимы.

**Граница сравнения.** LMX вызывает непосредственные операции текущего ядра; контрольные языки используют настоящую библиотеку или собственные средства языка. Самописные аналоги из соседних сравнений сюда не импортируются.

| Язык | Используемое средство |
| --- | --- |
| Haskell | `language: ordinary curried application` |
| Scala | `scala-library: Function2.curried` |

## LMX — поэтапный curry

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
        throws: copy(FxThrows\capture) FxCallFailure
        @: add curry(Addition\apply)
        @: add5 add(5)
        @: add100 add(100)
        int: saved 1000
        return: add5(1) * 1000000 + add100(1) * 1000 + add5(1)
```

Один общий curry создаёт две независимые ветви add5/add100. Сохранены saved=1000, повторный add5(1) и полный результат 6101006. Действующий вариант с двумя partial остаётся рядом. Полные тела и дополнительная стоимость curry раскрыты в [приложении](CURRY_ADAPTER_VARIANT.md), а не объявлены бесплатной заменой 099.

[Исходник](examples/lmx/085_currying.lm3)

## Haskell — готовое средство языка/библиотеки

```haskell
module CurryingExample where

add :: Int -> Int -> Int
add first second = first + second

demo :: Int
demo = let add5 = add 5
           add100 = add 100
           saved = 1000
       in add5 1 * 1000000 + add100 1 * 1000 + add5 1
```

Клиент использует существующее средство языка/библиотеки. Соседняя самостоятельная реализация служит отдельным сравнением и не подключается.

[Исходник](examples/haskell/085_currying.hs)

## Scala — готовое средство языка/библиотеки

```scala
object CurryingExample {
  def add(first: Int, second: Int): Int = first + second
  def demo: Int = {
    val curried = (add _).curried
    val add5 = curried(5)
    val add100 = curried(100)
    val saved = 1000
    add5(1) * 1000000 + add100(1) * 1000 + add5(1)
  }
}
```

Клиент использует существующее средство языка/библиотеки. Соседняя самостоятельная реализация служит отдельным сравнением и не подключается.

[Исходник](examples/scala/085_currying.scala)

## LMX — другой подход: прямой API ядра

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
        throws: copy(FxThrows\capture) FxCallFailure
        @: add5 partial(Addition\apply; (5))
        @: add100 partial(Addition\apply; (100))
        int: saved 1000
        return: add5(1) * 1000000 + add100(1) * 1000 + add5(1)
```

Прямое связывание двух независимых префиксов через partial; основной curry строит поэтапный интерфейс. Это разные способы построить callable.

[Исходник альтернативы](examples/lmx/variants/085_currying_core.lm3)

## Подсчёт

| Язык | Непробельные символы | Непустые строки | Без сложного Throws |
| --- | ---: | ---: | ---: |
| LMX | 236 | 15 | 223 |
| Haskell | 154 | 8 | — |
| Scala | 198 | 10 | — |

Считается только `listings[].code`, включая импорты, объявления и throws. Альтернативный подход не прибавляется к основному. [Выбор](variant_selection.json) сравнивает допустимые варианты одной границы. [Зависимости реализации](IMPLEMENTATION_DEPENDENCIES.md) показывают общие LMX-тела отдельно.

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основная цена включает их полностью. Дополнительная колонка оставляет заголовок и первый написанный аргумент списка; copy/ссылка сохраняется целиком, общий банк учитывается один раз с первым аргументом. Это только другой подсчёт, не сокращение исходника или контракта.

## Удалённые малозначимые повторы

Удалены полные повторы, отличавшиеся импортом, написанием вызова, повторением общего тела либо специализацией на int. Эти отличия не образуют отдельного текущего алгоритма; исходная редакция сохраняется в базе diff.

## Семантические границы

int относится только к прикладному сложению и числовой кодировке 6101006. Общее partial не ограничено int×int→int. Для k=N оно возвращает отложенный nullary callable и не вызывает исходную функцию при создании.

[Политика очистки, ошибок и Message/post](FAILURE_BOUNDARIES.md).

## English explanation

Direct partial builds add5 and add100 from an ordinary function; environment copying belongs to the generic implementation.

**Scenario.** Declare addition and create two independent bindings add5/add100 through staged curry or partial. Native Haskell application and Scala Function2.curried provide the control clients. Keep saved=1000 and the repeated add5(1); the result is 6101006.

**Expected.** 6, 101, 6; demo returns 6101006. The returned function has exactly one explicit int input. The LMX library prototype is unchanged and the two created functions are independent.

**Limits.** int belongs only to application addition and the numeric observation 6101006. Generic partial is not limited to int×int→int. At k=N it returns a delayed nullary callable without calling the target during construction.

Usage clients call the real language/library facility. Adjacent foreign implementations are independent comparison subjects and are not imported by usage clients. Only genuinely different approaches remain. The source listings have not been executed by an LMX/Haskell/Scala runtime in this workspace.

## Источники / Sources

- [Scala Function2.curried](https://www.scala-lang.org/api/2.13.16/scala/Function2.html)
- [Haskell curried application](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html)

**Норма LMX:** [семантика](../../LMX_semantics.en.md), [грамматика](../../LMX_grammar.en.md), [источники ядра](../LMX_Fn_Receivers/README.md).

## Проверка

[Проверка публикации](VALIDATION_2026-11-23.md) сверяет данные, исходники, отсутствие подмены библиотечных клиентов и границы подсчёта. [Acceptance matrix](acceptance_cases.json) отделяет подготовленные наблюдения от реального запуска.
