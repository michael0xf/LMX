# 073. Service Locator

Клиент получает сервис через явно выбранный реестр.

## Общий сценарий

По ключу 1 получить источник 42; неизвестный ключ направляется к fallback 0.

**Ожидаемое наблюдение:** 42.

**Граница сравнения:** Ядро сценария. Замены реализаций и динамического dictionary нет в этом минимуме. Добавление locator не делает зависимости клиента явными в его сигнатуре.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Services:
    return: int
    answer:
        return: 42
    fallback:
        return: 0

Locator:
    int: key
    return: @
    resolve:
        if: key = 1
            return: Services\answer
        return: Services\fallback

Client:
    @: locator Locator
    return: int
    demo:
        @: service locator\resolve(key := 1)
        return: service()
```

Вызов Client\demo(). Locator — пользовательская Structure, явно доступная через DATA. Он не создаёт встроенного process-global namespace.

[Отдельный листинг](examples/lmx/073_service_locator.lm3)

## Java

```java
import java.util.function.IntSupplier;
class Example {
    static class Locator {
        IntSupplier resolve(int key) { return key == 1 ? () -> 42 : () -> 0; }
    }
    static int client(Locator locator) { return locator.resolve(1).getAsInt(); }
    static int demo() { return client(new Locator()); }
}
```

Внешний вызов Example.demo(); main и печать не считаются.

[Отдельный листинг](examples/java/073_service_locator.java)

## Python

```python
class Locator:
    def resolve(self, key):
        return (lambda: 42) if key == 1 else (lambda: 0)

def client(locator):
    return locator.resolve(1)()

def demo():
    return client(Locator())
```

Внешний вызов demo(); все показанные классы и функции входят в измерение.

[Отдельный листинг](examples/python/073_service_locator.py)

## Разбор LMX

Вызов Client\demo(). Locator — пользовательская Structure, явно доступная через DATA. Он не создаёт встроенного process-global namespace.

## Сопоставление

В отличие от DI конкретный сервис клиент запрашивает внутри своей логики. Все реализации используют один фиксированный ключ и определённый fallback.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 223 | 19 |
| Java | 238 | 8 |
| Python | 151 | 7 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

The client retrieves a service from an explicitly chosen registry.

**Scenario.** Resolve key 1 to a source returning 42; unknown keys use a fallback returning 0.

**Expected observation.** 42.

**LMX.** Call Client\demo(). Locator is a user Structure explicitly available through DATA, not a built-in process-global namespace.

**Comparison.** Unlike DI, the client requests the concrete service within its own logic. Every version uses one fixed key and a defined fallback.

**Scope and limitations.** Dynamic dictionaries and service replacement are outside this minimum. A locator does not make each service dependency explicit in the client signature.

### Dependencies and execution boundaries

- **LMX:** Call Client\demo(). Locator is a user Structure explicitly available through DATA, not a built-in process-global namespace.
- **Java:** Call Example.demo(); main and printing are excluded.
- **Python:** Call demo(); all shown classes and functions are counted.

## Источники / Sources

- [Martin Fowler — Service Locator versus Dependency Injection](https://martinfowler.com/articles/injection.html) — Авторское сравнение locator и injection.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
