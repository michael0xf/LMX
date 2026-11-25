# 100. Lower bound / двоичный поиск границы

Найти первую позицию, на которой элемент перестаёт быть меньше ключа; равные значения остаются справа от границы.

## Договор и полезный результат

items — конечная random-access последовательность любого допустимого типа; needle — самостоятельное значение, необязательно того же типа. less(element, needle) — стабильный полный int-предикат без изменения inputs. Для выбранного ключа вход заранее разбит на true-префикс и false-суффикс. Возвращается индекс первой false-позиции, либо n. Отсортированность не проверяется линейным проходом; равенство вообще не вызывается. Пустой вход даёт 0 без вызова less. В LMX needle передаётся как одна готовая запись `(needle record)`; существующий FxApply допускает фактические типы элементов и ключа. Поэтому нет ограничения ни на int, ни на одинаковый тип аргументов comparator.

## Почему эти языки

C++ представляет generic algorithms и явный comparator; Python — обычные упорядоченные коллекции и bisect. В основных листингах обе стороны показывают двоичный алгоритм, поэтому размер вызова готовой библиотеки не сравнивается с чужим телом.

## Алгоритм, источники и стоимость

Контракт разбиения и логарифмическое число сравнений описаны в working draft C++; Python bisect_left возвращает левую границу и использует порядок без проверки равенства.

[C++ working draft: lower_bound](https://eel.is/c++draft/lower.bound); [Python: bisect_left](https://docs.python.org/3/library/bisect.html).

Процедурная форма: O(log(n+1)) обращений к random-access входу и comparator, O(1) дополнительных значений. Функциональная форма рекурсивно сужает тот же интервал и имеет O(log(n+1)) глубину вызовов без предположения об оптимизации хвостовой рекурсии. Стоимость callback оплачивается отдельно.

Готовые API std::lower_bound и bisect_left уже выражают предметную операцию. Её общий LMX-аналог lowerBound включён в ядро; данная страница сравнивает реализацию. Дополнительные пользовательские клиенты должны одинаково использовать готовые API на всех сторонах.

## LMX: общий договор двух форм

Обе формы выбирают один и тот же middle и дают одинаковую последовательность вызовов less. Процедурный канонический исходник размещён в общем ядре как FxLowerBound; файл в procedural — только fixture-alias, он не заменяет тело при измерении. Функциональная форма показывает самостоятельную рекурсивную реализацию без while.

Выбираемый driver — часть fixture, а не особая точка запуска. Корень поднимается как L3 Thread без DATA; указанный ниже обычный вызов выполняется после запуска. Общие методы доступны в том же графе, а динамически передаваемые рабочие переменные не помечены private.

| Стиль | Обычный вызов после запуска |
| --- | --- |
| Процедурный | `FxLowerBound\lowerBound(items; needleRecord; less)` |
| Функциональный | `LowerBound\run(items; needleRecord; less)` |

## LMX — процедурный

Ниже приведён полный [канонический исходник ядра](../LMX_Fn_Receivers/src/lowerBound.lmx); fixture-alias из procedural сам по себе не является измеряемой реализацией.

```lmx
FxLowerBound:
    private:
        @: items
        @: needle
        @: less
    required: items needle less
    return: int
    lowerBound:
        throws: copy(FxSeqInfo\get\throws) copy(FxSeqRead\read\throws) copy(FxApply\apply\throws) copy(FxSeqPredicate\truth\throws)
        FxSeqInfo\get(items)
        int: low 0
        int: high length(items)
        while: low < high
            int: middle low + (high - low) / 2
            @: item FxSeqRead\read(items; middle)
            @: flag FxApply\apply(less; FxTwo\make(item; needle))
            if: FxSeqPredicate\truth(flag) != 0
                low := middle + 1
            else:
                high := middle
        ---
        return: low
```

## LMX — функциональный

[Исходник](examples/lmx/100_lower_bound.lm3).

```lmx
LowerBoundStep:
    int: low
    int: high
    return: int
    search:
        throws: copy(FxSeqRead\read\throws) copy(FxApply\apply\throws) copy(FxSeqPredicate\truth\throws)
        if: low >= high
            return: low
        int: middle low + (high - low) / 2
        @: item FxSeqRead\read(items; middle)
        @: flag FxApply\apply(less; FxTwo\make(item; needle))
        if: FxSeqPredicate\truth(flag) != 0
            return: search(middle + 1; high)
        return: search(low; middle)

LowerBound:
    @: items
    @: needle
    @: less
    return: int
    run:
        throws: copy(FxSeqInfo\get\throws) copy(LowerBoundStep\search\throws)
        FxSeqInfo\get(items)
        return: LowerBoundStep\search(0; length(items))
```

## Python

[Полный исходник](examples/python/100_lower_bound.py).

```python
from operator import lt


def lower_bound(items, needle, less=lt):
    low, high = 0, len(items)
    while low < high:
        middle = low + (high - low) // 2
        if less(items[middle], needle):
            low = middle + 1
        else:
            high = middle
    return low
```

## C++

[Полный исходник](examples/cpp/100_lower_bound.cpp).

```cpp
#include <cstddef>
#include <functional>
#include <vector>

template<class T, class U, class Less = std::less<>>
std::size_t lowerBound(const std::vector<T>& items, const U& needle, Less less = {}) {
    std::size_t low = 0, high = items.size();
    while (low < high) {
        const auto middle = low + (high - low) / 2;
        if (less(items[middle], needle)) low = middle + 1;
        else high = middle;
    }
    return low;
}
```

## Контрольные сценарии

Все фиксированные случаи этой задачи из [cases.json](tests/cases.json) приведены ниже; алгоритм принимает и остальные допустимые входы.

| Случай | Вход | Ожидаемый результат |
| --- | --- | --- |
| `lb_empty` | `{"items":[],"needle":2}` | `0` |
| `lb_duplicates` | `{"items":[1,2,2,2,7],"needle":2}` | `1` |
| `lb_after` | `{"items":[1,2,7],"needle":8}` | `3` |
| `lb_before` | `{"items":[1,2,7],"needle":-5}` | `0` |
| `lb_between` | `{"items":[1,4,7],"needle":5}` | `2` |

## Сравнительная публикация и проверка

| Вариант | Граница | Символы / строки | Исполнение |
| --- | --- | --- | --- |





Метрики и победители сейчас не объявляются: пользователь явно отложил пересчёт. Будущая сборка должна учитывать каждую LMX-форму, все её локальные closure_sources, декларации и throws; стандартные зависимости отмечены отдельно. Колонки «без сложного throws» нет. Для равных минимальных полных чисел действует обычное зелёное подчёркивание всех победителей.

Иностранные программы проверены [воспроизводимым runner](tests/run_foreign.py), фиксированными случаями и 120 генерируемыми входами на задачу. [Отчёт исполнения](tests/validation.json) различает это от неподтверждённого исполнения LMX. Callback и resource failures не заменяются фиктивным успехом; нарушение явно перечисленных предусловий не является заявленным API восстановления ошибок.

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 453 | 22 |
| LMX — функциональный | 534 | 23 |
| Python | <span style="color:#176233"><u>182</u></span> | 10 |
| C++ | 328 | 13 |

Для каждой LMX-формы считаются все её source_files, включая общие определения ровно один раз. Все объявления и Throws входят в размер. Зелёным подчёркнут минимум полного сопоставимого листинга; равные минимумы выделены вместе.
