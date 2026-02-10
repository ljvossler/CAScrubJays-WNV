#!/bin/bash
# --------------------
### Directives Section
# --------------------
#SBATCH --job-name=submit_alignment_pipeline
#SBATCH --account=mcnew
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=24:00:00
#SBATCH --ntasks-per-node=12
#SBATCH --output %x_%a.out
#SBATCH --array=1-3

INPUTFASTQ="$( sed "${SLURM_ARRAY_TASK_ID}q;d" INPUTFASTQS )"

echo "\n"
echo "|---------------Trimming ${INPUTFASTQ}---------------|"
echo "\n"
source Genomics-Main/A_Preprocessing/A0.1_trimming.sh -p params_preprocessing.sh -i ${INPUTFASTQ}

echo "\n"
echo "|---------------Aligning ${INPUTFASTQ}---------------|"
echo "\n"
source Genomics-Main/A_Preprocessing/A0.2_alignandsort.sh -p params_preprocessing.sh -i ${INPUTFASTQ}

echo "\n"
echo "|---------------Clipping Overlaps for ${INPUTFASTQ}---------------|"
echo "\n"
source Genomics-Main/A_Preprocessing/A0.3_ClipOverlap.sh -p params_preprocessing.sh -i ${INPUTFASTQ}

echo "\n"
echo "|---------------Realigning around Indels for ${INPUTFASTQ}---------------|"
echo "\n"
source Genomics-Main/A_Preprocessing/A0.4_indelrealignment.sh -p params_preprocessing.sh -i ${INPUTFASTQ}

echo "\n"
echo "|---------------Completed Alignment Pipeline for ${INPUTFASTQ}---------------|"
echo "\n"