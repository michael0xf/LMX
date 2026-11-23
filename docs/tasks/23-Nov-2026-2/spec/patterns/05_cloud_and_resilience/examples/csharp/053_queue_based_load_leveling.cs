sealed class Buffer {
    readonly System.Collections.Generic.Queue<int> jobs = new();
    public void Accept(int job) => jobs.Enqueue(job);
    public void Tick(System.Action<int> process) {
        if (jobs.Count > 0) process(jobs.Dequeue());
    }
}
