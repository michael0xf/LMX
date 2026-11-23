proactor(Submit, Write) ->
    Ref = make_ref(), Submit(3, Ref, self()),
    receive {completed, Ref, Bytes} -> Write(Bytes) end.
