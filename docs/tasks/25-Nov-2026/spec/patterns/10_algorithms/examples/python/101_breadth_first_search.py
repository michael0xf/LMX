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
