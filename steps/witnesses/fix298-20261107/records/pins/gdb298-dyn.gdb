set pagination off
set confirm off
set charset ASCII
break lm_compiler_dyn_add
commands
silent
printf "DYN_ADD mi=%d len=%llu first=%d\n", (int)$rcx, *(unsigned long long*)($rdx+8), *(unsigned char*)(*(char**)$rdx)
bt 12
continue
end
run
bt 4
