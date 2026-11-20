# 04. Adapter: LMX и семь других языков

20 ноября 2026 года · Редакция по Python-прототипу

## Задача и границы

Как в Python, legacy_subtract принимает right,left, адаптер subtract предоставляет left,right и явно переставляет два значения. demo находится в adapter и вызывает subtract напрямую.

**Ожидаемый результат: 5.**

Адаптер реально делегирует старому методу после перестановки аргументов. Внешняя одноразовая callable-переменная удалена во всех языках. Возможность хранить произвольную заменяемую внешнюю реализацию отдельным требованием не задаётся.

## Архитектура LMX

В Python legacy_subtract и subtract имеют разные порядки параметров. Поэтому LMX сохраняет два DATA: legacy и adapter. demo находится рядом с адаптером и вызывает его непосредственно.

Структура задаёт общий DATA связанных методов. Метод обращается к нужным ему полям; отдельная оболочка для demo из-за остальных полей не требуется. Обычная ссылка `@: name method` не вызывает method и не требует самостоятельного `fn`. Программа по-прежнему использует типы объявленных полей и правила конкретных вызовов. [Связывание и ссылки][B]

Пустая строка завершает корневой синтаксический блок. Внутренний `---` сохраняется там, где нужно продолжить внешнюю структуру. `node\` выбирает лексическую связь, а не переход к parent. [Границы блоков][E]

## Подсчёт исходников

Главная метрика — **число непробельных символов**: `sum(not ch.isspace() for ch in code)`. Пробельные символы исключаются только из измерения; исходник сохраняет необходимое форматирование. Также приведены полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF после последней строки.

Считается весь показанный листинг: объявления, импорты, необходимые языковые оболочки, методы и демонстрация. Внешний вызов, main, печать, тестовый harness, Markdown и реализация runtime/стандартной библиотеки не входят. Имена не нормализованы. Python записан без необязательных аннотаций; одинаковые статические гарантии не заявляются. Таблица измеряет эти программы, а не теоретический минимум для каждого языка.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 163 | 251 | 15 | 1.00× |
| Python | 160 | 194 | 10 | 0.98× |
| Java | 203 | 289 | 13 | 1.25× |
| C++ | 165 | 207 | 11 | 1.01× |
| C# | 209 | 308 | 17 | 1.28× |
| TypeScript | 217 | 262 | 11 | 1.33× |
| Go | 179 | 225 | 13 | 1.10× |
| Rust | 165 | 211 | 11 | 1.01× |

Отношение больше 1 означает более длинный листинг по непробельным символам.

## 1. LMX

```lmx
legacy:
    int: right
    int: left
    return: int
    subtract:
        return: left - right

adapter:
    int: left
    int: right
    return: int
    subtract:
        return: legacy\subtract(right; left)
    demo:
        return: subtract(8; 3)
```

Внешний вызов: `adapter\demo()`. Он не входит в подсчёт.

Два DATA описывают два разных порядка входов. subtract(8;3) в adapter получает left=8,right=3. Вызов legacy\subtract(right;left) направляет 3 в первый legacy-вход right и8 во второй left. Получается8−3=5. Декларации результата и аргументов используются методами группы, включая demo. fn, import и отдельная Demo не нужны. Без адаптации прямой legacy\subtract(8;3) дал бы3−8=−5.

adapter.subtract получает left = 8 и right = 3, затем передаёт legacy значения в обратном порядке: right = 3, left = 8. Результат 5. Прямой legacy.subtract(8; 3) дал бы −5.

## 2. Python

```python
def legacy_subtract(right, left):
    return left - right


def subtract(minuend, subtrahend):
    return legacy_subtract(right=subtrahend, left=minuend)


def demo():
    return subtract(8, 3)
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 3. Java

```java
class Example {
    static int legacySubtract(int right, int left) {
        return left - right;
    }

    static int subtract(int minuend, int subtrahend) {
        return legacySubtract(subtrahend, minuend);
    }

    public static int demo() {
        return subtract(8, 3);
    }
}
```

Внешний вызов: `Example.demo()`. Он не входит в подсчёт.

## 4. C++

```cpp
int legacySubtract(int right, int left) {
    return left - right;
}

int subtract(int minuend, int subtrahend) {
    return legacySubtract(subtrahend, minuend);
}

int demo() {
    return subtract(8, 3);
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 5. C#

```csharp
static class Example
{
    static int LegacySubtract(int right, int left)
    {
        return left - right;
    }

    static int Subtract(int minuend, int subtrahend)
    {
        return LegacySubtract(subtrahend, minuend);
    }

    public static int Demo()
    {
        return Subtract(8, 3);
    }
}
```

Внешний вызов: `Example.Demo()`. Он не входит в подсчёт.

## 6. TypeScript

```typescript
function legacySubtract(right: number, left: number): number {
    return left - right;
}

function subtract(minuend: number, subtrahend: number): number {
    return legacySubtract(subtrahend, minuend);
}

function demo(): number {
    return subtract(8, 3);
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 7. Go

```go
package main

func legacySubtract(right, left int) int {
    return left - right
}

func subtract(minuend, subtrahend int) int {
    return legacySubtract(subtrahend, minuend)
}

func demo() int {
    return subtract(8, 3)
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 8. Rust

```rust
fn legacy_subtract(right: i32, left: i32) -> i32 {
    left - right
}

fn subtract(minuend: i32, subtrahend: i32) -> i32 {
    legacy_subtract(subtrahend, minuend)
}

pub fn demo() -> i32 {
    subtract(8, 3)
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## Что изменилось

LMX: **241 → 163 непробельных символов** относительно предыдущей согласованной редакции. Убрана обвязка, не нужная показанному сценарию: отдельные демонстрационные структуры, повторные описания сигнатур, промежуточные ссылки или перекладывание значений. Это изменение исходников; скорость исполнения не измерялась.

Во всех семи сравнительных версиях также удалены одноразовая callable-переменная внешнего вызова и ставшие ненужными функциональные типы или импорты. Обёртки и реальное делегирование сохранены.

## Проверка

LMX проверен по согласованным правилам: DATA, обычные ссылки на методы, явные аргументы и autofill, места вызывающего, лексический node и синтаксические границы. LMX-ядро здесь не запускалось; результат указан как ожидаемый.

Изменённые Python, Java, C++ и TypeScript исполнены: два последовательных вызова дали 5 и 5. C++ компилировался в режиме C++17; Java — через доступный javac. TypeScript исполнен с удалением типов; отдельный tsc --strict не заявляется. C#, Go и Rust просмотрены статически, без запуска.

Метрики пересчитаны непосредственно из восьми блоков исходника. Тестовая обвязка в них не включена.

## Источники правил и примеров

- [Связывание, структурный вызов и необязательный самостоятельный fn-контракт][B].
- [Переданные объявления и импорт корневых const-объявлений][D].
- [Пустая строка как завершение корневого блока][E].

Ранее использованные сетевые образцы ролей шаблона сохранены как источники. Показанные программы — адаптации общего сценария, а не дословные копии или измерение длины этих страниц.

- [Refactoring.Guru — Adapter in Python, original conceptual examples](https://refactoring.guru/design-patterns/adapter/python/example)

[B]: https://chatgpt.com/library?file_id=libfile_fde3_f-a38201c30fb88191b7207c0e48955c30_bbe92b09b62881918d17958175103ded&account_id=personal
[D]: https://chatgpt.com/library?file_id=libfile_fde3_f-02443abbc4508191b7c8fd7894e3ac24_bbe92b09b62881918d17958175103ded&account_id=personal
[E]: https://chatgpt.com/library?file_id=libfile_fde3_f-9d15a59bc5d881918724924fcef45b04_bbe92b09b62881918d17958175103ded&account_id=personal
