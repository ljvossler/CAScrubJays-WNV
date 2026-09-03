#!/bin/sh

# Load parameters
source "/xdisk/mcnew/scrubjays_wnv/programs/CAScrubJays-WNV/params_base.sh"

QUERY_FASTA=/xdisk/mcnew/scrubjays_wnv/human_GRCh38_dataset/ncbi_dataset/data/GCF_000001405.40/GCF_000001405.40_GRCh38.p14_genomic.fna
SUBJECT_FASTA=${REF}
THREADS=8
OUT_PATH=${OUTDIR}/datafiles/diamond

sbatch --account=mcnew
--job-name=rec_best_hits
--partition=standard
--output=../slurm_output/%x.out
--nodes=1
--ntasks-per-node=${THREADS}
--time=24:00:00
module load R/4.5.2
Rscript ${SCRIPTDIR}/helper_scripts/reciprocal_best_hits.r ${QUERY_FASTA} ${SUBJECT_FASTA} ${THREADS} ${OUT_PATH}
echo "DONE"