library(clusterProfiler)
library(org.Hs.eg.db) # Human annotations
library(stringr)
library(dplyr)


cat("Parsing command-line arguments...\n")
# Parse command-line arguments
args <- commandArgs(trailingOnly = TRUE)
wnv_ensembl_file <- args[1]
diamond_file <- args[2]

# Convert WNV VIP IDs from ENSEMBL to REFSEQ/SYMBOL
ensembl_ids <- readLines(wnv_ensembl_file)

wnv_ens2refids <- bitr(ensembl_ids, fromType="ENSEMBL", toType=c("REFSEQ"), OrgDb="org.Hs.eg.db")
wnv_ens2symbols <- bitr(ensembl_ids, fromType="ENSEMBL", toType=c("SYMBOL"), OrgDb="org.Hs.eg.db")

colnames(wnv_ens2refids) <- c("human_ENSEMBL", "human_REFSEQ")
colnames(wnv_ens2symbols) <- c("human_ENSEMBL", "human_SYMBOL")

# Map WNV REFSEQS onto SYMBOLS
wnv_refids2symbols <- bitr(wnv_ens2refids$human_REFSEQ, fromType="REFSEQ", toType=c("SYMBOL"), OrgDb="org.Hs.eg.db")
colnames(wnv_refids2symbols) <- c("human_REFSEQ", "human_SYMBOL")

wnv_refids_cleaned <- unique(wnv_ens2refids$human_REFSEQ)
wnv_symbols_cleaned <- unique(wnv_ens2symbols$human_SYMBOL)

write.table(wnv_refids_cleaned, file = "wnv_vip_refseq.map", sep = "\t", col.names = FALSE, row.names = FALSE)
write.table(wnv_symbols_cleaned, file = "wnv_vip_symbol.map", sep = "\t", col.names = FALSE, row.names = FALSE)
write.table(wnv_refids2symbols, file = "wnv_vip_refseq2symbols.map", sep = "\t", col.names = FALSE, row.names = FALSE)

# Load Diamond Best Reciprocal Hit Data
rec_best_hits <- read.table(diamond_file, sep = '\t')
colnames(rec_best_hits) <- c("scrubjays_REFSEQ", "human_REFSEQ")
# Trim loci version number
trimmed_loci <- lapply(str_split(rec_best_hits$"human_REFSEQ", "\\."), `[`, 1)
rec_best_hits$human_REFSEQ <- trimmed_loci

# Merge and save
merged_df <- merge(wnv_refids2symbols, rec_best_hits, by="human_REFSEQ")
human_to_jay_refseq <- human_to_jay_refseq %>% distinct(human_REFSEQ, .keep_all = TRUE)

write.table(human_to_jay_refseq, file="wnv_human_to_jay_homolog.map", sep="\t", row.names=FALSE)
