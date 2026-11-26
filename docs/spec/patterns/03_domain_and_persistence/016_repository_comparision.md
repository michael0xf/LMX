# 016. Repository

Доменный интерфейс коллекции скрывает способ получения объектов.

**Отдельное сравнение реализации:** [094. FindById — implementation](094_find_by_id_implementation_comparision.md)

## Общий сценарий

Репозиторий получает две уже материализованные записи: id=7, cents=100 и id=9, cents=250. Найти id=9 и затем отсутствующий id=10.

**Ожидаемое наблюдение:** Первое обращение возвращает исходный объект id=9; второе — отсутствие. Сам поиск не создаёт новый экземпляр.

**Граница сравнения:** Использование библиотеки. In-memory последовательность, совпадение по одному целочисленному id и первая запись при дубликатах. Возвращается исходный объект, не snapshot. Это не общий LINQ engine, не ORM и не индекс БД. Dataclass/record в клиенте описывает поля Account; алгоритм поиска реализован отдельно и полностью.

LMX использует существующие средства ядра или явно названную компактную группу, определённую в связанном сравнении реализации. Иностранные клиенты используют настоящие средства языка или установленную библиотеку.

## LMX

```lmx
Repository:
    []@: rows
    int: id
    return: @
    Match:
        @: row
        return: int
        accepts:
            return: row\id = id
    ---
    find:
        throws: copy(FxThrows\predicate)
        @: found findFirst(rows; Match\accepts)
        if: found\present != 0
            return: \found\value
        @: missing 0
        return: missing
```

findFirst выполняет единственный общий поиск; локальный Match задаёт только доменное равенство id. Свободный id берётся из действующего вызова Repository через обычную динамическую связь. Общий поиск не ограничен типом ключа. Maybe явно преобразуется в прежний договор клиента: исходная ссылка при успехе и нулевая ссылка при отсутствии. Тело обхода в клиенте не повторяется.

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

findFirst выполняет единственный общий поиск; локальный Match задаёт только доменное равенство id. Свободный id берётся из действующего вызова Repository через обычную динамическую связь. Общий поиск не ограничен типом ключа. Maybe явно преобразуется в прежний договор клиента: исходная ссылка при успехе и нулевая ссылка при отсутствии. Тело обхода в клиенте не повторяется.

## Сопоставление

Восстановлен исходный конечный договор 22-Nov и короткий LMX-клиент. Контрольные языки сохраняют естественные стандартные средства из 23-Nov. Узкая реализация LMX показана отдельно; более общий алгоритм 23-Nov имеет отдельный договор. Реализация LMX общая и обобщённая; контрольный клиент сохраняет оговорённый прикладной профиль. Это не утверждение равного полного охвата стандартных библиотек.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 215 | 17 |
| Python | <span style="color:#176233"><u>189</u></span> | 8 |
| C# | 227 | 7 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

Domain collection access hides retrieval details.

**Separate implementation comparison:** [094. FindById — implementation](094_find_by_id_implementation_comparision.md)

**Scenario.** Use two materialized accounts (7,100) and (9,250); find 9 and then missing 10.

**Expected observation.** Return the existing account 9, then absence; do not create a second instance.

**LMX.** findFirst performs the shared search; local Match supplies only the domain id predicate. Its free id keeps the current Repository dynamic binding. The generic search does not restrict the key type. The client explicitly converts Maybe to its established result: the original reference or a null reference, with no copied traversal.

**Comparison.** The finite 22-Nov contract and short LMX client are restored. Controls retain the natural standard facilities from 23-Nov. The narrow LMX implementation is shown separately; the wider 23-Nov algorithm has its own contract. The LMX implementation is shared and generic; the foreign client retains its stated application profile. The source comparison does not equate the complete general-purpose library coverage.

**Scope and limitations.** This is an in-memory sequence matched by one integer id, returning the first duplicate. The original object is returned, not a snapshot. It is not a LINQ engine, ORM, or database index. Client dataclass/record declarations describe Account fields; the complete search algorithm is separately implemented.

### Dependencies and execution boundaries

- **LMX:** findFirst performs the shared search; local Match supplies only the domain id predicate. Its free id keeps the current Repository dynamic binding. The generic search does not restrict the key type. The client explicitly converts Maybe to its established result: the original reference or a null reference, with no copied traversal.
- **Python:** Uses real dataclass and next(generator, default); implementation094 is not imported.
- **C#:** Real LINQ FirstOrDefault; Account retains both Id and Cents.

## Источники / Sources

- [Python next](https://docs.python.org/3/library/functions.html#next) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.
- [LINQ FirstOrDefault](https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.firstordefault) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
