import java.util.List;
record Event(int id,int accountId,int cents) {}
interface OutboxDb {
    void atomic(Runnable body);
    void updateAccount(int id,int cents);
    void insertOutbox(int eventId,int accountId,int cents);
    List<Event> pending();
    void markSent(int eventId);
}
interface Publisher { void publish(Event event); }
final class Outbox {
    static void execute(OutboxDb db,int id,int cents,int eventId) {
        db.atomic(() -> { db.updateAccount(id,cents); db.insertOutbox(eventId,id,cents); });
    }
    static void relay(OutboxDb db,Publisher publisher) {
        for (Event event:db.pending()) {
            publisher.publish(event);
            db.markSent(event.id());
        }
    }
}
