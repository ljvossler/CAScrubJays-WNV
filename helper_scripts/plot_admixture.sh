#!/bin/bash

OUTPREFIX=alljays
NUM_K=10
POPS=cascrubjays

source ../params_preprocessing.sh

cd ${OUTDIR}/analyses/admixture

# Collect all CV errors (https://speciationgenomics.github.io/ADMIXTURE/)
awk '/CV/ {print $3,$4}' *out | cut -c 4,7-20 > ${OUTPREFIX}.cv.error
awk '{split($1,name,"."); print $1,name[2]}' ${OUTPREFIX}.nosex > ${OUTPREFIX}.list

#wget -P ${PROGDIR} https://github.com/speciationgenomics/scripts/raw/master/plotADMIXTURE.r
#chmod +x ${PROGDIR}/plotADMIXTURE.r
Rscript ${PROGDIR}/plotADMIXTURE.r -p ${OUTPREFIX} -i ${OUTPREFIX}.list -k ${NUM_K} -l ${POPS}