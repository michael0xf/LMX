#! /bin/bash
#
cp stroud_rule.h /$HOME/include
#
gcc -c -g -Wall stroud_rule.c
if [ $? -ne 0 ]; then
  echo "Compile error."
  exit
fi
#
mv stroud_rule.o ~/libc/stroud_rule.o
#
echo "Normal end of execution."
