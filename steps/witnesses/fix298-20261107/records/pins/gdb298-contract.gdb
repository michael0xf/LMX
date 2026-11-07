set pagination off
set confirm off
set charset ASCII
break lm_compiler_scan_actuals_value if $r8 == 1
commands
silent
printf "SCAN_ACTUALS mi=%d\n", (int)$r8
tbreak lm_compiler_head_method
tbreak lm_compiler_path_resolve_contract
continue
end
run
bt 2
finish
printf "RET rax=%d\n", (int)$rax
bt 2
finish
printf "RET rax=%d\n", (int)$rax
bt 2
finish
printf "RET rax=%d\n", (int)$rax
bt 2
finish
printf "RET rax=%d\n", (int)$rax
bt 2
