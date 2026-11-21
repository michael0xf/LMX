# 10. State: LMX и семь других языков

20 ноября 2026 года. Продолжение серии: шаблоны 10–18.

## Задача

Два состояния closed и opened возвращают 0 и 1 и переводят машину друг в друга. Три последовательных обращения должны дать 0, 1, 0. Клиент вызывает текущую ссылку, а не проверяет числовой код состояния.

**Внешний вызов LMX:** `machine\demo()`. **Ожидаемый результат: 1.**

Это поведенческие состояния в виде callable, без обязательной иерархии классов State. Демонстрация создаёт собственный контекст заново. В LMX private на state запретил бы показанное неявное связывание; здесь такой модификатор не задан.

## Архитектура LMX

В Python текущая ссылка хранится у Machine и обозначает bound method. LMX хранит state в локальном контексте demo; closed и opened получают это место как свободное имя и меняют его. Вызов выполняется непосредственно из demo, поэтому промежуточный fallback и запись в граф не требуются.

Применены согласованные правила: DATA метода — его фактический parent; обычные ссылки на методы не требуют отдельного `fn`; объявленные входы без initializer допускают autofill, свободные имена — связь с местом непосредственного caller. `node\` выбирает лексическую связь. Пустая строка завершает корневой блок. [Связывание][B] · [Импорт][D] · [Границы блоков][E]

## Подсчёт исходников

Главная метрика — **непробельные символы**: `sum(not ch.isspace() for ch in code)`. Дополнительно показаны полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF в конце.

В подсчёт входят весь показанный исходник, импорты, необходимые языковые оболочки и `demo`. Внешний запуск, `main`, печать результата, тестовая обвязка и реализация стандартной библиотеки/runtime не включены. Имена не нормализованы. Python записан без необязательных аннотаций типов. Сравниваются конкретные реализации одной задачи; это не оценка быстродействия или одинаковых статических гарантий.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 152 | 270 | 14 | 1.00× |
| Python | 250 | 362 | 18 | 1.64× |
| Java | 326 | 481 | 23 | 2.14× |
| C++ | 307 | 435 | 22 | 2.02× |
| C# | 267 | 443 | 27 | 1.76× |
| TypeScript | 283 | 414 | 21 | 1.86× |
| Go | 325 | 429 | 24 | 2.14× |
| Rust | 340 | 481 | 23 | 2.24× |

Общая таблица серии доступна в [Excel](LMX_Comparison_10-18.xlsx) и [PDF](LMX_Comparison_10-18.pdf).

## 1. LMX

```lmx
machine:
    return: int
    closed:
        state := opened
        return: 0
    opened:
        state := closed
        return: 1
    demo:
        @: state closed
        int: result state()
        result += state()
        result += state()
        return: result
```

Внешний вызов: `machine\demo()`. Он не входит в подсчёт.

demo создаёт state = closed. Первый вызов возвращает 0 и выбирает opened; второй возвращает 1 и выбирает closed; третий возвращает 0. Вызовы разделены на три оператора, поэтому порядок эффектов не зависит от приоритетов одного арифметического выражения. Сумма равна 1.

## 2. Python

```python
class Machine:
    def __init__(self):
        self.state = self.closed

    def closed(self):
        self.state = self.opened
        return 0

    def opened(self):
        self.state = self.closed
        return 1

def demo():
    machine = Machine()
    result = machine.state()
    result += machine.state()
    result += machine.state()
    return result
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 3. Java

```java
import java.util.function.IntSupplier;

class Example {
    IntSupplier state = this::closed;

    int closed() {
        state = this::opened;
        return 0;
    }

    int opened() {
        state = this::closed;
        return 1;
    }

    public static int demo() {
        Example machine = new Example();
        int result = machine.state.getAsInt();
        result += machine.state.getAsInt();
        result += machine.state.getAsInt();
        return result;
    }
}
```

Внешний вызов: `Example.demo()`. Он не входит в подсчёт.

## 4. C++

```cpp
struct Machine {
    using State = int (Machine::*)();
    State state = &Machine::closed;

    int closed() {
        state = &Machine::opened;
        return 0;
    }

    int opened() {
        state = &Machine::closed;
        return 1;
    }
};

int demo() {
    Machine machine;
    int result = (machine.*machine.state)();
    result += (machine.*machine.state)();
    result += (machine.*machine.state)();
    return result;
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 5. C#

```csharp
using System;

class Example {
    Func<int> state;

    Example() {
        state = Closed;
    }

    int Closed() {
        state = Opened;
        return 0;
    }

    int Opened() {
        state = Closed;
        return 1;
    }

    public static int Demo() {
        var machine = new Example();
        int result = machine.state();
        result += machine.state();
        result += machine.state();
        return result;
    }
}
```

Внешний вызов: `Example.Demo()`. Он не входит в подсчёт.

## 6. TypeScript

```typescript
class Machine {
    closed = (): number => {
        this.state = this.opened;
        return 0;
    };

    opened = (): number => {
        this.state = this.closed;
        return 1;
    };

    state: () => number = this.closed;
}

function demo(): number {
    const machine = new Machine();
    let result = machine.state();
    result += machine.state();
    result += machine.state();
    return result;
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 7. Go

```go
package main

type Machine struct {
    state func() int
}

func (machine *Machine) closed() int {
    machine.state = machine.opened
    return 0
}

func (machine *Machine) opened() int {
    machine.state = machine.closed
    return 1
}

func demo() int {
    machine := &Machine{}
    machine.state = machine.closed
    result := machine.state()
    result += machine.state()
    result += machine.state()
    return result
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 8. Rust

```rust
struct Machine {
    state: fn(&mut Machine) -> i32,
}

impl Machine {
    fn closed(&mut self) -> i32 {
        self.state = Self::opened;
        0
    }

    fn opened(&mut self) -> i32 {
        self.state = Self::closed;
        1
    }
}

pub fn demo() -> i32 {
    let mut machine = Machine { state: Machine::closed };
    let mut result = (machine.state)(&mut machine);
    result += (machine.state)(&mut machine);
    result += (machine.state)(&mut machine);
    result
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## Проверка

Python, Java и C++17 исполнены с ожидаемыми результатами. TypeScript исполнен в Node с удалением аннотаций типов; отдельная статическая проверка TypeScript не выполнялась. Проверены последовательные переходы состояний и независимый повтор demo. C#, Go и Rust проверены статически; их компиляторы в этой среде недоступны.

Метрики пересчитаны из восьми листингов этого файла. Ожидаемый результат LMX проверен по правилам языка; исполнение на ядре LMX не проводилось.

## Источники

Сетевые образцы использованы для проверки ролей шаблона. Показанные программы — самостоятельные адаптации общего сценария, а не подсчёт длины исходников этих страниц.

- [Refactoring.Guru — State in Python, conceptual example](https://refactoring.guru/design-patterns/state/python/example)

[B]: reference/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md
[D]: reference/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md
[E]: reference/LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md
