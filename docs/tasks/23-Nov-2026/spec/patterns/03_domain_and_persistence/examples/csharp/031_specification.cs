using System;
using System.Linq;
public static class Specifications {
    public static bool Nonnegative(int value) => value >= 0;
    public static bool Below100(int value) => value < 100;
    public static Func<int,bool> Build() {
        Func<int,bool>[] checks = [Nonnegative, Below100];
        return value => checks.All(p => p(value));
    }
}
