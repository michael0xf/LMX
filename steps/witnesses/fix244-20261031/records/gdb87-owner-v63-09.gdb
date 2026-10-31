set pagination off
set confirm off
set $lastv = 0
set $srcarena = 0
break lmx_copy_reference_fill
commands
silent
set $lastv = $rcx
set $srcarena = $r8
continue
end
break *(lmx_copy_value+1440)
commands
printf "UNSUPPORTED v=%p from reference cell %p (stored %p)\n", $rbx, $lastv, *(void **)$lastv
print ((int (*)(void *, void *)) lmx_range_type_of)($srcarena, $lastv)
print ((int (*)(void *, void *)) lmx_domain_kind)($srcarena, $lastv)
print ((void * (*)(void *, void *)) lmx_source_name_get)($srcarena, $lastv)
x/2gx $3
x/16xb *(char **)((char *)$3 + 8)
x/5c *(char **)((char *)$3 + 8)
bt 3
kill
end
run
