# 07. Command: сравнение исходников LMX и семи других языков

20 ноября 2026 года · Один сценарий, восемь реализаций

## Задача и границы примера

Сбросить счётчик, передать общему исполнителю действие «прибавить 2», затем действие «удвоить». Исполнитель вызывает переданное действие, не зная его содержания; результат — 4.

**Ожидаемый результат демонстрации: `4`.**

Два действия без явных аргументов и единый исполнитель. Нет очереди, undo, сериализации или истории. Сохраняется действие по умолчанию: прибавить 2. В разных языках отсутствие аргумента выражается default, перегрузкой, отдельной функцией или Option; демонстрация везде выбирает обе команды явно.

LMX взят без изменений из [согласованной русской подборки примеров](https://chatgpt.com/library?file_id=libfile_fde3_f-e112f68f2f20819185805436a1f1f225_bbe92b09b62881918d17958175103ded&account_id=personal). Для остальных языков найдены сетевые образцы по названию шаблона; на их основе написаны сопоставимые реализации именно этого сценария. Это оригинальная адаптация, а не дословная копия кода сайта и не измерение длины его полного учебного листинга. Источники приведены в конце.

## Как считались символы

Главная величина — **число непробельных символов** в показанном блоке исходника: все символы, для которых Python `str.isspace()` возвращает false. Пробелы, табуляции и переводы строк не учитываются. Это счётчик, а не преобразование кода в исполняемый минифицированный вариант; пробельные символы внутри строк также не считаются.

Дополнительно показаны полный размер в символах Unicode и число физических строк. Для полного размера используется LF, без начальных и конечных пустых строк и с одним LF в конце. Здесь все исходники ASCII, поэтому при UTF-8 число байтов совпадает с полным числом символов.

Считаются объявления, импорты, обязательные классы-оболочки или `package`, вспомогательные функции и весь демонстрационный сценарий внутри `demo` / `Demo` / LMX `run`. Внешний запуск, `main`, печать результата, тестовый harness, Markdown и пояснения не входят. Реализация стандартной библиотеки и runtime не входит ни для одного языка. В измеряемом коде нет комментариев.

Обычные функции, замыкания и стандартные типы callable разрешены. Python приведён без необязательных аннотаций типов; это не равенство статических гарантий с LMX или другими типизированными вариантами. Имена и учебная разбивка не нормализованы: числа описывают эти конкретные листинги, а не минимально возможную длину программы на языке.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 387 | 525 | 30 | 1.00× |
| Python | 226 | 289 | 17 | 0.58× |
| Java | 318 | 482 | 26 | 0.82× |
| C++ | 231 | 306 | 22 | 0.60× |
| C# | 303 | 471 | 28 | 0.78× |
| TypeScript | 303 | 384 | 22 | 0.78× |
| Go | 260 | 345 | 28 | 0.67× |
| Rust | 443 | 529 | 26 | 1.14× |

Отношение больше 1 означает, что этот листинг длиннее показанного LMX по непробельным символам.

## 1. LMX

```lmx
Counter:
    int: value 0
end: Counter

fn: CommandSignature ()

AddTwoCommand:
    execute:
        Counter\value += 2
end: AddTwoCommand

DoubleCommand:
    execute:
        Counter\value *= 2
end: DoubleCommand

Invoker:
    @: command CommandSignature AddTwoCommand\execute
    run:
        command()
end: Invoker

Demo:
    return: int
    run:
        Counter\value := 0
        Invoker\run(command := AddTwoCommand\execute)
        Invoker\run(command := DoubleCommand\execute)
        return: Counter\value
end: Demo
```

Вызов из исполняемого контекста: `Demo\run()`. Сам этот внешний вызов не входит в подсчёт.

Считаются последние согласованные правила `fn`, структурных требований, связывания и `import` из исходной подборки.

## 2. Python

```python
class Counter:
    value = 0

def add_two_command():
    Counter.value += 2

def double_command():
    Counter.value *= 2

def invoke(command=add_two_command):
    command()

def demo():
    Counter.value = 0
    invoke(add_two_command)
    invoke(double_command)
    return Counter.value
```

Внешний вызов: `demo()`.

Функции — передаваемые команды, invoke — исполнитель. Тип callable здесь проверяется при выполнении; статический контракт не объявлен.

## 3. Java

```java
class Example {
    static int counter = 0;

    static void addTwoCommand() {
        counter += 2;
    }

    static void doubleCommand() {
        counter *= 2;
    }

    static void invoke(Runnable command) {
        command.run();
    }

    static void invoke() {
        invoke(Example::addTwoCommand);
    }

    public static int demo() {
        counter = 0;
        invoke(Example::addTwoCommand);
        invoke(Example::doubleCommand);
        return counter;
    }
}
```

Внешний вызов: `Example.demo()`.

Runnable задаёт стандартный контракт действия без аргументов и результата. Перегрузка invoke() сохраняет команду по умолчанию.

## 4. C++

```cpp
int counter = 0;

void addTwoCommand() {
    counter += 2;
}

void doubleCommand() {
    counter *= 2;
}

using Command = void (*)();

void invoke(Command command = addTwoCommand) {
    command();
}

int demo() {
    counter = 0;
    invoke(addTwoCommand);
    invoke(doubleCommand);
    return counter;
}
```

Внешний вызов: `demo()`.

Для этих команд достаточно обычного указателя на функцию: дополнительного состояния захвата у них нет. Счётчик хранится отдельно.

## 5. C#

```csharp
using System;

static class Example {
    static int counter = 0;

    static void AddTwoCommand() {
        counter += 2;
    }

    static void DoubleCommand() {
        counter *= 2;
    }

    static void Invoke(Action command) {
        command();
    }

    static void Invoke() {
        Invoke(AddTwoCommand);
    }

    public static int Demo() {
        counter = 0;
        Invoke(AddTwoCommand);
        Invoke(DoubleCommand);
        return counter;
    }
}
```

Внешний вызов: `Example.Demo()`.

Action — стандартный тип команды. Перегрузка без аргументов задаёт тот же default.

## 6. TypeScript

```typescript
const counter = {value: 0};

function addTwoCommand(): void {
    counter.value += 2;
}

function doubleCommand(): void {
    counter.value *= 2;
}

type Command = () => void;

function invoke(command: Command = addTwoCommand): void {
    command();
}

function demo(): number {
    counter.value = 0;
    invoke(addTwoCommand);
    invoke(doubleCommand);
    return counter.value;
}
```

Внешний вызов: `demo()`.

Именованный функциональный тип выполняет роль сигнатуры; default задаётся непосредственно в параметре.

## 7. Go

```go
package main

var counter = 0

func addTwoCommand() {
    counter += 2
}

func doubleCommand() {
    counter *= 2
}

type Command func()

func invoke(command Command) {
    command()
}

func invokeDefault() {
    invoke(addTwoCommand)
}

func demo() int {
    counter = 0
    invoke(addTwoCommand)
    invoke(doubleCommand)
    return counter
}
```

Внешний вызов: `demo()`.

Go не использует default-параметр в этой записи: эквивалентный вызов с выбранной по умолчанию командой вынесен в invokeDefault().

## 8. Rust

```rust
use std::cell::Cell;

thread_local! {
    static COUNTER: Cell<i32> = Cell::new(0);
}

fn add_two_command() {
    COUNTER.with(|counter| counter.set(counter.get() + 2));
}

fn double_command() {
    COUNTER.with(|counter| counter.set(counter.get() * 2));
}

type Command = fn();

fn invoke(command: Option<Command>) {
    command.unwrap_or(add_two_command)();
}

pub fn demo() -> i32 {
    COUNTER.with(|counter| counter.set(0));
    invoke(Some(add_two_command));
    invoke(Some(double_command));
    COUNTER.with(Cell::get)
}
```

Внешний вызов: `demo()`.

Cell и thread_local! сохраняют изменяемый счётчик между вызовами без unsafe. Сценарий однопоточный; межпоточное общее состояние здесь не моделируется. None выбирает команду по умолчанию.

## Проверка и воспроизводимость

Python, Java, C++ и TypeScript исполнены: два последовательных вызова входа дали `4` и `4`. Java проверена OpenJDK 21; C++ — g++ в режиме C++17; TypeScript — Node.js 24 с удалением типов перед исполнением. Для TypeScript это проверка выполнения, а не отдельный прогон `tsc --strict`. C#, Go и Rust прошли статическое ревью; их компиляторы в среде отсутствуют. LMX проверен по документам, без запуска ядра.

Смысловые свойства, сохранённые в демонстрации (кроме запуска входа, проверены чтением кода):

- demo возвращает 4; повторный demo снова возвращает 4 благодаря явному сбросу.
- Исполнитель вызывает переданный callable, а не выбирает команду по имени или условию.
- Вызов default после сброса даёт 2.

Подсчёт воспроизводится непосредственно по восьми блокам исходников выше: `sum(not ch.isspace() for ch in code)` для основной колонки и `len(code)` для полной. Перед подсчётом применяется описанная нормализация перевода строк.

## Найденные сетевые образцы

1. [Refactoring.Guru — Command](https://refactoring.guru/design-patterns/command). Роли команды, получателя, исполнителя и клиента.

2. [Refactoring.Guru — Command in Python, conceptual example](https://refactoring.guru/design-patterns/command/python/example). Проверен пример отдельного Invoker. Ниже оригинальная адаптация к счётчику; стандартные callable заменяют специальную иерархию команд.

Из сетевых материалов взяты ориентиры по ролям участников и взаимодействию. Имена, арифметика, объём поведения и код адаптированы к общему LMX-сценарию. Сравнение не переносит в маленький пример дополнительные функции исходного учебного проекта.
