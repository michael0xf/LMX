# 079. Fluent Interface

Операции API возвращают контекст для продолжения читаемой последовательности.

## Общий сценарий

Настроить count=3 и price=7 через возвращаемый тот же контекст, затем получить произведение.

**Ожидаемое наблюдение:** 21; оба setter возвращают исходный объект.

**Граница сравнения:** Ядро сценария. Один mutable контекст; concurrent access не допускается. Читаемость DSL определяется именами и композицией, одного return this недостаточно для хорошего API.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Options:
    int: count 0
    int: price 0
    int: value
    return: @
    withCount:
        node\count := value
        return: Options
    withPrice:
        node\price := value
        return: Options

Demo:
    return: int
    run:
        @: options Options\withCount(value := 3)
        options := options\withPrice(value := 7)
        return: options\count * options\price
```

Вызов Demo\run(). Возвращается исходная Options, а не результат copy. LMX-листинг разносит продолжение по двум явно записанным ссылочным шагам.

[Отдельный листинг](examples/lmx/079_fluent_interface.lm3)

## Java

```java
class Example {
    static class Options {
        int count, price;
        Options withCount(int value) { count = value; return this; }
        Options withPrice(int value) { price = value; return this; }
        int total() { return count * price; }
    }
    static int demo() { return new Options().withCount(3).withPrice(7).total(); }
}
```

Внешний вызов Example.demo(); main и печать не считаются.

[Отдельный листинг](examples/java/079_fluent_interface.java)

## Python

```python
class Options:
    def with_count(self, value):
        self.count = value
        return self
    def with_price(self, value):
        self.price = value
        return self
    def total(self):
        return self.count * self.price

def demo():
    return Options().with_count(3).with_price(7).total()
```

Внешний вызов demo(); все показанные классы и функции входят в измерение.

[Отдельный листинг](examples/python/079_fluent_interface.py)

## Разбор LMX

Вызов Demo\run(). Возвращается исходная Options, а не результат copy. LMX-листинг разносит продолжение по двум явно записанным ссылочным шагам.

## Сопоставление

Java/Python демонстрируют буквальную dot-chain; LMX — тот же return-context контракт с обычным путём метода. Это сравнительный API-аналог, не утверждение о наличии идентичного chaining-синтаксиса.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 252 | 17 |
| Java | 251 | 9 |
| Python | 220 | 11 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

API operations return a context so the interaction can continue fluently.

**Scenario.** Set count=3 and price=7 through the returned same context, then obtain their product.

**Expected observation.** 21; both setters return the original object.

**LMX.** Call Demo\run(). The original Options is returned, not a copy. The LMX listing spells continuation as two explicit reference steps.

**Comparison.** Java/Python show literal dot chaining; LMX uses the same return-context contract with ordinary method paths. This is an API analogue, not a claim of identical chaining syntax.

**Scope and limitations.** One mutable context with no concurrent access. DSL readability depends on names and composition; return this alone does not make a good API.

### Dependencies and execution boundaries

- **LMX:** Call Demo\run(). The original Options is returned, not a copy. The LMX listing spells continuation as two explicit reference steps.
- **Java:** Call Example.demo(); main and printing are excluded.
- **Python:** Call demo(); all shown classes and functions are counted.

## Источники / Sources

- [Martin Fowler — Fluent Interface](https://martinfowler.com/bliki/FluentInterface.html) — Читаемый DSL-подобный API и возвращаемый контекст.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
