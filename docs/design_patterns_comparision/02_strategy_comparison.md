# 02. Strategy: сравнение исходников LMX и семи других языков

20 ноября 2026 года · Один сценарий, восемь реализаций

## Задача и границы примера

Один обработчик применяет выбранную операцию к 5. В первом вызове операция удваивает, затем ссылка переключается на утроение; сумма двух результатов равна 25.

**Ожидаемый результат демонстрации: `25`.**

Сохранены два именованных алгоритма, общий обработчик и изменяемая ссылка на стратегию. Функциональные значения заменяют отдельную иерархию Strategy-классов. Дефолтная операция twice сохранена; языки без параметров по умолчанию выражают её перегрузкой или отсутствующим значением.

LMX взят без изменений из [согласованной русской подборки примеров](https://chatgpt.com/library?file_id=libfile_fde3_f-e112f68f2f20819185805436a1f1f225_bbe92b09b62881918d17958175103ded&account_id=personal). Для остальных языков найдены сетевые образцы по названию шаблона; на их основе написаны сопоставимые реализации именно этого сценария. Это оригинальная адаптация, а не дословная копия кода сайта и не измерение длины его полного учебного листинга. Источники приведены в конце.

## Как считались символы

Главная величина — **число непробельных символов** в показанном блоке исходника: все символы, для которых Python `str.isspace()` возвращает false. Пробелы, табуляции и переводы строк не учитываются. Это счётчик, а не преобразование кода в исполняемый минифицированный вариант; пробельные символы внутри строк также не считаются.

Дополнительно показаны полный размер в символах Unicode и число физических строк. Для полного размера используется LF, без начальных и конечных пустых строк и с одним LF в конце. Здесь все исходники ASCII, поэтому при UTF-8 число байтов совпадает с полным числом символов.

Считаются объявления, импорты, обязательные классы-оболочки или `package`, вспомогательные функции и весь демонстрационный сценарий внутри `demo` / `Demo` / LMX `run`. Внешний запуск, `main`, печать результата, тестовый harness, Markdown и пояснения не входят. Реализация стандартной библиотеки и runtime не входит ни для одного языка. В измеряемом коде нет комментариев.

Обычные функции, замыкания и стандартные типы callable разрешены. Python приведён без необязательных аннотаций типов; это не равенство статических гарантий с LMX или другими типизированными вариантами. Имена и учебная разбивка не нормализованы: числа описывают эти конкретные листинги, а не минимально возможную длину программы на языке.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 458 | 637 | 28 | 1.00× |
| Python | 217 | 292 | 18 | 0.47× |
| Java | 445 | 634 | 27 | 0.97× |
| C++ | 321 | 418 | 23 | 0.70× |
| C# | 377 | 569 | 27 | 0.82× |
| TypeScript | 364 | 466 | 21 | 0.79× |
| Go | 332 | 455 | 26 | 0.72× |
| Rust | 322 | 423 | 21 | 0.70× |

Отношение больше 1 означает, что этот листинг длиннее показанного LMX по непробельным символам.

## 1. LMX

```lmx
fn: Transform (int: x; return: int)

Algorithms:
    int: value
    return: int
    twice:
        return: value * 2
    thrice:
        return: value * 3
end: Algorithms

Processor:
    @: operation Transform Algorithms\twice
    int: input
    return: int
    apply:
        return: operation(x := input)
end: Processor

StrategyDemo:
    return: int
    run:
        @: selected Transform Algorithms\twice
        int: first Processor\apply(operation := selected; input := 5)
        selected := Algorithms\thrice
        int: second Processor\apply(operation := selected; input := 5)
        return: first + second
end: StrategyDemo
```

Вызов из исполняемого контекста: `StrategyDemo\run()`. Сам этот внешний вызов не входит в подсчёт.

Считаются последние согласованные правила `fn`, структурных требований, связывания и `import` из исходной подборки.

## 2. Python

```python
def twice(value):
    return value * 2


def thrice(value):
    return value * 3


def apply(input, operation=twice):
    return operation(input)


def demo():
    selected = twice
    first = apply(5, selected)
    selected = thrice
    second = apply(5, selected)
    return first + second
```

Внешний вызов: `demo()`.

Обычные функции являются стратегиями; operation=twice сохраняет дефолт исходного обработчика. Типы проверяются при исполнении, отдельного аналога статического fn-контракта в этом фрагменте нет.

## 3. Java

```java
import java.util.function.IntUnaryOperator;

class Example {
    static int twice(int value) {
        return value * 2;
    }

    static int thrice(int value) {
        return value * 3;
    }

    static int apply(int input, IntUnaryOperator operation) {
        return operation.applyAsInt(input);
    }

    static int apply(int input) {
        return apply(input, Example::twice);
    }

    public static int demo() {
        IntUnaryOperator selected = Example::twice;
        int first = apply(5, selected);
        selected = Example::thrice;
        int second = apply(5, selected);
        return first + second;
    }
}
```

Внешний вызов: `Example.demo()`.

Стандартный IntUnaryOperator задаёт тип int → int. Перегрузка apply(input) сохраняет вызов с дефолтной стратегией, поскольку у Java нет параметров по умолчанию.

## 4. C++

```cpp
#include <functional>

using Transform = std::function<int(int)>;

int twice(int value) {
    return value * 2;
}

int thrice(int value) {
    return value * 3;
}

int apply(int input, Transform operation = twice) {
    return operation(input);
}

int demo() {
    Transform selected = twice;
    int first = apply(5, selected);
    selected = thrice;
    int second = apply(5, selected);
    return first + second;
}
```

Внешний вызов: `demo()`.

std::function хранит заменяемое вызываемое значение, включая функции и замыкания. Сигнатура и дефолт выражаются непосредственно средствами C++.

## 5. C#

```csharp
using System;

static class Example {
    static int Twice(int value) {
        return value * 2;
    }

    static int Thrice(int value) {
        return value * 3;
    }

    static int Apply(int input, Func<int, int> operation) {
        return operation(input);
    }

    static int Apply(int input) {
        return Apply(input, Twice);
    }

    public static int Demo() {
        Func<int, int> selected = Twice;
        int first = Apply(5, selected);
        selected = Thrice;
        int second = Apply(5, selected);
        return first + second;
    }
}
```

Внешний вызов: `Example.Demo()`.

Делегат Func<int,int> выражает контракт. Отдельная перегрузка сохраняет дефолтную стратегию, не добавляя null как допустимую явно переданную операцию.

## 6. TypeScript

```typescript
type Transform = (x: number) => number;

function twice(value: number): number {
    return value * 2;
}

function thrice(value: number): number {
    return value * 3;
}

function apply(input: number, operation: Transform = twice): number {
    return operation(input);
}

function demo(): number {
    let selected: Transform = twice;
    const first = apply(5, selected);
    selected = thrice;
    const second = apply(5, selected);
    return first + second;
}
```

Внешний вызов: `demo()`.

Функциональный тип проверяет форму вызова; значение по умолчанию сохраняется. Имена аргументов типа не предоставляют именованные actuals при вызове, в отличие от согласованного правила LMX.

## 7. Go

```go
package main

type Transform func(int) int

func twice(value int) int {
    return value * 2
}

func thrice(value int) int {
    return value * 3
}

func apply(input int, operation Transform) int {
    if operation == nil {
        operation = twice
    }
    return operation(input)
}

func demo() int {
    var selected Transform = twice
    first := apply(5, selected)
    selected = thrice
    second := apply(5, selected)
    return first + second
}
```

Внешний вызов: `demo()`.

Именованный функциональный тип представляет контракт. У Go нет необязательных аргументов, поэтому nil в позиции operation означает выбор дефолта; это отличающееся соглашение вызова.

## 8. Rust

```rust
type Transform = fn(i32) -> i32;

fn twice(value: i32) -> i32 {
    value * 2
}

fn thrice(value: i32) -> i32 {
    value * 3
}

fn apply(input: i32, operation: Option<Transform>) -> i32 {
    operation.unwrap_or(twice)(input)
}

pub fn demo() -> i32 {
    let mut selected: Transform = twice;
    let first = apply(5, Some(selected));
    selected = thrice;
    let second = apply(5, Some(selected));
    first + second
}
```

Внешний вызов: `demo()`.

Для двух функций без захваченного окружения достаточно fn-указателя. None выбирает дефолт, Some передаёт выбранную стратегию; для захватывающих замыканий потребовался бы Fn/FnMut-контракт.

## Проверка и воспроизводимость

Python, Java, C++ и TypeScript исполнены: два последовательных вызова входа дали `25` и `25`. Java проверена OpenJDK 21; C++ — g++ в режиме C++17; TypeScript — Node.js 24 с удалением типов перед исполнением. Для TypeScript это проверка выполнения, а не отдельный прогон `tsc --strict`. C#, Go и Rust прошли статическое ревью; их компиляторы в среде отсутствуют. LMX проверен по документам, без запуска ядра.

Смысловые свойства, сохранённые в демонстрации (кроме запуска входа, проверены чтением кода):

- Первый результат = 10, второй = 15, demo = 25
- Обработчик не меняется при замене selected
- Вызов без выбранной стратегии (либо с nil/None по соглашению языка) использует twice

Подсчёт воспроизводится непосредственно по восьми блокам исходников выше: `sum(not ch.isspace() for ch in code)` для основной колонки и `len(code)` для полной. Перед подсчётом применяется описанная нормализация перевода строк.

## Найденные сетевые образцы

1. [Refactoring.Guru — Strategy in Python: Conceptual Example](https://refactoring.guru/design-patterns/strategy/python/example). Исходный образец показывает замену алгоритма в контексте. Для общего сценария две сортировки заменены удвоением и утроением; вместо отдельного класса для каждой стратегии использованы функциональные значения.

Из сетевых материалов взяты ориентиры по ролям участников и взаимодействию. Имена, арифметика, объём поведения и код адаптированы к общему LMX-сценарию. Сравнение не переносит в маленький пример дополнительные функции исходного учебного проекта.
