# 085. Currying

Независимые сохранённые префиксы: прямое окружение и общий curry.

## Общий сценарий

Объявить сложение и создать независимые префиксы 5 и 100 через поэтапный curry либо partial. add5 используется дважды, однократная ветвь 100 вызывается сразу. Контрольные клиенты используют применение Haskell и Function2.curried Scala; результат 6101006.

**Ожидается:** 6, 101, 6; demo возвращает 6101006. Возвращённая функция имеет ровно один явный int-вход. Библиотечный LMX-прототип не меняется; две созданные функции независимы.

Общие реализации: [099. General partial-application implementation](099_integer_partial_application_implementation_comparision.md). Они учитываются отдельно; иностранные клиенты не импортируют эти сравнительные модули.

## Граница двух стилей

Процедурный вариант целиком показывает собственные окружения и прямой вызов. Функциональный использует общий curry. Независимость сохранённых5/100 и остаточная сигнатура одинаковы; общие тела ядра в099 не размножаются.

## LMX — процедурный

```lmx
CapturePrototype:
    int: saved 0
    @: binary 0
    inputs:
        int: second
        return: int
        apply:
            return: node\binary(node\saved; second)

Curry:
    @: binary
    int: first
    return: @
    capture:
        @: instance (copy(CapturePrototype))
        @: owner parent(instance\inputs)
        owner\saved := first
        owner\binary := binary
        return: instance\inputs\apply

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

[Полный исходник](examples/lmx/procedural/085_currying.lm3). 493 непробельных символов; 31 непустых строк. Все объявления и Throws включены.

## LMX — функциональный

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
        throws: copy(curry\throws) FxRecordArity
        @: add curry(Addition\apply)
        @: add5 add(5)
        return: add5(1) * 1000000 + add(100)(1) * 1000 + add5(1)
```

[Полный исходник](examples/lmx/085_currying.lm3). 205 непробельных символов; 13 непустых строк. Все объявления и Throws включены.


## Haskell

```haskell
module CurryingExample where

add :: Int -> Int -> Int
add first second = first + second

demo :: Int
demo = let add5 = add 5
       in add5 1 * 1000000 + add 100 1 * 1000 + add5 1
```

Клиент использует существующее средство языка/библиотеки. Соседняя самостоятельная реализация служит отдельным сравнением и не подключается.

[Исходник](examples/haskell/085_currying.hs)

## Scala

```scala
object CurryingExample {
  def add(first: Int, second: Int): Int = first + second
  def demo: Int = {
    val curried = (add _).curried
    val add5 = curried(5)
    add5(1) * 1000000 + curried(100)(1) * 1000 + add5(1)
  }
}
```

Клиент использует существующее средство языка/библиотеки. Соседняя самостоятельная реализация служит отдельным сравнением и не подключается.

[Исходник](examples/scala/085_currying.scala)

## Подсчёт полного текста

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 493 | 31 |
| LMX — функциональный | 205 | 13 |
| Haskell | <span style="color:#176233"><u>131</u></span> | 6 |
| Scala | 169 | 8 |

Обе LMX-записи сравниваются самостоятельно. Полный текст включает все объявления, локальные helpers и Throws; заголовки и списки ошибок не вычитаются. Общие тела ядра учитываются один раз в отдельных сравнениях. Минимум сопоставимой строки подчёркивается в PDF и XLSX зелёным; при равенстве отмечаются все победители.

Явные Throws и copy списка вызываемого метода сохраняют точный видимый договор отказов. У процедурной записи нет скрытых обходов через map/filter/fold/unique/pipe/bind или поэлементную Array-арифметику.

## Семантические границы

int относится только к прикладному сложению и числовой кодировке 6101006. Общее partial не ограничено int×int→int. Для k=N оно возвращает отложенный nullary callable и не вызывает исходную функцию при создании.

[Ошибки и Message/post](FAILURE_BOUNDARIES.md). [Общие зависимости](IMPLEMENTATION_DEPENDENCIES.md).

## English explanation

Independent captured prefixes: direct environments and the common curry operation.

**Scenario.** Declare addition and create independent prefixes 5 and 100 through staged curry or partial. Reuse add5 twice and immediately call the one-use 100 branch. Native Haskell application and Scala Function2.curried provide the control clients; the result is 6101006.

**Expected.** 6, 101, 6; demo returns 6101006. The returned function has exactly one explicit int input. The LMX library prototype is unchanged and the two created functions are independent.

**Limits.** int belongs only to application addition and the numeric observation 6101006. Generic partial is not limited to int×int→int. At k=N it returns a delayed nullary callable without calling the target during construction.

Both complete LMX client styles are counted in full. Foreign controls retain the same scenario; 085 removes unused and single-use locals consistently across languages. Implementation comparisons retain one canonical body. Revised LMX source has not been executed.

## Источники

- [Scala Function2.curried](https://www.scala-lang.org/api/2.13.16/scala/Function2.html)
- [Haskell curried application](https://www.haskell.org/onlinereport/haskell2010/haskellch3.html)

## Проверка

[Проверка публикации](VALIDATION_2026-11-26.md) проверяет обе записи и зеркала. [Acceptance cases](acceptance_cases.json) — спецификация ожидаемых наблюдений, а не LMX execution receipt.
