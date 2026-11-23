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
        throws: OperandArity
        import: SpecificationLibrary\Operators
        return: Predicates\nonnegative both Predicates\below100
```

Клиент импортирует готовый both из SpecificationLibrary\Operators; его полный исходник находится в соседнем сравнении. Внешний driver получает predicate := SpecificationExample\build(), затем вызывает predicate(-1), predicate(50), predicate(100). Оператор бинарный: одна левая ссылка на callable и ровно одна правая; helper явно проверяет length(right)=1 и объявляет OperandArity, build распространяет этот failure. Унаследованы PASS_ARGS_AS_IS=0 и приоритет +; подготовка ссылок не исполняет предикаты. Результат — сохраняемый callable; && и сохранение ссылок показаны в реализации, а не предполагаются встроенной возможностью.

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

Клиент импортирует готовый both из SpecificationLibrary\Operators; его полный исходник находится в соседнем сравнении. Внешний driver получает predicate := SpecificationExample\build(), затем вызывает predicate(-1), predicate(50), predicate(100). Оператор бинарный: одна левая ссылка на callable и ровно одна правая; helper явно проверяет length(right)=1 и объявляет OperandArity, build распространяет этот failure. Унаследованы PASS_ARGS_AS_IS=0 и приоритет +; подготовка ссылок не исполняет предикаты. Результат — сохраняемый callable; && и сохранение ссылок показаны в реализации, а не предполагаются встроенной возможностью.

## Сопоставление

Восстановлен исходный конечный договор 22-Nov и короткий LMX-клиент. Контрольные языки сохраняют естественные стандартные средства из 23-Nov. Узкая реализация LMX показана отдельно; более общий алгоритм 23-Nov имеет отдельный договор.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки | Без сложного Throws |
| --- | ---: | ---: | ---: |
| LMX | 225 | 13 | 225 |
| Python | 140 | 4 | — |
| C# | 274 | 10 | — |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Дополнительная колонка «без сложного Throws» оставляет заголовок и первый аргумент каждого списка в исходном порядке, полностью считает ссылки/copy и первый аргумент общего банка. Меняется только расчёт, не исходник или контракт.

## English explanation

Compose predicates independently of their candidate values.

**Separate implementation comparison:** [095. Specification combinator — implementation](095_specification_combinator_implementation_comparision.md)

**Scenario.** Combine nonnegative and below100 with AND; test -1,50,100.

**Expected observation.** Results are false,true,false; the right predicate is skipped when the left is false.

**LMX.** The client imports ready both from SpecificationLibrary\Operators; the companion shows its full source. An external driver obtains predicate := SpecificationExample\build(), then invokes it for -1,50,100. The operator is binary: one left callable and exactly one right callable. The helper checks right length and declares OperandArity; build propagates it. It inherits mode 0 and additive priority; preparing references does not run predicates. The result is a reusable callable; the implementation explicitly shows reference retention and && rather than assuming a builtin combinator.

**Comparison.** The finite 22-Nov contract and short LMX client are restored. Controls retain the natural standard facilities from 23-Nov. The narrow LMX implementation is shown separately; the wider 23-Nov algorithm has its own contract.

**Scope and limitations.** Only int predicates without declared evaluation failures are included. build does not evaluate them early. SQL generation, serialization, and subsumption are excluded. Executable Specification is distinct from satisfies. Client and complete combinator implementation are measured separately.

### Dependencies and execution boundaries

- **LMX:** The client imports ready both from SpecificationLibrary\Operators; the companion shows its full source. An external driver obtains predicate := SpecificationExample\build(), then invokes it for -1,50,100. The operator is binary: one left callable and exactly one right callable. The helper checks right length and declares OperandArity; build propagates it. It inherits mode 0 and additive priority; preparing references does not run predicates. The result is a reusable callable; the implementation explicitly shows reference retention and && rather than assuming a builtin combinator.
- **Python:** Real builtin all with a lazy generator; no specification.py import.
- **C#:** Real Enumerable.All preserves short-circuit evaluation.

## Источники / Sources

- [Python all](https://docs.python.org/3/library/functions.html#all) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.
- [LINQ All](https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.all) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
