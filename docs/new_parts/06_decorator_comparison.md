# 06. Decorator: LMX и семь других языков

21 ноября 2026 года · Согласовано с документацией docs

## Задача и границы

Три функции и demo из Python собраны в одну группу transform. Вход value и результат int объявлены один раз. Каждая обёртка вызывает предыдущее звено и дополняет результат.

**Ожидаемый результат: 63.**

Фиксированная цепочка обёрток. Произвольная сборка или перестановка цепочки во время выполнения не реализована ни в одном листинге. Прямой внешний вызов применён одинаково ко всем языкам.

## Архитектура LMX

Авторский перевод Python base / with_one / with_three / demo использует одну группу transform. value и return объявлены один раз, вложенные вызовы используют autofill. Во всех восьми версиях demo непосредственно вызывает внешнюю обёртку.

Структура задаёт общий DATA связанных методов. Метод обращается к нужным ему полям; отдельная оболочка для demo из-за остальных полей не требуется. Обычная ссылка `@: name method` не вызывает method и не требует самостоятельного `fn`. Программа по-прежнему использует типы объявленных полей и правила конкретных вызовов. [Связывание и ссылки][B]

Пустая строка завершает корневой синтаксический блок. Внутренний `---` сохраняется там, где нужно продолжить внешнюю структуру. `node\` выбирает лексическую связь, а не переход к parent. [Границы блоков][E]

## Подсчёт исходников

Главная метрика — **число непробельных символов**: `sum(not ch.isspace() for ch in code)`. Пробельные символы исключаются только из измерения; исходник сохраняет необходимое форматирование. Также приведены полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF после последней строки.

Считается весь показанный листинг: объявления, импорты, необходимые языковые оболочки, методы и демонстрация. Внешний вызов, main, печать, тестовый harness, Markdown и реализация runtime/стандартной библиотеки не входят. Имена не нормализованы. Python записан без необязательных аннотаций; одинаковые статические гарантии не заявляются. Таблица измеряет эти программы, а не теоретический минимум для каждого языка.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 128 | 207 | 11 | 1.00× |
| Python | 140 | 184 | 14 | 1.09× |
| Java | 197 | 306 | 17 | 1.54× |
| C++ | 153 | 205 | 15 | 1.20× |
| C# | 203 | 329 | 22 | 1.59× |
| TypeScript | 213 | 269 | 15 | 1.66× |
| Go | 176 | 235 | 17 | 1.38× |
| Rust | 151 | 208 | 15 | 1.18× |

Отношение больше 1 означает более длинный листинг по непробельным символам.

## 1. LMX

```lmx
transform:
    int: value
    return: int
    base:
        return: value * 2
    with_one:
        return: base() + 1
    with_three:
        return: with_one() * 3
    demo:
        return: with_three(10)
```

Внешний вызов: `transform\demo()`. Он не входит в подсчёт.

demo вызывает with_three(10). Затем with_one() и base() получают свои значения value через обычное автодозаполнение объявленного входа от непосредственного вызывающего. base возвращает 20, with_one — 21, with_three — 63. Это разные рабочие места вызовов, записи в граф не нужны. demo — обычный метод той же группы; ему не требуется пользоваться каждым полем её DATA.

with_three(10) вызывает with_one(), тот вызывает base(). Каждый получает свой value = 10; результаты возвращаются как 20 → 21 → 63. Выбор base(10) или with_one(10) дал бы 20 или 21.

## 2. Python

```python
def base(value):
    return value * 2


def with_one(value):
    return base(value) + 1


def with_three(value):
    return with_one(value) * 3


def demo():
    return with_three(10)
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 3. Java

```java
class Example {
    static int base(int value) {
        return value * 2;
    }

    static int withOne(int value) {
        return base(value) + 1;
    }

    static int withThree(int value) {
        return withOne(value) * 3;
    }

    public static int demo() {
        return withThree(10);
    }
}
```

Внешний вызов: `Example.demo()`. Он не входит в подсчёт.

## 4. C++

```cpp
int base(int value) {
    return value * 2;
}

int withOne(int value) {
    return base(value) + 1;
}

int withThree(int value) {
    return withOne(value) * 3;
}

int demo() {
    return withThree(10);
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 5. C#

```csharp
static class Example
{
    static int Base(int value)
    {
        return value * 2;
    }

    static int WithOne(int value)
    {
        return Base(value) + 1;
    }

    static int WithThree(int value)
    {
        return WithOne(value) * 3;
    }

    public static int Demo()
    {
        return WithThree(10);
    }
}
```

Внешний вызов: `Example.Demo()`. Он не входит в подсчёт.

## 6. TypeScript

```typescript
function base(value: number): number {
    return value * 2;
}

function withOne(value: number): number {
    return base(value) + 1;
}

function withThree(value: number): number {
    return withOne(value) * 3;
}

function demo(): number {
    return withThree(10);
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 7. Go

```go
package main

func base(value int) int {
    return value * 2
}

func withOne(value int) int {
    return base(value) + 1
}

func withThree(value int) int {
    return withOne(value) * 3
}

func demo() int {
    return withThree(10)
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 8. Rust

```rust
fn base(value: i32) -> i32 {
    value * 2
}

fn with_one(value: i32) -> i32 {
    base(value) + 1
}

fn with_three(value: i32) -> i32 {
    with_one(value) * 3
}

pub fn demo() -> i32 {
    with_three(10)
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## Что изменилось в этой редакции

Сохранён авторский короткий Decorator с автодозаполнением value между методами. Ссылки на правила перенесены в docs.

Семь остальных листингов сохранены без изменений относительно загруженного архива.

## Проверка

LMX сопоставлен с правилами docs: роли DATA/CODE, аргументы, связывание, лексический node и синтаксические границы. Для copy/merge учитываются поток результата и явная группировка. Ожидаемые результаты относятся к этой модели.

В исходной редакции сообщалось об исполнении Python, Java, C++ и TypeScript и статическом просмотре C#, Go и Rust. Их листинги сохранены без изменений; новых запусков эта редакция не заявляет. LMX-ядро здесь не запускалось.

Метрики пересчитываются непосредственно из восьми основных блоков исходника. Внешний вызов и тестовая обвязка не включены.

## Источники правил и примеров

- [Связывание, структурный вызов и необязательный самостоятельный fn-контракт][B].
- [Переданные объявления и импорт корневых const-объявлений][D].
- [Пустая строка как завершение корневого блока][E].

Ранее использованные сетевые образцы ролей шаблона сохранены как источники. Показанные программы — адаптации общего сценария, а не дословные копии или измерение длины этих страниц.

- [Refactoring.Guru — Decorator in Python, original conceptual example](https://refactoring.guru/design-patterns/decorator/python/example)

[B]: ../TZ/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md
[D]: ../TZ/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md
[E]: ../TZ/LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md
