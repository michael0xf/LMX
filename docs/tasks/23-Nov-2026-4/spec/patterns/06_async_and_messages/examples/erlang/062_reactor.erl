reactor(ReadReady, Unregister, Write) ->
    receive
        {ready, Fd} ->
            N = ReadReady(Fd),
            if N > 0 -> Write(N); N < 0 -> Unregister(Fd); true -> ok end,
            reactor(ReadReady, Unregister, Write);
        stop -> ok
    end.
