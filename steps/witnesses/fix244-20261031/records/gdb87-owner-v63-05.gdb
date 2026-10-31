set pagination off
set confirm off
break lmx_pointer_store_context_in if $r9 != 0 && ((*(unsigned long long *)($r9 + 72)) >> 32) == 5
commands
printf "STACK REFERENT store cell=%p raw=%p context=%p referent=%p model=%p\n", $rdx, $r8, $r9, *(void **)($r9 + 72), *(void **)($r9 + 56)
bt 8
continue
end
break *(lmx_copy_value+1440)
commands
printf "UNSUPPORTED in lmx_copy_value v=%p\n", $rbx
bt 4
kill
end
run
