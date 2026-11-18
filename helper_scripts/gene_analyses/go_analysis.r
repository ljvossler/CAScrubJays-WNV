#!/usr/bin/env Rscript

# Load required packages, installing if necessary
required_packages <- c("clusterProfiler", "dplyr", "org.Hs.eg.db", "tidyr", "ggplot2", "msigdbr")
installed_packages <- rownames(installed.packages())

cat("Checking required packages...\n")
for (pkg in required_packages) {
  if (!(pkg %in% installed_packages)) {
    install.packages(pkg, repos = "http://cran.us.r-project.org")
  }
  library(pkg, character.only = TRUE)
}

cat("Parsing command-line arguments...\n")
# Parse command-line arguments
args <- commandArgs(trailingOnly = TRUE)
outdir <- args[1]
geneset <- args[2]
background <- args[3]
key_type <- args[4]
pval <- args[5]
qval <- args[6]
outname <- args[7]

geneset_vec <- readLines(geneset)
background_vec <- readLines(background)


cat("Performing enrichGO analysis...\n")
ego <- enrichGO(gene          = geneset_vec,
                keyType       = key_type,
                universe      = background_vec,
                OrgDb         = org.Hs.eg.db,
                ont           = "ALL",
                pAdjustMethod = "BH",
                pvalueCutoff  = pval,
                qvalueCutoff  = qval)


cat("Saving output to file...\n")
ego_df <- as.data.frame(ego)
write.table(ego_df, file = paste0(outdir, "/" , outname, ".tsv"), sep = '\t')

cat("DONE!\n")