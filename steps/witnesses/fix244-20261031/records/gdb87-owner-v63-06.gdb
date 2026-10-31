set pagination off
set confirm off
set $hits = 0
break lmx_pointer_store_context_in if $r9 != 0 && *(unsigned long long *)($r9 + 72) > $rsp - 0x400000 && *(unsigned long long *)($r9 + 72) < $rsp + 0x400000
commands
set $hits = $hits + 1
printf "STACK REFERENT pointer_store cell=%p raw=%p context=%p referent=%p rsp=%p\n", $rdx, $r8, $r9, *(void **)($r9 + 72), $rsp
bt 8
continue
end
break lmx_value_context_copy if $rdx != 0 && *(unsigned long long *)($rdx + 72) > $rsp - 0x400000 && *(unsigned long long *)($rdx + 72) < $rsp + 0x400000 && ($rcx < $rsp - 0x400000 || $rcx > $rsp + 0x400000)
commands
set $hits = $hits + 1
printf "STACK REFERENT context_copy dst=%p src=%p referent=%p rsp=%p\n", $rcx, $rdx, *(void **)($rdx + 72), $rsp
bt 8
continue
end
break *(lmx_copy_value+1440)
commands
printf "UNSUPPORTED in lmx_copy_value v=%p rsp=%p hits=%d\n", $rbx, $rsp, $hits
bt 4
kill
end
run
