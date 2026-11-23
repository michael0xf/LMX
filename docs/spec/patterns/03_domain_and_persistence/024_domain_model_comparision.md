# 024. Domain Model

Разместить бизнес-инвариант рядом с доменным состоянием.

## Общий сценарий

Счёт с 100 единицами принимает debit(30), затем debit(80). Только неотрицательная сумма в пределах остатка разрешена.

**Ожидаемое наблюдение:** Первая операция оставляет 70; вторая завершается Funds/исключением и оставляет 70.

**Граница сравнения:** Ядро сценария. Целые единицы исключают округление. Одновременный доступ требует владельца Message либо выбранного механизма синхронизации; пример однопоточный.

## LMX

```lmx
Account:
    int: balance 100
    int: amount
    return: int
    debit:
        throws: Funds
        if: amount < 0 || amount > node\balance
            throw: Funds()
        node\balance -= amount
        return: node\balance
```

node\balance — явное доменное состояние выбранного экземпляра. Обычное balance := ... изменяло бы локальное место вызова.

[Отдельный листинг](examples/lmx/024_domain_model.lm3)

## Python

```python
class Account:
    def __init__(self, balance=100): self.balance = balance
    def debit(self, amount):
        if amount < 0 or amount > self.balance: raise ValueError('funds')
        self.balance -= amount
        return self.balance
```

Целые единицы исключают округление. Одновременный доступ требует владельца Message либо выбранного механизма синхронизации; пример однопоточный.

[Отдельный листинг](examples/python/024_domain_model.py)

## C#

```csharp
using System;
public sealed class Account(int balance=100) {
    public int Balance { get; private set; } = balance;
    public int Debit(int amount) {
        if (amount < 0 || amount > Balance) throw new InvalidOperationException("funds");
        Balance -= amount;
        return Balance;
    }
}
```

Целые единицы исключают округление. Одновременный доступ требует владельца Message либо выбранного механизма синхронизации; пример однопоточный.

[Отдельный листинг](examples/csharp/024_domain_model.cs)

## Разбор LMX

node\balance — явное доменное состояние выбранного экземпляра. Обычное balance := ... изменяло бы локальное место вызова.

## Сопоставление

Данные и правило принадлежат одному доменному компоненту во всех языках; зависимости от БД нет.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки | Без сложного Throws |
| --- | ---: | ---: | ---: |
| LMX | 144 | 10 | 144 |
| Python | 179 | 6 | — |
| C# | 224 | 9 | — |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Дополнительная колонка «без сложного Throws» оставляет заголовок и первый аргумент каждого списка в исходном порядке, полностью считает ссылки/copy и первый аргумент общего банка. Меняется только расчёт, не исходник или контракт.

## English explanation

Keep a business invariant with domain state.

**Scenario.** An account starts at 100; debit 30, then attempt 80. Only nonnegative amounts within the balance are valid.

**Expected observation.** The first debit returns 70; the second raises Funds/an exception and leaves 70 unchanged.

**LMX.** node\balance selects instance state. An unqualified assignment would update the invocation local.

**Comparison.** Every version combines data and the invariant without a persistence dependency.

**Scope and limitations.** Integer units avoid rounding. Concurrent access needs an owner Message or another explicit synchronization policy; this is a serial core.

### Dependencies and execution boundaries

- **LMX:** node\balance selects instance state. An unqualified assignment would update the invocation local.
- **Python:** Integer units avoid rounding. Concurrent access needs an owner Message or another explicit synchronization policy; this is a serial core.
- **C#:** Integer units avoid rounding. Concurrent access needs an owner Message or another explicit synchronization policy; this is a serial core.

## Источники / Sources

- [Martin Fowler — Domain Model](https://martinfowler.com/eaaCatalog/domainModel.html) — Определение и границы паттерна.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
