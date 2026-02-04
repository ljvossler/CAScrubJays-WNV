module load R/4.4.0
module load htslib/1.19.1
module load bedtools2/2.29.2
module load python/3.11/3.11.4
module load bwa/0.7.18
module load bcftools/1.19
module load vcftools/0.1.16
module load plink/1.9
module load samtools/1.19.2



# Define variables
# all
OUTDIR=/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv # main directory for output files
PROGDIR=/xdisk/mcnew/scrubjays_wnv/programs  # path to directory for all installed programs
BAMDIR=/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/datafiles/bam_files  # path to directory with bam files
PROJHUB=CAScrubJays-WNV
SCRIPTDIR=${PROGDIR}/${PROJHUB}
PATH=$PATH:$SCRIPTDIR # this adds the workshop script directory to our path, so that executable scripts in it can be called without using the full path
ID=scrub_jays
FILENAME_LIST="/path/to/list.txt" # list with sample codes associated with each file in dataset, one per line

# define aspects of the reference genome
CHRLEAD=NC_0 # characters at the start of a chromosome number (excluding scaffolds)
MTCODE=NC_051467.1 # code for mitochondrial chromosome. changed this from sex chromosome since sex chromosomes are already excluded in base_setup SCAFFOLD list generation, but the MTs are included
REF_ACC=GCF_041296385.1 # accession number for reference genome
REF=/xdisk/mcnew/scrubjays_wnv/a_coerulescens_ncbi_ref_genome/data/GCF_041296385.1/GCF_041296385.1_UR_Acoe_1.0_genomic.fna # path to reference genome
GFF=/xdisk/mcnew/scrubjays_wnv/a_coerulescens_ncbi_ref_genome/data/GCF_041296385.1/genomic.gff # path to gff file

# define the path for the chromosome conversion file (converts chromosome ascension names to numbers)
CHR_FILE=${OUTDIR}/referencelists/GCF_041296385.1_chromconversion.txt

source base_setup.sh