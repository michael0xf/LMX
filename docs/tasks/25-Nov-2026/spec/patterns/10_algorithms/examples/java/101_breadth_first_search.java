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
