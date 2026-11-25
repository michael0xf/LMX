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
