class Example {
    interface Output { int present(boolean decision); }
    static boolean eligible(int income, int expense) { return income - expense >= 30; }
    static int execute(int income, int expense, Output output) {
        return output.present(eligible(income, expense));
    }
    static int render(boolean decision) { return decision ? 200 : 422; }
    static int demo() { return execute(100, 60, Example::render); }
}
