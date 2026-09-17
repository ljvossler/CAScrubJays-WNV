#!/bin/bash
source ../params_base.sh

OUTNAME=alljays_pre_alljays_post
WIN=50000
STAT_DIR="${OUTDIR}/analyses/composite_stat/${OUTNAME}"
GENEFILE="${STAT_DIR}/${OUTNAME}.composite_score.additive.all_windows.genelist.txt"
ALL_GENEREFSEQS="${OUTDIR}/referencelists/${OUTNAME}.ALL.generefseqs.txt"
DIAMOND_OUT=${OUTDIR}/datafiles/diamond/rec_best_hits.txt


# Map all best hits for scrubjays from refseq to symbols
ALL_JAY_REFSEQS=$(awk '{ print $1 }' $DIAMOND_OUT)
for refseq in echo ${ALL_JAY_REFSEQS}; do     
    symbol=$(grep -w "${refseq//\"}" ${GENEFILE} | awk '{split($0, arr, ";"); print arr[6] }' | awk '!seen[$0]++' | sed 's/^gene=//')
    if [[ -n "$symbol" ]]; then
    echo $symbol,"${refseq//\"}" >> $ALL_GENEREFSEQS
    fi  
done
# Remove some parsing errors
sed -i '/exception=unclassified translation discrepancy/d' ${ALL_GENEREFSEQS}


Rscript - << 'EOF'
library(clusterProfiler)
library(org.Hs.eg.db) # Human annotations
library(org.Gs.eg.db) # Chicken annotations
library(stringr)

rec_best_hits <- read.table("/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/datafiles/diamond/rec_best_hits.txt")

# Map human refseqs to symbols
trimmed_hs_refseq <- lapply(str_split(rec_best_hits$"V2", "\\."), `[`, 1)
rec_hits_hs_symbols <- bitr(trimmed_hs_refseq, fromType="REFSEQ", toType=c("SYMBOL"), OrgDb="org.Hs.eg.db")
EOF



python3 - "${DIAMOND_OUT}" "/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/datafiles/diamond/rec_best_hits.txt" "${WNV_GENEREFSEQS}" << 'EOF'
import pandas as pd
import os, sys

rec_hits = sys.argv[1]
hs_refsym_map = sys.argv[2]
sj_refsym_map = sys.argv[3]

rec_hits = pd.read_csv(rec_hits, sep='\t', header=None)
rec_hits.columns = ['scrubjay_REFSEQ', 'human_REFSEQ']
rec_hits['human_REFSEQ'] = [x.split('.')[0] for x in rec_hits['human_REFSEQ']]

hs_refs_to_symbols = pd.read_csv(hs_refsym_map, sep=' ')
sj_ref_to_symbols = pd.read_csv(sj_refsym_map, header=None)
sj_ref_to_symbols.columns = ['scrubjay_SYMBOL', 'scrubjay_REFSEQ']

merged_df = pd.merge(rec_hits, hs_refs_to_symbols, on='human_REFSEQ')
merged_df2 = pd.merge(merged_df, sj_ref_to_symbols, on='scrubjay_REFSEQ')

merged_df2[['human_SYMBOL', 'scrubjay_SYMBOL']].to_csv('/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/referencelists/hs_sj_genesymbols.map', header=None, index=None, sep='\t')


perc01_genenames = pd.read_csv('/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/analyses/composite_stat/alljays_pre_alljays_post/alljays_pre_alljays_post.composite_score.additive.0.1perc.genenames.txt', sep='\t', header=None)
perc1_genenames = pd.read_csv('/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/analyses/composite_stat/alljays_pre_alljays_post/alljays_pre_alljays_post.composite_score.additive.1perc.genenames.txt', sep='\t', header=None)

perc01_symbol_map = pd.DataFrame(columns=['scrubjay_SYMBOL', 'human_SYMBOL'])
perc1_symbol_map = pd.DataFrame(columns=['scrubjay_SYMBOL', 'human_SYMBOL'])


hs_lst = []
sj_lst = []
for row in merged_df2.index:
    if merged_df2.loc[row, 'scrubjay_SYMBOL'] in list(perc01_genenames[0]):
        hs_lst.append(merged_df2.loc[row, 'human_SYMBOL'])
        sj_lst.append(merged_df2.loc[row, 'scrubjay_SYMBOL'])
perc01_symbol_map['scrubjay_SYMBOL'] = sj_lst
perc01_symbol_map['human_SYMBOL'] = hs_lst


hs_lst = []
sj_lst = []
for row in merged_df2.index:
    if merged_df2.loc[row, 'scrubjay_SYMBOL'] in list(perc1_genenames[0]):
        hs_lst.append(merged_df2.loc[row, 'human_SYMBOL'])
        sj_lst.append(merged_df2.loc[row, 'scrubjay_SYMBOL'])
perc1_symbol_map['scrubjay_SYMBOL'] = sj_lst
perc1_symbol_map['human_SYMBOL'] = hs_lst

perc1_symbol_map.to_csv('top_1perc_genesymbols.map', header=None, index=None, sep='\t')
perc01_symbol_map.to_csv('top_0.1perc_genesymbols.map', header=None, index=None, sep='\t')

EOF


