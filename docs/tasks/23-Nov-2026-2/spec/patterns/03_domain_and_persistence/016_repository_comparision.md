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
    @[]: rows
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

Repository сохраняет последовательность доменных записей и делегирует поиск импортируемому FindLibrary. Его полный цикл показан в соседнем сравнении. import находится в CODE find, поэтому DATA Repository остаётся rows/id/return. rows findById id передаёт одну целую последовательность слева и один int справа; массив не раскрывается. Оператор наследует готовые режим 0 и приоритет + и проверяет right length=1. Возвращается ссылка на первую исходную запись либо 0; копия записи не создаётся.

## Сопоставление

Восстановлен исходный конечный договор 22-Nov и короткий LMX-клиент. Контрольные языки сохраняют естественные стандартные средства из 23-Nov. Узкая реализация LMX показана отдельно; более общий алгоритм 23-Nov имеет отдельный договор.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки | Без сложного Throws |
| --- | ---: | ---: | ---: |
| LMX | 96 | 8 | 96 |
| Python | 189 | 8 | — |
| C# | 227 | 7 | — |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Дополнительная колонка «без сложного Throws» оставляет заголовок и первый аргумент каждого списка в исходном порядке, полностью считает ссылки/copy и первый аргумент общего банка. Меняется только расчёт, не исходник или контракт.

## English explanation

Domain collection access hides retrieval details.

**Separate implementation comparison:** [094. FindById — implementation](094_find_by_id_implementation_comparision.md)

**Scenario.** Use two materialized accounts (7,100) and (9,250); find 9 and then missing 10.

**Expected observation.** Return the existing account 9, then absence; do not create a second instance.

**LMX.** Repository retains its domain-record sequence and delegates lookup to imported FindLibrary; the companion shows its full loop. import is in find CODE, so Repository DATA remains rows/id/return. rows findById id passes one whole sequence on the left and one int on the right; no array expansion occurs. The operand inherits ready mode 0 and additive priority and checks right length=1. It returns the first original record reference or 0, without copying a row.

**Comparison.** The finite 22-Nov contract and short LMX client are restored. Controls retain the natural standard facilities from 23-Nov. The narrow LMX implementation is shown separately; the wider 23-Nov algorithm has its own contract.

**Scope and limitations.** This is an in-memory sequence matched by one integer id, returning the first duplicate. The original object is returned, not a snapshot. It is not a LINQ engine, ORM, or database index. Client dataclass/record declarations describe Account fields; the complete search algorithm is separately implemented.

### Dependencies and execution boundaries

- **LMX:** Repository retains its domain-record sequence and delegates lookup to imported FindLibrary; the companion shows its full loop. import is in find CODE, so Repository DATA remains rows/id/return. rows findById id passes one whole sequence on the left and one int on the right; no array expansion occurs. The operand inherits ready mode 0 and additive priority and checks right length=1. It returns the first original record reference or 0, without copying a row.
- **Python:** Uses real dataclass and next(generator, default); implementation094 is not imported.
- **C#:** Real LINQ FirstOrDefault; Account retains both Id and Cents.

## Источники / Sources

- [Python next](https://docs.python.org/3/library/functions.html#next) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.
- [LINQ FirstOrDefault](https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.firstordefault) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
