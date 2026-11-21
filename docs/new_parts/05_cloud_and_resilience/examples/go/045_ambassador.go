import "example/retryhelper"
func Ambassador(post func(string, string) int) int {
    read := func() int { return post("https://catalog.example", "/catalog/read") }
    return retryhelper.Run(read, 2, nil)
}
