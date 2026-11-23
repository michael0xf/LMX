# 094. FindFirst — generic implementation

Реализовать общий поиск первого совпадения с явным признаком присутствия.

**Примеры использования:** [016. Repository](016_repository_comparision.md)

## Общий сценарий

Просмотреть значения до первого accepts(value); вернуть присутствующее значение или отсутствие, сохранив identity Account.

**Ожидаемое наблюдение:** Пустой ввод/нет совпадений дают отсутствие; дубликаты — первый; найденный null/default остаётся присутствующим; отказ predicate передаётся дальше.

**Граница сравнения:** Реализация библиотеки. Конечные последовательности без изменения во время обхода. Ошибки predicate обычные; ссылки сохраняют владельца/lifetime. Неявного копирования/асинхронного scheduler нет.

Это самостоятельное сравнение реализаций. Весь показанный код считается здесь; связанные иностранные клиенты используют настоящие библиотечные средства. Общие runtime-примитивы и их границы перечислены отдельно.

## LMX

```lmx
FxFindFirst:
    private:
        @: items
        @: accepts
    required: items accepts
    return: @
    findFirst:
        throws: copy(FxThrows\predicate)
        FxSeqInfo\get(items)
        private: int: count length(items)
        private: int: i 0
        while: i < count
            private: @: value FxSeqRead\read(items; i)
            private: @: accepted FxApply\apply(accepts; FxOne\make(value))
            if: FxSeqPredicate\truth(accepted) != 0
                return: FxSome\some(value := value)
            i += 1
        return: FxNone\none()
```

Полный поиск произвольного элемента по callable predicate; typed access поддерживает dense arrays и Structure/@[].

[Отдельный листинг](examples/lmx/094_find_by_id_implementation.lm3)

## Python

```python
def find_first(items, accepts):
    if not callable(accepts): raise TypeError("accepts must be callable")
    for item in items:
        if accepts(item): return True, item
    return False, None
```

Отдельная generic реализация; пара found/value различает найденный None и отсутствие. Predicate не вызывается после первого совпадения.

[Отдельный листинг](examples/python/094_find_by_id_implementation.py)

## C#

```csharp
#nullable enable
using System;
using System.Collections.Generic;
public static class FirstMatch {
    public static (bool Found, T? Value) FindFirst<T>(IEnumerable<T> items, Func<T,bool> accepts) {
        ArgumentNullException.ThrowIfNull(items);
        ArgumentNullException.ThrowIfNull(accepts);
        foreach (T item in items) if (accepts(item)) return (true, item);
        return (false, default);
    }
}
```

Общий цикл по T, ранний выход и явное отсутствие; foreach корректно освобождает enumerator.

[Отдельный листинг](examples/csharp/094_find_by_id_implementation.cs)

## Разбор LMX

Полный поиск произвольного элемента по callable predicate; typed access поддерживает dense arrays и Structure/@[].

## Сопоставление

Циклы полностью выписаны во всех языках; здесь не вызываются next/FirstOrDefault. Нет привязки к Account/id/int или фиксированной длине.

## Объём показанного исходника

| Язык | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX | 371 | 18 |
| Python | 153 | 5 |
| C# | 336 | 11 |

Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).

## English explanation

Implement generic first-match search with explicit presence and arbitrary predicates.

**Usage examples:** [016. Repository](016_repository_comparision.md)

**Scenario.** Scan ordered values until accepts(value) is true; return a tagged present value or absence. Preserve the original Account identity for the Repository fixture.

**Expected observation.** Empty and no-match inputs are absent; duplicates return the first; a matching null/default value remains present; predicate failures propagate.

**LMX.** Complete arbitrary-element predicate search; typed access supports dense arrays and Structure/@[].

**Comparison.** The loops are fully written in all languages. The controls do not call next/FirstOrDefault here. No implementation hardcodes Account, id, int, or a fixed sequence length.

**Scope and limitations.** Finite ordered sequences; no mutation during traversal. Predicate exceptions retain the language’s ordinary failure mechanism. Returned references retain the original owner/lifetime; no implicit copy or asynchronous scheduler is needed.

### Dependencies and execution boundaries

- **LMX:** Complete arbitrary-element predicate search; typed access supports dense arrays and Structure/@[].
- **Python:** Separate generic implementation; found/value distinguishes a found None from absence. No predicate call follows the first match.
- **C#:** Generic T loop, early exit, and explicit absence; foreach disposes its enumerator.

## Источники / Sources

- [LINQ FirstOrDefault contract](https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.firstordefault) — Официальный контракт; самостоятельные реализации написаны для указанной границы сравнения.

**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).

## Проверка

Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).
