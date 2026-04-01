#!/bin/bash

source params_base.sh

SCAFFOLD_LIST=${OUTDIR}/referencelists/SCAFFOLDS.txt
VCFDIR=${OUTDIR}/datafiles/phased_vcf
POPPREFIX=placeholder


echo VCF FILE PATH: $VCFDIR
echo SCAFFOLD SUBSET: $SCAFFOLD_LIST
echo OUTPUT PREFIX: $POPPREFIX

# Merge phased chr-split VCF files

SPLITVCFS=$(for chr in $(cat $SCAFFOLD_LIST); do echo ${OUTDIR}/datafiles/split_vcf/${POPPREFIX}_${chr}.phased.vcf.gz; done)
bcftools concat ${SPLITVCFS} -o ${OUTDIR}/datafiles/phased_vcf/${POPPREFIX}.phased.vcf.gz