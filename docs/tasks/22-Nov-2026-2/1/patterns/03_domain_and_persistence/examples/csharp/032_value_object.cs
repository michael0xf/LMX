using ExampleLib;
public static class Example {
    public static int Demo() {
        Money first = Money.Create();
        Money second = Money.Create();
        Money third = Money.Create(currency: 978);
        return (Money.Same(first, second) ? 10 : 0) + (Money.Same(first, third) ? 1 : 0);
    }
}
