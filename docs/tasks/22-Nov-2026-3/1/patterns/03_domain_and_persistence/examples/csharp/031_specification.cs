using System;
using ExampleLib;
public static class Specifications {
    public static bool Nonnegative(int value) => value >= 0;
    public static bool Below100(int value) => value < 100;
    public static Func<int,bool> Build() => Specification.Both(Nonnegative, Below100);
}
