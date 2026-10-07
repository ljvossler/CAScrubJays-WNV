library(ggplot2)
library(rehh)
library(vcfR)

cat("Parsing command-line arguments...\n")
args <- commandArgs(trailingOnly = TRUE)
vcf_lst <- args[1]
polarize <- args[2]
outfile <- args[3]

vcf_fpaths <- readLines(vcf_lst)

for (fpath in vcf_fpaths) {
  # Load input files
  hh <- data2haplohh(hap_file = fpath,
                     polarize_vcf = polarize,
                     vcf_reader = "data.table")
  
  # Calculate and Integrate EHH
  scan <- scan_hh(hh)
  
  # Concatenate EHH scans for WGS data
  if (i == 1) {
    wgscan <- scan
  } else {
    wgscan <- rbind(wgscan, scan)
  }
}

# log ratio for alleles and standardization
wgs_ihs <- ihh2ihs(wgscan)
write.table(wgs_ihs, file = outfile)

# Plot statistics
manhattanplot(wgs_ihs)

