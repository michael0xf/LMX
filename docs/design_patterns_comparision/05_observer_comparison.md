# 05. Observer: сравнение исходников LMX и семи других языков

20 ноября 2026 года · Один сценарий, восемь реализаций

## Задача и границы примера

Издатель синхронно передаёт события 3 и 8 двум обработчикам. Первый запоминает последнее значение, второй суммирует. После обоих событий last = 8, total = 11; demo возвращает total.

**Ожидаемый результат демонстрации: `11`.**

Во всех вариантах ровно два хранимых callback-слота и последовательное уведомление first, затем second. Динамический список, отписка, потоки и обработка ошибок не добавлены. В LMX состояние находится в графе и явно сбрасывается; в остальных версиях demo создаёт новое состояние с нуля. Срок жизни вне demo различается, но повторяемый сценарий и роли одинаковы. Это ограниченный Observer с фиксированным числом подписок. В LMX Publisher уже содержит обработчики по умолчанию. В остальных версиях та же начальная подписка явно задаётся при создании Publisher; это сопоставимый сценарий уведомления, а не полная копия API дефолтов.

LMX взят без изменений из [согласованной русской подборки примеров](https://chatgpt.com/library?file_id=libfile_fde3_f-e112f68f2f20819185805436a1f1f225_bbe92b09b62881918d17958175103ded&account_id=personal). Для остальных языков найдены сетевые образцы по названию шаблона; на их основе написаны сопоставимые реализации именно этого сценария. Это оригинальная адаптация, а не дословная копия кода сайта и не измерение длины его полного учебного листинга. Источники приведены в конце.

## Как считались символы

Главная величина — **число непробельных символов** в показанном блоке исходника: все символы, для которых Python `str.isspace()` возвращает false. Пробелы, табуляции и переводы строк не учитываются. Это счётчик, а не преобразование кода в исполняемый минифицированный вариант; пробельные символы внутри строк также не считаются.

Дополнительно показаны полный размер в символах Unicode и число физических строк. Для полного размера используется LF, без начальных и конечных пустых строк и с одним LF в конце. Здесь все исходники ASCII, поэтому при UTF-8 число байтов совпадает с полным числом символов.

Считаются объявления, импорты, обязательные классы-оболочки или `package`, вспомогательные функции и весь демонстрационный сценарий внутри `demo` / `Demo` / LMX `run`. Внешний запуск, `main`, печать результата, тестовый harness, Markdown и пояснения не входят. Реализация стандартной библиотеки и runtime не входит ни для одного языка. В измеряемом коде нет комментариев.

Обычные функции, замыкания и стандартные типы callable разрешены. Python приведён без необязательных аннотаций типов; это не равенство статических гарантий с LMX или другими типизированными вариантами. Имена и учебная разбивка не нормализованы: числа описывают эти конкретные листинги, а не минимально возможную длину программы на языке.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 525 | 721 | 37 | 1.00× |
| Python | 425 | 588 | 28 | 0.81× |
| Java | 565 | 884 | 39 | 1.08× |
| C++ | 469 | 655 | 35 | 0.89× |
| C# | 552 | 924 | 47 | 1.05× |
| TypeScript | 543 | 752 | 37 | 1.03× |
| Go | 468 | 593 | 32 | 0.89× |
| Rust | 662 | 902 | 44 | 1.26× |

Отношение больше 1 означает, что этот листинг длиннее показанного LMX по непробельным символам.

## 1. LMX

```lmx
ObserverState:
    int: last 0
    int: total 0
end: ObserverState

fn: ListenerSignature (int: value)

Remember:
    int: observed
    accept:
        ObserverState\last := observed
end: Remember

Accumulate:
    int: amount
    accept:
        ObserverState\total += amount
end: Accumulate

Publisher:
    @: first ListenerSignature Remember\accept
    @: second ListenerSignature Accumulate\accept
    int: event
    notify:
        first(value := event)
        second(value := event)
end: Publisher

Demo:
    return: int
    run:
        ObserverState\last := 0
        ObserverState\total := 0
        Publisher\notify(event := 3)
        Publisher\notify(event := 8)
        return: ObserverState\total
end: Demo
```

Вызов из исполняемого контекста: `Demo\run()`. Сам этот внешний вызов не входит в подсчёт.

Считаются последние согласованные правила `fn`, структурных требований, связывания и `import` из исходной подборки.

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

Внешний вызов: `demo()`.

Связанные методы несут ссылку на state. Типы обработчиков не аннотированы; Publisher требует лишь вызываемые значения с подходящим поведением.

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

Внешний вызов: `Example.demo()`.

IntConsumer — стандартный контракт int → void. Две ссылки на методы связаны с одним объектом состояния; его int-поля при создании равны нулю.

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

Внешний вызов: `demo()`.

std::function хранит замыкания; state захвачен по ссылке и живёт дольше publisher. Динамическое создание подписчиков или владение долгоживущим состоянием не моделируется.

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

Внешний вызов: `Example.Demo()`.

Action<int> хранит связанный метод. Встроенный event здесь не используется: он добавил бы иной механизм списка подписчиков, которого нет в данном примере LMX.

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

Внешний вызов: `demo()`.

Стрелочные обработчики сохраняют this объекта state. Сигнатура Listener статическая; её проверка не входит в исполнение JavaScript после удаления типов.

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

Внешний вызов: `demo()`.

Method values сохраняют указатель на state. Publisher содержит два поля функционального типа; нулевые значения int задают исходное состояние.

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

Внешний вызов: `demo()`.

Cell позволяет двум обработчикам безопасно изменять общее состояние через разделяемые ссылки в одном потоке. Время жизни callback-ссылок явно ограничено; unsafe и глобальное изменяемое состояние не нужны.

## Проверка и воспроизводимость

Python, Java, C++ и TypeScript исполнены: два последовательных вызова входа дали `11` и `11`. Java проверена OpenJDK 21; C++ — g++ в режиме C++17; TypeScript — Node.js 24 с удалением типов перед исполнением. Для TypeScript это проверка выполнения, а не отдельный прогон `tsc --strict`. C#, Go и Rust прошли статическое ревью; их компиляторы в среде отсутствуют. LMX проверен по документам, без запуска ядра.

Смысловые свойства, сохранённые в демонстрации (кроме запуска входа, проверены чтением кода):

- demo() возвращает 11 при каждом вызове.
- События передаются обоим подписчикам в одинаковом порядке.
- После последнего события состояние last равно 8, total равно 11.
- Publisher хранит два заменяемых обработчика, а не вызывает жёстко заданные действия напрямую.

Подсчёт воспроизводится непосредственно по восьми блокам исходников выше: `sum(not ch.isspace() for ch in code)` для основной колонки и `len(code)` для полной. Перед подсчётом применяется описанная нормализация перевода строк.

## Найденные сетевые образцы

1. [Refactoring.Guru — Observer in Python, original conceptual example](https://refactoring.guru/design-patterns/observer/python/example). Источник разделяет издателя и подписчиков. Для сопоставимости с LMX убраны динамический список, attach/detach, случайное изменение состояния и печать. Ниже самостоятельные реализации двух слотов с событиями 3 и 8.

Из сетевых материалов взяты ориентиры по ролям участников и взаимодействию. Имена, арифметика, объём поведения и код адаптированы к общему LMX-сценарию. Сравнение не переносит в маленький пример дополнительные функции исходного учебного проекта.
