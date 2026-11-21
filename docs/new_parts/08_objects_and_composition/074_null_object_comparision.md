# 074. Null Object

Нейтральная реализация выполняет тот же контракт, позволяя не проверять null у клиента.

## Общий сценарий

Выполнить работу с value=10 и отключённым журналированием через объект с пустым поведением.

**Ожидаемое наблюдение:** 10; logger вызван один раз и не изменяет состояние.

**Граница сравнения:** Ядро сценария. Пустое поведение допустимо только для необязательного журнала. Такой объект не следует использовать для сокрытия обязательного отказа платежа или записи.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Silent:
    int: value
    write:
        return

Client:
    int: value
    @: log Silent\write
    return: int
    execute:
        log(value := value)
        return: value
    demo:
        return: execute(value := 10)
```

Вызов Client\demo(). Silent\write — существующий метод-процедура; initialized null-reference 0 или uninit вместо него не подставляются.

[Отдельный листинг](examples/lmx/074_null_object.lm3)

## Java

```java
import java.util.function.IntConsumer;
class Example {
    static final IntConsumer SILENT = value -> {};
    static int execute(int value, IntConsumer log) {
        log.accept(value);
        return value;
    }
    static int demo() { return execute(10, SILENT); }
}
```

Внешний вызов Example.demo(); main и печать не считаются.

[Отдельный листинг](examples/java/074_null_object.java)

## Python

```python
def silent(value):
    pass

def execute(value, log=silent):
    log(value)
    return value

def demo():
    return execute(10)
```

Внешний вызов demo(); все показанные классы и функции входят в измерение.

[Отдельный листинг](examples/python/074_null_object.py)

## Разбор LMX

Вызов Client\demo(). Silent\write — существующий метод-процедура; initialized null-reference 0 или uninit вместо него не подставляются.

## Сопоставление

Нейтральный callable достаточен, если контракт состоит из одной операции. Это функциональная реализация Null Object, без принудительного отдельного класса.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 138 | 13 |
| Java | 205 | 9 |
| Python | 98 | 7 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

A neutral implementation satisfies the same contract so the client needs no null check.

**Scenario.** Run work with value=10 and logging disabled by a neutral implementation.

**Expected observation.** 10; the logger is called once and changes no state.

**LMX.** Call Client\demo(). Silent\write is an existing procedure; neither initialized null 0 nor uninit substitutes for it.

**Comparison.** A neutral callable is sufficient for a one-operation contract. This is a functional Null Object without a mandatory wrapper class.

**Scope and limitations.** Neutral behavior is suitable for an optional log. It should not hide a required payment or persistence failure.

### Dependencies and execution boundaries

- **LMX:** Call Client\demo(). Silent\write is an existing procedure; neither initialized null 0 nor uninit substitutes for it.
- **Java:** Call Example.demo(); main and printing are excluded.
- **Python:** Call demo(); all shown classes and functions are counted.

## Источники / Sources

- [Martin Fowler — Special Case](https://martinfowler.com/eaaCatalog/specialCase.html) — Нейтральный объект с ожидаемым интерфейсом вместо null.

**Норма LMX:** [CORE](../newdocs/CORE.md), [семантика](../newdocs/LMX_semantics.en.md), [guide](../newdocs/LMX_semantics_guide.en.md), [уточнение 21 ноября](../newdocs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
