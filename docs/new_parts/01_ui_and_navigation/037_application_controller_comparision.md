# 037. Application Controller

Единое место принимает решения о переходах между экранами.

## Общий сценарий

На экране 1 успешная проверка переводит на экран 2; отказ оставляет экран 1.

**Ожидаемое наблюдение:** 2 после успешного перехода; (screen=1, valid=0) возвращает 1.

**Граница сравнения:** Ядро сценария. Два экрана и одно событие. История, восстановление сессии, back navigation и маршрутизация транспортных запросов добавляются отдельно.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Navigation:
    int: screen 1
    int: valid
    return: int
    submit:
        if: node\screen = 1 && valid != 0
            node\screen := 2
        return: node\screen
    demo:
        node\screen := 1
        return: submit(valid := 1)
```

Вызов Navigation\demo(). node\screen хранит состояние конкретного владельца навигации; в многопользовательском сервисе это отдельный session Message, не глобальная переменная.

[Отдельный листинг](examples/lmx/037_application_controller.lm3)

## TypeScript

```typescript
class Navigation {
    private screen = 1;
    submit(valid: boolean) {
        if (this.screen === 1 && valid) this.screen = 2;
        return this.screen;
    }
}
function demo() { return new Navigation().submit(true); }
```

Внешний вызов demo(); DOM и HTTP-сервер не входят в ядро.

[Отдельный листинг](examples/typescript/037_application_controller.ts)

## C#

```csharp
static class Example {
    sealed class Navigation {
        int screen = 1;
        public int Submit(bool valid) {
            if (screen == 1 && valid) screen = 2;
            return screen;
        }
    }
    public static int Demo() => new Navigation().Submit(true);
}
```

Внешний вызов Example.Demo(); графический toolkit и web-host не входят в ядро.

[Отдельный листинг](examples/csharp/037_application_controller.cs)

## Разбор LMX

Вызов Navigation\demo(). node\screen хранит состояние конкретного владельца навигации; в многопользовательском сервисе это отдельный session Message, не глобальная переменная.

## Сопоставление

Смысл паттерна — концентрация правил перехода. Автоматический переход от изменения любого поля модели во всех трёх вариантах отсутствует.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 148 | 11 |
| TypeScript | 165 | 8 |
| C# | 177 | 10 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

One place decides navigation between screens.

**Scenario.** On screen 1 a valid submission goes to screen 2; invalid input stays on screen 1.

**Expected observation.** 2 after a successful transition; (screen=1, valid=0) returns 1.

**LMX.** Call Navigation\demo(). node\screen belongs to one navigation owner; a multi-user service uses a separate session Message, not a global variable.

**Comparison.** The pattern centralizes transition decisions. None of the variants automatically navigates on arbitrary model mutation.

**Scope and limitations.** Two screens and one event. History, session restoration, back navigation, and transport routing require additional logic.

### Dependencies and execution boundaries

- **LMX:** Call Navigation\demo(). node\screen belongs to one navigation owner; a multi-user service uses a separate session Message, not a global variable.
- **TypeScript:** Call demo(); the DOM and HTTP server are outside the core.
- **C#:** Call Example.Demo(); a GUI toolkit and web host are outside the core.

## Источники / Sources

- [Martin Fowler — Application Controller](https://martinfowler.com/eaaCatalog/applicationController.html) — Централизация навигации и потока приложения.

**Норма LMX:** [CORE](../../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
