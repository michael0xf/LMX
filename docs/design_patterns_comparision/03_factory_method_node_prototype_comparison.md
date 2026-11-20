# 03. Factory: сравнение создания продукта через прототип

20 ноября 2026 года · Редакция с завершением блока пустой строкой · LMX и семь других языков

## Общий сценарий

**Ожидаемый результат демонстрации — `32`.** Во всех восьми реализациях фабрика сначала меняет числовое поле исходного прототипа, затем возвращает самостоятельный продукт с копией этого значения. `small` задаёт `10`, `large` — `20`; `execute` читает продукт через `read` и добавляет единицу. Клиент непосредственно передаёт результаты фабрик в `execute`, получая `11 + 21`.

LMX-листинг ниже следует примеру автора и новому правилу завершения блока пустой строкой. **`node\payload` использует лексическое связывание с полем `payload` в `Product`.** Вложенность `create` не ограничивает эту запись полями непосредственного `parent`.

**Пустая строка жёстко завершает весь синтаксический блок.** По уточнению автора, её действие эквивалентно `---` на виртуальном уровне `-1` над root; явно записать такой маркер нельзя. Дополнительные закрывающие маркеры не нужны. Поэтому между `Product`, `add1` и `Demo` оставлено по одной пустой строке, а внутри каждого из этих корневых блоков пустых строк нет.

Последний блок `Demo` закрывается концом исходника (EOF). Действующее правило закрытия на EOF сохраняется; незакрытые ограниченные формы и лексические режимы остаются ошибками, но в этом примере их нет. Единственный LF после последней строки — окончание строки, а не дополнительная пустая строка. Закрывающая Markdown-ограда не является частью LMX-исходника.

Во всех вариантах можно сохранить первый и второй продукты: после второй фабрики их `read()` возвращают соответственно `10` и `20`, а исходный прототип содержит `20`. У созданных продуктов сохраняется возможность вызывать их методы.

Сравнение охватывает создание, копирование и использование продукта с одним числовым полем. В LMX `merge(Product)` копирует используемый граф структуры, включая связи её методов. В остальных вариантах применён механизм копирования, достаточный для этого продукта. При добавлении вложенных изменяемых объектов глубину копирования нужно сравнивать отдельно: поверхностная копия одного числового поля ещё не воспроизводит общую графовую семантику LMX.

В LMX `Product` служит исходной структурой-прототипом. В остальных реализациях один экземпляр `prototype` создаётся внутри `demo` и используется обеими фабриками. Начальное значение его поля — `0`; оно не наблюдается сценарием, поскольку фабрика сначала записывает нужное значение. Время жизни прототипа за пределами демонстрации в это сравнение не входит.

`create` в LMX группирует фабричные методы. В других языках они расположены непосредственно в `Product`; отдельный класс для воспроизведения одного лишь пространства имён не добавляется. Вызов и независимость числового состояния при этом сохраняются.

По организации создания это сочетание фабричных методов с копированием прототипа. Дополнительная иерархия `Creator` из классического GoF Factory Method в данном примере не используется; сетевые образцы обоих шаблонов приведены в конце.

## Как считались символы

Главная величина — **число непробельных символов**: `sum(not ch.isspace() for ch in code)`. Это метрика длины, а не инструкция удалить пробелы из исполняемого исходника. Дополнительно приведены полный размер в символах и количество физических строк.

Нормализация: переводы строк LF, без пустых строк в начале и конце блока, один LF в конце. Все восемь листингов состоят из ASCII-символов, поэтому полный размер в символах совпадает с размером в байтах UTF-8.

Считается весь показанный код: импорты, объявления, необходимые классы-оболочки или `package`, методы, обработчик и демонстрация. Внешний запуск, `main`, печать, проверочный код, Markdown и реализация стандартной библиотеки/runtime не считаются. Комментариев в измеряемом коде нет.

Python приведён без необязательных аннотаций. Статические гарантии типов между языками не уравниваются. Имена и учебное форматирование сохранены; таблица измеряет эти конкретные листинги, а не минимально возможную программу на каждом языке.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 338 | 547 | 27 | 1.00× |
| Python | 341 | 481 | 25 | 1.01× |
| Java | 428 | 730 | 36 | 1.27× |
| C++ | 314 | 468 | 28 | 0.93× |
| C# | 412 | 669 | 30 | 1.22× |
| TypeScript | 413 | 573 | 28 | 1.22× |
| Go | 404 | 524 | 30 | 1.20× |
| Rust | 381 | 551 | 31 | 1.13× |

Отношение больше 1 означает, что соответствующий листинг длиннее LMX по непробельным символам.

## 1. LMX

```lmx
Product:
    int: payload
    return: int
    read:
        return: payload
    create:
        return: Product
        small:
            node\payload := 10
            return: merge(Product)
        large:
            node\payload := 20
            return: merge(Product)

add1:
    @: product Product
    return: int
    execute:
        return: product\read() + 1

Demo:
    return: int
    run:
        import: Product add1
        int: first execute(create\small())
        int: second execute(create\large())
        return: first + second
```

Внешний вызов: `Demo\run()`; он не включён в подсчёт.

`node\payload` явно выбирает лексическое связывание поля. `small` записывает `10`, `large` — `20`; `merge(Product)` возвращает самостоятельную копию структуры. Это объясняет независимость результата первого вызова от последующей записи в прототип.

`import: Product add1` делает `create` и `execute` доступными в `run`. В `execute` передаётся уже полученный продукт; отдельная переменная с фабричным callable здесь не нужна. Контракт результата `run` задан полем `return: int` в `Demo`.

## 2. Python

```python
from copy import copy

class Product:
    def __init__(self):
        self.payload = 0

    def read(self):
        return self.payload

    def small(self):
        self.payload = 10
        return copy(self)

    def large(self):
        self.payload = 20
        return copy(self)

def execute(product):
    return product.read() + 1

def demo():
    prototype = Product()
    first = execute(prototype.small())
    second = execute(prototype.large())
    return first + second
```

Внешний вызов: `demo()`.

Фабрики изменяют текущий экземпляр и возвращают `copy(self)`. Для единственного числового поля это отдельный продукт с независимым состоянием; методы доступны через тот же класс. Контракт операции описан в [документации Python `copy`](https://docs.python.org/3/library/copy.html).

## 3. Java

```java
class Example {
    static class Product {
        int payload;

        Product() {}

        Product(Product other) {
            payload = other.payload;
        }

        int read() {
            return payload;
        }

        Product small() {
            payload = 10;
            return new Product(this);
        }

        Product large() {
            payload = 20;
            return new Product(this);
        }
    }

    static int execute(Product product) {
        return product.read() + 1;
    }

    public static int demo() {
        Product prototype = new Product();
        int first = execute(prototype.small());
        int second = execute(prototype.large());
        return first + second;
    }
}
```

Внешний вызов: `Example.demo()`.

`small` и `large` изменяют текущий экземпляр, затем вызывают копирующий конструктор. Он явно переносит единственное поле `payload`. Если состояние класса расширится, этот конструктор потребуется дополнить.

## 4. C++

```cpp
struct Product {
    int payload = 0;

    int read() const {
        return payload;
    }

    Product small() {
        payload = 10;
        return *this;
    }

    Product large() {
        payload = 20;
        return *this;
    }
};

int execute(const Product& product) {
    return product.read() + 1;
}

int demo() {
    Product prototype;
    int first = execute(prototype.small());
    int second = execute(prototype.large());
    return first + second;
}
```

Внешний вызов: `demo()`.

`return *this` возвращает отдельное значение `Product` после изменения исходного экземпляра. `execute` читает временный продукт по константной ссылке во время вызова. Для одного `int` обычного копирования структуры достаточно.

## 5. C#

```csharp
static class Example {
    sealed class Product {
        int payload;

        public int Read() {
            return payload;
        }

        public Product Small() {
            payload = 10;
            return (Product)MemberwiseClone();
        }

        public Product Large() {
            payload = 20;
            return (Product)MemberwiseClone();
        }
    }

    static int Execute(Product product) {
        return product.Read() + 1;
    }

    public static int Demo() {
        var prototype = new Product();
        int first = Execute(prototype.Small());
        int second = Execute(prototype.Large());
        return first + second;
    }
}
```

Внешний вызов: `Example.Demo()`.

`MemberwiseClone()` создаёт отдельный экземпляр того же типа с копией полей. У показанного продукта одно поле `int`, поэтому состояние копии независимо. Контракт поверхностного копирования описан в [документации Microsoft](https://learn.microsoft.com/en-us/dotnet/api/system.object.memberwiseclone).

## 6. TypeScript

```typescript
class Product {
    payload = 0;

    read(): number {
        return this.payload;
    }

    small(): Product {
        this.payload = 10;
        return Object.assign(new Product(), this);
    }

    large(): Product {
        this.payload = 20;
        return Object.assign(new Product(), this);
    }
}

function execute(product: Product): number {
    return product.read() + 1;
}

function demo(): number {
    const prototype = new Product();
    const first = execute(prototype.small());
    const second = execute(prototype.large());
    return first + second;
}
```

Внешний вызов: `demo()`.

`Object.assign(new Product(), this)` переносит собственные перечислимые поля в новый экземпляр класса. Новый `Product` сохраняет методы через прототип класса, а числовое поле копируется независимо. Правило переноса свойств задано в [ECMAScript: `Object.assign`](https://tc39.es/ecma262/multipage/fundamental-objects.html#sec-object.assign).

## 7. Go

```go
package main

type Product struct {
    payload int
}

func (product Product) read() int {
    return product.payload
}

func (product *Product) small() Product {
    product.payload = 10
    return *product
}

func (product *Product) large() Product {
    product.payload = 20
    return *product
}

func execute(product Product) int {
    return product.read() + 1
}

func demo() int {
    prototype := Product{}
    first := execute(prototype.small())
    second := execute(prototype.large())
    return first + second
}
```

Внешний вызов: `demo()`.

Фабрики имеют pointer receiver и изменяют исходный экземпляр. `return *product` возвращает структуру значением; `execute` также получает значение. Единственное числовое поле копируется независимо.

## 8. Rust

```rust
#[derive(Clone)]
struct Product {
    payload: i32,
}

impl Product {
    fn read(&self) -> i32 {
        self.payload
    }

    fn small(&mut self) -> Self {
        self.payload = 10;
        self.clone()
    }

    fn large(&mut self) -> Self {
        self.payload = 20;
        self.clone()
    }
}

fn execute(product: Product) -> i32 {
    product.read() + 1
}

pub fn demo() -> i32 {
    let mut prototype = Product { payload: 0 };
    let first = execute(prototype.small());
    let second = execute(prototype.large());
    first + second
}
```

Внешний вызов: `demo()`.

Методы с `&mut self` изменяют прототип; `#[derive(Clone)]` создаёт копию его поля `i32`. `execute` получает продукт во владение. При расширении структуры поведение `Clone` определяется типами её полей; см. [документацию Rust](https://doc.rust-lang.org/std/clone/trait.Clone.html).

## Что изменилось относительно предыдущего сравнения

Непосредственно предыдущая редакция этого примера содержала три явных маркера `---`. Они удалены по новому авторскому правилу: пустые строки между корневыми блоками закрывают предыдущий блок целиком, последний блок закрывается на EOF.

Размер LMX уменьшился с **347 до 338 непробельных символов**: разница **9** — ровно три удалённых маркера по три символа. Полный размер стал **547 символов**, число физических строк — **27**. Лексическое связывание `node\payload`, фабрики, копирование прототипа и ожидаемый результат `32` сохранены.

Семь остальных листингов не изменены. Их абсолютные размеры прежние; отношения к размеру LMX пересчитаны с новым знаменателем 338.

## Проверка

| Реализация | Способ проверки | Результат |
|---|---|---|
| LMX | Разбор по согласованным правилам лексического `node\`, завершения блока пустой строкой и закрытия на EOF; ядро не запускалось | Ожидаемый результат `32` |
| Python | Выполнение исходника и отдельного проверочного кода | Проверки пройдены |
| Java | Компиляция OpenJDK 21 и выполнение | Проверки пройдены |
| C++ | Компиляция g++ в режиме C++17 и выполнение | Проверки пройдены |
| C# | Статическое ревью; компилятор недоступен | Исполнение не проверено |
| TypeScript | Выполнение в Node.js 24 с удалением типов | Проверки пройдены; отдельный `tsc --strict` не запускался |
| Go | Статическое ревью; компилятор недоступен | Исполнение не проверено |
| Rust | Статическое ревью; компилятор недоступен | Исполнение не проверено |

Для четырёх исполненных реализаций проверено:

1. Два последовательных запуска демонстрации дают `32` и `32`.
2. После `small`, затем `large` сохранённые продукты читаются как `10` и `20`, а исходный прототип — как `20`.
3. Фабрики можно вызывать на созданных копиях; у них сохраняются методы, а изменение одной копии не меняет состояние остальных экземпляров.

Проверочный код хранится отдельно от сравниваемых листингов и не включён в число символов. Подсчёт таблицы повторно сверяется с восемью блоками исходника непосредственно из этого документа.

## Сетевые образцы и источники

1. [Refactoring.Guru — Factory Method in Python](https://refactoring.guru/design-patterns/factory-method/python/example): ориентир по отделению создания продукта от его использования. Иерархия `Creator` исходного учебного примера здесь не переносится.
2. [Refactoring.Guru — Prototype in Python](https://refactoring.guru/design-patterns/prototype/python/example): ориентир по созданию продуктов копированием прототипа. Произвольные вложенные объекты и циклические ссылки сетевого примера не включены в этот небольшой сценарий.
3. [Python — `copy`](https://docs.python.org/3/library/copy.html): поверхностное и глубокое копирование.
4. [Microsoft — `Object.MemberwiseClone`](https://learn.microsoft.com/en-us/dotnet/api/system.object.memberwiseclone): копирование полей экземпляра.
5. [ECMAScript — `Object.assign`](https://tc39.es/ecma262/multipage/fundamental-objects.html#sec-object.assign): копирование собственных перечислимых свойств в целевой объект.
6. [Rust — `Clone`](https://doc.rust-lang.org/std/clone/trait.Clone.html): копирование значения и производная реализация для полей структуры.

LMX взят из авторского примера с уточнениями о лексическом `node\` и завершении блока пустой строкой. Закрытие последнего блока на EOF сохраняет действующее правило грамматики. Остальные листинги написаны для общего сценария; это не дословные копии сетевых учебных программ.
