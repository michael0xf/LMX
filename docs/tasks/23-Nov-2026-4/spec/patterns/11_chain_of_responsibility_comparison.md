# 11. Chain of Responsibility: LMX и семь других языков

21 ноября 2026 года · Согласовано с документацией docs

## Задача

negative обрабатывает отрицательное число и возвращает 1; even обрабатывает чётное и возвращает 2. Ноль означает отказ обработчика. dispatch использует negative и even по умолчанию, но позволяет явно передать обе другие ссылки или поменять их местами.

**Внешний вызов LMX:** `chain\demo()`. **Ожидаемый результат: 5.**

Минимальная цепочка ровно из двух настраиваемых обработчиков. Первый принявший запрос завершает обработку; если оба отказываются, результат 0. Произвольная длина цепочки, пустая цепочка и асинхронные обработчики в этот сценарий не входят.

## Архитектура LMX

Как Python-функция с двумя default-параметрами, DATA LMX задаёт first = negative и second = even. dispatch вызывает first, а при нулевом результате — second. value передаётся обработчикам через autofill. Готовые defaults не заменяются одноимёнными локалями: перестановка выполнена явно через dispatch(-2; even; negative). Java и C# дают обычную перегрузку для defaults, Go и Rust — короткую функцию-обёртку.

Применены согласованные правила: DATA метода — его фактический parent; обычные ссылки на методы не требуют отдельного `fn`; объявленные входы без initializer допускают autofill, свободные имена — связь с местом непосредственного caller. `node\` выбирает лексическую связь. Пустая строка завершает корневой блок. [Связывание](../LMX_semantics.en.md#binding-places) · [Импорт](../LMX_semantics.en.md#import-receiver) · [Границы блоков](../LMX_grammar.en.md#levels)

## Подсчёт исходников

Главная метрика — **непробельные символы**: `sum(not ch.isspace() for ch in code)`. Дополнительно показаны полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF в конце.

В подсчёт входят весь показанный исходник, импорты, необходимые языковые оболочки и `demo`. Внешний запуск, `main`, печать результата, тестовая обвязка и реализация стандартной библиотеки/runtime не включены. Имена не нормализованы. Python записан без необязательных аннотаций типов. Сравниваются конкретные реализации одной задачи; это не оценка быстродействия или одинаковых статических гарантий.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
| --- | ---: | ---: | ---: | ---: |
| LMX | 295 | 517 | 24 | 1.00× |
| Python | 297 | 401 | 18 | 1.01× |
| Java | 549 | 773 | 29 | 1.86× |
| C++ | 361 | 484 | 23 | 1.22× |
| C# | 461 | 688 | 29 | 1.56× |
| TypeScript | 437 | 566 | 23 | 1.48× |
| Go | 441 | 628 | 37 | 1.49× |
| Rust | 434 | 597 | 29 | 1.47× |

Общая таблица серии доступна в [Excel](LMX_Comparison_10-18.xlsx) и [PDF](LMX_Comparison_10-18.pdf).

## 1. LMX

```lmx
chain:
    int: value
    @: first negative
    @: second even
    return: int
    negative:
        if: value < 0
            return: 1
        return: 0
    even:
        if: value % 2 = 0
            return: 2
        return: 0
    dispatch:
        int: result first()
        if: result
            return: result
        return: second()
    demo:
        int: result dispatch(-2)
        result += dispatch(4)
        result += dispatch(3)
        result += dispatch(-2; even; negative)
        return: result
```
Внешний вызов: `chain\demo()`. Он не входит в подсчёт.

С порядком по умолчанию запросы −2, 4, 3 дают 1, 2, 0. Затем явный вызов с порядком even, negative даёт 2 для того же −2. Итог равен 5. Если первый обработчик принял запрос, второй не вызывается.

## 2. Python

```python
def negative(value):
    return 1 if value < 0 else 0

def even(value):
    return 2 if value % 2 == 0 else 0

def dispatch(value, first=negative, second=even):
    result = first(value)
    if result:
        return result
    return second(value)

def demo():
    result = dispatch(-2)
    result += dispatch(4)
    result += dispatch(3)
    result += dispatch(-2, even, negative)
    return result
```
Внешний вызов: `demo()`. Он не входит в подсчёт.

## 3. Java

```java
import java.util.function.IntUnaryOperator;

class Example {
    static int negative(int value) {
        return value < 0 ? 1 : 0;
    }

    static int even(int value) {
        return value % 2 == 0 ? 2 : 0;
    }

    static int dispatch(int value, IntUnaryOperator first, IntUnaryOperator second) {
        int result = first.applyAsInt(value);
        if (result != 0) return result;
        return second.applyAsInt(value);
    }

    static int dispatch(int value) {
        return dispatch(value, Example::negative, Example::even);
    }

    public static int demo() {
        int result = dispatch(-2);
        result += dispatch(4);
        result += dispatch(3);
        result += dispatch(-2, Example::even, Example::negative);
        return result;
    }
}
```
Внешний вызов: `Example.demo()`. Он не входит в подсчёт.

## 4. C++

```cpp
using Handler = int (*)(int);

int negative(int value) {
    return value < 0 ? 1 : 0;
}

int even(int value) {
    return value % 2 == 0 ? 2 : 0;
}

int dispatch(int value, Handler first = negative, Handler second = even) {
    int result = first(value);
    if (result != 0) return result;
    return second(value);
}

int demo() {
    int result = dispatch(-2);
    result += dispatch(4);
    result += dispatch(3);
    result += dispatch(-2, even, negative);
    return result;
}
```
Внешний вызов: `demo()`. Он не входит в подсчёт.

## 5. C#

```csharp
using System;

static class Example {
    static int Negative(int value) {
        return value < 0 ? 1 : 0;
    }

    static int Even(int value) {
        return value % 2 == 0 ? 2 : 0;
    }

    static int Dispatch(int value, Func<int, int> first, Func<int, int> second) {
        int result = first(value);
        if (result != 0) return result;
        return second(value);
    }

    static int Dispatch(int value) {
        return Dispatch(value, Negative, Even);
    }

    public static int Demo() {
        int result = Dispatch(-2);
        result += Dispatch(4);
        result += Dispatch(3);
        result += Dispatch(-2, Even, Negative);
        return result;
    }
}
```
Внешний вызов: `Example.Demo()`. Он не входит в подсчёт.

## 6. TypeScript

```typescript
type Handler = (value: number) => number;

function negative(value: number): number {
    return value < 0 ? 1 : 0;
}

function even(value: number): number {
    return value % 2 === 0 ? 2 : 0;
}

function dispatch(value: number, first: Handler = negative, second: Handler = even): number {
    const result = first(value);
    if (result !== 0) return result;
    return second(value);
}

function demo(): number {
    let result = dispatch(-2);
    result += dispatch(4);
    result += dispatch(3);
    result += dispatch(-2, even, negative);
    return result;
}
```
Внешний вызов: `demo()`. Он не входит в подсчёт.

## 7. Go

```go
package main

type Handler func(int) int

func negative(value int) int {
    if value < 0 {
        return 1
    }
    return 0
}

func even(value int) int {
    if value % 2 == 0 {
        return 2
    }
    return 0
}

func dispatchWith(value int, first, second Handler) int {
    result := first(value)
    if result != 0 {
        return result
    }
    return second(value)
}

func dispatch(value int) int {
    return dispatchWith(value, negative, even)
}

func demo() int {
    result := dispatch(-2)
    result += dispatch(4)
    result += dispatch(3)
    result += dispatchWith(-2, even, negative)
    return result
}
```
Внешний вызов: `demo()`. Он не входит в подсчёт.

## 8. Rust

```rust
type Handler = fn(i32) -> i32;

fn negative(value: i32) -> i32 {
    if value < 0 { 1 } else { 0 }
}

fn even(value: i32) -> i32 {
    if value % 2 == 0 { 2 } else { 0 }
}

fn dispatch_with(value: i32, first: Handler, second: Handler) -> i32 {
    let result = first(value);
    if result != 0 {
        return result;
    }
    second(value)
}

fn dispatch(value: i32) -> i32 {
    dispatch_with(value, negative, even)
}

pub fn demo() -> i32 {
    let mut result = dispatch(-2);
    result += dispatch(4);
    result += dispatch(3);
    result += dispatch_with(-2, even, negative);
    result
}
```
Внешний вызов: `demo()`. Он не входит в подсчёт.

## Что изменилось в этой редакции

Сравнение в LMX записано текущим операндом =. Порядок обработчиков, defaults и ожидаемые результаты сохранены.

Семь остальных листингов сохранены без изменений относительно загруженного архива.

## Проверка

LMX сопоставлен с правилами docs: роли DATA/CODE, аргументы, связывание, лексический node и синтаксические границы. Для copy/merge учитываются поток результата и явная группировка. Ожидаемые результаты относятся к этой модели.

В исходной редакции сообщалось об исполнении Python, Java, C++ и TypeScript и статическом просмотре C#, Go и Rust. Их листинги сохранены без изменений; новых запусков эта редакция не заявляет. LMX-ядро здесь не запускалось.

Метрики пересчитываются непосредственно из восьми основных блоков исходника. Внешний вызов и тестовая обвязка не включены.

## Источники

Сетевые образцы использованы для проверки ролей шаблона. Показанные программы — самостоятельные адаптации общего сценария, а не подсчёт длины исходников этих страниц.

- [Refactoring.Guru — Chain of Responsibility in Python, conceptual example](https://refactoring.guru/design-patterns/chain-of-responsibility/python/example)

