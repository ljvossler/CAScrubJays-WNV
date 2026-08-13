#!/bin/bash
# --------------------
### Directives Section
# --------------------
#SBATCH --job-name=callvars_alljays_split
#SBATCH --account=mcnew
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --time=150:00:00
#SBATCH --output ../slurm_outs/callvariants/%x.out


source ../params_preprocessing.sh

module load parallel

CONCURRENT_JOBS=8
CHROMS=${OUTDIR}/referencelists/SCAFFOLDS.chroms.txt
SCAFFOLDS=${OUTDIR}/referencelists/SCAFFOLDS.unlabeled.txt
RUNNAME=alljays
BAMLIST=${OUTDIR}/referencelists/alljays.bamlist.txt

echo "Parallel variant calling on macrochromosomes..."
cat ${CHROMS} | parallel --jobs "$CONCURRENT_JOBS" "
    bcftools mpileup -f ${REF} -r {} -b ${BAMLIST} -Ou -a FORMAT/AD,DP,INFO/AD,SP | \
    bcftools call -mv -Oz -V indels -o ${OUTDIR}/datafiles/genotype_calls/${RUNNAME}_snps_multiallelic_{}.vcf.gz"

echo "Calling vars for unplaced scaffolds group..."
bcftools mpileup -f ${REF} -R ${SCAFFOLDS} -b ${BAMLIST} -Ou -a FORMAT/AD,DP,INFO/AD,SP | \
bcftools call -mv -Oz -V indels -o ${OUTDIR}/datafiles/genotype_calls/${RUNNAME}_snps_multiallelic_scaffolds.vcf.gz

bcftools concat -f ${OUTDIR}/datafiles/genotype_calls/splitvcf_ordered_list.txt -Oz -o ${OUTDIR}/datafiles/genotype_calls/alljays_snps_multiallelic_merged.vcf.gz
bcftools index ${OUTDIR}/datafiles/genotype_calls/alljays_snps_multiallelic_merged.vcf.gz


# 7. Safe Concatenation and Normalization
# Reads chunks in exact .fai order to preserve structural integrity of the VCF index
#awk -v dir="${OUTDIR}" '{print dir "/" $1 ".vcf.gz"}' "${REF}.fai" | while read f; do 
#    [ -f "$f" ] && echo "$f"
#done > vcf_list.txt

#echo "Merging and normalizing split variant files..."
#bcftools concat --threads "$SLURM_CPUS_PER_TASK" -f vcf_list.txt -Ou | \
#bcftools norm --threads "$SLURM_CPUS_PER_TASK" -m -any -f "$REF" -Oz -o "$FINAL_OUT"

# 8. Index Final Compressed Multi-Sample VCF
#bcftools index --threads "$SLURM_CPUS_PER_TASK" "$FINAL_OUT"

#echo "Job complete. Multi-sample VCF available at: $FINAL_OUT"

echo "DONE"