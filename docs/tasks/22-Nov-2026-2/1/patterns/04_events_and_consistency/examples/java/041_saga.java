import java.util.function.IntConsumer;
final class Saga {
    private int phase;
    private final IntConsumer publish;
    Saga(IntConsumer publish) { this.publish=publish; }
    void handle(int kind,boolean ok) {
        int action=0;
        if (kind==0 && phase==0) { phase=1; action=1; }
        if (kind==1 && phase==1) {
            if (ok) { phase=2; action=2; } else { phase=4; action=4; }
        }
        if (kind==2 && phase==2) {
            if (ok) { phase=5; action=5; } else { phase=3; action=3; }
        }
        if (kind==3 && phase==3 && ok) { phase=4; action=4; }
        if (action!=0) publish.accept(action);
    }
}
