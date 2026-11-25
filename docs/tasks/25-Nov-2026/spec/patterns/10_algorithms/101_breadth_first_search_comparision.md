# 101. Breadth-first search / поиск в ширину

Вычислить минимальное число рёбер от стартовой вершины ко всем вершинам графа.

## Договор и полезный результат

graph — конечный ориентированный граф в виде массива строк соседей; вершины имеют индексы 0..V-1. Каждая строка содержит допустимые int-индексы, порядок сохраняется. Петли и повторные рёбра разрешены. При V>0 start — допустимая вершина; при V=0 используется start=-1 и возвращается пустой массив. Результат содержит V целых расстояний: start имеет 0, недостижимые вершины — -1. Исходные строки не меняются. Посещение отмечается при постановке в очередь, поэтому каждая вершина ставится не более одного раза.

## Почему эти языки

Python показывает компактную обработку списков соседей, Java — явные массивы расстояний и FIFO-очередь ограниченной ёмкости V. Это типичные реализации обхода графа с одинаковым наблюдаемым результатом.

## Алгоритм, источники и стоимость

Boost.Graph описывает FIFO-обход с записью расстояния при обнаружении вершины и оценкой O(V+E). Java Arrays документирует явное заполнение массива; новый общий fill выполняет эту роль в LMX.

[Boost.Graph: breadth_first_search](https://www.boost.org/doc/libs/1_82_0/libs/graph/doc/breadth_first_search.html); [Java: Arrays.fill](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/Arrays.html).

O(V+E) времени в худшем случае, O(V) дополнительного рабочего состояния; недостижимые рёбра не обходятся. Функциональная collect дополнительно создаёт конечную последовательность посещённых вершин размера не больше V. Оценка размера живых значений не обещает конкретную политику освобождения арены runtime.

Используются обычные массивы, индекс головы и append в Python. Это не требует отдельного скрытого deque. fill уже включён в общее ядро; выделение массива не считается обещанием нулевых элементов LMX.

## LMX: общий договор двух форм

Подготовка distance/queue и единственный шаг обнаружения BfsDiscover общие. Процедурный driver содержит два while; функциональный заменяет поток вершин на collect и обход соседей на foldl. Локальные distance, queue, head, tail и nextDistance доступны callback через существующее динамическое связывание; это намеренная возможность LMX, поэтому повторять их параметры и контейнер состояния не требуется. Эта форма использует функциональные комбинаторы над приватным изменяемым рабочим состоянием и не выдаётся за persistent-очередь.

Выбираемый driver — часть fixture, а не особая точка запуска. Корень поднимается как L3 Thread без DATA; указанный ниже обычный вызов выполняется после запуска. Общие методы доступны в том же графе, а динамически передаваемые рабочие переменные не помечены private.

| Стиль | Обычный вызов после запуска |
| --- | --- |
| Процедурный | `BreadthFirst\run(graph; start; BfsProcedural\run)` |
| Функциональный | `BreadthFirst\run(graph; start; BfsFunctional\run)` |

[Общий AlgorithmArray — полное тело](README.md#общая-подготовка-массива), [исходник](examples/lmx/common/array.lm3), выделяет массив и явно заполняет его через [ядровый fill](../LMX_Fn_Receivers/src/fill.lmx). Его тело входит в полную границу каждого стиля один раз. Оно не предполагает нулевого результата resize и не скрывает алгоритм задачи.

### Общая реализация подготовки и шага

[Исходник](examples/lmx/common/101_breadth_first_search.lm3). Это необходимая часть обоих полных листингов; её стоимость не исчезает при сравнении.

```lmx
BreadthFirst:
    @: graph
    int: start
    @: traverse
    return: @
    run:
        throws: copy(AlgorithmArray\make\throws) copy(FxSeqAllocate\make\throws) copy(FxApply\apply\throws) ReceiverIndex
        int: n length(graph)
        @: distance AlgorithmArray\make(int[]; n; (-1 record))
        if: n = 0
            return: distance
        @: queue FxSeqAllocate\make(int[]; n)
        queue[0] := start
        distance[start] := 0
        int: head 0
        int: tail 1
        int: nextDistance 0
        FxApply\apply(traverse; ())
        return: distance

BfsDiscover:
    int: tail
    int: vertex
    return: int
    run:
        throws: ReceiverIndex
        if: distance[vertex] = -1
            distance[vertex] := nextDistance
            queue[tail] := vertex
            tail += 1
        return: tail
```

## LMX — процедурный

[Исходник](examples/lmx/procedural/101_breadth_first_search.lm3); требуется общая часть выше.

```lmx
BfsProcedural:
    return: int
    run:
        throws: copy(BfsDiscover\run\throws)
        while: head < tail
            int: vertex queue[head]
            head += 1
            nextDistance := distance[vertex] + 1
            @: row graph[vertex]
            int: i 0
            while: i < length(row)
                tail := BfsDiscover\run(tail; row[i])
                i += 1
        ---
        return: 0
```

## LMX — функциональный

[Исходник](examples/lmx/101_breadth_first_search.lm3); требуется общая часть выше.

```lmx
BfsVisit:
    return: int
    next:
        throws: copy(foldl\throws) Stop ReceiverIndex
        if: head = tail
            throw: Stop()
        int: vertex queue[head]
        head += 1
        nextDistance := distance[vertex] + 1
        tail := \foldl(graph[vertex]; (tail record); BfsDiscover\run)
        return: vertex

BfsFunctional:
    return: int
    run:
        throws: copy(collect\throws)
        collect(BfsVisit\next)
        return: 0
```

## Python

[Полный исходник](examples/python/101_breadth_first_search.py).

```python
def breadth_first_search(graph, start):
    distance = [-1] * len(graph)
    if not graph:
        return distance
    queue = [start]
    distance[start] = 0
    head = 0
    while head < len(queue):
        vertex = queue[head]
        head += 1
        for neighbor in graph[vertex]:
            if distance[neighbor] == -1:
                distance[neighbor] = distance[vertex] + 1
                queue.append(neighbor)
    return distance
```

## Java

[Полный исходник](examples/java/101_breadth_first_search.java).

```java
import java.util.Arrays;

final class BreadthFirstExample {
    static int[] run(int[][] graph, int start) {
        int[] distance = new int[graph.length];
        Arrays.fill(distance, -1);
        if (graph.length == 0) return distance;
        int[] queue = new int[graph.length];
        int head = 0, tail = 1;
        queue[0] = start;
        distance[start] = 0;
        while (head < tail) {
            int vertex = queue[head++];
            for (int neighbor : graph[vertex]) {
                if (distance[neighbor] == -1) {
                    distance[neighbor] = distance[vertex] + 1;
                    queue[tail++] = neighbor;
                }
            }
        }
        return distance;
    }
}
```

## Контрольные сценарии

Все фиксированные случаи этой задачи из [cases.json](tests/cases.json) приведены ниже; алгоритм принимает и остальные допустимые входы.

| Случай | Вход | Ожидаемый результат |
| --- | --- | --- |
| `bfs_empty` | `{"graph":[],"start":-1}` | `[]` |
| `bfs_branch_unreachable` | `{"graph":[[2,1],[3],[3],[],[]],"start":0}` | `[0,1,1,2,-1]` |
| `bfs_self_duplicate` | `{"graph":[[0,1,1],[0,2],[2]],"start":0}` | `[0,1,2]` |
| `bfs_other_start` | `{"graph":[[1],[2],[],[]],"start":1}` | `[-1,0,1,-1]` |

## Сравнительная публикация и проверка

| Вариант | Граница | Символы / строки | Исполнение |
| --- | --- | --- | --- |





Метрики и победители сейчас не объявляются: пользователь явно отложил пересчёт. Будущая сборка должна учитывать каждую LMX-форму, все её локальные closure_sources, декларации и throws; стандартные зависимости отмечены отдельно. Колонки «без сложного throws» нет. Для равных минимальных полных чисел действует обычное зелёное подчёркивание всех победителей.

Иностранные программы проверены [воспроизводимым runner](tests/run_foreign.py), фиксированными случаями и 120 генерируемыми входами на задачу. [Отчёт исполнения](tests/validation.json) различает это от неподтверждённого исполнения LMX. Callback и resource failures не заменяются фиктивным успехом; нарушение явно перечисленных предусловий не является заявленным API восстановления ошибок.

## Размер полного исходника

| Запись | Непробельные символы | Непустые строки |
| --- | ---: | ---: |
| LMX — процедурный | 970 | 54 |
| LMX — функциональный | 1044 | 56 |
| Python | <span style="color:#176233"><u>293</u></span> | 15 |
| Java | 447 | 22 |

Для каждой LMX-формы считаются все её source_files, включая общие определения ровно один раз. Все объявления и Throws входят в размер. Зелёным подчёркнут минимум полного сопоставимого листинга; равные минимумы выделены вместе.
