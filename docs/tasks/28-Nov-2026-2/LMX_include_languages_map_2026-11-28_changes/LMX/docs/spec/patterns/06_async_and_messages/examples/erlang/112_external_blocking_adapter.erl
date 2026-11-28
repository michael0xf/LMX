blocking_client(Call, ReleaseIdle, Observer) ->
    blocking_loop(Call, ReleaseIdle, Observer, 0, false, false).
blocking_loop(Call, ReleaseIdle, Observer, Token, Active, Closing) ->
    receive
        {submit, _} when Active; Closing ->
            Observer ! {rejected, 1},
            blocking_loop(Call,ReleaseIdle,Observer,Token,Active,Closing);
        {submit, _} when Token =:= 9223372036854775807 ->
            Observer ! {rejected, 2},
            blocking_loop(Call,ReleaseIdle,Observer,Token,Active,Closing);
        {submit, Value} ->
            Next = Token+1, Parent = self(),
            spawn(fun() ->
                Result = try Call(Value) of V -> {true,V}
                         catch _:_ -> {false,0} end,
                Parent ! {completed, Next, Result}
            end),
            blocking_loop(Call,ReleaseIdle,Observer,Next,true,Closing);
        {completed, Token, {OK, Value}} when Active ->
            Observer ! {finished, Token, OK, Value},
            case Closing of
                true -> ReleaseIdle(), Observer ! closed, ok;
                false -> blocking_loop(Call,ReleaseIdle,Observer,Token,false,false)
            end;
        begin_close when Active ->
            blocking_loop(Call,ReleaseIdle,Observer,Token,true,true);
        begin_close ->
            ReleaseIdle(), Observer ! closed, ok;
        query ->
            Observer ! {status, Closing, Active},
            blocking_loop(Call,ReleaseIdle,Observer,Token,Active,Closing);
        _ -> blocking_loop(Call,ReleaseIdle,Observer,Token,Active,Closing)
    end.
