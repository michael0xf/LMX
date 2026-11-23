# 031. Specification

Комбинировать предикаты, отделённые от проверяемого значения.

**Отдельное сравнение реализации:** [095. AllOf — predicate conjunction implementation](095_specification_combinator_implementation_comparision.md)

## Общий сценарий

Соединить nonnegative и below100 через AND; проверить -1,50,100.

**Ожидаемое наблюдение:** Результаты false,true,false. Правый предикат не вызывается, если левый дал false.

**Граница сравнения:** Использование библиотеки. Прикладной сценарий по-прежнему проверяет int -1,50,100. Factory допускает произвольное число predicate и общую сигнатуру, включая нулевую арность; пустому набору LMX нужен явный contract. SQL/subsumption не добавляются.

LMX вызывает операции единого ядра. Иностранные клиенты используют настоящие средства языка или установленную библиотеку; показанные рядом самостоятельные реализации в них не импортируются.

## LMX

```lmx
Predicates:
    int: value
    return: int
    nonnegative:
        return: value >= 0
    below100:
        return: value < 100

SpecificationExample:
    return: @
    build:
        throws: copy(FxThrows\adapter)
        return: allOf(predicates := (Predicates\nonnegative; Predicates\below100))
```

allOf — прямой core factory; он строит callable, а не выполняет predicates при build.

[Отдельный листинг](examples/lmx/031_specification.lm3)

## Python

```python
def nonnegative(value): return value >= 0
def below100(value): return value < 100

def build():
    return lambda value: all(p(value) for p in (nonnegative, below100))
```

Настоящий builtin all с ленивым generator; specification.py не подключается.

[Отдельный листинг](examples/python/031_specification.py)

## C#

```csharp
using System;
using System.Linq;
public static class Specifications {
    public static bool Nonnegative(int value) => value >= 0;
    public static bool Below100(int value) => value < 100;
    public static Func<int,bool> Build() {
        Func<int,bool>[] checks = [Nonnegative, Below100];
        return value => checks.All(p => p(value));
    }
}
```

Настоящий Enumerable.All сохраняет short-circuit.

[Отдельный листинг](examples/csharp/031_specification.cs)

## Разбор LMX

allOf — прямой core factory; он строит callable, а не выполняет predicates при build.

## Сопоставление

Оба исходных predicate остаются в каждом клиенте; conjunction выполняют allOf, all(generator), Enumerable.All. Обобщённые реализации — отдельно в095.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 216 | 12 |
| Python | 140 | 4 |
| C# | 274 | 10 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Compose predicates independently of their candidate values.

**Separate implementation comparison:** [095. AllOf — predicate conjunction implementation](095_specification_combinator_implementation_comparision.md)

**Scenario.** Combine nonnegative and below100 with AND; test -1,50,100.

**Expected observation.** Results are false,true,false; the right predicate is skipped when the left is false.

**LMX.** allOf is a direct core factory: build constructs a callable without evaluating predicates.

**Comparison.** The same two predicates remain in every usage client; allOf, all(generator), and Enumerable.All perform conjunction. Generic implementations are compared separately in095.

**Scope and limitations.** The application still tests int values -1,50,100. The core factory supports arbitrary finite predicate counts and common signatures, including zero inputs; an empty collection requires an explicit LMX contract. SQL generation/subsumption are outside this scenario.

### Dependencies and execution boundaries

- **LMX:** allOf is a direct core factory: build constructs a callable without evaluating predicates.
- **Python:** Real builtin all with a lazy generator; no specification.py import.
- **C#:** Real Enumerable.All preserves short-circuit evaluation.

## Источники / Sources

- [Python all](https://docs.python.org/3/library/functions.html#all) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.
- [LINQ All](https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.all) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
