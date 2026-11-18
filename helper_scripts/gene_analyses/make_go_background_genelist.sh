#!/bin/bash
# Make a file mapping scrubjay gene symbols to human ones. Similar to methods done in `build_master_genelist.sh` for WNV genes
source ../params_base.sh

OUTNAME=alljays_pre_alljays_post_nomaf
WIN=50000
STAT_DIR="${OUTDIR}/analyses/composite_stat/${OUTNAME}"
GENEFILE="${STAT_DIR}/${OUTNAME}.composite_score.additive.all_windows.genelist.txt"
JAY_SYMBOL2REFSEQ="${OUTDIR}/referencelists/${OUTNAME}.symbol2refseq.txt"
DIAMOND_OUT="${OUTDIR}/datafiles/diamond/rec_best_hits.tsv"


# Build refseq2symbol map by parsing GENEFILE.
JAY_REFSEQS=$(awk '{ print $1 }' $DIAMOND_OUT)
for refseq in echo ${JAY_REFSEQS}; do     
    symbol=$(grep -w "${refseq//\"}" ${GENEFILE} | awk '{split($0, arr, ";"); print arr[6] }' | awk '!seen[$0]++' | sed 's/^gene=//')
    if [[ -n "$symbol" ]]; then
    echo $symbol,"${refseq//\"}" >> $JAY_SYMBOL2REFSEQ
    fi  
done
# Remove some parsing errors
sed -i '/exception=unclassified translation discrepancy/d' ${JAY_SYMBOL2REFSEQ}
sed -i '/gbkey=CDS/d' ${JAY_SYMBOL2REFSEQ}

# Make scrubjay-human symbol map for doing go analyses
Rscript - "${DIAMOND_OUT}" "${OUTDIR}/referencelists" "${JAY_SYMBOL2REFSEQ}" << 'EOF'
library(clusterProfiler)
library(org.Hs.eg.db) # Human annotations
library(stringr)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)
diamond_file <- args[1]
outdir <- args[2]
jay_map <- args[3]

rec_best_hits <- read.table(diamond_file)
colnames(rec_best_hits) <- c("scrubjay_REFSEQ","human_REFSEQ")

jay_sym2ref <- read.table(jay_map, sep=',')
colnames(jay_sym2ref) <- c("scrubjay_SYMBOL","scrubjay_REFSEQ")

merged <- merge(rec_best_hits, jay_sym2ref, by="scrubjay_REFSEQ")


# First map human refseqs onto gene symbols
trimmed_hs_refs <- lapply(str_split(merged$human_REFSEQ, "\\."), `[`, 1)
merged$human_REFSEQ <- trimmed_hs_refs
hs_ref2sym <- bitr(trimmed_hs_refs, fromType="REFSEQ", toType=c("SYMBOL"), OrgDb="org.Hs.eg.db")
colnames(hs_ref2sym) <- c("human_REFSEQ", "human_SYMBOL")
hs_symbols <- hs_ref2sym$human_SYMBOL

merged2 <- merge(hs_ref2sym, merged, by="human_REFSEQ")
symbol_map <- merged2[c("scrubjay_SYMBOL", "human_SYMBOL")]
symbol_map <- symbol_map %>% distinct(scrubjay_SYMBOL, .keep_all = TRUE)

write.table(symbol_map, file=paste0(outdir, "/jay2human_symbol.map"), sep='\t', row.names=FALSE) # Map for converting jay symbols to human for making go analysis genesets
writeLines(hs_symbols, con = paste0(outdir, "/human_symbols_background_list.txt")) # Simple human symbol list for background geneset in go analysis
EOF