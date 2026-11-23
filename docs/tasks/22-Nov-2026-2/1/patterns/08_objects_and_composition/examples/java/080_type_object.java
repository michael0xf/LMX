class Example {
    static class TypeData { int damage = 2; }
    record Item(TypeData kind) {}
    static int damage(Item item) { return item.kind().damage; }
    static int demo() {
        TypeData kind = new TypeData();
        Item first = new Item(kind), second = new Item(kind);
        int before = damage(first); kind.damage = 3;
        return before * 10 + damage(second);
    }
}
