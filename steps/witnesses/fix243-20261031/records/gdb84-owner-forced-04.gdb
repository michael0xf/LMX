set pagination off
set confirm off
break lmx_walk_call_prim_dispatch
commands
silent
printf "== dispatch refs=%llx nargs=%llu\n", $r9, *(unsigned long long *)($rsp+0x28)
continue
end
break lmx_walk_args_open_values
commands
silent
printf "args_open\n"
continue
end
break lmx_walk_snapshot_args
commands
silent
printf "snapshot\n"
continue
end
break lmx_walk_receive
commands
silent
printf "receive\n"
continue
end
break lmx_walk_load_body
commands
silent
printf "load_body\n"
continue
end
break lmx_walk_body
commands
silent
printf "body\n"
continue
end
break lmx_walk_publish
commands
silent
printf "publish\n"
continue
end
break lmx_call_note_walk_fail
commands
printf "FAIL st=%d\n", $rcx
bt 6
kill
end
run
