set pagination off
set confirm off
break lmx_walk_value_receive
commands
silent
printf "RECV kind=%d type=%d wide=%llu natural=%u ty=%d\n", *(int*)($rcx+4), *(int*)($rcx+8), *(unsigned long long*)($rcx+32), *(unsigned int*)($rcx+40), (int)$rdx
bt 4
continue
end
run
bt 12
