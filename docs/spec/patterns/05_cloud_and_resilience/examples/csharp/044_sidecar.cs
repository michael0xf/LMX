static void App(int record, System.Action<int> sendLocal) => sendLocal(record);
static void Sidecar(System.Collections.Generic.IEnumerable<int> input,
                    System.Action<int> write) {
    foreach (int record in input) write(record);
}
