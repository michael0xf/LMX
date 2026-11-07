set pagination off
set confirm off
break lmx_call_bind_actuals
commands
silent
printf "BIND arena=%p callee=%p nargs=%llu nnamed=%llu\n", $rcx, $rdx, $r8, $r9
finish
end
break lmx_call_note_walk_fail
commands
silent
printf "NOTE status=%d\n", (int)$rcx
bt 8
continue
end
run
continue
continue
continue
continue
bt 12
