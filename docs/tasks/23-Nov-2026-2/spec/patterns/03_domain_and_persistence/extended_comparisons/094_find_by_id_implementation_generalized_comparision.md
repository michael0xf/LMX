# 094. FindFirst — generic implementation: отдельный расширенный договор

Сохранена самостоятельная обобщённая реализация 23-Nov. Она решает более широкую задачу, чем восстановленная основная пара 22-Nov, и не участвует в её сумме или выборе кратчайшего листинга.

## Договор

Просмотреть значения до первого accepts(value); вернуть присутствующее значение или отсутствие, сохранив identity Account.

Пустой ввод/нет совпадений дают отсутствие; дубликаты — первый; найденный null/default остаётся присутствующим; отказ predicate передаётся дальше.

Конечные последовательности без изменения во время обхода. Ошибки predicate обычные; ссылки сохраняют владельца/lifetime. Неявного копирования/асинхронного scheduler нет.

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

[Исходник](source/lmx/094_find_by_id_implementation_generalized.lm3)

Полный поиск произвольного элемента по callable predicate; typed access поддерживает dense arrays и Structure/@[].

## Python

```python
def find_first(items, accepts):
    if not callable(accepts): raise TypeError("accepts must be callable")
    for item in items:
        if accepts(item): return True, item
    return False, None
```

[Исходник](source/python/094_find_by_id_implementation_generalized.py)

Отдельная generic реализация; пара found/value различает найденный None и отсутствие. Predicate не вызывается после первого совпадения.

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

[Исходник](source/csharp/094_find_by_id_implementation_generalized.cs)

Общий цикл по T, ранний выход и явное отсутствие; foreach корректно освобождает enumerator.

## Измерение отдельной реализации

| Язык | Непробельные символы |
| --- | ---: |
| LMX | 371 |
| Python | 153 |
| C# | 336 |

[Основная узкая пара](../094_find_by_id_implementation_comparision.md). [Норма LMX](../../../LMX_semantics.en.md).

LMX здесь не выполнялся. Это сохранение исходников и их договора, а не новый отчёт о runtime-проверке.
