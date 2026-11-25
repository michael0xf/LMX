# 021. Row Data Gateway

Шлюз одной строки хранит её ключ и значения, но не доменные правила.

## Общий сценарий

Шлюз строки id=7 получает новое значение cents=150 и вызывает update.

**Ожидаемое наблюдение:** UPDATE получает параметры (150,7). В шлюзе нет правила доступного баланса или списания.

**Граница сравнения:** Ядро сценария. Отдельный finder и получение результата SQL не показаны. Конкурентное обновление без версии может перезаписать чужое изменение.

## LMX

```lmx
Row:
    @: db
    int: id 7
    int: cents 150
    return: int
    update:
        return: node\db\execute("UPDATE account SET cents = ? WHERE id = ?"; node\cents; node\id)
```

node выбирает хранимые id/cents шлюза. Внешний код может явным присваиванием изменить поле перед update.

[Отдельный листинг](examples/lmx/021_row_data_gateway.lm3)

## Python

```python
class RowGateway:
    def __init__(self, db, id, cents):
        self.db, self.id, self.cents = db, id, cents
    def update(self):
        return self.db.execute('UPDATE account SET cents = ? WHERE id = ?', self.cents, self.id)
```

Отдельный finder и получение результата SQL не показаны. Конкурентное обновление без версии может перезаписать чужое изменение.

[Отдельный листинг](examples/python/021_row_data_gateway.py)

## C#

```csharp
public interface IDb { int Execute(string sql,int cents,int id); }
public sealed class RowGateway(IDb db,int id,int cents) {
    public int Cents { get; set; } = cents;
    public int Update() => db.Execute("UPDATE account SET cents = ? WHERE id = ?",Cents,id);
}
```

Отдельный finder и получение результата SQL не показаны. Конкурентное обновление без версии может перезаписать чужое изменение.

[Отдельный листинг](examples/csharp/021_row_data_gateway.cs)

## Разбор LMX

node выбирает хранимые id/cents шлюза. Внешний код может явным присваиванием изменить поле перед update.

## Сопоставление

Один экземпляр на строку отличает этот вариант от Table Data Gateway; отсутствие доменного debit отличает его от Active Record.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | <span style="color:#176233"><u>121</u></span> | 7 |
| Python | 176 | 5 |
| C# | 214 | 5 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

A gateway for one row stores its key and values, without domain rules.

**Scenario.** For row 7, set cents to 150 and call update.

**Expected observation.** UPDATE receives (150,7); there is no balance validation or debit rule.

**LMX.** node selects the stored row fields. Client code explicitly edits cents before update.

**Comparison.** One gateway per row distinguishes this from Table Data Gateway; the absence of business operations distinguishes it from Active Record.

**Scope and limitations.** Finder construction and query results are omitted. Without a version check, concurrent updates can overwrite each other.

### Dependencies and execution boundaries

- **LMX:** node selects the stored row fields. Client code explicitly edits cents before update.
- **Python:** Finder construction and query results are omitted. Without a version check, concurrent updates can overwrite each other.
- **C#:** Finder construction and query results are omitted. Without a version check, concurrent updates can overwrite each other.

## Источники / Sources

- [Martin Fowler — Row Data Gateway](https://martinfowler.com/eaaCatalog/rowDataGateway.html) — Определение и границы паттерна.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
