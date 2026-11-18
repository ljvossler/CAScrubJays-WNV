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
genelist <- args[2] # This should be a tab-separated file containing all genes in your organism including any stats of interest (composite FST/TD, RSB, XPEHH, etc).
                    # Should also have a column with mapped human gene ids
metric <- args[3] # Should match a column name of a stat in the file you want
key_type <- args[4] # usually always SYMBOL
pval <- args[5]
outname <- args[7]

genelist_df <- read.table(genelist, header=1)

metric_scores <- genelist_df[c("human_gene_name", metric)]

cat("Sorting input data...\n")

metric_scores_nona <- metric_scores %>% drop_na()

labeled_meric_scores <- metric_scores_nona[[2]]
names(labeled_metric_scores) <- clean_df[[1]]

sorted_cs_scores <- sort(labeled_cs_scores, decreasing=TRUE)
sorted_cs_scores <- sorted_cs_scores[!duplicated(names(sorted_cs_scores))]

cat("Performing gseGO analysis...\n")
ego2 <- gseGO(geneList     = sorted_cs_scores,
              OrgDb        = org.Hs.eg.db,
              ont          = "ALL",
              minGSSize    = 100,
              maxGSSize    = 100000,
              pvalueCutoff = p_val,
              keyType       = key_type,
              scoreType    = "std")


cat("Performing MSigDB GSEA...\n")
H_t2g <- msigdbr(species = "Homo sapiens", collection = "H") |>
  dplyr::select(gs_name, gene_symbol)
em_H <- GSEA(sorted_metric_scores, TERM2GENE = H_t2g, pvalueCutoff = p_val)

C3_t2g <- msigdbr(species = "Homo sapiens", collection = "C3") |>
  dplyr::select(gs_name, gene_symbol)
em_C3 <- GSEA(sorted_metric_scores, TERM2GENE = C3_t2g, pvalueCutoff = p_val)

C5_t2g <- msigdbr(species = "Homo sapiens", collection = "C5") |>
  dplyr::select(gs_name, gene_symbol)
em_C5 <- GSEA(sorted_metric_scores, TERM2GENE = C5_t2g, pvalueCutoff = p_val)

C7_t2g <- msigdbr(species = "Homo sapiens", collection = "C7") |>
  dplyr::select(gs_name, gene_symbol)
em_C7 <- GSEA(sorted_metric_scores, TERM2GENE = C7_t2g, pvalueCutoff = p_val)


cat("Saving outputs to file...\n")


cat("DONE!\n")