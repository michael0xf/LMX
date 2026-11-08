set pagination off
break *lmx_implements_view_name
run
printf "hit1 s=%llx i=%llu\n", $rdx, $r8
finish
printf "ret1=%llu\n", $rax
continue
printf "hit2 s=%llx i=%llu\n", $rdx, $r8
finish
printf "ret2=%llu\n", $rax
continue
printf "hit3 s=%llx i=%llu\n", $rdx, $r8
set $ar = $rcx
set $s = $rdx
set $cell0 = ((void* (*)(void*, unsigned long long))lmx_arena_ref_cell)($s, 0)
set $cell1 = ((void* (*)(void*, unsigned long long))lmx_arena_ref_cell)($s, 1)
printf "cell0=%llx cell1=%llx\n", $cell0, $cell1
printf "slotname0=%llu slotname1=%llu\n", ((unsigned long long (*)(void*, void*))lmx_source_name_get)($ar, $cell0), ((unsigned long long (*)(void*, void*))lmx_source_name_get)($ar, $cell1)
set $v0 = ((void* (*)(void*, void*, unsigned long long))lmx_graph_value_in)($ar, $s, 0)
set $v1 = ((void* (*)(void*, void*, unsigned long long))lmx_graph_value_in)($ar, $s, 1)
printf "v0=%llx v1=%llx\n", $v0, $v1
printf "valname0=%llu valname1=%llu\n", ((unsigned long long (*)(void*, void*))lmx_source_name_get)($ar, $v0), ((unsigned long long (*)(void*, void*))lmx_source_name_get)($ar, $v1)
printf "head0=%llu head1=%llu\n", ((unsigned long long (*)(void*, void*, unsigned long long))lmx_source_name_get_at)($ar, $cell0, -2), ((unsigned long long (*)(void*, void*, unsigned long long))lmx_source_name_get_at)($ar, $cell1, -2)
printf "kind_s=%d kind_v0=%d kind_v1=%d\n", ((int (*)(void*, void*))lmx_range_classify)($ar, $s), ((int (*)(void*, void*))lmx_range_classify)($ar, $v0), ((int (*)(void*, void*))lmx_range_classify)($ar, $v1)
finish
printf "ret3=%llu\n", $rax
continue
printf "hit4 s=%llx i=%llu\n", $rdx, $r8
finish
printf "ret4=%llu\n", $rax
kill
quit
