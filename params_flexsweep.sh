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
VCFDIR=${OUTDIR}/datafiles/rephased_vcf/chr_split
RECMAP_PREFIX=${OUTDIR}/datafiles/recombination_map/flexsweep/postjays_est_MLZ68995A_merged.fs.map