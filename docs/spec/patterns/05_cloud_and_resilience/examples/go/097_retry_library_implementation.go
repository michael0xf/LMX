package retryhelper
func Run(request func() int, attempts int, delay func(int)) int {
    if attempts < 1 || attempts > 31 { panic("attempts") }
    pause := 1
    for attempt := 0; attempt < attempts; attempt++ {
        status := request()
        if status != 503 { return status }
        if attempt + 1 < attempts && delay != nil {
            delay(pause)
            pause *= 2
        }
    }
    return 503
}
