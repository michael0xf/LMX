start_link(WorkerModule) -> supervisor:start_link(?MODULE, WorkerModule).
init(WorkerModule) ->
    Flags = #{strategy => one_for_one, intensity => 1, period => 60},
    Child = #{id => worker, start => {WorkerModule,start_link,[]},
              restart => transient, shutdown => 5000, type => worker},
    {ok,{Flags,[Child]}}.
