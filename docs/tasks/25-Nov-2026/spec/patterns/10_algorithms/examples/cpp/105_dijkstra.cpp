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
