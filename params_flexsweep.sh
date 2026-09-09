source ../params_base.sh
source ${PROGDIR}/CAScrubJays-WNV/submit_scripts/.venv/bin/activate

# General
POPNAME=alljays
THREADS=24

# Simulations
NUM_HAPS=160 # Number of haplotypes (2x sample size)
DEMES=/path/to/demes/yaml/file
SIMULATIONS=250000

# VCF feature vectors
VCFDIR=/path/to/vcf/directory
REC_MAP=/path/to/recombination/map/file