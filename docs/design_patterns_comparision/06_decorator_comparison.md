# 06. Decorator: сравнение исходников LMX и семи других языков

20 ноября 2026 года · Один сценарий, восемь реализаций

## Задача и границы примера

Базовая операция умножает вход на 2. Первая обёртка прибавляет 1 к её результату, вторая умножает результат первой на 3. Клиент выбирает внешнюю обёртку через callable-ссылку и передаёт 10.

**Ожидаемый результат демонстрации: `63`.**

Как в исходном примере LMX, цепочка фиксирована в определениях: Base → WithOne → WithThree. Её звенья доступны через одинаковую форму int → int, но произвольная сборка и перестановка декораторов во время выполнения здесь не реализована ни в одном языке. Это фиксированная композиция с ролью Decorator, а не полный конструктор вложенных GoF-объектов.

LMX взят без изменений из [согласованной русской подборки примеров](https://chatgpt.com/library?file_id=libfile_fde3_f-e112f68f2f20819185805436a1f1f225_bbe92b09b62881918d17958175103ded&account_id=personal). Для остальных языков найдены сетевые образцы по названию шаблона; на их основе написаны сопоставимые реализации именно этого сценария. Это оригинальная адаптация, а не дословная копия кода сайта и не измерение длины его полного учебного листинга. Источники приведены в конце.

## Как считались символы

Главная величина — **число непробельных символов** в показанном блоке исходника: все символы, для которых Python `str.isspace()` возвращает false. Пробелы, табуляции и переводы строк не учитываются. Это счётчик, а не преобразование кода в исполняемый минифицированный вариант; пробельные символы внутри строк также не считаются.

Дополнительно показаны полный размер в символах Unicode и число физических строк. Для полного размера используется LF, без начальных и конечных пустых строк и с одним LF в конце. Здесь все исходники ASCII, поэтому при UTF-8 число байтов совпадает с полным числом символов.

Считаются объявления, импорты, обязательные классы-оболочки или `package`, вспомогательные функции и весь демонстрационный сценарий внутри `demo` / `Demo` / LMX `run`. Внешний запуск, `main`, печать результата, тестовый harness, Markdown и пояснения не входят. Реализация стандартной библиотеки и runtime не входит ни для одного языка. В измеряемом коде нет комментариев.

Обычные функции, замыкания и стандартные типы callable разрешены. Python приведён без необязательных аннотаций типов; это не равенство статических гарантий с LMX или другими типизированными вариантами. Имена и учебная разбивка не нормализованы: числа описывают эти конкретные листинги, а не минимально возможную длину программы на языке.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 352 | 500 | 29 | 1.00× |
| Python | 159 | 210 | 15 | 0.45× |
| Java | 295 | 419 | 20 | 0.84× |
| C++ | 209 | 275 | 18 | 0.59× |
| C# | 248 | 390 | 25 | 0.70× |
| TypeScript | 285 | 358 | 18 | 0.81× |
| Go | 232 | 305 | 20 | 0.66× |
| Rust | 211 | 284 | 18 | 0.60× |

Отношение больше 1 означает, что этот листинг длиннее показанного LMX по непробельным символам.

## 1. LMX

```lmx
fn: TransformSignature (int: x; return: int)

Base:
    int: value
    return: int
    apply:
        return: value * 2
end: Base

WithOne:
    int: input
    return: int
    apply:
        return: Base\apply(value := input) + 1
end: WithOne

WithThree:
    int: argument
    return: int
    apply:
        return: WithOne\apply(input := argument) * 3
end: WithThree

Demo:
    return: int
    run:
        @: transform TransformSignature WithThree\apply
        return: transform(x := 10)
end: Demo
```

Вызов из исполняемого контекста: `Demo\run()`. Сам этот внешний вызов не входит в подсчёт.

Считаются последние согласованные правила `fn`, структурных требований, связывания и `import` из исходной подборки.

## 2. Python

```python
def base(value):
    return value * 2


def with_one(value):
    return base(value) + 1


def with_three(value):
    return with_one(value) * 3


def demo():
    transform = with_three
    return transform(10)
```

Внешний вызов: `demo()`.

Каждая функция имеет одинаковую форму вызова и добавляет действие после делегирования. Синтаксический @decorator Python здесь не требуется; статических аннотаций нет.

## 3. Java

```java
import java.util.function.IntUnaryOperator;

class Example {
    static int base(int value) {
        return value * 2;
    }

    static int withOne(int value) {
        return base(value) + 1;
    }

    static int withThree(int value) {
        return withOne(value) * 3;
    }

    public static int demo() {
        IntUnaryOperator transform = Example::withThree;
        return transform.applyAsInt(10);
    }
}
```

Внешний вызов: `Example.demo()`.

IntUnaryOperator позволяет выбрать любое звено без отдельной иерархии классов. Внутренняя цепочка фиксирована, как и в LMX.

## 4. C++

```cpp
using Transform = int (*)(int);

int base(int value) {
    return value * 2;
}

int withOne(int value) {
    return base(value) + 1;
}

int withThree(int value) {
    return withOne(value) * 3;
}

int demo() {
    Transform transform = withThree;
    return transform(10);
}
```

Внешний вызов: `demo()`.

Захватываемого состояния нет, поэтому используется обычный указатель на функцию без std::function и дополнительных объектов.

## 5. C#

```csharp
using System;

static class Example
{
    static int Base(int value)
    {
        return value * 2;
    }

    static int WithOne(int value)
    {
        return Base(value) + 1;
    }

    static int WithThree(int value)
    {
        return WithOne(value) * 3;
    }

    public static int Demo()
    {
        Func<int, int> transform = WithThree;
        return transform(10);
    }
}
```

Внешний вызов: `Example.Demo()`.

Все звенья подходят к стандартному Func<int, int>; делегат в клиенте может ссылаться на базовую операцию или любую обёртку.

## 6. TypeScript

```typescript
type Transform = (value: number) => number;

function base(value: number): number {
    return value * 2;
}

function withOne(value: number): number {
    return base(value) + 1;
}

function withThree(value: number): number {
    return withOne(value) * 3;
}

function demo(): number {
    const transform: Transform = withThree;
    return transform(10);
}
```

Внешний вызов: `demo()`.

Функциональный тип служит общим интерфейсом. Метапрограммные decorators TypeScript не используются: это другой механизм, который для данной задачи не нужен.

## 7. Go

```go
package main

type Transform func(int) int

func base(value int) int {
    return value * 2
}

func withOne(value int) int {
    return base(value) + 1
}

func withThree(value int) int {
    return withOne(value) * 3
}

func demo() int {
    var transform Transform = withThree
    return transform(10)
}
```

Внешний вызов: `demo()`.

Именованный тип функции задаёт общий интерфейс всех звеньев; методы и структурные интерфейсы для этого небольшого примера не нужны.

## 8. Rust

```rust
type Transform = fn(i32) -> i32;

fn base(value: i32) -> i32 {
    value * 2
}

fn with_one(value: i32) -> i32 {
    base(value) + 1
}

fn with_three(value: i32) -> i32 {
    with_one(value) * 3
}

pub fn demo() -> i32 {
    let transform: Transform = with_three;
    transform(10)
}
```

Внешний вызов: `demo()`.

Одинаковый тип fn(i32) -> i32 сохраняет заменяемость звеньев. Здесь не требуются trait-объекты, владение или захват окружения.

## Проверка и воспроизводимость

Python, Java, C++ и TypeScript исполнены: два последовательных вызова входа дали `63` и `63`. Java проверена OpenJDK 21; C++ — g++ в режиме C++17; TypeScript — Node.js 24 с удалением типов перед исполнением. Для TypeScript это проверка выполнения, а не отдельный прогон `tsc --strict`. C#, Go и Rust прошли статическое ревью; их компиляторы в среде отсутствуют. LMX проверен по документам, без запуска ядра.

Смысловые свойства, сохранённые в демонстрации (кроме запуска входа, проверены чтением кода):

- demo() возвращает 63: ((10 × 2) + 1) × 3.
- Замена внешней ссылки на base возвращает 20, на with_one — 21.
- Обе обёртки реально делегируют следующему звену; выражение не свёрнуто в одну арифметическую формулу.

Подсчёт воспроизводится непосредственно по восьми блокам исходников выше: `sum(not ch.isspace() for ch in code)` для основной колонки и `len(code)` для полной. Перед подсчётом применяется описанная нормализация перевода строк.

## Найденные сетевые образцы

1. [Refactoring.Guru — Decorator in Python, original conceptual example](https://refactoring.guru/design-patterns/decorator/python/example). Источник показывает обёртки, делегирующие друг другу через общий интерфейс. Для равенства объёма задачи код написан заново как фиксированная цепочка числовых функций, соответствующая LMX. Динамическое вложение объектов исходного образца не переносилось.

Из сетевых материалов взяты ориентиры по ролям участников и взаимодействию. Имена, арифметика, объём поведения и код адаптированы к общему LMX-сценарию. Сравнение не переносит в маленький пример дополнительные функции исходного учебного проекта.
