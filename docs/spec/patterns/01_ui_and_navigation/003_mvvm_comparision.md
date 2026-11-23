# 003. MVVM (Model-View-ViewModel)

ViewModel предоставляет состояние представления и уведомляет binding об изменениях.

## Общий сценарий

Ввести значение 6; отображаемое производное значение равно удвоенному вводу и обновляется через подписку.

**Ожидаемое наблюдение:** 12; обновление доходит до экрана через зарегистрированную связь.

**Граница сравнения:** Ядро сценария. Один подписчик, одна производная характеристика, без XAML/DOM, очистки подписок и двухсторонней синхронизации.

## LMX

```lmx
Screen:
    int: shown 0
    int: value
    show:
        node\shown := value

ViewModel:
    int: count 0
    int: value
    @: changed Screen\show
    set:
        node\count := value
        changed(value := node\count * 2)

Demo:
    return: int
    run:
        ViewModel\set(value := 6)
        return: Screen\shown
```

Вызов Demo\run(). changed — явно передаваемая связь, а не встроенное автоматическое наблюдение произвольного графа.

[Отдельный листинг](examples/lmx/003_mvvm.lm3)

## TypeScript

```typescript
class ViewModel {
    private count = 0;
    changed: (value: number) => void = () => {};
    get doubled() { return this.count * 2; }
    set(value: number) {
        this.count = value;
        this.changed(this.doubled);
    }
}
function demo() {
    const vm = new ViewModel();
    let shown = 0;
    vm.changed = value => { shown = value; };
    vm.set(6);
    return shown;
}
```

Внешний вызов demo(); DOM и HTTP-сервер не входят в ядро.

[Отдельный листинг](examples/typescript/003_mvvm.ts)

## C#

```csharp
using System.ComponentModel;
static class Example {
    sealed class ViewModel : INotifyPropertyChanged {
        int count;
        public event PropertyChangedEventHandler? PropertyChanged;
        public int Doubled => count * 2;
        public void Set(int value) {
            count = value;
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(nameof(Doubled)));
        }
    }
    public static int Demo() {
        var vm = new ViewModel(); int shown = 0;
        vm.PropertyChanged += (_, e) => {
            if (e.PropertyName == nameof(ViewModel.Doubled)) shown = vm.Doubled;
        };
        vm.Set(6);
        return shown;
    }
}
```

Внешний вызов Example.Demo(); графический toolkit и web-host не входят в ядро.

[Отдельный листинг](examples/csharp/003_mvvm.cs)

## Разбор LMX

Вызов Demo\run(). changed — явно передаваемая связь, а не встроенное автоматическое наблюдение произвольного графа.

## Сопоставление

LMX и TypeScript показывают одну связь уведомления; C# использует стандартный INotifyPropertyChanged. Полный binding engine ни одному языку не приписывается бесплатно.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки | Без сложного Throws |
| --- | ---: | ---: | ---: |
| LMX | 207 | 17 | 207 |
| TypeScript | 268 | 16 | — |
| C# | 463 | 20 | — |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Дополнительная колонка «без сложного Throws» оставляет заголовок и первый аргумент каждого списка в исходном порядке, полностью считает ссылки/copy и первый аргумент общего банка. Меняется только расчёт, не исходник или контракт.

## English explanation

A view model exposes presentation state and notifies a binding when it changes.

**Scenario.** Set the input to 6; a subscription updates the displayed derived value to twice the input.

**Expected observation.** 12; the registered binding propagates the update to the screen.

**LMX.** Call Demo\run(). changed is an explicit binding, not automatic observation of arbitrary graph mutations.

**Comparison.** LMX and TypeScript show one explicit notification binding; C# uses INotifyPropertyChanged. No language is credited with an unimplemented binding engine.

**Scope and limitations.** One subscriber and one derived property; XAML/DOM, subscription cleanup, and two-way synchronization are excluded.

### Dependencies and execution boundaries

- **LMX:** Call Demo\run(). changed is an explicit binding, not automatic observation of arbitrary graph mutations.
- **TypeScript:** Call demo(); the DOM and HTTP server are outside the core.
- **C#:** Call Example.Demo(); a GUI toolkit and web host are outside the core.

## Источники / Sources

- [Microsoft — Model-View-ViewModel](https://learn.microsoft.com/en-us/dotnet/architecture/maui/mvvm) — Разделение View/ViewModel и механизмы binding.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
