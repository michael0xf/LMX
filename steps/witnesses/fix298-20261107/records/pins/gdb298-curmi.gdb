set pagination off
set confirm off
set charset ASCII
break lm_compiler_scan_actuals_value
commands
silent
printf "SCAN_ACTUALS mi=%d cur_mi=%d here_mi=%d e=%d\n", (int)$r8, *(int*)&l2_cur_mi, *(int*)&l2_here_mi, *(int*)&l2_e
continue
end
break lm_compiler_dyn_local
commands
silent
printf "DYN_LOCAL cur_mi=%d\n", *(int*)&l2_cur_mi
continue
end
run
bt 3
