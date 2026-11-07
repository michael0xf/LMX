set pagination off
set confirm off
set charset ASCII
break lm_compiler_scan_actuals_value if $r8 == 1
commands
silent
printf "SCAN_ACTUALS mi=%d\n", (int)$r8
tbreak lm_compiler_application_site_bind
tbreak lm_compiler_path_resolve
continue
end
run
printf "STOP1 rcx=%p rdx=%d r8=%d\n", $rcx, (int)$rdx, (int)$r8
bt 4
finish
continue
printf "STOP2 rcx=%p rdx=%d r8=%d\n", $rcx, (int)$rdx, (int)$r8
bt 4
finish
continue
bt 3
