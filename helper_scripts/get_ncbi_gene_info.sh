#!/bin/bash


source /xdisk/mcnew/scrubjays_wnv/programs/CAScrubJays-WNV/params_base.sh

cd ${OUTDIR}/datafiles/diamond

mkdir human
mkdir scrubjays

awk 'BEGIN { OFS="\t" } { print $1 }' rec_best_hits.txt > rec_best_hits_jays.txt
awk 'BEGIN { OFS="\t" } { print $2 }' rec_best_hits.txt > rec_best_hits_humans.txt

for code in $(cat rec_best_hits_jays.txt) 
do
    datasets summary gene accession $code > human/$code.json
done

for code in $(cat rec_best_hits_humans.txt)
do
    datasets summary gene accession $code > scrubjays/$code.json
done