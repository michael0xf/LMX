ask_client(Service, Observer, Delay) ->
    ask_loop(Service, Observer, Delay, 0, 0, false).
ask_loop(Service, Observer, Delay, Next, Current, Active) ->
    receive
        {start, _} when Active ->
            Observer ! {rejected, 1},
            ask_loop(Service, Observer, Delay, Next, Current, Active);
        {start, _} when Next =:= 9223372036854775807 ->
            Observer ! {rejected, 2},
            ask_loop(Service, Observer, Delay, Next, Current, Active);
        {start, Value} ->
            Token = Next + 1,
            erlang:send_after(Delay, self(), {expire, Token}),
            Service ! {compute, self(), Token, Value},
            ask_loop(Service, Observer, Delay, Token, Token, true);
        {computed, Current, Value} when Active ->
            Observer ! {finished, Current, false, Value},
            ask_loop(Service, Observer, Delay, Next, Current, false);
        {expire, Current} when Active ->
            Observer ! {finished, Current, true, 0},
            ask_loop(Service, Observer, Delay, Next, Current, false);
        query ->
            Observer ! {status, Active, Current},
            ask_loop(Service, Observer, Delay, Next, Current, Active);
        stop -> ok;
        _ -> ask_loop(Service, Observer, Delay, Next, Current, Active)
    end.
ask_service() ->
    receive
        {compute, From, Token, Value} ->
            From ! {computed, Token, Value * 2}, ask_service();
        stop -> ok
    end.
