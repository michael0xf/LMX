# 035. Front Controller

Один вход применяет общую политику и направляет запрос к обработчику.

## Общий сценарий

Маршрут 1 возвращает 200 только при admission=1; иначе 403. Неизвестный маршрут даёт 404.

**Ожидаемое наблюдение:** demo = 200; дополнительные проверки: (0,1) → 403, (1,9) → 404.

**Граница сравнения:** Протокол и порты. admitted — уже проверенное решение, а не клиентский флаг доверия. Цифры 403/404/200 не означают, что вызов сам отправил HTTP-ответ.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Front:
    int: admitted
    int: route
    return: int
    handle:
        if: admitted = 0
            return: 403
        if: route = 1
            return: 200
        return: 404
    demo:
        return: handle(admitted := 1; route := 1)
```

Вызов Front\demo(). Это принимающее ядро HTTP-профиля: провайдер декодирует application/lmx в Message, нормализует endpoint/route и выполняет admission до вызова handle. Числа — результаты выбранного тестового response-mapping.

[Отдельный листинг](examples/lmx/035_front_controller.lm3)

## TypeScript

```typescript
function handle(admitted: boolean, route: number): number {
    if (!admitted) return 403;
    if (route === 1) return 200;
    return 404;
}
function demo() { return handle(true, 1); }
```

Внешний вызов demo(); DOM и HTTP-сервер не входят в ядро.

[Отдельный листинг](examples/typescript/035_front_controller.ts)

## C#

```csharp
static class Example {
    static int Handle(bool admitted, int route) {
        if (!admitted) return 403;
        if (route == 1) return 200;
        return 404;
    }
    public static int Demo() => Handle(true, 1);
}
```

Внешний вызов Example.Demo(); графический toolkit и web-host не входят в ядро.

[Отдельный листинг](examples/csharp/035_front_controller.cs)

## Разбор LMX

Вызов Front\demo(). Это принимающее ядро HTTP-профиля: провайдер декодирует application/lmx в Message, нормализует endpoint/route и выполняет admission до вызова handle. Числа — результаты выбранного тестового response-mapping.

## Сопоставление

Общая политика применяется до выбора endpoint. Все листинги измеряют одинаковый dispatch-core, исключая HTTP host, декодирование и реальную аутентификацию.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 137 | 12 |
| TypeScript | 147 | 6 |
| C# | 153 | 8 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

One entry applies common policy and dispatches to a request handler.

**Scenario.** Route 1 returns 200 only when admission=1; otherwise 403. An unknown route returns 404.

**Expected observation.** demo = 200; extra checks: (0,1) → 403 and (1,9) → 404.

**LMX.** Call Front\demo(). This is the receiving core of the HTTP profile: its provider decodes application/lmx into a Message, normalizes endpoint/route, and performs admission before handle. Numbers are the test response mapping.

**Comparison.** Common policy precedes endpoint selection. All listings measure the same dispatch core, excluding the HTTP host, decoding, and real authentication.

**Scope and limitations.** admitted is a previously verified decision, not a trusted client flag. Returning 403/404/200 does not itself send an HTTP response.

### Dependencies and execution boundaries

- **LMX:** Call Front\demo(). This is the receiving core of the HTTP profile: its provider decodes application/lmx into a Message, normalizes endpoint/route, and performs admission before handle. Numbers are the test response mapping.
- **TypeScript:** Call demo(); the DOM and HTTP server are outside the core.
- **C#:** Call Example.Demo(); a GUI toolkit and web host are outside the core.

## Источники / Sources

- [Martin Fowler — Front Controller](https://martinfowler.com/eaaCatalog/frontController.html) — Общая обработка всех входящих запросов.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md), [уточнение 21 ноября](../../TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
