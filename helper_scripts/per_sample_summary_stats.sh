#!/bin/bash

# Usage message function
usage() {
    echo "Usage: $0 -p <parameter_file> -b <bam_list>

This script generates per-individual mean global heterozygosity.

Required arguments:
  -p  Path to the parameter file (e.g., params_preprocessing.sh).
  -b  Path to bamlist file.
"
    exit 1
}

# Check if no arguments were provided
if [ $# -lt 1 ]; then
    usage
fi


# Parse command-line arguments
while getopts p:b: option; do
    case "${option}" in
        p) PARAMS=${OPTARG};;
        b) BAMLIST=${OPTARG};;
        *) echo "Invalid option: -${OPTARG}" >&2; exit 1;;
    esac
done

# Ensure required arguments are provided
if [ -z "$PARAMS" ] || [ -z "$BAMLIST" ]; then
    echo "Error: Both -p (parameter file) and -b (bamlist file) are required." >&2
    usage
fi

# Load parameters from the provided file
if [ ! -f "$PARAMS" ]; then
    echo "Error: Parameter file '$PARAMS' not found." >&2
    exit 1
fi

source "$PARAMS"

# Print script start information
echo -e "\n$(date)"
echo "Current script: per_sample_summary_stats.sh"

if [ ! -d "${OUTDIR}/datafiles/sample_safs" ]; then
  echo "Directory for sample safs does not exist. Creating now..."
  mkdir -p "${OUTDIR}/datafiles/sample_safs" # -p creates parent directories if they don't exist
else
  echo "Directory for sample safs already exists. Moving on..."
fi

HET_FILE=${OUTDIR}/analyses/sample_avg_het.txt

for bam in $(cat ${BAMLIST}); do
  sample=$(basename "$bam" .realigned.bam)
  echo "Computing summary heterozygosity stats for $sample"

  # Get sample saf
  angsd -i $bam -anc ${REF} \
    -dosaf 1 -gl 1 -fold 1 \
    -minQ ${MINQ} -minmapq ${MINMAPQ} -C 50 -nthreads ${THREADS} \
    -out ${OUTDIR}/datafiles/sample_safs/$sample

  realSFS ${OUTDIR}/datafiles/sample_safs/$sample.saf.idx -fold 1 > ${OUTDIR}/datafiles/sample_safs/$sample1.ml

  het=$(awk '{print $2 / ($1 + $2)}' ${OUTDIR}/datafiles/sample_safs/$sample1.ml)
  echo -e "${sample}\t${het}" >> ${HET_FILE}
  echo "Mean heterozygosity for $sample is $het"
done

echo "Done. All stats saved to ${HET_FILE}"