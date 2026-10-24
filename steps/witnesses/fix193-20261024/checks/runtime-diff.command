# The runtime's C against Verified192's, as run (cwd C:/Nyasha_Planet/LMX/build2): the changed lines' bounds, and the
# lines before and after them compared byte for byte.
O=opus_fix192/boot-quick-01/runtime/driver.c; N=opus_fix193/rt-01/driver.c
diff $O $N | grep -E '^[0-9]' | head -1; diff $O $N | grep -E '^[0-9]' | tail -1
cmp <(head -n 19196 $O) <(head -n 19196 $N) && echo "lines 1-19196 byte-equal"
cmp <(tail -n +19414 $O) <(tail -n +19698 $N) && echo "192 lines 19414- and 193 lines 19698- byte-equal"
