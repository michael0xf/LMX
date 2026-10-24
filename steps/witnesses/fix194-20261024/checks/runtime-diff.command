# The runtime's C against Verified193's, as run (cwd C:/Nyasha_Planet/LMX/build2): the changed lines' bounds, and the
# lines before and after them compared byte for byte.
O=opus_fix193/boot-quick-01/runtime/driver.c; N=opus_fix194/rt-01/driver.c
diff $O $N | grep -E '^[0-9]' | head -1; diff $O $N | grep -E '^[0-9]' | tail -1
cmp <(head -n 10180 $O) <(head -n 10180 $N) && echo "lines 1-10180 byte-equal"
cmp <(tail -n +10428 $O) <(tail -n +10794 $N) && echo "193 lines 10428- and 194 lines 10794- byte-equal"
