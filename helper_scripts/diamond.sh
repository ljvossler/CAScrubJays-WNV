#!/bin/bash
# --------------------
### Directives Section
# --------------------
#SBATCH --job-name=rec_best_hits
#SBATCH --account=mcnew
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --time=10:00:00
#SBATCH --output ../slurm_outs/%x.out


source "/xdisk/mcnew/scrubjays_wnv/programs/CAScrubJays-WNV/params_base.sh"
module load diamond

source ~/.bashrc
micromamba activate diamond_env

export PATH=$PATH:${PROGDIR}/palign/palign

HUMAN_REF=/xdisk/mcnew/scrubjays_wnv/human_GRCh38_dataset/ncbi_dataset/data/GCF_000001405.40/GCF_000001405.40_GRCh38.p14_genomic.fna
THREADS=8
OUT_PATH=${OUTDIR}/datafiles/diamond

cd ${OUT_PATH}

diamond makedb --in ${REF} -d scrubjay
diamond makedb --in ${QUERY_FASTA} -d human


# Forward Search
diamond blastp -q human -d scrubjays -o forward_search.tsv --very-sensitive
# Reverse Search
diamond blastp -q scrubjays -d human -o reverse_search.tsv --very-sensitive

# Get Best Hits
${PROGDIR}/reciprologs/reciprologs forward_search.tsv reverse_search.tsv -p 8 -o scrubjays_human_rbh.csv 

echo "DONE"