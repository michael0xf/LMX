# 047. Strangler Fig

Маршрутизатор постепенно переводит отдельную функциональность на новую реализацию.

## Общий сценарий

Маршрут 1 сначала обслуживает legacy, затем new; маршрут 2 остаётся на legacy.

**Ожидаемое наблюдение:** Ответы 101, 201, 102; demo возвращает сумму 404.

**Граница сравнения:** Протокол и порты. Реальные backend-вызовы, синхронизация данных и обратимость миграции не включены. Возвращаемые числа — fixture payload, а не HTTP status codes.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Backends:
    int: route
    return: int
    legacy:
        return: 100 + route
    modern:
        return: 200 + route

Router:
    int: migrated 0
    int: route
    return: int
    handle:
        if: route = 1 && node\migrated != 0
            return: Backends\modern(route := route)
        return: Backends\legacy(route := route)
    demo:
        node\migrated := 0
        int: before handle(route := 1)
        node\migrated := 1
        return: before + handle(route := 1) + handle(route := 2)
```

Вызов Router\demo(). В HTTP-профиле Router — владелец явной маршрутной Table; изменения принимает своим Message turn. Листинг показывает решение о маршруте после decoder/admission.

[Отдельный листинг](examples/lmx/047_strangler_fig.lm3)

## Java

```java
class Example {
    static class Router {
        boolean migrated;
        int legacy(int route) { return 100 + route; }
        int modern(int route) { return 200 + route; }
        int handle(int route) {
            return route == 1 && migrated ? modern(route) : legacy(route);
        }
    }
    static int demo() {
        Router r = new Router(); int before = r.handle(1);
        r.migrated = true;
        return before + r.handle(1) + r.handle(2);
    }
}
```

Листинг ядра; внешний вызов Example.demo(), если он определён. Внешние порты описаны в границах сценария.

[Отдельный листинг](examples/java/047_strangler_fig.java)

## Go

```go
package main
type Router struct { Migrated bool }
func (r *Router) Handle(route int) int {
    if route == 1 && r.Migrated { return 200 + route }
    return 100 + route
}
func demo() int {
    r := &Router{}
    before := r.Handle(1)
    r.Migrated = true
    return before + r.Handle(1) + r.Handle(2)
}
```

Листинг пакета; внешний вызов demo(), если он определён. main и транспортный host не входят в подсчёт.

[Отдельный листинг](examples/go/047_strangler_fig.go)

## Разбор LMX

Вызов Router\demo(). В HTTP-профиле Router — владелец явной маршрутной Table; изменения принимает своим Message turn. Листинг показывает решение о маршруте после decoder/admission.

## Сопоставление

Переключение одной capability отделено от обновления всей системы. Включённый флаг не означает fallback после уже выполненных побочных эффектов нового сервиса.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 330 | 20 |
| Java | 309 | 15 |
| Go | 227 | 12 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

A router progressively moves selected capabilities to a new implementation.

**Scenario.** Route 1 initially uses legacy and then new; route 2 remains on legacy.

**Expected observation.** Responses 101, 201, 102; demo returns their sum, 404.

**LMX.** Call Router\demo(). In the HTTP profile Router owns an explicit route Table and changes it on its Message turn. The listing shows routing after decoding/admission.

**Comparison.** One capability switches independently of the rest. Enabling it does not imply fallback after the new service has already produced effects.

**Scope and limitations.** Real backend calls, data synchronization, and migration reversibility are excluded. Returned numbers are fixture payloads, not HTTP status codes.

### Dependencies and execution boundaries

- **LMX:** Call Router\demo(). In the HTTP profile Router owns an explicit route Table and changes it on its Message turn. The listing shows routing after decoding/admission.
- **Java:** Core listing; call Example.demo() when supplied. External ports are described in the scenario boundary.
- **Go:** Package listing; call demo() when supplied. main and the transport host are excluded.

## Источники / Sources

- [Martin Fowler — Strangler Fig](https://martinfowler.com/bliki/StranglerFigApplication.html) — Постепенная замена частей работающей системы.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
