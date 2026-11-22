package pipe
func Apply(value int, stages ...func(int) int) int {
    for _, stage := range stages { value = stage(value) }
    return value
}
