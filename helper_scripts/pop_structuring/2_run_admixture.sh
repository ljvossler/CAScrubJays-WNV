#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 -p <parameter_file> -f <ped_file> -o <outprefix_for_files> -k <number_of_pops>

This script runs admixture from a .ped file for a single inputted K values.
Best run in a slurm array
All error rates across array can be obtained by: 
    awk '/CV/ {print $3,$4}' *out | cut -c 4,7-20 > ${OUTDIR}/analyses/admixture/${OUTPREFIX}.cv.error

Required argument:
  -p  Path to the parameter file (e.g., params_preprocessing.sh in the GitHub repository).
  -f  Path to .ped file
  -o  Output file prefix
  -k  Number of populations to test"
    exit 1
fi

# Parse command-line arguments
while getopts ":p:f:o:k:" option; do
    case "${option}" in
        p) PARAMS=${OPTARG};;
        f) PED=${OPTARG} ;;
        o) OUTPREFIX=${OPTARG} ;;
        k) K=${OPTARG} ;;
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
echo "Current script: 2_run_admixture.sh"

if [ -d "${OUTDIR}/analyses/admixture/${OUTPREFIX}" ];
        then
            echo "admixture directory already exists, moving on!"
        else
            echo "making admixture directory"
            mkdir -p "${OUTDIR}/analyses/admixture/${OUTPREFIX}"
fi

cd ${OUTDIR}/analyses/admixture/${OUTPREFIX}
echo "Running admixture for K value: $K"
admixture --cv ${PED} ${K} | tee admixlog_${OUTPREFIX}_${K}.out
echo "Done running admixture for K $K"

echo "Done"
