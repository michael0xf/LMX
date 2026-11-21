# 031. Specification

Комбинировать предикаты, отделённые от проверяемого значения.

## Общий сценарий

Соединить nonnegative и below100 через AND; проверить -1,50,100.

**Ожидаемое наблюдение:** Результаты false,true,false. Правый предикат не вызывается, если левый дал false.

**Граница сравнения:** Ядро сценария. Не реализованы вывод SQL, доказательство subsumption и сериализация предикатов. Это исполняемая Specification, не структурный implements.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Predicates:
    int: value
    return: int
    nonnegative:
        return: value >= 0
    below100:
        return: value < 100

And:
    @: left
    @: right
    int: value
    return: int
    accepts:
        return: left(value) && right(value)
```

left и right — ссылки на обычные callable; && сохраняет короткое замыкание. Два готовых предиката и общий combinator имеют одинаковый вход int.

[Отдельный листинг](examples/lmx/031_specification.lm3)

## Python

```python
def nonnegative(value): return value >= 0
def below100(value): return value < 100
def both(left, right):
    return lambda value: left(value) and right(value)
```

Не реализованы вывод SQL, доказательство subsumption и сериализация предикатов. Это исполняемая Specification, не структурный implements.

[Отдельный листинг](examples/python/031_specification.py)

## C#

```csharp
using System;
public static class Specifications {
    public static bool Nonnegative(int value) => value>=0;
    public static bool Below100(int value) => value<100;
    public static Func<int,bool> Both(Func<int,bool> left,Func<int,bool> right) =>
        value => left(value) && right(value);
}
```

Не реализованы вывод SQL, доказательство subsumption и сериализация предикатов. Это исполняемая Specification, не структурный implements.

[Отдельный листинг](examples/csharp/031_specification.cs)

## Разбор LMX

left и right — ссылки на обычные callable; && сохраняет короткое замыкание. Два готовых предиката и общий combinator имеют одинаковый вход int.

## Сопоставление

LMX использует обычные методы, Python функции, C# Func. Иерархия классов не нужна, когда задача состоит только в композиции предикатов.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 158 | 14 |
| Python | 134 | 4 |
| C# | 244 | 7 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Compose predicates independently of their candidate values.

**Scenario.** Combine nonnegative and below100 with AND; test -1,50,100.

**Expected observation.** Results are false,true,false; the right predicate is skipped when the left is false.

**LMX.** left/right are ordinary callable references; && short-circuits. All predicates consume int.

**Comparison.** Ordinary methods, functions and Func are sufficient; a class hierarchy is not required.

**Scope and limitations.** No SQL generation, subsumption proof or predicate serialization is included. Executable Specification is distinct from structural implements.

### Dependencies and execution boundaries

- **LMX:** left/right are ordinary callable references; && short-circuits. All predicates consume int.
- **Python:** No SQL generation, subsumption proof or predicate serialization is included. Executable Specification is distinct from structural implements.
- **C#:** No SQL generation, subsumption proof or predicate serialization is included. Executable Specification is distinct from structural implements.

## Источники / Sources

- [Eric Evans and Martin Fowler — Specifications](https://martinfowler.com/apsupp/spec.pdf) — Определение и границы паттерна.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
