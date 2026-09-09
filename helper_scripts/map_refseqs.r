library(clusterProfiler)
library(org.Hs.eg.db) # Human annotations



cat("Parsing command-line arguments...\n")
# Parse command-line arguments
args <- commandArgs(trailingOnly = TRUE)
wnv_ensembl_file <- args[1]
diamond_file <- args[2]

# Convert WNV VIP IDs from ENSEMBL to REFSEQ
ensembl_ids <- readLines(wnv_ensembl_file)
wnv_refids <- bitr(ensembl_ids, fromType="ENSEMBL", toType=c("REFSEQ"), OrgDb="org.Hs.eg.db")
write.table(wnv_refids, file = "ensembl_refseq_vip.tsv", sep = "\t", col.names = FALSE, row.names = FALSE)

# Load Diamond Best Reciprocal Hit Data
rec_best_hits <- read.table(diamond_file, sep = '\t')
colnames(rec_best_hits) <- c("scrubjays_REFSEQ", "REFSEQ")
# Trim loci version number
trimmed_loci <- lapply(str_split(rec_best_hits$"REFSEQ", "\\."), `[`, 1)
rec_best_hits$REFSEQ <- trimmed_loci

# Merge and save
merged_df <- merge(wnv_refids, rec_best_hits, by="REFSEQ")
human_to_jay_refseq <- subset(merged_df, select = -ENSEMBL)
colnames(human_to_jay_refseq) <- c("human_REFSEQ", "scrubjay_REFSEQ")

write.table(human_to_jay_refseq, file="wnv_human_to_scrubjay_refseq_ids.txt", sep="\t", row.names=FALSE)
