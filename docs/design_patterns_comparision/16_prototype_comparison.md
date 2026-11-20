# 16. Prototype: LMX и семь других языков

20 ноября 2026 года. Продолжение серии: шаблоны 10–18.

## Задача

Создать Point(3,4), изменить original.x на 7, затем скопировать именно этот живой экземпляр. Изменить только replica.y на 9 и сложить результаты score = 10×x + y: 74 + 79 = 153.

**Внешний вызов LMX:** `Point\demo()`. **Ожидаемый результат: 153.**

Клонируется один конкретный тип с двумя скалярными полями. Пример не сравнивает глубокое копирование вложенных изменяемых объектов, внешних ресурсов или произвольной иерархии подтипов. merge имеет более общий графовый контракт; здесь проверяется лишь общий для всех программ сценарий.

## Архитектура LMX

LMX использует обычный merge(original) вместо отдельного интерфейса clone: графовое копирование уже является общей операцией языка. В Python эту роль выполняет copy(original), в C++ и Go — копирование значения, в остальных примерах — соответствующая операция копирования объекта. replica создаётся после настройки original, а не заново из исходных значений Point.

Применены согласованные правила: DATA метода — его фактический parent; обычные ссылки на методы не требуют отдельного `fn`; объявленные входы без initializer допускают autofill, свободные имена — связь с местом непосредственного caller. `node\` выбирает лексическую связь. Пустая строка завершает корневой блок. [Связывание][B] · [Импорт][D] · [Границы блоков][E]

## Подсчёт исходников

Главная метрика — **непробельные символы**: `sum(not ch.isspace() for ch in code)`. Дополнительно показаны полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF в конце.

В подсчёт входят весь показанный исходник, импорты, необходимые языковые оболочки и `demo`. Внешний запуск, `main`, печать результата, тестовая обвязка и реализация стандартной библиотеки/runtime не включены. Имена не нормализованы. Python записан без необязательных аннотаций типов. Сравниваются конкретные реализации одной задачи; это не оценка быстродействия или одинаковых статических гарантий.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 162 | 263 | 12 | 1.00× |
| Python | 209 | 304 | 16 | 1.29× |
| Java | 280 | 507 | 24 | 1.73× |
| C++ | 165 | 249 | 15 | 1.02× |
| C# | 273 | 457 | 21 | 1.69× |
| TypeScript | 219 | 311 | 16 | 1.35× |
| Go | 199 | 275 | 17 | 1.23× |
| Rust | 225 | 327 | 19 | 1.39× |

Общая таблица серии доступна в [Excel](LMX_Comparison_10-18.xlsx) и [PDF](LMX_Comparison_10-18.pdf).

## 1. LMX

```lmx
Point:
    int: x 3
    int: y 4
    return: int
    score:
        return: x * 10 + y
    demo:
        @: original merge(Point)
        original\x := 7
        @: replica merge(original)
        replica\y := 9
        return: original\score() + replica\score()
```

Внешний вызов: `Point\demo()`. Он не входит в подсчёт.

original остаётся (7,4), replica становится (7,9). Оба объекта сохраняют score, который читает DATA своего конкретного экземпляра. Изменение y в копии не меняет y исходного объекта; последующее изменение original.x также не меняет replica.x.

## 2. Python

```python
from copy import copy

class Point:
    def __init__(self):
        self.x = 3
        self.y = 4

    def score(self):
        return self.x * 10 + self.y

def demo():
    original = Point()
    original.x = 7
    replica = copy(original)
    replica.y = 9
    return original.score() + replica.score()
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 3. Java

```java
class Example {
    static class Point {
        int x = 3, y = 4;

        int score() {
            return x * 10 + y;
        }

        Point copy() {
            Point result = new Point();
            result.x = x;
            result.y = y;
            return result;
        }
    }

    public static int demo() {
        Point original = new Point();
        original.x = 7;
        Point replica = original.copy();
        replica.y = 9;
        return original.score() + replica.score();
    }
}
```

Внешний вызов: `Example.demo()`. Он не входит в подсчёт.

## 4. C++

```cpp
struct Point {
    int x = 3, y = 4;

    int score() const {
        return x * 10 + y;
    }
};

int demo() {
    Point original;
    original.x = 7;
    auto replica = original;
    replica.y = 9;
    return original.score() + replica.score();
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 5. C#

```csharp
static class Example {
    sealed class Point {
        public int X = 3, Y = 4;

        public int Score() {
            return X * 10 + Y;
        }

        public Point Copy() {
            return (Point)MemberwiseClone();
        }
    }

    public static int Demo() {
        var original = new Point();
        original.X = 7;
        var replica = original.Copy();
        replica.Y = 9;
        return original.Score() + replica.Score();
    }
}
```

Внешний вызов: `Example.Demo()`. Он не входит в подсчёт.

## 6. TypeScript

```typescript
class Point {
    x = 3;
    y = 4;

    score(): number {
        return this.x * 10 + this.y;
    }
}

function demo(): number {
    const original = new Point();
    original.x = 7;
    const replica = Object.assign(new Point(), original);
    replica.y = 9;
    return original.score() + replica.score();
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 7. Go

```go
package main

type Point struct {
    x, y int
}

func (point Point) score() int {
    return point.x * 10 + point.y
}

func demo() int {
    original := Point{3, 4}
    original.x = 7
    replica := original
    replica.y = 9
    return original.score() + replica.score()
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 8. Rust

```rust
#[derive(Clone)]
struct Point {
    x: i32,
    y: i32,
}

impl Point {
    fn score(&self) -> i32 {
        self.x * 10 + self.y
    }
}

pub fn demo() -> i32 {
    let mut original = Point { x: 3, y: 4 };
    original.x = 7;
    let mut replica = original.clone();
    replica.y = 9;
    original.score() + replica.score()
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## Проверка

Python, Java и C++17 исполнены с ожидаемыми результатами. TypeScript исполнен в Node с удалением аннотаций типов; отдельная статическая проверка TypeScript не выполнялась. Проверены копирование настроенного экземпляра и независимость последующих изменений обоих объектов. C#, Go и Rust проверены статически; их компиляторы в этой среде недоступны.

Метрики пересчитаны из восьми листингов этого файла. Ожидаемый результат LMX проверен по правилам языка; исполнение на ядре LMX не проводилось.

## Источники

Сетевые образцы использованы для проверки ролей шаблона. Показанные программы — самостоятельные адаптации общего сценария, а не подсчёт длины исходников этих страниц.

- [Refactoring.Guru — Prototype](https://refactoring.guru/design-patterns/prototype)
- [Refactoring.Guru — Prototype in Python](https://refactoring.guru/design-patterns/prototype/python/example)

[B]: https://chatgpt.com/library?file_id=libfile_fde3_f-a38201c30fb88191b7207c0e48955c30_bbe92b09b62881918d17958175103ded&account_id=personal
[D]: https://chatgpt.com/library?file_id=libfile_fde3_f-02443abbc4508191b7c8fd7894e3ac24_bbe92b09b62881918d17958175103ded&account_id=personal
[E]: https://chatgpt.com/library?file_id=libfile_fde3_f-9d15a59bc5d881918724924fcef45b04_bbe92b09b62881918d17958175103ded&account_id=personal
