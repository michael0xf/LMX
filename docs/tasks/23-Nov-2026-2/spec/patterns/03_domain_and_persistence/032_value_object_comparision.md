# 032. Value Object

Равенство определяется значением, а не адресом экземпляра.

**Отдельное сравнение реализации:** [096. Money value equality — implementation](096_money_value_equality_implementation_comparision.md)

## Общий сценарий

Сравнить отдельно созданные Money(100,840) и Money(100,840), затем Money(100,978). Currency — числовой код валюты.

**Ожидаемое наблюдение:** Первые два значения равны, третье отличается. demo кодирует эти две проверки как 10; идентичность объектов для равенства не требуется.

**Граница сравнения:** Использование библиотеки. Сравниваются только cents и currency двух уже допустимых Money-значений. Компоненты неизменяемы; низкоуровневая замена графовых фрагментов не является API компонента. Арифметика валют, хеширование и округление не включены. Клиент и полная реализация учитываются раздельно; типы и правила хранения языков не приравниваются.

LMX использует существующие средства ядра или явно названную компактную группу, определённую в связанном сравнении реализации. Иностранные клиенты используют настоящие средства языка или установленную библиотеку.

## LMX

```lmx
Demo:
    return: int
    run:
        throws: OperandArity
        import: MoneyLibrary\Equality
        @: money MoneyLibrary\immutable\Money
        @: first (copy(money))
        @: second (copy(money))
        @: third (merge(money; immutable: (int: currency 978)))
        return: (first equals second) * 10 + (first equals third)
```

Demo\run() возвращает 10: истина для first/second и ложь для first/third. Все клиенты используют готовый конкретный Money; его полная реализация и сравнение двух компонентов даны рядом. В исходном графе Money находится под сохранённым immutable, поэтому явные пути включают MoneyLibrary\immutable\Money. Внутри Money поля cents/currency — прямые terminal int; квалификация всего прототипа делает их значения immutable. copy создаёт отдельные контейнеры из этих полей. В merge второй источник — вызов immutable с одним анонимным контейнером (int: currency 978): результат имеет прямое immutable-поле currency и совместим с моделью. Это создание нового значения, без изменения существующего. equals наследует mode 0 и приоритет +, проверяет бинарную арность; скобки отделяют сравнения от арифметики. Встроенное сравнение ссылок не переопределяется.

[Отдельный листинг](examples/lmx/032_value_object.lm3)

## Python

```python
from dataclasses import dataclass

@dataclass(frozen=True, slots=True)
class Money:
    cents: int = 100
    currency: int = 840

def demo():
    first, second, third = Money(), Money(), Money(currency=978)
    return int(first == second) * 10 + int(first == third)
```

Реальный frozen dataclass и сгенерированное value equality; money.py не импортируется.

[Отдельный листинг](examples/python/032_value_object.py)

## C#

```csharp
public sealed record Money(int Cents = 100, int Currency = 840);
public static class Example {
    public static int Demo() {
        Money first = new(), second = new(), third = new(Currency: 978);
        return (first == second ? 10 : 0) + (first == third ? 1 : 0);
    }
}
```

Настоящий record class; оба поля и компонентное равенство сохранены.

[Отдельный листинг](examples/csharp/032_value_object.cs)

## Разбор LMX

Demo\run() возвращает 10: истина для first/second и ложь для first/third. Все клиенты используют готовый конкретный Money; его полная реализация и сравнение двух компонентов даны рядом. В исходном графе Money находится под сохранённым immutable, поэтому явные пути включают MoneyLibrary\immutable\Money. Внутри Money поля cents/currency — прямые terminal int; квалификация всего прототипа делает их значения immutable. copy создаёт отдельные контейнеры из этих полей. В merge второй источник — вызов immutable с одним анонимным контейнером (int: currency 978): результат имеет прямое immutable-поле currency и совместим с моделью. Это создание нового значения, без изменения существующего. equals наследует mode 0 и приоритет +, проверяет бинарную арность; скобки отделяют сравнения от арифметики. Встроенное сравнение ссылок не переопределяется.

## Сопоставление

Восстановлен исходный конечный договор 22-Nov и короткий LMX-клиент. Контрольные языки сохраняют естественные стандартные средства из 23-Nov. Узкая реализация LMX показана отдельно; более общий алгоритм 23-Nov имеет отдельный договор.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки | Без сложного Throws |
| --- | ---: | ---: | ---: |
| LMX | 239 | 10 | 239 |
| Python | 213 | 8 | — |
| C# | 203 | 7 | — |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Дополнительная колонка «без сложного Throws» оставляет заголовок и первый аргумент каждого списка в исходном порядке, полностью считает ссылки/copy и первый аргумент общего банка. Меняется только расчёт, не исходник или контракт.

## English explanation

Equality follows component values rather than object identity.

**Separate implementation comparison:** [096. Money value equality — implementation](096_money_value_equality_implementation_comparision.md)

**Scenario.** Compare distinct Money(100,840) values, then compare with Money(100,978). Currency is an integer code.

**Expected observation.** The first pair is equal and the third value differs. demo encodes the two checks as 10; equality does not require object identity.

**LMX.** Demo\run() returns 10: true for first/second, false for first/third. All clients use the ready concrete Money whose full two-component implementation is shown beside them. Money is under a retained immutable receiver, so explicit source paths include MoneyLibrary\immutable\Money. Its cents/currency children are direct terminal int declarations; qualifying the whole prototype makes their values immutable. copy constructs distinct containing Structures from those fields. The second merge source calls immutable with one anonymous Structure (int: currency 978); its result has a direct immutable currency field matching the model. This constructs a new value without mutating an existing one. equals inherits mode 0 and additive priority and checks binary arity; groups separate comparison from arithmetic. Built-in reference comparison is not overridden.

**Comparison.** The finite 22-Nov contract and short LMX client are restored. Controls retain the natural standard facilities from 23-Nov. The narrow LMX implementation is shown separately; the wider 23-Nov algorithm has its own contract.

**Scope and limitations.** Only cents and currency of already admissible Money values are compared. Components are read-only; low-level graph-fragment replacement is not part of the component API. Currency arithmetic, hashing, and rounding are excluded. Client and full implementation are counted separately; language type and storage guarantees are not equated.

### Dependencies and execution boundaries

- **LMX:** Demo\run() returns 10: true for first/second, false for first/third. All clients use the ready concrete Money whose full two-component implementation is shown beside them. Money is under a retained immutable receiver, so explicit source paths include MoneyLibrary\immutable\Money. Its cents/currency children are direct terminal int declarations; qualifying the whole prototype makes their values immutable. copy constructs distinct containing Structures from those fields. The second merge source calls immutable with one anonymous Structure (int: currency 978); its result has a direct immutable currency field matching the model. This constructs a new value without mutating an existing one. equals inherits mode 0 and additive priority and checks binary arity; groups separate comparison from arithmetic. Built-in reference comparison is not overridden.
- **Python:** Real frozen dataclass and generated value equality; no money.py import.
- **C#:** Real record class; both fields and component equality are preserved.

## Источники / Sources

- [Python dataclasses](https://docs.python.org/3/library/dataclasses.html) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.
- [C# records](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/types/records) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
