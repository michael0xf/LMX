# 18. Bridge: LMX и семь других языков

20 ноября 2026 года. Обновлено 21 ноября 2026 года. Продолжение серии: шаблоны 10–18.

## Задача

Числовая модель управления устройством. basic передаёт level как есть; boost увеличивает его на 1. Реализация radio возвращает 2 × level, speaker — 3 × level. Ссылки control и output выбираются независимо; demo выполняет все четыре сочетания.

**Внешний вызов LMX:** `bridge\demo()`. **Ожидаемый результат: 45.**

Это функциональная запись Bridge: независимые семейства абстракций и реализаций выражены функциями, а не обязательными иерархиями классов. Обе оси показаны в demo; пример не сводится к единственной функции с одной заменяемой стратегией. Возвращаемые числа моделируют действие устройства, реальных драйверов здесь нет.

## Архитектура LMX

Python передаёт output явно в basic и boost. В LMX оба метода получают его через объявленное неинициализированное поле @: output общего DATA. Когда output() вызывает реализацию, level передаётся автоматически. boost меняет только собственный level; исходное значение demo не изменяется. Две переменные demo независимо выбирают высокоуровневый режим и низкоуровневую реализацию.

Применены согласованные правила: DATA метода — его фактический parent; обычные ссылки на методы не требуют отдельного `fn`; объявленные входы без initializer допускают autofill, свободные имена — связь с местом непосредственного caller. `node\` выбирает лексическую связь. Пустая строка завершает корневой блок. [Связывание](../LMX_semantics.en.md#binding-places) · [Импорт][D] · [Границы блоков][E]

## Подсчёт исходников

Главная метрика — **непробельные символы**: `sum(not ch.isspace() for ch in code)`. Дополнительно показаны полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF в конце.

В подсчёт входят весь показанный исходник, импорты, необходимые языковые оболочки и `demo`. Внешний запуск, `main`, печать результата, тестовая обвязка и реализация стандартной библиотеки/runtime не включены. Имена не нормализованы. Python записан без необязательных аннотаций типов. Сравниваются конкретные реализации одной задачи; это не оценка быстродействия или одинаковых статических гарантий.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 276 | 475 | 23 | 1.00× |
| Python | 320 | 434 | 22 | 1.16× |
| Java | 645 | 908 | 35 | 2.34× |
| C++ | 399 | 538 | 29 | 1.45× |
| C# | 487 | 732 | 31 | 1.76× |
| TypeScript | 490 | 637 | 29 | 1.78× |
| Go | 413 | 556 | 31 | 1.50× |
| Rust | 425 | 579 | 29 | 1.54× |

Общая таблица серии доступна в [Excel](LMX_Comparison_10-18.xlsx) и [PDF](LMX_Comparison_10-18.pdf).

## 1. LMX

```lmx
bridge:
    int: level
    @: output
    return: int
    radio:
        return: level * 2
    speaker:
        return: level * 3
    basic:
        return: output()
    boost:
        level += 1
        return: output()
    demo:
        @: control basic
        @: output radio
        int: total control(4)
        output := speaker
        total += control(4)
        control := boost
        total += control(4)
        output := radio
        return: total + control(4)
```

Внешний вызов: `bridge\demo()`. Он не входит в подсчёт.

При level = 4 basic/radio даёт 8, basic/speaker — 12, boost/speaker — 15, boost/radio — 10. Сумма 45. Переключение output не требует менять control; переключение control не требует менять output.

## 2. Python

```python
def radio(level):
    return level * 2

def speaker(level):
    return level * 3

def basic(level, output):
    return output(level)

def boost(level, output):
    return output(level + 1)

def demo():
    control = basic
    output = radio
    total = control(4, output)
    output = speaker
    total += control(4, output)
    control = boost
    total += control(4, output)
    output = radio
    return total + control(4, output)
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 3. Java

```java
import java.util.function.IntUnaryOperator;

class Example {
    interface Control {
        int apply(int level, IntUnaryOperator output);
    }

    static int radio(int level) {
        return level * 2;
    }

    static int speaker(int level) {
        return level * 3;
    }

    static int basic(int level, IntUnaryOperator output) {
        return output.applyAsInt(level);
    }

    static int boost(int level, IntUnaryOperator output) {
        return output.applyAsInt(level + 1);
    }

    static int demo() {
        Control control = Example::basic;
        IntUnaryOperator output = Example::radio;
        int total = control.apply(4, output);
        output = Example::speaker;
        total += control.apply(4, output);
        control = Example::boost;
        total += control.apply(4, output);
        output = Example::radio;
        return total + control.apply(4, output);
    }
}
```

Внешний вызов: `Example.demo()`. Он не входит в подсчёт.

## 4. C++

```cpp
using Output = int (*)(int);

int radio(int level) {
    return level * 2;
}

int speaker(int level) {
    return level * 3;
}

int basic(int level, Output output) {
    return output(level);
}

int boost(int level, Output output) {
    return output(level + 1);
}

int demo() {
    auto control = basic;
    Output output = radio;
    int total = control(4, output);
    output = speaker;
    total += control(4, output);
    control = boost;
    total += control(4, output);
    output = radio;
    return total + control(4, output);
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 5. C#

```csharp
using System;

static class Example {
    static int Radio(int level) {
        return level * 2;
    }

    static int Speaker(int level) {
        return level * 3;
    }

    static int Basic(int level, Func<int, int> output) {
        return output(level);
    }

    static int Boost(int level, Func<int, int> output) {
        return output(level + 1);
    }

    public static int Demo() {
        Func<int, Func<int, int>, int> control = Basic;
        Func<int, int> output = Radio;
        int total = control(4, output);
        output = Speaker;
        total += control(4, output);
        control = Boost;
        total += control(4, output);
        output = Radio;
        return total + control(4, output);
    }
}
```

Внешний вызов: `Example.Demo()`. Он не входит в подсчёт.

## 6. TypeScript

```typescript
type Output = (level: number) => number;

function radio(level: number): number {
    return level * 2;
}

function speaker(level: number): number {
    return level * 3;
}

function basic(level: number, output: Output): number {
    return output(level);
}

function boost(level: number, output: Output): number {
    return output(level + 1);
}

function demo(): number {
    let control = basic;
    let output: Output = radio;
    let total = control(4, output);
    output = speaker;
    total += control(4, output);
    control = boost;
    total += control(4, output);
    output = radio;
    return total + control(4, output);
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 7. Go

```go
package main

type Output func(int) int

func radio(level int) int {
    return level * 2
}

func speaker(level int) int {
    return level * 3
}

func basic(level int, output Output) int {
    return output(level)
}

func boost(level int, output Output) int {
    return output(level + 1)
}

func demo() int {
    control := basic
    output := Output(radio)
    total := control(4, output)
    output = speaker
    total += control(4, output)
    control = boost
    total += control(4, output)
    output = radio
    return total + control(4, output)
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 8. Rust

```rust
type Output = fn(i32) -> i32;

fn radio(level: i32) -> i32 {
    level * 2
}

fn speaker(level: i32) -> i32 {
    level * 3
}

fn basic(level: i32, output: Output) -> i32 {
    output(level)
}

fn boost(level: i32, output: Output) -> i32 {
    output(level + 1)
}

pub fn demo() -> i32 {
    let mut control: fn(i32, Output) -> i32 = basic;
    let mut output: Output = radio;
    let mut total = control(4, output);
    output = speaker;
    total += control(4, output);
    control = boost;
    total += control(4, output);
    output = radio;
    total + control(4, output)
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## Проверка

В этой редакции проверены согласованность LMX-листинга с документами `docs`, явная группировка результатов копирования/композиции там, где нужен один объект, и ссылки на правила языка. Ожидаемый результат LMX следует из показанного сценария; запуск ядра не проводился.

Листинги Python, Java, C++, C#, TypeScript, Go и Rust сохранены из исходного сравнения. Сообщения исходной редакции об их выполнении относятся к той проверке; это обновление документации не выдаёт их за новый запуск. Подсчёт размеров выполняется заново по листингам текущего файла.

## Источники

Сетевые образцы использованы для проверки ролей шаблона. Показанные программы — самостоятельные адаптации общего сценария, а не подсчёт длины исходников этих страниц.

- [Refactoring.Guru — Bridge in Python, conceptual example](https://refactoring.guru/design-patterns/bridge/python/example)

[D]: ../tasks/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md
[E]: ../tasks/LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md
