pool(Input) ->
    Parent = self(),
    A = spawn(fun() -> worker(Parent) end),
    B = spawn(fun() -> worker(Parent) end),
    distribute(Input, A, B),
    A ! stop, B ! stop,
    [receive {result, V} -> V end || _ <- Input].
distribute([], _, _) -> ok;
distribute([X | Xs], A, B) -> A ! {job, X}, distribute(Xs, B, A).
worker(Parent) ->
    receive
        {job, X} -> Parent ! {result, X * X}, worker(Parent);
        stop -> ok
    end.
