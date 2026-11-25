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
