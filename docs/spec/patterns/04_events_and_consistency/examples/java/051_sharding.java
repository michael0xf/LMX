import java.util.List;
interface Transport { Object get(String target,int id); }
final class Router {
    static Object get(List<String> targets,Transport transport,int id) {
        if (id<0 || targets.isEmpty()) throw new IllegalArgumentException("shard");
        int index=id%targets.size();
        return transport.get(targets.get(index),id);
    }
}
