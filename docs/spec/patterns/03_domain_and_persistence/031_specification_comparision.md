# 031. Specification

Комбинировать предикаты, отделённые от проверяемого значения.

**Отдельное сравнение реализации:** [095. Specification combinator — implementation](095_specification_combinator_implementation_comparision.md)

## Общий сценарий

Соединить nonnegative и below100 через AND; проверить -1,50,100.

**Ожидаемое наблюдение:** Результаты false,true,false. Правый предикат не вызывается, если левый дал false.

**Граница сравнения:** Использование библиотеки. Показаны только int-предикаты без объявленных failure при проверке значения. build не выполняет проверки заранее. Генерация SQL, сериализация и subsumption не включены. Это исполняемая Specification, не satisfies. Короткий клиент и полный код combinator измеряются отдельно.

LMX использует существующие средства ядра или явно названную компактную группу, определённую в связанном сравнении реализации. Иностранные клиенты используют настоящие средства языка или установленную библиотеку.

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

allOf строит общий callable с фактической сигнатурой предикатов и коротким замыканием. Обход, проверка сигнатур и построение узла находятся в ядре; локального both нет. В примере используются два int-предиката, но построитель допускает произвольное конечное число совместимых предикатов. Пустому набору требуется явно переданный контракт. build не исполняет тела предикатов.

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

allOf строит общий callable с фактической сигнатурой предикатов и коротким замыканием. Обход, проверка сигнатур и построение узла находятся в ядре; локального both нет. В примере используются два int-предиката, но построитель допускает произвольное конечное число совместимых предикатов. Пустому набору требуется явно переданный контракт. build не исполняет тела предикатов.

## Сопоставление

Восстановлен исходный конечный договор 22-Nov и короткий LMX-клиент. Контрольные языки сохраняют естественные стандартные средства из 23-Nov. Узкая реализация LMX показана отдельно; более общий алгоритм 23-Nov имеет отдельный договор. Реализация LMX общая и обобщённая; контрольный клиент сохраняет оговорённый прикладной профиль. Это не утверждение равного полного охвата стандартных библиотек.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 216 | 12 |
| Python | <span style="color:#176233"><u>140</u></span> | 4 |
| C# | 274 | 10 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

Compose predicates independently of their candidate values.

**Separate implementation comparison:** [095. Specification combinator — implementation](095_specification_combinator_implementation_comparision.md)

**Scenario.** Combine nonnegative and below100 with AND; test -1,50,100.

**Expected observation.** Results are false,true,false; the right predicate is skipped when the left is false.

**LMX.** allOf builds a callable with the predicates' actual signature and short-circuit evaluation. Traversal, signature admission and node construction belong to the core. This client uses two integer predicates, while the builder accepts any finite compatible collection; an empty collection requires an explicit contract. build does not execute predicate bodies.

**Comparison.** The finite 22-Nov contract and short LMX client are restored. Controls retain the natural standard facilities from 23-Nov. The narrow LMX implementation is shown separately; the wider 23-Nov algorithm has its own contract. The LMX implementation is shared and generic; the foreign client retains its stated application profile. The source comparison does not equate the complete general-purpose library coverage.

**Scope and limitations.** Only int predicates without declared evaluation failures are included. build does not evaluate them early. SQL generation, serialization, and subsumption are excluded. Executable Specification is distinct from satisfies. Client and complete combinator implementation are measured separately.

### Dependencies and execution boundaries

- **LMX:** allOf builds a callable with the predicates' actual signature and short-circuit evaluation. Traversal, signature admission and node construction belong to the core. This client uses two integer predicates, while the builder accepts any finite compatible collection; an empty collection requires an explicit contract. build does not execute predicate bodies.
- **Python:** Real builtin all with a lazy generator; no specification.py import.
- **C#:** Real Enumerable.All preserves short-circuit evaluation.

## Источники / Sources

- [Python all](https://docs.python.org/3/library/functions.html#all) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.
- [LINQ All](https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.all) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
