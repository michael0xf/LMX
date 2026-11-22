# 016. Repository

Доменный интерфейс коллекции скрывает способ получения объектов.

**Реализация используемого компонента:** [094. FindById — implementation](094_find_by_id_implementation_comparision.md)

## Общий сценарий

Репозиторий получает две уже материализованные записи: id=7, cents=100 и id=9, cents=250. Найти id=9 и затем отсутствующий id=10.

**Ожидаемое наблюдение:** Первое обращение возвращает исходный объект id=9; второе — отсутствие. Сам поиск не создаёт новый экземпляр.

**Граница сравнения:** Использование библиотеки. In-memory последовательность, совпадение по одному целочисленному id и первая запись при дубликатах. Возвращается исходный объект, не snapshot. Это не общий LINQ engine, не ORM и не индекс БД. Dataclass/record в клиенте описывает поля Account; алгоритм поиска реализован отдельно и полностью.

Готовые компоненты одинаково доступны всем трём языкам. Здесь считается клиентский код; полные реализации вынесенных компонентов показаны в связанных сравнениях выше.

## LMX

```lmx
Repository:
    []: @ rows
    int: id
    return: @
    find:
        throws: OperandArity
        import: FindLibrary
        return: rows findById id
```

Repository сохраняет последовательность доменных записей и делегирует поиск импортируемому FindLibrary. Его полный цикл показан в соседнем сравнении. import находится в CODE find, поэтому DATA Repository остаётся rows/id/return. rows findById id передаёт одну целую последовательность слева и один int справа; массив не раскрывается. Оператор наследует готовые режим 0 и приоритет + и проверяет right length=1. Возвращается ссылка на первую исходную запись либо 0; копия записи не создаётся.

[Отдельный листинг](examples/lmx/016_repository.lm3)

## Python

```python
from dataclasses import dataclass
from lookup import find_by_id

@dataclass
class Account:
    id: int
    cents: int

class Repository:
    def __init__(self, rows): self.rows = rows
    def find(self, id): return find_by_id(self.rows, id)
```

Модуль lookup.py полностью дан в companion; dataclass остаётся декларацией клиентской Account.

[Отдельный листинг](examples/python/016_repository.py)

## C#

```csharp
using System.Collections.Generic;
using ExampleLib;
public sealed record Account(int Id, int Cents) : IIdentified;
public sealed class Repository(IReadOnlyList<Account> rows) {
    public Account? Find(int id) => Records.FindById(rows, id);
}
```

ExampleLib.Records и IIdentified полностью даны в companion. Account — клиентский доменный record, реализующий только Id-контракт.

[Отдельный листинг](examples/csharp/016_repository.cs)

## Разбор LMX

Repository сохраняет последовательность доменных записей и делегирует поиск импортируемому FindLibrary. Его полный цикл показан в соседнем сравнении. import находится в CODE find, поэтому DATA Repository остаётся rows/id/return. rows findById id передаёт одну целую последовательность слева и один int справа; массив не раскрывается. Оператор наследует готовые режим 0 и приоритет + и проверяет right length=1. Возвращается ссылка на первую исходную запись либо 0; копия записи не создаётся.

## Сопоставление

Во всех трёх клиентах готовый FindById — небольшой прикладной helper для последовательности записей с id, а доменная Account и граница Repository остаются клиентскими. Соседняя реализация раскрывает цикл, ранний возврат и отсутствие во всех языках. Это не сравнение готового LINQ с ручным циклом только в LMX.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 96 | 8 |
| Python | 194 | 9 |
| C# | 212 | 6 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Domain collection access hides retrieval details.

**Implementation of the supplied component:** [094. FindById — implementation](094_find_by_id_implementation_comparision.md)

**Scenario.** Use two materialized accounts (7,100) and (9,250); find 9 and then missing 10.

**Expected observation.** Return the existing account 9, then absence; do not create a second instance.

**LMX.** Repository retains its domain-record sequence and delegates lookup to imported FindLibrary; the companion shows its full loop. import is in find CODE, so Repository DATA remains rows/id/return. rows findById id passes one whole sequence on the left and one int on the right; no array expansion occurs. The operand inherits ready mode 0 and additive priority and checks right length=1. It returns the first original record reference or 0, without copying a row.

**Comparison.** All clients use a ready, narrow FindById helper over records with id while retaining the domain Account and repository boundary. The companion exposes iteration, early return, and absence in every language. Ready LINQ is not compared against a manual loop only in LMX.

**Scope and limitations.** This is an in-memory sequence matched by one integer id, returning the first duplicate. The original object is returned, not a snapshot. It is not a LINQ engine, ORM, or database index. Client dataclass/record declarations describe Account fields; the complete search algorithm is separately implemented.

### Dependencies and execution boundaries

- **LMX:** Repository retains its domain-record sequence and delegates lookup to imported FindLibrary; the companion shows its full loop. import is in find CODE, so Repository DATA remains rows/id/return. rows findById id passes one whole sequence on the left and one int on the right; no array expansion occurs. The operand inherits ready mode 0 and additive priority and checks right length=1. It returns the first original record reference or 0, without copying a row.
- **Python:** The companion fully supplies lookup.py; dataclass remains the client Account declaration.
- **C#:** The companion fully supplies ExampleLib.Records and IIdentified. Account is the client domain record implementing the Id contract.

## Источники / Sources

- [Martin Fowler — Repository](https://martinfowler.com/eaaCatalog/repository.html) — Определение и границы паттерна.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
