# The names-only comparison, as run (cwd S/runs/checks-01). E maps every name of the six families back to its index and
# masks the unit prefix the translator derives from the source path (l2_u<16 hex digits>_):
E='s/\b(l2_(q|wv|fv|pr|s|p)[0-9]+(_[0-9]+)?)_[A-Za-z_][A-Za-z0-9_]*/\1/g; s/\bl2_u[0-9A-F]{16}_/l2_uX_/g'
for p in "tool-g2/lmxtool.lm1 tool-g1/lmxtool.lm1" "tool-g2/lmxtool.c tool-g1/lmxtool.c" "runtime/driver.c runtime/driver.c"; do
  set -- $p
  diff C:/Nyasha_Planet/LMX/build2/opus_fix191/boot-quick-01/$1 C:/Nyasha_Planet/LMX/build2/opus_fix192/boot-quick-01/$2 | grep -c '^[<>]'
  diff <(sed -E "$E" C:/Nyasha_Planet/LMX/build2/opus_fix191/boot-quick-01/$1) <(sed -E "$E" C:/Nyasha_Planet/LMX/build2/opus_fix192/boot-quick-01/$2) | grep -c '^[<>]'
done

# The same with the derived tails kept: only the 192 text is mapped (a name between the index and an optional _from or
# _dirty is removed), the 191 text only has its unit prefix masked:
P='s/\b(l2_(?:q|wv|fv|pr|s|p)\d+(?:_\d+)?)_[A-Za-z_][A-Za-z0-9_]*?(_from|_dirty)?\b/$1$2/g; s/\bl2_u[0-9A-F]{16}_/l2_uX_/g'
U='s/\bl2_u[0-9A-F]{16}_/l2_uX_/g'
for p in "tool-g2/lmxtool.lm1 tool-g1/lmxtool.lm1" "runtime/driver.c runtime/driver.c"; do
  set -- $p
  diff <(perl -pe "$U" C:/Nyasha_Planet/LMX/build2/opus_fix191/boot-quick-01/$1) <(perl -pe "$P" C:/Nyasha_Planet/LMX/build2/opus_fix192/boot-quick-01/$2) | grep -c '^[<>]'
done
