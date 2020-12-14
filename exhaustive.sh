#!/bin/bash

cat /dev/zerip > solutions.out.txt
for BASE in `seq 2 100` ; do
  (time ruby solve.rb $BASE) | tee -a solutions.out.txt
done
