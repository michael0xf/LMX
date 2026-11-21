using PatternHelpers;
static int Ambassador(System.Func<string,string,int> post) {
    int Read() => post("https://catalog.example", "/catalog/read");
    return RetryLibrary.Run(Read, 2);
}
