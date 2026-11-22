# 076. Simple Factory

Одна функция выбирает и создаёт конкретный продукт по входному признаку.

## Общий сценарий

Создать два продукта kind=0 и kind=1 со стоимостью 5 и 9.

**Ожидаемое наблюдение:** Сумма 14; каждый вызов создаёт отдельный продукт.

**Граница сравнения:** Ядро сценария. kind ограничен 0 и 1; иной kind в этом fixture использует второй вариант. Память/конструкторы отличаются, измеряется только показанная задача.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Small:
    int: cost 5

Large:
    int: cost 9

Factory:
    int: kind
    return: @
    create:
        if: kind = 0
            return: (copy(Small))
        return: (copy(Large))

Demo:
    return: int
    run:
        @: a Factory\create(kind := 0)
        @: b Factory\create(kind := 1)
        return: a\cost + b\cost
```

Вызов Demo\run(). Явная группа собирает поля copy в один новый продукт. У продукта нет метода, поэтому отдельные слоты группирующего контейнера не создают неоднозначности владельца состояния.

[Отдельный листинг](examples/lmx/076_simple_factory.lm3)

## Java

```java
class Example {
    record Product(int cost) {}
    static Product create(int kind) { return new Product(kind == 0 ? 5 : 9); }
    static int demo() { return create(0).cost() + create(1).cost(); }
}
```

Внешний вызов Example.demo(); main и печать не считаются.

[Отдельный листинг](examples/java/076_simple_factory.java)

## Python

```python
class Product:
    def __init__(self, cost):
        self.cost = cost

def create(kind):
    return Product(5 if kind == 0 else 9)

def demo():
    return create(0).cost + create(1).cost
```

Внешний вызов demo(); все показанные классы и функции входят в измерение.

[Отдельный листинг](examples/python/076_simple_factory.py)

## Разбор LMX

Вызов Demo\run(). Явная группа собирает поля copy в один новый продукт. У продукта нет метода, поэтому отдельные слоты группирующего контейнера не создают неоднозначности владельца состояния.

## Сопоставление

Выбор типа продукта инкапсулирован в функции. Это Simple Factory, без виртуального factory method и без семейства Abstract Factory.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 201 | 17 |
| Java | 155 | 5 |
| Python | 141 | 7 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

One function selects and creates a concrete product from an input discriminator.

**Scenario.** Create products of kinds 0 and 1 with costs 5 and 9.

**Expected observation.** Sum 14; each call creates a separate product.

**LMX.** Call Demo\run(). The explicit group collects copy’s fields into one new product. The product has no method, so grouping slots introduce no method-owner ambiguity.

**Comparison.** Product selection is encapsulated in a function. This is Simple Factory, without a virtual factory method or Abstract Factory family.

**Scope and limitations.** The fixture uses kinds 0 and 1; other kinds take the second branch. Allocation/construction differs; only the shown task is measured.

### Dependencies and execution boundaries

- **LMX:** Call Demo\run(). The explicit group collects copy’s fields into one new product. The product has no method, so grouping slots introduce no method-owner ambiguity.
- **Java:** Call Example.demo(); main and printing are excluded.
- **Python:** Call demo(); all shown classes and functions are counted.

## Источники / Sources

- [Java Design Patterns — Factory programmatic example](https://java-design-patterns.com/patterns/factory/) — Исходный каталог со статической функцией выбора продукта; используется именно simple-factory форма примера.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
