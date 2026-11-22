use std::sync::OnceLock;
struct Lazy { value: OnceLock<i32> }
impl Lazy {
    fn new() -> Self { Self { value: OnceLock::new() } }
    fn get(&self, build: impl FnOnce() -> i32) -> i32 {
        *self.value.get_or_init(build)
    }
}
