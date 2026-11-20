# 08. Template Method: сравнение исходников LMX и семи других языков

20 ноября 2026 года · Один сценарий, восемь реализаций

## Задача и границы примера

Один алгоритм сначала вызывает prepare, затем finish. При входе 4 prepare увеличивает значение на 1; finish сначала удваивает, затем заменяется возведением в квадрат. Сумма двух результатов — 10 + 25 = 35.

**Ожидаемый результат демонстрации: `35`.**

Сохраняется скелет алгоритма и заменяемые шаги из LMX-примера. Это функциональный вариант этой роли; буквальная GoF-структура с базовым классом и переопределением методов не воспроизводится ни в LMX, ни принудительно в остальных языках. Скрытые зависимости LMX в аналогах передаются явно.

LMX взят без изменений из [согласованной русской подборки примеров](https://chatgpt.com/library?file_id=libfile_fde3_f-e112f68f2f20819185805436a1f1f225_bbe92b09b62881918d17958175103ded&account_id=personal). Для остальных языков найдены сетевые образцы по названию шаблона; на их основе написаны сопоставимые реализации именно этого сценария. Это оригинальная адаптация, а не дословная копия кода сайта и не измерение длины его полного учебного листинга. Источники приведены в конце.

## Как считались символы

Главная величина — **число непробельных символов** в показанном блоке исходника: все символы, для которых Python `str.isspace()` возвращает false. Пробелы, табуляции и переводы строк не учитываются. Это счётчик, а не преобразование кода в исполняемый минифицированный вариант; пробельные символы внутри строк также не считаются.

Дополнительно показаны полный размер в символах Unicode и число физических строк. Для полного размера используется LF, без начальных и конечных пустых строк и с одним LF в конце. Здесь все исходники ASCII, поэтому при UTF-8 число байтов совпадает с полным числом символов.

Считаются объявления, импорты, обязательные классы-оболочки или `package`, вспомогательные функции и весь демонстрационный сценарий внутри `demo` / `Demo` / LMX `run`. Внешний запуск, `main`, печать результата, тестовый harness, Markdown и пояснения не входят. Реализация стандартной библиотеки и runtime не входит ни для одного языка. В измеряемом коде нет комментариев.

Обычные функции, замыкания и стандартные типы callable разрешены. Python приведён без необязательных аннотаций типов; это не равенство статических гарантий с LMX или другими типизированными вариантами. Имена и учебная разбивка не нормализованы: числа описывают эти конкретные листинги, а не минимально возможную длину программы на языке.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 442 | 649 | 31 | 1.00× |
| Python | 318 | 418 | 20 | 0.72× |
| Java | 560 | 802 | 30 | 1.27× |
| C++ | 393 | 520 | 27 | 0.89× |
| C# | 475 | 722 | 30 | 1.07× |
| TypeScript | 497 | 633 | 27 | 1.12× |
| Go | 411 | 540 | 29 | 0.93× |
| Rust | 398 | 535 | 27 | 0.90× |

Отношение больше 1 означает, что этот листинг длиннее показанного LMX по непробельным символам.

## 1. LMX

```lmx
fn: StepSignature (int: x; return: int)

Steps:
    int: value
    return: int
    increment:
        return: value + 1
    twice:
        return: value * 2
    square:
        return: value * value
end: Steps

Pipeline:
    int: input
    return: int
    run:
        int: intermediate prepare(x := input)
        return: finish(x := intermediate)
end: Pipeline

Demo:
    return: int
    run:
        @: prepare StepSignature Steps\increment
        @: finish StepSignature Steps\twice
        int: first Pipeline\run(input := 4)
        finish := Steps\square
        int: second Pipeline\run(input := 4)
        return: first + second
end: Demo
```

Вызов из исполняемого контекста: `Demo\run()`. Сам этот внешний вызов не входит в подсчёт.

Считаются последние согласованные правила `fn`, структурных требований, связывания и `import` из исходной подборки.

## 2. Python

```python
def increment(value):
    return value + 1

def twice(value):
    return value * 2

def square(value):
    return value * value

def pipeline(input, prepare, finish):
    intermediate = prepare(input)
    return finish(intermediate)

def demo():
    prepare = increment
    finish = twice
    first = pipeline(4, prepare, finish)
    finish = square
    second = pipeline(4, prepare, finish)
    return first + second
```

Внешний вызов: `demo()`.

Обычные функции реализуют шаги, а pipeline фиксирует их порядок. Входы prepare и finish явные; pipeline не ищет переменные в вызывающем.

## 3. Java

```java
import java.util.function.IntUnaryOperator;

class Example {
    static int increment(int value) {
        return value + 1;
    }

    static int twice(int value) {
        return value * 2;
    }

    static int square(int value) {
        return value * value;
    }

    static int pipeline(int input, IntUnaryOperator prepare,
                        IntUnaryOperator finish) {
        int intermediate = prepare.applyAsInt(input);
        return finish.applyAsInt(intermediate);
    }

    public static int demo() {
        IntUnaryOperator prepare = Example::increment;
        IntUnaryOperator finish = Example::twice;
        int first = pipeline(4, prepare, finish);
        finish = Example::square;
        int second = pipeline(4, prepare, finish);
        return first + second;
    }
}
```

Внешний вызов: `Example.demo()`.

Стандартный IntUnaryOperator позволяет обойтись без отдельного класса для каждого арифметического шага.

## 4. C++

```cpp
int increment(int value) {
    return value + 1;
}

int twice(int value) {
    return value * 2;
}

int square(int value) {
    return value * value;
}

using Step = int (*)(int);

int pipeline(int input, Step prepare, Step finish) {
    int intermediate = prepare(input);
    return finish(intermediate);
}

int demo() {
    Step prepare = increment;
    Step finish = twice;
    int first = pipeline(4, prepare, finish);
    finish = square;
    int second = pipeline(4, prepare, finish);
    return first + second;
}
```

Внешний вызов: `demo()`.

Шаги не захватывают состояние, поэтому здесь достаточно типизированных указателей на функции.

## 5. C#

```csharp
using System;

static class Example {
    static int Increment(int value) {
        return value + 1;
    }

    static int Twice(int value) {
        return value * 2;
    }

    static int Square(int value) {
        return value * value;
    }

    static int Pipeline(int input, Func<int, int> prepare,
                        Func<int, int> finish) {
        int intermediate = prepare(input);
        return finish(intermediate);
    }

    public static int Demo() {
        Func<int, int> prepare = Increment;
        Func<int, int> finish = Twice;
        int first = Pipeline(4, prepare, finish);
        finish = Square;
        int second = Pipeline(4, prepare, finish);
        return first + second;
    }
}
```

Внешний вызов: `Example.Demo()`.

Func<int, int> задаёт тип шага. В остальном это та же явная передача двух операций.

## 6. TypeScript

```typescript
function increment(value: number): number {
    return value + 1;
}

function twice(value: number): number {
    return value * 2;
}

function square(value: number): number {
    return value * value;
}

type Step = (value: number) => number;

function pipeline(input: number, prepare: Step, finish: Step): number {
    const intermediate = prepare(input);
    return finish(intermediate);
}

function demo(): number {
    const prepare: Step = increment;
    let finish: Step = twice;
    const first = pipeline(4, prepare, finish);
    finish = square;
    const second = pipeline(4, prepare, finish);
    return first + second;
}
```

Внешний вызов: `demo()`.

Step — структурный функциональный тип. Числа в этом сценарии малы и целые; это не обещание равенства всех числовых моделей языков.

## 7. Go

```go
package main

func increment(value int) int {
    return value + 1
}

func twice(value int) int {
    return value * 2
}

func square(value int) int {
    return value * value
}

type Step func(int) int

func pipeline(input int, prepare Step, finish Step) int {
    intermediate := prepare(input)
    return finish(intermediate)
}

func demo() int {
    prepare := Step(increment)
    finish := Step(twice)
    first := pipeline(4, prepare, finish)
    finish = square
    second := pipeline(4, prepare, finish)
    return first + second
}
```

Внешний вызов: `demo()`.

Тип функции Step играет роль контракта. Порядок двух вызовов задан одной функцией pipeline.

## 8. Rust

```rust
fn increment(value: i32) -> i32 {
    value + 1
}

fn twice(value: i32) -> i32 {
    value * 2
}

fn square(value: i32) -> i32 {
    value * value
}

type Step = fn(i32) -> i32;

fn pipeline(input: i32, prepare: Step, finish: Step) -> i32 {
    let intermediate = prepare(input);
    finish(intermediate)
}

pub fn demo() -> i32 {
    let prepare: Step = increment;
    let mut finish: Step = twice;
    let first = pipeline(4, prepare, finish);
    finish = square;
    let second = pipeline(4, prepare, finish);
    first + second
}
```

Внешний вызов: `demo()`.

fn(i32) -> i32 здесь достаточно: шаги не содержат захваченного окружения. Переменная finish явно изменяема.

## Проверка и воспроизводимость

Python, Java, C++ и TypeScript исполнены: два последовательных вызова входа дали `35` и `35`. Java проверена OpenJDK 21; C++ — g++ в режиме C++17; TypeScript — Node.js 24 с удалением типов перед исполнением. Для TypeScript это проверка выполнения, а не отдельный прогон `tsc --strict`. C#, Go и Rust прошли статическое ревью; их компиляторы в среде отсутствуют. LMX проверен по документам, без запуска ядра.

Смысловые свойства, сохранённые в демонстрации (кроме запуска входа, проверены чтением кода):

- Первый запуск pipeline возвращает 10, второй — 25; demo возвращает 35.
- Тело pipeline не меняется при замене finish.
- Обе операции реально вызываются в порядке prepare, затем finish.

Подсчёт воспроизводится непосредственно по восьми блокам исходников выше: `sum(not ch.isspace() for ch in code)` для основной колонки и `len(code)` для полной. Перед подсчётом применяется описанная нормализация перевода строк.

## Найденные сетевые образцы

1. [Refactoring.Guru — Template Method](https://refactoring.guru/design-patterns/template-method). Общий порядок алгоритма и заменяемые шаги; исходная классовая формулировка.

2. [Refactoring.Guru — Template Method in Rust, conceptual example](https://refactoring.guru/design-patterns/template-method/rust/example). Проверен пример неизменного метода, вызывающего шаги. Ниже самостоятельная адаптация через callable под тот же LMX-сценарий.

Из сетевых материалов взяты ориентиры по ролям участников и взаимодействию. Имена, арифметика, объём поведения и код адаптированы к общему LMX-сценарию. Сравнение не переносит в маленький пример дополнительные функции исходного учебного проекта.
