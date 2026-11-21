# 12. Composite: LMX и семь других языков

20 ноября 2026 года. Продолжение серии: шаблоны 10–18.

## Задача

Лист возвращает собственное значение, Pair складывает total левого и правого ребёнка. Каждый ребёнок может быть другим Pair, поэтому глубина дерева не зашита в алгоритм. В demo построено дерево 2 + (3 + 5), результат 10.

**Внешний вызов LMX:** `Pair\demo()`. **Ожидаемый результат: 10.**

Конечное ациклическое бинарное дерево: каждый внутренний узел содержит ровно двух детей, глубина произвольна. LMX merge копирует используемый граф и перенаправляет ссылки; это не разделяемые изменяемые a/b/c. Другие версии используют ссылки или заимствования. Сравнивается построение и чтение без последующих изменений листьев; стоимость копирования и семантика редактирования дерева не приравниваются.

## Архитектура LMX

Структуры Leaf и Pair повторяют две роли Python-прототипа. Pair не распознаёт конкретный вид ребёнка: вызывает одно и то же total. merge создаёт экземпляры из моделей и заполняет left/right совпадающими полями. Контейнер переменной длины и length не требуются бинарному дереву.

Применены согласованные правила: DATA метода — его фактический parent; обычные ссылки на методы не требуют отдельного `fn`; объявленные входы без initializer допускают autofill, свободные имена — связь с местом непосредственного caller. `node\` выбирает лексическую связь. Пустая строка завершает корневой блок. [Связывание][B] · [Импорт][D] · [Границы блоков][E]

## Подсчёт исходников

Главная метрика — **непробельные символы**: `sum(not ch.isspace() for ch in code)`. Дополнительно показаны полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF в конце.

В подсчёт входят весь показанный исходник, импорты, необходимые языковые оболочки и `demo`. Внешний запуск, `main`, печать результата, тестовая обвязка и реализация стандартной библиотеки/runtime не включены. Имена не нормализованы. Python записан без необязательных аннотаций типов. Сравниваются конкретные реализации одной задачи; это не оценка быстродействия или одинаковых статических гарантий.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 291 | 447 | 19 | 1.00× |
| Python | 295 | 430 | 22 | 1.01× |
| Java | 480 | 756 | 33 | 1.65× |
| C++ | 453 | 592 | 24 | 1.56× |
| C# | 469 | 746 | 33 | 1.61× |
| TypeScript | 499 | 673 | 32 | 1.71× |
| Go | 312 | 426 | 28 | 1.07× |
| Rust | 379 | 530 | 29 | 1.30× |

Общая таблица серии доступна в [Excel](LMX_Comparison_10-18.xlsx) и [PDF](LMX_Comparison_10-18.pdf).

## 1. LMX

```lmx
Leaf:
    int: value
    return: int
    total:
        return: value

Pair:
    @: left
    @: right
    return: int
    total:
        return: left\total() + right\total()
    demo:
        @: a merge(Leaf; (int: value 2))
        @: b merge(Leaf; (int: value 3))
        @: c merge(Leaf; (int: value 5))
        @: inner merge(Pair; (@: left b; @: right c))
        @: tree merge(Pair; (@: left a; @: right inner))
        return: tree\total()
```

Внешний вызов: `Pair\demo()`. Он не входит в подсчёт.

Создаются листья a=2, b=3, c=5; inner объединяет b и c, а tree — a и inner. inner\total() возвращает 8, затем tree\total() — 10. Точно такая же операция действует при дальнейшей вложенности Pair.

## 2. Python

```python
class Leaf:
    def __init__(self, value):
        self.value = value

    def total(self):
        return self.value

class Pair:
    def __init__(self, left, right):
        self.left = left
        self.right = right

    def total(self):
        return self.left.total() + self.right.total()

def demo():
    a = Leaf(2)
    b = Leaf(3)
    c = Leaf(5)
    inner = Pair(b, c)
    tree = Pair(a, inner)
    return tree.total()
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 3. Java

```java
class Example {
    interface Component {
        int total();
    }

    static class Leaf implements Component {
        final int value;

        Leaf(int value) { this.value = value; }

        public int total() { return value; }
    }

    static class Pair implements Component {
        final Component left, right;

        Pair(Component left, Component right) {
            this.left = left;
            this.right = right;
        }

        public int total() { return left.total() + right.total(); }
    }

    public static int demo() {
        Leaf a = new Leaf(2);
        Leaf b = new Leaf(3);
        Leaf c = new Leaf(5);
        Pair inner = new Pair(b, c);
        Pair tree = new Pair(a, inner);
        return tree.total();
    }
}
```

Внешний вызов: `Example.demo()`. Он не входит в подсчёт.

## 4. C++

```cpp
struct Component {
    virtual int total() const = 0;
    virtual ~Component() = default;
};

struct Leaf : Component {
    int value;
    explicit Leaf(int value) : value(value) {}
    int total() const override { return value; }
};

struct Pair : Component {
    const Component& left;
    const Component& right;
    Pair(const Component& left, const Component& right) : left(left), right(right) {}
    int total() const override { return left.total() + right.total(); }
};

int demo() {
    Leaf a(2), b(3), c(5);
    Pair inner(b, c);
    Pair tree(a, inner);
    return tree.total();
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 5. C#

```csharp
static class Example {
    interface Component {
        int Total();
    }

    class Leaf : Component {
        readonly int value;

        public Leaf(int value) { this.value = value; }

        public int Total() { return value; }
    }

    class Pair : Component {
        readonly Component left, right;

        public Pair(Component left, Component right) {
            this.left = left;
            this.right = right;
        }

        public int Total() { return left.Total() + right.Total(); }
    }

    public static int Demo() {
        var a = new Leaf(2);
        var b = new Leaf(3);
        var c = new Leaf(5);
        var inner = new Pair(b, c);
        var tree = new Pair(a, inner);
        return tree.Total();
    }
}
```

Внешний вызов: `Example.Demo()`. Он не входит в подсчёт.

## 6. TypeScript

```typescript
interface Component {
    total(): number;
}

class Leaf implements Component {
    value: number;

    constructor(value: number) { this.value = value; }

    total(): number { return this.value; }
}

class Pair implements Component {
    left: Component;
    right: Component;

    constructor(left: Component, right: Component) {
        this.left = left;
        this.right = right;
    }

    total(): number { return this.left.total() + this.right.total(); }
}

function demo(): number {
    const a = new Leaf(2);
    const b = new Leaf(3);
    const c = new Leaf(5);
    const inner = new Pair(b, c);
    const tree = new Pair(a, inner);
    return tree.total();
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 7. Go

```go
package main

type Component interface {
    total() int
}

type Leaf struct {
    value int
}

func (leaf Leaf) total() int { return leaf.value }

type Pair struct {
    left, right Component
}

func (pair Pair) total() int {
    return pair.left.total() + pair.right.total()
}

func demo() int {
    a := Leaf{2}
    b := Leaf{3}
    c := Leaf{5}
    inner := Pair{b, c}
    tree := Pair{a, inner}
    return tree.total()
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 8. Rust

```rust
trait Component {
    fn total(&self) -> i32;
}

struct Leaf(i32);

impl Component for Leaf {
    fn total(&self) -> i32 { self.0 }
}

struct Pair<'a> {
    left: &'a dyn Component,
    right: &'a dyn Component,
}

impl Component for Pair<'_> {
    fn total(&self) -> i32 {
        self.left.total() + self.right.total()
    }
}

pub fn demo() -> i32 {
    let a = Leaf(2);
    let b = Leaf(3);
    let c = Leaf(5);
    let inner = Pair { left: &b, right: &c };
    let tree = Pair { left: &a, right: &inner };
    tree.total()
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## Проверка

Python, Java и C++17 исполнены с ожидаемыми результатами. TypeScript исполнен в Node с удалением аннотаций типов; отдельная статическая проверка TypeScript не выполнялась. Проверены листья, составные пары и более глубокая вложенность бинарного дерева. C#, Go и Rust проверены статически; их компиляторы в этой среде недоступны.

Метрики пересчитаны из восьми листингов этого файла. Ожидаемый результат LMX проверен по правилам языка; исполнение на ядре LMX не проводилось.

## Источники

Сетевые образцы использованы для проверки ролей шаблона. Показанные программы — самостоятельные адаптации общего сценария, а не подсчёт длины исходников этих страниц.

- [Refactoring.Guru — Composite in Python, conceptual example](https://refactoring.guru/design-patterns/composite/python/example)

[B]: https://chatgpt.com/library?file_id=libfile_fde3_f-a38201c30fb88191b7207c0e48955c30_bbe92b09b62881918d17958175103ded&account_id=personal
[D]: https://chatgpt.com/library?file_id=libfile_fde3_f-02443abbc4508191b7c8fd7894e3ac24_bbe92b09b62881918d17958175103ded&account_id=personal
[E]: https://chatgpt.com/library?file_id=libfile_fde3_f-9d15a59bc5d881918724924fcef45b04_bbe92b09b62881918d17958175103ded&account_id=personal
