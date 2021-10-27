#!/bin/sh


#PBS -l nodes=1:ppn=1,walltime=100:00:00,mem=16gb                                                                       
#PBS -W x=FLAGS:ADVRES:lss0021_lab.197924                                                                               
#PBS -q general                                                                                                         
#PBS -m abe                                                                                                            
#PBS -d .  

### Load the Modules you need to use
module load fastqc/0.11.8
module load trimmomatic/0.38

### Define variable for directories.  Yes you can do this first!
DATADIR=/scratch/uha0001/sequences
WORKDIR=/scratch/uha0001/cleaned
OUTDIR=/home/uha0001/results/fastqc_cleaned

######  make a directory in SCRATCH for processing the data
### make Working directory
mkdir -p $WORKDIR
##### Make a directory for my results in my home folder
mkdir -p $OUTDIR

# cd to ouput directory
cd $DATADIR

################ Trimmomatic ###################################

### Copy over the list of Sequencing Adapters that we want Trimmomatic to look for (along with its default adapters)

ls | grep ".fq.gz" |cut -d "." -f 1 |cut -d "_" -f 1-6 | sort | uniq > list

## Move list to the working directory
mv list $WORKDIR
## Change to the working directory
cd $WORKDIR

### Copy over the list of Sequencing Adapters that we want Trimmomatic to look for (along with its default adapters)
cp /scratch/uha0001/sequences/AdaptersToTrim_All.fa .

### Run a while loop to process through the names in the list
while read i
do

###########################################################  Trim read for quality when quality drops below Q30 and remove sequences shorter than 36 bp
## PE for paired end phred-score-type  R1-Infile   R2-Infile  R1-Paired-outfile R1-unpaired-outfile R-Paired-outfile R2-unpaired-outfile  Trimming paramenter
## MINLEN:<length> #length: Specifies the minimum length of reads to be kept.
## SLIDINGWINDOW:<windowSize>:<requiredQuality>  #windowSize: specifies the number of bases to average across  
## requiredQuality: specifies the average quality required.	
#java -jar /opt/asn/apps/trimmomatic_0.38/Trimmomatic-0.35/trimmomatic-0.35.jar PE -threads 6 -phred33 "$i"_All_R1.fastq "$i"_All_R2.fastq "$i"_All_R1_paired.fastq "$i"_All_R1_unpaired.fastq "$i"_All_R2_paired.fastq "$i"_All_R2_unpaired.fastq ILLUMINACLIP:AdaptersToTrim.fa:2:30:10 HEADCROP:10 LEADING:30 TRAILING:30 SLIDINGWINDOW:6:30 MINLEN:36 
	## use the \ at the end to continue to next line
# NOT work: java -jar /opt/asn/apps/trimmomatic_0.38/Trimmomatic-0.35/trimmomatic-0.35.jar
# NOT work: java -jar /opt/asn/apps/trimmomatic_0.38/Trimmomatic-0.38/trimmomatic-0.38.jar PE -threads 6 -phred33 \
# NOT WORK: java -jar trimmomatic-0.38.jar PE -threads 6 -phred33 \
#java -jar /mnt/beegfs/home/aubmxa/.conda/envs/BioInfo_Tools/share/trimmomatic-0.39-1/trimmomatic.jar  PE -threads 6 -phred33 \
#	$DATADIR/"$i"_All_R1.fq.gz $DATADIR/"$i"_All_R2.fq.gz \
#	"$i"_All_R1_paired.fq.gz "$i"_All_R1_unpaired.fq.gz 	\
#	"$i"_All_R2_paired.fq.gz "$i"_All_R2_unpaired.fq.gz 	\
#	ILLUMINACLIP:AdaptersToTrim_All.fa:2:35:10 HEADCROP:10 LEADING:30 TRAILING:30 SLIDINGWINDOW:6:30 MINLEN:36
#
###########################################################
#java -jar /tools/trimmomatic-0.38/trimmomatic.jar PE -threads 6 -phred33 L8_X8_2_CKDL210013403-1a-AK26951-AK17479_HFYTYCCX2_L4_1.fq.gz L8_X8_2_CKDL210013403-1a-AK26951-AK17479_HFYTYCCX2_L4_2.fq.gz L8_X8_2_CKDL210013403-1a-AK26951-AK17479_HFYTYCCX2_L4_1_paired.fq.gz L8_X8_2_CKDL210013403-1a-AK26951-AK17479_HFYTYCCX2_L4_1_unpaired.fq.gz L8_X8_2_CKDL210013403-1a-AK26951-AK17479_HFYTYCCX2_L4_2_paired.fq.gz L8_X8_2_CKDL210013403-1a-AK26951-AK17479_HFYTYCCX2_L4_2_unpaired.fq.gz ILLUMINACLIP:AdaptersToTrim_All.fa:2:35:10 LEADING:30 HEADCROP:10 TRAILING:30 MINLEN:36 SLIDINGWINDOW:6:30

#java -jar /tools/trimmomatic-0.38/trimmomatic.jar PE -threads 6 -phred33 $DATADIR/"$i".fq.gz $DATADIR/"$i".fq.gz ILLUMINACLIP:AdaptersToTrim_All.fa:2:35:10 HEADCROP:10 LEADING:30 TRAILING:30 SLIDINGWINDOW:6:30 MINLEN:36 
###########################################################


java -jar /tools/trimmomatic-0.38/trimmomatic.jar PE -threads 6 -phred33 \
$DATADIR/"$i"_1.fq.gz $DATADIR/"$i"_2.fq.gz \
"$i"_1_paired.fq.gz "$i"_1_unpaired.fq.gz \
"$i"_2_paired.fq.gz "$i"_2_unpaired.fq.gz \
ILLUMINACLIP:AdaptersToTrim_All.fa:2:35:10 LEADING:30 HEADCROP:10 TRAILING:30 MINLEN:36 SLIDINGWINDOW:6:30




done<list	

## Run fastqc on the cleaned paired files
fastqc *.fq.gz

## move  the fastqc from the cleaned files to my home directory
mv *fastqc* $OUTDIR
