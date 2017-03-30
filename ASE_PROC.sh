#!/usr/bin/env zsh
# Usage:
#	./ASE_PROC.sh Task_name Bam_file Ref_genome SNP_file

####################################################

Name=$1			### Task name
BAM=$2			### Sorted BAM file
Ref_genome=$3		### Reference genome
SNP_BED=$4		### SNP file with BED format

##### Check Output folder

Output_folder=$(find . -name Output)
if [[ "$Output_folder" == "" ]]; then
	mkdir Output
fi

##### Filter Pileup

samtools mpileup -f $Ref_genome $BAM -l $SNP_BED | awk '$4>10{print $0}' > test.pileup
./bin/pileup2base.pl test.pileup 10 filter_pileup.txt
cat filter_pileup.txt | awk -F'\t' '{print $1"\t"$2-1"\t"$2"\t"$3"\t"$4+$8"\t"$5+$9"\t"$6+$10"\t"$7+$11}' | awk '$5+$6+$7+$8>10{print $0}'> "$Name.txt"
rm -f test.pileup filter_pileup.txt

##### Process Test File

./bin/SiteQ "$Name".txt -s $SNP_BED "$Name".site.tem
cat "$Name".site.tem | awk '{print "chr"$1"\t"$2"\t"$3"\t"$4"\t"$13"\t"$5"\t"$6"\t"$7"\t"$8}' > "$Name".test.1.tem
cat "$Name".site.tem | awk '{print $13}' | sed "s/\//\t/g" > "$Name".test.2.tem
paste "$Name".test.1.tem "$Name".test.2.tem > "$Name".test.tem
rm -f "$Name".txt

awk 'BEGIN{
	set = 0
	ref = 0
}
{
	while(substr($1,1,1)!=""){
		set=$10
		ref=$4
		if ( set==ref ){
			print $1"\t"$2"\t"$3"\t"$4"\t"$11"\t"$6"\t"$7"\t"$8"\t"$9
		}
		else{
			print $1"\t"$2"\t"$3"\t"$4"\t"$10"\t"$6"\t"$7"\t"$8"\t"$9
		}
		set = 0
		ref = 0
		next
	}
}' "$Name".test.tem > "$Name".full.tem

awk 'BEGIN{
	Ref_site = 0
	Alt_site = 0
	other_site1 = 0
	other_site2 = 0
	noise = 0
	total = 0
	criteria = 0
}
{ 
	while(substr($1, 1, 1)!=""){
		total = $6 + $7 + $8 + $9
		criteria = total * 0.1

		if ( $4 == "A" && $5 == "T" ) {Ref_site=$6; Alt_site=$7; other_site1=$8; other_site2=$9} 
		else if ( $4 == "A" && $5 == "C" ) {Ref_site=$6; Alt_site=$8; other_site1=$7; other_site2=$9}
		else if ( $4 == "A" && $5 == "G" ) {Ref_site=$6; Alt_site=$9; other_site1=$7; other_site2=$8}
		else if ( $4 == "T" && $5 == "A" ) {Ref_site=$7; Alt_site=$6; other_site1=$8; other_site2=$9}
		else if ( $4 == "T" && $5 == "C" ) {Ref_site=$7; Alt_site=$8; other_site1=$6; other_site2=$9}
		else if ( $4 == "T" && $5 == "G" ) {Ref_site=$7; Alt_site=$9; other_site1=$6; other_site2=$8}
		else if ( $4 == "C" && $5 == "A" ) {Ref_site=$8; Alt_site=$6; other_site1=$7; other_site2=$9}
		else if ( $4 == "C" && $5 == "T" ) {Ref_site=$8; Alt_site=$7; other_site1=$6; other_site2=$9}
		else if ( $4 == "C" && $5 == "G" ) {Ref_site=$8; Alt_site=$9; other_site1=$6; other_site2=$7}
		else if ( $4 == "G" && $5 == "A" ) {Ref_site=$9; Alt_site=$6; other_site1=$7; other_site2=$8}
		else if ( $4 == "G" && $5 == "T" ) {Ref_site=$9; Alt_site=$7; other_site1=$6; other_site2=$8}
		else if ( $4 == "G" && $5 == "C" ) {Ref_site=$9; Alt_site=$8; other_site1=$6; other_site2=$7}
						
		split( other_site1"\t"other_site2, a, " " )
		asort( a )
		noise = a[2]

		if( noise < criteria ){
			print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"Ref_site"\t"Alt_site
		}
	
		Ref_site = 0
		Alt_site = 0 
		noise = 0
		total = 0
		criteria = 0					
	next
	}
}' "$Name".full.tem | sed '/^$/d' > "$Name".test
rm -f *.tem


##### Perform chi-square test

Rscript bin/do_chisq_test.R "$Name".test "$Name".pval
rm -f "$Name".test

##### ASE status

awk 'BEGIN{
	ref = 0
	alt = 0
	pval = 0
}
{
	while(substr($1,1,1)!=""){
		ref = $6
		alt = $7
		pval = $8

		if ( ref > alt && alt != 0){
			RoverA = ref / alt
		}
		else if ( ref < alt && ref != 0){
			AoverR = alt / ref
		}
		else{
			RoverA = 0
			AoverR = 0
		}

		if ( pval >= 0.05 ){
			print $0"\t""Biallilic"
		}
		else if ( ref > alt && RoverA > 2 && pval < 0.001 ){
			print $0"\t""Ref"
		}
		else if ( ref > alt && alt = 0 && pval < 0.001 ){
			print $0"\t""Ref"
		}
		else if ( ref < alt && AoverR > 2 && pval < 0.001 ){
			print $0"\t""Alt"
		}
		else if ( ref < alt && ref = 0 && pval < 0.001 ){
			print $0"\t""Alt"
		}
		else{
			print $0"\t""Partial"
		}

		ref = 0
		alt = 0
		pval = 0
		next
	}
}' "$Name".pval > "$Name".output.tem

cat <(echo Chr"\t"Start"\t"End"\t"Ref"\t"Alt"\t"Ref_count"\t"Alt_count"\t"P-value"\t"Status) <(cat "$Name".output.tem) > Output/"$Name".output
rm -f "$Name".pval "$Name".output.tem
