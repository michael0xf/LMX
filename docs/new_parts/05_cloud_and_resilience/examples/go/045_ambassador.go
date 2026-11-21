func Ambassador(post func(string, string) int) int {
    const endpoint = "https://catalog.example"
    const route = "/catalog/read"
    status := post(endpoint, route)
    if status == 503 { return post(endpoint, route) }
    return status
}
