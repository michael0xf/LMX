# 029. Lazy Load

Загрузить значение при первом обращении и сохранить успешный результат.

## Общий сценарий

Дважды прочитать holder.get; loader возвращает 0. В отдельном сценарии первая загрузка бросает исключение, вторая возвращает 0.

**Ожидаемое наблюдение:** В первом сценарии loader вызван один раз. Во втором ошибка не устанавливает loaded, поэтому второе обращение повторяет загрузку.

**Граница сравнения:** Ядро сценария. Сериализованный доступ; потокобезопасность не выводится из двух проверок флага. В LMX общий holder размещается у владельца Message.

## LMX

```lmx
Holder:
    int: loaded 0
    int: value 0
    @: load
    return: int
    get:
        if: !node\loaded
            int: result node\load()
            node\value := result
            node\loaded := 1
        return: node\value
```

loaded отделён от value: ноль является корректным значением, а не отсутствием. Изменения хранимого holder проходят через node.

[Отдельный листинг](examples/lmx/029_lazy_load.lm3)

## Python

```python
class Holder:
    def __init__(self, load):
        self.load, self.loaded, self.value = load, False, 0
    def get(self):
        if not self.loaded:
            value = self.load()
            self.value, self.loaded = value, True
        return self.value
```

Сериализованный доступ; потокобезопасность не выводится из двух проверок флага. В LMX общий holder размещается у владельца Message.

[Отдельный листинг](examples/python/029_lazy_load.py)

## C#

```csharp
using System;
public sealed class Holder(Func<int> load) {
    bool loaded;
    int value;
    public int Get() {
        if (!loaded) {
            int result=load();
            value=result;
            loaded=true;
        }
        return value;
    }
}
```

Сериализованный доступ; потокобезопасность не выводится из двух проверок флага. В LMX общий holder размещается у владельца Message.

[Отдельный листинг](examples/csharp/029_lazy_load.cs)

## Разбор LMX

loaded отделён от value: ноль является корректным значением, а не отсутствием. Изменения хранимого holder проходят через node.

## Сопоставление

Во всех версиях одинаковый marker и одинаковый порядок: вычислить, сохранить, затем отметить loaded.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 133 | 11 |
| Python | 176 | 8 |
| C# | 155 | 13 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Load on first use and retain a successful value.

**Scenario.** Read twice when load returns zero. Separately test a failing first load followed by a successful zero.

**Expected observation.** The successful scenario loads once. A failed attempt leaves loaded false and can be retried.

**LMX.** loaded is separate from value because zero is valid. node updates the persistent holder fields.

**Comparison.** All versions compute first, store the result, then publish the loaded flag.

**Scope and limitations.** Access is serial. Two flag checks do not establish thread safety; a shared LMX holder is owned by a Message.

### Dependencies and execution boundaries

- **LMX:** loaded is separate from value because zero is valid. node updates the persistent holder fields.
- **Python:** Access is serial. Two flag checks do not establish thread safety; a shared LMX holder is owned by a Message.
- **C#:** Access is serial. Two flag checks do not establish thread safety; a shared LMX holder is owned by a Message.

## Источники / Sources

- [Martin Fowler — Lazy Load](https://martinfowler.com/eaaCatalog/lazyLoad.html) — Определение и границы паттерна.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
