#!/bin/bash

# Merge phased chr-split bcfs (to be used after SAPPHIRE rephasing)

source params_base.sh

SCAFFOLD_LIST=${OUTDIR}/referencelists/SCAFFOLDS.txt
BCFDIR=${OUTDIR}/datafiles/rephased_bcf/bcfs
POPPREFIX=alljays_rephased


echo BCF FILE PATH: $BCFDIR
echo SCAFFOLD SUBSET: $SCAFFOLD_LIST
echo OUTPUT PREFIX: $POPPREFIX

# Merge phased chr-split BCF files

SPLITBCFS=$(for chr in $(cat $SCAFFOLD_LIST); do echo ${BCFDIR}/${chr}_rephased.bcf; done)
bcftools concat ${SPLITBCFS} -o ${OUTDIR}/datafiles/rephased_bcf/${POPPREFIX}.bcf