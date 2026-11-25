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
