static int Retry(System.Func<int> request, System.Action<int> delay) {
    int pause = 1;
    for (int attempt = 0; attempt < 3; attempt++) {
        int status = request();
        if (status != 503) return status;
        if (attempt < 2) { delay(pause); pause *= 2; }
    }
    return 503;
}
