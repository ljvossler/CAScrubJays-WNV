source ../params_base.sh
source ${PROGDIR}/CAScrubJays-WNV/submit_scripts/.venv/bin/activate

# General
POPNAME=alljays
THREADS=12

# Simulations
NUM_HAPS=160 # (2x sample size)
DEMES=${OUTDIR}/datafiles/demography/post_jays.yaml
SIMULATIONS=250000

# VCF feature vectorsflexsweep_reformatted.fs.map
VCFDIR=${OUTDIR}/datafiles/split_vcf/phased/vcfs/reheadered
RECMAP=${OUTDIR}/datafiles/recombination_map/flexsweep/old/flexsweep_reformatted.map