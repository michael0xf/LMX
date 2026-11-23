use std::sync::atomic::{AtomicBool, Ordering};
struct Save { busy: AtomicBool }
impl Save {
    fn new() -> Self { Self { busy: AtomicBool::new(false) } }
    fn start(&self) -> bool {
        self.busy.compare_exchange(false, true, Ordering::AcqRel, Ordering::Acquire).is_ok()
    }
    fn finish(&self) -> i32 { self.busy.store(false, Ordering::Release); 1 }
}
