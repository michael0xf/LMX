# 13. Proxy: LMX и семь других языков

20 ноября 2026 года. Обновлено 21 ноября 2026 года. Продолжение серии: шаблоны 10–18.

## Задача

Служба удваивает число. Прокси допускает только неотрицательные значения, возвращая 0 при отказе. Одна переменная request сначала обозначает прокси, затем саму службу: вызывающий сохраняет ту же форму обращения.

**Внешний вызов LMX:** `requests\demo()`. **Ожидаемый результат: 8.**

Это минимальный защитный прокси с фиксированной службой и числовым правилом допуска. Различаются отказ и делегирование; полноценная авторизация, кэш и общий конструктор прокси в сценарий не входят. Политика задана самим примером, а не языком.

## Архитектура LMX

Python real, proxy и demo собраны в одну группу requests. Общий DATA содержит value и тип результата. proxy вызывает real() с автопередачей value. demo хранит и меняет обычную ссылку на метод. Нет отдельного объекта-обёртки, потому что этот прокси не хранит состояния.

Применены согласованные правила: DATA метода — его фактический parent; обычные ссылки на методы не требуют отдельного `fn`; объявленные входы без initializer допускают autofill, свободные имена — связь с местом непосредственного caller. `node\` выбирает лексическую связь. Пустая строка завершает корневой блок. [Связывание](../LMX_semantics.en.md#binding-places) · [Импорт](../LMX_semantics.en.md#import-receiver) · [Границы блоков](../LMX_grammar.en.md#levels)

## Подсчёт исходников

Главная метрика — **непробельные символы**: `sum(not ch.isspace() for ch in code)`. Дополнительно показаны полный размер и число физических строк. Нормализация: LF, без пустых строк по краям, один LF в конце.

В подсчёт входят весь показанный исходник, импорты, необходимые языковые оболочки и `demo`. Внешний запуск, `main`, печать результата, тестовая обвязка и реализация стандартной библиотеки/runtime не включены. Имена не нормализованы. Python записан без необязательных аннотаций типов. Сравниваются конкретные реализации одной задачи; это не оценка быстродействия или одинаковых статических гарантий.

| Язык | Непробельных символов | Всего символов | Строк | К размеру LMX | Без сложного Throws |
|---|---:|---:|---:|---:|---:|
| LMX | 191 | 325 | 15 | 1.00× | 191 |
| Python | 181 | 259 | 14 | 0.95× | — |
| Java | 346 | 493 | 20 | 1.81× | — |
| C++ | 209 | 290 | 16 | 1.09× | — |
| C# | 274 | 424 | 20 | 1.43× | — |
| TypeScript | 256 | 340 | 16 | 1.34× | — |
| Go | 217 | 315 | 20 | 1.14× | — |
| Rust | 220 | 323 | 18 | 1.15× | — |

Общая таблица серии доступна в [Excel](LMX_Comparison_10-18.xlsx) и [PDF](LMX_Comparison_10-18.pdf).

## 1. LMX

```lmx
requests:
    int: value
    return: int
    real:
        return: value * 2
    proxy:
        if: value < 0
            return: 0
        return: real()
    demo:
        @: request proxy
        int: denied request(-3)
        int: allowed request(7)
        request := real
        return: denied + allowed + request(-3)
```

Внешний вызов: `requests\demo()`. Он не входит в подсчёт.

request(-3) через proxy возвращает 0, не вызывая real. request(7) делегирует и даёт 14. После request := real тот же отрицательный запрос возвращает −6. Итог demo: 0 + 14 − 6 = 8.

## 2. Python

```python
def real(value):
    return value * 2

def proxy(value):
    if value < 0:
        return 0
    return real(value)

def demo():
    request = proxy
    denied = request(-3)
    allowed = request(7)
    request = real
    return denied + allowed + request(-3)
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 3. Java

```java
import java.util.function.IntUnaryOperator;

class Example {
    static int real(int value) {
        return value * 2;
    }

    static int proxy(int value) {
        if (value < 0) return 0;
        return real(value);
    }

    static int demo() {
        IntUnaryOperator request = Example::proxy;
        int denied = request.applyAsInt(-3);
        int allowed = request.applyAsInt(7);
        request = Example::real;
        return denied + allowed + request.applyAsInt(-3);
    }
}
```

Внешний вызов: `Example.demo()`. Он не входит в подсчёт.

## 4. C++

```cpp
int real(int value) {
    return value * 2;
}

int proxy(int value) {
    if (value < 0) return 0;
    return real(value);
}

int demo() {
    auto request = proxy;
    int denied = request(-3);
    int allowed = request(7);
    request = real;
    return denied + allowed + request(-3);
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 5. C#

```csharp
using System;

static class Example {
    static int Real(int value) {
        return value * 2;
    }

    static int Proxy(int value) {
        if (value < 0) return 0;
        return Real(value);
    }

    public static int Demo() {
        Func<int, int> request = Proxy;
        int denied = request(-3);
        int allowed = request(7);
        request = Real;
        return denied + allowed + request(-3);
    }
}
```

Внешний вызов: `Example.Demo()`. Он не входит в подсчёт.

## 6. TypeScript

```typescript
function real(value: number): number {
    return value * 2;
}

function proxy(value: number): number {
    if (value < 0) return 0;
    return real(value);
}

function demo(): number {
    let request = proxy;
    const denied = request(-3);
    const allowed = request(7);
    request = real;
    return denied + allowed + request(-3);
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 7. Go

```go
package main

func real(value int) int {
    return value * 2
}

func proxy(value int) int {
    if value < 0 {
        return 0
    }
    return real(value)
}

func demo() int {
    request := proxy
    denied := request(-3)
    allowed := request(7)
    request = real
    return denied + allowed + request(-3)
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## 8. Rust

```rust
fn real(value: i32) -> i32 {
    value * 2
}

fn proxy(value: i32) -> i32 {
    if value < 0 {
        return 0;
    }
    real(value)
}

pub fn demo() -> i32 {
    let mut request: fn(i32) -> i32 = proxy;
    let denied = request(-3);
    let allowed = request(7);
    request = real;
    denied + allowed + request(-3)
}
```

Внешний вызов: `demo()`. Он не входит в подсчёт.

## Проверка

В этой редакции проверены согласованность LMX-листинга с документами `docs`, явная группировка результатов копирования/композиции там, где нужен один объект, и ссылки на правила языка. Ожидаемый результат LMX следует из показанного сценария; запуск ядра не проводился.

Листинги Python, Java, C++, C#, TypeScript, Go и Rust сохранены из исходного сравнения. Сообщения исходной редакции об их выполнении относятся к той проверке; это обновление документации не выдаёт их за новый запуск. Подсчёт размеров выполняется заново по листингам текущего файла.

## Источники

Сетевые образцы использованы для проверки ролей шаблона. Показанные программы — самостоятельные адаптации общего сценария, а не подсчёт длины исходников этих страниц.

- [Refactoring.Guru — Proxy in Python, conceptual example](https://refactoring.guru/design-patterns/proxy/python/example)

