set pagination off
set confirm off
set print thread-events off
# V63 producer, run 13 = run 12 with the context variable renamed: runs 11-12c
# assigned $cx, which is the CX register (low 16 bits of RCX = the arena argument
# of lmx_walk_place_load), so they corrupted it from the first place load on.
# Run 12 = run 11 with the place context read only when it is a
# plausible user-space pointer (run 11 stopped reading a place context
# 0xffffffffffffb960) and each caller printed first. Run 10 pinned the edge:
# context_outer_cell's Value context `references` reaches a node under
# try_dynamic_m's own Structure, which holds the `arena` cell. This run follows
# where that context enters, inside try_dynamic_m (l2_m15) up to the V63 copy:
# every own store through lmx_walk_value_store_with_writer (place, stored
# Value) and every lmx_walk_place_load (place, the raw content at its address,
# its context companion). Windows x64: rcx, rdx, r8, r9 are the arguments at
# entry; *$rsp is the return address.
# LmxWalkPlace = {address 0, storage 8, type 16, descriptor 20, context 24};
# LmxWalkValue = {present 0, kind 4, type 8, ref 16, ..., model 56,
# references 64, referent 72}.
break *l2_m15
commands 1
silent
printf "ENTER l2_m15\n"
enable 2 3 4
continue
end
break *lmx_walk_value_store_with_writer
commands 2
silent
set $pl = (char *) $rdx
set $vl = (char *) $r8
printf "STORE address=%p type=%d ctx=%p | value present=%d kind=%d type=%d ref=%p model=%p references=%p referent=%p from ", *(void **)$pl, *(int *)($pl + 16), *(void **)($pl + 24), *(int *)$vl, *(int *)($vl + 4), *(int *)($vl + 8), *(void **)($vl + 16), *(void **)($vl + 56), *(void **)($vl + 64), *(void **)($vl + 72)
info symbol *(void **)$rsp
continue
end
break *lmx_walk_place_load
commands 3
silent
set $pl = (char *) $rdx
set $ad = *(void **)$pl
set $ctxv = *(char **)($pl + 24)
printf "PLOAD address=%p raw=%p type=%d ctx=%p from ", $ad, *(void **)$ad, *(int *)($pl + 16), $ctxv
info symbol *(void **)$rsp
if (unsigned long long) $ctxv > 0x10000 && (unsigned long long) $ctxv < 0x7fffffffffff
  printf "  ctx present=%d kind=%d ref=%p model=%p references=%p referent=%p\n", *(int *)$ctxv, *(int *)($ctxv + 4), *(void **)($ctxv + 16), *(void **)($ctxv + 56), *(void **)($ctxv + 64), *(void **)($ctxv + 72)
end
continue
end
break *lmx_graph_copy_owned
commands 4
silent
printf "COPY root=%p arena=%p\n", $rcx, $rdx
kill
end
disable 2 3 4
run
