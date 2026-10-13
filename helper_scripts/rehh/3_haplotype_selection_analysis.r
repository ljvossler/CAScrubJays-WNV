library(ggplot2)
library(rehh)
library(vcfR)

# Should be run per-population for calculation of iHS

cat("Parsing command-line arguments...\n")
args <- commandArgs(trailingOnly = TRUE)
vcf_lst1 <- args[1]
vcf_lst2 <- args[2]
polarize <- args[3] # should almost always be set to true. If not, review docs for alternate pipeline
outdir <- args[4]
pop1 <- args[5]
pop2 <- args[6]

vcf_fpaths1 <- readLines(vcf_lst1)
vcf_fpaths2 <- readLines(vcf_lst2)

# Scan vcfs for pop1
for (fpath in vcf_fpaths1) {
  cat(paste0("scanning alleles for ", pop1," in ", fpath, "\n"))
  # Load input files
  hh <- data2haplohh(hap_file = fpath,
                     polarize_vcf = polarize,
                     vcf_reader = "vcfR")
  # Calculate and Integrate EHH
  scan <- scan_hh(hh)
  # Concatenate EHH scans for WGS data
  if (i == 1) {
    wgscan_pop1 <- scan
  } else {
    wgscan_pop1 <- rbind(wgscan_pop1, scan)
  }
}

# Scan vcfs for pop2
for (fpath in vcf_fpaths2) {
  cat(paste0("scanning alleles for ", pop2," in ", fpath, "\n"))
  # Load input files
  hh <- data2haplohh(hap_file = fpath,
                     polarize_vcf = polarize,
                     vcf_reader = "data.table")
  # Calculate and Integrate EHH
  scan <- scan_hh(hh)
  # Concatenate EHH scans for WGS data
  if (i == 1) {
    wgscan_pop2 <- scan
  } else {
    wgscan_pop2 <- rbind(wgscan_pop2, scan)
  }
}

write.table(wgscan_pop1, file = paste0(outdir, pop1, "_wscan.tsv"), sep = "\t")
write.table(wgscan_pop2, file = paste0(outdir, pop2, "_wscan.tsv"), sep = "\t")

# calculate genome-wide iHS values for each population
cat(paste0("calculating iHS...\n"))
wgs_ihs_pop1 <- ihh2ihs(wgscan_pop1)
wgs_ihs_pop2 <- ihh2ihs(wgscan_pop2)

# calculate rsb between two populations
cat(paste0("calculating RHS...\n"))
rsb_pop1_pop2 <- ines2rsb(scan_pop1 = wgscan_pop1,
                        scan_pop2 = wgscan_pop2,
                        popname1 = pop1,
                        popname2 = pop2)
write.table(rsb_pop1_pop2, file = paste0(outdir, pop1, "_", pop2, "_rsb.tsv"), sep = "\t")


# calculate xp-ehh between two populations
cat(paste0("calculating XP-EHH...\n"))
xpehh_pop1_pop2 <- ies2xpehh(scan_pop1 =  wgscan_pop1,
                           scan_pop2 =  wgscan_pop2,
                           popname1 = pop1,
                           popname2 = pop2)
write.table(xpehh_pop1_pop2, file = paste0(outdir, pop1, "_", pop2, "_xpehh.tsv"), sep = "\t")

# Plot statistics
manhattanplot(wgs_ihs)


plot(rsb_pop1_pop2[, paste0("RSB_", pop1, "_", pop2)],
     xpehh_pop1_pop2[, paste0("XPEHH_", pop1, "_", pop2)],
     xlab = "Rsb",
     ylab = "XP-EHH",
     pch = ".",
     xlim = c(-7.5, 7.5),
     ylim = c(-7.5, 7.5))
# add dashed diagonal
abline(a = 0, b = 1, lty = 2)
