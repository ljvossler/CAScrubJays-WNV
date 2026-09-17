# Build Background Gene Lists

library(clusterProfiler)
library(org.Hs.eg.db) # Human annotations
library(org.Gs.eg.db) # Chicken annotations
library(stringr)

rec_best_hits <- read.table("rec_best_hits.out")

trimmed_hs_refseq <- lapply(str_split(rec_best_hits$"V2", "\\."), `[`, 1)
rec_hits_hs_symbols <- bitr(trimmed_hs_refseq, fromType="REFSEQ", toType=c("SYMBOL"), OrgDb="org.Hs.eg.db")
write.table(rec_hits_hs_symbols, file = "/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/referencelists/rec_hits_hs_symbols.map")
# Load rec_best_hits
# Get full list of human refseqs from diamond and convert to symbols using clusterprofiler
# Get full list of scrubjay refseqs from diamond and map to symbols by greping GENEFILE

rec_hits_sj_index <- read.table("rec_best_hits.out", row.names=1)
rec_hits_sj_index$V2 <- trimmed_hs_refseq

rec_hits_sj_index$V2 <- lapply(str_split(rec_hits_sj_index$"V2", "\\."), `[`, 1)

colnames(rec_hits_sj_index) <- c("human_REFSEQ")
colnames(rec_hits_hs_symbols) <- c("human_REFSEQ", "human_SYMBOL")

merged_df <- merge(rec_hits_sj_index, rec_hits_hs_symbols, by="human_REFSEQ", all = FALSE)

# Make symbols map file between humans and scrubjays in R by merging them