#!/bin/bash

# Usage message function
usage() {
    echo "Usage: $0 -p <parameter_file> -t <target_fasta> -q <query_fasta> -o <outfilename>

This script generates pairwise alignments in NEX-AXT format for use in ancify.

Required arguments:
  -p  Path to the parameter file (e.g., params_preprocessing.sh).
  -t  Path to target reference genome .fna file.
  -q  Path to query reference genome .fna file.
  -o  Outfile name
"
    exit 1
}

# Check if no arguments were provided
if [ $# -lt 1 ]; then
    usage
fi

DISTANCE=medium

# Parse command-line arguments
while getopts p:t:q:o: option; do
    case "${option}" in
        p) PARAMS=${OPTARG};;
        t) TARGET_FA=${OPTARG};;
        q) QUERY_FA=${OPTARG};;
        o) OUTNAME=${OPTARG};;
        d) DISTANCE=${OPTARG};;
        *) echo "Invalid option: -${OPTARG}" >&2; exit 1;;
    esac
done

# Ensure required arguments are provided
if [ -z "$PARAMS" ] || [ -z "$TARGET_FA" ] || [ -z "$QUERY_FA" ]; then
    echo "Error: Missing required parameters." >&2
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
echo "Current script: pairwise_alignments.sh"

if [ ! -d "${OUTDIR}/datafiles/pairwise_alignments" ]; then
  echo "Directory for pairwise alignments does not exist. Creating now..."
  mkdir -p "${OUTDIR}/datafiles/pairwise_alignments" # -p creates parent directories if they don't exist
else
  echo "Directory for pairwise alignments already exists. Moving on..."
fi

# Prep variables and data files
TARGET_BASE=$(basename ${TARGET_FA} .fna)
QUERY_BASE=$(basename ${QUERY_FA} .fna)

TARGET_2BIT=${OUTDIR}/datafiles/pairwise_alignments/${TARGET_BASE}.2bit
QUERY_2BIT=${OUTDIR}/datafiles/pairwise_alignments/${QUERY_BASE}.2bit

TARGET_SIZES=${OUTDIR}/datafiles/pairwise_alignments/${TARGET_BASE}.chromsizes
QUERY_SIZES=${OUTDIR}/datafiles/pairwise_alignments/${QUERY_BASE}.chromsizes

TARGET_NET=${OUTDIR}/datafiles/pairwise_alignments/${TARGET_BASE}.net
QUERY_NET=${OUTDIR}/datafiles/pairwise_alignments/${QUERY_BASE}.net

echo "Converting FASTA genomes to 2bit format..."
faToTwoBit "${TARGET_FA}" "${TARGET_2BIT}"
faToTwoBit "${QUERY_FA}" "${QUERY_2BIT}"

echo "Generating chromosome size files..."
faSize -detailed "${TARGET_FA}" > "${TARGET_SIZES}"
faSize -detailed "${QUERY_FA}" > "${QUERY_SIZES}"

# Run pairwise alignment
RAW_AXT="${OUTDIR}/datafiles/pairwise_alignments/${OUTNAME}.axt"
echo "Running pairwise alignment..."
lastz "${TARGET_2BIT}[multiple]" "${QUERY_2BIT}[multiple]" \
  --step=19 --hspthresh=2200 --inner=2000 --gappedthresh=10000 --ydrop=3400 \
  --format=axt > ${RAW_AXT}

# Chaining and Netting alignment
RAW_CHAIN="${OUTDIR}/datafiles/pairwise_alignments/${OUTNAME}.raw.chain"
echo "Chaining alignments..."
axtChain -linearGap="medium" "${RAW_AXT}" "${TARGET_2BIT}" "${QUERY_2BIT}" "${RAW_CHAIN}"

# Sort and merge chains
SORTED_CHAIN="${OUTDIR}/datafiles/pairwise_alignments/${OUTNAME}.sorted.chain"
echo "Sorting and merging chains..."
chainMergeSort "${RAW_CHAIN}" | chainSort stdin "${SORTED_CHAIN}"

# Filter chains
FILTERED_CHAIN="${OUTDIR}/datafiles/pairwise_alignments/${OUTNAME}.filtered.chain"
echo "Running chainPreNet..."
chainPreNet "${SORTED_CHAIN}" "${TARGET_SIZES}" "${QUERY_SIZES}" "${FILTERED_CHAIN}"

# Make alignment nets
echo "Making alignment nets..."
chainNet "${FILTERED_CHAIN}" "${TARGET_SIZES}" "${QUERY_SIZES}" "${TARGET_NET}" "${QUERY_NET}"

# Make final converted files
NET_AXT="${OUTDIR}/datafiles/pairwise_alignments/${OUTNAME}.net.axt"
echo "Generating final .net.axt file..."
netToAxt "${TARGET_NET}" "${SORTED_CHAIN}" "${TARGET_2BIT}" "${QUERY_2BIT}" "${NET_AXT}"

echo "Done with pairwise alginments for ${OUTNAME}"