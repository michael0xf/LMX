#nullable enable
namespace PatternHelpers {
    public static class RetryLibrary {
        public static int Run(System.Func<int> request, int attempts,
                              System.Action<int>? delay = null) {
            if (attempts < 1 || attempts > 31)
                throw new System.ArgumentOutOfRangeException(nameof(attempts));
            int pause = 1;
            for (int attempt = 0; attempt < attempts; attempt++) {
                int status = request();
                if (status != 503) return status;
                if (attempt + 1 < attempts && delay != null) {
                    delay(pause);
                    pause *= 2;
                }
            }
            return 503;
        }
    }
}
