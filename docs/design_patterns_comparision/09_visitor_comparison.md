# 09. Visitor: сравнение исходников LMX и семи других языков

20 ноября 2026 года · Один сценарий, восемь реализаций

## Задача и границы примера

Узел Number хранит 3, узел Pair — 4 и 5. Каждый accept выбирает соответствующий обработчик; действия возвращают число или сумму пары. Драйвер складывает результаты: 12. При отсутствии нужного действия работает NoAction и результат драйвера становится -1.

**Ожидаемый результат демонстрации: `12`.**

Два вида узлов и сменяемый набор действий. Сохраняются два шага: узел выбирает действие своего вида, затем вызывается переданный обработчик. Дерево не обходится рекурсивно. В LMX значения n/a/b приходят скрытым связыванием; аналоги передают их явно. Динамический набор callback здесь выполняет роль visitor без обязательной иерархии классов Visitor. В Go и Rust явная ошибка здесь относится к отсутствию обработчика. Сами обработчики возвращают обычное число; произвольные ошибки действий этот небольшой интерфейс не моделирует.

LMX взят без изменений из [согласованной русской подборки примеров](https://chatgpt.com/library?file_id=libfile_fde3_f-e112f68f2f20819185805436a1f1f225_bbe92b09b62881918d17958175103ded&account_id=personal). Для остальных языков найдены сетевые образцы по названию шаблона; на их основе написаны сопоставимые реализации именно этого сценария. Это оригинальная адаптация, а не дословная копия кода сайта и не измерение длины его полного учебного листинга. Источники приведены в конце.

## Как считались символы

Главная величина — **число непробельных символов** в показанном блоке исходника: все символы, для которых Python `str.isspace()` возвращает false. Пробелы, табуляции и переводы строк не учитываются. Это счётчик, а не преобразование кода в исполняемый минифицированный вариант; пробельные символы внутри строк также не считаются.

Дополнительно показаны полный размер в символах Unicode и число физических строк. Для полного размера используется LF, без начальных и конечных пустых строк и с одним LF в конце. Здесь все исходники ASCII, поэтому при UTF-8 число байтов совпадает с полным числом символов.

Считаются объявления, импорты, обязательные классы-оболочки или `package`, вспомогательные функции и весь демонстрационный сценарий внутри `demo` / `Demo` / LMX `run`. Внешний запуск, `main`, печать результата, тестовый harness, Markdown и пояснения не входят. Реализация стандартной библиотеки и runtime не входит ни для одного языка. В измеряемом коде нет комментариев.

Обычные функции, замыкания и стандартные типы callable разрешены. Python приведён без необязательных аннотаций типов; это не равенство статических гарантий с LMX или другими типизированными вариантами. Имена и учебная разбивка не нормализованы: числа описывают эти конкретные листинги, а не минимально возможную длину программы на языке.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 589 | 994 | 47 | 1.00× |
| Python | 482 | 673 | 33 | 0.82× |
| Java | 717 | 1080 | 42 | 1.22× |
| C++ | 627 | 883 | 43 | 1.06× |
| C# | 597 | 957 | 41 | 1.01× |
| TypeScript | 619 | 881 | 40 | 1.05× |
| Go | 716 | 991 | 49 | 1.22× |
| Rust | 713 | 965 | 43 | 1.21× |

Отношение больше 1 означает, что этот листинг длиннее показанного LMX по непробельным символам.

## 1. LMX

```lmx
fn: ActionSignature (return: int)
Nodes:
    return: int
    on_number:
        throws: NoAction
        throw: NoAction()
    on_pair:
        throws: NoAction
        throw: NoAction()
    Number:
        int: value 3
        return: int
        accept:
            throws: NoAction
            int: n value
            return: on_number()
    end: Number
    Pair:
        int: left 4
        int: right 5
        return: int
        accept:
            throws: NoAction
            int: a left
            int: b right
            return: on_pair()
    end: Pair
end: Nodes
Actions:
    return: int
    number:
        return: n
    pair:
        return: a + b
end: Actions
Demo:
    return: int
    run:
        @: on_number ActionSignature Actions\number
        @: on_pair ActionSignature Actions\pair
        int: result 0
        result := Nodes\Number\accept()
        result += Nodes\Pair\accept()
        catch: NoAction ()
            result := -1
        return: result
end: Demo
```

Вызов из исполняемого контекста: `Demo\run()`. Сам этот внешний вызов не входит в подсчёт.

Считаются последние согласованные правила `fn`, структурных требований, связывания и `import` из исходной подборки.

## 2. Python

```python
class NoAction(Exception):
    pass

class Actions:
    def on_number(self, n):
        raise NoAction()

    def on_pair(self, a, b):
        raise NoAction()

class NumberNode:
    value = 3

    def accept(self, actions):
        return actions.on_number(self.value)

class PairNode:
    left = 4
    right = 5

    def accept(self, actions):
        return actions.on_pair(self.left, self.right)

def demo():
    actions = Actions()
    actions.on_number = lambda n: n
    actions.on_pair = lambda a, b: a + b
    try:
        result = NumberNode().accept(actions)
        result += PairNode().accept(actions)
    except NoAction:
        result = -1
    return result
```

Внешний вызов: `demo()`.

Методы по умолчанию сообщают NoAction. Драйвер подставляет функции в экземпляр Actions; явные параметры заменяют скрытое связывание n/a/b.

## 3. Java

```java
import java.util.function.IntUnaryOperator;
import java.util.function.IntBinaryOperator;

class Example {
    static class NoAction extends RuntimeException {}

    static class Actions {
        IntUnaryOperator onNumber = n -> { throw new NoAction(); };
        IntBinaryOperator onPair = (a, b) -> { throw new NoAction(); };
    }

    static class NumberNode {
        int value = 3;

        int accept(Actions actions) {
            return actions.onNumber.applyAsInt(value);
        }
    }

    static class PairNode {
        int left = 4;
        int right = 5;

        int accept(Actions actions) {
            return actions.onPair.applyAsInt(left, right);
        }
    }

    public static int demo() {
        Actions actions = new Actions();
        actions.onNumber = n -> n;
        actions.onPair = (a, b) -> a + b;
        int result;
        try {
            result = new NumberNode().accept(actions);
            result += new PairNode().accept(actions);
        } catch (NoAction error) {
            result = -1;
        }
        return result;
    }
}
```

Внешний вызов: `Example.demo()`.

Набор типизированных callback заменяет отдельные классы конкретных visitor. Оба accept сохраняются; отсутствующее действие вызывает отдельное исключение.

## 4. C++

```cpp
#include <functional>

struct NoAction {};

struct Actions {
    std::function<int(int)> onNumber = [](int) -> int {
        throw NoAction{};
    };
    std::function<int(int, int)> onPair = [](int, int) -> int {
        throw NoAction{};
    };
};

struct NumberNode {
    int value = 3;

    int accept(const Actions& actions) const {
        return actions.onNumber(value);
    }
};

struct PairNode {
    int left = 4;
    int right = 5;

    int accept(const Actions& actions) const {
        return actions.onPair(left, right);
    }
};

int demo() {
    Actions actions;
    actions.onNumber = [](int n) { return n; };
    actions.onPair = [](int a, int b) { return a + b; };
    int result;
    try {
        result = NumberNode{}.accept(actions);
        result += PairNode{}.accept(actions);
    } catch (const NoAction&) {
        result = -1;
    }
    return result;
}
```

Внешний вызов: `demo()`.

std::function хранит сменяемые обработчики. У двух видов узлов свои accept, выбирающие соответствующий callback; оба вида в демонстрации вызываются напрямую, как и в LMX.

## 5. C#

```csharp
using System;

static class Example {
    class NoAction : Exception {}

    class Actions {
        public Func<int, int> OnNumber = n => throw new NoAction();
        public Func<int, int, int> OnPair = (a, b) => throw new NoAction();
    }

    class NumberNode {
        int value = 3;

        public int Accept(Actions actions) {
            return actions.OnNumber(value);
        }
    }

    class PairNode {
        int left = 4;
        int right = 5;

        public int Accept(Actions actions) {
            return actions.OnPair(left, right);
        }
    }

    public static int Demo() {
        var actions = new Actions();
        actions.OnNumber = n => n;
        actions.OnPair = (a, b) => a + b;
        int result;
        try {
            result = new NumberNode().Accept(actions);
            result += new PairNode().Accept(actions);
        } catch (NoAction) {
            result = -1;
        }
        return result;
    }
}
```

Внешний вызов: `Example.Demo()`.

Func задаёт контракты обработчиков, а каждый Accept явно выбирает нужный. Обработчики по умолчанию бросают NoAction.

## 6. TypeScript

```typescript
class NoAction extends Error {}

type Actions = {
    onNumber?: (n: number) => number;
    onPair?: (a: number, b: number) => number;
};

class NumberNode {
    value = 3;

    accept(actions: Actions): number {
        if (!actions.onNumber) throw new NoAction();
        return actions.onNumber(this.value);
    }
}

class PairNode {
    left = 4;
    right = 5;

    accept(actions: Actions): number {
        if (!actions.onPair) throw new NoAction();
        return actions.onPair(this.left, this.right);
    }
}

function demo(): number {
    const actions: Actions = {
        onNumber: n => n,
        onPair: (a, b) => a + b
    };
    try {
        let result = new NumberNode().accept(actions);
        result += new PairNode().accept(actions);
        return result;
    } catch (error) {
        if (error instanceof NoAction) return -1;
        throw error;
    }
}
```

Внешний вызов: `demo()`.

Отсутствующий optional-handler вызывает NoAction. Перехватывается только этот выход; другие ошибки не превращаются молча в -1.

## 7. Go

```go
package main

import "errors"

var noAction = errors.New("NoAction")

type Actions struct {
    onNumber func(int) int
    onPair func(int, int) int
}

type NumberNode struct {
    value int
}

func (node NumberNode) accept(actions Actions) (int, error) {
    if actions.onNumber == nil {
        return 0, noAction
    }
    return actions.onNumber(node.value), nil
}

type PairNode struct {
    left int
    right int
}

func (node PairNode) accept(actions Actions) (int, error) {
    if actions.onPair == nil {
        return 0, noAction
    }
    return actions.onPair(node.left, node.right), nil
}

func demo() int {
    actions := Actions{
        onNumber: func(n int) int { return n },
        onPair: func(a, b int) int { return a + b },
    }
    first, err := (NumberNode{value: 3}).accept(actions)
    if err != nil {
        return -1
    }
    second, err := (PairNode{left: 4, right: 5}).accept(actions)
    if err != nil {
        return -1
    }
    return first + second
}
```

Внешний вызов: `demo()`.

Отсутствие callback выражается nil, NoAction возвращается как error. Это обычный возврат ошибки вместо исключения; в данной реализации accept может вернуть только noAction.

## 8. Rust

```rust
struct NoAction;

#[derive(Default)]
struct Actions {
    on_number: Option<fn(i32) -> i32>,
    on_pair: Option<fn(i32, i32) -> i32>,
}

struct NumberNode {
    value: i32,
}

impl NumberNode {
    fn accept(&self, actions: &Actions) -> Result<i32, NoAction> {
        let action = actions.on_number.ok_or(NoAction)?;
        Ok(action(self.value))
    }
}

struct PairNode {
    left: i32,
    right: i32,
}

impl PairNode {
    fn accept(&self, actions: &Actions) -> Result<i32, NoAction> {
        let action = actions.on_pair.ok_or(NoAction)?;
        Ok(action(self.left, self.right))
    }
}

pub fn demo() -> i32 {
    let actions = Actions {
        on_number: Some(|n| n),
        on_pair: Some(|a, b| a + b),
    };
    let result = (|| {
        let first = NumberNode { value: 3 }.accept(&actions)?;
        let second = PairNode { left: 4, right: 5 }.accept(&actions)?;
        Ok::<i32, NoAction>(first + second)
    })();
    result.unwrap_or(-1)
}
```

Внешний вызов: `demo()`.

Отсутствие действия — None, выход NoAction — Result::Err. Указателей fn достаточно для показанных обработчиков без захвата; Result сохраняет переход к -1 при отсутствии любого действия.

## Проверка и воспроизводимость

Python, Java, C++ и TypeScript исполнены: два последовательных вызова входа дали `12` и `12`. Java проверена OpenJDK 21; C++ — g++ в режиме C++17; TypeScript — Node.js 24 с удалением типов перед исполнением. Для TypeScript это проверка выполнения, а не отдельный прогон `tsc --strict`. C#, Go и Rust прошли статическое ревью; их компиляторы в среде отсутствуют. LMX проверен по документам, без запуска ядра.

Смысловые свойства, сохранённые в демонстрации (кроме запуска входа, проверены чтением кода):

- demo возвращает 3 + (4 + 5) = 12.
- Удаление или неподстановка любого обработчика должно приводить к NoAction и результату -1, не к 0 или аварийному завершению.
- NumberNode и PairNode выбирают разные обработчики; в их accept нет арифметики конкретной операции.
- Другой набор обработчиков можно подставить без изменения кода узлов.

Подсчёт воспроизводится непосредственно по восьми блокам исходников выше: `sum(not ch.isspace() for ch in code)` для основной колонки и `len(code)` для полной. Перед подсчётом применяется описанная нормализация перевода строк.

## Найденные сетевые образцы

1. [Refactoring.Guru — Visitor](https://refactoring.guru/design-patterns/visitor). Разделение узлов и операций, accept и выбор обработчика по виду узла.

2. [Refactoring.Guru — Visitor in Go, conceptual example](https://refactoring.guru/design-patterns/visitor/go/example). Проверены отдельные accept у разных фигур и внешний набор действий. Наш пример написан заново для Number/Pair с обязательным NoAction fallback.

Из сетевых материалов взяты ориентиры по ролям участников и взаимодействию. Имена, арифметика, объём поведения и код адаптированы к общему LMX-сценарию. Сравнение не переносит в маленький пример дополнительные функции исходного учебного проекта.
