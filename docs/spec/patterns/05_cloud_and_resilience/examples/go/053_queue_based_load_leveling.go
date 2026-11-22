type Buffer struct { jobs []int }
func (b *Buffer) Accept(job int) { b.jobs = append(b.jobs, job) }
func (b *Buffer) Tick(process func(int)) {
    if len(b.jobs) == 0 { return }
    job := b.jobs[0]; b.jobs = b.jobs[1:]; process(job)
}
