# 020. Table Data Gateway

Один шлюз обслуживает все строки таблицы.

## Общий сценарий

Прочитать balance строки 7, затем обновить balance строки 9 на 200. SQL и параметры сосредоточены в шлюзе.

**Ожидаемое наблюдение:** Вызваны SELECT с id=7 и UPDATE с cents=200,id=9; данные не вставлены в текст SQL.

**Граница сравнения:** Ядро сценария. Синтаксис ? в учебном драйвере — позиционный placeholder; адаптер переводит его в синтаксис конкретной БД. Транзакция определяется вызывающим.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Accounts:
    @: db
    int: id
    int: cents
    return: int
    balance:
        return: db\scalar("SELECT cents FROM account WHERE id = ?"; id)
    update:
        return: db\execute("UPDATE account SET cents = ? WHERE id = ?"; cents; id)
```

db.scalar(sql,id) и db.execute(sql,cents,id) — явно переданный драйвер параметризованных запросов. Текст SQL одинаков для всех трёх вариантов.

[Отдельный листинг](examples/lmx/020_table_data_gateway.lm3)

## Python

```python
class Accounts:
    def __init__(self, db): self.db = db
    def balance(self, id):
        return self.db.scalar('SELECT cents FROM account WHERE id = ?', id)
    def update(self, id, cents):
        return self.db.execute('UPDATE account SET cents = ? WHERE id = ?', cents, id)
```

Синтаксис ? в учебном драйвере — позиционный placeholder; адаптер переводит его в синтаксис конкретной БД. Транзакция определяется вызывающим.

[Отдельный листинг](examples/python/020_table_data_gateway.py)

## C#

```csharp
public interface IDb {
    int Scalar(string sql,int id);
    int Execute(string sql,int cents,int id);
}
public sealed class Accounts(IDb db) {
    public int Balance(int id) => db.Scalar("SELECT cents FROM account WHERE id = ?",id);
    public int Update(int id,int cents) => db.Execute("UPDATE account SET cents = ? WHERE id = ?",cents,id);
}
```

Синтаксис ? в учебном драйвере — позиционный placeholder; адаптер переводит его в синтаксис конкретной БД. Транзакция определяется вызывающим.

[Отдельный листинг](examples/csharp/020_table_data_gateway.cs)

## Разбор LMX

db.scalar(sql,id) и db.execute(sql,cents,id) — явно переданный драйвер параметризованных запросов. Текст SQL одинаков для всех трёх вариантов.

## Сопоставление

LMX объединяет операции структурой, Python и C# классом. Это шлюз таблицы, а не объект одной строки.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 169 | 9 |
| Python | 214 | 6 |
| C# | 280 | 8 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

One gateway serves every row in a table.

**Scenario.** Read account 7; update account 9 to 200 cents. Keep SQL and parameters in the gateway.

**Expected observation.** Run a parameterized SELECT for 7 and UPDATE for (200,9); do not concatenate values into SQL.

**LMX.** db.scalar and db.execute are explicit parameterized-driver methods, with identical SQL in all listings.

**Comparison.** An LMX Structure or a Python/C# class groups table-wide operations; this is not one object per row.

**Scope and limitations.** The teaching driver uses positional ? placeholders and adapts them for its database. Transactions belong to the caller.

### Dependencies and execution boundaries

- **LMX:** db.scalar and db.execute are explicit parameterized-driver methods, with identical SQL in all listings.
- **Python:** The teaching driver uses positional ? placeholders and adapts them for its database. Transactions belong to the caller.
- **C#:** The teaching driver uses positional ? placeholders and adapts them for its database. Transactions belong to the caller.

## Источники / Sources

- [Martin Fowler — Table Data Gateway](https://martinfowler.com/eaaCatalog/tableDataGateway.html) — Определение и границы паттерна.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
