using PatternHelpers;
static int Retry(System.Func<int> request, System.Action<int> delay) {
    return RetryLibrary.Run(request, 3, delay);
}
