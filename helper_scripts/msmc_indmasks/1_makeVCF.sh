#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 -p <parameter_file> -b <bamlist> -r <run_name>

This script calls variants for VCF file creation from BAM files. This will output VCF files containing ALLSITES. To be used to generating vcf / mask file inputs for VCFs when BEAGLE phasing
Will also do basic quality and depth filtering. Removing indels, while keeping homozygous reference and SNP sites.

Required argument:
  -p  Path to the parameter file (e.g., params_preprocessing.sh in the GitHub repository).
  -b  Path to bam list file for analysis
  -r  Run name, required for providing a unique name to output files."
    exit 1
fi

# Parse command-line arguments
while getopts p:r:b: option; do
    case "${option}" in
        p) PARAMS=${OPTARG};;
        r) RUNNAME=${OPTARG};;
        b) BAMLIST=${OPTARG};;
        *) echo "Invalid option: -${OPTARG}" >&2; exit 1;;
    esac
done

if [ -z "${PARAMS}" ]; then
    echo "Error: No parameter file provided." >&2
    exit 1
fi

# Load parameters
source "${PARAMS}"

printf "\n\n\n\n"
date
echo "Current script: 1_makeVCF.sh"

echo "Calling variants in parallel across chromosome regions"
echo "Outputting VCF with ALLSITES"


if [ -d "${OUTDIR}/datafiles/genotype_calls/allsites/filtered" ];
        then
            echo "output directory already exists, moving on!"
        else
            mkdir -p "${OUTDIR}/datafiles/genotype_calls/allsites/filtered"
fi

module load parallel
CHROMS=${OUTDIR}/referencelists/SCAFFOLDS.txt
SCAFFOLDS=${OUTDIR}/referencelists/SCAFFOLDS.unlabeled.txt

echo "Parallel variant calling on named macrochromosomes..."
echo "Processing ${THREADS} chromosomes at a time..."
cat ${CHROMS} | parallel --jobs "$THREADS" "
    bcftools mpileup -f ${REF} -r {} -b ${BAMLIST} -Ou -a FORMAT/AD,DP,INFO/AD,SP | \
    bcftools call -m -Ou -o ${OUTDIR}/datafiles/genotype_calls/allsites/${RUNNAME}_allsites_{}.vcf"

# Usually don't need to do unplaced scaffolds
#echo "Calling variants for unplaced scaffolds..."
#bcftools mpileup -f ${REF} -R ${SCAFFOLDS} -b ${BAMLIST} -Ou -a FORMAT/AD,DP,INFO/AD,SP | \
#bcftools call -m -Ou -o ${OUTDIR}/datafiles/genotype_calls/allsites/${RUNNAME}_allsites_scaffolds.vcf

echo "Parallel VCF filtering on named macrochromosomes..." # Quality & depth filtering. Also removing indels. Keeping homozygous reference sites
echo "Filtering ${THREADS} files at a time..."
cat ${CHROMS} | parallel --jobs "$THREADS" "
    bcftools view -v snps,ref -i 'QUAL>=100 && INFO/DP>=4' ${OUTDIR}/datafiles/genotype_calls/allsites/${RUNNAME}_allsites_{}.vcf \
        -o ${OUTDIR}/datafiles/genotype_calls/allsites/filtered/${RUNNAME}_allsites_{}_filtered.vcf"

echo "DONE"