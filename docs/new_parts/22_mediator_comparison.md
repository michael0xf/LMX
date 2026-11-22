# 22. Mediator: LMX и семь других языков

20 ноября 2026 года. Обновлено 21 ноября 2026 года. Продолжение серии: шаблоны 19–23.

## Задача

Переключатель Control хранит enabled, вентилятор Fan — running. Control.toggle меняет собственный флаг и посылает событие 1. Fan.stop сбрасывает свой флаг и посылает событие 2. Посредник при событии 1 приводит running к enabled, а при событии 2 выключает Control. Оба флага изначально равны 0.

**Внешний вызов LMX:** `Demo\run()`. **Ожидаемый результат: 10.**

Синхронный пример с двумя фиксированными компонентами и двумя событиями. Событие задаёт отправителя однозначно; общий реестр подписчиков не нужен. Прямые записи посредника не генерируют новых событий, поэтому цикл уведомлений не возникает. В Rust локальное замыкание посредника и Cell обеспечивают ту же связь без циклического владения. Копирование уже связанного C++ Room и перенос компонентов между посредниками не входят в сценарий.

## Архитектура LMX

В Python Room передаёт свой notify двум компонентам как callback. В LMX control и fan вложены в Room и обращаются к лексически видимому notify. Компоненты не называют друг друга. Их методы изменяют собственные хранимые флаги через node\; node здесь обозначает лексическое пространство компонента. Посредник единственный содержит правила взаимного изменения полей. `(copy(Room))` создаёт независимый комплект компонентов: `copy` сохраняет общую карту копирования и перенаправляет внутренние лексические связи, а явная группа собирает одну Structure для `room`. [Потоки полей и группировка][S]

Применены согласованные правила: DATA метода — его фактический parent; обычные ссылки на методы не требуют отдельного `fn`; объявленные входы без initializer допускают autofill, свободные имена — связь с местом непосредственного caller. `node\` выбирает лексическую связь. Пустая строка завершает корневой блок. [Связывание](../LMX_semantics.en.md#binding-places) · [Импорт][D] · [Границы блоков][E]

## Подсчёт исходников

Главная метрика — **непробельные символы**: `sum(not ch.isspace() for ch in code)`. Дополнительно показаны полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF в конце.

В подсчёт входят весь показанный исходник, импорты, необходимые языковые оболочки и `demo`. Внешний запуск, `main`, печать результата, тестовая обвязка и реализация стандартной библиотеки/runtime не включены. Имена не нормализованы. Python записан без необязательных аннотаций типов. Сравниваются конкретные реализации одной задачи; это не оценка быстродействия или одинаковых статических гарантий.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 350 | 605 | 28 | 1.00× |
| Python | 538 | 787 | 35 | 1.54× |
| Java | 406 | 687 | 33 | 1.16× |
| C++ | 529 | 744 | 36 | 1.51× |
| C# | 610 | 909 | 41 | 1.74× |
| TypeScript | 425 | 661 | 30 | 1.21× |
| Go | 513 | 697 | 41 | 1.47× |
| Rust | 625 | 862 | 40 | 1.79× |

Общая таблица этой пятёрки доступна в [Excel](LMX_Comparison_19-23.xlsx) и [PDF](LMX_Comparison_19-23.pdf).

## 1. LMX

```lmx
Room:
    control:
        int: enabled 0
        toggle:
            node\enabled := 1 - node\enabled
            notify(event := 1)
    ---
    fan:
        int: running 0
        stop:
            node\running := 0
            notify(event := 2)
    ---
    int: event
    notify:
        if: event = 1
            fan\running := control\enabled
        if: event = 2
            control\enabled := 0

Demo:
    return: int
    run:
        @: room (copy(Room))
        room\control\toggle()
        int: first room\fan\running
        room\fan\stop()
        return: first * 10 + room\control\enabled
```

Внешний вызов: `Demo\run()`. Он не входит в подсчёт.

После toggle оба флага равны 1, поэтому first = 1. Вызов stop обнуляет running, а посредник обнуляет enabled. Итог: 1 × 10 + 0 = 10. Обратная реакция показывает, что это двустороннее согласование через посредника.

## 2. Python

```python
class Control:
    def __init__(self, notify):
        self.enabled = 0
        self.notify = notify

    def toggle(self):
        self.enabled = 1 - self.enabled
        self.notify(1)

class Fan:
    def __init__(self, notify):
        self.running = 0
        self.notify = notify

    def stop(self):
        self.running = 0
        self.notify(2)

class Room:
    def __init__(self):
        self.control = Control(self.notify)
        self.fan = Fan(self.notify)

    def notify(self, event):
        if event == 1:
            self.fan.running = self.control.enabled
        if event == 2:
            self.control.enabled = 0

def demo():
    room = Room()
    room.control.toggle()
    first = room.fan.running
    room.fan.stop()
    return first * 10 + room.control.enabled
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 3. Java

```java
class Room {
    class Control {
        int enabled;
        void toggle() {
            enabled = 1 - enabled;
            changed(1);
        }
    }

    class Fan {
        int running;
        void stop() {
            running = 0;
            changed(2);
        }
    }

    Control control = new Control();
    Fan fan = new Fan();

    void changed(int event) {
        if (event == 1) fan.running = control.enabled;
        if (event == 2) control.enabled = 0;
    }

    static int demo() {
        Room room = new Room();
        room.control.toggle();
        int first = room.fan.running;
        room.fan.stop();
        return first * 10 + room.control.enabled;
    }
}
```

Внешний вызов: `Room.demo()`. Он не входит в подсчёт.

## 4. C++

```cpp
#include <functional>

struct Control {
    int enabled = 0;
    std::function<void(int)> notify;
    void toggle() {
        enabled = 1 - enabled;
        notify(1);
    }
};

struct Fan {
    int running = 0;
    std::function<void(int)> notify;
    void stop() {
        running = 0;
        notify(2);
    }
};

struct Room {
    Control control{0, [this](int event) { notify(event); }};
    Fan fan{0, [this](int event) { notify(event); }};
    void notify(int event) {
        if (event == 1) fan.running = control.enabled;
        if (event == 2) control.enabled = 0;
    }
};

int demo() {
    Room room;
    room.control.toggle();
    int first = room.fan.running;
    room.fan.stop();
    return first * 10 + room.control.enabled;
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 5. C#

```csharp
using System;

class Control {
    public int Enabled;
    public Action<int> Notify;
    public Control(Action<int> notify) { Notify = notify; }
    public void Toggle() {
        Enabled = 1 - Enabled;
        Notify(1);
    }
}

class Fan {
    public int Running;
    public Action<int> Notify;
    public Fan(Action<int> notify) { Notify = notify; }
    public void Stop() {
        Running = 0;
        Notify(2);
    }
}

class Room {
    Control control;
    Fan fan;
    public Room() {
        control = new Control(Notify);
        fan = new Fan(Notify);
    }
    void Notify(int e) {
        if (e == 1) fan.Running = control.Enabled;
        if (e == 2) control.Enabled = 0;
    }
    public static int Demo() {
        var room = new Room();
        room.control.Toggle();
        int first = room.fan.Running;
        room.fan.Stop();
        return first * 10 + room.control.Enabled;
    }
}
```

Внешний вызов: `Room.Demo()`. Он не входит в подсчёт.

## 6. TypeScript

```typescript
class Room {
    control = {
        enabled: 0,
        toggle: () => {
            this.control.enabled = 1 - this.control.enabled;
            this.notify(1);
        }
    };

    fan = {
        running: 0,
        stop: () => {
            this.fan.running = 0;
            this.notify(2);
        }
    };

    notify(event: number): void {
        if (event === 1) this.fan.running = this.control.enabled;
        if (event === 2) this.control.enabled = 0;
    }
}

function demo(): number {
    const room = new Room();
    room.control.toggle();
    const first = room.fan.running;
    room.fan.stop();
    return first * 10 + room.control.enabled;
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 7. Go

```go
package main

type Control struct {
    enabled int
    notify func(int)
}

func (c *Control) toggle() {
    c.enabled = 1 - c.enabled
    c.notify(1)
}

type Fan struct {
    running int
    notify func(int)
}

func (f *Fan) stop() {
    f.running = 0
    f.notify(2)
}

type Room struct {
    control Control
    fan Fan
}

func (r *Room) notify(event int) {
    if event == 1 { r.fan.running = r.control.enabled }
    if event == 2 { r.control.enabled = 0 }
}

func demo() int {
    room := &Room{}
    room.control.notify = room.notify
    room.fan.notify = room.notify
    room.control.toggle()
    first := room.fan.running
    room.fan.stop()
    return first * 10 + room.control.enabled
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 8. Rust

```rust
use std::cell::Cell;

struct Control<'a> {
    enabled: &'a Cell<i32>,
    notify: &'a dyn Fn(i32),
}

impl Control<'_> {
    fn toggle(&self) {
        self.enabled.set(1 - self.enabled.get());
        (self.notify)(1);
    }
}

struct Fan<'a> {
    running: &'a Cell<i32>,
    notify: &'a dyn Fn(i32),
}

impl Fan<'_> {
    fn stop(&self) {
        self.running.set(0);
        (self.notify)(2);
    }
}

pub fn demo() -> i32 {
    let enabled = Cell::new(0);
    let running = Cell::new(0);
    let notify = |event| {
        if event == 1 { running.set(enabled.get()); }
        if event == 2 { enabled.set(0); }
    };
    let control = Control { enabled: &enabled, notify: &notify };
    let fan = Fan { running: &running, notify: &notify };
    control.toggle();
    let first = fan.running.get();
    fan.stop();
    first * 10 + control.enabled.get()
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## Проверка

В этой редакции проверены согласованность LMX-листинга с документами `docs`, явная группировка результатов копирования/композиции там, где нужен один объект, и ссылки на правила языка. Ожидаемый результат LMX следует из показанного сценария; запуск ядра не проводился.

Листинги Python, Java, C++, C#, TypeScript, Go и Rust сохранены из исходного сравнения. Сообщения исходной редакции об их выполнении относятся к той проверке; это обновление документации не выдаёт их за новый запуск. Подсчёт размеров выполняется заново по листингам текущего файла.

## Источники

Сетевые образцы использованы для проверки ролей шаблона. Показанные программы — самостоятельные адаптации общего сценария, а не подсчёт длины исходников этих страниц.

- [Refactoring.Guru — Mediator in Python, conceptual example](https://refactoring.guru/design-patterns/mediator/python/example)

[D]: ../tasks/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md
[E]: ../tasks/LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md

[S]: ../LMX_semantics.en.md#merge-two-forms
