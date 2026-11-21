# 034. Pessimistic Offline Lock

Зарезервировать запись на время бизнес-сессии, не удерживая открытую SQL-транзакцию.

## Общий сценарий

Сессия A получает для id=7 lease-токен 41. B получает отказ. После окончания A новая сессия получает токен 42; запоздалый save с 41 отвергается.

**Ожидаемое наблюдение:** В каждый момент только действующий владелец может сохранить запись. Старый токен не оживает после истечения lease.

**Граница сравнения:** Протокол и порты. Показаны acquire/save/release; renewal выполняет менеджер сессии по тому же контракту. TTL, отказ сети, fencing и авторизация токена обязательны для адаптера.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Edit:
    @: locks
    @: db
    int: id
    int: session
    int: token
    int: cents
    return: int
    acquire:
        return: locks\reserve(id; session)
    save:
        return: db\writeWithLease(id; session; token; cents)
    release:
        return: locks\release(id; session; token)
```

locks.reserve/renew/release и db.writeWithLease — явные инфраструктурные порты. writeWithLease атомарно проверяет действующий lease и fencing token при записи; one Message serial lane этого не заменяет.

[Отдельный листинг](examples/lmx/034_pessimistic_offline_lock.lm3)

## Python

```python
class Edit:
    def __init__(self, locks, db): self.locks, self.db = locks, db
    def acquire(self, id, session):
        return self.locks.reserve(id, session)
    def save(self, id, session, token, cents):
        return self.db.write_with_lease(id, session, token, cents)
    def release(self, id, session, token):
        return self.locks.release(id, session, token)
```

Показаны acquire/save/release; renewal выполняет менеджер сессии по тому же контракту. TTL, отказ сети, fencing и авторизация токена обязательны для адаптера.

[Отдельный листинг](examples/python/034_pessimistic_offline_lock.py)

## C#

```csharp
public interface ILocks {
    int Reserve(int id,int session);
    int Release(int id,int session,int token);
}
public interface IDb { int WriteWithLease(int id,int session,int token,int cents); }
public sealed class Edit(ILocks locks,IDb db) {
    public int Acquire(int id,int session) => locks.Reserve(id,session);
    public int Save(int id,int session,int token,int cents) => db.WriteWithLease(id,session,token,cents);
    public int Release(int id,int session,int token) => locks.Release(id,session,token);
}
```

Показаны acquire/save/release; renewal выполняет менеджер сессии по тому же контракту. TTL, отказ сети, fencing и авторизация токена обязательны для адаптера.

[Отдельный листинг](examples/csharp/034_pessimistic_offline_lock.cs)

## Разбор LMX

locks.reserve/renew/release и db.writeWithLease — явные инфраструктурные порты. writeWithLease атомарно проверяет действующий lease и fencing token при записи; one Message serial lane этого не заменяет.

## Сопоставление

Все варианты передают токен до места записи. Объект guard или процессный mutex без серверной проверки не защищает редактирование между HTTP-запросами.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 200 | 14 |
| Python | 295 | 8 |
| C# | 438 | 10 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Reserve a row for a business session without holding one SQL transaction open.

**Scenario.** A acquires token 41 for row 7; B is refused. After A ends, a new session gets 42; a delayed write with 41 is rejected.

**Expected observation.** Only the current owner can save. Expired tokens never regain authority.

**LMX.** locks.reserve/renew/release and db.writeWithLease are explicit infrastructure ports. writeWithLease atomically validates the live lease and fencing token; one serial Message does not replace that contract.

**Comparison.** All variants carry the token to the protected write. A process-local guard does not protect editing across HTTP requests.

**Scope and limitations.** Acquire/save/release are shown; the session manager renews via the same contract. TTL, network failure, fencing and token authorization belong to the adapter.

### Dependencies and execution boundaries

- **LMX:** locks.reserve/renew/release and db.writeWithLease are explicit infrastructure ports. writeWithLease atomically validates the live lease and fencing token; one serial Message does not replace that contract.
- **Python:** Acquire/save/release are shown; the session manager renews via the same contract. TTL, network failure, fencing and token authorization belong to the adapter.
- **C#:** Acquire/save/release are shown; the session manager renews via the same contract. TTL, network failure, fencing and token authorization belong to the adapter.

## Источники / Sources

- [Martin Fowler — Pessimistic Offline Lock](https://martinfowler.com/eaaCatalog/pessimisticOfflineLock.html) — Определение и границы паттерна.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
