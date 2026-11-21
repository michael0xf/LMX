# 01. Iterator: LMX и семь других языков

20 ноября 2026 года · Редакция по Python-прототипу

## Задача и границы

Итератор хранит позицию в numbers; пользовательский cycles\iterate исполняет переданную форму объявления и тело. demo является методом numbers, как естественной группы этой демонстрации.

**Ожидаемый результат: 12.**

Пример содержит конкретную последовательность из трёх значений и пользовательский цикл. Stop завершает последовательность; обработчик охватывает весь оборот, поэтому Stop из тела также завершит цикл. Обобщённый API контейнеров не предполагается.

## Архитектура LMX

В Python Numbers хранит позицию, iterate принимает шаг и обработчик, demo накапливает total. В LMX сохраняются эти роли: numbers содержит next и demo, а cycles — пользовательский iterate. Переданная форма объявления связывает текущий item с телом.

Структура задаёт общий DATA связанных методов. Метод обращается к нужным ему полям; отдельная оболочка для demo из-за остальных полей не требуется. Обычная ссылка `@: name method` не вызывает method и не требует самостоятельного `fn`. Программа по-прежнему использует типы объявленных полей и правила конкретных вызовов. [Связывание и ссылки][B]

Пустая строка завершает корневой синтаксический блок. Внутренний `---` сохраняется там, где нужно продолжить внешнюю структуру. `node\` выбирает лексическую связь, а не переход к parent. [Границы блоков][E]

## Подсчёт исходников

Главная метрика — **число непробельных символов**: `sum(not ch.isspace() for ch in code)`. Пробельные символы исключаются только из измерения; исходник сохраняет необходимое форматирование. Также приведены полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF после последней строки.

Считается весь показанный листинг: объявления, импорты, необходимые языковые оболочки, методы и демонстрация. Внешний вызов, main, печать, тестовый harness, Markdown и реализация runtime/стандартной библиотеки не входят. Имена не нормализованы. Python записан без необязательных аннотаций; одинаковые статические гарантии не заявляются. Таблица измеряет эти программы, а не теоретический минимум для каждого языка.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 285 | 527 | 26 | 1.00× |
| Python | 363 | 579 | 33 | 1.27× |
| Java | 524 | 858 | 36 | 1.84× |
| C++ | 375 | 595 | 34 | 1.32× |
| C# | 389 | 731 | 36 | 1.36× |
| TypeScript | 413 | 687 | 35 | 1.45× |
| Go | 391 | 592 | 33 | 1.37× |
| Rust | 424 | 665 | 33 | 1.49× |

Отношение больше 1 означает более длинный листинг по непробельным символам.

## 1. LMX

```lmx
numbers:
    int: position 0
    return: int
    next:
        throws: Stop
        if: node\position >= 3
            throw: Stop()
        node\position += 1
        return: node\position
    demo:
        node\position := 0
        int: total 0
        cycles\iterate: int: item numbers\next()
            item *= 2
            total += item
        return: total

cycles:
    @: iteration
    @: body
    iterate:
        while: 1
            iteration()
            catch: Stop ()
                break
            body()
```

Внешний вызов: `numbers\demo()`. Он не входит в подсчёт.

node\position адресует лексическое хранимое поле numbers. demo сбрасывает его, создаёт локальный total, затем напрямую вызывает qualified head cycles\iterate:. Форма int: item numbers\next() и общий контекст тела сохранены буквально; total меняется в локальном месте demo. После трёх значений 1, 2, 3 тело накапливает 2, 4, 6; следующий Stop завершает цикл.

Последовательные значения 1, 2, 3 удваиваются до 2, 4, 6; total становится 12. Следующий вызов next даёт Stop. Позиция сбрасывается в начале demo, а total создаётся заново как локальная переменная.

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

Внешний вызов: `demo()`. Он не входит в подсчёт.

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

Внешний вызов: `Example.demo()`. Он не входит в подсчёт.

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

Внешний вызов: `demo()`. Он не входит в подсчёт.

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

Внешний вызов: `Example.Demo()`. Он не входит в подсчёт.

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

Внешний вызов: `demo()`. Он не входит в подсчёт.

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

Внешний вызов: `demo()`. Он не входит в подсчёт.

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

Внешний вызов: `demo()`. Он не входит в подсчёт.

## Что изменилось

LMX: **307 → 285 непробельных символов** относительно предыдущей согласованной редакции. Убрана обвязка, не нужная показанному сценарию: отдельные демонстрационные структуры, повторные описания сигнатур, промежуточные ссылки или перекладывание значений. Это изменение исходников; скорость исполнения не измерялась.

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

- [Refactoring.Guru — Iterator in Python: Conceptual Example](https://refactoring.guru/design-patterns/iterator/python/example)

[B]: https://chatgpt.com/library?file_id=libfile_fde3_f-a38201c30fb88191b7207c0e48955c30_bbe92b09b62881918d17958175103ded&account_id=personal
[D]: https://chatgpt.com/library?file_id=libfile_fde3_f-02443abbc4508191b7c8fd7894e3ac24_bbe92b09b62881918d17958175103ded&account_id=personal
[E]: https://chatgpt.com/library?file_id=libfile_fde3_f-9d15a59bc5d881918724924fcef45b04_bbe92b09b62881918d17958175103ded&account_id=personal
