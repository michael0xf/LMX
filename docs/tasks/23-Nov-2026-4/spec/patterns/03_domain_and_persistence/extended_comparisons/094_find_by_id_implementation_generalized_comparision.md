# 094. FindFirst — generic implementation: общий договор

Действующие общие определения извлечены из единого ядра. Эта отдельная пара сохраняет свой договор; её размер не подменяет размер клиентского вызова.

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

Точные общие определения FxFindFirst из текущего ядра. Общий договор сохраняет явно указанные типы, контекст вызова и отказы. Копия обновляется из единственного исходника; runtime LMX — NOT_RUN.

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

Полный текст каждого листинга включает все объявления, заголовки Throws, аргументы и ссылки; исключений из подсчёта нет.

[Основная пара](../094_find_by_id_implementation_comparision.md). [Единые формы](../../UNIFIED_OPERATIONS.md).

Результаты языкового выполнения изменённых исходников не заявлены.
