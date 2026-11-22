half_sync(Frames, Write) ->
    Parent = self(),
    Worker = spawn(fun() -> sync_worker(Write, Parent) end),
    [Worker ! {frame,F} || F <- Frames], Worker ! stop,
    receive drained -> ok end.
sync_worker(Write, Parent) ->
    receive
        {frame,F} -> Write(F * F), sync_worker(Write, Parent);
        stop -> Parent ! drained
    end.
