# 075. Object Pool

Пул выдаёт ресурс во временное пользование и принимает его обратно для повторного использования.

## Общий сценарий

Пул ёмкости 1: взять ресурс, получить отказ на второй take, вернуть первый и получить ту же ссылку.

**Ожидаемое наблюдение:** 1 означает first=again и busy=null.

**Граница сравнения:** Ядро сценария. Один доверенный клиент, один корректный return. Валидация чужого/двойного return, reset ресурса, таймаут и гарантированное освобождение при исключении здесь не реализованы.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Resource:
    int: id 7

Pool:
    @: free Resource
    @: item
    return: @
    take:
        @: result node\free
        node\free := 0
        return: result
    give:
        node\free := item
        return: item

Demo:
    return: int
    run:
        Pool\free := Resource
        @: first Pool\take()
        @: busy Pool\take()
        Pool\give(item := first)
        @: again Pool\take()
        if: first = again && busy = 0
            return: 1
        return: 0
```

Вызов Demo\run(). Pool принадлежит одному Message и обслуживает последовательные запросы. Для конкурентных клиентов take/give вызываются почтовым протоколом владельца, а не чужими прямыми записями в free.

[Отдельный листинг](examples/lmx/075_object_pool.lm3)

## Java

```java
class Example {
    static class Resource { final int id = 7; }
    static class Pool {
        Resource free = new Resource();
        Resource take() { Resource result = free; free = null; return result; }
        void give(Resource item) { free = item; }
    }
    static int demo() {
        Pool pool = new Pool(); Resource first = pool.take();
        Resource busy = pool.take(); pool.give(first);
        Resource again = pool.take();
        return first == again && busy == null ? 1 : 0;
    }
}
```

Внешний вызов Example.demo(); main и печать не считаются.

[Отдельный листинг](examples/java/075_object_pool.java)

## Python

```python
class Resource:
    id = 7

class Pool:
    def __init__(self):
        self.free = Resource()
    def take(self):
        result, self.free = self.free, None
        return result
    def give(self, item):
        self.free = item

def demo():
    pool = Pool()
    first, busy = pool.take(), pool.take()
    pool.give(first)
    again = pool.take()
    return int(first is again and busy is None)
```

Внешний вызов demo(); все показанные классы и функции входят в измерение.

[Отдельный листинг](examples/python/075_object_pool.py)

## Разбор LMX

Вызов Demo\run(). Pool принадлежит одному Message и обслуживает последовательные запросы. Для конкурентных клиентов take/give вызываются почтовым протоколом владельца, а не чужими прямыми записями в free.

## Сопоставление

Все варианты показывают reuse identity, состояние занятости и возврат. Автоматическая очистка арены LMX не заменяет release внешнего ресурса.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 278 | 24 |
| Java | 350 | 14 |
| Python | 280 | 16 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

A pool lends a resource and accepts it back for reuse.

**Scenario.** A capacity-one pool: acquire, refuse a second acquisition, return the first, and acquire the same reference.

**Expected observation.** 1 means first=again and busy=null.

**LMX.** Call Demo\run(). Pool belongs to one Message and handles requests serially. Concurrent clients use the owner’s Message protocol for take/give rather than writing free directly.

**Comparison.** All versions show identity reuse, occupancy, and return. LMX arena collection does not replace release of a foreign resource.

**Scope and limitations.** One trusted client and one valid return. Foreign/double-return validation, resource reset, timeouts, and exception-safe release are not implemented.

### Dependencies and execution boundaries

- **LMX:** Call Demo\run(). Pool belongs to one Message and handles requests serially. Concurrent clients use the owner’s Message protocol for take/give rather than writing free directly.
- **Java:** Call Example.demo(); main and printing are excluded.
- **Python:** Call demo(); all shown classes and functions are counted.

## Источники / Sources

- [Apache Commons Pool — lifecycle and pooling interfaces](https://commons.apache.org/proper/commons-pool/) — Жизненный цикл acquire/reuse/return ресурса.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
