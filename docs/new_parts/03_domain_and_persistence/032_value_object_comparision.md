# 032. Value Object

Равенство определяется значением, а не адресом экземпляра.

## Общий сценарий

Сравнить отдельно созданные Money(100,840) и Money(100,840), затем Money(100,978). Currency — числовой код валюты.

**Ожидаемое наблюдение:** Первые два значения равны, третье отличается, независимо от идентичности объектов.

**Граница сравнения:** Ядро сценария. Создание неизменяемых значений и равенство — весь scope. Арифметика валют, хеширование и округление не включены.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Money:
    immutable: int: cents 100
    immutable: int: currency 840

MoneyEqual:
    @: left
    @: right
    return: int
    equals:
        return: left\cents = right\cents && left\currency = right\currency
```

Деньги представлены immutable-структурой cents/currency; equals сравнивает компоненты явно. Сравнение ссылок само по себе не получает эту семантику.

[Отдельный листинг](examples/lmx/032_value_object.lm3)

## Python

```python
from dataclasses import dataclass
@dataclass(frozen=True)
class Money:
    cents: int
    currency: int
```

Создание неизменяемых значений и равенство — весь scope. Арифметика валют, хеширование и округление не включены.

[Отдельный листинг](examples/python/032_value_object.py)

## C#

```csharp
public readonly record struct Money(int Cents,int Currency);
```

Создание неизменяемых значений и равенство — весь scope. Арифметика валют, хеширование и округление не включены.

[Отдельный листинг](examples/csharp/032_value_object.cs)

## Разбор LMX

Деньги представлены immutable-структурой cents/currency; equals сравнивает компоненты явно. Сравнение ссылок само по себе не получает эту семантику.

## Сопоставление

Python frozen dataclass и C# readonly record struct автоматически дают равенство по компонентам. В LMX показан явный предикат, не выданный за встроенное сравнение @.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 153 | 9 |
| Python | 85 | 5 |
| C# | 54 | 1 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Equality follows component values rather than object identity.

**Scenario.** Compare distinct Money(100,840) values, then compare with Money(100,978). Currency is an integer code.

**Expected observation.** The first pair is equal; the different currency is unequal, regardless of addresses.

**LMX.** Immutable cents/currency fields form the value; an explicit equals predicate compares them. Reference equality does not gain this meaning automatically.

**Comparison.** Python frozen dataclass and C# readonly record struct supply value equality; LMX shows its explicit predicate honestly.

**Scope and limitations.** Only construction and equality are covered; currency arithmetic, hashing and rounding are excluded.

### Dependencies and execution boundaries

- **LMX:** Immutable cents/currency fields form the value; an explicit equals predicate compares them. Reference equality does not gain this meaning automatically.
- **Python:** Only construction and equality are covered; currency arithmetic, hashing and rounding are excluded.
- **C#:** Only construction and equality are covered; currency arithmetic, hashing and rounding are excluded.

## Источники / Sources

- [Martin Fowler — Value Object](https://martinfowler.com/eaaCatalog/valueObject.html) — Определение и границы паттерна.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
