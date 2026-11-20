# 14. Facade: LMX и семь других языков

20 ноября 2026 года. Продолжение серии: шаблоны 10–18.

## Задача

Операция subtotal вычисляет quantity × price, fee — weight × 2 + zone × 5. Фасад quote вызывает обе и возвращает общую стоимость. Все числа — целые условные единицы.

**Внешний вызов LMX:** `checkout\demo()`. **Ожидаемый результат: 39.**

Фасад координирует две самостоятельно вызываемые операции расчёта товаров и доставки. Им не нужны отдельные namespace или классы, чтобы оставаться отдельными операциями: как и в Python, они собраны в одну группу. Оплаты, складских транзакций и правил округления в задаче нет.

## Архитектура LMX

Как функции одного Python-модуля, subtotal, fee, quote и demo находятся в общей группе checkout. DATA объявляет quantity, price, weight, zone и return один раз; каждый метод использует только нужные ему поля. quote вызывает subtotal() и fee() с автопередачей значений. Эти две операции можно вызывать и отдельно: checkout\subtotal(3; 10) и checkout\fee(weight := 2; zone := 1). Именованная подача в fee выбирает нужные поля общего DATA, а не его первые две позиции.

Применены согласованные правила: DATA метода — его фактический parent; обычные ссылки на методы не требуют отдельного `fn`; объявленные входы без initializer допускают autofill, свободные имена — связь с местом непосредственного caller. `node\` выбирает лексическую связь. Пустая строка завершает корневой блок. [Связывание][B] · [Импорт][D] · [Границы блоков][E]

## Подсчёт исходников

Главная метрика — **непробельные символы**: `sum(not ch.isspace() for ch in code)`. Дополнительно показаны полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF в конце.

В подсчёт входят весь показанный исходник, импорты, необходимые языковые оболочки и `demo`. Внешний запуск, `main`, печать результата, тестовая обвязка и реализация стандартной библиотеки/runtime не включены. Имена не нормализованы. Python записан без необязательных аннотаций типов. Сравниваются конкретные реализации одной задачи; это не оценка быстродействия или одинаковых статических гарантий.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX |
|---|---:|---:|---:|---:|
| LMX | 170 | 274 | 14 | 1.00× |
| Python | 204 | 259 | 11 | 1.20× |
| Java | 274 | 401 | 17 | 1.61× |
| C++ | 236 | 307 | 15 | 1.39× |
| C# | 286 | 415 | 17 | 1.68× |
| TypeScript | 316 | 391 | 15 | 1.86× |
| Go | 244 | 317 | 17 | 1.44× |
| Rust | 235 | 311 | 15 | 1.38× |

Общая таблица серии доступна в [Excel](LMX_Comparison_10-18.xlsx) и [PDF](LMX_Comparison_10-18.pdf).

## 1. LMX

```lmx
checkout:
    int: quantity
    int: price
    int: weight
    int: zone
    return: int
    subtotal:
        return: quantity * price
    fee:
        return: weight * 2 + zone * 5
    quote:
        return: subtotal() + fee()
    demo:
        return: quote(3; 10; 2; 1)
```

Внешний вызов: `checkout\demo()`. Он не входит в подсчёт.

quote(3; 10; 2; 1) получает subtotal = 30 и fee = 9, затем возвращает 39. Дополнительный сценарий quote(1; 8; 3; 2) возвращает 24.

## 2. Python

```python
def subtotal(quantity, price):
    return quantity * price

def fee(weight, zone):
    return weight * 2 + zone * 5

def quote(quantity, price, weight, zone):
    return subtotal(quantity, price) + fee(weight, zone)

def demo():
    return quote(3, 10, 2, 1)
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 3. Java

```java
class Example {
    static int subtotal(int quantity, int price) {
        return quantity * price;
    }

    static int fee(int weight, int zone) {
        return weight * 2 + zone * 5;
    }

    static int quote(int quantity, int price, int weight, int zone) {
        return subtotal(quantity, price) + fee(weight, zone);
    }

    static int demo() {
        return quote(3, 10, 2, 1);
    }
}
```

Внешний вызов: `Example.demo()`. Он не входит в подсчёт.

## 4. C++

```cpp
int subtotal(int quantity, int price) {
    return quantity * price;
}

int fee(int weight, int zone) {
    return weight * 2 + zone * 5;
}

int quote(int quantity, int price, int weight, int zone) {
    return subtotal(quantity, price) + fee(weight, zone);
}

int demo() {
    return quote(3, 10, 2, 1);
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 5. C#

```csharp
static class Example {
    static int Subtotal(int quantity, int price) {
        return quantity * price;
    }

    static int Fee(int weight, int zone) {
        return weight * 2 + zone * 5;
    }

    static int Quote(int quantity, int price, int weight, int zone) {
        return Subtotal(quantity, price) + Fee(weight, zone);
    }

    public static int Demo() {
        return Quote(3, 10, 2, 1);
    }
}
```

Внешний вызов: `Example.Demo()`. Он не входит в подсчёт.

## 6. TypeScript

```typescript
function subtotal(quantity: number, price: number): number {
    return quantity * price;
}

function fee(weight: number, zone: number): number {
    return weight * 2 + zone * 5;
}

function quote(quantity: number, price: number, weight: number, zone: number): number {
    return subtotal(quantity, price) + fee(weight, zone);
}

function demo(): number {
    return quote(3, 10, 2, 1);
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 7. Go

```go
package main

func subtotal(quantity, price int) int {
    return quantity * price
}

func fee(weight, zone int) int {
    return weight * 2 + zone * 5
}

func quote(quantity, price, weight, zone int) int {
    return subtotal(quantity, price) + fee(weight, zone)
}

func demo() int {
    return quote(3, 10, 2, 1)
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 8. Rust

```rust
fn subtotal(quantity: i32, price: i32) -> i32 {
    quantity * price
}

fn fee(weight: i32, zone: i32) -> i32 {
    weight * 2 + zone * 5
}

fn quote(quantity: i32, price: i32, weight: i32, zone: i32) -> i32 {
    subtotal(quantity, price) + fee(weight, zone)
}

pub fn demo() -> i32 {
    quote(3, 10, 2, 1)
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## Проверка

Python, Java и C++17 исполнены с ожидаемыми результатами. TypeScript исполнен в Node с удалением аннотаций типов; отдельная статическая проверка TypeScript не выполнялась. Проверены два набора аргументов фасада и отдельные операции subtotal и fee. C#, Go и Rust проверены статически; их компиляторы в этой среде недоступны.

Метрики пересчитаны из восьми листингов этого файла. Ожидаемый результат LMX проверен по правилам языка; исполнение на ядре LMX не проводилось.

## Источники

Сетевые образцы использованы для проверки ролей шаблона. Показанные программы — самостоятельные адаптации общего сценария, а не подсчёт длины исходников этих страниц.

- [Refactoring.Guru — Facade in Python, conceptual example](https://refactoring.guru/design-patterns/facade/python/example)

[B]: https://chatgpt.com/library?file_id=libfile_fde3_f-a38201c30fb88191b7207c0e48955c30_bbe92b09b62881918d17958175103ded&account_id=personal
[D]: https://chatgpt.com/library?file_id=libfile_fde3_f-02443abbc4508191b7c8fd7894e3ac24_bbe92b09b62881918d17958175103ded&account_id=personal
[E]: https://chatgpt.com/library?file_id=libfile_fde3_f-9d15a59bc5d881918724924fcef45b04_bbe92b09b62881918d17958175103ded&account_id=personal
