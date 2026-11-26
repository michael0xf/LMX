# 103. Union–find / непересекающиеся множества

Объединить произвольную последовательность пар и вернуть представителя компоненты каждой вершины.

## Договор и полезный результат

n — неотрицательное число элементов 0..n-1. pairs — конечная последовательность двухэлементных пар допустимых индексов. Начально каждый элемент образует своё множество. Для каждой пары корни находятся с path halving; меньшая компонента прикрепляется к большей. При равных размерах выигрывает корень первого аргумента пары. Повторное объединение одной компоненты и self-union ничего не меняют. Результат — n представителей после всех операций; входные пары не меняются. n=0 допускает только пустой список пар и возвращает []. Наблюдаемы точные представители согласно правилу tie, а не только совпадение количества компонент.

## Почему эти языки

C++ и Java — характерные языки реализаций индексных структур данных. В обоих есть изменяемые плотные массивы, поэтому сравниваются одинаковые union-by-size и path-halving, а не persistent-структура против изменяемого массива.

## Алгоритм, источники и стоимость

Приведённая авторами Algorithms реализация связывает компоненты по размеру и сокращает путь переходом к деду; в описании разделены худшая стоимость отдельной операции и амортизированная оценка последовательности.

[Sedgewick / Wayne: weighted union with path halving](https://algs4.cs.princeton.edu/15uf/WeightedQuickUnionPathHalvingUF.java.html).

Инициализация O(n); для m объединений и финального обхода стандартная амортизированная оценка — O(n+(m+n)α(n)), O(n) памяти. Отдельная операция не объявлена безусловно O(1). Функциональная форма добавляет временные map-результаты O(n).

C++ vector(n,value) и Java Arrays.fill задают исходные значения. LMX использует общий fill для того же действия; parent[i]=i показан как часть алгоритма, поэтому новый специальный iota не спрятан в примере.

## LMX: общий договор двух форм

Само локальное сжатие пути и объединение — одно общее изменяемое тело. Процедурная форма содержит циклы инициализации, объединений и выдачи результата; функциональная выражает эти проходы через map/foldl/map. Это максимальное использование имеющихся общих проходов при сохранении данного алгоритма; превращение рабочего леса в persistent-значение изменило бы договор представления и стоимость, поэтому здесь такого утверждения нет.

Выбираемый driver — часть fixture, а не особая точка запуска. Корень поднимается как L3 Thread без DATA; указанный ниже обычный вызов выполняется после запуска. Общие методы доступны в том же графе, а динамически передаваемые рабочие переменные не помечены private.

| Стиль | Обычный вызов после запуска |
| --- | --- |
| Процедурный | `UnionFind\run(n; pairs; DsuProcedural\run)` |
| Функциональный | `UnionFind\run(n; pairs; DsuFunctional\run)` |

[Общий AlgorithmArray — полное тело](README.md#общая-подготовка-массива), [исходник](examples/lmx/common/array.lm3), выделяет массив и явно заполняет его через [ядровый fill](../LMX_Fn_Receivers/src/fill.lmx). Его тело входит в полную границу каждого стиля один раз. Оно не предполагает нулевого результата resize и не скрывает алгоритм задачи.

### Общая реализация подготовки и шага

[Исходник](examples/lmx/common/103_union_find.lm3). Это необходимая часть обоих полных листингов; её стоимость не исчезает при сравнении.

```lmx
UnionFind:
    int: n
    @: pairs
    @: traverse
    return: @
    run:
        throws: copy(AlgorithmArray\make\throws) copy(FxSeqAllocate\make\throws) copy(FxApply\apply\throws)
        @: parent FxSeqAllocate\make([]int; n)
        @: size AlgorithmArray\make([]int; n; (1 record))
        @: labels FxSeqAllocate\make([]int; n)
        FxApply\apply(traverse; ())
        return: labels

DsuInitialize:
    int: vertex
    return: int
    run:
        throws: ReceiverIndex
        parent[vertex] := vertex
        return: vertex

DsuRoot:
    int: vertex
    return: int
    run:
        throws: ReceiverIndex
        while: parent[vertex] != vertex
            parent[vertex] := parent[parent[vertex]]
            vertex := parent[vertex]
        return: vertex

DsuJoin:
    int: count
    @: pair
    return: int
    run:
        throws: copy(DsuRoot\run\throws)
        int: a DsuRoot\run(pair[0])
        int: b DsuRoot\run(pair[1])
        if: a = b
            return: count
        if: size[a] < size[b]
            (a b) .: (b a)
        parent[b] := a
        size[a] += size[b]
        return: count - 1

DsuEmit:
    int: vertex
    return: int
    run:
        throws: copy(DsuRoot\run\throws)
        labels[vertex] := DsuRoot\run(vertex)
        return: labels[vertex]
```

## LMX — процедурный

[Исходник](examples/lmx/procedural/103_union_find.lm3); требуется общая часть выше.

```lmx
DsuProcedural:
    return: int
    run:
        throws: copy(DsuInitialize\run\throws) copy(DsuJoin\run\throws) copy(DsuEmit\run\throws)
        int: vertex 0
        while: vertex < n
            DsuInitialize\run(vertex)
            vertex += 1
        int: count n
        int: i 0
        while: i < length(pairs)
            count := DsuJoin\run(count; pairs[i])
            i += 1
        vertex := 0
        while: vertex < n
            DsuEmit\run(vertex)
            vertex += 1
        return: count
```

## LMX — функциональный

[Исходник](examples/lmx/103_union_find.lm3); требуется общая часть выше.

```lmx
DsuFunctional:
    return: int
    run:
        throws: copy(range\throws) copy(map\throws) copy(foldl\throws)
        @: vertices range(0; n)
        map(vertices; DsuInitialize\run)
        int: count \foldl(pairs; (n record); DsuJoin\run)
        map(vertices; DsuEmit\run)
        return: count
```

## C++

[Полный исходник](examples/cpp/103_union_find.cpp).

```cpp
#include <array>
#include <utility>
#include <vector>

std::vector<int> unionFind(int n, const std::vector<std::array<int, 2>>& pairs) {
    std::vector<int> parent(n), size(n, 1), labels(n);
    for (int vertex = 0; vertex < n; ++vertex) parent[vertex] = vertex;
    const auto root = [&](int vertex) {
        while (parent[vertex] != vertex) {
            parent[vertex] = parent[parent[vertex]];
            vertex = parent[vertex];
        }
        return vertex;
    };
    for (const auto& pair : pairs) {
        auto a = root(pair[0]), b = root(pair[1]);
        if (a == b) continue;
        if (size[a] < size[b]) std::swap(a, b);
        parent[b] = a;
        size[a] += size[b];
    }
    for (int vertex = 0; vertex < n; ++vertex) labels[vertex] = root(vertex);
    return labels;
}
```

## Java

[Полный исходник](examples/java/103_union_find.java).

```java
import java.util.Arrays;

final class UnionFindExample {
    private static int root(int[] parent, int vertex) {
        while (parent[vertex] != vertex) {
            parent[vertex] = parent[parent[vertex]];
            vertex = parent[vertex];
        }
        return vertex;
    }

    static int[] run(int n, int[][] pairs) {
        int[] parent = new int[n], size = new int[n], labels = new int[n];
        Arrays.fill(size, 1);
        for (int vertex = 0; vertex < n; ++vertex) parent[vertex] = vertex;
        for (int[] pair : pairs) {
            int a = root(parent, pair[0]), b = root(parent, pair[1]);
            if (a == b) continue;
            if (size[a] < size[b]) {
                int saved = a;
                a = b;
                b = saved;
            }
            parent[b] = a;
            size[a] += size[b];
        }
        for (int vertex = 0; vertex < n; ++vertex) labels[vertex] = root(parent, vertex);
        return labels;
    }
}
```

## Контрольные сценарии

Все фиксированные случаи этой задачи из [cases.json](tests/cases.json) приведены ниже; алгоритм принимает и остальные допустимые входы.

| Случай | Вход | Ожидаемый результат |
| --- | --- | --- |
| `dsu_empty` | `{"n":0,"pairs":[]}` | `[]` |
| `dsu_tie_and_repeat` | `{"n":6,"pairs":[[0,1],[2,3],[1,3],[4,4],[0,2]]}` | `[0,0,0,0,4,5]` |
| `dsu_size_wins` | `{"n":5,"pairs":[[1,2],[1,3],[0,3]]}` | `[1,1,1,1,4]` |

## Сравнительная публикация и проверка

Полные размеры обеих LMX-форм пересчитаны по текущим исходникам и приведены ниже. Общие части входят в каждую использующую их границу ровно один раз; все объявления и Throws сохранены.

Иностранные программы проверены [воспроизводимым runner](tests/run_foreign.py), фиксированными случаями и 120 генерируемыми входами на задачу. [Отчёт исполнения](tests/validation.json) различает это от неподтверждённого исполнения LMX. Callback и resource failures не заменяются фиктивным успехом; нарушение явно перечисленных предусловий не является заявленным API восстановления ошибок.

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 1370 | 77 |
| LMX — функциональный | 1279 | 68 |
| C++ | <span style="color:#176233"><u>578</u></span> | 23 |
| Java | 608 | 28 |

Для каждой LMX-формы считаются все её source_files, включая общие определения ровно один раз. Все объявления и Throws входят в размер. Зелёным подчёркнут минимум полного сопоставимого листинга; равные минимумы выделены вместе.
