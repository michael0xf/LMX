scope(A, B) ->
    Parent = self(),
    Children = [spawn_monitor(fun() -> Parent ! {result,self(),F()} end) || F <- [A,B]],
    gather(Children, 0, none).
gather([], Total, none) -> {ok,Total};
gather([], _, Error) -> {error,Error};
gather(Children, Total, Error) ->
    receive
        {result,_,{ok,V}} -> gather(Children, Total+V, Error);
        {result,_,{error,E}} ->
            [exit(P,shutdown) || {P,_} <- Children], gather(Children, Total, E);
        {'DOWN',Ref,process,_,normal} ->
            gather(lists:keydelete(Ref,2,Children), Total, Error);
        {'DOWN',Ref,process,_,Reason} ->
            Rest = lists:keydelete(Ref,2,Children),
            [exit(P,shutdown) || {P,_} <- Rest],
            gather(Rest, Total, case Error of none -> Reason; _ -> Error end)
    end.
