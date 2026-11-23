# 001. MVC (Model-View-Controller)

Модель хранит состояние; контроллер обрабатывает действие; представление читает модель.

## Общий сценарий

Увеличить счётчик с 5 до 6 и получить значение через отдельное представление.

**Ожидаемое наблюдение:** 6; контроллер не записывает поле отображения.

**Граница сравнения:** Ядро сценария. Показано разделение ролей и чтение по запросу. Подписка наблюдателей, DOM, отрисовка и многопользовательская изоляция не реализованы.

## LMX

```lmx
Model:
    int: count 5
    increment:
        node\count += 1

View:
    @: model Model
    return: int
    render:
        return: model\count

Controller:
    @: model Model
    click:
        model\increment()

Demo:
    return: int
    run:
        Model\count := 5
        Controller\click()
        return: View\render()
```

Вызов Demo\run(). Состояние модели изменяется явным node\count. Model, View и Controller принадлежат одному последовательному Message.

[Отдельный листинг](examples/lmx/001_mvc.lm3)

## TypeScript

```typescript
class Model { count = 5; increment() { this.count++; } }
class View {
    constructor(private model: Model) {}
    render() { return this.model.count; }
}
class Controller {
    constructor(private model: Model) {}
    click() { this.model.increment(); }
}
function demo() {
    const model = new Model();
    new Controller(model).click();
    return new View(model).render();
}
```

Внешний вызов demo(); DOM и HTTP-сервер не входят в ядро.

[Отдельный листинг](examples/typescript/001_mvc.ts)

## C#

```csharp
static class Example {
    sealed class Model {
        public int Count = 5;
        public void Increment() { Count++; }
    }
    sealed class View {
        readonly Model model;
        public View(Model model) { this.model = model; }
        public int Render() => model.Count;
    }
    sealed class Controller {
        readonly Model model;
        public Controller(Model model) { this.model = model; }
        public void Click() { model.Increment(); }
    }
    public static int Demo() {
        var model = new Model();
        new Controller(model).Click();
        return new View(model).Render();
    }
}
```

Внешний вызов Example.Demo(); графический toolkit и web-host не входят в ядро.

[Отдельный листинг](examples/csharp/001_mvc.cs)

## Разбор LMX

Вызов Demo\run(). Состояние модели изменяется явным node\count. Model, View и Controller принадлежат одному последовательному Message.

## Сопоставление

Во всех трёх вариантах сохранены три роли. У LMX ссылки на модель находятся в DATA, у контрольных языков — в полях экземпляров.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки | Без сложного Throws |
| --- | ---: | ---: | ---: |
| LMX | 208 | 19 | 208 |
| TypeScript | 302 | 14 | — |
| C# | 422 | 21 | — |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Дополнительная колонка «без сложного Throws» оставляет заголовок и первый аргумент каждого списка в исходном порядке, полностью считает ссылки/copy и первый аргумент общего банка. Меняется только расчёт, не исходник или контракт.

## English explanation

The model owns state, the controller handles input, and the view reads the model.

**Scenario.** Increment a counter from 5 to 6 and read it through a separate view.

**Expected observation.** 6; the controller never writes a displayed-value field.

**LMX.** Call Demo\run(). Explicit node\count changes model state. Model, View, and Controller belong to one serial Message.

**Comparison.** All variants preserve the three roles. LMX stores model references in DATA; the controls use instance fields.

**Scope and limitations.** This shows role separation and pull rendering. Observer subscription, DOM rendering, and multi-user isolation are outside the example.

### Dependencies and execution boundaries

- **LMX:** Call Demo\run(). Explicit node\count changes model state. Model, View, and Controller belong to one serial Message.
- **TypeScript:** Call demo(); the DOM and HTTP server are outside the core.
- **C#:** Call Example.Demo(); a GUI toolkit and web host are outside the core.

## Источники / Sources

- [Martin Fowler — GUI Architectures](https://martinfowler.com/eaaDev/uiArchs.html) — Раздел MVC и отделение представления.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
