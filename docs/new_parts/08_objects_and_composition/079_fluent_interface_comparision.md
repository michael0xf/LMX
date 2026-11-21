# 079. Fluent Interface

Операции API возвращают контекст для продолжения читаемой последовательности.

## Общий сценарий

Одним выражением настроить count=3 и price=7 через операнды, возвращающие тот же контекст, затем получить произведение.

**Ожидаемое наблюдение:** 21; оба setter возвращают исходный объект.

**Граница сравнения:** Ядро сценария. Сравниваются ровно два бинарных setter и один последовательный владелец. Это разделяемая изменяемая конфигурация; persistent builder и произвольное число правых аргументов не обещаются. Пример становится выразительнее, даже если заголовок увеличивает число символов.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Options:
    copy: sys\OPERANDS_TEMPLATE
    int: count 0
    int: price 0
    return: @
    withCount:
        @: target \left
        target\count := \right[0]
        return: target
    withPrice:
        @: target \left
        target\price := \right[0]
        return: target

Demo:
    return: int
    run:
        import: Options
        @: options (Options withCount 3) withPrice 7
        return: options\count * options\price
```

Вызов Demo\run(). sys\OPERANDS_TEMPLATE — предоставленный шаблон ядра из примера Interpreter; строка copy учитывается. Режим 0 передаёт подготовленные target и число. Каждый setter использует ровно один правый аргумент и возвращает ту же ссылку; скобки явно задают левую группировку.

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

withCount и withPrice — обычные методы с общим DATA-заголовком, полученным через copy: sys\OPERANDS_TEMPLATE. \left получает ссылку на Options, \right[0] — значение настройки. Возврат target связывает два реальных применения операндов в цепочку; это не специальный синтаксис setter и не скрытая библиотека настроек.

## Сопоставление

LMX теперь показывает саму fluent-цепочку в expression; Java и Python используют цепочку методов. Все три изменяют и возвращают тот же объект, а не создают независимые варианты конфигурации. Общий заголовок операндов учтён строкой copy.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 285 | 19 |
| Java | 251 | 9 |
| Python | 220 | 11 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

API operations return a context so the interaction can continue fluently.

**Scenario.** Set count=3 and price=7 in one expression using operations that return the same context, then obtain the product.

**Expected observation.** 21; both setters return the original object.

**LMX.** withCount and withPrice are ordinary methods whose shared DATA header comes from copy: sys\OPERANDS_TEMPLATE. \left obtains the Options reference and \right[0] the setting value. Returning target connects two actual operator applications; no special setter syntax or hidden settings library is introduced.

**Comparison.** LMX now shows the fluent chain directly in an expression; Java and Python use method chaining. All three mutate and return the same object rather than create independent configuration values. The common operand header is accounted for by the copy line.

**Scope and limitations.** The comparison covers two binary setters and one serial owner. This is shared mutable configuration, not a persistent builder or an arbitrary variadic setter. The expression is more direct even if the header increases its character count.

### Dependencies and execution boundaries

- **LMX:** Call Demo\run(). sys\OPERANDS_TEMPLATE is the supplied kernel header from Interpreter; its copy line is counted. Mode 0 supplies the prepared target and number. Each setter consumes exactly one right argument and returns the same reference; parentheses explicitly group the chain to the left.
- **Java:** Call Example.demo(); main and printing are excluded.
- **Python:** Call demo(); all shown classes and functions are counted.

## Источники / Sources

- [Martin Fowler — Fluent Interface](https://martinfowler.com/bliki/FluentInterface.html) — Читаемый DSL-подобный API и возвращаемый контекст.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
