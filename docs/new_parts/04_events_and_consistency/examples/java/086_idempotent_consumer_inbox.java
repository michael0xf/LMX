interface InboxDb {
    void atomic(Runnable body);
    boolean tryInsert(int subscriber,int eventId);
    void addBalance(int delta);
}
interface Broker { void ack(int eventId); }
final class Inbox {
    static void receive(InboxDb db,Broker broker,int subscriber,int eventId,int delta) {
        db.atomic(() -> {
            if (db.tryInsert(subscriber,eventId)) db.addBalance(delta);
        });
        broker.ack(eventId);
    }
}
