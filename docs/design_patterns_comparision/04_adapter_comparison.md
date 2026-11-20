# 04. Adapter: сравнение исходников LMX и семи других языков

20 ноября 2026 года · Один сценарий, восемь реализаций

## Задача и границы примера

Старый метод принимает сначала вычитаемое, затем уменьшаемое. Новый интерфейс принимает уменьшаемое первым. Адаптер переставляет параметры; клиент вызывает его через заменяемую ссылку на операцию.

**Ожидаемый результат демонстрации: `5`.**

Сохранены три роли: старый метод, преобразующий вызов адаптер и клиент с callable-ссылкой. Адаптация касается смысла позиций двух int. Сравнивается эта минимальная задача, без классов Target/Adaptee, если язык позволяет выразить её обычными функциями. Именованные метки fn в LMX не имеют точного аналога у большинства функциональных типов, поэтому внешний вызов в остальных языках позиционный.

LMX взят без изменений из [согласованной русской подборки примеров](https://chatgpt.com/library?file_id=libfile_fde3_f-e112f68f2f20819185805436a1f1f225_bbe92b09b62881918d17958175103ded&account_id=personal). Для остальных языков найдены сетевые образцы по названию шаблона; на их основе написаны сопоставимые реализации именно этого сценария. Это оригинальная адаптация, а не дословная копия кода сайта и не измерение длины его полного учебного листинга. Источники приведены в конце.

## Как считались символы

Главная величина — **число непробельных символов** в показанном блоке исходника: все символы, для которых Python `str.isspace()` возвращает false. Пробелы, табуляции и переводы строк не учитываются. Это счётчик, а не преобразование кода в исполняемый минифицированный вариант; пробельные символы внутри строк также не считаются.

Дополнительно показаны полный размер в символах Unicode и число физических строк. Для полного размера используется LF, без начальных и конечных пустых строк и с одним LF в конце. Здесь все исходники ASCII, поэтому при UTF-8 число байтов совпадает с полным числом символов.

Считаются объявления, импорты, обязательные классы-оболочки или `package`, вспомогательные функции и весь демонстрационный сценарий внутри `demo` / `Demo` / LMX `run`. Внешний запуск, `main`, печать результата, тестовый harness, Markdown и пояснения не входят. Реализация стандартной библиотеки и runtime не входит ни для одного языка. В измеряемом коде нет комментариев.

Обычные функции, замыкания и стандартные типы callable разрешены. Python приведён без необязательных аннотаций типов; это не равенство статических гарантий с LMX или другими типизированными вариантами. Имена и учебная разбивка не нормализованы: числа описывают эти конкретные листинги, а не минимально возможную длину программы на языке.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 374 | 505 | 24 | 1.00× |
| Python | 179 | 220 | 11 | 0.48× |
| Java | 303 | 404 | 16 | 0.81× |
| C++ | 227 | 284 | 14 | 0.61× |
| C# | 258 | 374 | 20 | 0.69× |
| TypeScript | 303 | 367 | 14 | 0.81× |
| Go | 247 | 309 | 16 | 0.66× |
| Rust | 231 | 294 | 14 | 0.62× |

Отношение больше 1 означает, что этот листинг длиннее показанного LMX по непробельным символам.

## 1. LMX

```lmx
fn: Difference (int: left; int: right; return: int)

Legacy:
    int: right
    int: left
    return: int
    subtract:
        return: left - right
end: Legacy

DifferenceAdapter:
    int: minuend
    int: subtrahend
    return: int
    subtract:
        return: Legacy\subtract(right := subtrahend; left := minuend)
end: DifferenceAdapter

AdapterDemo:
    return: int
    run:
        @: operation Difference DifferenceAdapter\subtract
        return: operation(left := 8; right := 3)
end: AdapterDemo
```

Вызов из исполняемого контекста: `AdapterDemo\run()`. Сам этот внешний вызов не входит в подсчёт.

Считаются последние согласованные правила `fn`, структурных требований, связывания и `import` из исходной подборки.

## 2. Python

```python
def legacy_subtract(right, left):
    return left - right


def subtract(minuend, subtrahend):
    return legacy_subtract(right=subtrahend, left=minuend)


def demo():
    operation = subtract
    return operation(8, 3)
```

Внешний вызов: `demo()`.

Функции передаются как значения. Проверки callable-сигнатуры, аналогичной fn/implements, в этом неаннотированном варианте нет; ошибки типов проявятся при исполнении.

## 3. Java

```java
import java.util.function.IntBinaryOperator;

class Example {
    static int legacySubtract(int right, int left) {
        return left - right;
    }

    static int subtract(int minuend, int subtrahend) {
        return legacySubtract(subtrahend, minuend);
    }

    public static int demo() {
        IntBinaryOperator operation = Example::subtract;
        return operation.applyAsInt(8, 3);
    }
}
```

Внешний вызов: `Example.demo()`.

Стандартный IntBinaryOperator задаёт два int и результат int; ссылка на метод сохраняет заменяемость без отдельного класса адаптера.

## 4. C++

```cpp
using Difference = int (*)(int, int);

int legacySubtract(int right, int left) {
    return left - right;
}

int subtract(int minuend, int subtrahend) {
    return legacySubtract(subtrahend, minuend);
}

int demo() {
    Difference operation = subtract;
    return operation(8, 3);
}
```

Внешний вызов: `demo()`.

Типизированного указателя на функцию достаточно: захватываемого окружения и владения объектом здесь нет.

## 5. C#

```csharp
using System;

static class Example
{
    static int LegacySubtract(int right, int left)
    {
        return left - right;
    }

    static int Subtract(int minuend, int subtrahend)
    {
        return LegacySubtract(subtrahend, minuend);
    }

    public static int Demo()
    {
        Func<int, int, int> operation = Subtract;
        return operation(8, 3);
    }
}
```

Внешний вызов: `Example.Demo()`.

Стандартный делегат Func<int, int, int> сохраняет типизированную заменяемость; имена параметров старого метода не участвуют в совместимости делегата.

## 6. TypeScript

```typescript
type Difference = (left: number, right: number) => number;

function legacySubtract(right: number, left: number): number {
    return left - right;
}

function subtract(minuend: number, subtrahend: number): number {
    return legacySubtract(subtrahend, minuend);
}

function demo(): number {
    const operation: Difference = subtract;
    return operation(8, 3);
}
```

Внешний вызов: `demo()`.

Функциональный тип проверяет форму вызова статически, но number не является ограниченным int LMX. На выбранных малых целых арифметика совпадает.

## 7. Go

```go
package main

type Difference func(left, right int) int

func legacySubtract(right, left int) int {
    return left - right
}

func subtract(minuend, subtrahend int) int {
    return legacySubtract(subtrahend, minuend)
}

func demo() int {
    var operation Difference = subtract
    return operation(8, 3)
}
```

Внешний вызов: `demo()`.

Именованный функциональный тип заменяет отдельный интерфейс с единственным методом.

## 8. Rust

```rust
type Difference = fn(i32, i32) -> i32;

fn legacy_subtract(right: i32, left: i32) -> i32 {
    left - right
}

fn subtract(minuend: i32, subtrahend: i32) -> i32 {
    legacy_subtract(subtrahend, minuend)
}

pub fn demo() -> i32 {
    let operation: Difference = subtract;
    operation(8, 3)
}
```

Внешний вызов: `demo()`.

Использован обычный тип fn-указателя Rust: окружение не захватывается. Это встроенное средство Rust, не ресивер fn языка LMX.

## Проверка и воспроизводимость

Python, Java, C++ и TypeScript исполнены: два последовательных вызова входа дали `5` и `5`. Java проверена OpenJDK 21; C++ — g++ в режиме C++17; TypeScript — Node.js 24 с удалением типов перед исполнением. Для TypeScript это проверка выполнения, а не отдельный прогон `tsc --strict`. C#, Go и Rust прошли статическое ревью; их компиляторы в среде отсутствуют. LMX проверен по документам, без запуска ядра.

Смысловые свойства, сохранённые в демонстрации (кроме запуска входа, проверены чтением кода):

- demo() возвращает 5.
- Если клиенту напрямую присвоить legacy_subtract вместо адаптера, вызов с (8, 3) возвращает -5.
- Адаптер вызывает старую реализацию с переставленными аргументами, а не вычисляет разность самостоятельно.

Подсчёт воспроизводится непосредственно по восьми блокам исходников выше: `sum(not ch.isspace() for ch in code)` для основной колонки и `len(code)` для полной. Перед подсчётом применяется описанная нормализация перевода строк.

## Найденные сетевые образцы

1. [Refactoring.Guru — Adapter in Python, original conceptual examples](https://refactoring.guru/design-patterns/adapter/python/example). Найденный по названию образец: клиент, существующий интерфейс и делегирующий адаптер. Оттуда взято разделение ролей; код ниже написан заново для числового примера LMX, а не скопирован из примера со строками.

Из сетевых материалов взяты ориентиры по ролям участников и взаимодействию. Имена, арифметика, объём поведения и код адаптированы к общему LMX-сценарию. Сравнение не переносит в маленький пример дополнительные функции исходного учебного проекта.
