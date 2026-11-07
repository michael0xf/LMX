set pagination off
set confirm off
set charset ASCII
break lm_compiler_scan_actuals_value if $r8 == 1
commands
silent
set $p0nodeas = *(char**)($rcx+16)
set $p0frame = *(char**)($p0nodeas+8)
set $p0head = *(char**)($p0frame)
set $p0data = *(char**)($p0head)
printf "SCAN_ACTUALS mi=%d flags=%u headlen=%llu head=%c%c%c%c%c%c%c%c\n", (int)$r8, *(unsigned int*)($p0frame+8), *(unsigned long long*)($p0head+8), *(char*)($p0data), *(char*)($p0data+1), *(char*)($p0data+2), *(char*)($p0data+3), *(char*)($p0data+4), *(char*)($p0data+5), *(char*)($p0data+6), *(char*)($p0data+7)
continue
end
run
bt 3
