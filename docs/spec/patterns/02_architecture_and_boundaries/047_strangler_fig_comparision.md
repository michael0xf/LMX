# 047. Strangler Fig

Маршрутизатор постепенно переводит отдельную функциональность на новую реализацию.

## Общий сценарий

Маршрут 1 сначала обслуживает legacy, затем new; маршрут 2 остаётся на legacy.

**Ожидаемое наблюдение:** Ответы 101, 201, 102; demo возвращает сумму 404.

**Граница сравнения:** Протокол и порты. Реальные backend-вызовы, синхронизация данных и обратимость миграции не включены. Возвращаемые числа — fixture payload, а не HTTP status codes.

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
            return: Backends\modern(route)
        return: Backends\legacy(route)
    demo:
        int: route 1
        node\migrated := 0
        int: before handle()
        node\migrated := 1
        return: before + handle() + handle(route := 2)
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

### Небольшие варианты записи

Позиционные аргументы можно записать именованными, булев return — через if/return. Такие местные изменения записи и вызовов уже показанных leaf-методов не повторяются целыми листингами.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 310 | 21 |
| Java | 309 | 15 |
| Go | <span style="color:#176233"><u>227</u></span> | 12 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

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

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
