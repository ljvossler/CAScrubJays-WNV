module load bwa/0.7.17
module load samtools/1.19.2
module load bowtie2
module load picard
module load samtools
module load parallel
module load bcftools/1.19
module load vcftools/0.1.16
module load plink/1.9

source /xdisk/mcnew/scrubjays_wnv/programs/CAScrubJays-WNV/params_base.sh
#source /xdisk/mcnew/scrubjays_wnv/programs/CAScrubJays-WNV/Genomics-Main/A_Preprocessing/preprocessing_setup.sh uncomment since we are now setup

# across all preprocessing
THREADS=12

# trimming
FASTAS=/xdisk/mcnew/scrubjays_wnv/aphelocoma_sequence_data/test_fastqs # format must be samplename_
TRIMJAR=${PROGDIR}/trimmomatic/trimmomatic-0.40.jar
LEAD=20 # value to trim from leading strand, often 20
TRAIL=20 # value to trim from trailing strand, often 20
SLIDE=4:20 # threshold and windlow length, often 4:20
MINREADLEN=90 # minimum length for a read to be kept, often 90 for 150bp sequencing

# clipping
BAMUTILBAM=${PROGDIR}/bamUtil-master/bin/bam # Path to bamUtil bam executable. Ensure that this binary file has executable permissions (chmod +x)

# bam statistics

# snp ID
ANGSD=~${PROGDIR}/angsd/ # path to directory with angsd executables
SNPPVAL=1e-6 # max p-value for snp to be considered significant, often 1e-6
MINDEPTHIND=4 # minimum depth per individual required for a site to be kept
MININD=7 # minimum number of individuals required for a site to be kept
MINQ=30 # minimum quality score required for a site to be kept
MINMAF=0.05 # minimum minor allele frequency required for a site to be kept
MINMAPQ=30 # minimum mapping quality score required for a site to be kept
POP=<SET_VALUE> # name of population


# generate mask
k=<SET_VALUE>
prefix=<SET_VALUE>