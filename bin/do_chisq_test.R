#! /usr/bin/env Rscript

# Usage:
#    ./do_chisq_test.R INPUT.txt OUTPUT.txt

args <- commandArgs(TRUE)
in_file <- args[1]
out <- gsub("[.]test", "", in_file)
out_file <- paste(out, "pval", sep=".")

FILE <- read.table(in_file, header=FALSE)
FILELength <- dim(FILE)[1]
pval.FILE <- c()
for(i in 1:FILELength){
    if (sum(FILE[i,6:7]) == 0) {
        pval.FILE[i] = NA
    } else {
        pval.FILE[i] = chisq.test(c(FILE[i,6], FILE[i,7]), p = c(1, 1), rescale.p=T)$p.value
    }
}

new.FILE = cbind(FILE, pval.FILE)
write.table(new.FILE, file=out_file, sep="\t", row.names=FALSE, col.names=FALSE, quote=FALSE)
