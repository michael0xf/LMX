# 074. Null Object

Нейтральная реализация выполняет тот же контракт, позволяя не проверять null у клиента.

## Общий сценарий

Выполнить работу с value=10 и отключённым журналированием через объект с пустым поведением.

**Ожидаемое наблюдение:** 10; logger вызван один раз и не изменяет состояние.

**Граница сравнения:** Ядро сценария. Пустое поведение допустимо только для необязательного журнала. Такой объект не следует использовать для сокрытия обязательного отказа платежа или записи.

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
| Python | <span style="color:#176233"><u>98</u></span> | 7 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

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

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
