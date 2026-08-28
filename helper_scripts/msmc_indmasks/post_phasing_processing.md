# Prepare Sample-split VCFs for VCFparsing

## Make merged bcf
```
module load bcftools

cd /xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/datafiles/rephased_bcf/allsites/bcfs
ls * .bcf > ordered_bcf_list.txt

bcftools concat -f ordered_bcf_list.txt -O b -o allsites_rephased_merged.bcf
bcftools index allsites_rephased_merged.bcf
```

## Split by sample
```
#!/bin/bash
# --------------------
### Directives Section
# --------------------
#SBATCH --job-name=split_by_sample_allsites
#SBATCH --account=mcnew
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=01:00:00
#SBATCH --output ../slurm_outs/phasing/%x_%a.out
#SBATCH --array=1-80

samples="/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/referencelists/alljays_sampleids.filtered.txt"

INPUT="$( sed "${SLURM_ARRAY_TASK_ID}q;d" ${samples} )"

BCF_IN=/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/datafiles/genotype_calls/allsites_phased/bcfs/allsites_rephased_merged.bcf
VCF_OUT=/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/datafiles/rephased_vcf/allsites/${INPUT}_rephased.vcf

module load bcftools

bcftools view -s ${INPUT} -O v -o ${VCF_OUT} ${BCF}
```