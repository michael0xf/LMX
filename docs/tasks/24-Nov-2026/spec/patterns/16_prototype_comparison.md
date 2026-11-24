# 16. Prototype: LMX и семь других языков

20 ноября 2026 года. Обновлено 22 ноября 2026 года. Продолжение серии: шаблоны 10–18.

## Задача

Создать Point(3,4), изменить original.x на 7, затем скопировать именно этот живой экземпляр. Изменить только replica.y на 9 и сложить результаты score = 10×x + y: 74 + 79 = 153.

**Внешний вызов LMX:** `Point\demo()`. **Ожидаемый результат: 153.**

Клонируется один конкретный тип с двумя скалярными полями. Пример не сравнивает глубокое копирование вложенных изменяемых объектов, внешних ресурсов или произвольной иерархии подтипов. `copy` имеет более общий графовый контракт; здесь проверяется лишь общий для всех программ сценарий.

## Архитектура LMX

Основной вариант использует `bindFields`: общий ресивер копирует фактический DATA исходного метода с наложением значений по умолчанию и возвращает соответствующий метод новой копии. `original` и `replica` теперь являются callable-представлениями двух владельцев Point; их DATA — `parent(original)` и `parent(replica)`. Второй вызов копирует именно настроенный DATA первого, а не исходный Point. Существующие поля и поведение сохраняются, позиции входов не удаляются. [Исходник ресивера](LMX_Fn_Receivers/src/structures.lmx) · [Контракт](LMX_Fn_Receivers/API.md).

Все общие ресиверы уже входят в одно текущее ядро; import и загрузка альтернативной библиотеки не нужны. Полное относящееся к примеру LMX-тело механизма ядра и его отдельный размер приведены ниже. Прежний прямой вариант copy → parent → запись также сохранён. В обоих вариантах общий наблюдаемый сценарий остаётся 74 + 79 = 153.

Применены согласованные правила: DATA метода — его фактический parent; обычные ссылки на методы используют существующие callable; объявленные входы без initializer допускают autofill, свободные имена — связь с местом непосредственного caller. `node\` выбирает лексическую связь. Пустая строка завершает корневой блок. [Связывание](../LMX_semantics.en.md#binding-places) · [Импорт](../LMX_semantics.en.md#import-receiver) · [Границы блоков](../LMX_grammar.en.md#levels)

## Подсчёт исходников

Главная метрика — **непробельные символы**: `sum(not ch.isspace() for ch in code)`. Дополнительно показаны полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF в конце.

В подсчёт входят весь показанный исходник, импорты, необходимые языковые оболочки и `demo`. Внешний запуск, `main`, печать результата, тестовая обвязка и реализация стандартной библиотеки/runtime не включены. Имена не нормализованы. Python записан без необязательных аннотаций типов. Сравниваются конкретные реализации одной задачи; это не оценка быстродействия или одинаковых статических гарантий.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 180 | 275 | 11 | 1.00× |
| Python | 209 | 304 | 16 | 1.16× |
| Java | 280 | 507 | 24 | 1.56× |
| C++ | 165 | 249 | 15 | 0.92× |
| C# | 273 | 457 | 21 | 1.52× |
| TypeScript | 219 | 311 | 16 | 1.22× |
| Go | 199 | 275 | 17 | 1.11× |
| Rust | 225 | 327 | 19 | 1.25× |

Общая таблица серии доступна в [Excel](LMX_Comparison_10-18.xlsx) и [PDF](LMX_Comparison_10-18.pdf).

## 1. LMX

<!-- counted-lmx: primary -->
```lmx
Point:
    int: x 3
    int: y 4
    return: int
    score:
        return: x * 10 + y
    demo:
        throws: ReceiverParent
        @: original bindFields(Point\score; (int: x 7))
        @: replica bindFields(original; (int: y 9))
        return: original() + replica()
```
Внешний вызов: `Point\demo()`. Он не входит в подсчёт.

DATA `original` содержит (7,4), DATA `replica` — (7,9). `original()` и `replica()` исполняют прежний score над своими независимыми владельцами. Проверка дополнительной мутации выражается через `parent(original)`/`parent(replica)`; ссылки больше не выдаются за прямые ссылки на поля Point.

Наложение объединено с созданием каждой копии: промежуточные состояния до записи x/y в исходном сценарии никем не наблюдаются. Настроенный первый DATA остаётся источником второй копии. `bindFields` сам выбирает фактический parent, поэтому клиенту не приходится отдельно нормализовать ссылку после группировки. Возвращаемые ссылки и их результаты не являются новыми типами объектов или неявным захватом активации.

### Прежний процедурный LMX — не входит в подсчёт символов

Точный предыдущий вариант оставлен для сопоставления механизма копирования. Он не исполняется вместе с основной версией и исключён из её размера.

<!-- uncounted-lmx: procedural -->
```lmx
Point:
    int: x 3
    int: y 4
    return: int
    score:
        return: x * 10 + y
    demo:
        @: original (copy(Point))
        original := parent(original\score)
        original\x := 7
        @: replica (copy(original))
        replica := parent(replica\score)
        replica\y := 9
        return: original\score() + replica\score()
```
### Граница сравнения по языкам

| Язык | Что делает его собственный механизм | Что сохранено у LMX |
| --- | --- | --- |
| LMX | `bindFields` копирует фактический DATA метода, накладывает значения полей и возвращает метод нового владельца; исходники общего механизма показаны отдельно. | `x`, `y`, `score`, две независимые копии и копирование уже настроенного первого DATA. |
| Python | `copy(original)` использует стандартное поверхностное копирование; последующая запись меняет только `replica.y`. | Для двух скалярных полей получается такая же независимость состояния; глубокое копирование вложенных объектов здесь не сравнивается. |
| Java | Показанный `Point.copy()` явно создаёт объект и переносит оба поля; весь этот прикладной исходник входит в размер Java. | Перенос обоих полей и изменение только `y` второй копии; общий механизм копирования LMX не скрывает предметный алгоритм. |
| C++ | `auto replica = original` использует обычное копирование значения `Point` без написанного вручную конструктора копирования. | Вторая копия получает актуальные `x = 7`, `y = 4` и затем меняет только собственное `y`. |
| C# | `MemberwiseClone()` выполняет стандартное поверхностное копирование; показанная оболочка `Copy()` входит в размер программы. | Копирование актуальных скалярных полей и независимые владельцы метода `score`. |
| TypeScript | `Object.assign(new Point(), original)` переносит собственные поля в новый `Point`, сохраняя доступ к методу класса. | Все исходные поля и поведение доступны у нового владельца; наложение `y = 9` не изменяет первый объект. |
| Go | `replica := original` копирует значение структуры; метод с получателем `Point` работает с её полями. | Оба поля сохраняются, последующая запись во вторую копию не меняет первую. |
| Rust | `#[derive(Clone)]` создаёт реализацию `Clone`, а `original.clone()` копирует актуальные поля; сгенерированное тело не включено в клиентский исходник. | Копируется настроенное состояние, сохраняется `score` и независимость последующего изменения `y`. |

Сравнивается поведение и граница учёта, а не обязанность LMX повторить устройство класса или конструктора. Ядровой bindFields сокращает собственную композицию LMX; он не выполняет скрытую прикладную задачу. Его полный исходник виден ниже. Методы/поля динамического языка не объявляются статическими только ради этого сравнения.

### Реализация bindFields в едином ядре — прозрачная граница учёта

Ниже полностью приведены оба нужных определения из [structures.lmx](LMX_Fn_Receivers/src/structures.lmx). Зависимости — уже существующие `parent`, `sys\indexof` и `merge`; ни целочисленная специализация, ни фиксированное число полей в helper не зашиты. `ReceiverParent` — объявленный отказ при отсутствии фактического владельца.

<!-- uncounted-lmx: library-implementation -->
```lmx
RxComposeData:
    @: code
    @: overlay
    return: @
    composeData:
        throws:
            ReceiverParent
        @: data parent(code)
        if: data = 0
            throw: ReceiverParent()
        int: bodyIndex sys\indexof(code; data)
        @: composed (merge(data; overlay))
        return: composed[bodyIndex]

RxBindFields:
    private: @: operation
    private: @: bindings
    return: @
    bindFields:
        throws:
            ReceiverParent
        return: RxComposeData\composeData(operation; bindings)
```
| Учитываемая часть | Непробельные символы | Строки |
| --- | ---: | ---: |
| Новый клиент, включая необходимые throws | 180 | 11 |
| Общая реализация двух ресиверов | 353 | 22 |
| Прежний клиент, отдельно от нового | 226 | 14 |

Клиент стал короче на **46** символов. Если считать одноразовую программу вместе с исходниками соответствующего механизма ядра, уменьшение не заявляется: её код приведён и измерен отдельно. Стандартная библиотека/runtime других языков, как и раньше, не включены в клиентскую таблицу.

## 2. Python

```python
from copy import copy

class Point:
    def __init__(self):
        self.x = 3
        self.y = 4

    def score(self):
        return self.x * 10 + self.y

def demo():
    original = Point()
    original.x = 7
    replica = copy(original)
    replica.y = 9
    return original.score() + replica.score()
```
Внешний вызов: `demo()`. Он не входит в подсчёт.

## 3. Java

```java
class Example {
    static class Point {
        int x = 3, y = 4;

        int score() {
            return x * 10 + y;
        }

        Point copy() {
            Point result = new Point();
            result.x = x;
            result.y = y;
            return result;
        }
    }

    public static int demo() {
        Point original = new Point();
        original.x = 7;
        Point replica = original.copy();
        replica.y = 9;
        return original.score() + replica.score();
    }
}
```
Внешний вызов: `Example.demo()`. Он не входит в подсчёт.

## 4. C++

```cpp
struct Point {
    int x = 3, y = 4;

    int score() const {
        return x * 10 + y;
    }
};

int demo() {
    Point original;
    original.x = 7;
    auto replica = original;
    replica.y = 9;
    return original.score() + replica.score();
}
```
Внешний вызов: `demo()`. Он не входит в подсчёт.

## 5. C#

```csharp
static class Example {
    sealed class Point {
        public int X = 3, Y = 4;

        public int Score() {
            return X * 10 + Y;
        }

        public Point Copy() {
            return (Point)MemberwiseClone();
        }
    }

    public static int Demo() {
        var original = new Point();
        original.X = 7;
        var replica = original.Copy();
        replica.Y = 9;
        return original.Score() + replica.Score();
    }
}
```
Внешний вызов: `Example.Demo()`. Он не входит в подсчёт.

## 6. TypeScript

```typescript
class Point {
    x = 3;
    y = 4;

    score(): number {
        return this.x * 10 + this.y;
    }
}

function demo(): number {
    const original = new Point();
    original.x = 7;
    const replica = Object.assign(new Point(), original);
    replica.y = 9;
    return original.score() + replica.score();
}
```
Внешний вызов: `demo()`. Он не входит в подсчёт.

## 7. Go

```go
package main

type Point struct {
    x, y int
}

func (point Point) score() int {
    return point.x * 10 + point.y
}

func demo() int {
    original := Point{3, 4}
    original.x = 7
    replica := original
    replica.y = 9
    return original.score() + replica.score()
}
```
Внешний вызов: `demo()`. Он не входит в подсчёт.

## 8. Rust

```rust
#[derive(Clone)]
struct Point {
    x: i32,
    y: i32,
}

impl Point {
    fn score(&self) -> i32 {
        self.x * 10 + self.y
    }
}

pub fn demo() -> i32 {
    let mut original = Point { x: 3, y: 4 };
    original.x = 7;
    let mut replica = original.clone();
    replica.y = 9;
    original.score() + replica.score()
}
```
Внешний вызов: `demo()`. Он не входит в подсчёт.

## Проверка

В этой редакции проверены согласованность LMX-листинга с документами `docs`, явная группировка результатов копирования/композиции там, где нужен один объект, и ссылки на правила языка. Ожидаемый результат LMX следует из показанного сценария; запуск ядра не проводился.

Листинги Python, Java, C++, C#, TypeScript, Go и Rust сохранены из исходного сравнения. Сообщения исходной редакции об их выполнении относятся к той проверке; это обновление документации не выдаёт их за новый запуск. Подсчёт размеров выполняется заново по листингам текущего файла.

## Источники

Сетевые образцы использованы для проверки ролей шаблона. Показанные программы — самостоятельные адаптации общего сценария, а не подсчёт длины исходников этих страниц.

- [Refactoring.Guru — Prototype](https://refactoring.guru/design-patterns/prototype)
- [Refactoring.Guru — Prototype in Python](https://refactoring.guru/design-patterns/prototype/python/example)


[S]: ../LMX_semantics.en.md#merge-two-forms
