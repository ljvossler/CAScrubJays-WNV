#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 -p <parameter_file> -i <ind_id> -v <variant_sites_file>

This script runs vcfAllSiteParser.py from msmc-tools to generate mask/vcf file pairs

Required argument:
  -p  Path to the parameter file (e.g., params_preprocessing.sh in the GitHub repository).
  -i  Individual ID to work on
  -v  Your variant file. Can be either in BCF or GZipped VCF format. Can be phased or unphased. Must include homozygous reference sites."
    exit 1
fi

# Parse command-line arguments
while getopts p:i:v: option; do
    case "${option}" in
        p) PARAMS=${OPTARG};;
        i) IND=${OPTARG};;
        v) VAR_FILE=${OPTARG};;
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
echo "Current script: 3_run_VCFparser.sh"

SCAFFOLD_FILE="${OUTDIR}/referencelists/SCAFFOLDS.txt"

for s in $(cat "${OUTDIR}/referencelists/SCAFFOLDS.txt"); do
    echo "Processing scaffold: ${s}"

    # Define output file paths
    MASK_OUT="${OUTDIR}/datafiles/msmc/mask/ind/${IND}.${s}.bed.gz"
    VCF_OUT="${OUTDIR}/datafiles/msmc/vcf/${IND}.${s}.vcf"

    # Using edited vcfparser script (required some syntax and parsing updates)
    bcftools view -r ${s} -s ${IND} -Ou ${VAR_FILE} | ${PROGDIR}/msmc-tools/vcfAllSiteParser.custom.py ${s} ${MASK_OUT} > ${VCF_OUT}

    echo "Completed scaffold ${s}."

done

echo "done with ${IND}"