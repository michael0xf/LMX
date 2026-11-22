using System;
using System.Collections.Generic;
public sealed class Session(Func<int,object> load) {
    readonly Dictionary<int,object> cache = new();
    public object Get(int id) {
        if (!cache.TryGetValue(id,out var value)) {
            value=load(id);
            cache.Add(id,value);
        }
        return value;
    }
}
