active() ->
    receive
        {compute, Value, From, Ref} ->
            From ! {Ref, Value * 2}, active();
        stop -> ok
    end.
submit(Pid, Value) ->
    Ref = make_ref(), Pid ! {compute, Value, self(), Ref}, Ref.
result(Ref) -> receive {Ref, Value} -> Value end.
