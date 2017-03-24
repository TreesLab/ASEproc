## Manual of ASEproc
###### Version: 1.0

##### We developed a new pipeline, ASEproc, which can help user to find allele specific expression site from RNA-seq data. We also built a graph procedure to help user draw the scatter plot.
--------------
#### 

The ASEproc's manual and test datset can be downloaded from our FTP site: 

####**1. System requirements**

   ASEproc runs under the Linux

   The R scripts used in ASEproc are developed under 3.3.0

####**2. Preparation**

   The users can download  file from the "" page.
  

 **2.1.  External tools**

   The following three tools are involved in the ASEproc:
```
   (1) Samtools (http://www.htslib.org/)
   (2) R (https://www.r-project.org/)
   (3) pileup2base (https://github.com/riverlee/pileup2base/blob/master/pileup2base.pl)
```
   
 **2.3.  Reference preparation**
 
The genomic sequences was downloaded from the GENCODE website at http://www.gencodegenes.org/. Given the human reference genome (GRCh38.p7, http://www.gencodegenes.org/releases/current.html) as an example:

```
   (1) Genome sequence FASTA file in GRCh38.p7.genome assembly: GRCh38.p7.genome.fa.gz
```

 **2.4.  Generating the bam files**

	The bam files for ASE procedure were generated from STAR aligner and Samtools, the users can generate it with the following command:

        > STAR --genomeDir Genome_dir --readFilesIn test_1.fq test_2.fq --runThreadN 10
        > cat <(samtools view -S -H Aligned.out.sam) <(samtools view -S Aligned.out.sam | awk '$5==255{print $0}') > test.sam
		> samtools view -S -b -o test.bam test.sam
		> samtools sort -o test_sort.bam test.bam
		> samtools index test_sort.bam

 **2.5.  Preparing the SNP files**

	The users must prepare the SNP file.

		> chr10	119168031	119168032	+	T	G/T	GT
		> chr10	123138743	123138744	+	T	C/T	CT
		> chr10	13278235	13278236	+	C	C/T	CT

The column format of SNP file is described as follows:
```
(1) Chromosome name 
(2) 0 base
(3) 1 base
(4) strand
(5) Reference base
(6) Reference base / Alternative base
(7) Alleles type


####**3. Execution of ASE procedure and Graph procedure**

   Usage:

        > ./ASE_PROC.sh [Task_name] [Bam_file] [Ref_genome] [SNP_file]
	> ./Graph_PROC.sh [Site_location]

   An example:

        > ./ASE_PROC.sh NA06984 NA06984.bam GRCh38.p7.genome.fa NA06984.bed
	> ./Graph_PROC chr1:10000:10001

The test bam files "NA06984.bam", "NA06985.bam" and SNP files "NA06984.bed", "NA06985.bed" can be downloaded from our FTP site: 

Note: The Graph_PROC.sh is executed after all ASE_PROC are finished.

####**4. ASE procedure outputs**

The output files are generated after executing the ASE_PROC, these files would be stored in Output folder

		> chr1	151760858	151760859	T	G	67	67	1	Biallilic
		> chr1	154584186	154584187	G	A	98	66	0.0124621582945403	Partial
		> chr1	155017118	155017119	T	C	24	22	0.768082561900943	Biallilic
```
The column format is described as follows:
```
(1) Chromosome name 
(2) 0 base
(3) 1 base
(4) Reference base
(5) Alternative base
(6) Reference base reads count
(7) Alternative base reads count
(8) P-value
(9) ASE status
```
