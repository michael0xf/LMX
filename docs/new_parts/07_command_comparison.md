# 07. Command: LMX и семь других языков

21 ноября 2026 года · Согласовано с документацией docs

## Задача и границы

demo создаёт локальный value = 0, invoke сначала исполняет add_two по умолчанию, затем явно выбранный twice. Обе команды изменяют одну локальную переменную; результат 4.

**Ожидаемый результат: 4.**

Синхронное исполнение двух команд при доступном локальном контексте. Очередь, undo и сериализация не входят в пример. Обычная ссылка на метод сама по себе не продлевает время жизни локальной переменной.

## Архитектура LMX

Python demo содержит локальный счётчик, две команды и invoke. В LMX связанные методы находятся в commands, а изменяемая value остаётся локальной в demo. invoke получает это место до вызова выбранной команды.

Структура задаёт общий DATA связанных методов. Метод обращается к нужным ему полям; отдельная оболочка для demo из-за остальных полей не требуется. Обычная ссылка `@: name method` не вызывает method и не требует самостоятельного `fn`. Программа по-прежнему использует типы объявленных полей и правила конкретных вызовов. [Связывание и ссылки](../LMX_semantics.en.md#binding-places)

Пустая строка завершает корневой синтаксический блок. Внутренний `---` сохраняется там, где нужно продолжить внешнюю структуру. `node\` выбирает лексическую связь, а не переход к parent. [Границы блоков][E]

## Подсчёт исходников

Главная метрика — **число непробельных символов**: `sum(not ch.isspace() for ch in code)`. Пробельные символы исключаются только из измерения; исходник сохраняет необходимое форматирование. Также приведены полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF после последней строки.

Считается весь показанный листинг: объявления, импорты, необходимые языковые оболочки, методы и демонстрация. Внешний вызов, main, печать, тестовый harness, Markdown и реализация runtime/стандартной библиотеки не входят. Имена не нормализованы. Python записан без необязательных аннотаций; одинаковые статические гарантии не заявляются. Таблица измеряет эти программы, а не теоретический минимум для каждого языка.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 152 | 268 | 15 | 1.00× |
| Python | 185 | 283 | 17 | 1.22× |
| Java | 317 | 543 | 28 | 2.09× |
| C++ | 252 | 371 | 18 | 1.66× |
| C# | 250 | 437 | 20 | 1.64× |
| TypeScript | 210 | 318 | 15 | 1.38× |
| Go | 214 | 353 | 20 | 1.41× |
| Rust | 281 | 361 | 13 | 1.85× |

Отношение больше 1 означает более длинный листинг по непробельным символам.

## 1. LMX

```lmx
commands:
    @: command add_two
    return: int
    add_two:
        value += 2
    twice:
        value *= 2
    invoke:
        required: value
        command()
    demo:
        int: value 0
        invoke()
        invoke(command := twice)
        return: value
```

Внешний вызов: `commands\demo()`. Он не входит в подсчёт.

Структура commands собирает связанные методы ровно как локальные Python-функции внутри demo. Объявление @: command add_two задаёт обычную ссылку со значением по умолчанию; отдельный fn не нужен для конкретного примера. value объявлен в code demo, а не в общей DATA, поэтому в invoke и телах команд это свободное имя. required: value в invoke обращается к месту непосредственного caller до command(), не объявляет собственную копию и устанавливает связь с demo.value. Команда затем получает от invoke уже установленный alias к тому же месту. Первый вызов даёт 2, второй — 4; каждый новый demo создаёт собственную локальную переменную. Общее return:int описывает числовой результат demo; остальные методы вызываются как действия и их результаты не потребляются.

В начале demo value = 0. invoke() использует add_two и меняет её на 2. invoke(command := twice) явно выбирает вторую команду и меняет ту же переменную на 4. Повторный demo создаёт новую локальную value.

## 2. Python

```python
def demo():
    value = 0

    def add_two_command():
        nonlocal value
        value += 2

    def double_command():
        nonlocal value
        value *= 2

    def invoke(command=add_two_command):
        command()

    invoke()
    invoke(double_command)
    return value
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 3. Java

```java
class Example {
    static class Counter {
        int value = 0;

        void addTwoCommand() {
            value += 2;
        }

        void doubleCommand() {
            value *= 2;
        }

        void invoke(Runnable command) {
            command.run();
        }

        void invoke() {
            invoke(this::addTwoCommand);
        }
    }

    public static int demo() {
        Counter counter = new Counter();
        counter.invoke();
        counter.invoke(counter::doubleCommand);
        return counter.value;
    }
}
```

Внешний вызов: `Example.demo()`. Он не входит в подсчёт.

## 4. C++

```cpp
#include <functional>

int demo() {
    int value = 0;
    auto addTwoCommand = [&value] {
        value += 2;
    };
    auto doubleCommand = [&value] {
        value *= 2;
    };
    auto invoke = [&](std::function<void()> command = {}) {
        if (command) command();
        else addTwoCommand();
    };
    invoke();
    invoke(doubleCommand);
    return value;
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 5. C#

```csharp
using System;

static class Example {
    public static int Demo() {
        int value = 0;
        void AddTwoCommand() {
            value += 2;
        }
        void DoubleCommand() {
            value *= 2;
        }
        void Invoke(Action command = null) {
            if (command == null) command = AddTwoCommand;
            command();
        }
        Invoke();
        Invoke(DoubleCommand);
        return value;
    }
}
```

Внешний вызов: `Example.Demo()`. Он не входит в подсчёт.

## 6. TypeScript

```typescript
function demo(): number {
    let value = 0;
    const addTwoCommand = () => {
        value += 2;
    };
    const doubleCommand = () => {
        value *= 2;
    };
    function invoke(command: () => void = addTwoCommand): void {
        command();
    }
    invoke();
    invoke(doubleCommand);
    return value;
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 7. Go

```go
package main

func demo() int {
    value := 0
    addTwoCommand := func() {
        value += 2
    }
    doubleCommand := func() {
        value *= 2
    }
    invoke := func(command func()) {
        if command == nil {
            command = addTwoCommand
        }
        command()
    }
    invoke(nil)
    invoke(doubleCommand)
    return value
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 8. Rust

```rust
use std::cell::Cell;

pub fn demo() -> i32 {
    let value = Cell::new(0);
    let add_two_command = || value.set(value.get() + 2);
    let double_command = || value.set(value.get() * 2);
    let invoke = |command: Option<&dyn Fn()>| {
        command.unwrap_or(&add_two_command)();
    };
    invoke(None);
    invoke(Some(&double_command));
    value.get()
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## Что изменилось в этой редакции

Сохранены команды, работающие с местом value вызывающего. required в invoke достигает этого места до вызова команды; отдельный графовый объект состояния не добавлен.

Семь остальных листингов сохранены без изменений относительно загруженного архива.

## Проверка

LMX сопоставлен с правилами docs: роли DATA/CODE, аргументы, связывание, лексический node и синтаксические границы. Для copy/merge учитываются поток результата и явная группировка. Ожидаемые результаты относятся к этой модели.

В исходной редакции сообщалось об исполнении Python, Java, C++ и TypeScript и статическом просмотре C#, Go и Rust. Их листинги сохранены без изменений; новых запусков эта редакция не заявляет. LMX-ядро здесь не запускалось.

Метрики пересчитываются непосредственно из восьми основных блоков исходника. Внешний вызов и тестовая обвязка не включены.

## Источники правил и примеров

- [Связывание](../LMX_semantics.en.md#binding-places), [структурный вызов](../LMX_semantics.en.md#structural-call) и необязательный самостоятельный [fn-контракт](../LMX_semantics.en.md#fn-signature).
- [Переданные объявления и импорт корневых const-объявлений][D].
- [Пустая строка как завершение корневого блока][E].

Ранее использованные сетевые образцы ролей шаблона сохранены как источники. Показанные программы — адаптации общего сценария, а не дословные копии или измерение длины этих страниц.

- [Refactoring.Guru — Command](https://refactoring.guru/design-patterns/command)
- [Refactoring.Guru — Command in Python, conceptual example](https://refactoring.guru/design-patterns/command/python/example)

[D]: ../tasks/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md
[E]: ../tasks/LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md
