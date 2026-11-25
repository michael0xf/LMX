#! /bin/bash
#
gcc -c -g -Wall -I/$HOME/include stroud_rule_test.c
if [ $? -ne 0 ]; then
  echo "Compile error."
  exit
fi
#
gcc stroud_rule_test.o /$HOME/libc/stroud_rule.o -lm
if [ $? -ne 0 ]; then
  echo "Load error."
  exit
fi
#
rm stroud_rule_test.o
#
mv a.out stroud_rule_test
./stroud_rule_test > stroud_rule_test.txt
if [ $? -ne 0 ]; then
  echo "Run error."
  exit
fi
rm stroud_rule_test
#
echo "Normal end of execution."
