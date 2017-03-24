#!/usr/bin/env zsh

# Usage:
#	./Graph_PROC.sh Position
#	Position format: chr1:1000:1001
Pos=$1
chr=$(echo $Pos | cut -d':' -f1)
base=$(echo $Pos | cut -d':' -f3)

mkdir Tmp
for file in Output/*.output
do
	cat $file | awk '{print $1":"$2":"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9}' | grep "$Pos" >> Tmp/Temp.txt
done

Rscript bin/ScatterPlot_PROC.R Tmp/Temp.txt "$chr":"$base"
rm -rf Tmp
