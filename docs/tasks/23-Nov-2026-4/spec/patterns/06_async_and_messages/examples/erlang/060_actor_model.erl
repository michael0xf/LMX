counter(Total) ->
    receive
        {add, Delta, From, Ref} ->
            Next = Total + Delta, From ! {Ref, Next}, counter(Next);
        {read, From, Ref} ->
            From ! {Ref, Total}, counter(Total)
    end.
