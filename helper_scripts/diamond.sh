#!/bin/bash
# --------------------
### Directives Section
# --------------------
#SBATCH --job-name=rec_best_hits
#SBATCH --account=mcnew
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=3
#SBATCH --time=24:00:00
#SBATCH --output ../slurm_outs/%x.out


source "/xdisk/mcnew/scrubjays_wnv/programs/CAScrubJays-WNV/params_base.sh"
module load R/4.5.2

QUERY_FASTA=/xdisk/mcnew/scrubjays_wnv/human_GRCh38_dataset/ncbi_dataset/data/GCF_000001405.40/GCF_000001405.40_GRCh38.p14_genomic.fna
SUBJECT_FASTA=${REF}
THREADS=3
OUT_PATH=${OUTDIR}/datafiles/diamond


Rscript ${SCRIPTDIR}/helper_scripts/reciprocal_best_hits.r ${QUERY_FASTA} ${SUBJECT_FASTA} ${THREADS} ${OUT_PATH}
echo "DONE"