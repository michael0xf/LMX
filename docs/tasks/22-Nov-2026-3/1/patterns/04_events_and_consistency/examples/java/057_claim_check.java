import java.util.function.Consumer;
record Ticket(int key,int size) {}
interface Blobs { int put(String payload); String get(int key); }
final class ClaimCheck {
    static void send(Blobs blobs,Consumer<Ticket> publish,String payload) {
        int key=blobs.put(payload);
        publish.accept(new Ticket(key,payload.length()));
    }
    static void receive(Blobs blobs,Consumer<String> consume,Ticket ticket) {
        String payload=blobs.get(ticket.key());
        if (payload.length()!=ticket.size()) throw new IllegalStateException("payload");
        consume.accept(payload);
    }
}
