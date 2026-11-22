# 077. Multiton

Один владелец предоставляет по одному устойчивому экземпляру на каждый ключ.

## Общий сценарий

Закрытый набор ключей 0 и 1. Две выдачи ключа 0 разделяют запись value=7; ключ 1 сохраняет 0.

**Ожидаемое наблюдение:** 70.

**Граница сравнения:** Ядро сценария. Закрытый двухключевой eager registry. Не реализованы ленивый открытый dictionary, eviction и процессная/кластерная уникальность.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
First:
    int: value 0

Second:
    int: value 0

Registry:
    int: key
    return: @
    get:
        if: key = 0
            return: First
        return: Second

Demo:
    return: int
    run:
        First\value := 0
        Second\value := 0
        @: a Registry\get(key := 0)
        @: b Registry\get(key := 0)
        @: c Registry\get(key := 1)
        a\value := 7
        return: b\value * 10 + c\value
```

Вызов Demo\run(). Область уникальности — конкретный Registry в одном Message; копия графа или другой Message может иметь свой набор.

[Отдельный листинг](examples/lmx/077_multiton.lm3)

## Java

```java
class Example {
    static class Settings { int value; }
    static class Registry {
        final Settings first = new Settings(), second = new Settings();
        Settings get(int key) { return key == 0 ? first : second; }
    }
    static int demo() {
        Registry r = new Registry();
        Settings a = r.get(0), b = r.get(0), c = r.get(1);
        a.value = 7;
        return b.value * 10 + c.value;
    }
}
```

Внешний вызов Example.demo(); main и печать не считаются.

[Отдельный листинг](examples/java/077_multiton.java)

## Python

```python
class Settings:
    def __init__(self):
        self.value = 0

class Registry:
    def __init__(self):
        self.first, self.second = Settings(), Settings()
    def get(self, key):
        return self.first if key == 0 else self.second

def demo():
    registry = Registry()
    a, b, c = registry.get(0), registry.get(0), registry.get(1)
    a.value = 7
    return b.value * 10 + c.value
```

Внешний вызов demo(); все показанные классы и функции входят в измерение.

[Отдельный листинг](examples/python/077_multiton.py)

## Разбор LMX

Вызов Demo\run(). Область уникальности — конкретный Registry в одном Message; копия графа или другой Message может иметь свой набор.

## Сопоставление

В отличие от Flyweight объекты здесь изменяемы и идентифицируются ключом, а не автоматически интернированным содержимым.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 246 | 21 |
| Java | 283 | 13 |
| Python | 291 | 13 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

One owner provides one stable instance per key.

**Scenario.** For fixed keys 0 and 1, two reads of key 0 share a write of value=7; key 1 remains 0.

**Expected observation.** 70.

**LMX.** Call Demo\run(). Uniqueness is scoped to one Registry in one Message; copied graphs or other Messages can have another set.

**Comparison.** Unlike Flyweight, these objects are mutable and keyed, not automatically interned by content.

**Scope and limitations.** A fixed two-key eager registry. Lazy open dictionaries, eviction, and process/cluster-wide uniqueness are not implemented.

### Dependencies and execution boundaries

- **LMX:** Call Demo\run(). Uniqueness is scoped to one Registry in one Message; copied graphs or other Messages can have another set.
- **Java:** Call Example.demo(); main and printing are excluded.
- **Python:** Call demo(); all shown classes and functions are counted.

## Источники / Sources

- [Java Design Patterns — Multiton](https://java-design-patterns.com/patterns/multiton/) — По одному экземпляру на ключ, включая eager конечный набор.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
