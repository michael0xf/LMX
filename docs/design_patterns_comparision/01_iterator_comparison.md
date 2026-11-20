# 01. Iterator: сравнение исходников LMX и семи других языков

20 ноября 2026 года · Один сценарий, восемь реализаций

## Задача и границы примера

Получать числа 1, 2, 3 через next, выполнять пользовательское тело для каждого числа, удваивать item и складывать его в локальный total. Конец обхода не кодируется числом 0.

**Ожидаемый результат демонстрации: `12`.**

Сохранены отдельный объект с позицией обхода, пользовательская iterate и передаваемое тело. Это сравнение одинакового небольшого сценария, а не количества текста полного стандартного Iterator API. В LMX тело получает item и total через связывание контекста; в остальных вариантах item передаётся явно, total захватывается замыканием. Go и Rust вместо исключения используют явный признак завершения; тело тоже может досрочно закончить обход.

LMX взят без изменений из [согласованной русской подборки примеров](https://chatgpt.com/library?file_id=libfile_fde3_f-e112f68f2f20819185805436a1f1f225_bbe92b09b62881918d17958175103ded&account_id=personal). Для остальных языков найдены сетевые образцы по названию шаблона; на их основе написаны сопоставимые реализации именно этого сценария. Это оригинальная адаптация, а не дословная копия кода сайта и не измерение длины его полного учебного листинга. Источники приведены в конце.

## Как считались символы

Главная величина — **число непробельных символов** в показанном блоке исходника: все символы, для которых Python `str.isspace()` возвращает false. Пробелы, табуляции и переводы строк не учитываются. Это счётчик, а не преобразование кода в исполняемый минифицированный вариант; пробельные символы внутри строк также не считаются.

Дополнительно показаны полный размер в символах Unicode и число физических строк. Для полного размера используется LF, без начальных и конечных пустых строк и с одним LF в конце. Здесь все исходники ASCII, поэтому при UTF-8 число байтов совпадает с полным числом символов.

Считаются объявления, импорты, обязательные классы-оболочки или `package`, вспомогательные функции и весь демонстрационный сценарий внутри `demo` / `Demo` / LMX `run`. Внешний запуск, `main`, печать результата, тестовый harness, Markdown и пояснения не входят. Реализация стандартной библиотеки и runtime не входит ни для одного языка. В измеряемом коде нет комментариев.

Обычные функции, замыкания и стандартные типы callable разрешены. Python приведён без необязательных аннотаций типов; это не равенство статических гарантий с LMX или другими типизированными вариантами. Имена и учебная разбивка не нормализованы: числа описывают эти конкретные листинги, а не минимально возможную длину программы на языке.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 344 | 602 | 33 | 1.00× |
| Python | 363 | 579 | 33 | 1.06× |
| Java | 524 | 858 | 36 | 1.52× |
| C++ | 375 | 595 | 34 | 1.09× |
| C# | 389 | 731 | 36 | 1.13× |
| TypeScript | 413 | 687 | 35 | 1.20× |
| Go | 391 | 592 | 33 | 1.14× |
| Rust | 424 | 665 | 33 | 1.23× |

Отношение больше 1 означает, что этот листинг длиннее показанного LMX по непробельным символам.

## 1. LMX

```lmx
numbers:
    int: position 0
    return: int
    next:
        throws: Stop
        if: numbers\position >= 3
            throw: Stop()
        numbers\position += 1
        return: numbers\position
end: numbers

cycles:
    @: iteration
    @: body
    iterate:
        while: 1
            iteration()
            catch: Stop ()
                break
            body()
end: cycles

use:
    import: cycles
    int: total 0
    return: int
    run:
        numbers\position := 0
        iterate: int: item numbers\next()
            item *= 2
            total += item
        return: total
end: use
```

Вызов из исполняемого контекста: `use\run()`. Сам этот внешний вызов не входит в подсчёт.

Считаются последние согласованные правила `fn`, структурных требований, связывания и `import` из исходной подборки.

## 2. Python

```python
class Numbers:
    def __init__(self):
        self.position = 0

    def __iter__(self):
        return self

    def __next__(self):
        if self.position >= 3:
            raise StopIteration
        self.position += 1
        return self.position


def iterate(iteration, body):
    while True:
        try:
            body(next(iteration))
        except StopIteration:
            return


def demo():
    numbers = Numbers()
    total = 0

    def body(item):
        nonlocal total
        item *= 2
        total += item

    iterate(numbers, body)
    return total
```

Внешний вызов: `demo()`.

Стандартное соглашение __next__/StopIteration; nonlocal открывает запись в локальный аккумулятор внешнего вызова. Для каждого demo создаётся свежий объект с position = 0.

## 3. Java

```java
import java.util.NoSuchElementException;
import java.util.function.IntConsumer;
import java.util.function.IntSupplier;

class Example {
    static class Numbers {
        int position;

        int next() {
            if (position >= 3) {
                throw new NoSuchElementException();
            }
            return ++position;
        }
    }

    static void iterate(IntSupplier iteration, IntConsumer body) {
        while (true) {
            try {
                body.accept(iteration.getAsInt());
            } catch (NoSuchElementException stop) {
                return;
            }
        }
    }

    public static int demo() {
        Numbers numbers = new Numbers();
        int[] total = {0};
        iterate(numbers::next, item -> {
            item *= 2;
            total[0] += item;
        });
        return total[0];
    }
}
```

Внешний вызов: `Example.demo()`.

IntSupplier представляет next без дополнительного hasNext. Изменяемое значение total помещено в одноэлементный массив: захваченную локальную переменную Java нельзя переназначать внутри лямбды.

## 4. C++

```cpp
#include <functional>

struct Stop {};

struct Numbers {
    int position = 0;

    int next() {
        if (position >= 3) {
            throw Stop{};
        }
        return ++position;
    }
};

void iterate(std::function<int()> iteration, std::function<void(int)> body) {
    while (true) {
        try {
            body(iteration());
        } catch (const Stop&) {
            return;
        }
    }
}

int demo() {
    Numbers numbers;
    int total = 0;
    iterate([&] { return numbers.next(); }, [&](int item) {
        item *= 2;
        total += item;
    });
    return total;
}
```

Внешний вызов: `demo()`.

Лямбды явно захватывают локальные объекты по ссылке. std::function оставляет iteration и body заменяемыми во время выполнения. Это next-протокол данного примера, а не STL-пара begin/end.

## 5. C#

```csharp
using System;

static class Example {
    sealed class Stop : Exception {}

    sealed class Numbers {
        int position;

        public int Next() {
            if (position >= 3) {
                throw new Stop();
            }
            return ++position;
        }
    }

    static void Iterate(Func<int> iteration, Action<int> body) {
        while (true) {
            try {
                body(iteration());
            } catch (Stop) {
                return;
            }
        }
    }

    public static int Demo() {
        var numbers = new Numbers();
        int total = 0;
        Iterate(numbers.Next, item => {
            item *= 2;
            total += item;
        });
        return total;
    }
}
```

Внешний вызов: `Example.Demo()`.

Делегаты Func/Action сохраняют два заменяемых действия. Лямбда может непосредственно изменять захваченный total. Собственный Stop соответствует именованному выходу LMX.

## 6. TypeScript

```typescript
class Stop extends Error {}

class Numbers {
    position = 0;

    next(): number {
        if (this.position >= 3) {
            throw new Stop();
        }
        return ++this.position;
    }
}

function iterate(iteration: () => number, body: (item: number) => void): void {
    while (true) {
        try {
            body(iteration());
        } catch (error) {
            if (error instanceof Stop) {
                return;
            }
            throw error;
        }
    }
}

function demo(): number {
    const numbers = new Numbers();
    let total = 0;
    iterate(() => numbers.next(), item => {
        item *= 2;
        total += item;
    });
    return total;
}
```

Внешний вызов: `demo()`.

Замыкание связывает numbers с next и открывает запись в total. Обработчик пропускает наружу ошибки, отличные от Stop; конструкция IteratorResult здесь не требуется.

## 7. Go

```go
package main

type Numbers struct {
    position int
}

func (numbers *Numbers) next() (int, bool) {
    if numbers.position >= 3 {
        return 0, false
    }
    numbers.position++
    return numbers.position, true
}

func iterate(iteration func() (int, bool), body func(int) bool) {
    for {
        item, ok := iteration()
        if !ok || !body(item) {
            return
        }
    }
}

func demo() int {
    numbers := Numbers{}
    total := 0
    iterate(numbers.next, func(item int) bool {
        item *= 2
        total += item
        return true
    })
    return total
}
```

Внешний вызов: `demo()`.

Пара (значение, ok) отделяет конец обхода от значения 0. Возвращаемый body bool позволяет прекратить цикл из тела, как Stop в исходном LMX. Обе функции захватывают локальное состояние.

## 8. Rust

```rust
struct Numbers {
    position: i32,
}

impl Numbers {
    fn next(&mut self) -> Option<i32> {
        if self.position >= 3 {
            return None;
        }
        self.position += 1;
        Some(self.position)
    }
}

fn iterate(mut iteration: impl FnMut() -> Option<i32>,
           mut body: impl FnMut(i32) -> Option<()>) {
    while let Some(item) = iteration() {
        if body(item).is_none() {
            return;
        }
    }
}

pub fn demo() -> i32 {
    let mut numbers = Numbers { position: 0 };
    let mut total = 0;
    iterate(|| numbers.next(), |mut item| {
        item *= 2;
        total += item;
        Some(())
    });
    total
}
```

Внешний вызов: `demo()`.

Option отделяет завершение от любого i32; None от body также завершает цикл. FnMut разрешает изменение захваченного состояния. Заимствования ограничены вызовом iterate, поэтому после него total можно вернуть.

## Проверка и воспроизводимость

Python, Java, C++ и TypeScript исполнены: два последовательных вызова входа дали `12` и `12`. Java проверена OpenJDK 21; C++ — g++ в режиме C++17; TypeScript — Node.js 24 с удалением типов перед исполнением. Для TypeScript это проверка выполнения, а не отдельный прогон `tsc --strict`. C#, Go и Rust прошли статическое ревью; их компиляторы в среде отсутствуют. LMX проверен по документам, без запуска ядра.

Смысловые свойства, сохранённые в демонстрации (кроме запуска входа, проверены чтением кода):

- demo = 12; повторный demo = 12
- next выдаёт 1, 2, 3 и затем сигнал конца; тело получает ровно три значения
- Сигнал окончания из тела завершает цикл; 0 не используется как признак конца

Подсчёт воспроизводится непосредственно по восьми блокам исходников выше: `sum(not ch.isspace() for ch in code)` для основной колонки и `len(code)` для полной. Перед подсчётом применяется описанная нормализация перевода строк.

## Найденные сетевые образцы

1. [Refactoring.Guru — Iterator in Python: Conceptual Example](https://refactoring.guru/design-patterns/iterator/python/example). Исходный образец выделяет состояние обхода и next; его коллекция слов заменена общей для сравнения последовательностью 1, 2, 3. Код ниже написан заново и дополнен пользовательской iterate из примера LMX.

Из сетевых материалов взяты ориентиры по ролям участников и взаимодействию. Имена, арифметика, объём поведения и код адаптированы к общему LMX-сценарию. Сравнение не переносит в маленький пример дополнительные функции исходного учебного проекта.
