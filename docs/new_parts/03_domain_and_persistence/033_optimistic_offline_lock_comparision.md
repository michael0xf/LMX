# 033. Optimistic Offline Lock

При сохранении проверить прочитанную версию и атомарно увеличить её.

## Общий сценарий

Две сессии прочитали id=7,version=4. Первая сохраняет 120, вторая пробует сохранить 150 со старой version=4.

**Ожидаемое наблюдение:** Первый UPDATE меняет одну строку и версию на 5. Второй меняет ноль строк и сообщает Conflict; 120 сохраняется.

**Граница сравнения:** Ядро сценария. Долгая пользовательская сессия не держит DB-lock. Повтор, merge конфликтов и атомарность нескольких агрегатов задаются отдельно.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Save:
    @: db
    int: id
    int: version
    int: cents
    execute:
        throws: Conflict
        if: db\compareAndSet(id; version; cents) != 1
            throw: Conflict()
```

db.compareAndSet(id,expected,cents) — один атомарный UPDATE с WHERE id/version и version=version+1; возвращает число строк. Не раздельные read/check/write.

[Отдельный листинг](examples/lmx/033_optimistic_offline_lock.lm3)

## Python

```python
def save(db, id, version, cents):
    if db.compare_and_set(id, version, cents) != 1:
        raise RuntimeError('conflict')
```

Долгая пользовательская сессия не держит DB-lock. Повтор, merge конфликтов и атомарность нескольких агрегатов задаются отдельно.

[Отдельный листинг](examples/python/033_optimistic_offline_lock.py)

## C#

```csharp
using System;
public interface IDb { int CompareAndSet(int id,int version,int cents); }
public static class Saves {
    public static void Save(IDb db,int id,int version,int cents) {
        if (db.CompareAndSet(id,version,cents)!=1) throw new InvalidOperationException("conflict");
    }
}
```

Долгая пользовательская сессия не держит DB-lock. Повтор, merge конфликтов и атомарность нескольких агрегатов задаются отдельно.

[Отдельный листинг](examples/csharp/033_optimistic_offline_lock.cs)

## Разбор LMX

db.compareAndSet(id,expected,cents) — один атомарный UPDATE с WHERE id/version и version=version+1; возвращает число строк. Не раздельные read/check/write.

## Сопоставление

Во всех языках корректность обеспечивается одинаковой DB-операцией; локальная проверка версии перед обычным UPDATE была бы гонкой.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 114 | 9 |
| Python | 100 | 3 |
| C# | 242 | 7 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Atomically check the observed version and increment it when saving.

**Scenario.** Two sessions read account 7 at version 4. Save 120, then try 150 with the stale version.

**Expected observation.** The first update affects one row and sets version 5; the second affects zero rows and raises Conflict. 120 remains.

**LMX.** compareAndSet is one atomic UPDATE with id/version predicate and version increment, returning affected rows; it is not read/check/write.

**Comparison.** The same database primitive provides correctness in every language. A local check before an unguarded UPDATE would race.

**Scope and limitations.** No database lock spans user think time. Retry, conflict merging and multi-aggregate atomicity need separate policy.

### Dependencies and execution boundaries

- **LMX:** compareAndSet is one atomic UPDATE with id/version predicate and version increment, returning affected rows; it is not read/check/write.
- **Python:** No database lock spans user think time. Retry, conflict merging and multi-aggregate atomicity need separate policy.
- **C#:** No database lock spans user think time. Retry, conflict merging and multi-aggregate atomicity need separate policy.

## Источники / Sources

- [Martin Fowler — Optimistic Offline Lock](https://martinfowler.com/eaaCatalog/optimisticOfflineLock.html) — Определение и границы паттерна.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
