using System;
namespace ExampleLib {
    public static class Specification {
        public static Func<int,bool> Both(Func<int,bool> left, Func<int,bool> right) {
            return value => left(value) && right(value);
        }
    }
}
