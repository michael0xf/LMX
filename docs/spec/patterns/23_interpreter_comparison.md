# 23. Interpreter: LMX и семь других языков

20 ноября 2026 года. Обновлено 21 ноября 2026 года. Продолжение серии: шаблоны 19–23.

## Задача

Сохранённое выражение `(x + 3) + x` вычисляется сначала при `x = 2`, затем при `x = 5`; два результата складываются. Используются число, одна переменная и операция сложения — грамматика `E := Number(n) | X | Add(E,E)`. Для этой задачи имя переменной `n` в LMX соответствует `x` в остальных программах.

**Внешний вызов LMX:** `operands\example\demo()`. **Ожидаемый результат: 20.**

В LMX структура выражения записана в `calculate` и хранится в обычном графе языка. Остальные программы явно собирают то же выражение из узлов или замыканий в `demo`. Сравнивается реализация этого сохранённого вычисления с двумя контекстами. Универсальный API построения произвольных деревьев во время выполнения этим коротким LMX-листингом не демонстрируется.

Значения и результаты помещаются в int32. В задачу не входят отдельный текстовый парсер, произвольные имена переменных и переполнение. Python, C++ и Go представляют узлы замыканиями; TypeScript — объектами с замкнутым методом `eval`. Java и C# используют объекты узлов, Rust — enum. Каждый вариант вычисляет внутреннюю сумму, затем внешнюю. Отдельный обход для печати или сериализации не требуется.

## Архитектура LMX

Метод `add` использует стандартный шаблон ядра `sys\OPERANDS_TEMPLATE`. Строка `copy: sys\OPERANDS_TEMPLATE` поставляет поля этого шаблона в namespace `operands`; исходная запись `copy` остаётся в графе. Шаблон содержит ссылку `left`, массив ссылок `right` и обязательные постоянные поля `PASS_ARGS_AS_IS` и `PRIORITY`. Его определение показано ниже отдельно и не считается прикладным кодом. Имя операции совпадает с именем метода; отдельная регистрация в `sys\operand` не нужна. [Контракт операндов](../LMX_semantics.en.md#operand-receiver) · [Потоки полей][S]

Здесь `PASS_ARGS_AS_IS 0`: общий исполнитель expression сначала получает значения аргументов, затем передаёт ссылки на их типизированные места в `left` и `right`. `\left` и `\right[0]` читают эти значения; `[0]` выбирает первый правый аргумент из массива. Для внешнего `add` левое значение — результат внутреннего `add`. Конкретный числовой результат метода описан строкой `return: int`. Шаблон использует обычное сложение как источник приоритета; внутри `sys` оно записано `priority("+")`.

Вложенная группа `example` видит `add` лексически, поэтому отдельный `import` не нужен. DATA методов `calculate` и `demo` — `example`; DATA самого `add` — `operands`. Поле `n` не обязывает `demo` его читать. Внутри единственного корневого объявления нет пустых строк, которые преждевременно завершили бы блок. [Связывание](../LMX_semantics.en.md#binding-places) · [Границы блоков](../LMX_grammar.en.md#levels)

Python сохраняет композицию `(x + 3) + x` в замыкании `tree`; LMX сохраняет её в графе тела `calculate`. Два вызова меняют вход, сохраняя одну форму вычисления. Режим `PASS_ARGS_AS_IS 1` с исходными аргументными вхождениями и явным `sys\eval` здесь не требуется. Разыменование `\` само по себе код не вызывает.

## Подсчёт исходников

Главная метрика — **непробельные символы**: `sum(not ch.isspace() for ch in code)`. Дополнительно показаны полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF в конце.

В подсчёт входят прикладной листинг каждого языка, его импорты, необходимые языковые оболочки и `demo`. В LMX учитывается и строка `copy: sys\OPERANDS_TEMPLATE`, но отдельно показанное определение шаблона ядра исключено, как исключены внутренние реализации стандартных библиотек других языков. Внешний запуск, `main`, печать результата, тестовая обвязка и реализация стандартной библиотеки/runtime не включены. Имена не нормализованы. Python записан без необязательных аннотаций типов. Сравниваются конкретные реализации одной задачи; это не оценка быстродействия или одинаковых статических гарантий.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 159 | 266 | 12 | 1.00× |
| Python | 185 | 247 | 13 | 1.16× |
| Java | 406 | 540 | 23 | 2.55× |
| C++ | 312 | 404 | 21 | 1.96× |
| C# | 379 | 509 | 23 | 2.38× |
| TypeScript | 324 | 421 | 19 | 2.04× |
| Go | 286 | 381 | 21 | 1.80× |
| Rust | 340 | 502 | 24 | 2.14× |

Общая таблица этой пятёрки доступна в [Excel](LMX_Comparison_19-23.xlsx) и [PDF](LMX_Comparison_19-23.pdf).

## 1. LMX

### Прикладной код — входит в подсчёт

<!-- counted-code: LMX -->
```lmx
operands:
    copy: sys\OPERANDS_TEMPLATE
    return: int
    add:
        return: \left + \right[0]
    example:
        int: n
        return: int
        calculate:
            return: (n add 3) add n
        demo:
            return: calculate(2) + calculate(5)
```

Внешний вызов: `operands\example\demo()`. Он не входит в подсчёт.

`calculate(2)` даёт `(2 + 3) + 2 = 7`, а `calculate(5)` — `(5 + 3) + 5 = 13`. Результат `demo` — `20`. В обоих вызовах используется одна записанная структура выражения; меняется контекст её вычисления.

### Шаблон ядра — показан для понимания, в подсчёт не входит

<!-- uncounted-code: kernel-reference -->
```lmx
sys:
    OPERANDS_TEMPLATE:
        @: left
        @[]: right
        const: int: PASS_ARGS_AS_IS 0
        const: int: PRIORITY priority("+")
```

Это предоставляемый ядром шаблон с общими ссылками, а не пользовательский помощник, вынесенный из листинга ради размера. Подсчёт сохраняет стоимость его использования — строку `copy` в прикладном коде. Точно так же в других языках учитывается написанный импорт, но не исходники импортированной стандартной библиотеки.

Шаблон не объявляет `return`: тип результата принадлежит конкретной операции. Поэтому `return: int` в `operands` задаётся один раз. Переиспользуется общий заголовок операнда; копирование не вводит правило замены одноимённых DATA-объявлений. [Результат вызова][R] · [Приём потоков][S]

## 2. Python

```python
def number(value):
    return lambda x: value

def variable():
    return lambda x: x

def add(left, right):
    return lambda x: left(x) + right(x)

def demo():
    v = variable()
    tree = add(add(v, number(3)), v)
    return tree(2) + tree(5)
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 3. Java

```java
interface Expr {
    int eval(int x);
}

record Number(int value) implements Expr {
    public int eval(int x) { return value; }
}

record Variable() implements Expr {
    public int eval(int x) { return x; }
}

record Add(Expr left, Expr right) implements Expr {
    public int eval(int x) { return left.eval(x) + right.eval(x); }
}

class Example {
    static int demo() {
        Expr variable = new Variable();
        Expr tree = new Add(new Add(variable, new Number(3)), variable);
        return tree.eval(2) + tree.eval(5);
    }
}
```

Внешний вызов: `Example.demo()`. Он не входит в подсчёт.

## 4. C++

```cpp
#include <functional>

using Expr = std::function<int(int)>;

Expr number(int value) {
    return [value](int) { return value; };
}

Expr variable() {
    return [](int x) { return x; };
}

Expr add(Expr left, Expr right) {
    return [left, right](int x) { return left(x) + right(x); };
}

int demo() {
    auto v = variable();
    auto tree = add(add(v, number(3)), v);
    return tree(2) + tree(5);
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 5. C#

```csharp
interface IExpr {
    int Eval(int x);
}

record Number(int Value) : IExpr {
    public int Eval(int x) => Value;
}

record Variable : IExpr {
    public int Eval(int x) => x;
}

record Add(IExpr Left, IExpr Right) : IExpr {
    public int Eval(int x) => Left.Eval(x) + Right.Eval(x);
}

static class Example {
    public static int Demo() {
        IExpr variable = new Variable();
        IExpr tree = new Add(new Add(variable, new Number(3)), variable);
        return tree.Eval(2) + tree.Eval(5);
    }
}
```

Внешний вызов: `Example.Demo()`. Он не входит в подсчёт.

## 6. TypeScript

```typescript
type Expr = { eval(x: number): number };

function number(value: number): Expr {
    return { eval: () => value };
}

function variable(): Expr {
    return { eval: x => x };
}

function add(left: Expr, right: Expr): Expr {
    return { eval: x => left.eval(x) + right.eval(x) };
}

function demo(): number {
    const v = variable();
    const tree = add(add(v, number(3)), v);
    return tree.eval(2) + tree.eval(5);
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 7. Go

```go
package main

type Expr func(int) int

func number(value int) Expr {
    return func(int) int { return value }
}

func variable() Expr {
    return func(x int) int { return x }
}

func add(left, right Expr) Expr {
    return func(x int) int { return left(x) + right(x) }
}

func demo() int {
    v := variable()
    tree := add(add(v, number(3)), v)
    return tree(2) + tree(5)
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 8. Rust

```rust
enum Expr {
    Number(i32),
    Variable,
    Add(Box<Expr>, Box<Expr>),
}

impl Expr {
    fn eval(&self, x: i32) -> i32 {
        match self {
            Self::Number(value) => *value,
            Self::Variable => x,
            Self::Add(left, right) => left.eval(x) + right.eval(x),
        }
    }
}

pub fn demo() -> i32 {
    use Expr::*;
    let tree = Add(
        Box::new(Add(Box::new(Variable), Box::new(Number(3)))),
        Box::new(Variable),
    );
    tree.eval(2) + tree.eval(5)
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## Проверка

В этой редакции проверены согласованность LMX-листинга с документами `docs`, явная группировка результатов копирования/композиции там, где нужен один объект, и ссылки на правила языка. Ожидаемый результат LMX следует из показанного сценария; запуск ядра не проводился.

Листинги Python, Java, C++, C#, TypeScript, Go и Rust сохранены из исходного сравнения. Сообщения исходной редакции об их выполнении относятся к той проверке; это обновление документации не выдаёт их за новый запуск. Подсчёт размеров выполняется заново по листингам текущего файла.

## Источники

Сетевые образцы использованы для проверки ролей шаблона. Показанные программы — самостоятельные адаптации общего сценария, а не подсчёт длины исходников этих страниц.

- [GoF — Interpreter, intent, grammar, participants and sample code (MIT-hosted text)](https://people.csail.mit.edu/addy/pattern/pat5c.htm)



[S]: ../LMX_semantics.en.md#merge-two-forms
[R]: ../LMX_semantics.en.md#return-in-data
