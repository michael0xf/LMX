# 002. MVP (Model-View-Presenter)

Пассивное представление получает готовое значение от презентера.

## Общий сценарий

К модели 5 прибавить 2; презентер явно обновляет пассивный экран.

**Ожидаемое наблюдение:** Модель 7, экран 7, demo возвращает 77.

**Граница сравнения:** Ядро сценария. Выбран вариант Passive View. Супервизирующий контроллер с самостоятельным binding представления — другая разновидность MVP.

## LMX

```lmx
Model:
    int: count 5

Screen:
    int: shown 0
    int: value
    show:
        node\shown := value

Presenter:
    @: model Model
    @: view Screen
    int: delta
    click:
        model\count += delta
        view\show(value := model\count)

Demo:
    return: int
    run:
        Model\count := 5
        Presenter\click(delta := 2)
        return: Model\count * 10 + Screen\shown
```

Вызов Demo\run(). Screen не знает Model; все переходы координирует Presenter.

[Отдельный листинг](examples/lmx/002_mvp.lm3)

## TypeScript

```typescript
interface View { show(value: number): void; }
class Screen implements View {
    shown = 0;
    show(value: number) { this.shown = value; }
}
class Presenter {
    constructor(private model: {count: number}, private view: View) {}
    click(delta: number) {
        this.model.count += delta;
        this.view.show(this.model.count);
    }
}
function demo() {
    const model = {count: 5}, screen = new Screen();
    new Presenter(model, screen).click(2);
    return model.count * 10 + screen.shown;
}
```

Внешний вызов demo(); DOM и HTTP-сервер не входят в ядро.

[Отдельный листинг](examples/typescript/002_mvp.ts)

## C#

```csharp
static class Example {
    interface IView { void Show(int value); }
    sealed class Model { public int Count = 5; }
    sealed class Screen : IView {
        public int Shown;
        public void Show(int value) { Shown = value; }
    }
    sealed class Presenter {
        readonly Model model; readonly IView view;
        public Presenter(Model m, IView v) { model = m; view = v; }
        public void Click(int delta) {
            model.Count += delta;
            view.Show(model.Count);
        }
    }
    public static int Demo() {
        var model = new Model(); var screen = new Screen();
        new Presenter(model, screen).Click(2);
        return model.Count * 10 + screen.Shown;
    }
}
```

Внешний вызов Example.Demo(); графический toolkit и web-host не входят в ядро.

[Отдельный листинг](examples/csharp/002_mvp.cs)

## Разбор LMX

Вызов Demo\run(). Screen не знает Model; все переходы координирует Presenter.

## Сопоставление

Ключевое отличие от MVC-примера — экран не читает модель. Интерфейс IView/структурный контракт можно подменить записывающим тестовым представлением.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | <span style="color:#176233"><u>252</u></span> | 20 |
| TypeScript | 390 | 17 |
| C# | 478 | 21 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.

## English explanation

A passive view receives the final display value from its presenter.

**Scenario.** Add 2 to a model initially holding 5; the presenter explicitly updates a passive screen.

**Expected observation.** Model 7, screen 7; demo returns 77.

**LMX.** Call Demo\run(). Screen has no reference to Model; Presenter coordinates the changes.

**Comparison.** Unlike the MVC example, the screen never reads the model. Its view contract can be replaced with a recording test view.

**Scope and limitations.** This is the Passive View variant. A supervising controller with view-owned bindings is a different MVP variant.

### Dependencies and execution boundaries

- **LMX:** Call Demo\run(). Screen has no reference to Model; Presenter coordinates the changes.
- **TypeScript:** Call demo(); the DOM and HTTP server are outside the core.
- **C#:** Call Example.Demo(); a GUI toolkit and web host are outside the core.

## Источники / Sources

- [Martin Fowler — Passive View](https://martinfowler.com/eaaDev/PassiveScreen.html) — Презентер полностью управляет пассивным представлением.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
