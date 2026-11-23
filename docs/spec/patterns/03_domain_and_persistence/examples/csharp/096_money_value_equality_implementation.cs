namespace ExampleLib {
    public readonly struct Money {
        public int Cents { get; }
        public int Currency { get; }
        public Money(int cents, int currency) { Cents = cents; Currency = currency; }
        public static Money Create(int cents = 100, int currency = 840) => new Money(cents, currency);
        public static bool Same(Money left, Money right) =>
            left.Cents == right.Cents && left.Currency == right.Currency;
    }
}
