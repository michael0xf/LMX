# 080. Type Object

Разновидность объекта описывается обычными данными, разделяемыми его экземплярами.

## Общий сценарий

Два объекта ссылаются на один TypeData с damage=2. Изменить damage на 3; второй объект увидит новое значение.

**Ожидаемое наблюдение:** 23: первое чтение 2, второе 3.

**Граница сравнения:** Ядро сценария. Изменение общего TypeData влияет на все ссылки и требует одного владельца Message либо явного протокола обновления. Иерархия наследования типов и редактор данных не реализованы.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
TypeData:
    int: damage 2

First:
    @: kind TypeData

Second:
    @: kind TypeData

Operations:
    @: item
    return: int
    damage:
        return: item\kind\damage
    demo:
        TypeData\damage := 2
        int: before damage(item := First)
        TypeData\damage := 3
        return: before * 10 + damage(item := Second)
```

Вызов Operations\demo(). TypeData — пользовательский доменный объект, не физический type code записи и не замена typeof.

[Отдельный листинг](examples/lmx/080_type_object.lm3)

## Java

```java
class Example {
    static class TypeData { int damage = 2; }
    record Item(TypeData kind) {}
    static int damage(Item item) { return item.kind().damage; }
    static int demo() {
        TypeData kind = new TypeData();
        Item first = new Item(kind), second = new Item(kind);
        int before = damage(first); kind.damage = 3;
        return before * 10 + damage(second);
    }
}
```

Внешний вызов Example.demo(); main и печать не считаются.

[Отдельный листинг](examples/java/080_type_object.java)

## Python

```python
class TypeData:
    def __init__(self, damage):
        self.damage = damage

class Item:
    def __init__(self, kind):
        self.kind = kind

def damage(item):
    return item.kind.damage

def demo():
    kind = TypeData(2)
    first, second = Item(kind), Item(kind)
    before = damage(first)
    kind.damage = 3
    return before * 10 + damage(second)
```

Внешний вызов demo(); все показанные классы и функции входят в измерение.

[Отдельный листинг](examples/python/080_type_object.py)

## Разбор LMX

Вызов Operations\demo(). TypeData — пользовательский доменный объект, не физический type code записи и не замена typeof.

## Сопоставление

Общие свойства становятся данными во всех трёх языках. Возможность LMX читать/компоновать граф удобна для загрузки таких описаний, но в этом примере loader не требуется.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 225 | 16 |
| Java | 283 | 11 |
| Python | 265 | 14 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

An object’s kind is described by ordinary data shared by instances.

**Scenario.** Two objects reference one TypeData with damage=2. Change damage to 3; the second object sees the new value.

**Expected observation.** 23: the first read is 2 and the second is 3.

**LMX.** Call Operations\demo(). TypeData is a domain object, not a physical record type code or replacement for typeof.

**Comparison.** Shared properties become data in all three languages. LMX graph inspection/composition can help load such descriptions, but this example needs no loader.

**Scope and limitations.** Changing shared TypeData affects all references and needs one owning Message or an explicit update protocol. Type inheritance and data editors are not implemented.

### Dependencies and execution boundaries

- **LMX:** Call Operations\demo(). TypeData is a domain object, not a physical record type code or replacement for typeof.
- **Java:** Call Example.demo(); main and printing are excluded.
- **Python:** Call demo(); all shown classes and functions are counted.

## Источники / Sources

- [Java Design Patterns — Type Object implementation](https://java-design-patterns.com/patterns/type-object/) — Исходная демонстрация вида как объекта данных и ссылок на него.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
