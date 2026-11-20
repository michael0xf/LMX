# 08. Template Method: LMX и семь других языков

20 ноября 2026 года · Редакция по Python-прототипу

## Задача и границы

Три арифметических шага, постоянная последовательность execute и её demo находятся в одной группе pipeline. Это перенос структуры Python-функций с общим DATA числовых методов. Меняется только ссылка finish.

**Ожидаемый результат: 35.**

Постоянный порядок двух независимо заменяемых шагов. LMX передаёт ссылки на шаги через текущий контекст, другие варианты могут передавать их явно. Не вводится дополнительная обязательная иерархия классов.

## Архитектура LMX

Python increment / twice / square / pipeline / demo собраны в группу pipeline. execute сохраняет последовательность шагов, а demo задаёт prepare и finish обычными ссылками. Данные шага передаются через autofill.

Структура задаёт общий DATA связанных методов. Метод обращается к нужным ему полям; отдельная оболочка для demo из-за остальных полей не требуется. Обычная ссылка `@: name method` не вызывает method и не требует самостоятельного `fn`. Программа по-прежнему использует типы объявленных полей и правила конкретных вызовов. [Связывание и ссылки][B]

Пустая строка завершает корневой синтаксический блок. Внутренний `---` сохраняется там, где нужно продолжить внешнюю структуру. `node\` выбирает лексическую связь, а не переход к parent. [Границы блоков][E]

## Подсчёт исходников

Главная метрика — **число непробельных символов**: `sum(not ch.isspace() for ch in code)`. Пробельные символы исключаются только из измерения; исходник сохраняет необходимое форматирование. Также приведены полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF после последней строки.

Считается весь показанный листинг: объявления, импорты, необходимые языковые оболочки, методы и демонстрация. Внешний вызов, main, печать, тестовый harness, Markdown и реализация runtime/стандартной библиотеки не входят. Имена не нормализованы. Python записан без необязательных аннотаций; одинаковые статические гарантии не заявляются. Таблица измеряет эти программы, а не теоретический минимум для каждого языка.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 228 | 379 | 18 | 1.00× |
| Python | 305 | 398 | 19 | 1.34× |
| Java | 543 | 773 | 29 | 2.38× |
| C++ | 376 | 495 | 26 | 1.65× |
| C# | 458 | 693 | 29 | 2.01× |
| TypeScript | 478 | 606 | 26 | 2.10× |
| Go | 397 | 519 | 28 | 1.74× |
| Rust | 381 | 510 | 26 | 1.67× |

Отношение больше 1 означает более длинный листинг по непробельным символам.

## 1. LMX

```lmx
pipeline:
    int: value
    return: int
    increment:
        return: value + 1
    twice:
        return: value * 2
    square:
        return: value * value
    execute:
        value := prepare()
        return: finish()
    demo:
        @: prepare increment
        @: finish twice
        int: first execute(4)
        finish := square
        return: first + execute(4)
```

Внешний вызов: `pipeline\demo()`. Он не входит в подсчёт.

demo объявляет локальные ссылки @: prepare increment и @: finish twice без дополнительного fn-контракта. В execute имена prepare и finish не объявлены в собственных DATA или code и связываются с контекстом непосредственно вызывающего demo. execute(4) имеет собственное value=4. prepare() вызывает increment и через autofill передаёт ему копию4; результат5 присваивается локальному value текущего execute. finish() получает свою копию5 и возвращает10 либо25. finish := square меняет ссылку в demo между вызовами. Общий исходный граф value не меняется. Методы DATA не обязаны пользоваться всеми его полями; отдельная Demo не нужна.

execute(4) передаёт 4 в prepare и получает 5. После локального присваивания finish получает 5 и возвращает 10. Во втором проходе выбран square, поэтому получается 25. Итоговая сумма — 35.

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
    return first + pipeline(4, prepare, finish)
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

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
        return first + pipeline(4, prepare, finish);
    }
}
```

Внешний вызов: `Example.demo()`. Он не входит в подсчёт.

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
    return first + pipeline(4, prepare, finish);
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

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
        return first + Pipeline(4, prepare, finish);
    }
}
```

Внешний вызов: `Example.Demo()`. Он не входит в подсчёт.

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
    return first + pipeline(4, prepare, finish);
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

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
    return first + pipeline(4, prepare, finish)
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

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
    first + pipeline(4, prepare, finish)
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## Что изменилось

LMX: **280 → 228 непробельных символов** относительно предыдущей согласованной редакции. Убрана обвязка, не нужная показанному сценарию: отдельные демонстрационные структуры, повторные описания сигнатур, промежуточные ссылки или перекладывание значений. Это изменение исходников; скорость исполнения не измерялась.

Семь остальных листингов сохранены из предыдущей редакции: их показанный сценарий не изменился.

## Проверка

LMX проверен по согласованным правилам: DATA, обычные ссылки на методы, явные аргументы и autofill, места вызывающего, лексический node и синтаксические границы. LMX-ядро здесь не запускалось; результат указан как ожидаемый.

Python, Java, C++ и TypeScript совпадают байт в байт с ранее исполненными вариантами; повторно запускать неизменённые программы не требовалось. C#, Go и Rust сохраняют статус статического ревью. Эта редакция не выдаёт переиспользование проверки за новый запуск.

Метрики пересчитаны непосредственно из восьми блоков исходника. Тестовая обвязка в них не включена.

## Источники правил и примеров

- [Связывание, структурный вызов и необязательный самостоятельный fn-контракт][B].
- [Переданные объявления и импорт корневых const-объявлений][D].
- [Пустая строка как завершение корневого блока][E].

Ранее использованные сетевые образцы ролей шаблона сохранены как источники. Показанные программы — адаптации общего сценария, а не дословные копии или измерение длины этих страниц.

- [Refactoring.Guru — Template Method](https://refactoring.guru/design-patterns/template-method)
- [Refactoring.Guru — Template Method in Rust, conceptual example](https://refactoring.guru/design-patterns/template-method/rust/example)

[B]: https://chatgpt.com/library?file_id=libfile_fde3_f-a38201c30fb88191b7207c0e48955c30_bbe92b09b62881918d17958175103ded&account_id=personal
[D]: https://chatgpt.com/library?file_id=libfile_fde3_f-02443abbc4508191b7c8fd7894e3ac24_bbe92b09b62881918d17958175103ded&account_id=personal
[E]: https://chatgpt.com/library?file_id=libfile_fde3_f-9d15a59bc5d881918724924fcef45b04_bbe92b09b62881918d17958175103ded&account_id=personal
