#!/bin/sh

#PBS -l nodes=1:ppn=6,walltime=24:00:00,mem=16gb                                                                
#PBS -W x=FLAGS:ADVRES:lss0021_lab.197924                                                                               
#PBS -q general                                                                                                         
#PBS -m abe                                                                                                             
#PBS -d .        

module load bwamem2/2.0
module load bwa/0.7.17
module load hisat/2.0.5
module load stringtie/1.3.3b
module load python/2.7.11
module load gcc/9.2.0
module load samtools/0.1.19
module load bcftools/1.3.2
module load gffread/1
module load gffcompare/1

#  Set the stack size to unlimited
#ulimit -s unlimited

# Turn echo on so all commands are echoed in the output log
#set -x

# Define DATADIR to be where the input files are
DATADIR=/scratch/uha0001/cleaned/momsequences    #   *** This is where the cleaned paired files are located
REFDIR=/scratch/uha0001/reference                         # this directory contains the indexed reference genome
OUTDIR=/scratch/uha0001/mapped
COUNTSDIR=/scratch/uha0001/ballgown
RESULTSDIR=/home/uha0001/Counts

#REF=TelagGenome     ## This is what the "easy name" will be for the genome

mkdir -p $OUTDIR
mkdir -p $COUNTSDIR
mkdir -p $RESULTSDIR

##################  Prepare the Reference Index for mapping with HiSat2   #############################
 #####   I already indexed the genome. We only need to do it once and then we can all use it.
 #####   You would likely need to do when you download your reference genome or transcriptome
 
######  Move to $REFDIR
#cd $REFDIR

###  Identify exons and splice sites
#gffread $REF.gff -T -o $REF.gtf
#extract_splice_sites.py $REF.gtf > $REF.ss
#extract_exons.py $REF.gtf > $REF.exon

#### Create a HISAT2 index
#hisat2-build --ss $REF.ss --exon $REF.exon $REF.fasta $REF_index

########################  Map and Count the Data using HiSAT2 and StringTie  ########################

# Move to the data directory
cd $DATADIR   #### This is where our clean paired reads are located.

## Create list of fastq files to map    Example file format: SRR629651_1_paired.fastq
# grab all fastq files, cut on the underscore, use only the first of the cuts, sort, use unique put in list

ls | grep ".fq.gz" |cut -d "." -f 1 |cut -d "_" -f 1-7| sort | uniq > list1
cd $OUTDIR
cp $DATADIR/list1 . 

#while read i;
#do

#gunzip $DATADIR/"$i"_paired.fq.gz

#done<list1
cd $DATADIR
ls | grep ".fq" |cut -d "." -f 1 |cut -d "_" -f 1-6 | sort | uniq > list
# Move to the directory for mapping

# copy the list of unique ids from the original files to map
cp $DATADIR/list . 

while read i;
do
  ## HiSat2 is the mapping program
  #  -p indicates number ofprocessors, --dta reports alignments for StringTie --rf is the read orientation
 # hisat2 -p 6 --dta --phred33       \
  #  -x "$REFDIR"/"$REF"_index       \
   # -1 "$DATADIR"/"$i"_1_fq.gz  -2 "$DATADIR"/"$i"_2_fq.gz      \
    #-S "$i".sam
#L8_X8_76_CKDL210013403-1a-AK8265-AK17479_HFYTYCCX2_L4_1_paired.fq.gz 
bwa mem -t 6 $REFDIR/GCA_009870125.1_UCI_Dpse_MV25_genomic.fa $DATADIR/"$i"_1_paired.fq $DATADIR/"$i"_2_paired.fq > "$i".sam

done<list




    ### view: convert the SAM file into a BAM file  -bS: BAM is the binary format corresponding to the SAM text format.
    ### sort: convert the BAM file to a sorted BAM file.
    ### Example Input: SRR629651.sam; Output: SRR629651_sorted.bam
#samtools view  -bS  "$i".sam | samtools sort  "$i"_sorted2.bam  # This does not work on ASC
#samtools view  -bS  "$i".sam | samtools sort  "$i"_sorted3      # This does not work on ASC
#samtools view -@ 6 -bS ${i}.sam > ${i}.bam  ### This works on ASC

#samtools sort -@ 12  ${i}.bam -o ${i}_sorted2       # This does not work on ASC
#samtools sort -@ 12  ${i}.bam    ${i}_sorted3.bam   ### This works! but get _sorted.bam.bam
#samtools sort -@ 12  ${i}.bam >  ${i}_sorted4       # This does not work on ASC
#samtools sort -@ 12  ${i}.bam    ${i}_sorted5       ### This works!  USE THIS
#samtools sort -@ 12  ${i}.bam >  ${i}_sorted6       # This does not work on ASC
#samtools sort -@ 6  "$i".bam    "$i"_sorted

# Index the BAM and get stats
#samtools flagstat   "$i"_sorted.bam   > "$i"_Stats.txt

  ### Stringtie is the program that counts the reads that are mapped to each gene, exon, transcript model. 
  ### Original: This will make transcripts using the reference geneome as a guide for each sorted.bam
  # eAB options: This will run stringtie once and  ONLY use the Ref annotation for counting readsto genes and exons 
#mkdir "$COUNTSDIR"/"$i"
#stringtie -p 6 -e -B -G "$REFDIR"/"$REF".gtf -o "$COUNTSDIR"/"$i"/"$i".gtf  -l "$i"  "$OUTDIR"/"$i"_sorted.bam

#done<list

#####################  Copy Results to home Directory.  These will be the files you want to bring back to your computer.
### these are your stats files from Samtools
#cp *.txt $RESULTSDIR
### The PrepDE.py is a python script that converts the files in your ballgown folder to a count matrix
# python /home/aubtss/class_shared/scripts/PrepDE.py /scratch/aubtss/GarterSnakeProject/ballgown. 
#cd ..
#python /home/aubtss/class_shared/scripts/PrepDE.py $COUNTSDIR
#cp *.csv $RESULTSDIR
