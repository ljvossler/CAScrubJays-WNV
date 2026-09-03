#!/bin/sh

# Load parameters
source "/xdisk/mcnew/scrubjays_wnv/programs/CAScrubJays-WNV/params_base.sh"

module load R/4.5.2

QUERY_FASTA=
SUBJECT_FASTA=${REF}
THREADS=12
OUT_PATH=${OUTDIR}/datafiles/diamond

sbatch --account=mcnew
--job-name=rec_best_hits
--partition=standard
--output=slurm_output/%x.out
--nodes=1
--ntasks-per-node=${THREADS}
--time=24:00:00
Rscript ${SCRIPTDIR}/helper_scripts/reciprocal_best_hits.r ${QUERY_FASTA} ${SUBJECT_FASTA} ${THREADS} ${OUT_PATH}
echo "DONE"