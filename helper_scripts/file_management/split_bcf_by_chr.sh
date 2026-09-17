#!/bin/bash

# Convert a phased vcf.gz file to bcf and split by chromosome (to be used in prep for SAPPHIRE rephasing)

source params_base.sh

SCAFFOLD_LIST=${OUTDIR}/referencelists/SCAFFOLDS.txt
BCF=${OUTDIR}/datafiles/genotype_calls/alljays_phased.bcf
OUTPREFIX=alljays_phased


echo BCF FILE PATH: $BCF
echo SCAFFOLD SUBSET: $SCAFFOLD_LIST


# Split a BCF file by chromosome

for chr in $(cat $SCAFFOLD_LIST); do
    echo $chr
    bcftools view -O b -r "$chr" $BCF > "${OUTDIR}/datafiles/genotype_calls/split_bcf/${OUTPREFIX}_${chr}.bcf"
    bcftools index "${OUTDIR}/datafiles/genotype_calls/split_bcf/${OUTPREFIX}_${chr}.bcf"
done