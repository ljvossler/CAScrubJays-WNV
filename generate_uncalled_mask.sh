#!/bin/bash

# Generate a mapability mask for uncalled and low coverage regions from a list of BAM files
# To be used as mask for SMC++

source params_base.sh

POP=alljays


samtools merge -u - -b ${OUTDIR}/referencelists/${POP}.bamlist.txt --threads ${THREADS} | bedtools genomecov -ibam - -bga | awk '$4 < 5' > ${OUTDIR}/datafiles/mask/${POP}_low_coverage_raw.bed

bedtools sort -i ${OUTDIR}/datafiles/mask/${POP}_low_coverage_raw.bed | bedtools merge -i -  > ${OUTDIR}/datafiles/mask/${POP}_uncalled_raw.bed
sort -k1,1 -k2,2n ${OUTDIR}/datafiles/mask/${POP}_uncalled_raw.bed > ${OUTDIR}/datafiles/mask/${POP}_sorted_mask.bed

bgzip -c ${OUTDIR}/datafiles/mask/${POP}_sorted_mask.bed > ${OUTDIR}/datafiles/mask/${POP}_sorted_mask.bed.gz
tabix -p bed ${OUTDIR}/datafiles/mask/${POP}_sorted_mask.bed.gz