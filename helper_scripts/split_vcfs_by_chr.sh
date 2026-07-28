#!/bin/bash

source params_base.sh

SCAFFOLD_LIST=${OUTDIR}/referencelists/SCAFFOLDS.txt
VCFFILE=${OUTDIR}/datafiles/vcf/placeholder.vcf.gz
OUTPREFIX=placeholder


echo VCF FILE PATH: $VCFFILE
echo SCAFFOLD SUBSET: $SCAFFOLD_LIST
echo OUTPUT PREFIX: $OUTPREFIX

# Split a VCF file by chromosome

for chr in $(cat $SCAFFOLD_LIST); do
    echo --chr $chr
    vcftools --chr $chr --vcf $VCFFILE --recode --recode-INFO-all | bgzip -c > ${OUTDIR}/datafiles/split_vcf/${OUTPREFIX}_${chr}.vcf.gz
    tabix -p vcf ${OUTDIR}/datafiles/split_vcf/${OUTPREFIX}_${chr}.vcf.gz
done