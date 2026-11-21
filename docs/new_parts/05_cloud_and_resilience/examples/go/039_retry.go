import "example/retryhelper"
func Retry(request func() int, delay func(int)) int {
    return retryhelper.Run(request, 3, delay)
}
