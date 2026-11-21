# 017. Unit of Work

Накопить изменения и записать их одной транзакцией.

## Общий сценарий

Пометить id=7 значениями 120, затем 130, и id=9 значением 200; выполнить flush. Повторная пометка одного id заменяет предыдущее изменение.

**Ожидаемое наблюдение:** До flush записей в БД нет. Успешный flush записывает (7,130),(9,200) в одной транзакции и очищает dirty. При исключении dirty сохраняется, БД откатывается.

**Граница сравнения:** Ядро сценария. Карта сохраняет порядок первой вставки. Порт atomic гарантирует commit при нормальном возврате и rollback при исключении; nested transactions и обнаружение изменений по перехвату setters не показаны.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Work:
    @: dirty
    @: db
    int: id
    int: cents
    mark:
        node\dirty\set(id; cents)
    writeAll:
        @: rows node\dirty\entries()
        int: i 0
        while: i < length(rows)
            @: row rows[i]
            node\db\upsert(row\id; row\cents)
            i += 1
    flush:
        node\db\atomic(body := writeAll)
        node\dirty\clear()
```

dirty — явно переданная обычная карта с set/entries/clear, db — порт с upsert/atomic. atomic вызывает callback один раз в транзакции; commit/rollback реализует адаптер. node выбирает состояние этого Unit of Work. Имена формалов этих портов закреплены в примере: atomic(body: @), save(account: @), publish(event: @) или publish(ticket: @), consume(payload: @) по соответствующему листингу. Явно именованная передача сохраняет callback/контейнер целиком и исключает неоднозначность W/E.

[Отдельный листинг](examples/lmx/017_unit_of_work.lm3)

## Python

```python
class UnitOfWork:
    def __init__(self, db):
        self.db, self.dirty = db, {}
    def mark(self, id, cents):
        self.dirty[id] = cents
    def flush(self):
        def write_all():
            for id, cents in self.dirty.items():
                self.db.upsert(id, cents)
        self.db.atomic(write_all)
        self.dirty.clear()
```

Карта сохраняет порядок первой вставки. Порт atomic гарантирует commit при нормальном возврате и rollback при исключении; nested transactions и обнаружение изменений по перехвату setters не показаны.

[Отдельный листинг](examples/python/017_unit_of_work.py)

## C#

```csharp
using System;
using System.Collections.Generic;
public interface IDb {
    void Upsert(int id, int cents);
    void Atomic(Action body);
}
public sealed class UnitOfWork(IDb db) {
    readonly Dictionary<int,int> dirty = new();
    public void Mark(int id, int cents) => dirty[id] = cents;
    public void Flush() {
        db.Atomic(() => { foreach (var row in dirty) db.Upsert(row.Key,row.Value); });
        dirty.Clear();
    }
}
```

Карта сохраняет порядок первой вставки. Порт atomic гарантирует commit при нормальном возврате и rollback при исключении; nested transactions и обнаружение изменений по перехвату setters не показаны.

[Отдельный листинг](examples/csharp/017_unit_of_work.cs)

## Разбор LMX

dirty — явно переданная обычная карта с set/entries/clear, db — порт с upsert/atomic. atomic вызывает callback один раз в транзакции; commit/rollback реализует адаптер. node выбирает состояние этого Unit of Work. Имена формалов этих портов закреплены в примере: atomic(body: @), save(account: @), publish(event: @) или publish(ticket: @), consume(payload: @) по соответствующему листингу. Явно именованная передача сохраняет callback/контейнер целиком и исключает неоднозначность W/E.

## Сопоставление

Python использует dict, C# Dictionary, LMX — переданную карту. Атомарность во всех трёх версиях принадлежит одному и тому же db.atomic контракту.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 223 | 17 |
| Python | 233 | 11 |
| C# | 339 | 14 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Accumulate changes and flush them in one transaction.

**Scenario.** Mark account 7 as 120 then 130, mark account 9 as 200, then flush. Repeated IDs replace their pending value.

**Expected observation.** No writes before flush. A successful transaction writes (7,130),(9,200) and clears dirty; failure rolls back and retains dirty.

**LMX.** dirty is an explicitly supplied map with set/entries/clear; db supplies upsert/atomic. atomic invokes the callback once and owns commit/rollback. node selects this unit of work state. Relevant port formal names are fixed by this example: atomic(body: @), save(account: @), publish(event: @) or publish(ticket: @), and consume(payload: @), as applicable. Explicit naming passes the whole callback/container and removes W/E ambiguity.

**Comparison.** Python dict, C# Dictionary and an LMX map serve the same job. All three depend on the same transaction contract.

**Scope and limitations.** Insertion order is preserved. atomic commits normal completion and rolls back exceptions. Nested transactions and automatic setter tracking are outside scope.

### Dependencies and execution boundaries

- **LMX:** dirty is an explicitly supplied map with set/entries/clear; db supplies upsert/atomic. atomic invokes the callback once and owns commit/rollback. node selects this unit of work state. Relevant port formal names are fixed by this example: atomic(body: @), save(account: @), publish(event: @) or publish(ticket: @), and consume(payload: @), as applicable. Explicit naming passes the whole callback/container and removes W/E ambiguity.
- **Python:** Insertion order is preserved. atomic commits normal completion and rolls back exceptions. Nested transactions and automatic setter tracking are outside scope.
- **C#:** Insertion order is preserved. atomic commits normal completion and rolls back exceptions. Nested transactions and automatic setter tracking are outside scope.

## Источники / Sources

- [Martin Fowler — Unit of Work](https://martinfowler.com/eaaCatalog/unitOfWork.html) — Определение и границы паттерна.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
