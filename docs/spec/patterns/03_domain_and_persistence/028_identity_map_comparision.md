# 028. Identity Map

Одна сессия возвращает один объект для одного ключа.

## Общий сценарий

Вызвать get(7) дважды, затем get(9); loader создаёт новый объект при каждом реальном чтении.

**Ожидаемое наблюдение:** Loader вызывается дважды. Два результата для id=7 имеют одну идентичность; объект id=9 другой.

**Граница сравнения:** Ядро сценария. Один последовательный владелец; конкурентный miss требует координации. Инвалидация между транзакциями и составные ключи задаются приложением.

## LMX

```lmx
Session:
    @: cache
    @: load
    int: id
    return: @
    get:
        if: !cache\has(id)
            cache\set(id; load(id))
        return: cache\get(id)
```

cache — явная карта с has/get/set; load — переданный callable. Identity Map принадлежит одной сессии или одному Message, не скрытому глобальному registry.

[Отдельный листинг](examples/lmx/028_identity_map.lm3)

## Python

```python
class Session:
    def __init__(self, load): self.load, self.cache = load, {}
    def get(self, id):
        if id not in self.cache:
            self.cache[id] = self.load(id)
        return self.cache[id]
```

Один последовательный владелец; конкурентный miss требует координации. Инвалидация между транзакциями и составные ключи задаются приложением.

[Отдельный листинг](examples/python/028_identity_map.py)

## C#

```csharp
using System;
using System.Collections.Generic;
public sealed class Session(Func<int,object> load) {
    readonly Dictionary<int,object> cache = new();
    public object Get(int id) {
        if (!cache.TryGetValue(id,out var value)) {
            value=load(id);
            cache.Add(id,value);
        }
        return value;
    }
}
```

Один последовательный владелец; конкурентный miss требует координации. Инвалидация между транзакциями и составные ключи задаются приложением.

[Отдельный листинг](examples/csharp/028_identity_map.cs)

## Разбор LMX

cache — явная карта с has/get/set; load — переданный callable. Identity Map принадлежит одной сессии или одному Message, не скрытому глобальному registry.

## Сопоставление

Словарь Python, Dictionary C# и карта LMX хранят именно ссылки. Копирование объекта при каждом get уничтожило бы смысл паттерна.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 98 | 9 |
| Python | 148 | 6 |
| C# | 245 | 12 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

One session returns one object identity per key.

**Scenario.** Call get(7), get(7), get(9). The loader creates a fresh object on each real read.

**Expected observation.** The loader runs twice. Both results for 7 are the same object; the result for 9 differs.

**LMX.** cache supplies has/get/set; load is explicit. The identity map belongs to a session or one Message, never a hidden process registry.

**Comparison.** Each implementation stores references. Copying on every get would violate the identity requirement.

**Scope and limitations.** The owner is serial; concurrent misses need coordination. Cross-transaction invalidation and composite keys are application policy.

### Dependencies and execution boundaries

- **LMX:** cache supplies has/get/set; load is explicit. The identity map belongs to a session or one Message, never a hidden process registry.
- **Python:** The owner is serial; concurrent misses need coordination. Cross-transaction invalidation and composite keys are application policy.
- **C#:** The owner is serial; concurrent misses need coordination. Cross-transaction invalidation and composite keys are application policy.

## Источники / Sources

- [Martin Fowler — Identity Map](https://martinfowler.com/eaaCatalog/identityMap.html) — Определение и границы паттерна.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
