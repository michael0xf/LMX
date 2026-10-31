set pagination off
set confirm off
set $armed = 0
break lmx_graph_copy_owned
commands
silent
printf "== graph_copy_owned root=%p\n", $rcx
set $armed = 1
continue
end
break lmx_copy_ensure_graph if $armed == 1
commands
silent
printf "ensure_graph\n"
continue
end
break lmx_copy_reference_snapshot if $armed == 1
commands
silent
printf "reference_snapshot\n"
continue
end
break lmx_copy_project_context if $armed == 1
commands
silent
printf "project_context\n"
continue
end
break *(lmx_copy_project_context+130) if $armed == 1
commands
silent
printf "project_context ret+130 %d\n", $rax
continue
end
break *(lmx_copy_project_context+149) if $armed == 1
commands
silent
printf "project_context ret+149 %d\n", $rax
continue
end
break *(lmx_copy_project_context+173) if $armed == 1
commands
silent
printf "project_context ret+173 %d\n", $rax
continue
end
break lmx_value_context_cell_in if $armed == 1
commands
silent
printf "context_cell_in v=%p\n", $rdx
continue
end
break *(lmx_value_context_cell_in+227) if $armed == 1
commands
silent
printf "context_cell_in ret %p\n", $rax
continue
end
run
