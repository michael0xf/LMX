map_reduce(Parts) ->
    Parent = self(),
    [spawn(fun() -> [Parent ! {key,X rem 2} || X <- Part] end) || Part <- Parts],
    reduce(lists:sum([length(P) || P <- Parts]), #{0=>0,1=>0}).
reduce(0, Totals) -> Totals;
reduce(N, Totals) ->
    receive {key,K} -> reduce(N-1, maps:update_with(K,fun(V)->V+1 end,1,Totals)) end.
