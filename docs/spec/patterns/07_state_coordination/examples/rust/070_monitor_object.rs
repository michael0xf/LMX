use std::sync::Mutex;
struct Account { balance: Mutex<i32> }
impl Account {
    fn new() -> Self { Self { balance: Mutex::new(10) } }
    fn withdraw(&self, amount: i32) -> bool {
        let mut balance = self.balance.lock().unwrap();
        if amount < 0 || *balance < amount { return false; }
        *balance -= amount; true
    }
    fn read(&self) -> i32 { *self.balance.lock().unwrap() }
}
