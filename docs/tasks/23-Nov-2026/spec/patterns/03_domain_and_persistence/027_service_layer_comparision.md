# 027. Service Layer

Одинаковая прикладная операция доступна разным интерфейсам через одну границу.

## Общий сценарий

CLI и HTTP-обработчик вызывают checkout(accountId=7,amount=30). Сервис загружает свежую доменную копию, выполняет debit и сохраняет её в транзакции.

**Ожидаемое наблюдение:** Оба входа выполняют одинаковую цепочку load → debit → save. При недостатке средств save не вызывается и транзакция откатывается.

**Граница сравнения:** Ядро сценария. Листинг показывает сервис, а не маршрутизатор и SQL backend. Транзакция не откатывает внешние уведомления; для них нужен outbox.

## LMX

```lmx
Checkout:
    @: db
    @: repository
    int: accountId
    int: amount
    body:
        @: account repository\load(accountId)
        account\debit(amount := amount)
        repository\save(account := account)
    execute:
        db\atomic(body := body)
```

db.atomic, repository.load/save и доменный account.debit заданы портами. load даёт свежую копию; поэтому неуспешный запрос не портит общий identity map. Для HTTP используются существующий профиль и Message intake перед сервисом. Имена формалов этих портов закреплены в примере: atomic(body: @), save(account: @), publish(event: @) или publish(ticket: @), consume(payload: @) по соответствующему листингу. Явно именованная передача сохраняет callback/контейнер целиком и исключает неоднозначность W/E.

[Отдельный листинг](examples/lmx/027_service_layer.lm3)

## Python

```python
def checkout(db, repository, account_id, amount):
    def body():
        account = repository.load(account_id)
        account.debit(amount)
        repository.save(account)
    db.atomic(body)
```

Листинг показывает сервис, а не маршрутизатор и SQL backend. Транзакция не откатывает внешние уведомления; для них нужен outbox.

[Отдельный листинг](examples/python/027_service_layer.py)

## C#

```csharp
using System;
public interface IAccount { void Debit(int amount); }
public interface IRepository {
    IAccount Load(int id);
    void Save(IAccount account);
}
public interface IDb { void Atomic(Action body); }
public static class Checkout {
    public static void Execute(IDb db,IRepository repository,int accountId,int amount) {
        db.Atomic(() => {
            IAccount account=repository.Load(accountId);
            account.Debit(amount);
            repository.Save(account);
        });
    }
}
```

Листинг показывает сервис, а не маршрутизатор и SQL backend. Транзакция не откатывает внешние уведомления; для них нужен outbox.

[Отдельный листинг](examples/csharp/027_service_layer.cs)

## Разбор LMX

db.atomic, repository.load/save и доменный account.debit заданы портами. load даёт свежую копию; поэтому неуспешный запрос не портит общий identity map. Для HTTP используются существующий профиль и Message intake перед сервисом. Имена формалов этих портов закреплены в примере: atomic(body: @), save(account: @), publish(event: @) или publish(ticket: @), consume(payload: @) по соответствующему листингу. Явно именованная передача сохраняет callback/контейнер целиком и исключает неоднозначность W/E.

## Сопоставление

Транспортные интерфейсы тонкие; сервис координирует домен и инфраструктуру. В отличие от Transaction Script, бизнес-правило debit вынесено в доменный объект.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 179 | 11 |
| Python | 150 | 6 |
| C# | 387 | 16 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Expose the same application operation to multiple interfaces.

**Scenario.** CLI and HTTP both invoke checkout(7,30). Load a fresh domain copy, debit it, then save in one transaction.

**Expected observation.** Both entrances use load → debit → save. Insufficient funds skip save and roll back the database.

**LMX.** db.atomic, repository and account.debit are explicit ports. load returns a fresh copy. LMX HTTP uses its documented profile and Message intake before the service. Relevant port formal names are fixed by this example: atomic(body: @), save(account: @), publish(event: @) or publish(ticket: @), and consume(payload: @), as applicable. Explicit naming passes the whole callback/container and removes W/E ambiguity.

**Comparison.** Transport adapters stay thin. The service coordinates the domain and infrastructure; unlike Transaction Script, debit rules live in the domain object.

**Scope and limitations.** The listing excludes HTTP routing and the SQL backend. External notifications require an outbox rather than assuming transaction rollback covers them.

### Dependencies and execution boundaries

- **LMX:** db.atomic, repository and account.debit are explicit ports. load returns a fresh copy. LMX HTTP uses its documented profile and Message intake before the service. Relevant port formal names are fixed by this example: atomic(body: @), save(account: @), publish(event: @) or publish(ticket: @), and consume(payload: @), as applicable. Explicit naming passes the whole callback/container and removes W/E ambiguity.
- **Python:** The listing excludes HTTP routing and the SQL backend. External notifications require an outbox rather than assuming transaction rollback covers them.
- **C#:** The listing excludes HTTP routing and the SQL backend. External notifications require an outbox rather than assuming transaction rollback covers them.

## Источники / Sources

- [Martin Fowler — Service Layer](https://martinfowler.com/eaaCatalog/serviceLayer.html) — Определение и границы паттерна.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
