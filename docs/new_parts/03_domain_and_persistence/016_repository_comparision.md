# 016. Repository

Доменный интерфейс коллекции скрывает способ получения объектов.

## Общий сценарий

Репозиторий получает две уже материализованные записи: id=7, cents=100 и id=9, cents=250. Найти id=9 и затем отсутствующий id=10.

**Ожидаемое наблюдение:** Первое обращение возвращает исходный объект id=9; второе — отсутствие. Сам поиск не создаёт новый экземпляр.

**Граница сравнения:** Ядро сценария. Показан узкий контракт find(id); транзакции и долговременная запись не входят в сценарий.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Repository:
    []: @ rows
    int: id
    return: @
    find:
        int: i 0
        while: i < length(rows)
            @: row rows[i]
            if: row\id = id
                return: row
            i += 1
        @: missing 0
        return: missing
```

rows — переданный массив ссылок на доменные структуры; find — обычный метод. Нулевая ссылка обозначает отсутствие. Это in-memory реализация интерфейса Repository.

[Отдельный листинг](examples/lmx/016_repository.lm3)

## Python

```python
from dataclasses import dataclass
@dataclass
class Account:
    id: int
    cents: int
class Repository:
    def __init__(self, rows):
        self.rows = rows
    def find(self, id):
        return next((row for row in self.rows if row.id == id), None)
```

Показан узкий контракт find(id); транзакции и долговременная запись не входят в сценарий.

[Отдельный листинг](examples/python/016_repository.py)

## C#

```csharp
using System.Collections.Generic;
using System.Linq;
public sealed record Account(int Id, int Cents);
public sealed class Repository(IReadOnlyList<Account> rows) {
    public Account? Find(int id) => rows.FirstOrDefault(row => row.Id == id);
}
```

Показан узкий контракт find(id); транзакции и долговременная запись не входят в сценарий.

[Отдельный листинг](examples/csharp/016_repository.cs)

## Разбор LMX

rows — переданный массив ссылок на доменные структуры; find — обычный метод. Нулевая ссылка обозначает отсутствие. Это in-memory реализация интерфейса Repository.

## Сопоставление

Все три варианта выполняют одинаковый линейный поиск. Доменный интерфейс можно сохранить при замене реализации на SQL; нынешний листинг SQL не моделирует.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 126 | 13 |
| Python | 189 | 10 |
| C# | 212 | 6 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Domain collection access hides retrieval details.

**Scenario.** Use two materialized accounts (7,100) and (9,250); find 9 and then missing 10.

**Expected observation.** Return the existing account 9, then absence; do not create a second instance.

**LMX.** rows contains references to supplied domain Structures. find is an ordinary method; zero is an absent reference. This is an in-memory Repository implementation.

**Comparison.** All versions perform the same linear lookup. A SQL implementation can preserve the domain interface; SQL execution is outside this example.

**Scope and limitations.** Only find(id) is implemented; transaction management and durable writes are out of scope.

### Dependencies and execution boundaries

- **LMX:** rows contains references to supplied domain Structures. find is an ordinary method; zero is an absent reference. This is an in-memory Repository implementation.
- **Python:** Only find(id) is implemented; transaction management and durable writes are out of scope.
- **C#:** Only find(id) is implemented; transaction management and durable writes are out of scope.

## Источники / Sources

- [Martin Fowler — Repository](https://martinfowler.com/eaaCatalog/repository.html) — Определение и границы паттерна.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
