# 102. Kahn topological sort / порядок зависимостей

Выдать детерминированный порядок выполнения зависимостей либо сообщить о цикле.

## Договор и полезный результат

graph задаётся списками исходящих рёбер с допустимыми индексами 0..V-1; разрешены кратные рёбра и петли. Результат — присутствующий массив всех вершин, либо отсутствие при любом цикле, включая цикл в отдельной компоненте. Пустой граф даёт присутствующий пустой массив. Начальные вершины с нулевой входящей степенью ставятся в очередь по возрастанию индекса; затем действует FIFO, а соседи рассматриваются в порядке строки graph. Это определяет точный порядок при нескольких допустимых сортировках. Каждое кратное ребро отдельно увеличивает и уменьшает степень. Частичный порядок при цикле наружу не возвращается.

## Почему эти языки

Python удобен для обработки зависимостей и DAG; Java показывает ту же работу на массивах с явной очередью. Оба листинга реализуют именно зафиксированный FIFO-порядок, а не произвольную топологическую перестановку.

## Алгоритм, источники и стоимость

TopologicalX описывает алгоритм через входящие степени и очередь, O(V+E) времени и O(V) памяти. Python graphlib предоставляет более широкий API зависимостей с другим представлением и правилами готовности; он указан как близкий стандартный механизм, а не молча подставлен вместо согласованного FIFO-договора.

[Sedgewick / Wayne: TopologicalX](https://algs4.cs.princeton.edu/code/edu/princeton/cs/algs4/TopologicalX.java.html); [Python: graphlib.TopologicalSorter](https://docs.python.org/3/library/graphlib.html).

O(V+E) времени, O(V) основной дополнительной памяти. Функциональные map/collect создают дополнительные временные результаты суммарного логического размера O(V), а foldl обрабатывает каждое ребро один раз при подсчёте и не более одного раза при снятии.

Готовый graphlib.TopologicalSorter принимает predecessor-отношения, имеет отдельную фазу ready/done и свои ошибки. Простой одновызовный результат на этой странице не объявлен полным аналогом того API; отдельного скрытого topologicalSort из ядра нет.

## LMX: общий договор двух форм

TopoCount, TopoEnqueue и TopoRemove записаны один раз. Процедурная форма явно обходит строки и очередь. Функциональная использует map для строк и начальных вершин, foldl для каждого ряда рёбер и collect до исчерпания очереди. Обе формы вызывают один общий Topological\run, который различает none и some(empty array). Python None и Java null в fixture означают отсутствие, а не пустой успешный результат.

Выбираемый driver — часть fixture, а не особая точка запуска. Корень поднимается как L3 Thread без DATA; указанный ниже обычный вызов выполняется после запуска. Общие методы доступны в том же графе, а динамически передаваемые рабочие переменные не помечены private.

| Стиль | Обычный вызов после запуска |
| --- | --- |
| Процедурный | `Topological\run(graph; TopoProcedural\run)` |
| Функциональный | `Topological\run(graph; TopoFunctional\run)` |

[Общий AlgorithmArray — полное тело](README.md#общая-подготовка-массива), [исходник](examples/lmx/common/array.lm3), выделяет массив и явно заполняет его через [ядровый fill](../LMX_Fn_Receivers/src/fill.lmx). Его тело входит в полную границу каждого стиля один раз. Оно не предполагает нулевого результата resize и не скрывает алгоритм задачи.

### Общая реализация подготовки и шага

[Исходник](examples/lmx/common/102_topological_sort.lm3). Это необходимая часть обоих полных листингов; её стоимость не исчезает при сравнении.

```lmx
Topological:
    @: graph
    @: traverse
    return: @FxMaybe
    run:
        throws: copy(AlgorithmArray\make\throws) copy(FxSeqAllocate\make\throws) copy(FxApply\apply\throws) FxRecordArity
        int: n length(graph)
        @: degree AlgorithmArray\make([]int; n; (0 record))
        @: queue FxSeqAllocate\make([]int; n)
        int: head 0
        int: tail 0
        FxApply\apply(traverse; ())
        if: tail != n
            return: none()
        return: some(queue)

TopoCount:
    int: ignored
    int: vertex
    return: int
    run:
        throws: ReceiverIndex
        degree[vertex] += 1
        return: 0

TopoEnqueue:
    int: vertex
    return: int
    run:
        throws: ReceiverIndex
        if: degree[vertex] = 0
            queue[tail] := vertex
            tail += 1
        return: vertex

TopoRemove:
    int: tail
    int: vertex
    return: int
    run:
        throws: ReceiverIndex
        degree[vertex] -= 1
        if: degree[vertex] = 0
            queue[tail] := vertex
            tail += 1
        return: tail
```

## LMX — процедурный

[Исходник](examples/lmx/procedural/102_topological_sort.lm3); требуется общая часть выше.

```lmx
TopoProcedural:
    return: int
    run:
        throws: copy(TopoCount\run\throws) copy(TopoEnqueue\run\throws) copy(TopoRemove\run\throws)
        int: i 0
        while: i < n
            @: row graph[i]
            int: j 0
            while: j < length(row)
                TopoCount\run(0; row[j])
                j += 1
            i += 1
        i := 0
        while: i < n
            TopoEnqueue\run(i)
            i += 1
        while: head < tail
            @: row graph[queue[head]]
            head += 1
            int: j 0
            while: j < length(row)
                tail := TopoRemove\run(tail; row[j])
                j += 1
        ---
        return: 0
```

## LMX — функциональный

[Исходник](examples/lmx/102_topological_sort.lm3); требуется общая часть выше.

```lmx
TopoRow:
    @: row
    return: int
    count:
        throws: copy(foldl\throws)
        return: \foldl(row; (0 record); TopoCount\run)

TopoVisit:
    return: int
    next:
        throws: copy(foldl\throws) Stop ReceiverIndex
        if: head = tail
            throw: Stop()
        int: vertex queue[head]
        head += 1
        tail := \foldl(graph[vertex]; (tail record); TopoRemove\run)
        return: vertex

TopoFunctional:
    return: int
    run:
        throws: copy(map\throws) copy(range\throws) copy(collect\throws)
        map(graph; TopoRow\count)
        map(range(0; n); TopoEnqueue\run)
        collect(TopoVisit\next)
        return: 0
```

## Python

[Полный исходник](examples/python/102_topological_sort.py).

```python
def topological_sort(graph):
    degree = [0] * len(graph)
    for row in graph:
        for vertex in row:
            degree[vertex] += 1
    order = [v for v, incoming in enumerate(degree) if incoming == 0]
    head = 0
    while head < len(order):
        vertex = order[head]
        head += 1
        for neighbor in graph[vertex]:
            degree[neighbor] -= 1
            if degree[neighbor] == 0:
                order.append(neighbor)
    return order if len(order) == len(graph) else None
```

## Java

[Полный исходник](examples/java/102_topological_sort.java).

```java
final class TopologicalExample {
    static int[] run(int[][] graph) {
        int[] degree = new int[graph.length], order = new int[graph.length];
        for (int[] row : graph) {
            for (int vertex : row) degree[vertex]++;
        }
        int head = 0, tail = 0;
        for (int vertex = 0; vertex < graph.length; ++vertex) {
            if (degree[vertex] == 0) order[tail++] = vertex;
        }
        while (head < tail) {
            for (int neighbor : graph[order[head++]]) {
                if (--degree[neighbor] == 0) order[tail++] = neighbor;
            }
        }
        return tail == graph.length ? order : null;
    }
}
```

## Контрольные сценарии

Все фиксированные случаи этой задачи из [cases.json](tests/cases.json) приведены ниже; алгоритм принимает и остальные допустимые входы.

| Случай | Вход | Ожидаемый результат |
| --- | --- | --- |
| `topo_empty` | `{"graph":[]}` | `[]` |
| `topo_fifo` | `{"graph":[[2],[2],[3],[],[]]}` | `[0,1,4,2,3]` |
| `topo_duplicate` | `{"graph":[[1,1],[2],[]]}` | `[0,1,2]` |
| `topo_cycle` | `{"graph":[[1],[0],[]]}` | `null` |
| `topo_self` | `{"graph":[[0]]}` | `null` |

## Сравнительная публикация и проверка

Полные размеры обеих LMX-форм пересчитаны по текущим исходникам и приведены ниже. Общие части входят в каждую использующую их границу ровно один раз; все объявления и Throws сохранены.

Иностранные программы проверены [воспроизводимым runner](tests/run_foreign.py), фиксированными случаями и 120 генерируемыми входами на задачу. [Отчёт исполнения](tests/validation.json) различает это от неподтверждённого исполнения LMX. Callback и resource failures не заменяются фиктивным успехом; нарушение явно перечисленных предусловий не является заявленным API восстановления ошибок.

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 1230 | 77 |
| LMX — функциональный | 1335 | 76 |
| Python | <span style="color:#176233"><u>333</u></span> | 15 |
| Java | 423 | 18 |

Для каждой LMX-формы считаются все её source_files, включая общие определения ровно один раз. Все объявления и Throws входят в размер. Зелёным подчёркнут минимум полного сопоставимого листинга; равные минимумы выделены вместе.
