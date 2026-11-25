# 081. Extension Object

Объект выдаёт отдельное расширение с дополнительным интерфейсом и доступом к его состоянию.

## Общий сценарий

К Host(value=7) прикрепить Report-расширение; запросить его и получить удвоенное значение 14.

**Ожидаемое наблюдение:** 14; идентичность Host сохраняется.

**Граница сравнения:** Ядро сценария. Одна заранее предусмотренная extension point. Query до install возвращает null, и вызывающий обязан обработать отсутствие; open registry типов и ABI не показаны.

## LMX

```lmx
Host:
    int: value 7
    @: extension 0
    @: addon
    return: @
    install:
        node\extension := addon
        return: addon
    query:
        return: node\extension

Report:
    @: target Host
    return: int
    render:
        return: target\value * 2

Demo:
    return: int
    run:
        Host\install(addon := Report)
        @: report Host\query()
        return: report\render()
```

Вызов Demo\run(). Report хранит явную ссылку target; запись ссылки в Host не делает Host parent для Report\render.

[Отдельный листинг](examples/lmx/081_extension_object.lm3)

## Java

```java
class Example {
    static class Host {
        int value = 7; Report extension;
        void install(Report addon) { extension = addon; }
        Report query() { return extension; }
    }
    record Report(Host target) { int render() { return target.value * 2; } }
    static int demo() {
        Host host = new Host(); host.install(new Report(host));
        return host.query().render();
    }
}
```

Внешний вызов Example.demo(); main и печать не считаются.

[Отдельный листинг](examples/java/081_extension_object.java)

## Python

```python
class Host:
    def __init__(self):
        self.value, self.extension = 7, None
    def install(self, addon):
        self.extension = addon
    def query(self):
        return self.extension

class Report:
    def __init__(self, target):
        self.target = target
    def render(self):
        return self.target.value * 2

def demo():
    host = Host()
    host.install(Report(host))
    return host.query().render()
```

Внешний вызов demo(); все показанные классы и функции входят в измерение.

[Отдельный листинг](examples/python/081_extension_object.py)

## Разбор LMX

Вызов Demo\run(). Report хранит явную ссылку target; запись ссылки в Host не делает Host parent для Report\render.

## Сопоставление

Выдаётся дополнительный интерфейс отдельного объекта. Это отличается от замены самого Host или присваивания методу нового lexical owner.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | <span style="color:#176233"><u>255</u></span> | 21 |
| Java | 285 | 12 |
| Python | 308 | 16 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

An object exposes a separate extension with additional behavior and access to its state.

**Scenario.** Attach a Report extension to Host(value=7), query it, and obtain twice the value, 14.

**Expected observation.** 14; Host identity is preserved.

**LMX.** Call Demo\run(). Report has an explicit target reference; storing it in Host does not make Host the parent of Report\render.

**Comparison.** A separate object provides the additional interface. This differs from replacing Host or assigning a method a new lexical owner.

**Scope and limitations.** One pre-existing extension point. Query before install returns null and callers must handle absence; an open type registry and ABI are not shown.

### Dependencies and execution boundaries

- **LMX:** Call Demo\run(). Report has an explicit target reference; storing it in Host does not make Host the parent of Report\render.
- **Java:** Call Example.demo(); main and printing are excluded.
- **Python:** Call demo(); all shown classes and functions are counted.

## Источники / Sources

- [Java Design Patterns — Extension Objects](https://java-design-patterns.com/patterns/extension-objects/) — Реализация query дополнительного интерфейса и связи расширения с объектом.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
