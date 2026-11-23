use std::cell::Cell;
thread_local! { static COUNT: Cell<i32> = const { Cell::new(0) }; }
fn next() -> i32 {
    COUNT.with(|count| { let value = count.get() + 1; count.set(value); value })
}
