# 072. Dependency Injection

Клиент получает готовую зависимость от места сборки приложения.

## Общий сценарий

Один клиент читает число из двух переданных источников и удваивает его. Источники возвращают 5 и 7.

**Ожидаемое наблюдение:** 10 + 14 = 24.

**Граница сравнения:** Ядро сценария. Scope dependency — один client/call. Контейнер DI, автоматическое сканирование, lifetime scopes и циклы зависимостей в задачу не входят.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Sources:
    return: int
    first:
        return: 5
    second:
        return: 7

Client:
    @: read
    return: int
    execute:
        return: read() * 2
    demo:
        return: execute(read := Sources\first) + execute(read := Sources\second)
```

Вызов Client\demo(). Именованный actual read явно задаёт зависимость; это не неявное автодозаполнение и не скрытый registry.

[Отдельный листинг](examples/lmx/072_dependency_injection.lm3)

## Java

```java
import java.util.function.IntSupplier;
class Example {
    static class Client {
        final IntSupplier read;
        Client(IntSupplier read) { this.read = read; }
        int execute() { return read.getAsInt() * 2; }
    }
    static int demo() { return new Client(() -> 5).execute() + new Client(() -> 7).execute(); }
}
```

Внешний вызов Example.demo(); main и печать не считаются.

[Отдельный листинг](examples/java/072_dependency_injection.java)

## Python

```python
class Client:
    def __init__(self, read):
        self.read = read
    def execute(self):
        return self.read() * 2

def demo():
    return Client(lambda: 5).execute() + Client(lambda: 7).execute()
```

Внешний вызов demo(); все показанные классы и функции входят в измерение.

[Отдельный листинг](examples/python/072_dependency_injection.py)

## Разбор LMX

Вызов Client\demo(). Именованный actual read явно задаёт зависимость; это не неявное автодозаполнение и не скрытый registry.

## Сопоставление

LMX показывает injection при вызове, Java/Python — через конструктор объекта. Контракт источника одинаков: ()→int без дополнительных эффектов.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 163 | 13 |
| Java | 246 | 9 |
| Python | 154 | 7 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

The composition root supplies a ready dependency to the client.

**Scenario.** One client reads and doubles values from two supplied sources returning 5 and 7.

**Expected observation.** 10 + 14 = 24.

**LMX.** Call Client\demo(). The named actual read explicitly supplies a dependency; this is neither implicit autofill nor a hidden registry.

**Comparison.** LMX uses call injection; Java/Python use constructor injection. The source contract is the same: ()→int with no additional effects.

**Scope and limitations.** A dependency belongs to one client/call. DI containers, scanning, lifetime scopes, and dependency cycles are excluded.

### Dependencies and execution boundaries

- **LMX:** Call Client\demo(). The named actual read explicitly supplies a dependency; this is neither implicit autofill nor a hidden registry.
- **Java:** Call Example.demo(); main and printing are excluded.
- **Python:** Call demo(); all shown classes and functions are counted.

## Источники / Sources

- [Martin Fowler — Inversion of Control Containers and Dependency Injection](https://martinfowler.com/articles/injection.html) — Разделение конфигурации и использования зависимости.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
