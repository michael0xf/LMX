func Live() int { return 200 }
func Ready(probe func() bool) int {
    if probe() { return 200 }
    return 503
}
