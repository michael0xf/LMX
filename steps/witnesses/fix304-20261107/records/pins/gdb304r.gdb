set pagination off
set confirm off
break lmx_callable_args_value
run 0 entry 7
echo === hit 1: parens -- tst\\args (c 3; a required)\n
set $ar = $rcx
set $outp = $r8
finish
p/d $eax
set $built = *(void**)$outp
p/x $built
set $s0 = ((void*(*)(void*,void*,unsigned long long))lmx_graph_ref_cell_in)($ar, $built, 0)
set $s1 = ((void*(*)(void*,void*,unsigned long long))lmx_graph_ref_cell_in)($ar, $built, 1)
echo slot 0 child, slot 1 child:\n
p/x *(void**)$s0
p/x *(void**)$s1
echo slot 0 value:\n
p ((int(*)(void*))lmx_int_value_known)(*(void**)$s0)
if *(void**)$s1 != 0
echo slot 1 value:\n
p ((int(*)(void*))lmx_int_value_known)(*(void**)$s1)
end
echo names of slot 0 and slot 1:\n
p ((unsigned long long(*)(void*,void*))lmx_source_name_get)($ar, $s0)
p ((unsigned long long(*)(void*,void*))lmx_source_name_get)($ar, $s1)
continue
echo === hit 2: bare -- tst\\args (skipped)\n
continue
echo === hit 3: zero -- zed\\args (c 3; z 0 explicit)\n
set $ar = $rcx
set $outp = $r8
finish
p/d $eax
set $built = *(void**)$outp
p/x $built
set $s0 = ((void*(*)(void*,void*,unsigned long long))lmx_graph_ref_cell_in)($ar, $built, 0)
set $s1 = ((void*(*)(void*,void*,unsigned long long))lmx_graph_ref_cell_in)($ar, $built, 1)
echo slot 0 child, slot 1 child:\n
p/x *(void**)$s0
p/x *(void**)$s1
echo slot 0 value:\n
p ((int(*)(void*))lmx_int_value_known)(*(void**)$s0)
if *(void**)$s1 != 0
echo slot 1 value:\n
p ((int(*)(void*))lmx_int_value_known)(*(void**)$s1)
end
echo names of slot 0 and slot 1:\n
p ((unsigned long long(*)(void*,void*))lmx_source_name_get)($ar, $s0)
p ((unsigned long long(*)(void*,void*))lmx_source_name_get)($ar, $s1)
continue
echo === hit 4: later -- two\\args (skipped)\n
continue
echo === hit 5: filled -- tst\\args as the second operand (c 3; a required)\n
set $ar = $rcx
set $outp = $r8
finish
p/d $eax
set $built = *(void**)$outp
p/x $built
set $s0 = ((void*(*)(void*,void*,unsigned long long))lmx_graph_ref_cell_in)($ar, $built, 0)
set $s1 = ((void*(*)(void*,void*,unsigned long long))lmx_graph_ref_cell_in)($ar, $built, 1)
echo slot 0 child, slot 1 child:\n
p/x *(void**)$s0
p/x *(void**)$s1
echo slot 0 value:\n
p ((int(*)(void*))lmx_int_value_known)(*(void**)$s0)
if *(void**)$s1 != 0
echo slot 1 value:\n
p ((int(*)(void*))lmx_int_value_known)(*(void**)$s1)
end
echo names of slot 0 and slot 1:\n
p ((unsigned long long(*)(void*,void*))lmx_source_name_get)($ar, $s0)
p ((unsigned long long(*)(void*,void*))lmx_source_name_get)($ar, $s1)
continue
echo === hit 6: computed -- comp\\args (c 3; a 2 + 3 not built)\n
set $ar = $rcx
set $outp = $r8
finish
p/d $eax
set $built = *(void**)$outp
p/x $built
set $s0 = ((void*(*)(void*,void*,unsigned long long))lmx_graph_ref_cell_in)($ar, $built, 0)
set $s1 = ((void*(*)(void*,void*,unsigned long long))lmx_graph_ref_cell_in)($ar, $built, 1)
echo slot 0 child, slot 1 child:\n
p/x *(void**)$s0
p/x *(void**)$s1
echo slot 0 value:\n
p ((int(*)(void*))lmx_int_value_known)(*(void**)$s0)
if *(void**)$s1 != 0
echo slot 1 value:\n
p ((int(*)(void*))lmx_int_value_known)(*(void**)$s1)
end
echo names of slot 0 and slot 1:\n
p ((unsigned long long(*)(void*,void*))lmx_source_name_get)($ar, $s0)
p ((unsigned long long(*)(void*,void*))lmx_source_name_get)($ar, $s1)
delete
continue
