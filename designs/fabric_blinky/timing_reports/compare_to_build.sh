#!/bin/bash
#
# 6/16/2025 D. W. Hawkins (dwh@caltech.edu)
#
# Compare the timing reports in this directory to those in the build area.
#
for i in {1..14..1}; do 
	diff -w timing_report_$i.txt ../build/libero_$i/timing_report.txt
	if [ $? == 0 ]; then
		echo "Variant $i: PASS"
	else
		echo "Variant $i: FAIL"
	fi
done
