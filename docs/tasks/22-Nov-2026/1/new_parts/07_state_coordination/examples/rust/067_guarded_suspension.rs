use std::sync::{Condvar, Mutex};
struct Ready { value: Mutex<Option<i32>>, changed: Condvar }
impl Ready {
    fn new() -> Self { Self { value: Mutex::new(None), changed: Condvar::new() } }
    fn wait(&self) -> i32 {
        let guard = self.value.lock().unwrap();
        let guard = self.changed.wait_while(guard, |v| v.is_none()).unwrap();
        guard.unwrap()
    }
    fn publish(&self, next: i32) {
        *self.value.lock().unwrap() = Some(next);
        self.changed.notify_all();
    }
}
