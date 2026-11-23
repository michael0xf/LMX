# 15. Builder: LMX и семь других языков

20 ноября 2026 года. Обновлено 21 ноября 2026 года. Продолжение серии: шаблоны 10–18.

## Задача

Два шага задают width и height; finish выдаёт самостоятельный прямоугольник. Первый продукт 3×4 сохраняется, пока тот же builder собирает второй 5×2. Сумма площадей равна 22.

**Внешний вызов LMX:** `Rectangle\demo()`. **Ожидаемый результат: 22.**

Один вид продукта, два шага, повторное использование builder и независимость результатов. Отдельный Director и семейство разных представлений не входят в пример. Размеры — обычные int; проверка геометрических ограничений не добавлена ни в одном языке.

## Архитектура LMX

Python отделяет Rectangle от Builder, который хранит заготовку и выдаёт её копию. В LMX заготовка — Rectangle, а операции builder вложены рядом с area и demo. builder имеет собственное DATA для value и результата Rectangle; node\width и node\height выбирают лексические поля заготовки. finish получает поток копии уже записанного графа через `copy(Rectangle)` и возвращает одну Structure, явно сгруппированную как `(copy(Rectangle))`. [Потоки полей и группировка][S]

Применены согласованные правила: DATA метода — его фактический parent; обычные ссылки на методы не требуют отдельного `fn`; объявленные входы без initializer допускают autofill, свободные имена — связь с местом непосредственного caller. `node\` выбирает лексическую связь. Пустая строка завершает корневой блок. [Связывание](../LMX_semantics.en.md#binding-places) · [Импорт](../LMX_semantics.en.md#import-receiver) · [Границы блоков](../LMX_grammar.en.md#levels)

## Подсчёт исходников

Главная метрика — **непробельные символы**: `sum(not ch.isspace() for ch in code)`. Дополнительно показаны полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF в конце.

В подсчёт входят весь показанный исходник, импорты, необходимые языковые оболочки и `demo`. Внешний запуск, `main`, печать результата, тестовая обвязка и реализация стандартной библиотеки/runtime не включены. Имена не нормализованы. Python записан без необязательных аннотаций типов. Сравниваются конкретные реализации одной задачи; это не оценка быстродействия или одинаковых статических гарантий.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX | Без сложного Throws |
|---|---:|---:|---:|---:|---:|
| LMX | 355 | 569 | 24 | 1.00× | 355 |
| Python | 499 | 680 | 32 | 1.41× | — |
| Java | 574 | 922 | 39 | 1.62× | — |
| C++ | 436 | 617 | 34 | 1.23× | — |
| C# | 581 | 925 | 40 | 1.64× | — |
| TypeScript | 514 | 704 | 35 | 1.45× | — |
| Go | 543 | 685 | 36 | 1.53× | — |
| Rust | 565 | 767 | 41 | 1.59× | — |

Общая таблица серии доступна в [Excel](LMX_Comparison_10-18.xlsx) и [PDF](LMX_Comparison_10-18.pdf).

## 1. LMX

```lmx
Rectangle:
    int: width 0
    int: height 0
    return: int
    area:
        return: width * height
    builder:
        int: value
        return: Rectangle
        set_width:
            node\width := value
        set_height:
            node\height := value
        finish:
            return: (copy(Rectangle))
    ---
    demo:
        builder\set_width(3)
        builder\set_height(4)
        @: first builder\finish()
        builder\set_width(5)
        builder\set_height(2)
        @: second builder\finish()
        return: first\area() + second\area()
```

Внешний вызов: `Rectangle\demo()`. Он не входит в подсчёт.

После первых двух шагов first имеет размеры 3 и 4. Изменение заготовки на 5 и 2 не меняет first: finish создаёт отдельный граф. second имеет площадь 10, first — 12. Каждый demo задаёт оба размера перед первым finish, поэтому повторный запуск также возвращает 22.

## 2. Python

```python
from copy import copy

class Rectangle:
    def __init__(self):
        self.width = 0
        self.height = 0

    def area(self):
        return self.width * self.height

class Builder:
    def __init__(self):
        self.product = Rectangle()

    def set_width(self, value):
        self.product.width = value

    def set_height(self, value):
        self.product.height = value

    def finish(self):
        return copy(self.product)

def demo():
    builder = Builder()
    builder.set_width(3)
    builder.set_height(4)
    first = builder.finish()
    builder.set_width(5)
    builder.set_height(2)
    second = builder.finish()
    return first.area() + second.area()
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 3. Java

```java
class Example {
    static class Rectangle {
        int width, height;

        int area() {
            return width * height;
        }
    }

    static class Builder {
        Rectangle product = new Rectangle();

        void setWidth(int value) {
            product.width = value;
        }

        void setHeight(int value) {
            product.height = value;
        }

        Rectangle finish() {
            Rectangle result = new Rectangle();
            result.width = product.width;
            result.height = product.height;
            return result;
        }
    }

    public static int demo() {
        Builder builder = new Builder();
        builder.setWidth(3);
        builder.setHeight(4);
        Rectangle first = builder.finish();
        builder.setWidth(5);
        builder.setHeight(2);
        Rectangle second = builder.finish();
        return first.area() + second.area();
    }
}
```

Внешний вызов: `Example.demo()`. Он не входит в подсчёт.

## 4. C++

```cpp
struct Rectangle {
    int width = 0, height = 0;

    int area() const {
        return width * height;
    }
};

struct Builder {
    Rectangle product;

    void set_width(int value) {
        product.width = value;
    }

    void set_height(int value) {
        product.height = value;
    }

    Rectangle finish() const {
        return product;
    }
};

int demo() {
    Builder builder;
    builder.set_width(3);
    builder.set_height(4);
    auto first = builder.finish();
    builder.set_width(5);
    builder.set_height(2);
    auto second = builder.finish();
    return first.area() + second.area();
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 5. C#

```csharp
static class Example {
    sealed class Rectangle {
        public int Width, Height;

        public int Area() {
            return Width * Height;
        }

        public Rectangle Copy() {
            return (Rectangle)MemberwiseClone();
        }
    }

    sealed class Builder {
        readonly Rectangle product = new Rectangle();

        public void SetWidth(int value) {
            product.Width = value;
        }

        public void SetHeight(int value) {
            product.Height = value;
        }

        public Rectangle Finish() {
            return product.Copy();
        }
    }

    public static int Demo() {
        var builder = new Builder();
        builder.SetWidth(3);
        builder.SetHeight(4);
        var first = builder.Finish();
        builder.SetWidth(5);
        builder.SetHeight(2);
        var second = builder.Finish();
        return first.Area() + second.Area();
    }
}
```

Внешний вызов: `Example.Demo()`. Он не входит в подсчёт.

## 6. TypeScript

```typescript
class Rectangle {
    width = 0;
    height = 0;

    area(): number {
        return this.width * this.height;
    }
}

class Builder {
    product = new Rectangle();

    setWidth(value: number): void {
        this.product.width = value;
    }

    setHeight(value: number): void {
        this.product.height = value;
    }

    finish(): Rectangle {
        return Object.assign(new Rectangle(), this.product);
    }
}

function demo(): number {
    const builder = new Builder();
    builder.setWidth(3);
    builder.setHeight(4);
    const first = builder.finish();
    builder.setWidth(5);
    builder.setHeight(2);
    const second = builder.finish();
    return first.area() + second.area();
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 7. Go

```go
package main

type Rectangle struct {
    width, height int
}

func (rectangle Rectangle) area() int {
    return rectangle.width * rectangle.height
}

type Builder struct {
    product Rectangle
}

func (builder *Builder) setWidth(value int) {
    builder.product.width = value
}

func (builder *Builder) setHeight(value int) {
    builder.product.height = value
}

func (builder Builder) finish() Rectangle {
    return builder.product
}

func demo() int {
    builder := Builder{}
    builder.setWidth(3)
    builder.setHeight(4)
    first := builder.finish()
    builder.setWidth(5)
    builder.setHeight(2)
    second := builder.finish()
    return first.area() + second.area()
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 8. Rust

```rust
#[derive(Clone, Default)]
struct Rectangle {
    width: i32,
    height: i32,
}

impl Rectangle {
    fn area(&self) -> i32 {
        self.width * self.height
    }
}

#[derive(Default)]
struct Builder {
    product: Rectangle,
}

impl Builder {
    fn set_width(&mut self, value: i32) {
        self.product.width = value;
    }

    fn set_height(&mut self, value: i32) {
        self.product.height = value;
    }

    fn finish(&self) -> Rectangle {
        self.product.clone()
    }
}

pub fn demo() -> i32 {
    let mut builder = Builder::default();
    builder.set_width(3);
    builder.set_height(4);
    let first = builder.finish();
    builder.set_width(5);
    builder.set_height(2);
    let second = builder.finish();
    first.area() + second.area()
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## Проверка

В этой редакции проверены согласованность LMX-листинга с документами `docs`, явная группировка результатов копирования/композиции там, где нужен один объект, и ссылки на правила языка. Ожидаемый результат LMX следует из показанного сценария; запуск ядра не проводился.

Листинги Python, Java, C++, C#, TypeScript, Go и Rust сохранены из исходного сравнения. Сообщения исходной редакции об их выполнении относятся к той проверке; это обновление документации не выдаёт их за новый запуск. Подсчёт размеров выполняется заново по листингам текущего файла.

## Источники

Сетевые образцы использованы для проверки ролей шаблона. Показанные программы — самостоятельные адаптации общего сценария, а не подсчёт длины исходников этих страниц.

- [Refactoring.Guru — Builder](https://refactoring.guru/design-patterns/builder)
- [Refactoring.Guru — Builder in Python](https://refactoring.guru/design-patterns/builder/python/example)


[S]: ../LMX_semantics.en.md#merge-two-forms
