# 09. Visitor: LMX и семь других языков

20 ноября 2026 года · Редакция по Python-прототипу

## Задача и границы

Actions непосредственно содержит методы on_number/on_pair и demo. Они составляют тот контекст действий, который получает вызываемый accept; отдельные fn, Demo и копии-ссылки не нужны.

**Ожидаемый результат: 12.**

Два посещения с выбором действия по виду узла и доступному контексту. Оба обработчика NoAction сохранены. Хранение и рекурсивный обход произвольного дерева не включены.

## Архитектура LMX

Python отделяет Actions от NumberNode и PairNode. В LMX этому соответствуют Actions и два узла в Nodes. Методы действий уже доступны в контексте demo; дополнительные копии-ссылки и переименование полей узлов не нужны.

Структура задаёт общий DATA связанных методов. Метод обращается к нужным ему полям; отдельная оболочка для demo из-за остальных полей не требуется. Обычная ссылка `@: name method` не вызывает method и не требует самостоятельного `fn`. Программа по-прежнему использует типы объявленных полей и правила конкретных вызовов. [Связывание и ссылки][B]

Пустая строка завершает корневой синтаксический блок. Внутренний `---` сохраняется там, где нужно продолжить внешнюю структуру. `node\` выбирает лексическую связь, а не переход к parent. [Границы блоков][E]

## Подсчёт исходников

Главная метрика — **число непробельных символов**: `sum(not ch.isspace() for ch in code)`. Пробельные символы исключаются только из измерения; исходник сохраняет необходимое форматирование. Также приведены полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF после последней строки.

Считается весь показанный листинг: объявления, импорты, необходимые языковые оболочки, методы и демонстрация. Внешний вызов, main, печать, тестовый harness, Markdown и реализация runtime/стандартной библиотеки не входят. Имена не нормализованы. Python записан без необязательных аннотаций; одинаковые статические гарантии не заявляются. Таблица измеряет эти программы, а не теоретический минимум для каждого языка.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 414 | 727 | 36 | 1.00× |
| Python | 482 | 673 | 33 | 1.16× |
| Java | 717 | 1080 | 42 | 1.73× |
| C++ | 627 | 883 | 43 | 1.51× |
| C# | 597 | 957 | 41 | 1.44× |
| TypeScript | 619 | 881 | 40 | 1.50× |
| Go | 716 | 991 | 49 | 1.73× |
| Rust | 713 | 965 | 43 | 1.72× |

Отношение больше 1 означает более длинный листинг по непробельным символам.

## 1. LMX

```lmx
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
            return: on_number()
    ---
    Pair:
        int: left 4
        int: right 5
        return: int
        accept:
            throws: NoAction
            return: on_pair()

Actions:
    return: int
    on_number:
        return: value
    on_pair:
        return: left + right
    demo:
        int: result 0
        result := Nodes\Number\accept()
        result += Nodes\Pair\accept()
        catch: NoAction ()
            result := -1
        return: result
```

Внешний вызов: `Actions\demo()`. Он не входит в подсчёт.

Структурные/методные имена on_number и on_pair доступны в namespace Actions\demo при открытии. Свободное имя обработчика у accept сначала получает значение из доступного caller-context; Nodes fallback остаётся ниже по приоритету. Примитивные value/left/right являются объявленными входами DATA Number/Pair, поэтому обработчик получает их из контекста accept без дополнительных n/a/b. Записи в них не производятся. При удалении Actions\on_pair доступен Nodes\on_pair, который выдаёт NoAction; catch устанавливает -1.

Number передаёт через текущий контекст value = 3; Pair — left = 4 и right = 5. Обработчики возвращают 3 и 9. Если убрать Actions.on_pair, будет выбран Nodes.on_pair, возникнет NoAction и demo вернёт −1.

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

Внешний вызов: `demo()`. Он не входит в подсчёт.

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

Внешний вызов: `Example.demo()`. Он не входит в подсчёт.

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

Внешний вызов: `demo()`. Он не входит в подсчёт.

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

Внешний вызов: `Example.Demo()`. Он не входит в подсчёт.

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

Внешний вызов: `demo()`. Он не входит в подсчёт.

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

Внешний вызов: `demo()`. Он не входит в подсчёт.

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

Внешний вызов: `demo()`. Он не входит в подсчёт.

## Что изменилось

LMX: **546 → 414 непробельных символов** относительно предыдущей согласованной редакции. Убрана обвязка, не нужная показанному сценарию: отдельные демонстрационные структуры, повторные описания сигнатур, промежуточные ссылки или перекладывание значений. Это изменение исходников; скорость исполнения не измерялась.

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

- [Refactoring.Guru — Visitor](https://refactoring.guru/design-patterns/visitor)
- [Refactoring.Guru — Visitor in Go, conceptual example](https://refactoring.guru/design-patterns/visitor/go/example)

[B]: reference/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md
[D]: reference/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md
[E]: reference/LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md
