# 23. Interpreter: LMX и семь других языков

20 ноября 2026 года. Обновлено 21 ноября 2026 года. Продолжение серии: шаблоны 19–23.

## Задача

Сохранённое выражение `(x + 3) + x` вычисляется сначала при `x = 2`, затем при `x = 5`; два результата складываются. Используются число, одна переменная и операция сложения — грамматика `E := Number(n) | X | Add(E,E)`. Для этой задачи имя переменной `n` в LMX соответствует `x` в остальных программах.

**Внешний вызов LMX:** `Example\demo()`. **Ожидаемый результат: 20.**

В LMX структура выражения записана в `calculate` и хранится в обычном графе языка. Остальные программы явно собирают то же выражение из узлов или замыканий в `demo`. Сравнивается реализация этого сохранённого вычисления с двумя контекстами. Универсальный API построения произвольных деревьев во время выполнения этим коротким LMX-листингом не демонстрируется.

Значения и результаты помещаются в int32. В задачу не входят отдельный текстовый парсер, произвольные имена переменных и переполнение. Python, C++ и Go представляют узлы замыканиями; TypeScript — объектами с замкнутым методом `eval`. Java и C# используют объекты узлов, Rust — enum. Каждый вариант вычисляет внутреннюю сумму, затем внешнюю. Отдельный обход для печати или сериализации не требуется.

## Архитектура LMX

Метод `add` становится пользовательским операндом благодаря форме его DATA: ссылка `left`, массив ссылок `right` и обязательные постоянные поля `PASS_ARGS_AS_IS` и `PRIORITY`. Имя операции — имя метода. `import: operands` делает метод доступным в namespace; отдельная регистрация в `sys\operand` не нужна. [Контракт операндов, §§2–3][O]

Здесь `PASS_ARGS_AS_IS 0`: общий исполнитель expression сначала получает значения аргументов, затем передаёт ссылки на их типизированные места в `left` и `right`. `\left` и `\right[0]` читают эти значения. Для внешнего `add` левое значение — уже вычисленный результат внутреннего `add`. `return: int` объявляет обычный числовой результат; необходимое представление промежуточного результата обеспечивает общий механизм expression. `PRIORITY sys\priority("+")` задаёт тот же приоритет, что у встроенного сложения. [Подготовленные значения и обычный результат][O]

`PASS_ARGS_AS_IS 1` остаётся отдельным предусмотренным режимом: он передаёт исходные аргументные вхождения, а их явное вычисление выполняет `sys\eval`. В этом примере достаточно режима `0`. Разыменование `\` само по себе код не вызывает. Оба свойства обязательны — отсутствующее поле не получает неявного значения. [Два режима аргументов][O]

Python сохраняет композицию `(x + 3) + x` в замыкании `tree`; LMX сохраняет её в графе тела `calculate`. Два вызова меняют значение входа, сохраняя одну форму вычисления. Дополнительные `number`, `variable`, wrapper-структуры и копирование `merge` для этой записи не требуются.

DATA методов `calculate` и `demo` — `Example`; наличие `n` не обязывает `demo` читать его. Пустая строка между `operands` и `Example` закрывает первый корневой блок. [Связывание][B] · [Импорт][D] · [Границы блоков][E]

## Подсчёт исходников

Главная метрика — **непробельные символы**: `sum(not ch.isspace() for ch in code)`. Дополнительно показаны полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF в конце.

В подсчёт входят весь показанный исходник, импорты, необходимые языковые оболочки и `demo`. Внешний запуск, `main`, печать результата, тестовая обвязка и реализация стандартной библиотеки/runtime не включены. Имена не нормализованы. Python записан без необязательных аннотаций типов. Сравниваются конкретные реализации одной задачи; это не оценка быстродействия или одинаковых статических гарантий.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 232 | 346 | 17 | 1.00× |
| Python | 185 | 247 | 13 | 0.80× |
| Java | 406 | 540 | 23 | 1.75× |
| C++ | 312 | 404 | 21 | 1.34× |
| C# | 379 | 509 | 23 | 1.63× |
| TypeScript | 324 | 421 | 19 | 1.40× |
| Go | 286 | 381 | 21 | 1.23× |
| Rust | 340 | 502 | 24 | 1.47× |

Общая таблица этой пятёрки доступна в [Excel](LMX_Comparison_19-23.xlsx) и [PDF](LMX_Comparison_19-23.pdf).

## 1. LMX

```lmx
operands:
    @: left int
    []: @(int) right
    const: int: PASS_ARGS_AS_IS 0
    const: int: PRIORITY sys\priority("+")
    return: int
    add:
        return: \left + \right[0]

Example:
    int: n
    return: int
    calculate:
        import: operands
        return: (n add 3) add n
    demo:
        return: calculate(2) + calculate(5)
```

Внешний вызов: `Example\demo()`. Он не входит в подсчёт.

`calculate(2)` даёт `(2 + 3) + 2 = 7`, а `calculate(5)` — `(5 + 3) + 5 = 13`. Результат `demo` — `20`. Поле `n` передаётся обычным аргументом метода. В обоих вызовах используется одна записанная структура выражения; меняется контекст её вычисления.

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

В этой редакции повторно выполнен Python: `demo() == 20`, а одно сохранённое замыкание даёт `7` при аргументе `2` и `13` при аргументе `5`. LMX проверен статически по последней редакции контракта операндов; результаты `7`, `13` и `20` выведены по модели.

Для неизменённых листингов сохранён статус предыдущей редакции: Java, C++ и TypeScript — выполнение demo и проверок роли шаблона; TypeScript без отдельной проверки tsc. C#, Go и Rust — статическая проверка. Метрики заново получены из всех восьми листингов этого файла.

## Источники

Сетевые образцы использованы для проверки ролей шаблона. Показанные программы — самостоятельные адаптации общего сценария, а не подсчёт длины исходников этих страниц.

- [GoF — Interpreter, intent, grammar, participants and sample code (MIT-hosted text)](https://people.csail.mit.edu/addy/pattern/pat5c.htm)

[B]: reference/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md
[D]: reference/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md
[E]: reference/LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md

[O]: reference/to_fable_operands_arguments_priorities.md
