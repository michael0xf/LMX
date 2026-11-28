selective(Observer) -> selective_loop(Observer, 0, []).
selective_loop(Observer, Phase, Queue) ->
    receive
        {work, Id, _} when Phase =:= 2 ->
            Observer ! {rejected, Id, 2},
            selective_loop(Observer, Phase, Queue);
        {work, Id, Value} when Phase =:= 1, Queue =:= [] ->
            Observer ! {finished, Id, Value * 2},
            selective_loop(Observer, Phase, Queue);
        {work, Id, _} when length(Queue) =:= 2 ->
            Observer ! {rejected, Id, 1},
            selective_loop(Observer, Phase, Queue);
        {work, Id, Value} ->
            case Phase of 1 -> self() ! pump; _ -> ok end,
            selective_loop(Observer, Phase, Queue ++ [{Id, Value}]);
        {become, Mode} when Phase =/= 2, (Mode =:= 0 orelse Mode =:= 1) ->
            case {Mode, Queue} of {1, [_|_]} -> self() ! pump; _ -> ok end,
            selective_loop(Observer, Mode, Queue);
        pump when Phase =:= 1, Queue =/= [] ->
            [{Id, Value}|Rest] = Queue,
            Observer ! {finished, Id, Value * 2},
            case Rest of [] -> ok; _ -> self() ! pump end,
            selective_loop(Observer, Phase, Rest);
        {reply, Id, Value} ->
            Observer ! {reply_seen, Id, Value},
            selective_loop(Observer, Phase, Queue);
        query ->
            Observer ! {status, Phase, length(Queue)},
            selective_loop(Observer, Phase, Queue);
        stop when Phase =/= 2 ->
            [Observer ! {rejected, Id, 2} || {Id, _} <- Queue],
            Observer ! stopped,
            selective_loop(Observer, 2, []);
        terminate -> ok;
        _ -> selective_loop(Observer, Phase, Queue)
    end.
