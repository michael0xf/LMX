# 016. Repository

Доменный интерфейс коллекции скрывает способ получения объектов.

**Отдельное сравнение реализации:** [094. FindFirst — generic implementation](094_find_by_id_implementation_comparision.md)

## Общий сценарий

Репозиторий получает две уже материализованные записи: id=7, cents=100 и id=9, cents=250. Найти id=9 и затем отсутствующий id=10.

**Ожидаемое наблюдение:** Первое обращение возвращает исходный объект id=9; второе — отсутствие. Сам поиск не создаёт новый экземпляр.

**Граница сравнения:** Использование библиотеки. Упорядоченный поиск сохраняет исходный объект и первый дубликат; это не ORM/индекс. LMX выражает отсутствие через none; в сценарии с ненулевыми Account допустимы None/null.

LMX вызывает операции единого ядра. Иностранные клиенты используют настоящие средства языка или установленную библиотеку; показанные рядом самостоятельные реализации в них не импортируются.

## LMX

```lmx
MatchAccount:
    int: id
    @: row
    return: int
    matches:
        return: row\id = id

Repository:
    @[]: rows
    int: id
    return: @
    find:
        throws:
            copy(FxThrows\capture)
            copy(FxThrows\predicate)
        @: accepts partial(MatchAccount\matches; (id record))
        return: findFirst(rows; accepts)
```

findFirst — прямой receiver ядра. some содержит запись найденного исходного объекта; none отделяет отсутствие от допустимого null-значения.

[Отдельный листинг](examples/lmx/016_repository.lm3)

## Python

```python
from dataclasses import dataclass

@dataclass
class Account:
    id: int
    cents: int

class Repository:
    def __init__(self, rows): self.rows = rows
    def find(self, id): return next((row for row in self.rows if row.id == id), None)
```

Используются настоящие dataclass и next(generator, default). Реализация094 не импортируется.

[Отдельный листинг](examples/python/016_repository.py)

## C#

```csharp
#nullable enable
using System.Collections.Generic;
using System.Linq;
public sealed record Account(int Id, int Cents);
public sealed class Repository(IReadOnlyList<Account> rows) {
    public Account? Find(int id) => rows.FirstOrDefault(row => row.Id == id);
}
```

Настоящий LINQ FirstOrDefault; Account сохраняет поля Id и Cents.

[Отдельный листинг](examples/csharp/016_repository.cs)

## Разбор LMX

findFirst — прямой receiver ядра. some содержит запись найденного исходного объекта; none отделяет отсутствие от допустимого null-значения.

## Сопоставление

Клиенты используют core findFirst, Python next и LINQ FirstOrDefault. Общие циклы поиска сравниваются отдельно в094; иностранные клиенты наши реализации не импортируют.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 228 | 16 |
| Python | 189 | 8 |
| C# | 227 | 7 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Domain collection access hides retrieval details.

**Separate implementation comparison:** [094. FindFirst — generic implementation](094_find_by_id_implementation_comparision.md)

**Scenario.** Use two materialized accounts (7,100) and (9,250); find 9 and then missing 10.

**Expected observation.** Return the existing account 9, then absence; do not create a second instance.

**LMX.** findFirst is a direct core receiver. some contains the existing object record; none distinguishes absence from a valid null value.

**Comparison.** The clients use core findFirst, Python next, and LINQ FirstOrDefault. The reusable first-match loops are compared separately in094; no foreign example imports our comparison implementation.

**Scope and limitations.** Ordered in-memory first match, original object identity and first duplicate preserved. This is not an ORM/index. LMX represents absence by none; the non-null Account scenario permits None/null defaults in the controls.

### Dependencies and execution boundaries

- **LMX:** findFirst is a direct core receiver. some contains the existing object record; none distinguishes absence from a valid null value.
- **Python:** Uses real dataclass and next(generator, default); implementation094 is not imported.
- **C#:** Real LINQ FirstOrDefault; Account retains both Id and Cents.

## Источники / Sources

- [Python next](https://docs.python.org/3/library/functions.html#next) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.
- [LINQ FirstOrDefault](https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.firstordefault) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
