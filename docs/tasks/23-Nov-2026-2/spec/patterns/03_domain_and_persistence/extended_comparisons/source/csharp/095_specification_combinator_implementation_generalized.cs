using System;
using System.Collections.Generic;
public static class PredicateSet {
    public static Func<T,bool> AllOf<T>(IEnumerable<Func<T,bool>> predicates) {
        ArgumentNullException.ThrowIfNull(predicates);
        var checks = new List<Func<T,bool>>();
        foreach (var predicate in predicates) {
            ArgumentNullException.ThrowIfNull(predicate);
            checks.Add(predicate);
        }
        return value => {
            foreach (var predicate in checks) if (!predicate(value)) return false;
            return true;
        };
    }
}
