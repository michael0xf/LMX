# 21. Flyweight: LMX и семь других языков

20 ноября 2026 года. Обновлено 21 ноября 2026 года. Продолжение серии: шаблоны 19–23.

## Задача

В заранее подготовленном пуле есть два вида глифа: thin с шириной 2 и thick с шириной 3. Допустимые ключи — 0 и 1. get повторно выдаёт ту же ссылку для того же ключа. render принимает позицию отдельно и вычисляет width * 10 + position. Два использования thin на позициях 3 и 7 и одно использование thick на позиции 1 дают 81.

**Внешний вызов LMX:** `glyphs\drawing\demo()`. **Ожидаемый результат: 81.**

Во всех восьми вариантах пул фиксирован и заранее содержит ровно два вида; динамического кэша, вытеснения и разбора новых ключей нет. Позиции остаются внешними значениями. width представляет потенциально большой набор общих данных глифа: этот маленький пример демонстрирует разделение состояния и идентичность, а не измеренный выигрыш памяти. Общие данные после создания не меняются; в Go это контракт данного API, поскольку поле внутри пакета технически доступно для записи. Прочие варианты используют соответствующие средства неизменяемости или доступа только для чтения.

## Архитектура LMX

В `glyphs` находятся общие объекты `thin` и `thick`, выбирающий их метод `get` и вложенная группа `drawing`. Вызовы `get(0)` и `get(1)` внутри `drawing` находят метод по лексической видимости. `render` получает ссылку на глиф и внешнюю позицию; позиция в сам глиф не записывается. DATA методов `render` и `demo` — `drawing`, а DATA метода `get` — `glyphs`.

LMX и Python используют именованное поле `width`: в LMX оно находится в `immutable`-структуре, в Python — в `@dataclass(frozen=True)`. Поле может быть частью более богатого набора общих свойств. `immutable` защищает содержимое глифа; одной константности имени для такого обещания недостаточно. Возврат и присваивание структурной ссылки сохраняют идентичность; копирование через `copy` здесь не требуется.

Внутри `glyphs` нет пустых строк: по принятому правилу пустая строка завершила бы весь корневой блок. Завершающий `return` расположен на уровне объявления `demo` и завершает его тело. Пробелы в `render(first 3)` разделяют два позиционных аргумента. [Связывание](../LMX_semantics.en.md#binding-places) · [Импорт][D] · [Границы блоков][E]

## Подсчёт исходников

Главная метрика — **непробельные символы**: `sum(not ch.isspace() for ch in code)`. Дополнительно показаны полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF в конце.

В подсчёт входят весь показанный исходник, импорты, необходимые языковые оболочки и `demo`. Внешний запуск, `main`, печать результата, тестовая обвязка и реализация стандартной библиотеки/runtime не включены. Имена не нормализованы. Python записан без необязательных аннотаций типов. Сравниваются конкретные реализации одной задачи; это не оценка быстродействия или одинаковых статических гарантий.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 281 | 486 | 20 | 1.00× |
| Python | 309 | 396 | 20 | 1.10× |
| Java | 354 | 517 | 20 | 1.26× |
| C++ | 312 | 411 | 20 | 1.11× |
| C# | 359 | 522 | 20 | 1.28× |
| TypeScript | 391 | 495 | 18 | 1.39× |
| Go | 303 | 418 | 25 | 1.08× |
| Rust | 328 | 444 | 21 | 1.17× |

Общая таблица этой пятёрки доступна в [Excel](LMX_Comparison_19-23.xlsx) и [PDF](LMX_Comparison_19-23.pdf).

## 1. LMX

```lmx
glyphs:
    int: kind
    return: @
    immutable: thin: int: width 2
    immutable: thick: int: width 3
    get:
        if: kind = 0
            return: thin
        return: thick
    drawing:
        @: glyph
        int: position
        return: int
        render:
            return: glyph\width * 10 + position
        demo:
            @: first get(0)
            @: second get(0)
            @: third get(1)
        return: render(first 3) + render(second 7) + render(third 1)
```

Внешний вызов: `glyphs\drawing\demo()`. Он не входит в подсчёт.

first и second ссылаются на один thin; third ссылается на другой объект thick. Вычисления дают 2 * 10 + 3 = 23, 2 * 10 + 7 = 27 и 3 * 10 + 1 = 31. Общая ширина не изменяется; результат demo — 81. В Python дополнительно проверены идентичность возвращаемых ссылок, использование других позиций и запрет обычного присваивания в `width`.

## 2. Python

```python
from dataclasses import dataclass

@dataclass(frozen=True)
class Glyph:
    width: int

thin = Glyph(width=2)
thick = Glyph(width=3)

def get(kind):
    return thin if kind == 0 else thick

def render(glyph, position):
    return glyph.width * 10 + position

def demo():
    first = get(0)
    second = get(0)
    third = get(1)
    return render(first, 3) + render(second, 7) + render(third, 1)
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 3. Java

```java
class Example {
    record Glyph(int width) {}
    static final Glyph thin = new Glyph(2);
    static final Glyph thick = new Glyph(3);

    static Glyph get(int kind) {
        return kind == 0 ? thin : thick;
    }

    static int render(Glyph glyph, int position) {
        return glyph.width() * 10 + position;
    }

    static int demo() {
        Glyph first = get(0);
        Glyph second = get(0);
        Glyph third = get(1);
        return render(first, 3) + render(second, 7) + render(third, 1);
    }
}
```

Внешний вызов: `Example.demo()`. Он не входит в подсчёт.

## 4. C++

```cpp
struct Glyph {
    const int width;
};

const Glyph thin{2}, thick{3};

const Glyph& get(int kind) {
    return kind == 0 ? thin : thick;
}

int render(const Glyph& glyph, int position) {
    return glyph.width * 10 + position;
}

int demo() {
    const auto& first = get(0);
    const auto& second = get(0);
    const auto& third = get(1);
    return render(first, 3) + render(second, 7) + render(third, 1);
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 5. C#

```csharp
static class Example {
    sealed record Glyph(int Width);
    static readonly Glyph thin = new(2);
    static readonly Glyph thick = new(3);

    static Glyph Get(int kind) {
        return kind == 0 ? thin : thick;
    }

    static int Render(Glyph glyph, int position) {
        return glyph.Width * 10 + position;
    }

    public static int Demo() {
        var first = Get(0);
        var second = Get(0);
        var third = Get(1);
        return Render(first, 3) + Render(second, 7) + Render(third, 1);
    }
}
```

Внешний вызов: `Example.Demo()`. Он не входит в подсчёт.

## 6. TypeScript

```typescript
type Glyph = Readonly<{ width: number }>;
const thin: Glyph = Object.freeze({ width: 2 });
const thick: Glyph = Object.freeze({ width: 3 });

function get(kind: number): Glyph {
    return kind === 0 ? thin : thick;
}

function render(glyph: Glyph, position: number): number {
    return glyph.width * 10 + position;
}

function demo(): number {
    const first = get(0);
    const second = get(0);
    const third = get(1);
    return render(first, 3) + render(second, 7) + render(third, 1);
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 7. Go

```go
package main

type Glyph struct {
    width int
}

var thin, thick = Glyph{2}, Glyph{3}

func get(kind int) *Glyph {
    if kind == 0 {
        return &thin
    }
    return &thick
}

func render(glyph *Glyph, position int) int {
    return glyph.width*10 + position
}

func demo() int {
    first := get(0)
    second := get(0)
    third := get(1)
    return render(first, 3) + render(second, 7) + render(third, 1)
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 8. Rust

```rust
struct Glyph {
    width: i32,
}

static THIN: Glyph = Glyph { width: 2 };
static THICK: Glyph = Glyph { width: 3 };

fn get(kind: i32) -> &'static Glyph {
    if kind == 0 { &THIN } else { &THICK }
}

fn render(glyph: &Glyph, position: i32) -> i32 {
    glyph.width * 10 + position
}

pub fn demo() -> i32 {
    let first = get(0);
    let second = get(0);
    let third = get(1);
    render(first, 3) + render(second, 7) + render(third, 1)
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## Проверка

В этой редакции проверены согласованность LMX-листинга с документами `docs`, явная группировка результатов копирования/композиции там, где нужен один объект, и ссылки на правила языка. Ожидаемый результат LMX следует из показанного сценария; запуск ядра не проводился.

Листинги Python, Java, C++, C#, TypeScript, Go и Rust сохранены из исходного сравнения. Сообщения исходной редакции об их выполнении относятся к той проверке; это обновление документации не выдаёт их за новый запуск. Подсчёт размеров выполняется заново по листингам текущего файла.

## Источники

Сетевые образцы использованы для проверки ролей шаблона. Показанные программы — самостоятельные адаптации общего сценария, а не подсчёт длины исходников этих страниц.

- [Refactoring.Guru — Flyweight in Python, conceptual example](https://refactoring.guru/design-patterns/flyweight/python/example)

[D]: ../tasks/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md
[E]: ../tasks/LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md
