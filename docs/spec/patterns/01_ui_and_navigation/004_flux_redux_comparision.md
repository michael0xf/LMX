# 004. Flux / Redux

Действия проходят через единый store и чистый reducer.

## Общий сценарий

Из состояния 0 обработать действия +2 и +3; сохранить старое значение после первого шага.

**Ожидаемое наблюдение:** Сохранённое значение 2, текущее 5, demo = 25.

**Граница сравнения:** Ядро сценария. Целые числа не демонстрируют стоимость immutable-деревьев. Middleware, подписчики, persistence и time-travel UI не входят в сравнение.

Все три листинга относятся к указанному сценарию. Предоставленные порты и библиотеки перечислены рядом с кодом; их реализации не входят в размер листинга.

## LMX

```lmx
Reducer:
    int: state
    int: delta
    return: int
    reduce:
        return: state + delta

Store:
    int: state 0
    int: delta
    dispatch:
        node\state := Reducer\reduce(state := node\state; delta := delta)

Demo:
    return: int
    run:
        Store\state := 0
        Store\dispatch(delta := 2)
        int: previous Store\state
        Store\dispatch(delta := 3)
        return: previous * 10 + Store\state
```

Вызов Demo\run(). Редуктор чист в данном примере; изменяется только ссылка/значение store. Состояние — скаляр, поэтому старое значение сохраняется обычным копированием.

[Отдельный листинг](examples/lmx/004_flux_redux.lm3)

## TypeScript

```typescript
type Action = {type: "add"; delta: number};
function reduce(state: number, action: Action) { return state + action.delta; }
class Store {
    private state = 0;
    dispatch(action: Action) { this.state = reduce(this.state, action); }
    getState() { return this.state; }
}
function demo() {
    const store = new Store();
    store.dispatch({type: "add", delta: 2});
    const previous = store.getState();
    store.dispatch({type: "add", delta: 3});
    return previous * 10 + store.getState();
}
```

Внешний вызов demo(); DOM и HTTP-сервер не входят в ядро.

[Отдельный листинг](examples/typescript/004_flux_redux.ts)

## C#

```csharp
static class Example {
    readonly record struct Add(int Delta);
    static int Reduce(int state, Add action) => state + action.Delta;
    sealed class Store {
        public int State { get; private set; }
        public void Dispatch(Add action) { State = Reduce(State, action); }
    }
    public static int Demo() {
        var store = new Store();
        store.Dispatch(new Add(2)); int previous = store.State;
        store.Dispatch(new Add(3));
        return previous * 10 + store.State;
    }
}
```

Внешний вызов Example.Demo(); графический toolkit и web-host не входят в ядро.

[Отдельный листинг](examples/csharp/004_flux_redux.cs)

## Разбор LMX

Вызов Demo\run(). Редуктор чист в данном примере; изменяется только ссылка/значение store. Состояние — скаляр, поэтому старое значение сохраняется обычным копированием.

## Сопоставление

TypeScript использует объект action, C# — value record, LMX — структурный вызов с именованным delta. Это однонаправленный поток без обязательной библиотеки Redux.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 287 | 19 |
| TypeScript | 402 | 14 |
| C# | 366 | 14 |

Подсчёт включает комментарии и весь показанный код. Первая метрика исключает все пробельные символы, в том числе внутри строковых литералов. Исходный код при этом не изменяется. Это измерение листинга, не производительности, трудоёмкости или размера полной системы. Общий метод: [METHODOLOGY](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Actions pass through one store and a pure reducer.

**Scenario.** From state 0 dispatch +2 and +3, retaining the old value after the first step.

**Expected observation.** Retained value 2, current state 5, demo = 25.

**LMX.** Call Demo\run(). The reducer is pure in this example; only the store changes. Scalar state retains its previous value by ordinary value copying.

**Comparison.** TypeScript uses an action object, C# a value record, and LMX a structural call with named delta. This is unidirectional flow without a mandatory Redux dependency.

**Scope and limitations.** Integers do not demonstrate immutable-tree costs. Middleware, subscriptions, persistence, and time-travel UI are outside the comparison.

### Dependencies and execution boundaries

- **LMX:** Call Demo\run(). The reducer is pure in this example; only the store changes. Scalar state retains its previous value by ordinary value copying.
- **TypeScript:** Call demo(); the DOM and HTTP server are outside the core.
- **C#:** Call Example.Demo(); a GUI toolkit and web host are outside the core.

## Источники / Sources

- [Redux — Three Principles](https://redux.js.org/understanding/thinking-in-redux/three-principles) — Store, actions и чистые преобразования состояния.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

Сетевые источники использованы для определения паттерна и проверки контрактов контрольных языков. Листинги созданы для общего сценария; заимствованные идеи не являются заявлением об исполнении исходного репозитория.

## Проверка

Текущий статус см. в [VALIDATION](../VALIDATION.md). Ожидаемое наблюдение выше — критерий приёмки. Приложенный архив документации не содержит запускаемого LMX-ядра; выполнение LMX здесь не заявляется.
