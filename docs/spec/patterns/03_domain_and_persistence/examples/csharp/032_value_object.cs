public sealed record Money(int Cents = 100, int Currency = 840);
public static class Example {
    public static int Demo() {
        Money first = new(), second = new(), third = new(Currency: 978);
        return (first == second ? 10 : 0) + (first == third ? 1 : 0);
    }
}
