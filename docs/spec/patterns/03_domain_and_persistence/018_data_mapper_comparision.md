# 018. Data Mapper

Перевод между схемой строки и независимым доменным представлением.

## Общий сценарий

В БД строка [7,1250]; доменный объект имеет именованные поля id и cents. Загрузить его, затем сохранить cents=1300.

**Ожидаемое наблюдение:** После load: id=7,cents=1250. После save в rowStore записана строка [7,1300]. Доменный объект не содержит ссылку на БД.

**Граница сравнения:** Ядро сценария. Пример одной таблицы и двух целых колонок. Nullability, миграции схемы, отношения и SQL-драйвер требуют отдельного адаптера.

## LMX

```lmx
independent: AccountData:
    int: id 0
    int: cents 0

Mapper:
    @: rowStore
    int: id
    @: account
    return: @
    load:
        @: row rowStore\read(id)
        @: result (copy(AccountData))
        result\id := row[0]
        result\cents := row[1]
        return: result
    save:
        rowStore\write(account\id; account\cents)
        return: account
```

rowStore.read(id) возвращает массив из двух int; write(id,cents) сохраняет такую строку. AccountData — independent-шаблон готовых примитивных полей. load копирует его и явно записывает id/cents в слоты результата; доменный объект не содержит rowStore.

[Отдельный листинг](examples/lmx/018_data_mapper.lm3)

## Python

```python
from dataclasses import dataclass
@dataclass
class Account:
    id: int
    cents: int
class Mapper:
    def __init__(self, rows): self.rows = rows
    def load(self, id):
        row = self.rows.read(id)
        return Account(row[0], row[1])
    def save(self, account):
        self.rows.write(account.id, account.cents)
        return account
```

Пример одной таблицы и двух целых колонок. Nullability, миграции схемы, отношения и SQL-драйвер требуют отдельного адаптера.

[Отдельный листинг](examples/python/018_data_mapper.py)

## C#

```csharp
public sealed record Account(int Id, int Cents);
public interface IRows {
    []int Read(int id);
    void Write(int id, int cents);
}
public sealed class Mapper(IRows rows) {
    public Account Load(int id) {
        []int row = rows.Read(id);
        return new Account(row[0],row[1]);
    }
    public Account Save(Account value) {
        rows.Write(value.Id,value.Cents);
        return value;
    }
}
```

Пример одной таблицы и двух целых колонок. Nullability, миграции схемы, отношения и SQL-драйвер требуют отдельного адаптера.

[Отдельный листинг](examples/csharp/018_data_mapper.cs)

## Разбор LMX

rowStore.read(id) возвращает массив из двух int; write(id,cents) сохраняет такую строку. AccountData — independent-шаблон готовых примитивных полей. load копирует его и явно записывает id/cents в слоты результата; доменный объект не содержит rowStore.

## Сопоставление

Маппинг находится в отдельном компоненте во всех языках. Создание record/dataclass в контролях соответствует созданию обычной Structure LMX.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | <span style="color:#176233"><u>244</u></span> | 17 |
| Python | 260 | 13 |
| C# | 302 | 15 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

Map stored rows to a persistence-independent domain representation.

**Scenario.** Load row [7,1250], then save a domain account with cents=1300.

**Expected observation.** load yields id=7,cents=1250; save writes [7,1300]. The domain object holds no database reference.

**LMX.** rowStore.read(id) returns two ints; write(id,cents) persists the row. AccountData is an independent template of ready primitive fields. load copies it and explicitly replaces result slots with id/cents; the domain object has no rowStore reference.

**Comparison.** Every version separates mapping from the domain object. Records/dataclasses correspond to the ordinary LMX Structure.

**Scope and limitations.** One table and two integer columns only. Nulls, schema changes, relationships and the SQL driver need an adapter.

### Dependencies and execution boundaries

- **LMX:** rowStore.read(id) returns two ints; write(id,cents) persists the row. AccountData is an independent template of ready primitive fields. load copies it and explicitly replaces result slots with id/cents; the domain object has no rowStore reference.
- **Python:** One table and two integer columns only. Nulls, schema changes, relationships and the SQL driver need an adapter.
- **C#:** One table and two integer columns only. Nulls, schema changes, relationships and the SQL driver need an adapter.

## Источники / Sources

- [Martin Fowler — Data Mapper](https://martinfowler.com/eaaCatalog/dataMapper.html) — Определение и границы паттерна.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
