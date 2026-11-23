future(pending, Waiters) ->
    receive
        {get, From, Ref} -> future(pending, [{From,Ref}|Waiters]);
        {resolve, Value} ->
            [P ! {R,Value} || {P,R} <- Waiters], future({ready,Value}, [])
    end;
future({ready,Value}, []) ->
    receive
        {get, From, Ref} -> From ! {Ref,Value}, future({ready,Value}, []);
        {resolve, _} -> future({ready,Value}, [])
    end.
