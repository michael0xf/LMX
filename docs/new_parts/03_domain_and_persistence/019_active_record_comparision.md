# 019. Active Record

Объект строки содержит её данные, доменную операцию и сохранение.

## Общий сценарий

Счёт id=7,cents=100 выполняет debit(30), затем save. Попытка debit(80) после этого отвергается.

**Ожидаемое наблюдение:** После первого debit значение 70, save пишет (7,70). Неверное списание не меняет 70 и не пишет БД.

**Граница сравнения:** Ядро сценария. Списание и save — отдельные вызовы. Пример не обещает автоматическую транзакцию, rollback локального объекта или конкурентную защиту.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Account:
    int: id 7
    int: cents 100
    @: db
    int: amount
    debit:
        throws: Funds
        if: amount < 0 || amount > node\cents
            throw: Funds()
        node\cents -= amount
    save:
        node\db\upsert(node\id; node\cents)
```

Состояние обновляется через node\cents. db — явно заданный порт upsert(id,cents). Debit и Save принадлежат одному фактическому DATA.

[Отдельный листинг](examples/lmx/019_active_record.lm3)

## Python

```python
class Account:
    def __init__(self, db, id=7, cents=100):
        self.db, self.id, self.cents = db, id, cents
    def debit(self, amount):
        if amount < 0 or amount > self.cents: raise ValueError('funds')
        self.cents -= amount
    def save(self):
        self.db.upsert(self.id, self.cents)
```

Списание и save — отдельные вызовы. Пример не обещает автоматическую транзакцию, rollback локального объекта или конкурентную защиту.

[Отдельный листинг](examples/python/019_active_record.py)

## C#

```csharp
using System;
public interface IDb { void Upsert(int id,int cents); }
public sealed class Account(IDb db,int id=7,int cents=100) {
    public int Cents { get; private set; } = cents;
    public void Debit(int amount) {
        if (amount < 0 || amount > Cents) throw new InvalidOperationException("funds");
        Cents -= amount;
    }
    public void Save() => db.Upsert(id,Cents);
}
```

Списание и save — отдельные вызовы. Пример не обещает автоматическую транзакцию, rollback локального объекта или конкурентную защиту.

[Отдельный листинг](examples/csharp/019_active_record.cs)

## Разбор LMX

Состояние обновляется через node\cents. db — явно заданный порт upsert(id,cents). Debit и Save принадлежат одному фактическому DATA.

## Сопоставление

Active Record соединяет правила списания и сохранение в одном объекте. В отличие от Data Mapper, объект знает свой порт хранения.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 159 | 12 |
| Python | 229 | 8 |
| C# | 300 | 10 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

A row object owns data, domain behavior and persistence.

**Scenario.** Account 7 starts with 100 cents: debit 30, save, then try to debit 80.

**Expected observation.** 70 is persisted; the invalid second debit leaves 70 unchanged and performs no write.

**LMX.** Persistent object state is updated through node. db explicitly supplies upsert. Debit and Save belong to the same actual DATA.

**Comparison.** Unlike Data Mapper, the domain object knows its storage port.

**Scope and limitations.** Debit and save are separate operations; no implicit transaction, in-memory rollback or concurrency protection is promised.

### Dependencies and execution boundaries

- **LMX:** Persistent object state is updated through node. db explicitly supplies upsert. Debit and Save belong to the same actual DATA.
- **Python:** Debit and save are separate operations; no implicit transaction, in-memory rollback or concurrency protection is promised.
- **C#:** Debit and save are separate operations; no implicit transaction, in-memory rollback or concurrency protection is promised.

## Источники / Sources

- [Martin Fowler — Active Record](https://martinfowler.com/eaaCatalog/activeRecord.html) — Определение и границы паттерна.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
