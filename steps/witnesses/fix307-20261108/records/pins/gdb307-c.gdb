set pagination off
break *lmx_implements_view_name
run
continue
continue
set $ar = $rcx
set $s = $rdx
set $n = ((unsigned long long (*)(void*))lmx_arena_ref_count)($s)
printf "Args count=%llu\n", $n
set $i = 0
while $i < 4
  set $c = ((void* (*)(void*, unsigned long long))lmx_arena_ref_cell)($s, $i)
  set $v = ((void* (*)(void*, void*, unsigned long long))lmx_graph_value_in)($ar, $s, $i)
  printf "cell %d: cell=%llx slotname=%llu head=%llu value=%llx kind=%d valname=%llu\n", $i, $c, ((unsigned long long (*)(void*, void*))lmx_source_name_get)($ar, $c), ((unsigned long long (*)(void*, void*, unsigned long long))lmx_source_name_get_at)($ar, $c, -2), $v, ((int (*)(void*, void*))lmx_range_classify)($ar, $v), ((unsigned long long (*)(void*, void*))lmx_source_name_get)($ar, $v)
  set $i = $i + 1
end
set $v1 = ((void* (*)(void*, void*, unsigned long long))lmx_graph_value_in)($ar, $s, 1)
set $n1 = ((unsigned long long (*)(void*))lmx_arena_ref_count)($v1)
printf "cell1 struct count=%llu\n", $n1
set $i = 0
while $i < $n1 && $i < 6
  set $v = ((void* (*)(void*, void*, unsigned long long))lmx_graph_value_in)($ar, $v1, $i)
  printf "  sub %d: value=%llx kind=%d valname=%llu\n", $i, $v, ((int (*)(void*, void*))lmx_range_classify)($ar, $v), ((unsigned long long (*)(void*, void*))lmx_source_name_get)($ar, $v)
  set $i = $i + 1
end
kill
quit
