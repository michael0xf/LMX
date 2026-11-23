# 025. Transaction Script

Одна процедура организует один прикладной запрос.

## Общий сценарий

Перевести 30 из счёта 1 со 100 единицами на счёт 2 с 20 единицами; повторить в отдельной транзакции недопустимый перевод 200.

**Ожидаемое наблюдение:** Первый запрос атомарно даёт 70 и 50. Второй не меняет остатки и сообщает Funds.

**Граница сравнения:** Ядро сценария. Одинаковый контракт атомарности и блокировок задан для всех вариантов. Исключения откатывают БД, но не произвольные внешние эффекты.

## LMX

```lmx
Transfer:
    @: db
    int: fromId
    int: toId
    int: amount
    body:
        throws: Funds
        int: a db\readLocked(fromId)
        int: b db\readLocked(toId)
        if: amount < 0 || fromId = toId || a < amount
            throw: Funds()
        db\write(fromId; a - amount)
        db\write(toId; b + amount)
    execute:
        db\atomic(body := body)
```

db.atomic вызывает body синхронно; readLocked блокирует нужную строку до конца транзакции. В сценарии fromId < toId; для общего случая нужен единый порядок захвата. Все db-методы — порт адаптера. Имена формалов этих портов закреплены в примере: atomic(body: @), save(account: @), publish(event: @) или publish(ticket: @), consume(payload: @) по соответствующему листингу. Явно именованная передача сохраняет callback/контейнер целиком и исключает неоднозначность W/E.

[Отдельный листинг](examples/lmx/025_transaction_script.lm3)

## Python

```python
def transfer(db, from_id, to_id, amount):
    def body():
        a, b = db.read_locked(from_id), db.read_locked(to_id)
        if amount < 0 or from_id == to_id or a < amount:
            raise ValueError('funds')
        db.write(from_id, a - amount)
        db.write(to_id, b + amount)
    db.atomic(body)
```

Одинаковый контракт атомарности и блокировок задан для всех вариантов. Исключения откатывают БД, но не произвольные внешние эффекты.

[Отдельный листинг](examples/python/025_transaction_script.py)

## C#

```csharp
using System;
public interface IDb {
    int ReadLocked(int id);
    void Write(int id,int value);
    void Atomic(Action body);
}
public static class Transfers {
    public static void Transfer(IDb db,int fromId,int toId,int amount) {
        db.Atomic(() => {
            int a=db.ReadLocked(fromId), b=db.ReadLocked(toId);
            if (amount<0 || fromId==toId || a<amount) throw new InvalidOperationException("funds");
            db.Write(fromId,a-amount);
            db.Write(toId,b+amount);
        });
    }
}
```

Одинаковый контракт атомарности и блокировок задан для всех вариантов. Исключения откатывают БД, но не произвольные внешние эффекты.

[Отдельный листинг](examples/csharp/025_transaction_script.cs)

## Разбор LMX

db.atomic вызывает body синхронно; readLocked блокирует нужную строку до конца транзакции. В сценарии fromId < toId; для общего случая нужен единый порядок захвата. Все db-методы — порт адаптера. Имена формалов этих портов закреплены в примере: atomic(body: @), save(account: @), publish(event: @) или publish(ticket: @), consume(payload: @) по соответствующему листингу. Явно именованная передача сохраняет callback/контейнер целиком и исключает неоднозначность W/E.

## Сопоставление

Правило и последовательность работы с БД находятся в одной процедуре каждого языка. Объекты доменной модели не обязательны для этого паттерна.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 232 | 15 |
| Python | 222 | 8 |
| C# | 387 | 16 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

One procedure handles one application request.

**Scenario.** Transfer 30 from account 1 (100) to account 2 (20), then attempt 200 in a separate transaction.

**Expected observation.** The first request atomically produces 70 and 50; the second raises Funds and changes neither balance.

**LMX.** db.atomic runs body synchronously; readLocked holds each row lock to transaction end. This scenario uses fromId < toId; a general API needs consistent lock ordering. These are adapter methods. Relevant port formal names are fixed by this example: atomic(body: @), save(account: @), publish(event: @) or publish(ticket: @), and consume(payload: @), as applicable. Explicit naming passes the whole callback/container and removes W/E ambiguity.

**Comparison.** Each language places the request rule and database sequence in one procedure; a rich domain object hierarchy is unnecessary.

**Scope and limitations.** All versions use the same atomicity and locking contract. Rollback covers database changes, not arbitrary external effects.

### Dependencies and execution boundaries

- **LMX:** db.atomic runs body synchronously; readLocked holds each row lock to transaction end. This scenario uses fromId < toId; a general API needs consistent lock ordering. These are adapter methods. Relevant port formal names are fixed by this example: atomic(body: @), save(account: @), publish(event: @) or publish(ticket: @), and consume(payload: @), as applicable. Explicit naming passes the whole callback/container and removes W/E ambiguity.
- **Python:** All versions use the same atomicity and locking contract. Rollback covers database changes, not arbitrary external effects.
- **C#:** All versions use the same atomicity and locking contract. Rollback covers database changes, not arbitrary external effects.

## Источники / Sources

- [Martin Fowler — Transaction Script](https://martinfowler.com/eaaCatalog/transactionScript.html) — Определение и границы паттерна.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
