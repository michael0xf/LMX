# 026. Table Module

Один модуль вычисляет бизнес-логику над всеми строками набора.

## Общий сценарий

Таблица содержит строки quantity=2,price=10 и quantity=3,price=7. Модуль вычисляет сумму заказа.

**Ожидаемое наблюдение:** Итог 41; строки остаются неизменными.

**Граница сравнения:** Ядро сценария. Налог, округление и переполнение исключены согласованным диапазоном целых входов. SQL и DataTable не обязательны для демонстрации Table Module.

## LMX

```lmx
OrderTable:
    @[]: rows
    return: int
    total:
        int: result 0
        int: i 0
        while: i < length(rows)
            @: row rows[i]
            result += row\quantity * row\price
            i += 1
        return: result
```

rows — массив структур quantity/price. Один метод обслуживает весь набор, не создавая доменный объект на каждую строку.

[Отдельный листинг](examples/lmx/026_table_module.lm3)

## Python

```python
class OrderTable:
    def __init__(self, rows): self.rows = rows
    def total(self):
        result = 0
        for row in self.rows:
            result += row['quantity'] * row['price']
        return result
```

Налог, округление и переполнение исключены согласованным диапазоном целых входов. SQL и DataTable не обязательны для демонстрации Table Module.

[Отдельный листинг](examples/python/026_table_module.py)

## C#

```csharp
using System.Collections.Generic;
public sealed record Row(int Quantity,int Price);
public sealed class OrderTable(IReadOnlyList<Row> rows) {
    public int Total() {
        int result=0;
        foreach (var row in rows) result += row.Quantity*row.Price;
        return result;
    }
}
```

Налог, округление и переполнение исключены согласованным диапазоном целых входов. SQL и DataTable не обязательны для демонстрации Table Module.

[Отдельный листинг](examples/csharp/026_table_module.cs)

## Разбор LMX

rows — массив структур quantity/price. Один метод обслуживает весь набор, не создавая доменный объект на каждую строку.

## Сопоставление

LMX и Python обходят строки, C# использует цикл с тем же умножением и сложением. Здесь важна единица организации логики, а не тип коллекции.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки | Без сложного Throws |
| --- | ---: | ---: | ---: |
| LMX | 131 | 11 | 131 |
| Python | 142 | 7 | — |
| C# | 224 | 9 | — |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Дополнительная колонка «без сложного Throws» оставляет заголовок и первый аргумент каждого списка в исходном порядке, полностью считает ссылки/copy и первый аргумент общего банка. Меняется только расчёт, не исходник или контракт.

## English explanation

One module applies business logic to a complete row set.

**Scenario.** Rows (quantity=2,price=10) and (quantity=3,price=7) form an order.

**Expected observation.** Total is 41; input rows remain unchanged.

**LMX.** rows is an Array of quantity/price Structures. One module owns the operation over the table.

**Comparison.** All versions perform the same multiply-and-sum loop; organization, not collection syntax, defines the pattern.

**Scope and limitations.** Inputs are bounded integers without overflow. Tax and rounding are excluded. SQL and DataTable are not required to demonstrate a Table Module.

### Dependencies and execution boundaries

- **LMX:** rows is an Array of quantity/price Structures. One module owns the operation over the table.
- **Python:** Inputs are bounded integers without overflow. Tax and rounding are excluded. SQL and DataTable are not required to demonstrate a Table Module.
- **C#:** Inputs are bounded integers without overflow. Tax and rounding are excluded. SQL and DataTable are not required to demonstrate a Table Module.

## Источники / Sources

- [Martin Fowler — Table Module](https://martinfowler.com/eaaCatalog/tableModule.html) — Определение и границы паттерна.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
