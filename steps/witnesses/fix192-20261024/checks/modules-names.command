# The stage's files the recipe rewrote (the twelve machine modules, their headers and C headers), against Verified191's
# stage, as run (cwd C:/Nyasha_Planet/LMX/build2): the raw diff lines, and the lines that still differ when every name of
# the six families in the 192 file is mapped back to its index with its derived tail kept.
P='s/\b(l2_(?:q|wv|fv|pr|s|p)\d+(?:_\d+)?)_[A-Za-z_][A-Za-z0-9_]*?(_from|_dirty)?\b/$1$2/g'
for f in $(diff -rq --exclude=l2_driver_launch.err opus_fix191/src opus_fix192/src | awk '{print $2}' | grep -v l2trans.lm1 | sed 's#opus_fix191/##') $(diff -rq --exclude=l2_driver_launch.err opus_fix191/headers opus_fix192/headers | awk '{print $2}' | sed 's#opus_fix191/##'); do
  r=$(diff opus_fix191/$f opus_fix192/$f | grep -c '^[<>]'); n=$(diff opus_fix191/$f <(perl -pe "$P" opus_fix192/$f) | grep -c '^[<>]')
  printf '%-40s raw %5s  names-mapped %s\n' $f $r $n
done
