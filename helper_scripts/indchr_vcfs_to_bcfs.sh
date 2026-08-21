#!/bin/bash

# Usage message function
usage() {
    echo "Usage: $0 -p <parameter_file> -i <individual>"
    echo ""
    echo "This script converts a phased Individual-Scaffold VCF file (generated from A2.4) to a BCF."
    echo "It is best run as a Slurm array that calls this script for each individual."
    echo ""
    echo "Required arguments:"
    echo "  -p  Path to the parameter file (e.g., params_preprocessing.sh in the GitHub repository)."
    echo "  -i  Name of the individual to analyze."
    exit 1
}

# Parse command-line arguments
while getopts ":p:i:" option; do
    case "${option}" in
        p) PARAMS=${OPTARG} ;;
        i) IND=${OPTARG} ;;
        *) echo "Invalid option: -${OPTARG}" >&2; usage ;;
    esac
done

# Ensure all required arguments are provided
if [[ -z "$PARAMS" || -z "$IND" ]]; then
    echo "Error: Missing required arguments."
    usage
fi

# Load parameters
source "${PARAMS}"

# Ensure OUTDIR is set
if [ -z "$OUTDIR" ]; then
    echo "Error: OUTDIR is not defined. Please set this variable."
    exit 1
fi

if [ -d "${OUTDIR}/datafiles/vcf2/bcfs" ]; then
    echo "Directory ${OUTDIR}/datafiles/vcf2/bcfs exists."
else
    echo "Directory ${OUTDIR}/datafiles/vcf2/bcfs does not exist. Creating it now."
    mkdir -p ${OUTDIR}/datafiles/vcf2/bcfs
fi

echo "Processing individual: $IND"

SCAFFOLD_LST=${OUTDIR}/referencelists/SCAFFOLDS.txt
while read -r SCAFFOLD; do

    VCF_OUT="${OUTDIR}/datafiles/vcf2/${IND}.${SCAFFOLD}.phased"

    echo "Converting phased ${IND}-${SCAFFOLD} VCF to BCF"
    bcftools view ${VCF_OUT}.vcf.gz -O b -o ${OUTDIR}/datafiles/vcf2/bcfs/${IND}.${SCAFFOLD}.phased.bcf
    bcftools index ${OUTDIR}/datafiles/vcf2/bcfs/${IND}.${SCAFFOLD}.phased.bcf

done < "$SCAFFOLD_LST"


echo "BCF conversion for ${IND} completed."
date
