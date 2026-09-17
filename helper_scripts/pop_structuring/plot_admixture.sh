#!/bin/bash

OUTPREFIX=alljays
NUM_K=5
POPS="King,Pierce,Lewis,Multnomah,Deschutes,Klamath,Siskiyou,Shasta,Humboldt,Lassen,Tehama,Plumas,Colusa,Lake,Sonoma,Sacramento,Calaveras,ContraCosta,Alameda,SantaClara,SanBenito,Inyo,Monterey,SanLuisObispo,Kern,SanBernardino,SantaBarbara,Ventura,LosAngeles,Riverside,Orange,SanDiego,BajaCaliforniaSur"

source ../params_preprocessing.sh

cd ${OUTDIR}/analyses/admixture

# Collect all CV errors (https://speciationgenomics.github.io/ADMIXTURE/)
awk '/CV/ {print $3,$4}' *out | cut -c 4,7-20 > ${OUTPREFIX}.cv.error
awk '{split($1,name,"."); print $1,name[2]}' ${OUTPREFIX}.nosex > ${OUTPREFIX}.list

#wget -P ${PROGDIR} https://github.com/speciationgenomics/scripts/raw/master/plotADMIXTURE.r
#chmod +x ${PROGDIR}/plotADMIXTURE.r
Rscript ${PROGDIR}/plotADMIXTURE.r -p ${OUTPREFIX} -i ${OUTPREFIX}.list -k ${NUM_K} -l ${POPS}