# 078. Marker Interface

Отдельный признак допускает объект к операции без добавления поведенческих методов.

## Общий сценарий

Проверить помеченный и непомеченный объект; результат кодируется как accepted*10 + rejected.

**Ожидаемое наблюдение:** 10.

**Граница сравнения:** Ядро сценария. Метаданные не являются авторизацией. Структурную метку нельзя считать неподлежающей подделке capability или буквальным эквивалентом Java nominal marker.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Marker:
    auditable:

Marked:
    auditable:

Unmarked:
    int: value 7

Check:
    @: item
    return: int
    accepts:
        if: implements(item; Marker)
            return: 1
        return: 0
    demo:
        return: accepts(item := Marked) * 10 + accepts(item := Unmarked)
```

Вызов Check\demo(). Используется непустой структурный шаблон с именованной ветвью auditable. Совершенно пустая Structure не различала бы наличие метки.

[Отдельный листинг](examples/lmx/078_marker_interface.lm3)

## Java

```java
class Example {
    interface Auditable {}
    static class Marked implements Auditable {}
    static class Unmarked { int value = 7; }
    static int accepts(Object item) { return item instanceof Auditable ? 1 : 0; }
    static int demo() { return accepts(new Marked()) * 10 + accepts(new Unmarked()); }
}
```

Внешний вызов Example.demo(); main и печать не считаются.

[Отдельный листинг](examples/java/078_marker_interface.java)

## Python

```python
class Auditable:
    pass

class Marked(Auditable):
    pass

class Unmarked:
    value = 7

def accepts(item):
    return int(isinstance(item, Auditable))

def demo():
    return accepts(Marked()) * 10 + accepts(Unmarked())
```

Внешний вызов demo(); все показанные классы и функции входят в измерение.

[Отдельный листинг](examples/python/078_marker_interface.py)

## Разбор LMX

Вызов Check\demo(). Используется непустой структурный шаблон с именованной ветвью auditable. Совершенно пустая Structure не различала бы наличие метки.

## Сопоставление

Java и Python проверяют номинальную принадлежность. LMX проверяет явно требуемую структуру; такую ветвь может построить другой автор. Положительный сценарий совпадает, сила номинальной гарантии различается.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 185 | 15 |
| Java | 238 | 7 |
| Python | 177 | 10 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

A separate marker admits an object without adding behavioral methods.

**Scenario.** Check a marked and an unmarked object; encode accepted*10 + rejected.

**Expected observation.** 10.

**LMX.** Call Check\demo(). A nonempty structural requirement contains a named auditable branch. An entirely empty Structure would not distinguish the marker.

**Comparison.** Java and Python check nominal membership. LMX checks an explicit structure that another author can reproduce. The positive scenario matches, but nominal guarantees differ.

**Scope and limitations.** Metadata is not authority. A structural marker is neither an unforgeable capability nor a literal Java nominal-marker equivalent.

### Dependencies and execution boundaries

- **LMX:** Call Check\demo(). A nonempty structural requirement contains a named auditable branch. An entirely empty Structure would not distinguish the marker.
- **Java:** Call Example.demo(); main and printing are excluded.
- **Python:** Call demo(); all shown classes and functions are counted.

## Источники / Sources

- [Oracle — java.io.Serializable](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/io/Serializable.html) — Реальный Java marker без собственных методов и полей.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../tasks/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
