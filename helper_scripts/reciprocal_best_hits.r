#!/usr/bin/env Rscript

cat("Checking required packages...\n")
# install Bioconductor
#if (!requireNamespace("BiocManager", quietly = TRUE))
#  install.packages("BiocManager")
#BiocManager::install()

# install Biostrings -> see here for different Biostrings verions:
# http://bioconductor.org/about/release-announcements/
#BiocManager::install(c("Biostrings"))

#if (!requireNamespace("devtools", quietly = TRUE))
#  install.packages("devtools")
# install the current version of rdiamond on your system
#devtools::install_github("drostlab/rdiamond", build_vignettes = TRUE, dependencies = TRUE)

library(rdiamond)

cat("Parsing command-line arguments...\n")
# Parse command-line arguments
args <- commandArgs(trailingOnly = TRUE)
query_file <- args[1]
subject_file <- args[2]
threads <- args[3]
out_path <- args[4]

best_rec_hits <- diamond_protein_to_protein_best_reciprocal_hits(
  query=query_file,
  subject=subject_file,
  sensitivity_mode = "ultra-sensitive", cores = 1, 
  out_format = "csv", format = "fasta",add_diamond_options = "--type protein")

cat("Finished\n")





