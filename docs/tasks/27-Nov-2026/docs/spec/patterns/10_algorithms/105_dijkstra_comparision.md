# 105. Dijkstra / кратчайшие взвешенные пути

Вычислить кратчайшие расстояния в ориентированном графе с неотрицательными весами.

## Договор и полезный результат

graph — массив строк рёбер [vertex, weight]; вершины 0..V-1, веса — точные неотрицательные целые. Самопетли, нулевые веса и кратные рёбра разрешены. При V>0 start допустим; при V=0 используется start=-1. Результат содержит V точных расстояний, -1 обозначает недостижимую вершину. Общая область сравнения требует, чтобы все рассматриваемые суммы distance[u]+weight помещались в signed 64-bit; LMX сохраняет их в []bigint, Python — в int, C++ — в int64_t. Это явная общая граница машинной C++-реализации, не свойство bigint LMX. При равном расстоянии первой выбирается меньшая вершина; исходный graph не меняется. Отрицательные веса не входят в договор и не проверяются скрытым дополнительным проходом.

## Почему эти языки

C++ естественен для численных графовых алгоритмов с явной стоимостью памяти, Python — для компактной проверяемой реализации. Во всех языках используется одна версия с линейным поиском минимальной unsettled-вершины; heap отсутствует на обеих сторонах.

## Алгоритм, источники и стоимость

Boost.Graph описывает выбор минимальной текущей метки, релаксацию и требование неотрицательных весов. Его готовая библиотечная реализация использует очередь приоритетов; её более сильная оценка не перенесена на показанный здесь линейный выбор.

[Boost.Graph: Dijkstra shortest paths](https://www.boost.org/doc/libs/1_82_0/libs/graph/doc/dijkstra_shortest_paths.html).

Именно для приведённых тел: O(V²+E) времени и O(V) основного рабочего состояния. Эта оценка следует из не более V выборов минимума по V вершинам и одного рассмотрения каждого достижимого ребра. Функциональные range/collect добавляют временные последовательности O(V) живого размера, а не меняют алгоритм на heap-вариант.

heapq и priority_queue не подключены и не заменены несуществующей функцией LMX. Общие map/foldl/collect/fill остаются стандартными операциями ядра; весь предметный выбор и relax виден на странице.

## LMX: общий договор двух форм

DijkstraPick и DijkstraRelax общие. Процедурная форма содержит явные проходы по шагам, вершинам и рёбрам. Функциональная использует foldl для выбора и релаксации, collect — для последовательности settled-вершин до Stop. Sentinel -1 не смешивается с достижимым нулевым расстоянием. bigint в LMX исключает искусственное сужение его арифметики ради контрольного C++-типа.

Выбираемый driver — часть fixture, а не особая точка запуска. Корень поднимается как L3 Thread без DATA; указанный ниже обычный вызов выполняется после запуска. Общие методы доступны в том же графе, а динамически передаваемые рабочие переменные не помечены private.

| Стиль | Обычный вызов после запуска |
| --- | --- |
| Процедурный | `Dijkstra\run(graph; start; DijkstraProcedural\run)` |
| Функциональный | `Dijkstra\run(graph; start; DijkstraFunctional\run)` |

[Общий AlgorithmArray — полное тело](README.md#общая-подготовка-массива), [исходник](examples/lmx/common/array.lm3), выделяет массив и явно заполняет его через [ядровый fill](../LMX_Fn_Receivers/src/fill.lmx). Его тело входит в полную границу каждого стиля один раз. Оно не предполагает нулевого результата resize и не скрывает алгоритм задачи.

### Общая реализация подготовки и шага

[Исходник](examples/lmx/common/105_dijkstra.lm3). Это необходимая часть обоих полных листингов; её стоимость не исчезает при сравнении.

```lmx
Dijkstra:
    @: graph
    int: start
    @: traverse
    return: @
    run:
        throws: copy(AlgorithmArray\make\throws) copy(FxApply\apply\throws) ReceiverIndex
        int: n length(graph)
        @: distance AlgorithmArray\make([]bigint; n; (-1 record))
        @: settled AlgorithmArray\make([]int; n; (0 record))
        if: n = 0
            return: distance
        distance[start] := 0
        int: best -1
        FxApply\apply(traverse; ())
        return: distance

DijkstraPick:
    int: chosen
    int: vertex
    return: int
    run:
        throws: ReceiverIndex
        if: settled[vertex] = 0 && distance[vertex] >= 0
            if: chosen = -1
                return: vertex
            if: distance[vertex] < distance[chosen]
                return: vertex
        ---
        return: chosen

DijkstraRelax:
    int: ignored
    @: edge
    return: int
    run:
        throws: ReceiverIndex
        int: vertex edge[0]
        bigint: candidate distance[best] + edge[1]
        if: distance[vertex] = -1 || candidate < distance[vertex]
            distance[vertex] := candidate
        return: 0
```

## LMX — процедурный

[Исходник](examples/lmx/procedural/105_dijkstra.lm3); требуется общая часть выше.

```lmx
DijkstraProcedural:
    return: int
    run:
        throws: copy(DijkstraPick\run\throws) copy(DijkstraRelax\run\throws)
        int: step 0
        while: step < n
            best := -1
            int: vertex 0
            while: vertex < n
                best := DijkstraPick\run(best; vertex)
                vertex += 1
            if: best = -1
                return: 0
            settled[best] := 1
            @: row graph[best]
            int: i 0
            while: i < length(row)
                DijkstraRelax\run(0; row[i])
                i += 1
            step += 1
        return: 0
```

## LMX — функциональный

[Исходник](examples/lmx/105_dijkstra.lm3); требуется общая часть выше.

```lmx
DijkstraStep:
    return: int
    next:
        throws: copy(range\throws) copy(foldl\throws) ReceiverIndex Stop
        best := \foldl(range(0; n); (-1 record); DijkstraPick\run)
        if: best = -1
            throw: Stop()
        settled[best] := 1
        foldl(graph[best]; (0 record); DijkstraRelax\run)
        return: best

DijkstraFunctional:
    return: int
    run:
        throws: copy(collect\throws)
        collect(DijkstraStep\next)
        return: 0
```

## Python

[Полный исходник](examples/python/105_dijkstra.py).

```python
def dijkstra(graph, start):
    distance = [-1] * len(graph)
    settled = [False] * len(graph)
    if not graph:
        return distance
    distance[start] = 0
    for _ in graph:
        best = -1
        for vertex, value in enumerate(distance):
            if not settled[vertex] and value >= 0:
                if best == -1 or value < distance[best]:
                    best = vertex
        if best == -1:
            break
        settled[best] = True
        for neighbor, weight in graph[best]:
            candidate = distance[best] + weight
            if distance[neighbor] == -1 or candidate < distance[neighbor]:
                distance[neighbor] = candidate
    return distance
```

## C++

[Полный исходник](examples/cpp/105_dijkstra.cpp).

```cpp
#include <cstdint>
#include <utility>
#include <vector>

std::vector<std::int64_t> dijkstra(
    const std::vector<std::vector<std::pair<int, std::int64_t>>>& graph, int start) {
    std::vector<std::int64_t> distance(graph.size(), -1);
    std::vector<bool> settled(graph.size(), false);
    if (graph.empty()) return distance;
    distance[start] = 0;
    for (std::size_t step = 0; step < graph.size(); ++step) {
        int best = -1;
        for (int vertex = 0; vertex < static_cast<int>(graph.size()); ++vertex) {
            if (!settled[vertex] && distance[vertex] >= 0 &&
                (best == -1 || distance[vertex] < distance[best])) best = vertex;
        }
        if (best == -1) break;
        settled[best] = true;
        for (const auto& [neighbor, weight] : graph[best]) {
            const auto candidate = distance[best] + weight;
            if (distance[neighbor] == -1 || candidate < distance[neighbor])
                distance[neighbor] = candidate;
        }
    }
    return distance;
}
```

## Контрольные сценарии

Все фиксированные случаи этой задачи из [cases.json](tests/cases.json) приведены ниже; алгоритм принимает и остальные допустимые входы.

| Случай | Вход | Ожидаемый результат |
| --- | --- | --- |
| `dijkstra_empty` | `{"graph":[],"start":-1}` | `[]` |
| `dijkstra_relaxation` | `{"graph":[[[1,9],[2,2]],[[3,1]],[[1,1],[3,8]],[],[]],"start":0}` | `[0,3,2,4,-1]` |
| `dijkstra_zero_parallel` | `{"graph":[[[0,0],[1,7],[1,0]],[[2,0]],[[1,0]]],"start":0}` | `[0,0,0]` |
| `dijkstra_large` | `{"graph":[[[1,1000000000000]],[[2,1000000000000]],[]],"start":0}` | `[0,1000000000000,2000000000000]` |

## Сравнительная публикация и проверка

Полные размеры обеих LMX-форм пересчитаны по текущим исходникам и приведены ниже. Общие части входят в каждую использующую их границу ровно один раз; все объявления и Throws сохранены.

Иностранные программы проверены [воспроизводимым runner](tests/run_foreign.py), фиксированными случаями и 120 генерируемыми входами на задачу. [Отчёт исполнения](tests/validation.json) различает это от неподтверждённого исполнения LMX. Callback и resource failures не заменяются фиктивным успехом; нарушение явно перечисленных предусловий не является заявленным API восстановления ошибок.

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 1247 | 70 |
| LMX — функциональный | 1258 | 65 |
| Python | <span style="color:#176233"><u>443</u></span> | 20 |
| C++ | 753 | 25 |

Для каждой LMX-формы считаются все её source_files, включая общие определения ровно один раз. Все объявления и Throws входят в размер. Зелёным подчёркнут минимум полного сопоставимого листинга; равные минимумы выделены вместе.
