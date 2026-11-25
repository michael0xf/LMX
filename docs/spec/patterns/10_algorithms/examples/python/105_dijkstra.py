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
