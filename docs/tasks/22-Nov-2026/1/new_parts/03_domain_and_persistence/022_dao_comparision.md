# 022. DAO — Data Access Object

Прикладной код зависит от операций доступа, а не от устройства хранилища.

## Общий сценарий

Один сервис читает баланс id=7 через DAO. Подставить адаптер БД с результатом 100, затем тестовый DAO с результатом 25.

**Ожидаемое наблюдение:** Сервис возвращает 100 и 25 без изменения своей реализации.

**Граница сравнения:** Ядро сценария. Проверка интерфейса не гарантирует корректность SQL или транзакций. Структуры адаптеров создаются и снабжаются зависимостями явно.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
DbDao:
    @: db
    int: id
    return: int
    readBalance:
        return: db\scalar("SELECT cents FROM account WHERE id = ?"; id)

FixedDao:
    int: id
    return: int
    readBalance:
        return: 25

Service:
    @: dao
    int: id
    return: int
    read:
        return: dao\readBalance(id)
```

Балансовый DAO — обычная переданная структура с методом readBalance. Реализация DbDao хранит явно заданный db; FixedDao предназначен для теста.

[Отдельный листинг](examples/lmx/022_dao.lm3)

## Python

```python
class DbDao:
    def __init__(self, db): self.db = db
    def read_balance(self, id):
        return self.db.scalar('SELECT cents FROM account WHERE id = ?', id)
class FixedDao:
    def read_balance(self, id): return 25
def read(dao, id):
    return dao.read_balance(id)
```

Проверка интерфейса не гарантирует корректность SQL или транзакций. Структуры адаптеров создаются и снабжаются зависимостями явно.

[Отдельный листинг](examples/python/022_dao.py)

## C#

```csharp
public interface IDao { int ReadBalance(int id); }
public interface IDb { int Scalar(string sql,int id); }
public sealed class DbDao(IDb db) : IDao {
    public int ReadBalance(int id) => db.Scalar("SELECT cents FROM account WHERE id = ?",id);
}
public sealed class FixedDao : IDao {
    public int ReadBalance(int id) => 25;
}
public static class Service {
    public static int Read(IDao dao,int id) => dao.ReadBalance(id);
}
```

Проверка интерфейса не гарантирует корректность SQL или транзакций. Структуры адаптеров создаются и снабжаются зависимостями явно.

[Отдельный листинг](examples/csharp/022_dao.cs)

## Разбор LMX

Балансовый DAO — обычная переданная структура с методом readBalance. Реализация DbDao хранит явно заданный db; FixedDao предназначен для теста.

## Сопоставление

Структурная совместимость LMX, duck typing Python и интерфейс C# выражают одинаковую границу. DAO здесь возвращает scalar, а Repository обычно предоставляет доменную коллекцию.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 198 | 17 |
| Python | 214 | 8 |
| C# | 349 | 11 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Application code depends on access operations rather than storage details.

**Scenario.** Call the same service with a database DAO returning 100 and a test DAO returning 25.

**Expected observation.** The service returns 100 and 25 without modification.

**LMX.** The DAO is an explicitly passed Structure with readBalance. DbDao has an explicit database dependency; FixedDao is a test adapter.

**Comparison.** LMX structural compatibility, Python duck typing and a C# interface express the boundary. This scalar DAO differs from a domain collection Repository.

**Scope and limitations.** Interface admission does not establish SQL correctness or transaction guarantees; adapters and dependencies are supplied explicitly.

### Dependencies and execution boundaries

- **LMX:** The DAO is an explicitly passed Structure with readBalance. DbDao has an explicit database dependency; FixedDao is a test adapter.
- **Python:** Interface admission does not establish SQL correctness or transaction guarantees; adapters and dependencies are supplied explicitly.
- **C#:** Interface admission does not establish SQL correctness or transaction guarantees; adapters and dependencies are supplied explicitly.

## Источники / Sources

- [Oracle — Core J2EE Patterns: Data Access Object](https://www.oracle.com/java/technologies/dataaccessobject.html) — Определение и границы паттерна.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
