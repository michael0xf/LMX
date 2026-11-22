# 19. Singleton: LMX и семь других языков

20 ноября 2026 года. Обновлено 21 ноября 2026 года. Продолжение серии: шаблоны 19–23.

## Задача

В одном последовательном контексте получить Settings дважды, записать value = 7 через первую ссылку и прочитать 7 через вторую. Повторное обращение не создаёт копию состояния.

**Внешний вызов LMX:** `Demo\run()`. **Ожидаемый результат: 7.**

Область уникальности — один провайдер в одном последовательном контексте; для LMX это один Message. Это пример единственного предоставляемого объекта, а не запрет пользователю намеренно создать или скопировать другой объект. Межпроцессная уникальность и конкурентная инициализация не входят в сценарий. В Rust контекст представлен thread_local; клонируется Rc-ссылка, а не Settings, и Cell даёт изменяемое скалярное поле без блокировок. Остальные программы также рассматриваются только в одном последовательном контексте.

## Архитектура LMX

Именованная Structure Settings уже является одним объектом графа LMX. get возвращает именно эту Structure; `copy` и `merge` не вызываются. Как в Python-провайдере с единственным settings, first и second обозначают один объект. Отдельный класс-контейнер экземпляра не требуется.

Применены согласованные правила: DATA метода — его фактический parent; обычные ссылки на методы не требуют отдельного `fn`; объявленные входы без initializer допускают autofill, свободные имена — связь с местом непосредственного caller. `node\` выбирает лексическую связь. Пустая строка завершает корневой блок. [Связывание](../LMX_semantics.en.md#binding-places) · [Импорт][D] · [Границы блоков][E]

## Подсчёт исходников

Главная метрика — **непробельные символы**: `sum(not ch.isspace() for ch in code)`. Дополнительно показаны полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF в конце.

В подсчёт входят весь показанный исходник, импорты, необходимые языковые оболочки и `demo`. Внешний запуск, `main`, печать результата, тестовая обвязка и реализация стандартной библиотеки/runtime не включены. Имена не нормализованы. Python записан без необязательных аннотаций типов. Сравниваются конкретные реализации одной задачи; это не оценка быстродействия или одинаковых статических гарантий.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 141 | 226 | 13 | 1.00× |
| Python | 127 | 179 | 13 | 0.90× |
| Java | 213 | 335 | 18 | 1.51× |
| C++ | 155 | 215 | 16 | 1.10× |
| C# | 224 | 349 | 18 | 1.59× |
| TypeScript | 181 | 245 | 16 | 1.28× |
| Go | 164 | 227 | 18 | 1.16× |
| Rust | 274 | 351 | 20 | 1.94× |

Общая таблица этой пятёрки доступна в [Excel](LMX_Comparison_19-23.xlsx) и [PDF](LMX_Comparison_19-23.pdf).

## 1. LMX

```lmx
Settings:
    int: value 0
    return: @
    get:
        return: Settings

Demo:
    return: int
    run:
        @: first Settings\get()
        @: second Settings\get()
        first\value := 7
        return: second\value
```

Внешний вызов: `Demo\run()`. Он не входит в подсчёт.

Оба вызова get возвращают тот же Settings. Прямая запись first\value меняет его поле, поэтому second\value читает 7. Каждый demo явно записывает 7, так что повторный запуск даёт тот же результат. Проверка дополнительно меняет поле через вторую ссылку и читает его через первую.

## 2. Python

```python
class Settings:
    value = 0

settings = Settings()

def get():
    return settings

def demo():
    first = get()
    second = get()
    first.value = 7
    return second.value
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 3. Java

```java
class Example {
    static class Settings {
        int value;
    }

    static final Settings settings = new Settings();

    static Settings get() {
        return settings;
    }

    static int demo() {
        Settings first = get();
        Settings second = get();
        first.value = 7;
        return second.value;
    }
}
```

Внешний вызов: `Example.demo()`. Он не входит в подсчёт.

## 4. C++

```cpp
struct Settings {
    int value = 0;
};

Settings settings;

Settings& get() {
    return settings;
}

int demo() {
    auto& first = get();
    auto& second = get();
    first.value = 7;
    return second.value;
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 5. C#

```csharp
static class Example {
    sealed class Settings {
        public int Value;
    }

    static readonly Settings settings = new Settings();

    static Settings Get() {
        return settings;
    }

    public static int Demo() {
        var first = Get();
        var second = Get();
        first.Value = 7;
        return second.Value;
    }
}
```

Внешний вызов: `Example.Demo()`. Он не входит в подсчёт.

## 6. TypeScript

```typescript
class Settings {
    value = 0;
}

const settings = new Settings();

function get(): Settings {
    return settings;
}

function demo(): number {
    const first = get();
    const second = get();
    first.value = 7;
    return second.value;
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 7. Go

```go
package main

type Settings struct {
    value int
}

var settings Settings

func get() *Settings {
    return &settings
}

func demo() int {
    first := get()
    second := get()
    first.value = 7
    return second.value
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 8. Rust

```rust
use std::{cell::Cell, rc::Rc};

struct Settings {
    value: Cell<i32>,
}

thread_local! {
    static SETTINGS: Rc<Settings> = Rc::new(Settings { value: Cell::new(0) });
}

fn get() -> Rc<Settings> {
    SETTINGS.with(Rc::clone)
}

pub fn demo() -> i32 {
    let first = get();
    let second = get();
    first.value.set(7);
    second.value.get()
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## Проверка

В этой редакции проверены согласованность LMX-листинга с документами `docs`, явная группировка результатов копирования/композиции там, где нужен один объект, и ссылки на правила языка. Ожидаемый результат LMX следует из показанного сценария; запуск ядра не проводился.

Листинги Python, Java, C++, C#, TypeScript, Go и Rust сохранены из исходного сравнения. Сообщения исходной редакции об их выполнении относятся к той проверке; это обновление документации не выдаёт их за новый запуск. Подсчёт размеров выполняется заново по листингам текущего файла.

## Источники

Сетевые образцы использованы для проверки ролей шаблона. Показанные программы — самостоятельные адаптации общего сценария, а не подсчёт длины исходников этих страниц.

- [Refactoring.Guru — Singleton](https://refactoring.guru/design-patterns/singleton)
- [Refactoring.Guru — Singleton in Python](https://refactoring.guru/design-patterns/singleton/python/example)

[D]: ../tasks/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md
[E]: ../tasks/LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md
