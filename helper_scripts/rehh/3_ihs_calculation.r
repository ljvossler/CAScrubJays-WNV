library(ggplot2)
library(rehh)
library(vcfR)

# Should be run per-chromosome for a given population

cat("Parsing command-line arguments...\n")
args <- commandArgs(trailingOnly = TRUE)
vcf_fpath <- args[1]
polarize <- args[2] # should almost always be set to true. If not, review docs for alternate pipeline
outdir <- args[3]
chrom_id <- args[4]

# Scan vcf
# Load input files for single chromosome
hh <- data2haplohh(hap_file = vcf_fpath, polarize_vcf = polarize, vcf_reader = "vcfR")
# Calculate and Integrate EHH
scan <- scan_hh(hh)

write.table(scan, file = paste0(outdir, chrom_id, "_wscan.tsv"), sep = "\t")