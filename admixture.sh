#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 -p <parameter_file> -v <vcf_dir> -s <path_to_smc_file> -i <population_prefix> -n <num_haplotypes>

This script generates pyrho lookup tables and outputs stats on optimal hyperparams to use for recombination mapping (A2.5.3) Requires csv outputs from SMC++

Required argument:
  -p  Path to the parameter file (e.g., params_preprocessing.sh in the GitHub repository).
  -v  Path to chromosome-split vcfs"
    exit 1
fi

# Parse command-line arguments
while getopts ":p:v:o:k:" option; do
    case "${option}" in
        p) PARAMS=${OPTARG};;
        v) VCF=${OPTARG} ;;
        o) OUTPREFIX=${OPTARG} ;;
        k) NUM_K=${OPTARG} ;;
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
echo "Current script: A2.5.2_pyrho_recombination_params.sh"

if [ -d "${OUTDIR}/analyses/admixture/" ];
        then
            echo "admixture directory already exists, moving on!"
        else
            echo "making admixture directory"
            mkdir -p "${OUTDIR}/analyses/admixture/"
fi

# First convert VCF to PLINK .bed format and convert chromids to ints
if [ -f "${OUTDIR}/analyses/admixture/${OUTPREFIX}.bed" ];
        then
            echo "PLINK .bed converted file for ${VCF} already exists, moving on!"
        else
            echo "Converting ${VCF} to PLINK .bed file"
            bcftools annotate --rename-chrs ${OUTDIR}/referencelists/chroms_to_ints.txt ${VCF} -ou | \
            plink --vcf /dev/stdin \
                    --allow-extra-chr \
                    --make-bed \
                    --out ${OUTDIR}/analyses/admixture/${OUTPREFIX}.bed
fi

cd ${OUTDIR}/analyses/admixture/ # change dir since admixture apparently always outputs to working directory
echo ${NUM_K}
for k in $(seq ${NUM_K})
do 
    echo "Running admixture for K value: $k"
    admixture --cv ${OUTDIR}/analyses/admixture/${OUTPREFIX}_numeric.bed ${k} | tee admixlog_${OUTPREFIX}_${k}.out
    echo "Done running admixture for K $k"
done

echo "Done"