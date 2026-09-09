#!/bin/bash

source ../params_base.sh
RECMAP_DIR=${OUTDIR}/datafiles/recombination_map
PYRHO_RUN=postjays_est_MLZ68995A

for scaffold in $(cat ${OUTDIR}/referencelists/SCAFFOLDS.txt);
do
    echo "making map for $scaffold"
    PYRHO_MAP=${RECMAP_DIR}/pyrho/${PYRHO_RUN}_${scaffold}.rmap
    REF_MAP=${RECMAP_DIR}/chr_split_refmaps/ref_linkage_map_${scaffold}.txt
    python3 pyrho_to_flexsweep.py -p ${PYRHO_MAP} -r ${REF_MAP} -s ${scaffold};
done

echo "done"
