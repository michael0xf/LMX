# 02. Strategy: LMX и семь других языков

21 ноября 2026 года · Согласовано с документацией docs

## Задача и границы

Перенос Python twice/thrice/apply/demo в одну группу strategy с общим DATA. Выбранная ссылка selected меняется между двумя вызовами apply; готовый default operation=twice сохраняется.

**Ожидаемый результат: 25.**

Сохранены два алгоритма, общий потребитель, default и смена ссылки. Дополнительный именованный fn-контракт переменной не входит в задачу. Все вызовы подчиняются обычному допуску аргументов выбранного метода.

## Архитектура LMX

Python-функции twice, thrice, apply и demo стали методами одной группы strategy. Общие объявления DATA заменяют повторение параметров; selected остаётся настоящей переназначаемой ссылкой, а apply сохраняет default операции.

Структура задаёт общий DATA связанных методов. Метод обращается к нужным ему полям; отдельная оболочка для demo из-за остальных полей не требуется. Обычная ссылка `@: name method` не вызывает method и не требует самостоятельного `fn`. Программа по-прежнему использует типы объявленных полей и правила конкретных вызовов. [Связывание и ссылки](../LMX_semantics.en.md#binding-places)

Пустая строка завершает корневой синтаксический блок. Внутренний `---` сохраняется там, где нужно продолжить внешнюю структуру. `node\` выбирает лексическую связь, а не переход к parent. [Границы блоков](../LMX_grammar.en.md#levels)

## Подсчёт исходников

Главная метрика — **число непробельных символов**: `sum(not ch.isspace() for ch in code)`. Пробельные символы исключаются только из измерения; исходник сохраняет необходимое форматирование. Также приведены полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF после последней строки.

Считается весь показанный листинг: объявления, импорты, необходимые языковые оболочки, методы и демонстрация. Внешний вызов, main, печать, тестовый harness, Markdown и реализация runtime/стандартной библиотеки не входят. Имена не нормализованы. Python записан без необязательных аннотаций; одинаковые статические гарантии не заявляются. Таблица измеряет эти программы, а не теоретический минимум для каждого языка.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
| --- | ---: | ---: | ---: | ---: |
| LMX | 201 | 322 | 15 | 1.00× |
| Python | 204 | 272 | 17 | 1.01× |
| Java | 428 | 605 | 26 | 2.13× |
| C++ | 304 | 393 | 22 | 1.51× |
| C# | 360 | 540 | 26 | 1.79× |
| TypeScript | 345 | 439 | 20 | 1.72× |
| Go | 318 | 434 | 25 | 1.58× |
| Rust | 305 | 398 | 20 | 1.52× |

Отношение больше 1 означает более длинный листинг по непробельным символам.

## 1. LMX

```lmx
strategy:
    int: value
    @: operation twice
    return: int
    twice:
        return: value * 2
    thrice:
        return: value * 3
    apply:
        return: operation()
    demo:
        @: selected twice
        int: first apply(5; selected)
        selected := thrice
        return: first + apply(5; selected)
```
Внешний вызов: `strategy\demo()`. Он не входит в подсчёт.

Все методы используют объявления value, operation и return общего DATA. Не каждый метод обязан обращаться ко всем полям. apply(5; selected) явно задаёт value и operation. operation() вызывает выбранный метод; его объявленный value получает копию 5 от непосредственного apply. Собственное operation этого арифметического метода имеет исходный default и не используется телом. demo — обычный метод группы. @: selected twice создаёт ссылку на метод без вызова; selected := thrice переназначает её по общим правилам. Отдельного fn-требования программа не вводит. Прямой apply(5) использует ready default twice; одноимённая локаль сама default не вытесняет.

Первый apply(5; selected) использует twice и возвращает 10. После selected := thrice второй возвращает 15. Отдельный apply(5) сохраняет исходный default twice.

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
    return first + apply(5, selected)
```
Внешний вызов: `demo()`. Он не входит в подсчёт.

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
        return first + apply(5, selected);
    }
}
```
Внешний вызов: `Example.demo()`. Он не входит в подсчёт.

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
    return first + apply(5, selected);
}
```
Внешний вызов: `demo()`. Он не входит в подсчёт.

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
        return first + Apply(5, selected);
    }
}
```
Внешний вызов: `Example.Demo()`. Он не входит в подсчёт.

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
    return first + apply(5, selected);
}
```
Внешний вызов: `demo()`. Он не входит в подсчёт.

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
    return first + apply(5, selected)
}
```
Внешний вызов: `demo()`. Он не входит в подсчёт.

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
    first + apply(5, Some(selected))
}
```
Внешний вызов: `demo()`. Он не входит в подсчёт.

## Что изменилось в этой редакции

Сохранены общий DATA, обычные ссылки и default операции. Ссылки на правила перенесены в docs.

Семь остальных листингов сохранены без изменений относительно загруженного архива.

## Проверка

LMX сопоставлен с правилами docs: роли DATA/CODE, аргументы, связывание, лексический node и синтаксические границы. Для copy/merge учитываются поток результата и явная группировка. Ожидаемые результаты относятся к этой модели.

В исходной редакции сообщалось об исполнении Python, Java, C++ и TypeScript и статическом просмотре C#, Go и Rust. Их листинги сохранены без изменений; новых запусков эта редакция не заявляет. LMX-ядро здесь не запускалось.

Метрики пересчитываются непосредственно из восьми основных блоков исходника. Внешний вызов и тестовая обвязка не включены.

## Источники правил и примеров

- [Связывание](../LMX_semantics.en.md#binding-places), [структурный вызов](../LMX_semantics.en.md#structural-call) и необязательный самостоятельный [fn-контракт](../LMX_semantics.en.md#fn-signature).
- [Переданные объявления](../LMX_semantics.en.md#declaration-arguments) и [импорт корневых const-объявлений](../LMX_semantics.en.md#import-receiver).
- [Пустая строка как завершение корневого блока](../LMX_grammar.en.md#levels).

Ранее использованные сетевые образцы ролей шаблона сохранены как источники. Показанные программы — адаптации общего сценария, а не дословные копии или измерение длины этих страниц.

- [Refactoring.Guru — Strategy in Python: Conceptual Example](https://refactoring.guru/design-patterns/strategy/python/example)

