# 03. Factory: LMX и семь других языков

20 ноября 2026 года · Редакция по Python-прототипу

## Задача и границы

Авторские Product/create и потребитель add1 сохранены. Демонстрационный метод помещён рядом с execute в add1; отдельный Demo не нужен.

**Ожидаемый результат: 32.**

Это фабричные методы с копированием прототипа. Сравнивается независимость одного числового поля и возможность вызвать read у продукта. Общая графовая семантика merge не приравнивается к поверхностному копированию произвольных вложенных объектов других языков.

## Архитектура LMX

Как Python Product, исходная структура содержит payload, read и фабричные методы, которые сначала записывают значение, затем возвращают копию. execute и demo собраны в add1. Первый результат сохраняется, второй сразу участвует в сумме.

Структура задаёт общий DATA связанных методов. Метод обращается к нужным ему полям; отдельная оболочка для demo из-за остальных полей не требуется. Обычная ссылка `@: name method` не вызывает method и не требует самостоятельного `fn`. Программа по-прежнему использует типы объявленных полей и правила конкретных вызовов. [Связывание и ссылки][B]

Пустая строка завершает корневой синтаксический блок. Внутренний `---` сохраняется там, где нужно продолжить внешнюю структуру. `node\` выбирает лексическую связь, а не переход к parent. [Границы блоков][E]

## Подсчёт исходников

Главная метрика — **число непробельных символов**: `sum(not ch.isspace() for ch in code)`. Пробельные символы исключаются только из измерения; исходник сохраняет необходимое форматирование. Также приведены полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF после последней строки.

Считается весь показанный листинг: объявления, импорты, необходимые языковые оболочки, методы и демонстрация. Внешний вызов, main, печать, тестовый harness, Markdown и реализация runtime/стандартной библиотеки не входят. Имена не нормализованы. Python записан без необязательных аннотаций; одинаковые статические гарантии не заявляются. Таблица измеряет эти программы, а не теоретический минимум для каждого языка.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 304 | 493 | 23 | 1.00× |
| Python | 328 | 461 | 24 | 1.08× |
| Java | 411 | 701 | 35 | 1.35× |
| C++ | 297 | 443 | 27 | 0.98× |
| C# | 395 | 640 | 29 | 1.30× |
| TypeScript | 394 | 546 | 27 | 1.30× |
| Go | 390 | 503 | 29 | 1.28× |
| Rust | 364 | 526 | 30 | 1.20× |

Отношение больше 1 означает более длинный листинг по непробельным символам.

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
    demo:
        import: Product
        int: first execute(create\small())
        return: first + execute(create\large())
```

Внешний вызов: `add1\demo()`. Он не входит в подсчёт.

node\payload в create выбирает лексическое поле Product, не непосредственный parent. Каждый метод записывает 10 либо 20 до merge(Product), поэтому продукты остаются независимыми. Поле product потребителя получает созданный продукт явно. demo не обязан обращаться к каждому полю своего DATA. import: Product открывает create, а execute уже виден в собственном DATA.

small возвращает продукт с payload = 10, large — с payload = 20; потребитель возвращает 11 и 21. Если удержать оба продукта, поздний large не меняет значение первого. Исходный прототип после серии содержит 20.

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
    return first + execute(prototype.large())
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

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
        return first + execute(prototype.large());
    }
}
```

Внешний вызов: `Example.demo()`. Он не входит в подсчёт.

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
    return first + execute(prototype.large());
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

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
        return first + Execute(prototype.Large());
    }
}
```

Внешний вызов: `Example.Demo()`. Он не входит в подсчёт.

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
    return first + execute(prototype.large());
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

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
    return first + execute(prototype.large())
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

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
    first + execute(prototype.large())
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## Что изменилось

LMX: **338 → 304 непробельных символов** относительно предыдущей согласованной редакции. Убрана обвязка, не нужная показанному сценарию: отдельные демонстрационные структуры, повторные описания сигнатур, промежуточные ссылки или перекладывание значений. Это изменение исходников; скорость исполнения не измерялась.

Во всех семи остальных языках второе одноразовое значение также подставлено непосредственно в return. Первый вызов остаётся отдельным, поэтому порядок фабричных действий сохраняется.

## Проверка

LMX проверен по согласованным правилам: DATA, обычные ссылки на методы, явные аргументы и autofill, места вызывающего, лексический node и синтаксические границы. LMX-ядро здесь не запускалось; результат указан как ожидаемый.

Изменённые Python, Java, C++ и TypeScript исполнены: два последовательных вызова дали 32 и 32. C++ компилировался в режиме C++17; Java — через доступный javac. TypeScript исполнен с удалением типов; отдельный tsc --strict не заявляется. C#, Go и Rust просмотрены статически, без запуска.

Метрики пересчитаны непосредственно из восьми блоков исходника. Тестовая обвязка в них не включена.

## Источники правил и примеров

- [Связывание, структурный вызов и необязательный самостоятельный fn-контракт][B].
- [Переданные объявления и импорт корневых const-объявлений][D].
- [Пустая строка как завершение корневого блока][E].

Ранее использованные сетевые образцы ролей шаблона сохранены как источники. Показанные программы — адаптации общего сценария, а не дословные копии или измерение длины этих страниц.

- [документации Python `copy`](https://docs.python.org/3/library/copy.html)
- [документации Microsoft](https://learn.microsoft.com/en-us/dotnet/api/system.object.memberwiseclone)
- [ECMAScript: `Object.assign`](https://tc39.es/ecma262/multipage/fundamental-objects.html#sec-object.assign)
- [документацию Rust](https://doc.rust-lang.org/std/clone/trait.Clone.html)
- [Refactoring.Guru — Factory Method in Python](https://refactoring.guru/design-patterns/factory-method/python/example)
- [Refactoring.Guru — Prototype in Python](https://refactoring.guru/design-patterns/prototype/python/example)

[B]: https://chatgpt.com/library?file_id=libfile_fde3_f-a38201c30fb88191b7207c0e48955c30_bbe92b09b62881918d17958175103ded&account_id=personal
[D]: https://chatgpt.com/library?file_id=libfile_fde3_f-02443abbc4508191b7c8fd7894e3ac24_bbe92b09b62881918d17958175103ded&account_id=personal
[E]: https://chatgpt.com/library?file_id=libfile_fde3_f-9d15a59bc5d881918724924fcef45b04_bbe92b09b62881918d17958175103ded&account_id=personal
