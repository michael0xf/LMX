producer_consumer() ->
    Parent = self(),
    Consumer = spawn(fun() -> consume(0, Parent) end),
    Consumer ! {item, 1}, Consumer ! {item, 2}, Consumer ! {item, 3},
    Consumer ! finish,
    receive {total, Total} -> Total end.
consume(Total, Parent) ->
    receive
        {item, V} -> consume(Total + V, Parent);
        finish -> Parent ! {total, Total}
    end.
