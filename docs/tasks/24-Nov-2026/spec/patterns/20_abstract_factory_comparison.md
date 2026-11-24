# 20. Abstract Factory: LMX и семь других языков

20 ноября 2026 года. Обновлено 21 ноября 2026 года. Продолжение серии: шаблоны 19–23.

## Задача

Light создаёт Button со значением 1 и Frame со значением 10; Dark — Button(2) и Frame(20). Потребитель вызывает оба фабричных метода и передаёт кнопку рамке. Frame.render(button) складывает своё значение с button.render(). Два семейства дают 11 и 22; demo возвращает 33.

**Внешний вызов LMX:** `Client\demo()`. **Ожидаемый результат: 33.**

Два семейства конфигураций и два вида продуктов; совместимость семейства обеспечена выбранной фабрикой и порядком действий потребителя. Продукты имеют общий формат и различаются настройками: для этого сценария отдельные подклассы LightButton/DarkButton не нужны. Никакой язык здесь не запрещает вручную смешать продукты двух семейств. Это не сравнение GUI-библиотек или автоматического доказательства совместимости. C++ выражает интерфейс фабрики двумя указателями на функции, сохраняя тот же выбор семейства во время выполнения.

## Архитектура LMX

Light определяет методы фабрики один раз и хранит theme=1. Dark копирует поля и методы через merge, меняя только theme на 2. button()/frame() вычисляют значения theme и theme*10; копия сохраняет правильного лексического владельца. Оба семейства, самостоятельные продукты и динамическая передача button в Frame остаются в договоре.

У Button и Frame разные роли и отдельные DATA. Light и Dark — обычные структуры с двумя фабричными методами; каждый метод объединяет модель и настройку посредством `merge` и явно группирует поток в один возвращаемый продукт. Текущий DATA фабрики в источники `merge` не входит. [Потоки полей и группировка][S] Client знает только button(), frame() и render(): имя конкретного семейства в его алгоритме отсутствует. В frame\render() поле button без инициализатора получает ссылку из локального контекста вызывающего; готовое value рамки сохраняется. Саму фабрику demo передаёт явно по имени, исключая раскрытие единственного структурного аргумента. В Python те же роли выражены небольшими классами без лишней иерархии базовых классов.

Применены согласованные правила: DATA метода — его фактический parent; обычные ссылки на методы не требуют отдельного `fn`; объявленные входы без initializer допускают autofill, свободные имена — связь с местом непосредственного caller. `node\` выбирает лексическую связь. Пустая строка завершает корневой блок. [Связывание](../LMX_semantics.en.md#binding-places) · [Импорт](../LMX_semantics.en.md#import-receiver) · [Границы блоков](../LMX_grammar.en.md#levels)

## Подсчёт исходников

Главная метрика — **непробельные символы**: `sum(not ch.isspace() for ch in code)`. Дополнительно показаны полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF в конце.

В подсчёт входят весь показанный исходник, импорты, необходимые языковые оболочки и `demo`. Внешний запуск, `main`, печать результата, тестовая обвязка и реализация стандартной библиотеки/runtime не включены. Имена не нормализованы. Python записан без необязательных аннотаций типов. Сравниваются конкретные реализации одной задачи; это не оценка быстродействия или одинаковых статических гарантий.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 414 | 610 | 32 | 1.00× |
| Python | 468 | 652 | 35 | 1.13× |
| Java | 591 | 859 | 34 | 1.43× |
| C++ | 470 | 624 | 34 | 1.14× |
| C# | 572 | 834 | 34 | 1.38× |
| TypeScript | 636 | 818 | 36 | 1.54× |
| Go | 582 | 728 | 36 | 1.41× |
| Rust | 598 | 793 | 40 | 1.44× |

Общая таблица этой пятёрки доступна в [Excel](LMX_Comparison_19-23.xlsx) и [PDF](LMX_Comparison_19-23.pdf).

## 1. LMX

<!-- counted-lmx: primary -->
```lmx
Button:
    int: value
    return: int
    render:
        return: value

Frame:
    int: value
    @: button
    return: int
    render:
        return: value + button\render()

Light:
    int: theme 1
    return: @
    button:
        return: derive(Button; (int: value theme))
    frame:
        return: derive(Frame; (int: value theme * 10))

Dark: merge(Light; (int: theme 2))

Client:
    @: factory
    return: int
    render:
        @: button factory\button()
        @: frame factory\frame()
        return: frame\render()
    demo:
        return: render(factory := Light) + render(factory := Dark)
```
Внешний вызов: `Client\demo()`. Он не входит в подсчёт.

Client\render(factory := Light) получает кнопку 1 и рамку 10, затем Frame.render вызывает Button.render и возвращает 11. Тот же Client\render(factory := Dark) получает 2 и 20 и возвращает 22. Семейство выбирается одним аргументом фабрики, оба продукта создаются через неё. Повторные вызовы фабричных методов создают отдельные продукты.

### Прямой ресивер текущего ядра

`derive(base; overlay)` выполняет ту же общую композицию, что прежняя сгруппированная merge. Все поля Button/Frame, обе семьи, сохранённая ссылка button и оба render остаются в программе. Это архитектурная запись LMX; дополнительного предметного алгоритма внутри ресивера нет. Конструкторы и обычные поля контрольных языков выполняют сопоставимое создание/инициализацию объектов. Импорт ядра не требуется.

[Полное определение RxDerive](LMX_Fn_Receivers/src/structures.lmx) содержит обычный merge и показано здесь для проверки границы. Его текст не включён в размер клиента, как и код runtime/конструкторных механизмов других языков.

<!-- uncounted-lmx: core-implementation -->
```lmx
RxDerive:
    @: base
    @: extension
    return: @
    derive:
        return: (merge(base; extension))
```
### Небольшое отличие без повторного листинга

Два общих вызова `derive(model; overlay)` можно записать как `(merge(model; overlay))`. Это та же композиция, поэтому полный дублирующий листинг не повторяется.


## 2. Python

```python
class Button:
    def __init__(self, value):
        self.value = value

    def render(self):
        return self.value

class Frame:
    def __init__(self, value):
        self.value = value

    def render(self, button):
        return self.value + button.render()

class Light:
    def button(self):
        return Button(1)

    def frame(self):
        return Frame(10)

class Dark:
    def button(self):
        return Button(2)

    def frame(self):
        return Frame(20)

def render(factory):
    button = factory.button()
    frame = factory.frame()
    return frame.render(button)

def demo():
    return render(Light()) + render(Dark())
```
Внешний вызов: `demo()`. Он не входит в подсчёт.

## 3. Java

```java
class Example {
    record Button(int value) {
        int render() { return value; }
    }

    record Frame(int value) {
        int render(Button button) { return value + button.render(); }
    }

    interface Factory {
        Button button();
        Frame frame();
    }

    static class Light implements Factory {
        public Button button() { return new Button(1); }
        public Frame frame() { return new Frame(10); }
    }

    static class Dark implements Factory {
        public Button button() { return new Button(2); }
        public Frame frame() { return new Frame(20); }
    }

    static int render(Factory factory) {
        Button button = factory.button();
        Frame frame = factory.frame();
        return frame.render(button);
    }

    static int demo() {
        return render(new Light()) + render(new Dark());
    }
}
```
Внешний вызов: `Example.demo()`. Он не входит в подсчёт.

## 4. C++

```cpp
struct Button {
    int value;
    int render() const { return value; }
};

struct Frame {
    int value;
    int render(const Button& button) const { return value + button.render(); }
};

struct Factory {
    Button (*button)();
    Frame (*frame)();
};

const Factory light {
    [] { return Button{1}; },
    [] { return Frame{10}; }
};

const Factory dark {
    [] { return Button{2}; },
    [] { return Frame{20}; }
};

int render(const Factory& factory) {
    auto button = factory.button();
    auto frame = factory.frame();
    return frame.render(button);
}

int demo() {
    return render(light) + render(dark);
}
```
Внешний вызов: `demo()`. Он не входит в подсчёт.

## 5. C#

```csharp
static class Example {
    sealed record Button(int Value) {
        public int Render() => Value;
    }

    sealed record Frame(int Value) {
        public int Render(Button button) => Value + button.Render();
    }

    interface IFactory {
        Button Button();
        Frame Frame();
    }

    sealed class Light : IFactory {
        public Button Button() => new Button(1);
        public Frame Frame() => new Frame(10);
    }

    sealed class Dark : IFactory {
        public Button Button() => new Button(2);
        public Frame Frame() => new Frame(20);
    }

    static int Render(IFactory factory) {
        var button = factory.Button();
        var frame = factory.Frame();
        return frame.Render(button);
    }

    public static int Demo() {
        return Render(new Light()) + Render(new Dark());
    }
}
```
Внешний вызов: `Example.Demo()`. Он не входит в подсчёт.

## 6. TypeScript

```typescript
class Button {
    value: number;
    constructor(value: number) { this.value = value; }
    render(): number { return this.value; }
}

class Frame {
    value: number;
    constructor(value: number) { this.value = value; }
    render(button: Button): number { return this.value + button.render(); }
}

interface Factory {
    button(): Button;
    frame(): Frame;
}

class Light {
    button(): Button { return new Button(1); }
    frame(): Frame { return new Frame(10); }
}

class Dark {
    button(): Button { return new Button(2); }
    frame(): Frame { return new Frame(20); }
}

function render(factory: Factory): number {
    const button = factory.button();
    const frame = factory.frame();
    return frame.render(button);
}

function demo(): number {
    return render(new Light()) + render(new Dark());
}
```
Внешний вызов: `demo()`. Он не входит в подсчёт.

## 7. Go

```go
package main

type Button struct { value int }

func (button Button) render() int { return button.value }

type Frame struct { value int }

func (frame Frame) render(button Button) int {
    return frame.value + button.render()
}

type Factory interface {
    button() Button
    frame() Frame
}

type Light struct{}

func (Light) button() Button { return Button{1} }
func (Light) frame() Frame { return Frame{10} }

type Dark struct{}

func (Dark) button() Button { return Button{2} }
func (Dark) frame() Frame { return Frame{20} }

func render(factory Factory) int {
    button := factory.button()
    frame := factory.frame()
    return frame.render(button)
}

func demo() int {
    return render(Light{}) + render(Dark{})
}
```
Внешний вызов: `demo()`. Он не входит в подсчёт.

## 8. Rust

```rust
struct Button { value: i32 }

impl Button {
    fn render(&self) -> i32 { self.value }
}

struct Frame { value: i32 }

impl Frame {
    fn render(&self, button: &Button) -> i32 { self.value + button.render() }
}

trait Factory {
    fn button(&self) -> Button;
    fn frame(&self) -> Frame;
}

struct Light;

impl Factory for Light {
    fn button(&self) -> Button { Button { value: 1 } }
    fn frame(&self) -> Frame { Frame { value: 10 } }
}

struct Dark;

impl Factory for Dark {
    fn button(&self) -> Button { Button { value: 2 } }
    fn frame(&self) -> Frame { Frame { value: 20 } }
}

fn render(factory: &dyn Factory) -> i32 {
    let button = factory.button();
    let frame = factory.frame();
    frame.render(&button)
}

pub fn demo() -> i32 {
    render(&Light) + render(&Dark)
}
```
Внешний вызов: `demo()`. Он не входит в подсчёт.

## Проверка

В этой редакции проверены согласованность LMX-листинга с документами `docs`, явная группировка результатов копирования/композиции там, где нужен один объект, и ссылки на правила языка. Ожидаемый результат LMX следует из показанного сценария; запуск ядра не проводился.

Листинги Python, Java, C++, C#, TypeScript, Go и Rust сохранены из исходного сравнения. Сообщения исходной редакции об их выполнении относятся к той проверке; это обновление документации не выдаёт их за новый запуск. Подсчёт размеров выполняется заново по листингам текущего файла.

## Источники

Сетевые образцы использованы для проверки ролей шаблона. Показанные программы — самостоятельные адаптации общего сценария, а не подсчёт длины исходников этих страниц.

- [Refactoring.Guru — Abstract Factory](https://refactoring.guru/design-patterns/abstract-factory)
- [Refactoring.Guru — Abstract Factory in Python](https://refactoring.guru/design-patterns/abstract-factory/python/example)


[S]: ../LMX_semantics.en.md#merge-two-forms
