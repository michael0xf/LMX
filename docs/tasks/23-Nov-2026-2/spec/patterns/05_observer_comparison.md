# 05. Observer: LMX и семь других языков

21 ноября 2026 года · Согласовано с документацией docs

## Задача и границы

Два сохранённых обработчика получают события 3 и 8. Первый сохраняет последнее значение, второй накапливает сумму. После демонстрации last = 8, total = 11.

**Ожидаемый результат: 11.**

Два синхронных callback-слота и одно состояние. Очередь, динамический список подписок, отписка и политика ошибок требуют дополнительной логики. Python и другие варианты могут представлять состояние и издателя отдельными объектами; LMX объединяет их в одной группе для данного сценария.

## Архитектура LMX

Python хранит одно состояние и две ссылки на обработчики. В LMX связанные данные, обработчики, notify и demo собраны в observer. Два callback-слота сохранены; отдельные классы или namespace-обёртки не требуются для этой демонстрации.

Структура задаёт общий DATA связанных методов. Метод обращается к нужным ему полям; отдельная оболочка для demo из-за остальных полей не требуется. Обычная ссылка `@: name method` не вызывает method и не требует самостоятельного `fn`. Программа по-прежнему использует типы объявленных полей и правила конкретных вызовов. [Связывание и ссылки](../LMX_semantics.en.md#binding-places)

Пустая строка завершает корневой синтаксический блок. Внутренний `---` сохраняется там, где нужно продолжить внешнюю структуру. `node\` выбирает лексическую связь, а не переход к parent. [Границы блоков](../LMX_grammar.en.md#levels)

## Подсчёт исходников

Главная метрика — **число непробельных символов**: `sum(not ch.isspace() for ch in code)`. Пробельные символы исключаются только из измерения; исходник сохраняет необходимое форматирование. Также приведены полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF после последней строки.

Считается весь показанный листинг: объявления, импорты, необходимые языковые оболочки, методы и демонстрация. Внешний вызов, main, печать, тестовый harness, Markdown и реализация runtime/стандартной библиотеки не входят. Имена не нормализованы. Python записан без необязательных аннотаций; одинаковые статические гарантии не заявляются. Таблица измеряет эти программы, а не теоретический минимум для каждого языка.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX | Без сложного Throws |
|---|---:|---:|---:|---:|---:|
| LMX | 220 | 371 | 20 | 1.00× | 220 |
| Python | 425 | 588 | 28 | 1.93× | — |
| Java | 565 | 884 | 39 | 2.57× | — |
| C++ | 469 | 655 | 35 | 2.13× | — |
| C# | 552 | 924 | 47 | 2.51× | — |
| TypeScript | 543 | 752 | 37 | 2.47× | — |
| Go | 468 | 593 | 32 | 2.13× | — |
| Rust | 662 | 902 | 44 | 3.01× | — |

Отношение больше 1 означает более длинный листинг по непробельным символам.

## 1. LMX

```lmx
observer:
    int: value
    int: last 0
    int: total 0
    @: first remember
    @: second accumulate
    return: int
    remember:
        node\last := value
    accumulate:
        node\total += value
    notify:
        first()
        second()
    demo:
        node\last := 0
        node\total := 0
        notify(3)
        notify(8)
        return: node\total
```

Внешний вызов: `observer\demo()`. Он не входит в подсчёт.

Как в исходном Python, remember и accumulate работают с одним состоянием, а notify вызывает две сохранённые ссылки. В LMX эти методы естественно принадлежат одной структуре observer. first и second первоначально указывают на remember и accumulate через обычную форму @: name value; отдельный fn-контракт не добавляется. notify(3) и notify(8) задают собственный value, а вызовы обработчиков без аргументов заполняют их объявленный value копией через autofill. node\last и node\total явно выбирают лексическое состояние observer, сохраняющееся между уведомлениями. demo сбрасывает это состояние перед серией. Общее DATA может иметь поля, которых отдельный метод не читает. return:int описывает допустимый числовой результат demo; вызовы notify и обработчиков используются только ради эффектов, не потребляют результата и не требуют синтетического return.

Событие 3 даёт last = 3 и total = 3; событие 8 — last = 8 и total = 11. По два обработчика на событие: четыре вызова. Повторный demo начинает новую серию с явного сброса состояния.

## 2. Python

```python
class ObserverState:
    def __init__(self):
        self.last = 0
        self.total = 0

    def remember(self, observed):
        self.last = observed

    def accumulate(self, amount):
        self.total += amount


class Publisher:
    def __init__(self, first, second):
        self.first = first
        self.second = second

    def notify(self, event):
        self.first(event)
        self.second(event)


def demo():
    state = ObserverState()
    publisher = Publisher(state.remember, state.accumulate)
    publisher.notify(3)
    publisher.notify(8)
    return state.total
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 3. Java

```java
import java.util.function.IntConsumer;

class Example {
    static class ObserverState {
        int last;
        int total;

        void remember(int observed) {
            last = observed;
        }

        void accumulate(int amount) {
            total += amount;
        }
    }

    static class Publisher {
        IntConsumer first;
        IntConsumer second;

        Publisher(IntConsumer first, IntConsumer second) {
            this.first = first;
            this.second = second;
        }

        void notify(int event) {
            first.accept(event);
            second.accept(event);
        }
    }

    public static int demo() {
        ObserverState state = new ObserverState();
        Publisher publisher = new Publisher(state::remember, state::accumulate);
        publisher.notify(3);
        publisher.notify(8);
        return state.total;
    }
}
```

Внешний вызов: `Example.demo()`. Он не входит в подсчёт.

## 4. C++

```cpp
#include <functional>

struct ObserverState {
    int last = 0;
    int total = 0;

    void remember(int observed) {
        last = observed;
    }

    void accumulate(int amount) {
        total += amount;
    }
};

struct Publisher {
    std::function<void(int)> first;
    std::function<void(int)> second;

    void notify(int event) {
        first(event);
        second(event);
    }
};

int demo() {
    ObserverState state;
    Publisher publisher{
        [&state](int value) { state.remember(value); },
        [&state](int value) { state.accumulate(value); }
    };
    publisher.notify(3);
    publisher.notify(8);
    return state.total;
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 5. C#

```csharp
using System;

static class Example
{
    sealed class ObserverState
    {
        public int Last;
        public int Total;

        public void Remember(int observed)
        {
            Last = observed;
        }

        public void Accumulate(int amount)
        {
            Total += amount;
        }
    }

    sealed class Publisher
    {
        public Action<int> First;
        public Action<int> Second;

        public Publisher(Action<int> first, Action<int> second)
        {
            First = first;
            Second = second;
        }

        public void Notify(int value)
        {
            First(value);
            Second(value);
        }
    }

    public static int Demo()
    {
        var state = new ObserverState();
        var publisher = new Publisher(state.Remember, state.Accumulate);
        publisher.Notify(3);
        publisher.Notify(8);
        return state.Total;
    }
}
```

Внешний вызов: `Example.Demo()`. Он не входит в подсчёт.

## 6. TypeScript

```typescript
type Listener = (value: number) => void;

class ObserverState {
    last = 0;
    total = 0;

    remember = (observed: number): void => {
        this.last = observed;
    };

    accumulate = (amount: number): void => {
        this.total += amount;
    };
}

class Publisher {
    first: Listener;
    second: Listener;

    constructor(first: Listener, second: Listener) {
        this.first = first;
        this.second = second;
    }

    notify(event: number): void {
        this.first(event);
        this.second(event);
    }
}

function demo(): number {
    const state = new ObserverState();
    const publisher = new Publisher(state.remember, state.accumulate);
    publisher.notify(3);
    publisher.notify(8);
    return state.total;
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 7. Go

```go
package main

type ObserverState struct {
    last  int
    total int
}

func (state *ObserverState) remember(observed int) {
    state.last = observed
}

func (state *ObserverState) accumulate(amount int) {
    state.total += amount
}

type Publisher struct {
    first  func(int)
    second func(int)
}

func (publisher *Publisher) notify(event int) {
    publisher.first(event)
    publisher.second(event)
}

func demo() int {
    state := ObserverState{}
    publisher := Publisher{state.remember, state.accumulate}
    publisher.notify(3)
    publisher.notify(8)
    return state.total
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 8. Rust

```rust
use std::cell::Cell;

struct ObserverState {
    last: Cell<i32>,
    total: Cell<i32>,
}

impl ObserverState {
    fn remember(&self, observed: i32) {
        self.last.set(observed);
    }

    fn accumulate(&self, amount: i32) {
        self.total.set(self.total.get() + amount);
    }
}

struct Publisher<'a> {
    first: &'a dyn Fn(i32),
    second: &'a dyn Fn(i32),
}

impl<'a> Publisher<'a> {
    fn notify(&self, event: i32) {
        (self.first)(event);
        (self.second)(event);
    }
}

pub fn demo() -> i32 {
    let state = ObserverState {
        last: Cell::new(0),
        total: Cell::new(0),
    };
    let remember = |observed| state.remember(observed);
    let accumulate = |amount| state.accumulate(amount);
    let publisher = Publisher {
        first: &remember,
        second: &accumulate,
    };
    publisher.notify(3);
    publisher.notify(8);
    state.total.get()
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## Что изменилось в этой редакции

Сохранены два обработчика и явные записи в лексическое состояние observer. Ссылки на правила перенесены в docs.

Семь остальных листингов сохранены без изменений относительно загруженного архива.

## Проверка

LMX сопоставлен с правилами docs: роли DATA/CODE, аргументы, связывание, лексический node и синтаксические границы. Для copy/merge учитываются поток результата и явная группировка. Ожидаемые результаты относятся к этой модели.

В исходной редакции сообщалось об исполнении Python, Java, C++ и TypeScript и статическом просмотре C#, Go и Rust. Их листинги сохранены без изменений; новых запусков эта редакция не заявляет. LMX-ядро здесь не запускалось.

Метрики пересчитываются непосредственно из восьми основных блоков исходника. Внешний вызов и тестовая обвязка не включены.

## Источники правил и примеров

- [Связывание](../LMX_semantics.en.md#binding-places), [структурный вызов](../LMX_semantics.en.md#structural-call) и необязательный самостоятельный [fn-контракт](../LMX_semantics.en.md#fn-signature).
- [Переданные объявления](../LMX_semantics.en.md#declaration-arguments) и [импорт корневых const-объявлений](../LMX_semantics.en.md#import-receiver).
- [Пустая строка как завершение корневого блока](../LMX_grammar.en.md#levels).

Ранее использованные сетевые образцы ролей шаблона сохранены как источники. Показанные программы — адаптации общего сценария, а не дословные копии или измерение длины этих страниц.

- [Refactoring.Guru — Observer in Python, original conceptual example](https://refactoring.guru/design-patterns/observer/python/example)

