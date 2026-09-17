#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 -p <parameter_file> -v <vcf_file> -o <outprefix_for_files>

This script plots a PCA for population structure analyses.

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
echo "Current script: PCA.sh"

if [ -d "${OUTDIR}/analyses/PCA/" ];
        then
            echo "PCA directory already exists, moving on!"
        else
            echo "making PCA directory"
            mkdir -p "${OUTDIR}/analyses/PCA/"
fi

# Prune VCF for linked variants
plink --vcf ${VCF} --double-id --allow-extra-chr \
    --set-missing-var-ids @:# \
    --indep-pairwise 50 10 0.1 --out "${OUTDIR}/analyses/PCA/${OUTPREFIX}"

# Conduct PCA
plink --vcf ${VCF} --double-id --allow-extra-chr --set-missing-var-ids @:# \
    --extract "${OUTDIR}/analyses/PCA/${OUTPREFIX}.prune.in" \
    --make-bed --pca --out "${OUTDIR}/analyses/PCA/${OUTPREFIX}"