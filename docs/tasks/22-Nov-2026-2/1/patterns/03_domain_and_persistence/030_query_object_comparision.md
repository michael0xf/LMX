# 030. Query Object

Представить запрос данными и централизованно перевести его в параметризованный SQL.

## Общий сценарий

Объект диапазона min=100,max=200 выбирает строки с cents внутри включительных границ.

**Ожидаемое наблюдение:** Драйвер получает SQL с двумя placeholders и параметры (100,200); данные 99,100,200,201 дают две подходящие строки.

**Граница сравнения:** Ядро сценария. Задана только грамматика диапазона одной колонки; это не универсальный SQL AST. Проверка min<=max выполняется во всех трёх вариантах.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
RangeQuery:
    int: minimum
    int: maximum
    @: db
    return: @
    execute:
        throws: Range
        if: minimum > maximum
            throw: Range()
        return: db\query("SELECT id,cents FROM account WHERE cents BETWEEN ? AND ?"; minimum; maximum)
```

Поля query обычные данные; execute выполняет их интерпретацию. db.query(sql,min,max) — явный адаптер, результат — массив строк.

[Отдельный листинг](examples/lmx/030_query_object.lm3)

## Python

```python
from dataclasses import dataclass
@dataclass(frozen=True)
class RangeQuery:
    minimum: int
    maximum: int
    def execute(self, db):
        if self.minimum > self.maximum: raise ValueError('range')
        return db.query('SELECT id,cents FROM account WHERE cents BETWEEN ? AND ?', self.minimum, self.maximum)
```

Задана только грамматика диапазона одной колонки; это не универсальный SQL AST. Проверка min<=max выполняется во всех трёх вариантах.

[Отдельный листинг](examples/python/030_query_object.py)

## C#

```csharp
using System;
public interface IDb { object Query(string sql,int minimum,int maximum); }
public sealed record RangeQuery(int Minimum,int Maximum) {
    public object Execute(IDb db) {
        if (Minimum>Maximum) throw new ArgumentException("range");
        return db.Query("SELECT id,cents FROM account WHERE cents BETWEEN ? AND ?",Minimum,Maximum);
    }
}
```

Задана только грамматика диапазона одной колонки; это не универсальный SQL AST. Проверка min<=max выполняется во всех трёх вариантах.

[Отдельный листинг](examples/csharp/030_query_object.cs)

## Разбор LMX

Поля query обычные данные; execute выполняет их интерпретацию. db.query(sql,min,max) — явный адаптер, результат — массив строк.

## Сопоставление

Объект запроса не обязан строить строку конкатенацией. Все реализации сохраняют значения отдельно от SQL.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 178 | 10 |
| Python | 254 | 8 |
| C# | 294 | 8 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Represent a query as data and translate it to parameterized SQL.

**Scenario.** A range query [100,200] filters balances inclusively.

**Expected observation.** The driver receives two placeholders and parameters (100,200); values 99,100,200,201 yield two rows.

**LMX.** Query fields are data; execute interprets them. db.query is an explicitly supplied adapter returning rows.

**Comparison.** Every implementation keeps parameters separate from SQL text.

**Scope and limitations.** Only a one-column range grammar is provided, not a universal SQL AST. Every version rejects minimum>maximum.

### Dependencies and execution boundaries

- **LMX:** Query fields are data; execute interprets them. db.query is an explicitly supplied adapter returning rows.
- **Python:** Only a one-column range grammar is provided, not a universal SQL AST. Every version rejects minimum>maximum.
- **C#:** Only a one-column range grammar is provided, not a universal SQL AST. Every version rejects minimum>maximum.

## Источники / Sources

- [Martin Fowler — Query Object](https://martinfowler.com/eaaCatalog/queryObject.html) — Определение и границы паттерна.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
