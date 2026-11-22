using System;
public sealed class Holder(Func<int> load) {
    bool loaded;
    int value;
    public int Get() {
        if (!loaded) {
            int result=load();
            value=result;
            loaded=true;
        }
        return value;
    }
}
