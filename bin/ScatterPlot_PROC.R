#! /usr/bin/env Rscript

# Usage:
#    ./ScatterPlot_PROC.R INPUT.txt Out_name

############################## Scatter plot Proc ##############################

args = commandArgs(TRUE)
in_file = args[1]
out_name = args[2]
FILE = read.table(in_file, header=FALSE)

chr = strsplit( toString( FILE[1,1] ),":" )[[1]][1]
base1 = strsplit( toString( FILE[1,1] ),":" )[[1]][3]

ref_max = max( FILE[,4] ) + 10
alt_max = max( FILE[,5] ) + 10

png( out_name, width = 800, height = 360 )
plot( FILE[,4], FILE[,5], xlab=c("Ref Count"), ylab=c("Alt Count"), cex.lab=1.5, pch=19, cex.axis=1.5, las="1", cex=0.5, 
	xlim=c(0, ref_max), bty="l", ylim=c(0, alt_max), 
	main = paste(chr, ", ", base1, "\n", "# of applicable individuals: ", length(FILE[,4]), sep="") )
dev.off()

############################################################################
