#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 -p <parameter_file> -c <chr_id> -r <run_name>

This script phases and rephases VCFs created in 1_makeVCF.sh using BEAGLE and SAPPHIRE.
Will output chromosome-split rephased BCF files. These must be rearranged/resplit into Sample-Split VCFs prior to running 3_runVCFparser.sh.

Required argument:
  -p  Path to the parameter file (e.g., params_preprocessing.sh in the GitHub repository).
  -c  Chromosome ID to work on
  -r  Run name, required for providing a unique name to output files."
    exit 1
fi

# Parse command-line arguments
while getopts p:r:c: option; do
    case "${option}" in
        p) PARAMS=${OPTARG};;
        r) RUNNAME=${OPTARG};;
        c) CHR=${OPTARG};;
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
echo "Current script: 2_phasing.sh"

if [ -d "${OUTDIR}/datafiles/genotype_calls/allsites/phased/bcfs" ];
        then
            echo "phasing output directory already exists, moving on!"
        else
            mkdir -p "${OUTDIR}/datafiles/genotype_calls/allsites/phased/bcfs"
fi

VCF_IN=${OUTDIR}/datafiles/genotype_calls/allsites/filtered/${RUNNAME}_allsites_${CHR}_filtered.vcf
VCF_OUT=${OUTDIR}/datafiles/genotype_calls/allsites/phased/${RUNNAME}_allsites_${CHR}_phased
MAP=${OUTDIR}/datafiles/recombination_map/${RUNNAME}_plink_cm_${CHR}.map


echo "VCF_IN: $VCF_IN"
echo "VCF_OUT: $VCF_OUT"
echo "MAP: $MAP"

echo "running beagle"

beagle -Xmx20g gt=${VCF_IN} out=${VCF_OUT} map=${MAP} nthreads=4
bcftools index ${VCF_OUT}.vcf.gz

echo "bcf conversion"

BCF=${OUTDIR}/datafiles/genotype_calls/allsites/phased/bcfs/${RUNNAME}_allsites_${CHR}_phased.bcf
TAGGED_BCF=${OUTDIR}/datafiles/genotype_calls/allsites/phased/bcfs/${RUNNAME}_allsites_${CHR}_phased_tagfilled.bcf

bcftools view ${VCF_OUT}.vcf.gz -O b -o ${BCF}
bcftools index ${BCF}

echo "fill tags for rephasing"

echo "Filling INFO tags for AD, AC, and AN"
    bcftools +fill-tags "${BCF}" -Ob \
        -o "${TAGGED_BCF}" -- -t AF,AC,AN
    bcftools index "${TAGGED_BCF}"

echo "rephasing bcf"

${SCRIPTDIR}/Genomics-Main/A_Preprocessing/A2.7_rephasing.sh -p ${PARAMS} -c ${CHR} -b ${TAGGED_BCF} -m 0.01 -o "${OUTDIR}/datafiles/genotype_calls/allsites/rephased"

echo "DONE" 
