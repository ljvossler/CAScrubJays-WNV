source ../params_base.sh
source ${PROGDIR}/CAScrubJays-WNV/submit_scripts/.venv/bin/activate

# General
POPNAME=alljays
THREADS=12

# Simulations
NUM_HAPS=160 # (2x sample size)
DEMES=${OUTDIR}/datafiles/demography/post_jays.yaml
SIMULATIONS=250000

# VCF feature vectors
VCFDIR=${OUTDIR}/datafiles/split_vcf/phased
REC_MAP=${OUTDIR}/datafiles/recombination_map/plink_cm/alljays_plink_cm_merged.map