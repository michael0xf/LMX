func Retry(request func() int, delay func(int)) int {
    pause := 1
    for attempt := 0; attempt < 3; attempt++ {
        status := request()
        if status != 503 { return status }
        if attempt < 2 { delay(pause); pause *= 2 }
    }
    return 503
}
