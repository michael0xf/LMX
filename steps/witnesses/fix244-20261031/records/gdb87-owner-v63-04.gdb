set pagination off
set confirm off
break *(lmx_copy_value+1440)
commands
printf "UNSUPPORTED in lmx_copy_value\n"
bt 8
info registers rbx rsi rdi rbp r12 r13 r14 r15
kill
end
break *(lmx_copy_ensure_graph+1041)
commands
printf "UNSUPPORTED in lmx_copy_ensure_graph\n"
bt 8
info registers rbx rsi rdi rbp r12 r13 r14 r15
kill
end
run
