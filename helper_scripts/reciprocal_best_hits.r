#!/usr/bin/env Rscript

cat("Checking required packages...\n")
# install Bioconductor
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install()

# install Biostrings -> see here for different Biostrings verions:
# http://bioconductor.org/about/release-announcements/
BiocManager::install(c("Biostrings"))

# install.packages("devtools")
# install the current version of rdiamond on your system
devtools::install_github("drostlab/rdiamond", build_vignettes = TRUE, dependencies = TRUE)

cat("Parsing command-line arguments...\n")
# Parse command-line arguments
args <- commandArgs(trailingOnly = TRUE)
query_file <- args[1]
subject_file <- args[2]
threads <- args[3]
out_path <- args[3]

best_rec_hits <- diamond_protein_to_protein_best_reciprocal_hits(
  query   = system.file(query_file, package = 'rdiamond'),
  subject = system.file(subject_file, package = 'rdiamond'),
  sensitivity_mode = "ultra-sensitive", cores = threads, output_path  = out_path,
  use_arrow_duckdb_connection  = FALSE, out_format = "csv", format = "fasta")

cat("Finished\n")





