#!/bin/bash
# --------------------
### Directives Section
# --------------------
#SBATCH --job-name=submit_trimming_array
#SBATCH --account=mcnew
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=01:00:00
#SBATCH --ntasks-per-node=12
##SBATCH --gres=gpu:1
#SBATCH --output submit_trimming_array.out
##SBATCH --constraint=hi_mem
##SBATCH --mem-per-cpu=41gb
#SBATCH --array=1-3

INPUTFASTQ="$( sed "${SLURM_ARRAY_TASK_ID}q;d" INPUTFASTQS )"
OUTFILE="$( echo trimming_${INPUTFASTQ}.out)"

source Genomics-Main/A_Preprocessing/A0.1_trimming.sh -p params_preprocessing.sh -i ${INPUTFASTQ} > $OUTFILE