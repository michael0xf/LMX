# 036. Page Controller

Отдельный обработчик принадлежит конкретной странице или действию.

## Общий сценарий

Обработчик страницы заказа принимает quantity=3 и строит значение subtotal=30.

**Ожидаемое наблюдение:** 30; другая страница не участвует в вычислении.

**Граница сравнения:** Протокол и порты. Показана логика страницы после декодирования запроса. Пример не реализует template engine, сессии или полноценную HTTP-библиотеку.

## LMX

```lmx
OrderPage:
    int: quantity
    return: int
    handle:
        if: quantity < 1
            return: 0
        return: quantity * 10
    demo:
        return: handle(3)
```

Вызов OrderPage\demo(). В HTTP-профиле явная маршрутная Table связывает /orders/show с этим принимающим методом; host и HTML-представление не включены.

[Отдельный листинг](examples/lmx/036_page_controller.lm3)

## TypeScript

```typescript
class OrderPage {
    handle(quantity: number) {
        if (quantity < 1) return 0;
        return quantity * 10;
    }
}
function demo() { return new OrderPage().handle(3); }
```

Внешний вызов demo(); DOM и HTTP-сервер не входят в ядро.

[Отдельный листинг](examples/typescript/036_page_controller.ts)

## C#

```csharp
static class Example {
    sealed class OrderPage {
        public int Handle(int quantity) {
            if (quantity < 1) return 0;
            return quantity * 10;
        }
    }
    public static int Demo() => new OrderPage().Handle(3);
}
```

Внешний вызов Example.Demo(); графический toolkit и web-host не входят в ядро.

[Отдельный листинг](examples/csharp/036_page_controller.cs)

## Разбор LMX

Вызов OrderPage\demo(). В HTTP-профиле явная маршрутная Table связывает /orders/show с этим принимающим методом; host и HTML-представление не включены.

## Сопоставление

Page Controller отличается от Front Controller принадлежностью одному экрану/действию. Общий web-router может существовать перед ним; эти паттерны совместимы.

### Небольшие варианты записи

Позиционные аргументы можно записать именованными, булев return — через if/return. Такие местные изменения записи и вызовов уже показанных leaf-методов не повторяются целыми листингами.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки | Без сложного Throws |
| --- | ---: | ---: | ---: |
| LMX | 99 | 9 | 99 |
| TypeScript | 128 | 7 | — |
| C# | 160 | 9 | — |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Дополнительная колонка «без сложного Throws» оставляет заголовок и первый аргумент каждого списка в исходном порядке, полностью считает ссылки/copy и первый аргумент общего банка. Меняется только расчёт, не исходник или контракт.

## English explanation

A dedicated handler belongs to a specific page or action.

**Scenario.** An order-page handler receives quantity=3 and produces subtotal=30.

**Expected observation.** 30; no other page participates.

**LMX.** Call OrderPage\demo(). An explicit HTTP route Table maps /orders/show to this receiver; the host and HTML rendering are excluded.

**Comparison.** A page controller belongs to one page/action. A shared web router may precede it; it can coexist with a front controller.

**Scope and limitations.** The code shows page logic after request decoding. It does not implement a template engine, sessions, or an HTTP library.

### Dependencies and execution boundaries

- **LMX:** Call OrderPage\demo(). An explicit HTTP route Table maps /orders/show to this receiver; the host and HTML rendering are excluded.
- **TypeScript:** Call demo(); the DOM and HTTP server are outside the core.
- **C#:** Call Example.Demo(); a GUI toolkit and web host are outside the core.

## Источники / Sources

- [Martin Fowler — Page Controller](https://martinfowler.com/eaaCatalog/pageController.html) — Обработчик одной страницы или действия.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
