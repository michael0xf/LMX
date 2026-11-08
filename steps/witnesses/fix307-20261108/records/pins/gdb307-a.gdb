set pagination off
set breakpoint pending on
set $inw = 0
break *lmx_call_bind_whole
commands
silent
set $inw = 1
printf "BIND_WHOLE arena=%llx code=%llx data=%llx count=%llu whole=%llx values=%llx route_count=%llu\n", $rcx, $rdx, $r8, $r9, *(unsigned long long *)($rsp+0x28), *(unsigned long long *)($rsp+0x30), *(unsigned long long *)($rsp+0x38)
continue
end
break *lmx_callable_headers
commands
silent
if $inw
printf "  headers selected=%llx\n", $rdx
end
continue
end
break *lmx_callable_source_count
commands
silent
if $inw
printf "  source_count part=%llx\n", $rdx
end
continue
end
break *lmx_callable_named_formal
commands
silent
if $inw
printf "  named_formal args=%llx wanted=%llu\n", $rdx, $r8
end
continue
end
break *lmx_implements_view_name
commands
silent
if $inw
printf "  view_name s=%llx i=%llu\n", $rdx, $r8
end
continue
end
break *lmx_walk_current_default
commands
silent
if $inw
printf "  current_default j=%llu\n", $r8
end
continue
end
break *lmx_call_formal_default
commands
silent
if $inw
printf "  formal_default j=%llu\n", $r8
end
continue
end
break *lmx_walk_value_cell
commands
silent
if $inw
printf "  value_cell cell=%llx\n", $rdx
end
continue
end
break *lmx_callable_source_entry
commands
silent
if $inw
printf "  source_entry index=%llu\n", $r8
end
continue
end
break *lmx_walk_receive_selected
commands
silent
if $inw
printf "  receive_selected numeric=%d\n", $r8
end
continue
end
break *lmx_call_receive_formal
commands
silent
if $inw
printf "  receive_formal index=%llu\n", $r9
end
continue
end
break *lmx_walk_argument_storage
commands
silent
if $inw
printf "  argument_storage\n"
end
continue
end
break *lmx_call_note_walk_fail
commands
silent
printf "NOTE_FAIL st=%d\n", $rcx
bt 6
continue
end
run
quit
