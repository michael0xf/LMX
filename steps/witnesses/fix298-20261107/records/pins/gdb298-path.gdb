set pagination off
set confirm off
break l2_m1
commands
silent
printf "ENTER l2_m1 node=%p self=%p\n", $rcx, $rdx
break lmx_graph_ref_cell_in
break lmx_walk_graph_cell_place
break lmx_walk_place_load
break lmx_implements_unary_admission
continue
end
break l2_m2
commands
silent
printf "ENTER l2_m2\n"
continue
end
break l2_m0
commands
silent
printf "ENTER l2_m0\n"
continue
end
run
bt 3
finish
continue
bt 3
finish
continue
bt 3
finish
continue
bt 3
finish
continue
bt 3
finish
continue
bt 3
finish
continue
bt 12
