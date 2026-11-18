#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 -p <parameter_file> -v <vcf_file> -o <outprefix_for_files>

Generates required .ped input file from VCF.
Can be run interactively

Required argument:
  -p  Path to the parameter file (e.g., params_preprocessing.sh in the GitHub repository).
  -v  Path to filtered vcf file
  -o  Output file prefix"
    exit 1
fi

# Parse command-line arguments
while getopts ":p:v:o:" option; do
    case "${option}" in
        p) PARAMS=${OPTARG};;
        v) VCF=${OPTARG} ;;
        o) OUTPREFIX=${OPTARG} ;;
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
echo "Current script: 1_generate_input_admixture.sh"

if [ -d "${OUTDIR}/analyses/admixture/${OUTPREFIX}" ];
        then
            echo "admixture directory already exists, moving on!"
        else
            echo "making admixture directory"
            mkdir -p "${OUTDIR}/analyses/admixture/${OUTPREFIX}"
fi

# First convert VCF to PLINK .bed format and convert chromids to ints
echo "Converting ${VCF} to PLINK .bed file..."
plink --vcf ${VCF} --allow-extra-chr --make-bed --out ${OUTDIR}/analyses/admixture/${OUTPREFIX}/${OUTPREFIX}
# Extra processing for admixture
awk '{OFS="\t"; $1="0"; print}' ${OUTDIR}/analyses/admixture/${OUTPREFIX}/${OUTPREFIX}.bim > ${OUTDIR}/analyses/admixture/${OUTPREFIX}/${OUTPREFIX}_fixed.bim
mv ${OUTDIR}/analyses/admixture/${OUTPREFIX}/${OUTPREFIX}.bim ${OUTDIR}/analyses/admixture/${OUTPREFIX}/${OUTPREFIX}_original.bim
mv ${OUTDIR}/analyses/admixture/${OUTPREFIX}/${OUTPREFIX}_fixed.bim ${OUTDIR}/analyses/admixture/${OUTPREFIX}/${OUTPREFIX}.bim

echo DONE