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
