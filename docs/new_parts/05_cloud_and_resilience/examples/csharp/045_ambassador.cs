static int Ambassador(System.Func<string,string,int> post) {
    const string endpoint = "https://catalog.example", route = "/catalog/read";
    int status = post(endpoint, route);
    return status == 503 ? post(endpoint, route) : status;
}
