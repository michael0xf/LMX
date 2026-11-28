phase_parent(A, B, Observer) ->
    RA = monitor(process, A), RB = monitor(process, B),
    phase_loop(A, B, RA, RB, Observer, 1, 0, #{}, #{}, false).
phase_loop(A, B, RA, RB, Observer, Gen, Phase, Drained, Stopped, Failed) ->
    receive
        begin_stop when Phase =:= 0 ->
            A ! {drain, self(), Gen}, B ! {drain, self(), Gen},
            phase_loop(A,B,RA,RB,Observer,Gen,1,Drained,Stopped,Failed);
        {drained, Id, Gen, _} when Phase =:= 1, is_map_key(Id, Drained) ->
            phase_loop(A,B,RA,RB,Observer,Gen,Phase,Drained,Stopped,Failed);
        {drained, Id, Gen, OK} when Phase =:= 1, Id >= 0, Id =< 1 ->
            D = Drained#{Id => true}, F = Failed orelse not OK,
            P = case map_size(D) of
                2 -> A ! stop, B ! stop, 2;
                _ -> 1
            end,
            phase_loop(A,B,RA,RB,Observer,Gen,P,D,Stopped,F);
        {'DOWN', Ref, process, Pid, _} when Phase =:= 2,
              ((Ref =:= RA andalso Pid =:= A) orelse
               (Ref =:= RB andalso Pid =:= B)) ->
            S = Stopped#{Ref => true},
            case map_size(S) of
                2 -> Observer ! {finished, not Failed}, ok;
                _ -> phase_loop(A,B,RA,RB,Observer,Gen,Phase,Drained,S,Failed)
            end;
        query ->
            Observer ! {status, Phase, 2-map_size(Drained), 2-map_size(Stopped)},
            phase_loop(A,B,RA,RB,Observer,Gen,Phase,Drained,Stopped,Failed);
        _ -> phase_loop(A,B,RA,RB,Observer,Gen,Phase,Drained,Stopped,Failed)
    end.
phase_child(Id, Gen, Observer, Flush, Release) ->
    phase_child_loop(Id,Gen,Observer,Flush,Release,0,undefined).
phase_child_loop(Id,Gen,Observer,Flush,Release,Phase,Parent) ->
    receive
        {work, Value} when Phase =:= 0 ->
            Observer ! {value, Value*2},
            phase_child_loop(Id,Gen,Observer,Flush,Release,Phase,Parent);
        {work, _} ->
            Observer ! rejected,
            phase_child_loop(Id,Gen,Observer,Flush,Release,Phase,Parent);
        {drain, From, Gen} when Phase =:= 0 ->
            Flush(Gen, self()),
            phase_child_loop(Id,Gen,Observer,Flush,Release,1,From);
        {flushed, Gen, OK} when Phase =:= 1 ->
            Release(), Parent ! {drained, Id, Gen, OK},
            phase_child_loop(Id,Gen,Observer,Flush,Release,2,Parent);
        query ->
            Observer ! {child_status,Id,Phase},
            phase_child_loop(Id,Gen,Observer,Flush,Release,Phase,Parent);
        stop when Phase =:= 2 -> ok;
        _ -> phase_child_loop(Id,Gen,Observer,Flush,Release,Phase,Parent)
    end.
