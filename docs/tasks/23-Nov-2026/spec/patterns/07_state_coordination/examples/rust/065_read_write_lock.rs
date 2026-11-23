use std::sync::RwLock;
struct Value { value: RwLock<i32> }
impl Value {
    fn new() -> Self { Self { value: RwLock::new(10) } }
    fn read(&self) -> i32 { *self.value.read().unwrap() }
    fn write(&self, next: i32) -> i32 {
        let mut value = self.value.write().unwrap();
        *value = next; *value
    }
}
