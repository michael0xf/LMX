#nullable enable
using System;
using System.Collections.Generic;
public static class FirstMatch {
    public static (bool Found, T? Value) FindFirst<T>(IEnumerable<T> items, Func<T,bool> accepts) {
        ArgumentNullException.ThrowIfNull(items);
        ArgumentNullException.ThrowIfNull(accepts);
        foreach (T item in items) if (accepts(item)) return (true, item);
        return (false, default);
    }
}
