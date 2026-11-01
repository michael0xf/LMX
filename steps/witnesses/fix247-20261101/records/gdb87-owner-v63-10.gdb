set pagination off
set confirm off
set print thread-events off
# V63 parent edge (DRAFT79-OWNER-POINTER-CONTEXT-STACK-POINTEE). Run 09:
# the refusal is lmx_copy_value+1440 <- lmx_copy_reference_fill <-
# lmx_copy_value returning at +753 <- lmx_copy_process, so the refused
# `arena` cell is a child of a Structure the copy was processing and the edge
# that first reached that Structure is not on the stack. This run logs the
# copy traversal inside try_dynamic_m (l2_m15) only: every lmx_copy_process
# src, every lmx_copy_value and lmx_copy_reference_fill entry with its caller,
# and the kernel's own kind/type/source-name answers (Windows x64: rcx, rdx,
# r8 are the first arguments; *$rsp is the return address at entry).
# Lmx = {parent, native, array{size, data}}; a source name = {size, data}.
set $n = 0
set $limit = 40000
break *l2_m15
commands 1
silent
printf "ENTER l2_m15\n"
enable 2 3 4 5
continue
end
break *lmx_graph_copy_owned
commands 2
silent
printf "COPY root=%p arena=%p destination=%p\n", $rcx, $rdx, $r8
continue
end
break *lmx_copy_process
commands 3
silent
set $n = $n + 1
if $n < $limit
  set $src = $rcx
  set $sa = $rdx
  set $k = ((int (*)(void *, void *)) lmx_range_classify)($sa, $src)
  set $t = ((int (*)(void *, void *)) lmx_range_type_of)($sa, $src)
  printf "PROC src=%p kind=%d type=%d parent=%p children=%llu", $src, $k, $t, *(void **)$src, *(unsigned long long *)((char *)$src + 16)
  set $nm = ((void * (*)(void *, void *)) lmx_source_name_get)($sa, $src)
  if $nm != 0 && *(unsigned long long *)$nm > 0 && *(unsigned long long *)$nm < 64
    printf " name="
    eval "output *(char (*)[%llu]) %p", *(unsigned long long *)$nm, *(char **)((char *)$nm + 8)
  end
  printf "\n"
end
continue
end
break *lmx_copy_value
commands 4
silent
set $n = $n + 1
if $n < $limit
  set $v = $rcx
  set $sa = $rdx
  set $k = 0
  if $v != 0
    set $k = ((int (*)(void *, void *)) lmx_range_classify)($sa, $v)
  end
  printf "VAL v=%p kind=%d", $v, $k
  if $k != 0
    set $t = ((int (*)(void *, void *)) lmx_range_type_of)($sa, $v)
    printf " type=%d", $t
    set $nm = ((void * (*)(void *, void *)) lmx_source_name_get)($sa, $v)
    if $nm != 0 && *(unsigned long long *)$nm > 0 && *(unsigned long long *)$nm < 64
      printf " name="
      eval "output *(char (*)[%llu]) %p", *(unsigned long long *)$nm, *(char **)((char *)$nm + 8)
    end
  end
  printf " from "
  info symbol *(void **)$rsp
end
continue
end
break *lmx_copy_reference_fill
commands 5
silent
set $n = $n + 1
if $n < $limit
  set $c = $rcx
  set $sa = $r8
  set $t = ((int (*)(void *, void *)) lmx_range_type_of)($sa, $c)
  printf "FILL cell=%p type=%d stored=%p", $c, $t, *(void **)$c
  set $nm = ((void * (*)(void *, void *)) lmx_source_name_get)($sa, $c)
  if $nm != 0 && *(unsigned long long *)$nm > 0 && *(unsigned long long *)$nm < 64
    printf " name="
    eval "output *(char (*)[%llu]) %p", *(unsigned long long *)$nm, *(char **)((char *)$nm + 8)
  end
  printf " from "
  info symbol *(void **)$rsp
end
continue
end
break *(lmx_copy_value+1440)
commands 6
silent
printf "UNSUPPORTED v=%p events=%d\n", $rbx, $n
bt 12
kill
end
disable 2 3 4 5
run
