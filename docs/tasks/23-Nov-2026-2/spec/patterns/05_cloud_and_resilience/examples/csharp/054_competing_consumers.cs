static async System.Threading.Tasks.Task Worker(
    System.Threading.Channels.ChannelReader<int> jobs,
    System.Action<int> process) {
    await foreach (int job in jobs.ReadAllAsync()) process(job);
}
static System.Threading.Tasks.Task Start(
    System.Threading.Channels.ChannelReader<int> jobs,
    System.Action<int> process) =>
    System.Threading.Tasks.Task.WhenAll(
        System.Threading.Tasks.Task.Run(() => Worker(jobs, process)),
        System.Threading.Tasks.Task.Run(() => Worker(jobs, process)));
