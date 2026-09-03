#!/usr/bin/env Rscript

# Load required packages, installing if necessary
required_packages <- c("BiocManager")
installed_packages <- rownames(installed.packages())

cat("Checking required packages...\n")
for (pkg in required_packages) {
  if (!(pkg %in% installed_packages)) {
    install.packages(pkg, repos = "http://cran.us.r-project.org")
  }
  library(pkg, character.only = TRUE)
}

if (!requireNamespace("homologr", quietly = TRUE)) {
  BiocManager::install("drostlab/homologr")
}
library('homologr', character.only = TRUE)

cat("Parsing command-line arguments...\n")
# Parse command-line arguments
args <- commandArgs(trailingOnly = TRUE)
query_file <- args[1]
subject_file <- args[2]
cores <- args[3]
out_path <- args[3]

rec_best_hits <- diamond_reciprocal_best_hits(
  query   = system.file(query_file, package = 'homologr'),
  subject = system.file(subject_file, package = 'homologr'),
  cores   = 2, output_path  = out_path)


cat("Finished\n")





