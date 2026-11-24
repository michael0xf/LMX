# 03. Factory: LMX и семь других языков

21 ноября 2026 года · Согласовано с документацией docs

## Задача и границы

Авторские Product/create и потребитель add1 сохранены. Демонстрационный метод помещён рядом с execute в add1; отдельный Demo не нужен.

**Ожидаемый результат: 32.**

Это фабричные методы с копированием прототипа. Сравнивается независимость одного числового поля и возможность вызвать read у продукта. Общая графовая семантика copy не приравнивается к поверхностному копированию произвольных вложенных объектов других языков.

## Архитектура LMX

Как Python Product, исходная структура содержит payload, read и фабричные методы, которые сначала записывают значение, затем возвращают копию. execute и demo собраны в add1. Первый результат сохраняется, второй сразу участвует в сумме.

Структура задаёт общий DATA связанных методов. Метод обращается к нужным ему полям; отдельная оболочка для demo из-за остальных полей не требуется. Обычная ссылка `@: name method` не вызывает method и не требует самостоятельного `fn`. Программа по-прежнему использует типы объявленных полей и правила конкретных вызовов. [Связывание и ссылки](../LMX_semantics.en.md#binding-places)

Пустая строка завершает корневой синтаксический блок. Внутренний `---` сохраняется там, где нужно продолжить внешнюю структуру. `node\` выбирает лексическую связь, а не переход к parent. [Границы блоков](../LMX_grammar.en.md#levels)

## Подсчёт исходников

Главная метрика — **число непробельных символов**: `sum(not ch.isspace() for ch in code)`. Пробельные символы исключаются только из измерения; исходник сохраняет необходимое форматирование. Также приведены полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF после последней строки.

Считается весь показанный листинг: объявления, импорты, необходимые языковые оболочки, методы и демонстрация. Внешний вызов, main, печать, тестовый harness, Markdown и реализация runtime/стандартной библиотеки не входят. Имена не нормализованы. Python записан без необязательных аннотаций; одинаковые статические гарантии не заявляются. Таблица измеряет эти программы, а не теоретический минимум для каждого языка.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 306 | 495 | 23 | 1.00× |
| Python | 328 | 461 | 24 | 1.07× |
| Java | 411 | 701 | 35 | 1.34× |
| C++ | 297 | 443 | 27 | 0.97× |
| C# | 395 | 640 | 29 | 1.29× |
| TypeScript | 394 | 546 | 27 | 1.29× |
| Go | 390 | 503 | 29 | 1.27× |
| Rust | 364 | 526 | 30 | 1.19× |

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
            return: (copy(Product))
        large:
            node\payload := 20
            return: (copy(Product))

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

node\payload в create выбирает лексическое поле Product, не непосредственный parent. Каждый метод записывает 10 либо 20, затем `copy(Product)` копирует источник. Явная группа `(copy(Product))` собирает поток полей в один возвращаемый продукт, поэтому продукты остаются независимыми. Исходная запись ресивера сохраняется в графе; результат принимается через namespace. [Копирование и потоки полей](../LMX_semantics.en.md#composition) Поле product потребителя получает созданный продукт явно. demo не обязан обращаться к каждому полю своего DATA. import: Product открывает create, а execute уже виден в собственном DATA.

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

## Что изменилось в этой редакции

Оба одноисточниковых копирования записаны как return: (copy(Product)): copy выдаёт поток полей, а явная группа собирает один возвращаемый продукт. Лексический node и короткая демонстрация сохранены.

Семь остальных листингов сохранены без изменений относительно загруженного архива.

## Проверка

LMX сопоставлен с правилами docs: роли DATA/CODE, аргументы, связывание, лексический node и синтаксические границы. Для copy/merge учитываются поток результата и явная группировка. Ожидаемые результаты относятся к этой модели.

В исходной редакции сообщалось об исполнении Python, Java, C++ и TypeScript и статическом просмотре C#, Go и Rust. Их листинги сохранены без изменений; новых запусков эта редакция не заявляет. LMX-ядро здесь не запускалось.

Метрики пересчитываются непосредственно из восьми основных блоков исходника. Внешний вызов и тестовая обвязка не включены.

## Источники правил и примеров

- [Связывание](../LMX_semantics.en.md#binding-places), [структурный вызов](../LMX_semantics.en.md#structural-call) и необязательный самостоятельный [fn-контракт](../LMX_semantics.en.md#fn-signature).
- [Переданные объявления](../LMX_semantics.en.md#declaration-arguments) и [импорт корневых const-объявлений](../LMX_semantics.en.md#import-receiver).
- [Пустая строка как завершение корневого блока](../LMX_grammar.en.md#levels).

Ранее использованные сетевые образцы ролей шаблона сохранены как источники. Показанные программы — адаптации общего сценария, а не дословные копии или измерение длины этих страниц.

- [документации Python `copy`](https://docs.python.org/3/library/copy.html)
- [документации Microsoft](https://learn.microsoft.com/en-us/dotnet/api/system.object.memberwiseclone)
- [ECMAScript: `Object.assign`](https://tc39.es/ecma262/multipage/fundamental-objects.html#sec-object.assign)
- [документацию Rust](https://doc.rust-lang.org/std/clone/trait.Clone.html)
- [Refactoring.Guru — Factory Method in Python](https://refactoring.guru/design-patterns/factory-method/python/example)
- [Refactoring.Guru — Prototype in Python](https://refactoring.guru/design-patterns/prototype/python/example)


