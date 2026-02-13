#!/bin/bash
# --------------------
### Directives Section
# --------------------
#SBATCH --job-name=alignment_pipeline
#SBATCH --account=mcnew
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=48:00:00
#SBATCH --ntasks-per-node=12
#SBATCH --output %x_%a.out
#SBATCH --array=1-3

sample_ids="/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/referencelists/sampleids_subset.txt"

INPUT="$( sed "${SLURM_ARRAY_TASK_ID}q;d" ${sample_ids} )"

echo "\n"
echo "|---------------Trimming ${INPUT}---------------|"
echo "\n"
source Genomics-Main/A_Preprocessing/A0.1_trimming.sh -p params_preprocessing.sh -i ${INPUT}

echo "\n"
echo "|---------------Aligning ${INPUT}---------------|"
echo "\n"
source Genomics-Main/A_Preprocessing/A0.2_alignandsort.sh -p params_preprocessing.sh -i ${INPUT}

echo "\n"
echo "|---------------Clipping Overlaps for ${INPUT}---------------|"
echo "\n"
source Genomics-Main/A_Preprocessing/A0.3_ClipOverlap.sh -p params_preprocessing.sh -i ${INPUT}

echo "\n"
echo "|---------------Realigning around Indels for ${INPUT}---------------|"
echo "\n"
source Genomics-Main/A_Preprocessing/A0.4_indelrealignment.sh -p params_preprocessing.sh -i ${INPUT}

echo "\n"
echo "|---------------Completed Alignment Pipeline for ${INPUT}---------------|"
echo "\n"